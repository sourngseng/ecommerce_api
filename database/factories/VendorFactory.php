<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Vendor>
 */
class VendorFactory extends Factory
{
    public function definition(): array
    {
        $shopName = fake()->company() . ' ' . fake()->randomElement(['Store', 'Electronics', 'Shop', 'Fashion', 'Hub', 'Mart']);

        return [
            'user_id' => User::factory()->vendor(),
            'shop_name' => $shopName,
            'slug' => Str::slug($shopName) . '-' . Str::random(5),
            'description' => fake()->paragraph(),
            'logo' => 'https://picsum.photos/seed/' . Str::slug($shopName) . '/200/200',
            'phone' => '+855 ' . fake()->numerify('## ### ###'),
            'email' => fake()->unique()->companyEmail(),
            'address' => 'St. ' . fake()->numberBetween(100, 999) . ', Sangkat Toul Tompoung, Khan Chamkarmon, Phnom Penh',
            'status' => 'active',
        ];
    }
}
