<?php

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Customer\StoreAddressRequest;
use App\Http\Requests\Customer\UpdateAddressRequest;
use App\Http\Resources\AddressResource;
use App\Models\Address;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AddressController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $addresses = $request->user()->addresses()->orderBy('is_default', 'desc')->latest()->get();

        return $this->success(
            AddressResource::collection($addresses),
            'Addresses retrieved successfully'
        );
    }

    public function store(StoreAddressRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        if (!empty($validated['is_default']) && $validated['is_default']) {
            $user->addresses()->update(['is_default' => false]);
        }

        $address = $user->addresses()->create($validated);

        return $this->success(
            new AddressResource($address),
            'Address created successfully',
            201
        );
    }

    public function show(Address $address): JsonResponse
    {
        Gate::authorize('view', $address);

        return $this->success(
            new AddressResource($address),
            'Address retrieved successfully'
        );
    }

    public function update(UpdateAddressRequest $request, Address $address): JsonResponse
    {
        Gate::authorize('update', $address);

        $validated = $request->validated();

        if (!empty($validated['is_default']) && $validated['is_default']) {
            $request->user()->addresses()->where('id', '!=', $address->id)->update(['is_default' => false]);
        }

        $address->update($validated);

        return $this->success(
            new AddressResource($address),
            'Address updated successfully'
        );
    }

    public function destroy(Address $address): JsonResponse
    {
        Gate::authorize('delete', $address);

        $address->delete();

        return $this->success(null, 'Address deleted successfully');
    }
}
