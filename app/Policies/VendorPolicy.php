<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Vendor;

class VendorPolicy
{
    public function update(User $user, Vendor $vendor): bool
    {
        return $user->isAdmin() || $user->id === $vendor->user_id;
    }
}
