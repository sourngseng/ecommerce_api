<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Http\Resources\ProductResource;
use App\Http\Resources\VendorResource;
use App\Models\Category;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use App\Models\Vendor;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $totalCustomers = User::where('role', 'customer')->count();
        $totalVendors = Vendor::count();
        $totalProducts = Product::count();
        $totalCategories = Category::count();
        $totalOrders = Order::count();
        $pendingOrders = Order::where('status', 'pending')->count();
        $completedOrders = Order::where('status', 'delivered')->count();

        // Total sales from paid payments or delivered orders
        $totalSales = (float) Order::whereIn('status', ['confirmed', 'processing', 'shipped', 'delivered'])->sum('grand_total');

        // Recent 5 orders
        $recentOrders = Order::with(['user', 'payment'])->latest()->limit(5)->get();

        // Top products by quantity sold
        $topProductIds = OrderItem::select('product_id', DB::raw('SUM(quantity) as total_sold'))
            ->groupBy('product_id')
            ->orderByDesc('total_sold')
            ->limit(5)
            ->pluck('product_id');

        $topProducts = Product::with(['category', 'images'])
            ->whereIn('id', $topProductIds)
            ->get();

        // Top vendors by order volume
        $topVendorIds = OrderItem::select('vendor_id', DB::raw('SUM(total_price) as vendor_sales'))
            ->groupBy('vendor_id')
            ->orderByDesc('vendor_sales')
            ->limit(5)
            ->pluck('vendor_id');

        $topVendors = Vendor::whereIn('id', $topVendorIds)->withCount('products')->get();

        return $this->success([
            'metrics' => [
                'total_customers' => $totalCustomers,
                'total_vendors' => $totalVendors,
                'total_products' => $totalProducts,
                'total_categories' => $totalCategories,
                'total_orders' => $totalOrders,
                'pending_orders' => $pendingOrders,
                'completed_orders' => $completedOrders,
                'total_sales' => round($totalSales, 2),
            ],
            'recent_orders' => OrderResource::collection($recentOrders),
            'top_products' => ProductResource::collection($topProducts),
            'top_vendors' => VendorResource::collection($topVendors),
        ], 'Admin dashboard metrics retrieved successfully');
    }
}
