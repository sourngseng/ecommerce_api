<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_categories(): void
    {
        Category::factory()->count(3)->create(['status' => 'active']);

        $response = $this->getJson('/api/v1/categories');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'data',
                'meta' => ['current_page', 'total'],
            ]);
    }

    public function test_can_get_single_category(): void
    {
        $category = Category::factory()->create(['name' => 'Electronics']);

        $response = $this->getJson('/api/v1/categories/' . $category->id);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $category->id,
                    'name' => 'Electronics',
                ],
            ]);
    }

    public function test_can_list_products_by_category(): void
    {
        $category = Category::factory()->create();
        Product::factory()->count(2)->create(['category_id' => $category->id, 'status' => 'active']);

        $response = $this->getJson("/api/v1/categories/{$category->id}/products");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);
        $this->assertCount(2, $response->json('data'));
    }

    public function test_admin_can_create_category(): void
    {
        $admin = User::factory()->admin()->create();

        $response = $this->actingAs($admin)->postJson('/api/v1/admin/categories', [
            'name' => 'Home & Living',
            'description' => 'Home accessories and furniture',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => ['name' => 'Home & Living', 'slug' => 'home-living'],
            ]);

        $this->assertDatabaseHas('categories', ['slug' => 'home-living']);
    }

    public function test_customer_cannot_create_category(): void
    {
        $customer = User::factory()->customer()->create();

        $response = $this->actingAs($customer)->postJson('/api/v1/admin/categories', [
            'name' => 'Unauthorized Category',
        ]);

        $response->assertStatus(403);
    }
}
