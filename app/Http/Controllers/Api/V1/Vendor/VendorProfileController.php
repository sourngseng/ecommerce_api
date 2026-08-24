<?php

namespace App\Http\Controllers\Api\V1\Vendor;

use App\Http\Controllers\Controller;
use App\Http\Requests\Vendor\UpdateVendorProfileRequest;
use App\Http\Resources\VendorResource;
use App\Models\Vendor;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class VendorProfileController extends Controller
{
    use ApiResponse;

    protected function getOrCreateVendor(Request $request): Vendor
    {
        $user = $request->user();
        return Vendor::firstOrCreate(
            ['user_id' => $user->id],
            [
                'shop_name' => $user->name . "'s Shop",
                'slug' => Str::slug($user->name . "'s Shop") . '-' . Str::random(5),
                'email' => $user->email,
                'phone' => $user->phone,
                'status' => 'active',
            ]
        );
    }

    public function show(Request $request): JsonResponse
    {
        $vendor = $this->getOrCreateVendor($request);
        $vendor->loadCount('products');

        return $this->success(
            new VendorResource($vendor),
            'Vendor profile retrieved successfully'
        );
    }

    public function update(UpdateVendorProfileRequest $request): JsonResponse
    {
        $vendor = $this->getOrCreateVendor($request);
        $validated = $request->validated();

        if (isset($validated['shop_name']) && $validated['shop_name'] !== $vendor->shop_name) {
            $validated['slug'] = Str::slug($validated['shop_name']) . '-' . Str::random(5);
        }

        $vendor->update($validated);
        $vendor->loadCount('products');

        return $this->success(
            new VendorResource($vendor),
            'Vendor profile updated successfully'
        );
    }
}
