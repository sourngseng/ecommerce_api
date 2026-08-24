# ⚡ Laravel 12 E-Commerce REST API & In-Browser Testing Explorer

A production-ready, feature-complete multi-vendor **E-Commerce RESTful API** built with **Laravel 12**, **Laravel Sanctum**, and **PHP 8.2+**. Localized with realistic **Cambodian marketplaces, store locations, and currency presets (USD / KHR)**.

Includes a built-in **Interactive Web-Based API Explorer & Live Testing Playground** — test all 71+ endpoints directly in your browser without requiring Postman!

---

## 🌟 Key Features

### 🖥️ In-Browser Interactive API Explorer (Postman Alternative)
- **Direct Browser Testing**: Accessible at `http://localhost:8000/` or `http://localhost:8000/docs`.
- **🌙 Dark / ☀️ Light Mode**: High-contrast theme toggle with persistent `localStorage` preference and auto OS detection.
- **⚡ 1-Click Authentication**: Instant Bearer token login presets for **Admin**, **Electronics Vendor**, **Fashion Vendor**, and **Customer**.
- **🚪 Interactive Logout**: One-click session invalidation and database token revocation with SweetAlert2 modals.
- **🔍 Real-Time Method Filters & Search**: Filter 71+ routes by `ALL`, `GET`, `POST`, `PUT`, `DEL` or keyword search.
- **🚀 Live Request Runner**: Path/Query parameter inputs, formatted JSON editors, response time latency metrics, HTTP status badges, and 1-click **cURL generator**.

### ⚙️ General System Settings & Banners
- **Branding & Identity**: Site Title, Tagline, Company Name, **Logo URL**, **Favicon URL**, and Footer Copyright.
- **Localization & Currency**: Default Currency (`USD`), Currency Symbol (`$`), and Exchange Rate to Cambodian Riel (`4,100 KHR`).
- **Contact & Socials**: Support email, phone, physical address, Facebook page, and Telegram channel.
- **Homepage Banners & Sliders**: Multi-position banner management (`slider`, `hero_banner`, `promo_banner`, `sidebar_banner`) with active status and sorting order.

### 🛍️ Complete E-Commerce Lifecycle
- **Authentication & RBAC**: Laravel Sanctum tokens with `admin`, `vendor`, and `customer` role separation.
- **Product Catalog & Search**: Instant keyword search, multi-filter queries (category, vendor, min/max price, featured), multi-image gallery uploads, and related products.
- **Shopping Cart**: Real-time subtotal, discount, tax, shipping, and promo coupon calculation (`WELCOME10`, `CAMBODIA50`).
- **Wishlist**: Customer saved items with duplicate prevention.
- **Inventory Tracking**: Automated warehouse deductions on order checkout and automatic stock restoration upon cancellation with audit logs.
- **Order Lifecycles & Payments**: Multi-item orders, Cambodian delivery addresses, and payment simulation (`demo_card`, `bank_transfer`, `cash_on_delivery`).
- **Verified Buyer Reviews**: 1-5 star ratings and reviews restricted to verified purchasers with average score recalculation.
- **Vendor Portal**: Isolated vendor product CRUD, image galleries, order fulfillment, and low-stock monitors.
- **Admin Dashboard**: Live aggregated statistics (total customers, vendors, products, revenue, top-selling items).

---

## 🚀 Quick Start Guide

### 1. Requirements
- **PHP 8.2** or higher
- **Composer 2.x**
- **PostgreSQL**, **MySQL**, or **SQLite**

### 2. Installation & Dependencies
```bash
# Clone repository
git clone https://github.com/sourngseng/ecommerce_api.git
cd ecommerce_api

# Install Composer packages
composer install
```

### 3. Environment Configuration
Copy the example environment file and generate the application encryption key:
```bash
cp .env.example .env
php artisan key:generate
```

Configure your database connection in `.env` (PostgreSQL default):
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=ecommerce_api
DB_USERNAME=postgres
DB_PASSWORD=your_password
```
*(Or set `DB_CONNECTION=sqlite` for zero-configuration local testing)*

### 4. Database Migrations & Cambodian Demo Seeding
Run migrations and populate the database with realistic Cambodian stores, customers, addresses, products, orders, and system settings:
```bash
php artisan migrate:fresh --seed
```

### 5. Start the Development Server
```bash
php artisan serve
```

---

## 🌐 How to Use the In-Browser Testing Interface

Once `php artisan serve` is running, open your web browser and navigate to:
👉 **[http://localhost:8000](http://localhost:8000)** (or **[http://localhost:8000/docs](http://localhost:8000/docs)**)

1. Click any **1-Click Login** button at the top (e.g. `👑 Admin`, `🏪 Sokha`, or `👤 Rithy`).
2. Select any endpoint from the sidebar.
3. Click **"Send Request"** to execute live API queries against your local backend.
4. Switch between **Dark Mode 🌙** and **Light Mode ☀️** anytime via the top header toggle.

---

## 🔑 Seeded Demo Accounts

All seeded demo accounts use the password: `password`

| Role | Name | Email | Password | Description |
|---|---|---|---|---|
| 👑 **Super Admin** | System Administrator | `admin@ecommerce.test` | `password` | Full platform control & analytics |
| 🏪 **Vendor** | Sokha Chan | `sokha@phnompenhelectronics.com` | `password` | Phnom Penh Electronics Store |
| 👗 **Vendor** | Bopha Vong | `bopha@angkorfashion.com` | `password` | Angkor Fashion Hub |
| 💻 **Vendor** | Dara Sam | `dara@sovannaphumgadgets.com` | `password` | Sovannaphum Gadgets |
| 👤 **Customer** | Rithy Sok | `rithy.sok@example.com` | `password` | Customer with Phnom Penh Address |
| 👤 **Customer** | Kalyan Keo | `kalyan.keo@example.com` | `password` | Customer with Siem Reap Address |

---

## 📋 API Endpoints Matrix (71+ Endpoints)

All API routes are prefixed with `/api/v1`:

### 1. General Settings & Banners
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `GET` | `/api/v1/settings` | Public | Get system site title, logo, favicon, currency, contact info |
| `GET` | `/api/v1/banners` | Public | List active homepage sliders & promo banners |
| `GET` | `/api/v1/admin/settings` | Admin | Get all system settings grouped by category |
| `PUT` | `/api/v1/admin/settings` | Admin | Bulk update site name, logo, favicon, currency settings |
| `GET` | `/api/v1/admin/banners` | Admin | List all sliders and promotional banners |
| `POST` | `/api/v1/admin/banners` | Admin | Create new homepage slider or promo banner |
| `GET` | `/api/v1/admin/banners/{id}` | Admin | Get single banner details |
| `PUT` | `/api/v1/admin/banners/{id}` | Admin | Update banner title, image, link, position |
| `DELETE` | `/api/v1/admin/banners/{id}` | Admin | Delete banner / slider |

### 2. Authentication
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `POST` | `/api/v1/auth/register` | Public | Register customer or vendor account |
| `POST` | `/api/v1/auth/login` | Public | Authenticate credentials & get Bearer Token |
| `GET` | `/api/v1/auth/me` | Auth | Get current authenticated profile & roles |
| `POST` | `/api/v1/auth/logout` | Auth | Revoke token & invalidate session |

### 3. Categories & Products
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `GET` | `/api/v1/categories` | Public | List active product categories |
| `GET` | `/api/v1/categories/{id}` | Public | Get category details by ID or Slug |
| `GET` | `/api/v1/categories/{id}/products` | Public | Paginated products in category |
| `GET` | `/api/v1/products` | Public | Filter products by category, vendor, price, sort |
| `GET` | `/api/v1/products/search` | Public | Instant keyword search |
| `GET` | `/api/v1/products/{id}` | Public | Product details with gallery & vendor info |
| `GET` | `/api/v1/products/{id}/related` | Public | Related products in the same category |
| `GET` | `/api/v1/products/{id}/reviews` | Public | Approved buyer reviews & ratings |
| `POST` | `/api/v1/products/{id}/reviews` | Customer | Submit verified buyer review (1-5 stars) |

### 4. Shopping Cart & Wishlist
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `GET` | `/api/v1/cart` | Customer | View cart totals, discounts, shipping & items |
| `POST` | `/api/v1/cart/items` | Customer | Add item to cart with live stock check |
| `PUT` | `/api/v1/cart/items/{id}` | Customer | Update item quantity |
| `DELETE` | `/api/v1/cart/items/{id}` | Customer | Remove item from cart |
| `DELETE` | `/api/v1/cart/clear` | Customer | Clear all items from cart |
| `POST` | `/api/v1/cart/apply-coupon` | Customer | Apply promo code (`WELCOME10`, `CAMBODIA50`) |
| `DELETE` | `/api/v1/cart/coupon` | Customer | Remove applied coupon from cart |
| `GET` | `/api/v1/wishlist` | Customer | List saved wishlist products |
| `POST` | `/api/v1/wishlist/items` | Customer | Add product to wishlist |
| `DELETE` | `/api/v1/wishlist/items/{id}` | Customer | Remove product from wishlist |
| `DELETE` | `/api/v1/wishlist/clear` | Customer | Clear entire wishlist |

### 5. Customer Profile, Addresses & Orders
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `GET` | `/api/v1/customer/profile` | Customer | View customer account details |
| `PUT` | `/api/v1/customer/profile` | Customer | Update profile name & phone |
| `GET` | `/api/v1/customer/addresses` | Customer | List saved delivery addresses |
| `POST` | `/api/v1/customer/addresses` | Customer | Add new delivery address |
| `PUT` | `/api/v1/customer/addresses/{id}` | Customer | Update existing address |
| `DELETE` | `/api/v1/customer/addresses/{id}` | Customer | Delete saved address |
| `GET` | `/api/v1/customer/orders` | Customer | Order history with item breakdowns |
| `POST` | `/api/v1/customer/orders` | Customer | Checkout, place order, and deduct stock |
| `GET` | `/api/v1/customer/orders/{id}` | Customer | View specific order details |
| `POST` | `/api/v1/customer/orders/{id}/cancel` | Customer | Cancel pending order & restore stock |
| `GET` | `/api/v1/customer/orders/{id}/payment` | Customer | View order transaction status |
| `POST` | `/api/v1/customer/orders/{id}/payment` | Customer | Process demo payment gateway |

### 6. Vendor Management Portal
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `GET` | `/api/v1/vendor/profile` | Vendor | Get vendor store profile |
| `PUT` | `/api/v1/vendor/profile` | Vendor | Update store name, address, phone |
| `GET` | `/api/v1/vendor/products` | Vendor | List products owned by vendor |
| `POST` | `/api/v1/vendor/products` | Vendor | Create new product & log stock |
| `GET` | `/api/v1/vendor/products/{id}` | Vendor | Get vendor product details |
| `PUT` | `/api/v1/vendor/products/{id}` | Vendor | Update product price, discount, stock |
| `DELETE` | `/api/v1/vendor/products/{id}` | Vendor | Delete vendor product |
| `POST` | `/api/v1/vendor/products/{id}/images`| Vendor | Upload product gallery image |
| `GET` | `/api/v1/vendor/orders` | Vendor | Isolated vendor order fulfillment list |
| `PUT` | `/api/v1/vendor/orders/{id}/status` | Vendor | Update status (`processing`, `shipped`, `delivered`) |
| `GET` | `/api/v1/vendor/inventory` | Vendor | Inventory stock monitor & low-stock alerts |
| `GET` | `/api/v1/vendor/inventory/transactions`| Vendor| Warehouse transaction audit trail |

### 7. Super Admin Management
| Method | Endpoint | Access | Description |
|:---:|---|:---:|---|
| `GET` | `/api/v1/admin/dashboard` | Admin | Aggregate metrics, revenue, top products |
| `POST` | `/api/v1/admin/categories` | Admin | Create category |
| `PUT` | `/api/v1/admin/categories/{id}` | Admin | Update category |
| `DELETE` | `/api/v1/admin/categories/{id}` | Admin | Delete category |
| `GET` | `/api/v1/admin/orders` | Admin | Global platform order manager |
| `PUT` | `/api/v1/admin/orders/{id}/status` | Admin | Override any order status |

---

## 🧪 Automated Testing

The project includes an automated **PHPUnit Feature Test Suite** covering all business logic, role-based access control, cart calculations, order stock management, and settings:

```bash
php artisan test
```

**Test Coverage Summary**:
```
Tests:    43 passed (127 assertions)
Duration: 1.12s
Result:   100% Green
```

---

## 📄 License

This open-source project is licensed under the [MIT license](LICENSE).
