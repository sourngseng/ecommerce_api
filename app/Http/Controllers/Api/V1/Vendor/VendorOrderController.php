<?php

namespace App\Http\Controllers\Api\V1\Vendor;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\UpdateOrderStatusRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class VendorOrderController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $vendor = $request->user()->vendor;

        if (!$vendor) {
            return $this->error('Vendor account not found.', 404);
        }

        $perPage = min((int) $request->query('per_page', 15), 100);

        $orders = Order::whereHas('items', function ($q) use ($vendor) {
            $q->where('vendor_id', $vendor->id);
        })
        ->with(['items' => function ($q) use ($vendor) {
            $q->where('vendor_id', $vendor->id)->with('product');
        }, 'payment'])
        ->latest()
        ->paginate($perPage);

        return $this->successWithPagination(
            $orders,
            OrderResource::collection($orders->items()),
            'Vendor orders retrieved successfully'
        );
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        Gate::authorize('view', $order);

        $vendor = $request->user()->vendor;

        $order->load(['items' => function ($q) use ($vendor) {
            if ($vendor) {
                $q->where('vendor_id', $vendor->id)->with('product');
            }
        }, 'payment', 'user']);

        return $this->success(
            new OrderResource($order),
            'Order details retrieved successfully'
        );
    }

    public function updateStatus(UpdateOrderStatusRequest $request, Order $order): JsonResponse
    {
        Gate::authorize('updateStatus', $order);

        $order->update($request->validated());

        $vendor = $request->user()->vendor;
        $order->load(['items' => function ($q) use ($vendor) {
            if ($vendor) {
                $q->where('vendor_id', $vendor->id)->with('product');
            }
        }, 'payment', 'user']);

        return $this->success(
            new OrderResource($order),
            'Order status updated successfully'
        );
    }
}
