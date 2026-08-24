<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\WishlistResource;
use App\Models\Product;
use App\Models\Wishlist;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $wishlist = $request->user()->wishlist()->with('product.images')->latest()->get();

        return $this->success(
            WishlistResource::collection($wishlist),
            'Wishlist items retrieved successfully'
        );
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'product_id' => ['required', 'exists:products,id'],
        ]);

        $user = $request->user();
        $productId = $request->input('product_id');

        $exists = $user->wishlist()->where('product_id', $productId)->exists();

        if ($exists) {
            return $this->error('Product is already in your wishlist.', 422);
        }

        $item = $user->wishlist()->create([
            'product_id' => $productId,
        ]);

        $item->load('product.images');

        return $this->success(
            new WishlistResource($item),
            'Product added to wishlist successfully',
            201
        );
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        $deleted = $request->user()->wishlist()->where('product_id', $product->id)->delete();

        if (!$deleted) {
            return $this->error('Product not found in your wishlist.', 404);
        }

        return $this->success(null, 'Product removed from wishlist successfully');
    }

    public function clear(Request $request): JsonResponse
    {
        $request->user()->wishlist()->delete();

        return $this->success(null, 'Wishlist cleared successfully');
    }
}
