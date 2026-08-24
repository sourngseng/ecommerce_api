<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\UpdateOrderStatusRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Order::with(['user', 'items.product', 'payment', 'coupon']);

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('order_number', 'like', "%{$search}%")
                  ->orWhereHas('user', function ($uq) use ($search) {
                      $uq->where('name', 'like', "%{$search}%")
                         ->orWhere('email', 'like', "%{$search}%");
                  });
            });
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $orders = $query->latest()->paginate($perPage);

        return $this->successWithPagination(
            $orders,
            OrderResource::collection($orders->items()),
            'All orders retrieved successfully'
        );
    }

    public function show(Order $order): JsonResponse
    {
        $order->load(['user', 'items.product', 'items.vendor', 'payment', 'coupon']);

        return $this->success(
            new OrderResource($order),
            'Order details retrieved successfully'
        );
    }

    public function updateStatus(UpdateOrderStatusRequest $request, Order $order): JsonResponse
    {
        $order->update($request->validated());
        $order->load(['user', 'items.product', 'payment', 'coupon']);

        return $this->success(
            new OrderResource($order),
            'Order status updated successfully'
        );
    }
}
