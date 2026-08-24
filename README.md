# E-Commerce REST API Demo (Laravel 12)

A production-ready, feature-complete RESTful E-Commerce Demo API built with **Laravel 12**, **Laravel Sanctum**, and **PHP 8.3**.

---

## Features

- **Authentication & RBAC**: Laravel Sanctum token auth with `admin`, `vendor`, and `customer` roles.
- **Product Catalog**: Multi-attribute filtering (category, vendor, price range, search, featured, latest), rating aggregations, multi-image galleries, related products.
- **Shopping Cart**: Real-time totals, stock validation, tax, shipping, and promo coupon calculation.
- **Wishlist**: Save favorite products with duplicate protection.
- **Orders & Inventory**: Multi-item checkout, inventory deduction, order cancellation with stock restoration, order status lifecycles.
- **Payment Gateway Simulation**: Cash on delivery, demo card, and bank transfer support.
- **Verified Buyer Reviews**: Product reviews and average star rating updates.
- **Vendor Dashboard & Stock Tracking**: Vendor product CRUD, inventory transaction logs, and order fulfillment.
- **Admin Dashboard & Analytics**: System overview, revenue metrics, category management, and global order control.
- **Cambodian Demo Dataset**: Real Cambodian store profiles, locations (Phnom Penh, Siem Reap, etc.), products, and realistic sample orders.

---

## Installation & Setup

### 1. Requirements
- PHP 8.2 or higher
- Composer 2.x
- SQLite (default) or MySQL / MariaDB

### 2. Environment Setup
```bash
cp .env.example .env
php artisan key:generate
```

### 3. Database Migration & Realistic Seeding
```bash
php artisan migrate:fresh --seed
```

### 4. Running the Dev Server
```bash
php artisan serve
```
API endpoints will be available at: `http://localhost:8000/api/v1/`

---

## Demo Credentials

All seeded accounts use password: `password`

| Role | Email | Password | Description |
|---|---|---|---|
| **Admin** | `admin@ecommerce.test` | `password` | Super Admin with full platform access |
| **Vendor** | `sokha@phnompenhelectronics.com` | `password` | Phnom Penh Electronics shop owner |
| **Vendor** | `bopha@angkorfashion.com` | `password` | Angkor Fashion Hub shop owner |
| **Customer** | `rithy.sok@example.com` | `password` | Sample customer with saved Cambodian address |
| **Customer** | `kalyan.keo@example.com` | `password` | Sample customer |

---

## Running Tests

Run the full automated Feature Test suite:
```bash
php artisan test
```

---

## API Documentation

For the full endpoint matrix, parameter specifications, and JSON payload examples, see:
[`API_DOCUMENTATION.md`](file:///e:/01-SUBJECT%202026/Mobile%20Programming%20Flutter/ecommerce_api/API_DOCUMENTATION.md)
