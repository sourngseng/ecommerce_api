<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'type',
        'value',
        'minimum_order_amount',
        'maximum_discount',
        'start_date',
        'end_date',
        'usage_limit',
        'times_used',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'value' => 'decimal:2',
            'minimum_order_amount' => 'decimal:2',
            'maximum_discount' => 'decimal:2',
            'start_date' => 'datetime',
            'end_date' => 'datetime',
            'usage_limit' => 'integer',
            'times_used' => 'integer',
        ];
    }

    public function isValidForAmount(float $amount, ?string &$error = null): bool
    {
        if ($this->status !== 'active') {
            $error = 'This coupon is inactive.';
            return false;
        }

        $now = now();

        if ($this->start_date && $now->lt($this->start_date)) {
            $error = 'This coupon is not active yet.';
            return false;
        }

        if ($this->end_date && $now->gt($this->end_date)) {
            $error = 'This coupon has expired.';
            return false;
        }

        if ($this->usage_limit !== null && $this->times_used >= $this->usage_limit) {
            $error = 'This coupon has reached its usage limit.';
            return false;
        }

        if ($amount < (float) $this->minimum_order_amount) {
            $error = "Minimum order amount of \${$this->minimum_order_amount} is required to apply this coupon.";
            return false;
        }

        return true;
    }

    public function calculateDiscount(float $subtotal): float
    {
        if ($this->type === 'percentage') {
            $discount = ($subtotal * (float) $this->value) / 100;
        } else {
            $discount = (float) $this->value;
        }

        if ($this->maximum_discount !== null && $this->maximum_discount > 0) {
            $discount = min($discount, (float) $this->maximum_discount);
        }

        return min($discount, $subtotal);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active');
    }
}
