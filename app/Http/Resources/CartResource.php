<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $totals = $this->calculateTotals();

        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'coupon' => new CouponResource($this->whenLoaded('coupon')),
            'items' => CartItemResource::collection($this->whenLoaded('items')),
            'calculation' => $totals,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
