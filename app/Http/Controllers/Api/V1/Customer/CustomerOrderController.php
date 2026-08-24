<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\CreateOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Address;
use App\Models\Cart;
use App\Models\InventoryTransaction;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Product;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;

class CustomerOrderController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $perPage = min((int) $request->query('per_page', 15), 100);
        $orders = $request->user()->orders()
            ->with(['items.product', 'payment', 'coupon'])
            ->latest()
            ->paginate($perPage);

        return $this->successWithPagination(
            $orders,
            OrderResource::collection($orders->items()),
            'Orders retrieved successfully'
        );
    }

    public function store(CreateOrderRequest $request): JsonResponse
    {
        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)->with(['items.product', 'coupon'])->first();

        if (!$cart || $cart->items->isEmpty()) {
            return $this->error('Your shopping cart is empty.', 422);
        }

        $validated = $request->validated();

        // Resolve shipping address
        $shippingAddress = [];
        if (!empty($validated['address_id'])) {
            $address = Address::where('id', $validated['address_id'])->where('user_id', $user->id)->firstOrFail();
            $shippingAddress = [
                'recipient_name' => $address->recipient_name,
                'phone' => $address->phone,
                'address_line_1' => $address->address_line_1,
                'address_line_2' => $address->address_line_2,
                'city' => $address->city,
                'province' => $address->province,
                'postal_code' => $address->postal_code,
            ];
        } else {
            $shippingAddress = $validated['shipping_address'];
        }

        // Validate stock for all cart items
        foreach ($cart->items as $item) {
            $product = $item->product;
            if (!$product || $product->status !== 'active') {
                return $this->error("Product '{$item->product?->name}' is no longer available.", 422);
            }
            if ($product->stock < $item->quantity) {
                return $this->error("Not enough stock available for '{$product->name}'. Available: {$product->stock}.", 422);
            }
        }

        $totals = $cart->calculateTotals();

        $order = DB::transaction(function () use ($user, $cart, $totals, $shippingAddress, $validated) {
            // Create Order
            $order = Order::create([
                'order_number' => 'ORD-' . strtoupper(Str::random(10)),
                'user_id' => $user->id,
                'coupon_id' => $cart->coupon_id,
                'status' => 'pending',
                'subtotal' => $totals['subtotal'],
                'discount_amount' => $totals['discount'],
                'tax_amount' => $totals['tax'],
                'shipping_amount' => $totals['shipping'],
                'grand_total' => $totals['grand_total'],
                'shipping_address' => $shippingAddress,
                'notes' => $validated['notes'] ?? null,
            ]);

            // Create Order Items and adjust inventory
            foreach ($cart->items as $item) {
                $product = $item->product;
                $unitPrice = $product->effective_price;
                $totalPrice = $unitPrice * $item->quantity;

                $order->items()->create([
                    'product_id' => $product->id,
                    'vendor_id' => $product->vendor_id,
                    'product_name' => $product->name,
                    'unit_price' => $unitPrice,
                    'quantity' => $item->quantity,
                    'total_price' => $totalPrice,
                ]);

                // Deduct stock & log inventory transaction
                $prevStock = $product->stock;
                $newStock = $prevStock - $item->quantity;
                $product->update(['stock' => $newStock]);

                InventoryTransaction::create([
                    'product_id' => $product->id,
                    'vendor_id' => $product->vendor_id,
                    'type' => 'order_deduction',
                    'quantity_change' => -$item->quantity,
                    'previous_stock' => $prevStock,
                    'current_stock' => $newStock,
                    'reference_id' => (string) $order->id,
                    'notes' => "Order #{$order->order_number} placed",
                ]);
            }

            // If coupon was used, increment usage count
            if ($cart->coupon) {
                $cart->coupon->increment('times_used');
            }

            // Create initial payment record
            Payment::create([
                'order_id' => $order->id,
                'payment_method' => $validated['payment_method'],
                'transaction_reference' => 'PAY-' . strtoupper(Str::random(12)),
                'amount' => $totals['grand_total'],
                'status' => 'pending',
            ]);

            // Clear Cart
            $cart->items()->delete();
            $cart->update(['coupon_id' => null]);

            return $order;
        });

        $order->load(['items.product', 'payment', 'coupon']);

        return $this->success(
            new OrderResource($order),
            'Order created successfully',
            201
        );
    }

    public function show(Order $order): JsonResponse
    {
        Gate::authorize('view', $order);

        $order->load(['items.product', 'payment', 'coupon']);

        return $this->success(
            new OrderResource($order),
            'Order details retrieved successfully'
        );
    }

    public function cancel(Order $order): JsonResponse
    {
        Gate::authorize('cancel', $order);

        if (!$order->canBeCancelled()) {
            return $this->error('Order cannot be cancelled at its current status.', 422);
        }

        DB::transaction(function () use ($order) {
            $order->update(['status' => 'cancelled']);

            // Restore product stock and record inventory transaction
            foreach ($order->items as $item) {
                if ($item->product) {
                    $prevStock = $item->product->stock;
                    $newStock = $prevStock + $item->quantity;
                    $item->product->update(['stock' => $newStock]);

                    InventoryTransaction::create([
                        'product_id' => $item->product_id,
                        'vendor_id' => $item->vendor_id,
                        'type' => 'order_cancellation_restoration',
                        'quantity_change' => $item->quantity,
                        'previous_stock' => $prevStock,
                        'current_stock' => $newStock,
                        'reference_id' => (string) $order->id,
                        'notes' => "Order #{$order->order_number} cancelled",
                    ]);
                }
            }

            if ($order->payment && $order->payment->status === 'paid') {
                $order->payment->update(['status' => 'refunded']);
            }
        });

        $order->load(['items.product', 'payment', 'coupon']);

        return $this->success(
            new OrderResource($order),
            'Order cancelled successfully'
        );
    }
}
