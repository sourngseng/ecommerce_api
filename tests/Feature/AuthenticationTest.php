<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_as_customer(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Kosal Dara',
            'email' => 'kosal@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'phone' => '+855 12 333 444',
            'role' => 'customer',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'User registered successfully',
            ])
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user' => ['id', 'name', 'email', 'role'],
                    'access_token',
                    'token_type',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'kosal@example.com',
            'role' => 'customer',
        ]);
    }

    public function test_user_can_register_as_vendor_and_creates_vendor_profile(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Ratanak Vong',
            'email' => 'ratanak@store.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'vendor',
            'shop_name' => 'Ratanak Tech Store',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('vendors', [
            'shop_name' => 'Ratanak Tech Store',
        ]);
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => 'secret123',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'secret123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Logged in successfully',
            ])
            ->assertJsonStructure([
                'data' => ['access_token', 'user'],
            ]);
    }

    public function test_user_cannot_login_with_invalid_password(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => 'secret123',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
                'message' => 'Invalid email or password.',
            ]);
    }

    public function test_authenticated_user_can_get_me(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'email' => $user->email,
                ],
            ]);
    }

    public function test_authenticated_user_can_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/auth/logout');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Logged out successfully',
            ]);
    }
}
