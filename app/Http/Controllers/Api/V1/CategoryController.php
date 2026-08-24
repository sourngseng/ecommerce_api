<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Models\Category;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Category::withCount('products');

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        } else {
            $query->where('status', 'active');
        }

        $sort = $request->query('sort_by', 'created_at');
        $order = $request->query('sort_order', 'desc');
        if (in_array($sort, ['name', 'created_at'], true)) {
            $query->orderBy($sort, in_array(strtolower($order), ['asc', 'desc'], true) ? $order : 'desc');
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $categories = $query->paginate($perPage);

        return $this->successWithPagination(
            $categories,
            CategoryResource::collection($categories->items()),
            'Categories retrieved successfully'
        );
    }

    public function show(Category $category): JsonResponse
    {
        $category->loadCount('products');

        return $this->success(
            new CategoryResource($category),
            'Category details retrieved successfully'
        );
    }

    public function products(Request $request, Category $category): JsonResponse
    {
        $query = $category->products()->with(['category', 'vendor', 'images'])->where('status', 'active');

        if ($request->filled('search')) {
            $query->search($request->query('search'));
        }

        if ($request->filled('min_price')) {
            $query->where('price', '>=', (float) $request->query('min_price'));
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', (float) $request->query('max_price'));
        }

        $sort = $request->query('sort_by', 'created_at');
        $order = $request->query('sort_order', 'desc');
        if (in_array($sort, ['price', 'created_at', 'name', 'average_rating'], true)) {
            $query->orderBy($sort, in_array(strtolower($order), ['asc', 'desc'], true) ? $order : 'desc');
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $products = $query->paginate($perPage);

        return $this->successWithPagination(
            $products,
            ProductResource::collection($products->items()),
            'Category products retrieved successfully'
        );
    }
}
