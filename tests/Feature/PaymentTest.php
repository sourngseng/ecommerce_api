<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_process_demo_card_payment(): void
    {
        $customer = User::factory()->customer()->create();
        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'status' => 'pending',
            'grand_total' => 150.00,
        ]);

        $response = $this->actingAs($customer)->postJson("/api/v1/customer/orders/{$order->id}/payment", [
            'payment_method' => 'demo_card',
            'card_number' => '4242424242421234',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'payment_method' => 'demo_card',
                    'status' => 'paid',
                ],
            ]);

        $this->assertEquals('confirmed', $order->fresh()->status);
    }
}
