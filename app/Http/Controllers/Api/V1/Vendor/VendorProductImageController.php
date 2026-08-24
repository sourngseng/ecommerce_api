<?php

namespace App\Http\Controllers\Api\V1\Vendor;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\StoreProductImageRequest;
use App\Http\Resources\ProductImageResource;
use App\Models\Product;
use App\Models\ProductImage;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class VendorProductImageController extends Controller
{
    use ApiResponse;

    public function store(StoreProductImageRequest $request, Product $product): JsonResponse
    {
        Gate::authorize('update', $product);

        $validated = $request->validated();

        if (!empty($validated['is_primary']) && $validated['is_primary']) {
            $product->images()->update(['is_primary' => false]);
            $product->update(['image' => $validated['image_url']]);
        }

        $image = $product->images()->create($validated);

        return $this->success(
            new ProductImageResource($image),
            'Product image added successfully',
            201
        );
    }

    public function destroy(Product $product, ProductImage $image): JsonResponse
    {
        Gate::authorize('update', $product);

        if ($image->product_id !== $product->id) {
            return $this->error('Image does not belong to this product.', 422);
        }

        $image->delete();

        return $this->success(null, 'Product image deleted successfully');
    }
}
