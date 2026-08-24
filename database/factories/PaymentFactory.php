<?php

namespace Database\Factories;

use App\Models\Order;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Payment>
 */
class PaymentFactory extends Factory
{
    public function definition(): array
    {
        $method = fake()->randomElement(['cash_on_delivery', 'demo_card', 'bank_transfer']);
        $status = $method === 'cash_on_delivery' ? 'pending' : 'paid';

        return [
            'order_id' => Order::factory(),
            'payment_method' => $method,
            'transaction_reference' => 'PAY-' . strtoupper(Str::random(12)),
            'amount' => fake()->randomFloat(2, 20, 500),
            'status' => $status,
            'payment_details' => [
                'method' => $method,
                'gateway' => 'demo_gateway',
            ],
            'paid_at' => $status === 'paid' ? now() : null,
        ];
    }
}
