<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isVendor() || $this->user()?->isAdmin();
    }

    public function rules(): array
    {
        $product = $this->route('product');
        $productId = $product instanceof \App\Models\Product ? $product->id : $product;
        $price = $this->has('price') ? $this->input('price') : ($product instanceof \App\Models\Product ? $product->price : null);

        $discountRules = ['nullable', 'numeric', 'min:0'];
        if ($price !== null) {
            $discountRules[] = 'lt:' . $price;
        }

        return [
            'category_id' => ['sometimes', 'required', 'exists:categories,id'],
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'sku' => ['sometimes', 'required', 'string', 'max:100', Rule::unique('products', 'sku')->ignore($productId)],
            'description' => ['nullable', 'string'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'discount_price' => $discountRules,
            'stock' => ['sometimes', 'required', 'integer', 'min:0'],
            'image' => ['nullable', 'string', 'max:500'],
            'is_featured' => ['nullable', 'boolean'],
            'status' => ['nullable', 'string', 'in:active,inactive,draft'],
        ];
    }
}
