<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Models\Vendor;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    use ApiResponse;

    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $role = $validated['role'] ?? 'customer';

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
            'role' => $role,
            'status' => 'active',
        ]);

        if ($role === 'vendor') {
            $shopName = $validated['shop_name'] ?? $validated['name'] . "'s Shop";
            Vendor::create([
                'user_id' => $user->id,
                'shop_name' => $shopName,
                'slug' => Str::slug($shopName) . '-' . Str::random(5),
                'phone' => $validated['phone'] ?? null,
                'email' => $validated['email'],
                'status' => 'active',
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return $this->success([
            'user' => new UserResource($user->load('vendor')),
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 'User registered successfully', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return $this->error('Invalid email or password.', 401);
        }

        if ($user->status !== 'active') {
            return $this->error('Your account is ' . $user->status . '.', 403);
        }

        $deviceName = $validated['device_name'] ?? 'auth_token';
        $token = $user->createToken($deviceName)->plainTextToken;

        return $this->success([
            'user' => new UserResource($user->load('vendor')),
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 'Logged in successfully');
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->success(null, 'Logged out successfully');
    }

    public function me(Request $request): JsonResponse
    {
        return $this->success(
            new UserResource($request->user()->load('vendor')),
            'Current user profile retrieved successfully'
        );
    }
}
