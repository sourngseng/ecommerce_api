<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BannerController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Banner::active()->orderBy('order', 'asc')->latest();

        if ($request->filled('position')) {
            $query->where('position', $request->query('position'));
        }

        $banners = $query->get();

        return $this->success(
            BannerResource::collection($banners),
            'Banners and sliders retrieved successfully'
        );
    }
}
