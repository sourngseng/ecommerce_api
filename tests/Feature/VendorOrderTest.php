<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VendorOrderTest extends TestCase
{
    use RefreshDatabase;

    public function test_vendor_can_only_see_orders_with_their_products(): void
    {
        $vendor1User = User::factory()->vendor()->create();
        $vendor1 = Vendor::factory()->create(['user_id' => $vendor1User->id]);

        $vendor2User = User::factory()->vendor()->create();
        $vendor2 = Vendor::factory()->create(['user_id' => $vendor2User->id]);

        $customer = User::factory()->customer()->create();

        // Order with Vendor 1 product
        $order1 = Order::factory()->create(['user_id' => $customer->id]);
        $prod1 = Product::factory()->create(['vendor_id' => $vendor1->id]);
        OrderItem::factory()->create(['order_id' => $order1->id, 'vendor_id' => $vendor1->id, 'product_id' => $prod1->id]);

        // Order with Vendor 2 product
        $order2 = Order::factory()->create(['user_id' => $customer->id]);
        $prod2 = Product::factory()->create(['vendor_id' => $vendor2->id]);
        OrderItem::factory()->create(['order_id' => $order2->id, 'vendor_id' => $vendor2->id, 'product_id' => $prod2->id]);

        $response = $this->actingAs($vendor1User)->getJson('/api/v1/vendor/orders');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals($order1->id, $response->json('data.0.id'));
    }

    public function test_vendor_can_update_order_status(): void
    {
        $vendorUser = User::factory()->vendor()->create();
        $vendor = Vendor::factory()->create(['user_id' => $vendorUser->id]);
        $customer = User::factory()->customer()->create();

        $order = Order::factory()->create(['user_id' => $customer->id, 'status' => 'confirmed']);
        $prod = Product::factory()->create(['vendor_id' => $vendor->id]);
        OrderItem::factory()->create(['order_id' => $order->id, 'vendor_id' => $vendor->id, 'product_id' => $prod->id]);

        $response = $this->actingAs($vendorUser)->putJson("/api/v1/vendor/orders/{$order->id}/status", [
            'status' => 'processing',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'processing',
                ],
            ]);
    }
}
