<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_who_purchased_can_submit_review_and_updates_average_rating(): void
    {
        $customer = User::factory()->customer()->create();
        $vendor = Vendor::factory()->create();
        $product = Product::factory()->create(['vendor_id' => $vendor->id]);

        $order = Order::factory()->create(['user_id' => $customer->id, 'status' => 'delivered']);
        OrderItem::factory()->create([
            'order_id' => $order->id,
            'vendor_id' => $vendor->id,
            'product_id' => $product->id,
        ]);

        $response = $this->actingAs($customer)->postJson("/api/v1/products/{$product->id}/reviews", [
            'rating' => 5,
            'comment' => 'Truly outstanding product!',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'rating' => 5,
                    'comment' => 'Truly outstanding product!',
                ],
            ]);

        $this->assertEquals(5.00, $product->fresh()->average_rating);
        $this->assertEquals(1, $product->fresh()->reviews_count);
    }

    public function test_customer_who_did_not_purchase_cannot_submit_review(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create();

        $response = $this->actingAs($customer)->postJson("/api/v1/products/{$product->id}/reviews", [
            'rating' => 4,
            'comment' => 'I never bought this.',
        ]);

        $response->assertStatus(403);
    }
}
