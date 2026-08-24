<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Cart\AddCartItemRequest;
use App\Http\Requests\Cart\ApplyCouponRequest;
use App\Http\Requests\Cart\UpdateCartItemRequest;
use App\Http\Resources\CartResource;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\Product;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    use ApiResponse;

    protected function getOrCreateCart(Request $request): Cart
    {
        return Cart::firstOrCreate(['user_id' => $request->user()->id]);
    }

    public function show(Request $request): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);
        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Cart retrieved successfully'
        );
    }

    public function addItem(AddCartItemRequest $request): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);
        $validated = $request->validated();

        $product = Product::findOrFail($validated['product_id']);

        if ($product->status !== 'active') {
            return $this->error('This product is not available for purchase.', 422);
        }

        $existingItem = $cart->items()->where('product_id', $product->id)->first();
        $newQuantity = $existingItem ? $existingItem->quantity + $validated['quantity'] : $validated['quantity'];

        if ($product->stock < $newQuantity) {
            return $this->error("Only {$product->stock} units available in stock for '{$product->name}'.", 422);
        }

        if ($existingItem) {
            $existingItem->update([
                'quantity' => $newQuantity,
                'unit_price' => $product->effective_price,
            ]);
        } else {
            $cart->items()->create([
                'product_id' => $product->id,
                'quantity' => $validated['quantity'],
                'unit_price' => $product->effective_price,
            ]);
        }

        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Item added to cart successfully'
        );
    }

    public function updateItem(UpdateCartItemRequest $request, CartItem $item): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);

        if ($item->cart_id !== $cart->id) {
            return $this->error('Unauthorized cart item.', 403);
        }

        $product = $item->product;
        $quantity = $request->validated()['quantity'];

        if ($product && $product->stock < $quantity) {
            return $this->error("Only {$product->stock} units available in stock.", 422);
        }

        $item->update([
            'quantity' => $quantity,
            'unit_price' => $product ? $product->effective_price : $item->unit_price,
        ]);

        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Cart item updated successfully'
        );
    }

    public function removeItem(Request $request, CartItem $item): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);

        if ($item->cart_id !== $cart->id) {
            return $this->error('Unauthorized cart item.', 403);
        }

        $item->delete();
        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Item removed from cart successfully'
        );
    }

    public function clear(Request $request): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);
        $cart->items()->delete();
        $cart->update(['coupon_id' => null]);
        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Cart cleared successfully'
        );
    }

    public function applyCoupon(ApplyCouponRequest $request): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);
        $cart->load(['items.product']);

        $totals = $cart->calculateTotals();
        $subtotal = $totals['subtotal'];

        $coupon = Coupon::where('code', $request->validated()['code'])->firstOrFail();

        $error = null;
        if (!$coupon->isValidForAmount($subtotal, $error)) {
            return $this->error($error ?: 'Invalid coupon.', 422);
        }

        $cart->update(['coupon_id' => $coupon->id]);
        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Coupon applied successfully'
        );
    }

    public function removeCoupon(Request $request): JsonResponse
    {
        $cart = $this->getOrCreateCart($request);
        $cart->update(['coupon_id' => null]);
        $cart->load(['items.product.images', 'coupon']);

        return $this->success(
            new CartResource($cart),
            'Coupon removed successfully'
        );
    }
}
