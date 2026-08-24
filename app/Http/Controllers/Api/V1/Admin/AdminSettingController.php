<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminSettingController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $settings = Setting::all()->groupBy('group');

        return $this->success($settings, 'Admin settings retrieved successfully');
    }

    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'settings' => ['required', 'array'],
            'settings.*.key' => ['required', 'string'],
            'settings.*.value' => ['nullable'],
            'settings.*.group' => ['nullable', 'string'],
        ]);

        $incoming = $request->input('settings');
        foreach ($incoming as $item) {
            Setting::set(
                $item['key'],
                $item['value'] ?? '',
                $item['group'] ?? 'general'
            );
        }

        $allSettings = Setting::all()->pluck('value', 'key')->toArray();

        return $this->success($allSettings, 'Settings updated successfully');
    }
}
