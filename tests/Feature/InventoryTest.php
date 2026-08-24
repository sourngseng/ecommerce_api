<?php

namespace Tests\Feature;

use App\Models\InventoryTransaction;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InventoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_vendor_can_view_inventory_and_transactions(): void
    {
        $vendorUser = User::factory()->vendor()->create();
        $vendor = Vendor::factory()->create(['user_id' => $vendorUser->id]);

        $product = Product::factory()->create([
            'vendor_id' => $vendor->id,
            'stock' => 20,
        ]);

        InventoryTransaction::create([
            'product_id' => $product->id,
            'vendor_id' => $vendor->id,
            'type' => 'restock',
            'quantity_change' => 20,
            'previous_stock' => 0,
            'current_stock' => 20,
            'notes' => 'Initial stock test',
        ]);

        $responseInventory = $this->actingAs($vendorUser)->getJson('/api/v1/vendor/inventory');
        $responseInventory->assertStatus(200);
        $this->assertCount(1, $responseInventory->json('data'));

        $responseTransactions = $this->actingAs($vendorUser)->getJson('/api/v1/vendor/inventory/transactions');
        $responseTransactions->assertStatus(200);
        $this->assertCount(1, $responseTransactions->json('data'));
        $this->assertEquals('restock', $responseTransactions->json('data.0.type'));
    }
}
