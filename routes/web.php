<?php

use App\Http\Controllers\ApiDocController;
use Illuminate\Support\Facades\Route;

Route::get('/', [ApiDocController::class, 'index'])->name('api.docs');
Route::get('/docs', [ApiDocController::class, 'index']);
Route::get('/api/docs', [ApiDocController::class, 'index']);
