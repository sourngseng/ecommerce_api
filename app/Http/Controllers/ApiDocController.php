<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;

class ApiDocController extends Controller
{
    /**
     * Show the interactive API Documentation & Live Testing UI.
     */
    public function index(): View
    {
        return view('api-docs');
    }
}
