<?php

namespace Tests\Feature;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CouponTest extends TestCase
{
    use RefreshDatabase;

    public function test_cannot_apply_expired_coupon(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create(['price' => 100.00, 'stock' => 10, 'status' => 'active']);

        $cart = Cart::create(['user_id' => $customer->id]);
        CartItem::create(['cart_id' => $cart->id, 'product_id' => $product->id, 'quantity' => 1, 'unit_price' => 100.00]);

        $expiredCoupon = Coupon::factory()->create([
            'code' => 'EXPIRED99',
            'start_date' => now()->subDays(20),
            'end_date' => now()->subDays(5),
            'status' => 'active',
        ]);

        $response = $this->actingAs($customer)->postJson('/api/v1/cart/apply-coupon', [
            'code' => 'EXPIRED99',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'message' => 'This coupon has expired.',
            ]);
    }

    public function test_cannot_apply_coupon_if_order_below_minimum_amount(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create(['price' => 20.00, 'stock' => 10, 'status' => 'active']);

        $cart = Cart::create(['user_id' => $customer->id]);
        CartItem::create(['cart_id' => $cart->id, 'product_id' => $product->id, 'quantity' => 1, 'unit_price' => 20.00]);

        $coupon = Coupon::factory()->create([
            'code' => 'MIN100',
            'minimum_order_amount' => 100.00,
            'status' => 'active',
        ]);

        $response = $this->actingAs($customer)->postJson('/api/v1/cart/apply-coupon', [
            'code' => 'MIN100',
        ]);

        $response->assertStatus(422);
    }
}
