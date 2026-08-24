<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Order>
 */
class OrderFactory extends Factory
{
    public function definition(): array
    {
        $subtotal = fake()->randomFloat(2, 20, 500);
        $discount = 0.00;
        $tax = 0.00;
        $shipping = $subtotal < 50 ? 2.00 : 0.00;
        $grandTotal = $subtotal - $discount + $tax + $shipping;

        return [
            'order_number' => 'ORD-' . strtoupper(Str::random(10)),
            'user_id' => User::factory(),
            'coupon_id' => null,
            'status' => fake()->randomElement(['pending', 'confirmed', 'processing', 'shipped', 'delivered']),
            'subtotal' => $subtotal,
            'discount_amount' => $discount,
            'tax_amount' => $tax,
            'shipping_amount' => $shipping,
            'grand_total' => $grandTotal,
            'shipping_address' => [
                'recipient_name' => fake()->name(),
                'phone' => '+855 ' . fake()->numerify('## ### ###'),
                'address_line_1' => '#' . fake()->numberBetween(1, 100) . ', St. ' . fake()->numberBetween(100, 500),
                'city' => 'Phnom Penh',
                'province' => 'Phnom Penh',
            ],
            'notes' => fake()->optional(0.3)->sentence(),
        ];
    }
}
