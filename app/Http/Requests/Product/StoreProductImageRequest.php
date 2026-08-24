<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductImageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isVendor() || $this->user()?->isAdmin();
    }

    public function rules(): array
    {
        return [
            'image_url' => ['required', 'string', 'max:500'],
            'is_primary' => ['nullable', 'boolean'],
        ];
    }
}
