<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cart extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'coupon_id',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function coupon(): BelongsTo
    {
        return $this->belongsTo(Coupon::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function calculateTotals(): array
    {
        $this->loadMissing(['items.product', 'coupon']);

        $subtotal = 0.00;
        foreach ($this->items as $item) {
            $price = $item->product ? $item->product->effective_price : (float) $item->unit_price;
            $subtotal += $price * $item->quantity;
        }

        $discount = 0.00;
        if ($this->coupon && $this->coupon->isValidForAmount($subtotal)) {
            $discount = $this->coupon->calculateDiscount($subtotal);
        }

        $taxRate = 0.00; // Flat or 0 for demo
        $tax = round(($subtotal - $discount) * $taxRate, 2);
        $shipping = ($subtotal > 0 && $subtotal < 50.00) ? 2.00 : 0.00;
        $grandTotal = max(0.00, round($subtotal - $discount + $tax + $shipping, 2));

        return [
            'subtotal' => round($subtotal, 2),
            'discount' => round($discount, 2),
            'tax' => round($tax, 2),
            'shipping' => round($shipping, 2),
            'grand_total' => round($grandTotal, 2),
            'items_count' => $this->items->sum('quantity'),
        ];
    }
}
