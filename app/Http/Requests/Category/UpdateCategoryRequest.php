<?php

namespace App\Http\Requests\Category;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() ?? false;
    }

    public function rules(): array
    {
        $categoryId = $this->route('category') instanceof \App\Models\Category 
            ? $this->route('category')->id 
            : $this->route('category');

        return [
            'name' => ['sometimes', 'required', 'string', 'max:255', Rule::unique('categories', 'name')->ignore($categoryId)],
            'description' => ['nullable', 'string'],
            'image' => ['nullable', 'string', 'max:500'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ];
    }
}
