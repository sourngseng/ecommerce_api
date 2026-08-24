<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Address>
 */
class AddressFactory extends Factory
{
    public function definition(): array
    {
        $khmerDistricts = ['Khan Daun Penh', 'Khan Chamkarmon', 'Khan Toul Kork', 'Khan Sen Sok', 'Khan Chroy Changvar', 'Siem Reap Krong', 'Battambang Krong'];
        $khmerProvinces = ['Phnom Penh', 'Siem Reap', 'Battambang', 'Kandal', 'Kampot'];

        return [
            'user_id' => User::factory(),
            'recipient_name' => fake()->name(),
            'phone' => '+855 ' . fake()->numerify('## ### ###'),
            'address_line_1' => '#' . fake()->numberBetween(1, 200) . ', St. ' . fake()->numberBetween(100, 999) . ', ' . fake()->randomElement($khmerDistricts),
            'address_line_2' => fake()->optional(0.3)->sentence(3),
            'city' => fake()->randomElement(['Phnom Penh', 'Siem Reap', 'Battambang', 'Sihanoukville']),
            'province' => fake()->randomElement($khmerProvinces),
            'postal_code' => (string) fake()->numberBetween(12000, 12500),
            'is_default' => false,
        ];
    }
}
