<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Coupon>
 */
class CouponFactory extends Factory
{
    public function definition(): array
    {
        $type = fake()->randomElement(['percentage', 'fixed']);
        $value = $type === 'percentage' ? fake()->numberBetween(5, 30) : fake()->numberBetween(5, 50);

        return [
            'code' => strtoupper(fake()->unique()->lexify('PROMO-????')),
            'type' => $type,
            'value' => $value,
            'minimum_order_amount' => fake()->randomElement([20.00, 50.00, 100.00]),
            'maximum_discount' => $type === 'percentage' ? 50.00 : null,
            'start_date' => now()->subDays(5),
            'end_date' => now()->addDays(30),
            'usage_limit' => fake()->numberBetween(50, 500),
            'times_used' => fake()->numberBetween(0, 20),
            'status' => 'active',
        ];
    }
}
