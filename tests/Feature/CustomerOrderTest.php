<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerOrderTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_checkout_and_place_order(): void
    {
        $customer = User::factory()->customer()->create();
        $vendor = Vendor::factory()->create();
        $product = Product::factory()->create([
            'vendor_id' => $vendor->id,
            'price' => 100.00,
            'discount_price' => null,
            'stock' => 10,
            'status' => 'active',
        ]);

        $cart = Cart::create(['user_id' => $customer->id]);
        CartItem::create([
            'cart_id' => $cart->id,
            'product_id' => $product->id,
            'quantity' => 2,
            'unit_price' => 100.00,
        ]);

        $response = $this->actingAs($customer)->postJson('/api/v1/customer/orders', [
            'shipping_address' => [
                'recipient_name' => 'Kosal Seng',
                'phone' => '+855 12 345 678',
                'address_line_1' => '#12, St. 2004',
                'city' => 'Phnom Penh',
                'province' => 'Phnom Penh',
            ],
            'payment_method' => 'demo_card',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'pending',
                    'subtotal' => 200.00,
                ],
            ]);

        // Verify stock deducted
        $this->assertEquals(8, $product->fresh()->stock);

        // Verify inventory transaction logged
        $this->assertDatabaseHas('inventory_transactions', [
            'product_id' => $product->id,
            'type' => 'order_deduction',
            'quantity_change' => -2,
        ]);

        // Verify cart is cleared
        $this->assertEquals(0, $cart->fresh()->items()->count());
    }

    public function test_customer_can_cancel_pending_order_and_restores_stock(): void
    {
        $customer = User::factory()->customer()->create();
        $vendor = Vendor::factory()->create();
        $product = Product::factory()->create(['vendor_id' => $vendor->id, 'stock' => 8]);

        $order = Order::factory()->create([
            'user_id' => $customer->id,
            'status' => 'pending',
        ]);

        $order->items()->create([
            'product_id' => $product->id,
            'vendor_id' => $vendor->id,
            'product_name' => $product->name,
            'unit_price' => 100.00,
            'quantity' => 2,
            'total_price' => 200.00,
        ]);

        $response = $this->actingAs($customer)->postJson("/api/v1/customer/orders/{$order->id}/cancel");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'cancelled',
                ],
            ]);

        // Stock restored from 8 to 10
        $this->assertEquals(10, $product->fresh()->stock);

        $this->assertDatabaseHas('inventory_transactions', [
            'product_id' => $product->id,
            'type' => 'order_cancellation_restoration',
            'quantity_change' => 2,
        ]);
    }
}
