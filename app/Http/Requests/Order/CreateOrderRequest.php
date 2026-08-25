<?php

namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class CreateOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'address_id' => ['nullable'],
            'shipping_address' => ['nullable', 'array'],
            'shipping_method' => ['nullable', 'string'],
            'payment_method' => ['nullable', 'string'],
            'coupon_code' => ['nullable', 'string'],
            'notes' => ['nullable', 'string', 'max:1000'],
            'items' => ['nullable', 'array'],
        ];
    }
}
