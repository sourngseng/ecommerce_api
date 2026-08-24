<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Review\StoreReviewRequest;
use App\Http\Requests\Review\UpdateReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Models\Order;
use App\Models\Product;
use App\Models\Review;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ReviewController extends Controller
{
    use ApiResponse;

    public function productReviews(Product $product): JsonResponse
    {
        $reviews = $product->reviews()->with('user')->where('status', 'approved')->latest()->get();

        return $this->success(
            ReviewResource::collection($reviews),
            'Product reviews retrieved successfully'
        );
    }

    public function store(StoreReviewRequest $request, Product $product): JsonResponse
    {
        $user = $request->user();

        // Check if customer purchased this product
        $purchasedOrder = Order::where('user_id', $user->id)
            ->whereIn('status', ['delivered', 'shipped', 'confirmed', 'processing'])
            ->whereHas('items', function ($query) use ($product) {
                $query->where('product_id', $product->id);
            })
            ->first();

        if (!$purchasedOrder) {
            return $this->error('Only customers who have purchased this product can submit a review.', 403);
        }

        // Check if customer already reviewed this product
        $existingReview = Review::where('user_id', $user->id)
            ->where('product_id', $product->id)
            ->first();

        if ($existingReview) {
            return $this->error('You have already reviewed this product.', 422);
        }

        $validated = $request->validated();
        $review = Review::create([
            'user_id' => $user->id,
            'product_id' => $product->id,
            'order_id' => $purchasedOrder->id,
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
            'status' => 'approved',
        ]);

        $product->updateRatingStats();

        $review->load('user');

        return $this->success(
            new ReviewResource($review),
            'Review submitted successfully',
            201
        );
    }

    public function update(UpdateReviewRequest $request, Review $review): JsonResponse
    {
        Gate::authorize('update', $review);

        $review->update($request->validated());
        $review->product->updateRatingStats();

        $review->load('user');

        return $this->success(
            new ReviewResource($review),
            'Review updated successfully'
        );
    }

    public function destroy(Review $review): JsonResponse
    {
        Gate::authorize('delete', $review);

        $product = $review->product;
        $review->delete();

        $product->updateRatingStats();

        return $this->success(null, 'Review deleted successfully');
    }
}
