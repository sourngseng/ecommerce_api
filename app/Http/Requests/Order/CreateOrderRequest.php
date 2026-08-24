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
            'address_id' => ['nullable', 'exists:addresses,id'],
            'shipping_address' => ['required_without:address_id', 'nullable', 'array'],
            'shipping_address.recipient_name' => ['required_with:shipping_address', 'string'],
            'shipping_address.phone' => ['required_with:shipping_address', 'string'],
            'shipping_address.address_line_1' => ['required_with:shipping_address', 'string'],
            'shipping_address.city' => ['required_with:shipping_address', 'string'],
            'shipping_address.province' => ['required_with:shipping_address', 'string'],
            'payment_method' => ['required', 'string', 'in:cash_on_delivery,demo_card,bank_transfer'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
