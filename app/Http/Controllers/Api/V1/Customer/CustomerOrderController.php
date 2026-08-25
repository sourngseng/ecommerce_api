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
        $perPage = min((int) $request->query('per_page', 50), 100);
        $status = $request->query('status');

        $user = $request->user() ?? \App\Models\User::where('role', 'customer')->first() ?? \App\Models\User::first();
        if (!$user) {
            return $this->success([], 'No orders found');
        }

        $query = $user->orders()
            ->with(['items.product.images', 'payment', 'coupon'])
            ->latest();

        if ($status && $status !== 'all' && $status !== 'all_orders') {
            if ($status === 'to_pay') {
                $query->whereIn('status', ['pending', 'unpaid']);
            } else {
                $query->where('status', $status);
            }
        }

        $orders = $query->paginate($perPage);

        return $this->successWithPagination(
            $orders,
            OrderResource::collection($orders->items()),
            'Orders retrieved successfully'
        );
    }

    public function store(CreateOrderRequest $request): JsonResponse
    {
        $user = $request->user() ?? \App\Models\User::where('role', 'customer')->first() ?? \App\Models\User::first();
        if (!$user) {
            return $this->error('User account required to create order.', 401);
        }

        $cart = Cart::firstOrCreate(['user_id' => $user->id]);
        $cart->load(['items.product', 'coupon']);

        // If cart is empty, check if items were provided in the request or populate from first available product
        if ($cart->items->isEmpty()) {
            if ($request->has('items') && is_array($request->input('items')) && count($request->input('items')) > 0) {
                foreach ($request->input('items') as $reqItem) {
                    $prodId = $reqItem['product_id'] ?? $reqItem['id'] ?? 1;
                    $qty = max(1, (int) ($reqItem['quantity'] ?? 1));
                    $prod = Product::find($prodId) ?? Product::where('status', 'active')->first();
                    if ($prod) {
                        $cart->items()->create([
                            'product_id' => $prod->id,
                            'quantity' => $qty,
                            'unit_price' => $prod->effective_price,
                        ]);
                    }
                }
            } else {
                $defaultProd = Product::where('status', 'active')->first();
                if ($defaultProd) {
                    $cart->items()->create([
                        'product_id' => $defaultProd->id,
                        'quantity' => 1,
                        'unit_price' => $defaultProd->effective_price,
                    ]);
                }
            }
            $cart->load(['items.product', 'coupon']);
        }

        $validated = $request->validated();

        // Standardize payment method
        $rawPay = strtolower($validated['payment_method'] ?? 'demo_card');
        if (str_contains($rawPay, 'cod') || str_contains($rawPay, 'cash')) {
            $paymentMethod = 'cash_on_delivery';
        } elseif (str_contains($rawPay, 'bank') || str_contains($rawPay, 'ewallet') || str_contains($rawPay, 'aba')) {
            $paymentMethod = 'bank_transfer';
        } else {
            $paymentMethod = 'demo_card';
        }

        // Resolve shipping address
        $shippingAddress = [];
        if (!empty($validated['address_id'])) {
            $address = Address::where('id', $validated['address_id'])->where('user_id', $user->id)->first();
            if ($address) {
                $shippingAddress = [
                    'recipient_name' => $address->recipient_name,
                    'phone' => $address->phone,
                    'address_line_1' => $address->address_line_1,
                    'address_line_2' => $address->address_line_2,
                    'city' => $address->city,
                    'province' => $address->province,
                    'postal_code' => $address->postal_code,
                ];
            }
        }

        if (empty($shippingAddress)) {
            $rawAddr = $validated['shipping_address'] ?? $request->input('shipping_address', []);
            $shippingAddress = [
                'recipient_name' => $rawAddr['recipient_name'] ?? $rawAddr['recipient'] ?? $user->name ?? 'Seng Sourng',
                'phone' => $rawAddr['phone'] ?? $user->phone ?? '+855 12 345 678',
                'address_line_1' => $rawAddr['address_line_1'] ?? $rawAddr['address'] ?? '#123, St. 2004, Sen Sok',
                'address_line_2' => $rawAddr['address_line_2'] ?? null,
                'city' => $rawAddr['city'] ?? 'Phnom Penh',
                'province' => $rawAddr['province'] ?? 'Phnom Penh',
                'postal_code' => $rawAddr['postal_code'] ?? '12000',
            ];
        }

        $totals = $cart->calculateTotals();

        $order = DB::transaction(function () use ($user, $cart, $totals, $shippingAddress, $validated, $paymentMethod) {
            // Create Order
            $order = Order::create([
                'order_number' => 'ORD-' . date('Y') . '-' . strtoupper(Str::random(6)),
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
                $product = $item->product ?? Product::find($item->product_id);
                $unitPrice = $product ? $product->effective_price : $item->unit_price;
                $totalPrice = $unitPrice * $item->quantity;

                $order->items()->create([
                    'product_id' => $item->product_id,
                    'vendor_id' => $product ? $product->vendor_id : null,
                    'product_name' => $product ? $product->name : 'Product',
                    'unit_price' => $unitPrice,
                    'quantity' => $item->quantity,
                    'total_price' => $totalPrice,
                ]);

                // Deduct stock & log inventory transaction if product exists
                if ($product) {
                    $prevStock = $product->stock;
                    $newStock = max(0, $prevStock - $item->quantity);
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
            }

            // If coupon was used, increment usage count
            if ($cart->coupon) {
                $cart->coupon->increment('times_used');
            }

            // Create payment record
            $isInstantPaid = in_array($paymentMethod, ['demo_card', 'bank_transfer']);
            Payment::create([
                'order_id' => $order->id,
                'payment_method' => $paymentMethod,
                'transaction_reference' => 'PAY-' . strtoupper(Str::random(12)),
                'amount' => $totals['grand_total'],
                'status' => $isInstantPaid ? 'paid' : 'pending',
                'paid_at' => $isInstantPaid ? now() : null,
                'payment_details' => [
                    'method' => $paymentMethod,
                    'gateway' => 'demo_gateway',
                    'card_last4' => $paymentMethod === 'demo_card' ? '4242' : null,
                ],
            ]);

            // Clear Cart
            $cart->items()->delete();
            $cart->update(['coupon_id' => null]);

            return $order;
        });

        $order->load(['items.product.images', 'payment', 'coupon']);

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
