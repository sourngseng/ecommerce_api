<?php

namespace Tests\Feature;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CartTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_add_product_to_cart_and_calculates_total(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create([
            'price' => 50.00,
            'discount_price' => 45.00,
            'stock' => 10,
            'status' => 'active',
        ]);

        $response = $this->actingAs($customer)->postJson('/api/v1/cart/items', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'calculation' => [
                        'subtotal' => 90.00,
                        'items_count' => 2,
                    ],
                ],
            ]);
    }

    public function test_cannot_add_more_quantity_than_available_stock(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create([
            'stock' => 3,
            'status' => 'active',
        ]);

        $response = $this->actingAs($customer)->postJson('/api/v1/cart/items', [
            'product_id' => $product->id,
            'quantity' => 5,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_customer_can_apply_coupon_to_cart(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create([
            'price' => 100.00,
            'discount_price' => null,
            'stock' => 10,
            'status' => 'active',
        ]);

        $coupon = Coupon::factory()->create([
            'code' => 'DISCOUNT20',
            'type' => 'percentage',
            'value' => 20.00,
            'minimum_order_amount' => 50.00,
            'status' => 'active',
        ]);

        // Add to cart
        $this->actingAs($customer)->postJson('/api/v1/cart/items', [
            'product_id' => $product->id,
            'quantity' => 1,
        ]);

        // Apply coupon
        $response = $this->actingAs($customer)->postJson('/api/v1/cart/apply-coupon', [
            'code' => 'DISCOUNT20',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'calculation' => [
                        'subtotal' => 100.00,
                        'discount' => 20.00,
                        'grand_total' => 80.00,
                    ],
                ],
            ]);
    }
}
