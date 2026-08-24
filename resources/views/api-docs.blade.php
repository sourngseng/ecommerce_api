<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title id="pageTitle">E-Commerce REST API Explorer & Live Testing Interface</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* CSS Variables - Dark Mode (Default) */
        :root, [data-theme="dark"] {
            --bg-main: #0b0f19;
            --bg-card: #111827;
            --bg-input: #1f2937;
            --bg-sidebar: #0e1526;
            --bg-panel: #0d1424;
            --bg-code: #060913;
            --border-color: #1f293d;
            --border-hover: #374151;
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --text-dim: #6b7280;
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --primary-glow: rgba(99, 102, 241, 0.25);
            --header-bg: rgba(14, 21, 38, 0.85);

            --method-get: #10b981;
            --method-post: #3b82f6;
            --method-put: #f59e0b;
            --method-delete: #ef4444;

            --badge-get-bg: rgba(16, 185, 129, 0.15);
            --badge-get-text: #34d399;
            --badge-post-bg: rgba(59, 130, 246, 0.15);
            --badge-post-text: #60a5fa;
            --badge-put-bg: rgba(245, 158, 11, 0.15);
            --badge-put-text: #fbbf24;
            --badge-delete-bg: rgba(239, 68, 68, 0.15);
            --badge-delete-text: #f87171;

            --status-success: #10b981;
            --status-error: #ef4444;
            --sidebar-width: 330px;
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            --json-key: #93c5fd;
            --json-string: #86efac;
            --json-number: #fcd34d;
            --json-boolean: #c084fc;
            --json-null: #9ca3af;
        }

        /* CSS Variables - Light Mode */
        [data-theme="light"] {
            --bg-main: #f8fafc;
            --bg-card: #ffffff;
            --bg-input: #f1f5f9;
            --bg-sidebar: #ffffff;
            --bg-panel: #f8fafc;
            --bg-code: #0f172a;
            --border-color: #e2e8f0;
            --border-hover: #cbd5e1;
            --text-main: #0f172a;
            --text-muted: #475569;
            --text-dim: #64748b;
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --primary-glow: rgba(79, 70, 229, 0.15);
            --header-bg: rgba(255, 255, 255, 0.9);

            --method-get: #059669;
            --method-post: #2563eb;
            --method-put: #d97706;
            --method-delete: #dc2626;

            --badge-get-bg: #ecfdf5;
            --badge-get-text: #059669;
            --badge-post-bg: #eff6ff;
            --badge-post-text: #2563eb;
            --badge-put-bg: #fffbeb;
            --badge-put-text: #d97706;
            --badge-delete-bg: #fef2f2;
            --badge-delete-text: #dc2626;

            --status-success: #059669;
            --status-error: #dc2626;
            --sidebar-width: 330px;
            --card-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
            --json-key: #93c5fd;
            --json-string: #86efac;
            --json-number: #fcd34d;
            --json-boolean: #c084fc;
            --json-null: #9ca3af;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            transition: background-color 0.2s ease, border-color 0.2s ease, color 0.2s ease;
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
            background-color: var(--header-bg);
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
            cursor: pointer;
            padding: 4px 8px;
            border-radius: 8px;
            transition: background-color 0.2s ease;
        }

        .logo-group:hover {
            background-color: rgba(99, 102, 241, 0.08);
        }

        .logo-badge {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #6366f1, #ec4899);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 18px;
            color: white;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);
            overflow: hidden;
            flex-shrink: 0;
        }

        .logo-badge img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .logo-title-wrap {
            display: flex;
            flex-direction: column;
        }

        .logo-title-row {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .logo-title {
            font-size: 16.5px;
            font-weight: 800;
            letter-spacing: -0.3px;
        }

        .edit-brand-badge {
            font-size: 10.5px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 4px;
            background: rgba(99, 102, 241, 0.15);
            color: var(--primary);
            border: 1px solid rgba(99, 102, 241, 0.3);
            display: flex;
            align-items: center;
            gap: 3px;
        }

        .logo-subtitle {
            font-size: 12px;
            color: var(--text-dim);
            font-weight: 500;
        }

        .auth-bar {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .quick-login-label {
            font-size: 11px;
            color: var(--text-dim);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
        }

        .quick-btn {
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            color: var(--text-main);
            padding: 6px 11px;
            border-radius: 6px;
            font-size: 11.5px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .quick-btn:hover {
            border-color: var(--primary);
            color: var(--primary);
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
            color: #ef4444;
        }

        .logout-btn {
            background: rgba(239, 68, 68, 0.12);
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #ef4444;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 11.5px;
            font-weight: 700;
            cursor: pointer;
            display: none;
            align-items: center;
            gap: 5px;
        }

        .logout-btn:hover {
            background: #ef4444;
            color: white;
            transform: translateY(-1px);
        }

        /* Theme Switcher Button */
        .theme-toggle-btn {
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            color: var(--text-main);
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 16px;
            user-select: none;
        }

        .theme-toggle-btn:hover {
            border-color: var(--border-hover);
            transform: translateY(-1px);
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
            padding: 14px 14px 10px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .search-input {
            width: 100%;
            background-color: var(--bg-input);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 9px 12px;
            color: var(--text-main);
            font-size: 12.5px;
            outline: none;
            font-family: inherit;
        }

        .search-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-glow);
        }

        /* Method Filter Pills */
        .method-filters {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .filter-pill {
            background: var(--bg-input);
            border: 1px solid var(--border-color);
            color: var(--text-dim);
            font-size: 10.5px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
            cursor: pointer;
            font-family: 'JetBrains Mono', monospace;
            text-transform: uppercase;
        }

        .filter-pill:hover, .filter-pill.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
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
            padding: 14px 8px 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 7px 10px;
            border-radius: 6px;
            font-size: 12px;
            color: var(--text-muted);
            text-decoration: none;
            cursor: pointer;
            margin-bottom: 2px;
        }

        .nav-item:hover {
            background-color: var(--bg-card);
            color: var(--text-main);
        }

        .nav-item.active {
            background-color: rgba(99, 102, 241, 0.15);
            color: var(--text-main);
            font-weight: 700;
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

        .badge-get { background: var(--badge-get-bg); color: var(--badge-get-text); border: 1px solid rgba(16, 185, 129, 0.2); }
        .badge-post { background: var(--badge-post-bg); color: var(--badge-post-text); border: 1px solid rgba(59, 130, 246, 0.2); }
        .badge-put { background: var(--badge-put-bg); color: var(--badge-put-text); border: 1px solid rgba(245, 158, 11, 0.2); }
        .badge-delete { background: var(--badge-delete-bg); color: var(--badge-delete-text); border: 1px solid rgba(239, 68, 68, 0.2); }

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
            padding: 24px 32px;
            background-color: var(--bg-main);
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .endpoint-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 24px;
            box-shadow: var(--card-shadow);
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
            font-weight: 700;
            color: var(--text-main);
        }

        .endpoint-desc {
            font-size: 13.5px;
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
            color: #818cf8;
            border: 1px solid rgba(99, 102, 241, 0.25);
        }

        .auth-tag {
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 6px;
            background: rgba(245, 158, 11, 0.15);
            color: #f59e0b;
            border: 1px solid rgba(245, 158, 11, 0.25);
        }

        .auth-tag.public {
            background: rgba(16, 185, 129, 0.15);
            color: #10b981;
            border-color: rgba(16, 185, 129, 0.25);
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
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .panel-title {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-dim);
            text-transform: uppercase;
            letter-spacing: 0.6px;
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
            color: var(--text-main);
            font-size: 13px;
            font-family: 'JetBrains Mono', monospace;
            outline: none;
            width: 100%;
        }

        .input-text:focus {
            border-color: var(--primary);
        }

        .json-editor {
            background-color: var(--bg-code);
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
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 11.5px;
            font-weight: 600;
            cursor: pointer;
        }

        .btn-secondary:hover {
            color: var(--text-main);
            border-color: var(--border-hover);
        }

        /* Response View Box */
        .response-box {
            background-color: var(--bg-code);
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
            font-size: 11.5px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
        }

        .status-2xx { background: rgba(16, 185, 129, 0.2); color: #34d399; }
        .status-4xx { background: rgba(245, 158, 11, 0.2); color: #fbbf24; }
        .status-5xx { background: rgba(239, 68, 68, 0.2); color: #f87171; }

        /* JSON Syntax Highlighting */
        .json-key { color: var(--json-key); }
        .json-string { color: var(--json-string); }
        .json-number { color: var(--json-number); }
        .json-boolean { color: var(--json-boolean); }
        .json-null { color: var(--json-null); }

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
            background: var(--bg-code);
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
        <div class="logo-group" onclick="openBrandingModal()" title="Click to customize App Name & Logo">
            <div class="logo-badge" id="appLogoBadge">⚡</div>
            <div class="logo-title-wrap">
                <div class="logo-title-row">
                    <div class="logo-title" id="appHeaderTitle">E-Commerce REST API Explorer</div>
                    <span class="edit-brand-badge">✏️ Edit App</span>
                </div>
                <div class="logo-subtitle" id="appHeaderSubtitle">Laravel 12 &bull; Sanctum Auth &bull; 72+ Endpoints</div>
            </div>
        </div>

        <div class="auth-bar">
            <span class="quick-login-label">1-Click Login:</span>
            <button class="quick-btn" onclick="quickLogin('admin@ecommerce.test', 'Super Admin')">👑 Admin</button>
            <button class="quick-btn" onclick="quickLogin('sokha@phnompenhelectronics.com', 'Sokha (Electronics)')">🏪 Sokha</button>
            <button class="quick-btn" onclick="quickLogin('bopha@angkorfashion.com', 'Bopha (Fashion)')">👗 Bopha</button>
            <button class="quick-btn" onclick="quickLogin('rithy.sok@example.com', 'Rithy Sok (Customer)')">👤 Rithy</button>

            <div id="tokenBadge" class="token-status unauthenticated">
                <span id="tokenStatusText">Unauthenticated</span>
            </div>

            <!-- Logout Button -->
            <button class="logout-btn" id="btnLogout" onclick="confirmLogout()">
                🚪 Logout
            </button>

            <!-- Dark / Light Mode Toggle Button -->
            <button class="theme-toggle-btn" id="themeToggleBtn" title="Toggle Dark / Light Mode" onclick="toggleTheme()">
                🌙
            </button>
        </div>
    </header>

    <div class="app-container">
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <div class="search-box">
                <input type="text" id="endpointSearch" class="search-input" placeholder="Search 72+ API endpoints (e.g. settings, upload, banner)..." oninput="filterEndpoints()">
                <div class="method-filters">
                    <button class="filter-pill active" onclick="setMethodFilter('ALL')">ALL</button>
                    <button class="filter-pill" onclick="setMethodFilter('GET')">GET</button>
                    <button class="filter-pill" onclick="setMethodFilter('POST')">POST</button>
                    <button class="filter-pill" onclick="setMethodFilter('PUT')">PUT</button>
                    <button class="filter-pill" onclick="setMethodFilter('DELETE')">DEL</button>
                </div>
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
        let currentSettings = {};
        let selectedMethodFilter = 'ALL';

        // Theme management (dark / light mode)
        let currentTheme = localStorage.getItem('api_docs_theme') || (window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
        applyTheme(currentTheme);

        function applyTheme(theme) {
            currentTheme = theme;
            document.documentElement.setAttribute('data-theme', theme);
            localStorage.setItem('api_docs_theme', theme);
            const btn = document.getElementById('themeToggleBtn');
            if (btn) {
                btn.innerHTML = theme === 'dark' ? '🌙' : '☀️';
                btn.setAttribute('title', theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode');
            }
        }

        function toggleTheme() {
            const nextTheme = currentTheme === 'dark' ? 'light' : 'dark';
            applyTheme(nextTheme);
        }

        const ENDPOINTS = [
            // 1. General Settings & System (Logo, Favicon, Banners, Sliders)
            {
                id: 'settings-get',
                category: 'General Settings & Banners',
                method: 'GET',
                path: '/settings',
                title: 'Get General System Settings',
                desc: 'Retrieve public system configurations: Logo, Favicon, Title, Tagline, Currency ($/KHR), Contact Info, and Footer Copyright.',
                auth: false,
                role: 'Public',
                body: null
            },
            {
                id: 'banners-get',
                category: 'General Settings & Banners',
                method: 'GET',
                path: '/banners',
                title: 'List Active Sliders & Banners',
                desc: 'Retrieve active homepage sliders, promo banners, and hero ads with sorting and position filtering.',
                auth: false,
                role: 'Public',
                queryParams: { position: 'slider' },
                body: null
            },
            {
                id: 'admin-settings-get',
                category: 'General Settings & Banners',
                method: 'GET',
                path: '/admin/settings',
                title: 'Admin: Get All System Settings',
                desc: 'Retrieve complete system configuration grouped by category (general, contact, localization).',
                auth: true,
                role: 'Super Admin Only',
                body: null
            },
            {
                id: 'admin-settings-update',
                category: 'General Settings & Banners',
                method: 'PUT',
                path: '/admin/settings',
                title: 'Admin: Update System Settings (Logo, Favicon, App Name)',
                desc: 'Bulk update system name, logo URL, favicon URL, contact details, currency, and copyright.',
                auth: true,
                role: 'Super Admin Only',
                body: {
                    settings: [
                        { key: "site_title", value: "Cambodia Premier E-Commerce Hub", group: "general" },
                        { key: "site_tagline", value: "No. 1 Trusted Marketplace in Cambodia", group: "general" },
                        { key: "site_logo", value: "https://picsum.photos/seed/cambodia-ecom-logo/400/120", group: "general" },
                        { key: "site_favicon", value: "https://picsum.photos/seed/cambodia-ecom-favicon/64/64", group: "general" },
                        { key: "contact_email", value: "support@ecommerce.test", group: "contact" },
                        { key: "contact_phone", value: "+855 23 888 999", group: "contact" },
                        { key: "default_currency", value: "USD", group: "localization" },
                        { key: "currency_symbol", value: "$", group: "localization" },
                        { key: "exchange_rate_khr", value: "4100", group: "localization" }
                    ]
                }
            },
            {
                id: 'admin-settings-upload',
                category: 'General Settings & Banners',
                method: 'POST',
                path: '/admin/settings/upload',
                title: 'Admin: Upload Logo, Favicon or Banner Image',
                desc: 'Upload image file directly to server public storage (/storage/settings/...) and updates site_logo or site_favicon.',
                auth: true,
                role: 'Super Admin Only',
                body: {
                    type: "logo"
                }
            },
            {
                id: 'admin-banners-list',
                category: 'General Settings & Banners',
                method: 'GET',
                path: '/admin/banners',
                title: 'Admin: List All Sliders & Banners',
                desc: 'Paginated overview of all banners with position filter and status toggle.',
                auth: true,
                role: 'Super Admin Only',
                queryParams: { position: '', status: 'active', per_page: 15 },
                body: null
            },
            {
                id: 'admin-banner-create',
                category: 'General Settings & Banners',
                method: 'POST',
                path: '/admin/banners',
                title: 'Admin: Create Slider / Banner',
                desc: 'Create new homepage slider, hero banner, or promotional banner.',
                auth: true,
                role: 'Super Admin Only',
                body: {
                    title: "Water Festival Grand Sale 2026",
                    subtitle: "Up to 50% off on all trending products",
                    image_url: "https://picsum.photos/seed/water-festival-banner/1200/500",
                    link_url: "/products",
                    button_text: "Shop the Sale",
                    position: "slider",
                    order: 1,
                    status: "active"
                }
            },
            {
                id: 'admin-banner-show',
                category: 'General Settings & Banners',
                method: 'GET',
                path: '/admin/banners/{banner}',
                title: 'Admin: Get Banner Details',
                desc: 'Retrieve details for a single slider or banner.',
                auth: true,
                role: 'Super Admin Only',
                params: { banner: '1' },
                body: null
            },
            {
                id: 'admin-banner-update',
                category: 'General Settings & Banners',
                method: 'PUT',
                path: '/admin/banners/{banner}',
                title: 'Admin: Update Slider / Banner',
                desc: 'Update banner image, title, link URL, position, or order.',
                auth: true,
                role: 'Super Admin Only',
                params: { banner: '1' },
                body: {
                    title: "Updated Banner Title",
                    subtitle: "Limited time special discount",
                    status: "active"
                }
            },
            {
                id: 'admin-banner-delete',
                category: 'General Settings & Banners',
                method: 'DELETE',
                path: '/admin/banners/{banner}',
                title: 'Admin: Delete Slider / Banner',
                desc: 'Delete slider or promotional banner from system.',
                auth: true,
                role: 'Super Admin Only',
                params: { banner: '5' },
                body: null
            },

            // 2. Authentication
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

            // 3. Categories
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

            // 4. Products & Search
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

            // 5. Vendors
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

            // 6. Shopping Cart
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

            // 7. Wishlist
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

            // 8. Customer Profile & Addresses
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

            // 9. Orders & Payments
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

            // 10. Reviews
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

            // 11. Vendor Dashboard & Management
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

            // 12. Super Admin Dashboard & Global Management
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

        // Fetch settings from server on boot
        async function fetchSystemSettings() {
            try {
                const response = await fetch(API_BASE + '/settings');
                const data = await response.json();
                if (data.success && data.data) {
                    currentSettings = data.data;
                    applyHeaderSettings(data.data);
                }
            } catch (e) {
                console.warn('Could not load dynamic settings:', e);
            }
        }

        function applyHeaderSettings(settings) {
            const titleEl = document.getElementById('appHeaderTitle');
            const subEl = document.getElementById('appHeaderSubtitle');
            const logoBadge = document.getElementById('appLogoBadge');
            const pageTitle = document.getElementById('pageTitle');

            if (settings.site_title) {
                if (titleEl) titleEl.innerText = settings.site_title;
                if (pageTitle) pageTitle.innerText = settings.site_title + ' - REST API Explorer';
            }

            if (settings.site_tagline && subEl) {
                subEl.innerText = settings.site_tagline;
            }

            if (settings.site_logo && logoBadge) {
                logoBadge.innerHTML = `<img src="${settings.site_logo}" alt="App Logo" style="width:100%; height:100%; object-fit:contain;" onerror="this.onerror=null; this.parentElement.innerText='⚡';">`;
            }
        }

        // Open Branding & Logo Customizer Modal
        async function openBrandingModal() {
            const isAdmin = currentUser && currentUser.role === 'admin';
            const currentTitle = currentSettings.site_title || (document.getElementById('appHeaderTitle')?.innerText || 'E-Commerce REST API Explorer');
            const currentTagline = currentSettings.site_tagline || 'Best online shopping experience across Cambodia';
            const currentLogo = currentSettings.site_logo || '';
            const currentFavicon = currentSettings.site_favicon || '';

            const isDark = currentTheme === 'dark';

            const { value: formValues } = await Swal.fire({
                title: '⚙️ App Branding & Logo Customizer',
                html: `
                    <div style="text-align:left; font-size:13px; display:flex; flex-direction:column; gap:14px; margin-top:10px;">
                        ${!isAdmin ? `
                            <div style="background:rgba(245,158,11,0.15); border:1px solid rgba(245,158,11,0.3); color:#f59e0b; padding:8px 12px; border-radius:6px; font-size:12px; display:flex; justify-content:space-between; align-items:center;">
                                <span>⚠️ Admin login required to save settings permanently.</span>
                                <button type="button" onclick="quickLogin('admin@ecommerce.test', 'Super Admin'); Swal.close();" style="background:#f59e0b; color:black; border:none; padding:4px 8px; border-radius:4px; font-weight:700; cursor:pointer; font-size:11px;">1-Click Admin</button>
                            </div>
                        ` : ''}

                        <div>
                            <label style="font-weight:700; color:var(--text-main); font-size:12px; margin-bottom:4px; display:block;">App / Website Name:</label>
                            <input type="text" id="swalAppName" class="swal2-input" value="${currentTitle}" placeholder="e.g. Cambodia Premier E-Commerce" style="margin:0; width:100%; font-size:13px; padding:10px;">
                        </div>

                        <div>
                            <label style="font-weight:700; color:var(--text-main); font-size:12px; margin-bottom:4px; display:block;">App Tagline / Subtitle:</label>
                            <input type="text" id="swalAppTagline" class="swal2-input" value="${currentTagline}" placeholder="e.g. No. 1 Marketplace in Cambodia" style="margin:0; width:100%; font-size:13px; padding:10px;">
                        </div>

                        <div style="border:1px dashed var(--border-color); padding:12px; border-radius:8px; background:var(--bg-input);">
                            <label style="font-weight:700; color:var(--text-main); font-size:12px; margin-bottom:4px; display:block;">Logo Image Upload:</label>
                            <input type="file" id="swalLogoFile" accept="image/*" style="font-size:12px; color:var(--text-main); width:100%; margin-top:4px;">
                            <div style="font-size:11px; color:var(--text-dim); margin-top:6px;">Or paste Logo Image URL:</div>
                            <input type="text" id="swalLogoUrl" class="swal2-input" value="${currentLogo}" placeholder="https://example.com/logo.png" style="margin:4px 0 0 0; width:100%; font-size:12px; padding:8px;">
                        </div>

                        <div style="border:1px dashed var(--border-color); padding:12px; border-radius:8px; background:var(--bg-input);">
                            <label style="font-weight:700; color:var(--text-main); font-size:12px; margin-bottom:4px; display:block;">Favicon Image Upload / URL:</label>
                            <input type="file" id="swalFaviconFile" accept="image/*" style="font-size:12px; color:var(--text-main); width:100%; margin-top:4px;">
                            <input type="text" id="swalFaviconUrl" class="swal2-input" value="${currentFavicon}" placeholder="https://example.com/favicon.ico" style="margin:4px 0 0 0; width:100%; font-size:12px; padding:8px;">
                        </div>
                    </div>
                `,
                focusConfirm: false,
                showCancelButton: true,
                confirmButtonText: '💾 Save App Branding',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#6366f1',
                cancelButtonColor: '#6b7280',
                background: isDark ? '#111827' : '#ffffff',
                color: isDark ? '#f3f4f6' : '#0f172a',
                preConfirm: () => {
                    return {
                        name: document.getElementById('swalAppName').value.trim(),
                        tagline: document.getElementById('swalAppTagline').value.trim(),
                        logoFile: document.getElementById('swalLogoFile').files[0],
                        logoUrl: document.getElementById('swalLogoUrl').value.trim(),
                        faviconFile: document.getElementById('swalFaviconFile').files[0],
                        faviconUrl: document.getElementById('swalFaviconUrl').value.trim(),
                    };
                }
            });

            if (formValues) {
                await saveBrandingSettings(formValues);
            }
        }

        async function saveBrandingSettings(values) {
            if (!authToken) {
                // Apply locally only
                applyHeaderSettings({
                    site_title: values.name,
                    site_tagline: values.tagline,
                    site_logo: values.logoUrl,
                });
                showToast('info', 'Updated Temporarily', 'Login as Admin to persist settings in the database.');
                return;
            }

            try {
                Swal.fire({
                    title: 'Saving Branding...',
                    text: 'Uploading assets and updating database records.',
                    allowOutsideClick: false,
                    didOpen: () => Swal.showLoading(),
                    background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                    color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                });

                let uploadedLogoUrl = values.logoUrl;
                let uploadedFaviconUrl = values.faviconUrl;

                // 1. If logo file uploaded, send to /admin/settings/upload
                if (values.logoFile) {
                    const formData = new FormData();
                    formData.append('file', values.logoFile);
                    formData.append('type', 'logo');

                    const uploadRes = await fetch(API_BASE + '/admin/settings/upload', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Authorization': `Bearer ${authToken}`
                        },
                        body: formData
                    });
                    const uploadData = await uploadRes.json();
                    if (uploadData.success && uploadData.data && uploadData.data.url) {
                        uploadedLogoUrl = uploadData.data.url;
                    }
                }

                // 2. If favicon file uploaded
                if (values.faviconFile) {
                    const formData = new FormData();
                    formData.append('file', values.faviconFile);
                    formData.append('type', 'favicon');

                    const uploadRes = await fetch(API_BASE + '/admin/settings/upload', {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Authorization': `Bearer ${authToken}`
                        },
                        body: formData
                    });
                    const uploadData = await uploadRes.json();
                    if (uploadData.success && uploadData.data && uploadData.data.url) {
                        uploadedFaviconUrl = uploadData.data.url;
                    }
                }

                // 3. Update site_title, site_tagline, site_logo, site_favicon in settings table
                const settingsPayload = {
                    settings: [
                        { key: "site_title", value: values.name, group: "general" },
                        { key: "site_tagline", value: values.tagline, group: "general" }
                    ]
                };

                if (uploadedLogoUrl) {
                    settingsPayload.settings.push({ key: "site_logo", value: uploadedLogoUrl, group: "general" });
                }
                if (uploadedFaviconUrl) {
                    settingsPayload.settings.push({ key: "site_favicon", value: uploadedFaviconUrl, group: "general" });
                }

                const response = await fetch(API_BASE + '/admin/settings', {
                    method: 'PUT',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${authToken}`
                    },
                    body: JSON.stringify(settingsPayload)
                });

                const data = await response.json();

                if (data.success) {
                    currentSettings = data.data;
                    applyHeaderSettings(data.data);

                    Swal.fire({
                        icon: 'success',
                        title: 'App Branding Updated!',
                        html: `<div style="font-size:13px; line-height:1.6; margin-top:8px;">
                            <b>App Name:</b> ${escapeHtml(values.name)}<br>
                            <b>Tagline:</b> ${escapeHtml(values.tagline)}<br>
                            <span style="color:#10b981; font-size:12px;">✅ Saved permanently to database and live in header.</span>
                        </div>`,
                        confirmButtonColor: '#6366f1',
                        background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                        color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Update Failed',
                        text: data.message || 'Could not update settings',
                        confirmButtonColor: '#6366f1',
                        background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                        color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                    });
                }

            } catch (err) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: err.message,
                    confirmButtonColor: '#6366f1',
                    background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                    color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                });
            }
        }

        function setMethodFilter(method) {
            selectedMethodFilter = method;
            document.querySelectorAll('.filter-pill').forEach(btn => {
                btn.classList.toggle('active', btn.innerText === (method === 'DELETE' ? 'DEL' : method));
            });
            filterEndpoints();
        }

        function renderNavigation(items) {
            const container = document.getElementById('navContainer');
            container.innerHTML = '';

            const categories = {};
            items.forEach(ep => {
                if (!categories[ep.category]) categories[ep.category] = [];
                categories[ep.category].push(ep);
            });

            if (Object.keys(categories).length === 0) {
                container.innerHTML = '<div style="padding:20px; color:var(--text-dim); text-align:center; font-size:12px;">No endpoints match search filter</div>';
                return;
            }

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
            const filtered = ENDPOINTS.filter(ep => {
                const matchesMethod = (selectedMethodFilter === 'ALL' || ep.method === selectedMethodFilter);
                const matchesQuery = !query || (
                    ep.path.toLowerCase().includes(query) ||
                    ep.title.toLowerCase().includes(query) ||
                    ep.method.toLowerCase().includes(query) ||
                    ep.category.toLowerCase().includes(query)
                );
                return matchesMethod && matchesQuery;
            });
            renderNavigation(filtered);
        }

        function selectEndpoint(ep) {
            activeEndpoint = ep;
            filterEndpoints();
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
                            <span style="font-family:'JetBrains Mono'; font-size:12px; min-width:100px; color:var(--text-muted);">${q}</span>
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
                                <span style="font-size:11px; color:var(--text-dim);">Live API Execution</span>
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

                            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:4px;">
                                <button class="btn-secondary" onclick="clearResponseViewer()">Clear</button>
                                <button class="btn-secondary" onclick="copyResponse()">Copy JSON</button>
                            </div>
                        </div>
                    </div>
                </div>
            `;

            updateCurlPreview();
        }

        function clearResponseViewer() {
            const viewer = document.getElementById('responseViewer');
            const resStatus = document.getElementById('resStatus');
            const resTime = document.getElementById('resTime');
            if (viewer) viewer.innerText = '// Response cleared.';
            if (resStatus) resStatus.innerHTML = '';
            if (resTime) resTime.innerText = '';
        }

        function formatJsonBody() {
            const editor = document.getElementById('requestBodyEditor');
            if (editor) {
                try {
                    const parsed = JSON.parse(editor.value);
                    editor.value = JSON.stringify(parsed, null, 2);
                    showToast('success', 'JSON formatted successfully');
                } catch(e) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Invalid JSON Format',
                        text: e.message,
                        background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                        color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                        confirmButtonColor: '#6366f1'
                    });
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

        function showToast(icon, title, text = '') {
            const isDark = currentTheme === 'dark';
            Swal.fire({
                toast: true,
                position: 'top-end',
                icon: icon,
                title: title,
                text: text,
                showConfirmButton: false,
                timer: 3000,
                timerProgressBar: true,
                background: isDark ? '#111827' : '#ffffff',
                color: isDark ? '#f3f4f6' : '#0f172a',
                didOpen: (toast) => {
                    toast.onmouseenter = Swal.stopTimer;
                    toast.onmouseleave = Swal.resumeTimer;
                }
            });
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
                    
                    Swal.fire({
                        icon: 'success',
                        title: `Authenticated as ${roleLabel}!`,
                        html: `<div style="font-size:13px; margin-top:8px; line-height:1.6;">
                            <b>User:</b> ${data.data.user.name} (${email})<br>
                            <b>Role:</b> <span style="text-transform:capitalize; color:#6366f1; font-weight:700;">${data.data.user.role}</span><br>
                            <span style="color:#10b981; font-size:12px; margin-top:6px; display:inline-block;">⚡ Bearer Token is now active for all API requests.</span>
                        </div>`,
                        background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                        color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                        confirmButtonColor: '#6366f1',
                        confirmButtonText: 'Start Testing Endpoints'
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Login Failed',
                        text: data.message || 'Check database seeders.',
                        background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                        color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                        confirmButtonColor: '#6366f1'
                    });
                }
            } catch (err) {
                Swal.fire({
                    icon: 'error',
                    title: 'Connection Error',
                    text: err.message,
                    background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                    color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
                    confirmButtonColor: '#6366f1'
                });
            }
        }

        async function confirmLogout() {
            const result = await Swal.fire({
                title: 'Log out of current session?',
                text: 'This will revoke your Sanctum bearer token.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Yes, Log Out',
                cancelButtonText: 'Cancel',
                background: currentTheme === 'dark' ? '#111827' : '#ffffff',
                color: currentTheme === 'dark' ? '#f3f4f6' : '#0f172a',
            });

            if (result.isConfirmed) {
                if (authToken) {
                    try {
                        await fetch(API_BASE + '/auth/logout', {
                            method: 'POST',
                            headers: {
                                'Accept': 'application/json',
                                'Authorization': `Bearer ${authToken}`
                            }
                        });
                    } catch (e) {
                        // ignore and clear locally
                    }
                }
                clearToken();
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
            showToast('info', 'Logged Out', 'Bearer token session cleared.');
        }

        function updateTokenBadge() {
            const badge = document.getElementById('tokenBadge');
            const text = document.getElementById('tokenStatusText');
            const logoutBtn = document.getElementById('btnLogout');

            if (authToken && currentUser) {
                badge.className = 'token-status';
                text.innerText = `🔑 ${currentUser.name} (${currentUser.role})`;
                if (logoutBtn) logoutBtn.style.display = 'flex';
            } else if (authToken) {
                badge.className = 'token-status';
                text.innerText = `🔑 Bearer Token Active`;
                if (logoutBtn) logoutBtn.style.display = 'flex';
            } else {
                badge.className = 'token-status unauthenticated';
                text.innerText = 'Unauthenticated';
                if (logoutBtn) logoutBtn.style.display = 'none';
            }

            updateCurlPreview();
        }

        function copyResponse() {
            const viewer = document.getElementById('responseViewer');
            if (viewer) {
                navigator.clipboard.writeText(viewer.innerText);
                showToast('success', 'Copied to Clipboard!', 'Response JSON copied.');
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
        fetchSystemSettings();
        renderNavigation(ENDPOINTS);
        renderMainContent();
        updateTokenBadge();
    </script>
</body>
</html>
