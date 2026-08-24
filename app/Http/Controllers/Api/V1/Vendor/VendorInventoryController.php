<?php

namespace App\Http\Controllers\Api\V1\Vendor;

use App\Http\Controllers\Controller;
use App\Http\Resources\InventoryTransactionResource;
use App\Http\Resources\ProductResource;
use App\Models\InventoryTransaction;
use App\Models\Product;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorInventoryController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $vendor = $request->user()->vendor;

        if (!$vendor) {
            return $this->error('Vendor account not found.', 404);
        }

        $perPage = min((int) $request->query('per_page', 15), 100);

        $query = Product::where('vendor_id', $vendor->id)->with(['category', 'images']);

        if ($request->filled('search')) {
            $query->search($request->query('search'));
        }

        if ($request->filled('low_stock')) {
            $query->where('stock', '<=', (int) $request->query('low_stock', 5));
        }

        $products = $query->orderBy('stock', 'asc')->paginate($perPage);

        return $this->successWithPagination(
            $products,
            ProductResource::collection($products->items()),
            'Vendor inventory retrieved successfully'
        );
    }

    public function transactions(Request $request): JsonResponse
    {
        $vendor = $request->user()->vendor;

        if (!$vendor) {
            return $this->error('Vendor account not found.', 404);
        }

        $perPage = min((int) $request->query('per_page', 15), 100);

        $query = InventoryTransaction::where('vendor_id', $vendor->id)->with('product');

        if ($request->filled('type')) {
            $query->where('type', $request->query('type'));
        }

        if ($request->filled('product_id')) {
            $query->where('product_id', $request->query('product_id'));
        }

        $transactions = $query->latest()->paginate($perPage);

        return $this->successWithPagination(
            $transactions,
            InventoryTransactionResource::collection($transactions->items()),
            'Inventory transactions retrieved successfully'
        );
    }
}
