<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\VendorResource;
use App\Models\Vendor;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Vendor::withCount('products')->where('status', 'active');

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('shop_name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $vendors = $query->paginate($perPage);

        return $this->successWithPagination(
            $vendors,
            VendorResource::collection($vendors->items()),
            'Vendors retrieved successfully'
        );
    }

    public function show(Vendor $vendor): JsonResponse
    {
        $vendor->load(['products' => function ($q) {
            $q->where('status', 'active')->with(['category', 'images'])->latest()->limit(12);
        }])->loadCount('products');

        return $this->success(
            new VendorResource($vendor),
            'Vendor details retrieved successfully'
        );
    }
}
