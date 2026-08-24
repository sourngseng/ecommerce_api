<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerProfileAndAddressTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_view_and_update_profile(): void
    {
        $customer = User::factory()->customer()->create(['name' => 'Original Name']);

        $response = $this->actingAs($customer)->putJson('/api/v1/customer/profile', [
            'name' => 'Updated Name',
            'phone' => '+855 99 888 777',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'name' => 'Updated Name',
                    'phone' => '+855 99 888 777',
                ],
            ]);
    }

    public function test_customer_can_manage_addresses(): void
    {
        $customer = User::factory()->customer()->create();

        // Create address
        $responseCreate = $this->actingAs($customer)->postJson('/api/v1/customer/addresses', [
            'recipient_name' => 'Vannak Heng',
            'phone' => '+855 12 999 000',
            'address_line_1' => '#88, St. 271',
            'city' => 'Phnom Penh',
            'province' => 'Phnom Penh',
            'postal_code' => '12300',
            'is_default' => true,
        ]);

        $responseCreate->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'recipient_name' => 'Vannak Heng',
                    'is_default' => true,
                ],
            ]);

        $addressId = $responseCreate->json('data.id');

        // Update address
        $responseUpdate = $this->actingAs($customer)->putJson("/api/v1/customer/addresses/{$addressId}", [
            'address_line_1' => '#99, St. 271 (New House)',
        ]);

        $responseUpdate->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'address_line_1' => '#99, St. 271 (New House)',
                ],
            ]);

        // Delete address
        $responseDelete = $this->actingAs($customer)->deleteJson("/api/v1/customer/addresses/{$addressId}");
        $responseDelete->assertStatus(200);

        $this->assertDatabaseMissing('addresses', ['id' => $addressId]);
    }
}
