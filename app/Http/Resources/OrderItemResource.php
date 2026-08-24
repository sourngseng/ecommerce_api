<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_id' => $this->order_id,
            'product_id' => $this->product_id,
            'vendor_id' => $this->vendor_id,
            'product_name' => $this->product_name,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'total_price' => (float) $this->total_price,
            'product' => new ProductResource($this->whenLoaded('product')),
            'vendor' => new VendorResource($this->whenLoaded('vendor')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
