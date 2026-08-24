<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Commerce REST API Explorer & Live Testing Interface</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-main: #0b0f19;
            --bg-card: #111827;
            --bg-input: #1f2937;
            --bg-sidebar: #0e1526;
            --border-color: #1f293d;
            --border-hover: #374151;
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --text-dim: #6b7280;
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --primary-glow: rgba(99, 102, 241, 0.25);
            --method-get: #10b981;
            --method-post: #3b82f6;
            --method-put: #f59e0b;
            --method-delete: #ef4444;
            --status-success: #10b981;
            --status-error: #ef4444;
            --status-warn: #f59e0b;
            --sidebar-width: 320px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--bg-main);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
        }

        /* Top Navigation Bar */
        header.top-bar {
            height: 68px;
            background-color: rgba(14, 21, 38, 0.85);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .logo-group {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-badge {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #6366f1, #ec4899);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 18px;
            color: white;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.4);
        }

        .logo-title {
            font-size: 17px;
            font-weight: 700;
            letter-spacing: -0.3px;
        }

        .logo-subtitle {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .auth-bar {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .quick-login-label {
            font-size: 12px;
            color: var(--text-dim);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .quick-btn {
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            color: var(--text-main);
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .quick-btn:hover {
            border-color: var(--primary);
            background: #283548;
            transform: translateY(-1px);
        }

        .token-status {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 12px;
            border-radius: 6px;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.25);
            font-size: 12px;
            font-weight: 600;
            color: var(--status-success);
        }

        .token-status.unauthenticated {
            background: rgba(239, 68, 68, 0.1);
            border-color: rgba(239, 68, 68, 0.25);
            color: #f87171;
        }

        .btn-clear-token {
            background: transparent;
            border: none;
            color: var(--text-dim);
            cursor: pointer;
            font-size: 14px;
            padding: 2px 4px;
        }
        .btn-clear-token:hover {
            color: var(--status-error);
        }

        /* App Layout */
        .app-container {
            display: flex;
            flex: 1;
            height: calc(100vh - 68px);
            overflow: hidden;
        }

        /* Sidebar Navigation */
        aside.sidebar {
            width: var(--sidebar-width);
            background-color: var(--bg-sidebar);
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            overflow: hidden;
        }

        .search-box {
            padding: 16px;
            border-bottom: 1px solid var(--border-color);
        }

        .search-input {
            width: 100%;
            background-color: var(--bg-input);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 10px 14px;
            color: white;
            font-size: 13px;
            outline: none;
            font-family: inherit;
            transition: border 0.2s;
        }

        .search-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-glow);
        }

        .nav-sections {
            flex: 1;
            overflow-y: auto;
            padding: 12px 10px;
        }

        .nav-category-title {
            font-size: 11px;
            text-transform: uppercase;
            font-weight: 700;
            color: var(--text-dim);
            letter-spacing: 0.8px;
            padding: 12px 8px 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 10px;
            border-radius: 6px;
            font-size: 12.5px;
            color: var(--text-muted);
            text-decoration: none;
            cursor: pointer;
            transition: all 0.15s ease;
            margin-bottom: 2px;
        }

        .nav-item:hover {
            background-color: var(--bg-card);
            color: white;
        }

        .nav-item.active {
            background-color: rgba(99, 102, 241, 0.15);
            color: white;
            font-weight: 600;
            border-left: 3px solid var(--primary);
        }

        .method-badge {
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 4px;
            text-transform: uppercase;
            min-width: 44px;
            text-align: center;
        }

        .badge-get { background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.3); }
        .badge-post { background: rgba(59, 130, 246, 0.15); color: #60a5fa; border: 1px solid rgba(59, 130, 246, 0.3); }
        .badge-put { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3); }
        .badge-delete { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }

        .nav-item-path {
            flex: 1;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11.5px;
        }

        /* Main Playground Content Area */
        main.main-content {
            flex: 1;
            overflow-y: auto;
            padding: 28px 36px;
            background-color: var(--bg-main);
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .endpoint-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .endpoint-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 16px;
            gap: 16px;
        }

        .endpoint-title-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .endpoint-method-url {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .endpoint-method-large {
            font-family: 'JetBrains Mono', monospace;
            font-size: 13px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 6px;
        }

        .endpoint-url-text {
            font-family: 'JetBrains Mono', monospace;
            font-size: 16px;
            font-weight: 600;
            color: #ffffff;
        }

        .endpoint-desc {
            font-size: 14px;
            color: var(--text-muted);
        }

        .endpoint-tags {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .role-tag {
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 6px;
            background: rgba(99, 102, 241, 0.15);
            color: #a5b4fc;
            border: 1px solid rgba(99, 102, 241, 0.3);
        }

        .auth-tag {
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 6px;
            background: rgba(245, 158, 11, 0.15);
            color: #fcd34d;
            border: 1px solid rgba(245, 158, 11, 0.3);
        }

        .auth-tag.public {
            background: rgba(16, 185, 129, 0.15);
            color: #6ee7b7;
            border-color: rgba(16, 185, 129, 0.3);
        }

        /* 2-Column Split: Request & Response */
        .tester-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 16px;
        }

        @media (max-width: 1100px) {
            .tester-grid {
                grid-template-columns: 1fr;
            }
        }

        .panel-box {
            background-color: var(--bg-sidebar);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .panel-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .field-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .field-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-dim);
            font-family: 'JetBrains Mono', monospace;
        }

        .input-text {
            background-color: var(--bg-input);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 8px 12px;
            color: white;
            font-size: 13px;
            font-family: 'JetBrains Mono', monospace;
            outline: none;
            width: 100%;
        }

        .input-text:focus {
            border-color: var(--primary);
        }

        .json-editor {
            background-color: #080d1a;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 12px;
            color: #38bdf8;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12.5px;
            line-height: 1.5;
            min-height: 180px;
            max-height: 320px;
            resize: vertical;
            outline: none;
            width: 100%;
        }

        .json-editor:focus {
            border-color: var(--primary);
        }

        .action-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-top: 8px;
        }

        .btn-send {
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            box-shadow: 0 4px 14px var(--primary-glow);
        }

        .btn-send:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 20px var(--primary-glow);
        }

        .btn-send:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .btn-secondary {
            background: var(--bg-input);
            color: var(--text-muted);
            border: 1px solid var(--border-color);
            padding: 8px 14px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.15s;
        }

        .btn-secondary:hover {
            color: white;
            border-color: var(--border-hover);
        }

        /* Response View Box */
        .response-box {
            background-color: #060913;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 14px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12.5px;
            line-height: 1.5;
            min-height: 220px;
            max-height: 480px;
            overflow: auto;
            color: #cbd5e1;
            white-space: pre-wrap;
            word-break: break-word;
        }

        .status-badge-res {
            font-size: 12px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
        }

        .status-2xx { background: rgba(16, 185, 129, 0.2); color: #34d399; }
        .status-4xx { background: rgba(245, 158, 11, 0.2); color: #fbbf24; }
        .status-5xx { background: rgba(239, 68, 68, 0.2); color: #f87171; }

        /* JSON Syntax Highlighting */
        .json-key { color: #93c5fd; }
        .json-string { color: #86efac; }
        .json-number { color: #fcd34d; }
        .json-boolean { color: #c084fc; }
        .json-null { color: #9ca3af; }

        .spinner {
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-top: 2px solid white;
            border-radius: 50%;
            width: 14px;
            height: 14px;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .curl-box {
            background: #0d1322;
            border: 1px dashed var(--border-color);
            padding: 10px 14px;
            border-radius: 6px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: #94a3b8;
            overflow-x: auto;
            display: none;
        }

        .curl-box.show {
            display: block;
        }
    </style>
</head>
<body>

    <!-- Header Navigation -->
    <header class="top-bar">
        <div class="logo-group">
            <div class="logo-badge">⚡</div>
            <div>
                <div class="logo-title">E-Commerce REST API Explorer</div>
                <div class="logo-subtitle">Laravel 12 &bull; Sanctum Auth &bull; 62 Endpoints</div>
            </div>
        </div>

        <div class="auth-bar">
            <span class="quick-login-label">Quick 1-Click Login:</span>
            <button class="quick-btn" onclick="quickLogin('admin@ecommerce.test', 'Super Admin')">👑 Admin</button>
            <button class="quick-btn" onclick="quickLogin('sokha@phnompenhelectronics.com', 'Sokha (Electronics Vendor)')">🏪 Vendor Sokha</button>
            <button class="quick-btn" onclick="quickLogin('bopha@angkorfashion.com', 'Bopha (Fashion Vendor)')">👗 Vendor Bopha</button>
            <button class="quick-btn" onclick="quickLogin('rithy.sok@example.com', 'Rithy Sok (Customer)')">👤 Customer Rithy</button>

            <div id="tokenBadge" class="token-status unauthenticated">
                <span id="tokenStatusText">Unauthenticated</span>
                <button class="btn-clear-token" title="Clear Token" onclick="clearToken()">&times;</button>
            </div>
        </div>
    </header>

    <div class="app-container">
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <div class="search-box">
                <input type="text" id="endpointSearch" class="search-input" placeholder="Search 62 API endpoints (e.g. cart, order, review)..." oninput="filterEndpoints()">
            </div>

            <div class="nav-sections" id="navContainer">
                <!-- Navigation items dynamically rendered -->
            </div>
        </aside>

        <!-- Main Content Area -->
        <main class="main-content" id="mainContent">
            <!-- Active endpoint test card dynamically rendered -->
        </main>
    </div>

    <!-- Embedded Complete Endpoint Database & Interactive Runner -->
    <script>
        const API_BASE = window.location.origin + '/api/v1';

        let authToken = localStorage.getItem('api_bearer_token') || '';
        let currentUser = JSON.parse(localStorage.getItem('api_current_user') || 'null');

        const ENDPOINTS = [
            // 1. Authentication
            {
                id: 'auth-register',
                category: 'Authentication',
                method: 'POST',
                path: '/auth/register',
                title: 'Register New User',
                desc: 'Register a new customer or vendor user account with instant bearer token issuance.',
                auth: false,
                role: 'Guest / Public',
                body: {
                    name: "Sopheap Heng",
                    email: "sopheap" + Math.floor(Math.random() * 1000) + "@example.com",
                    password: "password123",
                    password_confirmation: "password123",
                    phone: "+855 12 888 777",
                    role: "customer"
                }
            },
            {
                id: 'auth-login',
                category: 'Authentication',
                method: 'POST',
                path: '/auth/login',
                title: 'Login & Obtain Bearer Token',
                desc: 'Authenticate user credentials and receive Sanctum plainTextToken.',
                auth: false,
                role: 'Guest / Public',
                body: {
                    email: "admin@ecommerce.test",
                    password: "password",
                    device_name: "Web Browser"
                }
            },
            {
                id: 'auth-me',
                category: 'Authentication',
                method: 'GET',
                path: '/auth/me',
                title: 'Get Current Authenticated User',
                desc: 'Returns currently authenticated user profile, active roles, and shop details if vendor.',
                auth: true,
                role: 'Any Authenticated User',
                body: null
            },
            {
                id: 'auth-logout',
                category: 'Authentication',
                method: 'POST',
                path: '/auth/logout',
                title: 'Logout & Revoke Token',
                desc: 'Revoke and delete current personal access token.',
                auth: true,
                role: 'Any Authenticated User',
                body: null
            },

            // 2. Categories
            {
                id: 'cat-list',
                category: 'Categories',
                method: 'GET',
                path: '/categories',
                title: 'List All Categories',
                desc: 'Retrieve paginated list of active product categories with product counts and sorting.',
                auth: false,
                role: 'Public',
                queryParams: { search: '', sort_by: 'name', sort_order: 'asc', per_page: 15 },
                body: null
            },
            {
                id: 'cat-show',
                category: 'Categories',
                method: 'GET',
                path: '/categories/{category}',
                title: 'Get Category Details',
                desc: 'Retrieve a single category details by ID or Slug.',
                auth: false,
                role: 'Public',
                params: { category: '1' },
                body: null
            },
            {
                id: 'cat-products',
                category: 'Categories',
                method: 'GET',
                path: '/categories/{category}/products',
                title: 'Get Category Products',
                desc: 'Retrieve paginated products belonging to a specific category with price filtering.',
                auth: false,
                role: 'Public',
                params: { category: '1' },
                queryParams: { min_price: '', max_price: '', sort_by: 'price', sort_order: 'asc', per_page: 10 },
                body: null
            },
            {
                id: 'admin-cat-create',
                category: 'Categories',
                method: 'POST',
                path: '/admin/categories',
                title: 'Admin: Create Category',
                desc: 'Create a new product category (Super Admin Only).',
                auth: true,
                role: 'Admin Only',
                body: {
                    name: "Smart Watches & Wearables",
                    description: "Modern fitness trackers, smart bands, and wearable tech.",
                    status: "active"
                }
            },
            {
                id: 'admin-cat-update',
                category: 'Categories',
                method: 'PUT',
                path: '/admin/categories/{category}',
                title: 'Admin: Update Category',
                desc: 'Update existing category details (Super Admin Only).',
                auth: true,
                role: 'Admin Only',
                params: { category: '1' },
                body: {
                    name: "Consumer Electronics & Tech",
                    description: "Updated category description",
                    status: "active"
                }
            },
            {
                id: 'admin-cat-delete',
                category: 'Categories',
                method: 'DELETE',
                path: '/admin/categories/{category}',
                title: 'Admin: Delete Category',
                desc: 'Delete an unused category (Super Admin Only).',
                auth: true,
                role: 'Admin Only',
                params: { category: '10' },
                body: null
            },

            // 3. Products & Search
            {
                id: 'prod-list',
                category: 'Products',
                method: 'GET',
                path: '/products',
                title: 'List & Filter Products',
                desc: 'Filter catalog by category, vendor, price range, featured flag, keyword, and sort order.',
                auth: false,
                role: 'Public',
                queryParams: { category_id: '', vendor_id: '', min_price: '', max_price: '', featured: '', search: '', sort_by: 'created_at', sort_order: 'desc', per_page: 12 },
                body: null
            },
            {
                id: 'prod-search',
                category: 'Products',
                method: 'GET',
                path: '/products/search',
                title: 'Search Products',
                desc: 'Instant keyword search matching product names, descriptions, and SKUs.',
                auth: false,
                role: 'Public',
                queryParams: { q: 'iPhone' },
                body: null
            },
            {
                id: 'prod-show',
                category: 'Products',
                method: 'GET',
                path: '/products/{product}',
                title: 'Get Product Details',
                desc: 'Retrieve single product with full gallery images, vendor profile, and customer reviews.',
                auth: false,
                role: 'Public',
                params: { product: '1' },
                body: null
            },
            {
                id: 'prod-related',
                category: 'Products',
                method: 'GET',
                path: '/products/{product}/related',
                title: 'Get Related Products',
                desc: 'Returns related products in the same category.',
                auth: false,
                role: 'Public',
                params: { product: '1' },
                body: null
            },
            {
                id: 'prod-reviews',
                category: 'Products',
                method: 'GET',
                path: '/products/{product}/reviews',
                title: 'Get Product Reviews',
                desc: 'Retrieve all approved customer reviews and star ratings for this product.',
                auth: false,
                role: 'Public',
                params: { product: '1' },
                body: null
            },

            // 4. Vendors
            {
                id: 'vendor-list',
                category: 'Vendors',
                method: 'GET',
                path: '/vendors',
                title: 'List Active Vendors',
                desc: 'Browse verified Cambodian vendor shops and marketplaces.',
                auth: false,
                role: 'Public',
                queryParams: { search: '', per_page: 10 },
                body: null
            },
            {
                id: 'vendor-show',
                category: 'Vendors',
                method: 'GET',
                path: '/vendors/{vendor}',
                title: 'Get Vendor Shop Details',
                desc: 'Retrieve vendor profile, contact information, and their listed inventory.',
                auth: false,
                role: 'Public',
                params: { vendor: '1' },
                body: null
            },

            // 5. Shopping Cart
            {
                id: 'cart-get',
                category: 'Shopping Cart',
                method: 'GET',
                path: '/cart',
                title: 'View Shopping Cart',
                desc: 'Get cart items with automatic subtotal, discount, tax, shipping, and grand total calculations.',
                auth: true,
                role: 'Customer',
                body: null
            },
            {
                id: 'cart-add',
                category: 'Shopping Cart',
                method: 'POST',
                path: '/cart/items',
                title: 'Add Item to Cart',
                desc: 'Add product with quantity; validates available stock in real-time.',
                auth: true,
                role: 'Customer',
                body: {
                    product_id: 1,
                    quantity: 2
                }
            },
            {
                id: 'cart-update',
                category: 'Shopping Cart',
                method: 'PUT',
                path: '/cart/items/{item}',
                title: 'Update Cart Item Quantity',
                desc: 'Update quantity of an item in the cart.',
                auth: true,
                role: 'Customer',
                params: { item: '1' },
                body: {
                    quantity: 3
                }
            },
            {
                id: 'cart-remove',
                category: 'Shopping Cart',
                method: 'DELETE',
                path: '/cart/items/{item}',
                title: 'Remove Item from Cart',
                desc: 'Remove single item from shopping cart.',
                auth: true,
                role: 'Customer',
                params: { item: '1' },
                body: null
            },
            {
                id: 'cart-clear',
                category: 'Shopping Cart',
                method: 'DELETE',
                path: '/cart/clear',
                title: 'Clear Entire Cart',
                desc: 'Remove all items and clear applied coupon.',
                auth: true,
                role: 'Customer',
                body: null
            },
            {
                id: 'cart-coupon',
                category: 'Shopping Cart',
                method: 'POST',
                path: '/cart/apply-coupon',
                title: 'Apply Coupon Code',
                desc: 'Apply promo code (e.g. WELCOME10, CAMBODIA50, TECHDISCOUNT) to cart.',
                auth: true,
                role: 'Customer',
                body: {
                    code: "WELCOME10"
                }
            },
            {
                id: 'cart-coupon-remove',
                category: 'Shopping Cart',
                method: 'DELETE',
                path: '/cart/coupon',
                title: 'Remove Coupon Code',
                desc: 'Detach currently applied coupon from cart.',
                auth: true,
                role: 'Customer',
                body: null
            },

            // 6. Wishlist
            {
                id: 'wish-get',
                category: 'Wishlist',
                method: 'GET',
                path: '/wishlist',
                title: 'Get Wishlist',
                desc: 'List saved wishlist products for current customer.',
                auth: true,
                role: 'Customer',
                body: null
            },
            {
                id: 'wish-add',
                category: 'Wishlist',
                method: 'POST',
                path: '/wishlist/items',
                title: 'Add Product to Wishlist',
                desc: 'Add product to customer wishlist with duplicate prevention.',
                auth: true,
                role: 'Customer',
                body: {
                    product_id: 2
                }
            },
            {
                id: 'wish-remove',
                category: 'Wishlist',
                method: 'DELETE',
                path: '/wishlist/items/{product}',
                title: 'Remove Product from Wishlist',
                desc: 'Remove single product from customer wishlist.',
                auth: true,
                role: 'Customer',
                params: { product: '2' },
                body: null
            },
            {
                id: 'wish-clear',
                category: 'Wishlist',
                method: 'DELETE',
                path: '/wishlist/clear',
                title: 'Clear Wishlist',
                desc: 'Clear all products in customer wishlist.',
                auth: true,
                role: 'Customer',
                body: null
            },

            // 7. Customer Profile & Addresses
            {
                id: 'cust-profile',
                category: 'Customer Profile & Addresses',
                method: 'GET',
                path: '/customer/profile',
                title: 'Get Customer Profile',
                desc: 'Retrieve current customer account details.',
                auth: true,
                role: 'Customer',
                body: null
            },
            {
                id: 'cust-profile-update',
                category: 'Customer Profile & Addresses',
                method: 'PUT',
                path: '/customer/profile',
                title: 'Update Customer Profile',
                desc: 'Update customer name and phone number.',
                auth: true,
                role: 'Customer',
                body: {
                    name: "Rithy Sok",
                    phone: "+855 12 999 888"
                }
            },
            {
                id: 'cust-addr-list',
                category: 'Customer Profile & Addresses',
                method: 'GET',
                path: '/customer/addresses',
                title: 'List Customer Addresses',
                desc: 'Retrieve saved delivery addresses in Cambodia.',
                auth: true,
                role: 'Customer',
                body: null
            },
            {
                id: 'cust-addr-create',
                category: 'Customer Profile & Addresses',
                method: 'POST',
                path: '/customer/addresses',
                title: 'Create Delivery Address',
                desc: 'Save new shipping address with default flag.',
                auth: true,
                role: 'Customer',
                body: {
                    recipient_name: "Rithy Sok",
                    phone: "+855 12 999 888",
                    address_line_1: "#45, St. 310, Sangkat Boeung Keng Kang",
                    address_line_2: "Near BKK Market",
                    city: "Phnom Penh",
                    province: "Phnom Penh",
                    postal_code: "12302",
                    is_default: true
                }
            },
            {
                id: 'cust-addr-show',
                category: 'Customer Profile & Addresses',
                method: 'GET',
                path: '/customer/addresses/{address}',
                title: 'Get Single Address',
                desc: 'Retrieve specific address details.',
                auth: true,
                role: 'Customer',
                params: { address: '1' },
                body: null
            },
            {
                id: 'cust-addr-update',
                category: 'Customer Profile & Addresses',
                method: 'PUT',
                path: '/customer/addresses/{address}',
                title: 'Update Delivery Address',
                desc: 'Update existing delivery address.',
                auth: true,
                role: 'Customer',
                params: { address: '1' },
                body: {
                    recipient_name: "Rithy Sok (Office)",
                    address_line_1: "#120, Norodom Blvd",
                    is_default: true
                }
            },
            {
                id: 'cust-addr-delete',
                category: 'Customer Profile & Addresses',
                method: 'DELETE',
                path: '/customer/addresses/{address}',
                title: 'Delete Delivery Address',
                desc: 'Delete saved address.',
                auth: true,
                role: 'Customer',
                params: { address: '1' },
                body: null
            },

            // 8. Orders & Payments
            {
                id: 'order-list',
                category: 'Orders & Payments',
                method: 'GET',
                path: '/customer/orders',
                title: 'List Customer Orders',
                desc: 'Retrieve order history with items, payments, and order status.',
                auth: true,
                role: 'Customer',
                queryParams: { per_page: 10 },
                body: null
            },
            {
                id: 'order-create',
                category: 'Orders & Payments',
                method: 'POST',
                path: '/customer/orders',
                title: 'Checkout & Place Order',
                desc: 'Converts cart items to an order, deducts product stock, and logs inventory adjustments.',
                auth: true,
                role: 'Customer',
                body: {
                    address_id: 1,
                    payment_method: "demo_card",
                    notes: "Please deliver before 5 PM."
                }
            },
            {
                id: 'order-show',
                category: 'Orders & Payments',
                method: 'GET',
                path: '/customer/orders/{order}',
                title: 'Get Customer Order Details',
                desc: 'Retrieve single order breakdown.',
                auth: true,
                role: 'Customer',
                params: { order: '1' },
                body: null
            },
            {
                id: 'order-cancel',
                category: 'Orders & Payments',
                method: 'POST',
                path: '/customer/orders/{order}/cancel',
                title: 'Cancel Order (Restores Stock)',
                desc: 'Cancel pending order; automatically restores stock inventory with transaction audit record.',
                auth: true,
                role: 'Customer',
                params: { order: '1' },
                body: null
            },
            {
                id: 'order-payment-get',
                category: 'Orders & Payments',
                method: 'GET',
                path: '/customer/orders/{order}/payment',
                title: 'Get Order Payment Status',
                desc: 'Check demo transaction status for an order.',
                auth: true,
                role: 'Customer',
                params: { order: '1' },
                body: null
            },
            {
                id: 'order-payment-process',
                category: 'Orders & Payments',
                method: 'POST',
                path: '/customer/orders/{order}/payment',
                title: 'Process Payment (Demo Gateway)',
                desc: 'Simulates payment processing via cash_on_delivery, demo_card, or bank_transfer.',
                auth: true,
                role: 'Customer',
                params: { order: '1' },
                body: {
                    payment_method: "demo_card",
                    card_number: "4242424242421234"
                }
            },

            // 9. Reviews
            {
                id: 'review-create',
                category: 'Reviews & Ratings',
                method: 'POST',
                path: '/products/{product}/reviews',
                title: 'Submit Verified Purchase Review',
                desc: 'Submit review with 1-5 rating. Only customers who purchased this product can review.',
                auth: true,
                role: 'Verified Buyer (Customer)',
                params: { product: '1' },
                body: {
                    rating: 5,
                    comment: "Fantastic product! Very fast delivery and excellent packaging."
                }
            },
            {
                id: 'review-update',
                category: 'Reviews & Ratings',
                method: 'PUT',
                path: '/reviews/{review}',
                title: 'Update Review',
                desc: 'Customer updates their existing review.',
                auth: true,
                role: 'Review Author / Admin',
                params: { review: '1' },
                body: {
                    rating: 4,
                    comment: "Updated review after using for 2 weeks."
                }
            },
            {
                id: 'review-delete',
                category: 'Reviews & Ratings',
                method: 'DELETE',
                path: '/reviews/{review}',
                title: 'Delete Review',
                desc: 'Delete customer review and recalculate product average rating.',
                auth: true,
                role: 'Review Author / Admin',
                params: { review: '1' },
                body: null
            },

            // 10. Vendor Dashboard & Management
            {
                id: 'vendor-prof-get',
                category: 'Vendor Area',
                method: 'GET',
                path: '/vendor/profile',
                title: 'Get Shop Profile',
                desc: 'Retrieve vendor shop settings and listed product totals.',
                auth: true,
                role: 'Vendor Only',
                body: null
            },
            {
                id: 'vendor-prof-update',
                category: 'Vendor Area',
                method: 'PUT',
                path: '/vendor/profile',
                title: 'Update Shop Profile',
                desc: 'Update vendor store name, description, address, and phone.',
                auth: true,
                role: 'Vendor Only',
                body: {
                    shop_name: "Phnom Penh Electronics Premier",
                    description: "Leading authorized electronics store in Cambodia.",
                    phone: "+855 12 888 999",
                    address: "#45 Norodom Blvd, Phnom Penh"
                }
            },
            {
                id: 'vendor-prod-list',
                category: 'Vendor Area',
                method: 'GET',
                path: '/vendor/products',
                title: 'List Vendor Products',
                desc: 'Retrieve products created by this vendor.',
                auth: true,
                role: 'Vendor Only',
                queryParams: { per_page: 15 },
                body: null
            },
            {
                id: 'vendor-prod-create',
                category: 'Vendor Area',
                method: 'POST',
                path: '/vendor/products',
                title: 'Create Product (Vendor)',
                desc: 'Add new product to catalog; triggers initial warehouse stock inventory log.',
                auth: true,
                role: 'Vendor Only',
                body: {
                    category_id: 1,
                    name: "iPad Air M2 11-inch 128GB Wi-Fi Space Gray",
                    sku: "IPAD-AIR-M2-" + Math.floor(Math.random() * 1000),
                    description: "Powerful M2 chip with stunning Liquid Retina display.",
                    price: 599.00,
                    discount_price: 549.00,
                    stock: 20,
                    is_featured: true,
                    status: "active"
                }
            },
            {
                id: 'vendor-prod-show',
                category: 'Vendor Area',
                method: 'GET',
                path: '/vendor/products/{product}',
                title: 'Get Vendor Product',
                desc: 'Retrieve single vendor product.',
                auth: true,
                role: 'Vendor Only',
                params: { product: '1' },
                body: null
            },
            {
                id: 'vendor-prod-update',
                category: 'Vendor Area',
                method: 'PUT',
                path: '/vendor/products/{product}',
                title: 'Update Vendor Product',
                desc: 'Update price, discount, or stock (logs inventory adjustment on stock change).',
                auth: true,
                role: 'Vendor Only',
                params: { product: '1' },
                body: {
                    price: 1149.00,
                    discount_price: 1099.00,
                    stock: 30
                }
            },
            {
                id: 'vendor-prod-delete',
                category: 'Vendor Area',
                method: 'DELETE',
                path: '/vendor/products/{product}',
                title: 'Delete Vendor Product',
                desc: 'Remove product from catalog.',
                auth: true,
                role: 'Vendor Only',
                params: { product: '1' },
                body: null
            },
            {
                id: 'vendor-img-create',
                category: 'Vendor Area',
                method: 'POST',
                path: '/vendor/products/{product}/images',
                title: 'Add Product Gallery Image',
                desc: 'Add secondary or primary image to product gallery.',
                auth: true,
                role: 'Vendor Only',
                params: { product: '1' },
                body: {
                    image_url: "https://picsum.photos/seed/gadget-angle3/600/600",
                    is_primary: false
                }
            },
            {
                id: 'vendor-order-list',
                category: 'Vendor Area',
                method: 'GET',
                path: '/vendor/orders',
                title: 'List Vendor Orders',
                desc: 'Vendors only see orders containing their products with vendor data isolation.',
                auth: true,
                role: 'Vendor Only',
                queryParams: { per_page: 15 },
                body: null
            },
            {
                id: 'vendor-order-status',
                category: 'Vendor Area',
                method: 'PUT',
                path: '/vendor/orders/{order}/status',
                title: 'Update Order Status (Vendor)',
                desc: 'Fulfill orders (e.g. mark processing, shipped, or delivered).',
                auth: true,
                role: 'Vendor Only',
                params: { order: '1' },
                body: {
                    status: "processing"
                }
            },
            {
                id: 'vendor-inventory-get',
                category: 'Vendor Area',
                method: 'GET',
                path: '/vendor/inventory',
                title: 'Vendor Stock Monitor',
                desc: 'Monitor stock levels with low stock alerts.',
                auth: true,
                role: 'Vendor Only',
                queryParams: { low_stock: '10' },
                body: null
            },
            {
                id: 'vendor-transactions-get',
                category: 'Vendor Area',
                method: 'GET',
                path: '/vendor/inventory/transactions',
                title: 'Inventory Transaction Logs',
                desc: 'Audit trail of restocks, order deductions, manual adjustments, and cancellations.',
                auth: true,
                role: 'Vendor Only',
                queryParams: { type: 'order_deduction' },
                body: null
            },

            // 11. Super Admin Area
            {
                id: 'admin-dashboard',
                category: 'Admin Area',
                method: 'GET',
                path: '/admin/dashboard',
                title: 'Admin Dashboard & Metrics',
                desc: 'Live aggregation of customers, vendors, products, categories, total revenue, recent orders, top products & vendors.',
                auth: true,
                role: 'Super Admin Only',
                body: null
            },
            {
                id: 'admin-orders-list',
                category: 'Admin Area',
                method: 'GET',
                path: '/admin/orders',
                title: 'Admin: List All Orders',
                desc: 'Global view of all platform orders with customer search & status filter.',
                auth: true,
                role: 'Super Admin Only',
                queryParams: { status: 'delivered', search: '', per_page: 15 },
                body: null
            },
            {
                id: 'admin-order-status',
                category: 'Admin Area',
                method: 'PUT',
                path: '/admin/orders/{order}/status',
                title: 'Admin: Update Order Status',
                desc: 'Override any order lifecycle status across the platform.',
                auth: true,
                role: 'Super Admin Only',
                params: { order: '1' },
                body: {
                    status: "delivered"
                }
            }
        ];

        let activeEndpoint = ENDPOINTS[0];

        function renderNavigation(items) {
            const container = document.getElementById('navContainer');
            container.innerHTML = '';

            const categories = {};
            items.forEach(ep => {
                if (!categories[ep.category]) categories[ep.category] = [];
                categories[ep.category].push(ep);
            });

            for (const cat in categories) {
                const title = document.createElement('div');
                title.className = 'nav-category-title';
                title.innerText = cat;
                container.appendChild(title);

                categories[cat].forEach(ep => {
                    const item = document.createElement('div');
                    item.className = 'nav-item' + (activeEndpoint && activeEndpoint.id === ep.id ? ' active' : '');
                    item.onclick = () => selectEndpoint(ep);

                    const badge = document.createElement('span');
                    badge.className = `method-badge badge-${ep.method.toLowerCase()}`;
                    badge.innerText = ep.method;

                    const path = document.createElement('span');
                    path.className = 'nav-item-path';
                    path.innerText = ep.path;

                    item.appendChild(badge);
                    item.appendChild(path);
                    container.appendChild(item);
                });
            }
        }

        function filterEndpoints() {
            const query = document.getElementById('endpointSearch').value.toLowerCase().trim();
            const filtered = ENDPOINTS.filter(ep => 
                ep.path.toLowerCase().includes(query) ||
                ep.title.toLowerCase().includes(query) ||
                ep.method.toLowerCase().includes(query) ||
                ep.category.toLowerCase().includes(query)
            );
            renderNavigation(filtered);
        }

        function selectEndpoint(ep) {
            activeEndpoint = ep;
            renderNavigation(ENDPOINTS);
            renderMainContent();
        }

        function renderMainContent() {
            const main = document.getElementById('mainContent');
            const ep = activeEndpoint;
            if (!ep) return;

            let pathParamsHtml = '';
            if (ep.params) {
                pathParamsHtml = '<div class="field-group"><span class="field-label">Path Parameters:</span>';
                for (const param in ep.params) {
                    pathParamsHtml += `
                        <div style="display:flex; align-items:center; gap:8px; margin-top:4px;">
                            <span style="font-family:'JetBrains Mono'; font-size:12px; min-width:80px; color:#93c5fd;">{${param}}</span>
                            <input type="text" class="input-text" id="param_${param}" value="${ep.params[param]}" placeholder="Value for ${param}">
                        </div>
                    `;
                }
                pathParamsHtml += '</div>';
            }

            let queryParamsHtml = '';
            if (ep.queryParams) {
                queryParamsHtml = '<div class="field-group" style="margin-top:10px;"><span class="field-label">Query Parameters:</span>';
                for (const q in ep.queryParams) {
                    queryParamsHtml += `
                        <div style="display:flex; align-items:center; gap:8px; margin-top:4px;">
                            <span style="font-family:'JetBrains Mono'; font-size:12px; min-width:100px; color:#cbd5e1;">${q}</span>
                            <input type="text" class="input-text" id="query_${q}" value="${ep.queryParams[q]}" placeholder="Value">
                        </div>
                    `;
                }
                queryParamsHtml += '</div>';
            }

            let bodyHtml = '';
            if (['POST', 'PUT', 'PATCH'].includes(ep.method)) {
                const bodyStr = ep.body ? JSON.stringify(ep.body, null, 2) : '{}';
                bodyHtml = `
                    <div class="field-group" style="margin-top:10px;">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <span class="field-label">JSON Request Body:</span>
                            <button class="btn-secondary" style="padding:2px 8px; font-size:11px;" onclick="formatJsonBody()">Format JSON</button>
                        </div>
                        <textarea class="json-editor" id="requestBodyEditor">${bodyStr}</textarea>
                    </div>
                `;
            }

            main.innerHTML = `
                <div class="endpoint-card">
                    <div class="endpoint-header">
                        <div class="endpoint-title-group">
                            <div class="endpoint-method-url">
                                <span class="endpoint-method-large badge-${ep.method.toLowerCase()}">${ep.method}</span>
                                <span class="endpoint-url-text">${ep.path}</span>
                            </div>
                            <div class="endpoint-desc">${ep.desc}</div>
                        </div>

                        <div class="endpoint-tags">
                            <span class="role-tag">${ep.role}</span>
                            <span class="auth-tag ${ep.auth ? '' : 'public'}">${ep.auth ? '🔒 Requires Sanctum Bearer Token' : '🌐 Public Access'}</span>
                        </div>
                    </div>

                    <div class="tester-grid">
                        <!-- Request Config Column -->
                        <div class="panel-box">
                            <div class="panel-title">
                                <span>Request Configuration</span>
                                <button class="btn-secondary" onclick="toggleCurl()">Toggle cURL</button>
                            </div>

                            <div id="curlBox" class="curl-box"></div>

                            ${pathParamsHtml}
                            ${queryParamsHtml}
                            ${bodyHtml}

                            <div class="action-row">
                                <button class="btn-send" id="btnExecute" onclick="executeActiveRequest()">
                                    <span>Send Request</span>
                                </button>
                                <span style="font-size:11px; color:var(--text-dim);">Live Backend Request</span>
                            </div>
                        </div>

                        <!-- Live Response Column -->
                        <div class="panel-box">
                            <div class="panel-title">
                                <span>Response Inspector</span>
                                <div id="resMeta" style="display:flex; gap:8px; align-items:center;">
                                    <span id="resStatus"></span>
                                    <span id="resTime" style="font-size:11px; color:var(--text-dim);"></span>
                                </div>
                            </div>

                            <div class="response-box" id="responseViewer">// Click "Send Request" to test this endpoint live against the API backend...</div>

                            <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:4px;">
                                <button class="btn-secondary" onclick="copyResponse()">Copy JSON</button>
                            </div>
                        </div>
                    </div>
                </div>
            `;

            updateCurlPreview();
        }

        function formatJsonBody() {
            const editor = document.getElementById('requestBodyEditor');
            if (editor) {
                try {
                    const parsed = JSON.parse(editor.value);
                    editor.value = JSON.stringify(parsed, null, 2);
                } catch(e) {
                    alert('Invalid JSON: ' + e.message);
                }
            }
        }

        function buildRequestUrl() {
            const ep = activeEndpoint;
            let path = ep.path;

            if (ep.params) {
                for (const param in ep.params) {
                    const el = document.getElementById(`param_${param}`);
                    const val = el ? el.value.trim() : ep.params[param];
                    path = path.replace(`{${param}}`, encodeURIComponent(val));
                }
            }

            const url = new URL(API_BASE + path);

            if (ep.queryParams) {
                for (const q in ep.queryParams) {
                    const el = document.getElementById(`query_${q}`);
                    if (el && el.value.trim() !== '') {
                        url.searchParams.set(q, el.value.trim());
                    }
                }
            }

            return url.toString();
        }

        function updateCurlPreview() {
            const ep = activeEndpoint;
            const url = buildRequestUrl();
            let curl = `curl -X ${ep.method} "${url}" \\\n  -H "Accept: application/json"`;

            if (authToken) {
                curl += ` \\\n  -H "Authorization: Bearer ${authToken}"`;
            }

            if (['POST', 'PUT', 'PATCH'].includes(ep.method)) {
                const editor = document.getElementById('requestBodyEditor');
                if (editor && editor.value.trim()) {
                    curl += ` \\\n  -H "Content-Type: application/json" \\\n  -d '${editor.value.replace(/'/g, "\\'")}'`;
                }
            }

            const curlBox = document.getElementById('curlBox');
            if (curlBox) curlBox.innerText = curl;
        }

        function toggleCurl() {
            const curlBox = document.getElementById('curlBox');
            if (curlBox) {
                updateCurlPreview();
                curlBox.classList.toggle('show');
            }
        }

        async function executeActiveRequest() {
            const ep = activeEndpoint;
            const url = buildRequestUrl();
            const btn = document.getElementById('btnExecute');
            const viewer = document.getElementById('responseViewer');
            const resStatus = document.getElementById('resStatus');
            const resTime = document.getElementById('resTime');

            btn.disabled = true;
            btn.innerHTML = `<div class="spinner"></div> <span>Sending...</span>`;
            viewer.innerText = 'Connecting to backend...';
            resStatus.innerHTML = '';
            resTime.innerText = '';

            const headers = {
                'Accept': 'application/json'
            };

            if (authToken) {
                headers['Authorization'] = `Bearer ${authToken}`;
            }

            let body = null;
            if (['POST', 'PUT', 'PATCH'].includes(ep.method)) {
                headers['Content-Type'] = 'application/json';
                const editor = document.getElementById('requestBodyEditor');
                if (editor) {
                    body = editor.value.trim() || '{}';
                }
            }

            const startTime = performance.now();

            try {
                const response = await fetch(url, {
                    method: ep.method,
                    headers: headers,
                    body: body
                });

                const duration = Math.round(performance.now() - startTime);
                const status = response.status;
                const statusText = response.statusText;

                let data;
                const contentType = response.headers.get('content-type');
                if (contentType && contentType.includes('application/json')) {
                    data = await response.json();
                } else {
                    data = await response.text();
                }

                // If user just registered or logged in, save token automatically
                if ((ep.id === 'auth-login' || ep.id === 'auth-register') && data.success && data.data && data.data.access_token) {
                    setAuthToken(data.data.access_token, data.data.user);
                } else if (ep.id === 'auth-logout' && data.success) {
                    clearToken();
                }

                // Status badge
                let statusClass = 'status-2xx';
                if (status >= 400 && status < 500) statusClass = 'status-4xx';
                if (status >= 500) statusClass = 'status-5xx';

                resStatus.innerHTML = `<span class="status-badge-res ${statusClass}">${status} ${statusText}</span>`;
                resTime.innerText = `${duration} ms`;

                viewer.innerHTML = typeof data === 'object' ? syntaxHighlight(data) : escapeHtml(data);

            } catch (error) {
                const duration = Math.round(performance.now() - startTime);
                resStatus.innerHTML = `<span class="status-badge-res status-5xx">Network Error</span>`;
                resTime.innerText = `${duration} ms`;
                viewer.innerText = 'Request failed: ' + error.message + '\n\nMake sure the local server (php artisan serve) is running on http://127.0.0.1:8000';
            } finally {
                btn.disabled = false;
                btn.innerHTML = `<span>Send Request</span>`;
            }
        }

        async function quickLogin(email, roleLabel) {
            try {
                const response = await fetch(API_BASE + '/auth/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify({ email: email, password: 'password' })
                });
                const data = await response.json();
                if (data.success && data.data && data.data.access_token) {
                    setAuthToken(data.data.access_token, data.data.user);
                    alert(`✅ Logged in as ${roleLabel} (${email})!\nBearer token is now active for all authenticated API requests.`);
                } else {
                    alert('Login failed: ' + (data.message || 'Check database seeders'));
                }
            } catch (err) {
                alert('Connection error: ' + err.message);
            }
        }

        function setAuthToken(token, user) {
            authToken = token;
            currentUser = user;
            localStorage.setItem('api_bearer_token', token);
            localStorage.setItem('api_current_user', JSON.stringify(user));
            updateTokenBadge();
        }

        function clearToken() {
            authToken = '';
            currentUser = null;
            localStorage.removeItem('api_bearer_token');
            localStorage.removeItem('api_current_user');
            updateTokenBadge();
        }

        function updateTokenBadge() {
            const badge = document.getElementById('tokenBadge');
            const text = document.getElementById('tokenStatusText');

            if (authToken && currentUser) {
                badge.className = 'token-status';
                text.innerText = `🔑 ${currentUser.name} (${currentUser.role})`;
            } else if (authToken) {
                badge.className = 'token-status';
                text.innerText = `🔑 Bearer Token Active`;
            } else {
                badge.className = 'token-status unauthenticated';
                text.innerText = 'Unauthenticated';
            }

            updateCurlPreview();
        }

        function copyResponse() {
            const viewer = document.getElementById('responseViewer');
            if (viewer) {
                navigator.clipboard.writeText(viewer.innerText);
                alert('Copied response JSON to clipboard!');
            }
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.innerText = text;
            return div.innerHTML;
        }

        function syntaxHighlight(json) {
            if (typeof json !== 'string') {
                json = JSON.stringify(json, undefined, 2);
            }
            json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
                let cls = 'json-number';
                if (/^"/.test(match)) {
                    if (/:$/.test(match)) {
                        cls = 'json-key';
                    } else {
                        cls = 'json-string';
                    }
                } else if (/true|false/.test(match)) {
                    cls = 'json-boolean';
                } else if (/null/.test(match)) {
                    cls = 'json-null';
                }
                return '<span class="' + cls + '">' + match + '</span>';
            });
        }

        // Initialize UI
        renderNavigation(ENDPOINTS);
        renderMainContent();
        updateTokenBadge();
    </script>
</body>
</html>
