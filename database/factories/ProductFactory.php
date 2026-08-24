<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Product>
 */
class ProductFactory extends Factory
{
    public function definition(): array
    {
        $name = fake()->words(3, true);
        $price = fake()->randomFloat(2, 5, 1200);
        $hasDiscount = fake()->boolean(40);
        $discountPrice = $hasDiscount ? round($price * fake()->randomFloat(2, 0.7, 0.95), 2) : null;

        return [
            'vendor_id' => Vendor::factory(),
            'category_id' => Category::factory(),
            'name' => ucfirst($name),
            'slug' => Str::slug($name) . '-' . Str::random(5),
            'sku' => strtoupper(fake()->bothify('SKU-###??-####')),
            'description' => fake()->paragraph(3),
            'price' => $price,
            'discount_price' => $discountPrice,
            'stock' => fake()->numberBetween(5, 150),
            'image' => 'https://picsum.photos/seed/' . Str::slug($name) . '/600/600',
            'is_featured' => fake()->boolean(25),
            'average_rating' => 0.00,
            'reviews_count' => 0,
            'status' => 'active',
        ];
    }
}
