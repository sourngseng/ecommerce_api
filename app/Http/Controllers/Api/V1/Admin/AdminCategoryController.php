<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Category\StoreCategoryRequest;
use App\Http\Requests\Category\UpdateCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class AdminCategoryController extends Controller
{
    use ApiResponse;

    public function store(StoreCategoryRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $validated['slug'] = Str::slug($validated['name']);

        $category = Category::create($validated);

        return $this->success(
            new CategoryResource($category),
            'Category created successfully',
            201
        );
    }

    public function update(UpdateCategoryRequest $request, Category $category): JsonResponse
    {
        $validated = $request->validated();

        if (isset($validated['name']) && $validated['name'] !== $category->name) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $category->update($validated);

        return $this->success(
            new CategoryResource($category),
            'Category updated successfully'
        );
    }

    public function destroy(Category $category): JsonResponse
    {
        if ($category->products()->exists()) {
            return $this->error('Cannot delete category because it contains active products.', 422);
        }

        $category->delete();

        return $this->success(null, 'Category deleted successfully');
    }
}
