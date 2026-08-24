<?php

namespace App\Http\Requests\Payment;

use Illuminate\Foundation\Http\FormRequest;

class ProcessPaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'payment_method' => ['required', 'string', 'in:cash_on_delivery,demo_card,bank_transfer'],
            'card_number' => ['nullable', 'string'],
            'bank_account' => ['nullable', 'string'],
        ];
    }
}
