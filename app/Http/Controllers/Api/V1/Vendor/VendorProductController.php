<?php

namespace App\Http\Controllers\Api\V1\Vendor;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\StoreProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\InventoryTransaction;
use App\Models\Product;
use App\Models\Vendor;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;

class VendorProductController extends Controller
{
    use ApiResponse;

    protected function getVendor(Request $request): Vendor
    {
        $user = $request->user();
        return Vendor::firstOrCreate(
            ['user_id' => $user->id],
            [
                'shop_name' => $user->name . "'s Shop",
                'slug' => Str::slug($user->name . "'s Shop") . '-' . Str::random(5),
                'email' => $user->email,
                'phone' => $user->phone,
                'status' => 'active',
            ]
        );
    }

    public function index(Request $request): JsonResponse
    {
        $vendor = $this->getVendor($request);
        $perPage = min((int) $request->query('per_page', 15), 100);

        $products = $vendor->products()
            ->with(['category', 'images'])
            ->latest()
            ->paginate($perPage);

        return $this->successWithPagination(
            $products,
            ProductResource::collection($products->items()),
            'Vendor products retrieved successfully'
        );
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $vendor = $this->getVendor($request);
        $validated = $request->validated();

        $product = DB::transaction(function () use ($vendor, $validated) {
            $slug = Str::slug($validated['name']) . '-' . Str::random(5);

            $product = $vendor->products()->create([
                'category_id' => $validated['category_id'],
                'name' => $validated['name'],
                'slug' => $slug,
                'sku' => $validated['sku'],
                'description' => $validated['description'] ?? null,
                'price' => $validated['price'],
                'discount_price' => $validated['discount_price'] ?? null,
                'stock' => $validated['stock'],
                'image' => $validated['image'] ?? null,
                'is_featured' => $validated['is_featured'] ?? false,
                'status' => $validated['status'] ?? 'active',
            ]);

            if ($validated['stock'] > 0) {
                InventoryTransaction::create([
                    'product_id' => $product->id,
                    'vendor_id' => $vendor->id,
                    'type' => 'restock',
                    'quantity_change' => $validated['stock'],
                    'previous_stock' => 0,
                    'current_stock' => $validated['stock'],
                    'notes' => 'Initial stock on product creation',
                ]);
            }

            return $product;
        });

        $product->load(['category', 'vendor', 'images']);

        return $this->success(
            new ProductResource($product),
            'Product created successfully',
            201
        );
    }

    public function show(Request $request, Product $product): JsonResponse
    {
        Gate::authorize('update', $product);

        $product->load(['category', 'vendor', 'images', 'reviews.user']);

        return $this->success(
            new ProductResource($product),
            'Product details retrieved successfully'
        );
    }

    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        Gate::authorize('update', $product);

        $validated = $request->validated();

        DB::transaction(function () use ($product, $validated) {
            if (isset($validated['name']) && $validated['name'] !== $product->name) {
                $validated['slug'] = Str::slug($validated['name']) . '-' . Str::random(5);
            }

            if (isset($validated['stock']) && $validated['stock'] !== $product->stock) {
                $prevStock = $product->stock;
                $newStock = $validated['stock'];
                $diff = $newStock - $prevStock;

                InventoryTransaction::create([
                    'product_id' => $product->id,
                    'vendor_id' => $product->vendor_id,
                    'type' => $diff > 0 ? 'restock' : 'adjustment',
                    'quantity_change' => $diff,
                    'previous_stock' => $prevStock,
                    'current_stock' => $newStock,
                    'notes' => 'Manual stock update by vendor',
                ]);
            }

            $product->update($validated);
        });

        $product->load(['category', 'vendor', 'images']);

        return $this->success(
            new ProductResource($product),
            'Product updated successfully'
        );
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        Gate::authorize('delete', $product);

        $product->delete();

        return $this->success(null, 'Product deleted successfully');
    }
}
