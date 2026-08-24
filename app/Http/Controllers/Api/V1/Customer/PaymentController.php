<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Payment\ProcessPaymentRequest;
use App\Http\Resources\PaymentResource;
use App\Models\Order;
use App\Models\Payment;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class PaymentController extends Controller
{
    use ApiResponse;

    public function show(Order $order): JsonResponse
    {
        Gate::authorize('view', $order);

        $payment = $order->payment;

        if (!$payment) {
            return $this->error('No payment record found for this order.', 404);
        }

        return $this->success(
            new PaymentResource($payment),
            'Payment details retrieved successfully'
        );
    }

    public function process(ProcessPaymentRequest $request, Order $order): JsonResponse
    {
        Gate::authorize('view', $order);

        if ($order->status === 'cancelled') {
            return $this->error('Cannot process payment for a cancelled order.', 422);
        }

        $validated = $request->validated();
        $payment = $order->payment;

        if ($payment && $payment->status === 'paid') {
            return $this->error('This order has already been paid.', 422);
        }

        $paymentMethod = $validated['payment_method'];
        $paymentStatus = match ($paymentMethod) {
            'cash_on_delivery' => 'pending',
            'demo_card' => 'paid',
            'bank_transfer' => 'paid',
            default => 'paid',
        };

        $paymentDetails = [
            'method' => $paymentMethod,
            'gateway' => 'demo_gateway',
            'processed_at' => now()->toIso8601String(),
        ];

        if ($paymentMethod === 'demo_card') {
            $paymentDetails['card_last4'] = substr($validated['card_number'] ?? '4242', -4);
        }

        if (!$payment) {
            $payment = Payment::create([
                'order_id' => $order->id,
                'payment_method' => $paymentMethod,
                'transaction_reference' => 'PAY-' . strtoupper(\Illuminate\Support\Str::random(12)),
                'amount' => $order->grand_total,
                'status' => $paymentStatus,
                'payment_details' => $paymentDetails,
                'paid_at' => $paymentStatus === 'paid' ? now() : null,
            ]);
        } else {
            $payment->update([
                'payment_method' => $paymentMethod,
                'status' => $paymentStatus,
                'payment_details' => $paymentDetails,
                'paid_at' => $paymentStatus === 'paid' ? now() : null,
            ]);
        }

        if ($paymentStatus === 'paid' && $order->status === 'pending') {
            $order->update(['status' => 'confirmed']);
        }

        return $this->success(
            new PaymentResource($payment),
            'Payment processed successfully'
        );
    }
}
