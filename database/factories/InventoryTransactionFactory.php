<?php

namespace Database\Factories;

use App\Models\Product;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\InventoryTransaction>
 */
class InventoryTransactionFactory extends Factory
{
    public function definition(): array
    {
        $change = fake()->numberBetween(5, 50);

        return [
            'product_id' => Product::factory(),
            'vendor_id' => Vendor::factory(),
            'type' => 'restock',
            'quantity_change' => $change,
            'previous_stock' => 0,
            'current_stock' => $change,
            'reference_id' => null,
            'notes' => 'Inventory restock',
        ];
    }
}
