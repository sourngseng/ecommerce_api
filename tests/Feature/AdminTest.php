<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_access_dashboard_metrics(): void
    {
        $admin = User::factory()->admin()->create();
        $vendorUser = User::factory()->vendor()->create();
        $vendor = Vendor::factory()->create(['user_id' => $vendorUser->id]);
        $category = Category::factory()->create();
        $customer = User::factory()->customer()->create();

        Product::factory()->create(['vendor_id' => $vendor->id, 'category_id' => $category->id]);
        Order::factory()->create(['user_id' => $customer->id, 'status' => 'delivered', 'grand_total' => 150.00]);

        $response = $this->actingAs($admin)->getJson('/api/v1/admin/dashboard');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'metrics' => [
                        'total_customers' => 1,
                        'total_vendors' => 1,
                        'total_categories' => 1,
                        'total_orders' => 1,
                        'completed_orders' => 1,
                        'total_sales' => 150.00,
                    ],
                ],
            ]);
    }

    public function test_admin_can_view_all_orders_and_update_status(): void
    {
        $admin = User::factory()->admin()->create();
        $order = Order::factory()->create(['status' => 'processing']);

        $response = $this->actingAs($admin)->putJson("/api/v1/admin/orders/{$order->id}/status", [
            'status' => 'shipped',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'shipped',
                ],
            ]);
    }
}
