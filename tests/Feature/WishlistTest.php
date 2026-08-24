<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\User;
use App\Models\Wishlist;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WishlistTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_add_product_to_wishlist(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create();

        $response = $this->actingAs($customer)->postJson('/api/v1/wishlist/items', [
            'product_id' => $product->id,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'product_id' => $product->id,
                ],
            ]);
    }

    public function test_cannot_add_duplicate_item_to_wishlist(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create();

        Wishlist::create([
            'user_id' => $customer->id,
            'product_id' => $product->id,
        ]);

        $response = $this->actingAs($customer)->postJson('/api/v1/wishlist/items', [
            'product_id' => $product->id,
        ]);

        $response->assertStatus(422);
    }

    public function test_customer_can_remove_item_and_clear_wishlist(): void
    {
        $customer = User::factory()->customer()->create();
        $product = Product::factory()->create();

        Wishlist::create([
            'user_id' => $customer->id,
            'product_id' => $product->id,
        ]);

        $response = $this->actingAs($customer)->deleteJson("/api/v1/wishlist/items/{$product->id}");
        $response->assertStatus(200);
        $this->assertDatabaseMissing('wishlists', ['user_id' => $customer->id]);
    }
}
