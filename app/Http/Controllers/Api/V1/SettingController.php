<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $settings = Setting::all()->pluck('value', 'key')->toArray();

        return $this->success($settings, 'System settings retrieved successfully');
    }
}
