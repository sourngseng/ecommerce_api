<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_and_filter_products(): void
    {
        $category = Category::factory()->create();
        $vendor = Vendor::factory()->create();

        Product::factory()->create([
            'category_id' => $category->id,
            'vendor_id' => $vendor->id,
            'name' => 'iPhone 15 Pro',
            'price' => 999.00,
            'status' => 'active',
        ]);

        Product::factory()->create([
            'category_id' => $category->id,
            'name' => 'Cheap Cover',
            'price' => 10.00,
            'status' => 'active',
        ]);

        $response = $this->getJson("/api/v1/products?category_id={$category->id}&min_price=500");

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('iPhone 15 Pro', $response->json('data.0.name'));
    }

    public function test_can_search_products(): void
    {
        Product::factory()->create([
            'name' => 'Sony Wireless Headphones',
            'status' => 'active',
        ]);

        Product::factory()->create([
            'name' => 'Nike Shoes',
            'status' => 'active',
        ]);

        $response = $this->getJson('/api/v1/products/search?q=Headphones');

        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertStringContainsString('Sony', $response->json('data.0.name'));
    }

    public function test_vendor_can_create_product(): void
    {
        $vendorUser = User::factory()->vendor()->create();
        $vendor = Vendor::factory()->create(['user_id' => $vendorUser->id]);
        $category = Category::factory()->create();

        $response = $this->actingAs($vendorUser)->postJson('/api/v1/vendor/products', [
            'category_id' => $category->id,
            'name' => 'MacBook Air M2',
            'sku' => 'MBA-M2-256',
            'description' => 'Super fast laptop',
            'price' => 1099.00,
            'discount_price' => 999.00,
            'stock' => 15,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'name' => 'MacBook Air M2',
                    'sku' => 'MBA-M2-256',
                    'stock' => 15,
                ],
            ]);

        $this->assertDatabaseHas('products', [
            'sku' => 'MBA-M2-256',
            'vendor_id' => $vendor->id,
        ]);

        $this->assertDatabaseHas('inventory_transactions', [
            'vendor_id' => $vendor->id,
            'quantity_change' => 15,
        ]);
    }

    public function test_vendor_cannot_update_another_vendors_product(): void
    {
        $vendor1User = User::factory()->vendor()->create();
        $vendor1 = Vendor::factory()->create(['user_id' => $vendor1User->id]);

        $vendor2User = User::factory()->vendor()->create();
        $vendor2 = Vendor::factory()->create(['user_id' => $vendor2User->id]);

        $product = Product::factory()->create(['vendor_id' => $vendor1->id]);

        $response = $this->actingAs($vendor2User)->putJson("/api/v1/vendor/products/{$product->id}", [
            'name' => 'Hacked Product Name',
        ]);

        $response->assertStatus(403);
    }
}
