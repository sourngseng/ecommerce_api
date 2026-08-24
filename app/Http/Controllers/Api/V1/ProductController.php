<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Product::with(['category', 'vendor', 'images'])->where('status', 'active');

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->query('category_id'));
        }

        if ($request->filled('vendor_id')) {
            $query->where('vendor_id', $request->query('vendor_id'));
        }

        if ($request->filled('min_price')) {
            $query->where('price', '>=', (float) $request->query('min_price'));
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', (float) $request->query('max_price'));
        }

        if ($request->boolean('featured') || $request->query('is_featured') === '1') {
            $query->featured();
        }

        if ($request->filled('search')) {
            $query->search($request->query('search'));
        }

        $sort = $request->query('sort_by', 'created_at');
        $order = $request->query('sort_order', 'desc');
        if (in_array($sort, ['price', 'created_at', 'name', 'average_rating', 'stock'], true)) {
            $query->orderBy($sort, in_array(strtolower($order), ['asc', 'desc'], true) ? $order : 'desc');
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $products = $query->paginate($perPage);

        return $this->successWithPagination(
            $products,
            ProductResource::collection($products->items()),
            'Products retrieved successfully'
        );
    }

    public function show(Product $product): JsonResponse
    {
        $product->load(['category', 'vendor', 'images', 'reviews.user']);

        return $this->success(
            new ProductResource($product),
            'Product details retrieved successfully'
        );
    }

    public function search(Request $request): JsonResponse
    {
        $term = $request->query('q') ?? $request->query('search');

        if (!$term) {
            return $this->error('Search term is required.', 422);
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $products = Product::with(['category', 'vendor', 'images'])
            ->where('status', 'active')
            ->search($term)
            ->paginate($perPage);

        return $this->successWithPagination(
            $products,
            ProductResource::collection($products->items()),
            'Search results retrieved successfully'
        );
    }

    public function related(Product $product): JsonResponse
    {
        $relatedProducts = Product::with(['category', 'vendor', 'images'])
            ->where('status', 'active')
            ->where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->latest()
            ->limit(10)
            ->get();

        return $this->success(
            ProductResource::collection($relatedProducts),
            'Related products retrieved successfully'
        );
    }
}
