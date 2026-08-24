<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminBannerController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $query = Banner::orderBy('order', 'asc')->latest();

        if ($request->filled('position')) {
            $query->where('position', $request->query('position'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        $perPage = min((int) $request->query('per_page', 15), 100);
        $banners = $query->paginate($perPage);

        return $this->successWithPagination(
            $banners,
            BannerResource::collection($banners->items()),
            'All banners retrieved successfully'
        );
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'image_url' => ['required', 'string', 'max:500'],
            'link_url' => ['nullable', 'string', 'max:500'],
            'button_text' => ['nullable', 'string', 'max:50'],
            'position' => ['nullable', 'string', 'in:slider,hero_banner,promo_banner,sidebar_banner'],
            'order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ]);

        $banner = Banner::create($validated);

        return $this->success(
            new BannerResource($banner),
            'Banner created successfully',
            201
        );
    }

    public function show(Banner $banner): JsonResponse
    {
        return $this->success(
            new BannerResource($banner),
            'Banner details retrieved successfully'
        );
    }

    public function update(Request $request, Banner $banner): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'image_url' => ['sometimes', 'required', 'string', 'max:500'],
            'link_url' => ['nullable', 'string', 'max:500'],
            'button_text' => ['nullable', 'string', 'max:50'],
            'position' => ['nullable', 'string', 'in:slider,hero_banner,promo_banner,sidebar_banner'],
            'order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', 'string', 'in:active,inactive'],
        ]);

        $banner->update($validated);

        return $this->success(
            new BannerResource($banner),
            'Banner updated successfully'
        );
    }

    public function destroy(Banner $banner): JsonResponse
    {
        $banner->delete();

        return $this->success(null, 'Banner deleted successfully');
    }
}
