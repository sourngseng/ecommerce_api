<?php

use App\Http\Controllers\Api\V1\Admin\AdminBannerController;
use App\Http\Controllers\Api\V1\Admin\AdminCategoryController;
use App\Http\Controllers\Api\V1\Admin\AdminDashboardController;
use App\Http\Controllers\Api\V1\Admin\AdminOrderController;
use App\Http\Controllers\Api\V1\Admin\AdminSettingController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BannerController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\Customer\AddressController;
use App\Http\Controllers\Api\V1\Customer\CartController;
use App\Http\Controllers\Api\V1\Customer\CustomerOrderController;
use App\Http\Controllers\Api\V1\Customer\CustomerProfileController;
use App\Http\Controllers\Api\V1\Customer\PaymentController;
use App\Http\Controllers\Api\V1\Customer\ReviewController;
use App\Http\Controllers\Api\V1\Customer\WishlistController;
use App\Http\Controllers\Api\V1\ProductController;
use App\Http\Controllers\Api\V1\SettingController;
use App\Http\Controllers\Api\V1\Vendor\VendorInventoryController;
use App\Http\Controllers\Api\V1\Vendor\VendorOrderController;
use App\Http\Controllers\Api\V1\Vendor\VendorProductController;
use App\Http\Controllers\Api\V1\Vendor\VendorProductImageController;
use App\Http\Controllers\Api\V1\Vendor\VendorProfileController;
use App\Http\Controllers\Api\V1\VendorController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // General System Settings & Banners (Public)
    Route::get('/settings', [SettingController::class, 'index']);
    Route::get('/banners', [BannerController::class, 'index']);

    // Authentication Routes
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
        });
    });

    // Public Categories Routes
    Route::prefix('categories')->group(function () {
        Route::get('/', [CategoryController::class, 'index']);
        Route::get('/{category}', [CategoryController::class, 'show']);
        Route::get('/{category}/products', [CategoryController::class, 'products']);
    });

    // Public Products Routes
    Route::prefix('products')->group(function () {
        Route::get('/', [ProductController::class, 'index']);
        Route::get('/search', [ProductController::class, 'search']);
        Route::get('/{product}', [ProductController::class, 'show']);
        Route::get('/{product}/related', [ProductController::class, 'related']);
        Route::get('/{product}/reviews', [ReviewController::class, 'productReviews']);

        // Authenticated Review Submission
        Route::middleware('auth:sanctum')->group(function () {
            Route::post('/{product}/reviews', [ReviewController::class, 'store']);
        });
    });

    // Authenticated Review Update/Delete
    Route::middleware('auth:sanctum')->group(function () {
        Route::put('/reviews/{review}', [ReviewController::class, 'update']);
        Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);
    });

    // Public Vendors Routes
    Route::prefix('vendors')->group(function () {
        Route::get('/', [VendorController::class, 'index']);
        Route::get('/{vendor}', [VendorController::class, 'show']);
    });

    // Shopping Cart Routes (Authenticated)
    Route::middleware('auth:sanctum')->prefix('cart')->group(function () {
        Route::get('/', [CartController::class, 'show']);
        Route::post('/items', [CartController::class, 'addItem']);
        Route::put('/items/{item}', [CartController::class, 'updateItem']);
        Route::delete('/items/{item}', [CartController::class, 'removeItem']);
        Route::delete('/clear', [CartController::class, 'clear']);
        Route::post('/apply-coupon', [CartController::class, 'applyCoupon']);
        Route::delete('/coupon', [CartController::class, 'removeCoupon']);
    });

    // Wishlist Routes (Authenticated)
    Route::middleware('auth:sanctum')->prefix('wishlist')->group(function () {
        Route::get('/', [WishlistController::class, 'index']);
        Route::post('/items', [WishlistController::class, 'store']);
        Route::delete('/items/{product}', [WishlistController::class, 'destroy']);
        Route::delete('/clear', [WishlistController::class, 'clear']);
    });

    // Customer Area Routes (Authenticated)
    Route::middleware('auth:sanctum')->prefix('customer')->group(function () {
        // Customer Profile
        Route::get('/profile', [CustomerProfileController::class, 'show']);
        Route::put('/profile', [CustomerProfileController::class, 'update']);

        // Customer Addresses
        Route::get('/addresses', [AddressController::class, 'index']);
        Route::post('/addresses', [AddressController::class, 'store']);
        Route::get('/addresses/{address}', [AddressController::class, 'show']);
        Route::put('/addresses/{address}', [AddressController::class, 'update']);
        Route::delete('/addresses/{address}', [AddressController::class, 'destroy']);

        // Customer Orders
        Route::get('/orders', [CustomerOrderController::class, 'index']);
        Route::post('/orders', [CustomerOrderController::class, 'store']);
        Route::get('/orders/{order}', [CustomerOrderController::class, 'show']);
        Route::post('/orders/{order}/cancel', [CustomerOrderController::class, 'cancel']);

        // Customer Payments
        Route::get('/orders/{order}/payment', [PaymentController::class, 'show']);
        Route::post('/orders/{order}/payment', [PaymentController::class, 'process']);
    });

    // Top-Level Orders Endpoints (Direct and Mobile Client Support)
    Route::get('/orders', [CustomerOrderController::class, 'index']);
    Route::post('/orders', [CustomerOrderController::class, 'store']);
    Route::get('/orders/{order}', [CustomerOrderController::class, 'show']);
    Route::post('/orders/{order}/cancel', [CustomerOrderController::class, 'cancel']);

    // Vendor Area Routes (Vendor Role Only)
    Route::middleware(['auth:sanctum', 'role:vendor,admin'])->prefix('vendor')->group(function () {
        // Vendor Profile
        Route::get('/profile', [VendorProfileController::class, 'show']);
        Route::put('/profile', [VendorProfileController::class, 'update']);

        // Vendor Products
        Route::get('/products', [VendorProductController::class, 'index']);
        Route::post('/products', [VendorProductController::class, 'store']);
        Route::get('/products/{product}', [VendorProductController::class, 'show']);
        Route::put('/products/{product}', [VendorProductController::class, 'update']);
        Route::delete('/products/{product}', [VendorProductController::class, 'destroy']);

        // Vendor Product Images
        Route::post('/products/{product}/images', [VendorProductImageController::class, 'store']);
        Route::delete('/products/{product}/images/{image}', [VendorProductImageController::class, 'destroy']);

        // Vendor Orders
        Route::get('/orders', [VendorOrderController::class, 'index']);
        Route::get('/orders/{order}', [VendorOrderController::class, 'show']);
        Route::put('/orders/{order}/status', [VendorOrderController::class, 'updateStatus']);

        // Vendor Inventory
        Route::get('/inventory', [VendorInventoryController::class, 'index']);
        Route::get('/inventory/transactions', [VendorInventoryController::class, 'transactions']);
    });

    // Admin Area Routes (Admin Role Only)
    Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
        // Admin Dashboard
        Route::get('/dashboard', [AdminDashboardController::class, 'index']);

        // Admin Categories Management
        Route::post('/categories', [AdminCategoryController::class, 'store']);
        Route::put('/categories/{category}', [AdminCategoryController::class, 'update']);
        Route::delete('/categories/{category}', [AdminCategoryController::class, 'destroy']);

        // Admin Orders Management
        Route::get('/orders', [AdminOrderController::class, 'index']);
        Route::get('/orders/{order}', [AdminOrderController::class, 'show']);
        Route::put('/orders/{order}/status', [AdminOrderController::class, 'updateStatus']);

        // Admin General Settings Management
        Route::get('/settings', [AdminSettingController::class, 'index']);
        Route::put('/settings', [AdminSettingController::class, 'update']);
        Route::post('/settings/upload', [AdminSettingController::class, 'uploadAsset']);

        // Admin Banners & Sliders Management
        Route::get('/banners', [AdminBannerController::class, 'index']);
        Route::post('/banners', [AdminBannerController::class, 'store']);
        Route::get('/banners/{banner}', [AdminBannerController::class, 'show']);
        Route::put('/banners/{banner}', [AdminBannerController::class, 'update']);
        Route::delete('/banners/{banner}', [AdminBannerController::class, 'destroy']);
    });
});
