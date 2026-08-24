# E-Commerce REST API Documentation (Laravel 12)

Base URL: `http://localhost:8000/api/v1`

---

## Response Envelopes

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 65
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

---

## 1. Authentication Endpoints

| Method | Endpoint | Auth | Role | Parameters / Body | Description | Status |
|---|---|---|---|---|---|---|
| `POST` | `/auth/register` | None | Guest | `name`, `email`, `password`, `password_confirmation`, `phone`, `role` (`vendor`/`customer`), `shop_name` (required if vendor) | Register a new user | `201` |
| `POST` | `/auth/login` | None | Guest | `email`, `password`, `device_name` | Login & receive Bearer Token | `200` |
| `POST` | `/auth/logout` | Sanctum | Any | None | Invalidate current token | `200` |
| `GET` | `/auth/me` | Sanctum | Any | None | Retrieve authenticated user profile | `200` |

#### Example: Register Customer
`POST /api/v1/auth/register`
```json
{
  "name": "Sokha Chan",
  "email": "sokha@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+855 12 345 678",
  "role": "customer"
}
```
**Response (201 Created):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "Sokha Chan",
      "email": "sokha@example.com",
      "phone": "+855 12 345 678",
      "role": "customer",
      "avatar": null,
      "status": "active"
    },
    "access_token": "1|abcdef123456...",
    "token_type": "Bearer"
  }
}
```

---

## 2. Public Catalog Endpoints

| Method | Endpoint | Auth | Role | Query Parameters / Body | Description | Status |
|---|---|---|---|---|---|---|
| `GET` | `/categories` | None | Public | `search`, `status`, `sort_by`, `sort_order`, `per_page` | Paginated category list | `200` |
| `GET` | `/categories/{category}` | None | Public | None | Category details | `200` |
| `GET` | `/categories/{category}/products` | None | Public | `search`, `min_price`, `max_price`, `sort_by`, `per_page` | Products under a category | `200` |
| `GET` | `/products` | None | Public | `category_id`, `vendor_id`, `min_price`, `max_price`, `featured`, `search`, `sort_by`, `per_page` | Filtered & paginated products | `200` |
| `GET` | `/products/search` | None | Public | `q` (keyword) | Search products | `200` |
| `GET` | `/products/{product}` | None | Public | None | Product details with gallery & reviews | `200` |
| `GET` | `/products/{product}/related` | None | Public | None | Related products in same category | `200` |
| `GET` | `/products/{product}/reviews` | None | Public | None | Approved product reviews | `200` |
| `GET` | `/vendors` | None | Public | `search`, `per_page` | Browse active vendors/shops | `200` |
| `GET` | `/vendors/{vendor}` | None | Public | None | Vendor details & featured items | `200` |

---

## 3. Shopping Cart Endpoints

All cart endpoints require `Authorization: Bearer <token>`.

| Method | Endpoint | Auth | Body | Description | Status |
|---|---|---|---|---|---|
| `GET` | `/cart` | Sanctum | None | Get cart with items & auto-calculated totals | `200` |
| `POST` | `/cart/items` | Sanctum | `product_id`, `quantity` | Add item to cart (with stock check) | `200` |
| `PUT` | `/cart/items/{item}` | Sanctum | `quantity` | Update cart item quantity | `200` |
| `DELETE` | `/cart/items/{item}` | Sanctum | None | Remove cart item | `200` |
| `DELETE` | `/cart/clear` | Sanctum | None | Empty entire shopping cart | `200` |
| `POST` | `/cart/apply-coupon` | Sanctum | `code` | Apply promo coupon code | `200` |
| `DELETE` | `/cart/coupon` | Sanctum | None | Remove applied coupon | `200` |

#### Example: Add Item to Cart
`POST /api/v1/cart/items`
```json
{
  "product_id": 1,
  "quantity": 2
}
```
**Response (200 OK):**
```json
{
  "success": true,
  "message": "Item added to cart successfully",
  "data": {
    "id": 1,
    "items": [
      {
        "id": 1,
        "product_id": 1,
        "quantity": 2,
        "unit_price": 1149.00,
        "total_price": 2298.00
      }
    ],
    "calculation": {
      "subtotal": 2298.00,
      "discount": 0.00,
      "tax": 0.00,
      "shipping": 0.00,
      "grand_total": 2298.00,
      "items_count": 2
    }
  }
}
```

---

## 4. Wishlist Endpoints

| Method | Endpoint | Auth | Body | Description | Status |
|---|---|---|---|---|---|
| `GET` | `/wishlist` | Sanctum | None | Get customer wishlist items | `200` |
| `POST` | `/wishlist/items` | Sanctum | `product_id` | Add product to wishlist | `201` |
| `DELETE` | `/wishlist/items/{product}` | Sanctum | None | Remove product from wishlist | `200` |
| `DELETE` | `/wishlist/clear` | Sanctum | None | Clear entire wishlist | `200` |

---

## 5. Customer Profile & Orders

| Method | Endpoint | Auth | Body | Description | Status |
|---|---|---|---|---|---|
| `GET` | `/customer/profile` | Sanctum | None | Get current customer profile | `200` |
| `PUT` | `/customer/profile` | Sanctum | `name`, `phone`, `avatar` | Update customer profile | `200` |
| `GET` | `/customer/addresses` | Sanctum | None | List customer saved addresses | `200` |
| `POST` | `/customer/addresses` | Sanctum | `recipient_name`, `phone`, `address_line_1`, `city`, `province`, `postal_code`, `is_default` | Create new address | `201` |
| `PUT` | `/customer/addresses/{address}` | Sanctum | Address fields | Update address | `200` |
| `DELETE` | `/customer/addresses/{address}` | Sanctum | None | Delete address | `200` |
| `GET` | `/customer/orders` | Sanctum | None | List customer orders | `200` |
| `POST` | `/customer/orders` | Sanctum | `address_id` (or `shipping_address`), `payment_method`, `notes` | Checkout & place order | `201` |
| `GET` | `/customer/orders/{order}` | Sanctum | None | Get order details | `200` |
| `POST` | `/customer/orders/{order}/cancel` | Sanctum | None | Cancel pending order & restore stock | `200` |
| `GET` | `/customer/orders/{order}/payment` | Sanctum | None | Get order payment status | `200` |
| `POST` | `/customer/orders/{order}/payment` | Sanctum | `payment_method`, `card_number` | Process order payment | `200` |
| `POST` | `/products/{product}/reviews` | Sanctum | `rating` (1-5), `comment` | Submit review (verified buyer only) | `201` |
| `PUT` | `/reviews/{review}` | Sanctum | `rating`, `comment` | Update review | `200` |
| `DELETE` | `/reviews/{review}` | Sanctum | None | Delete review | `200` |

---

## 6. Vendor Management Endpoints

Requires `Authorization: Bearer <vendor_token>`.

| Method | Endpoint | Auth | Role | Body | Description | Status |
|---|---|---|---|---|---|---|
| `GET` | `/vendor/profile` | Sanctum | `vendor` | None | Get shop profile | `200` |
| `PUT` | `/vendor/profile` | Sanctum | `vendor` | `shop_name`, `description`, `logo`, `phone`, `email`, `address` | Update shop profile | `200` |
| `GET` | `/vendor/products` | Sanctum | `vendor` | `per_page` | List vendor products | `200` |
| `POST` | `/vendor/products` | Sanctum | `vendor` | `category_id`, `name`, `sku`, `price`, `discount_price`, `stock`, `description` | Create new product | `201` |
| `GET` | `/vendor/products/{product}` | Sanctum | `vendor` | None | Get vendor product | `200` |
| `PUT` | `/vendor/products/{product}` | Sanctum | `vendor` | Product fields | Update vendor product | `200` |
| `DELETE` | `/vendor/products/{product}` | Sanctum | `vendor` | None | Delete vendor product | `200` |
| `POST` | `/vendor/products/{product}/images` | Sanctum | `vendor` | `image_url`, `is_primary` | Add gallery image | `201` |
| `DELETE` | `/vendor/products/{product}/images/{image}` | Sanctum | `vendor` | None | Delete gallery image | `200` |
| `GET` | `/vendor/orders` | Sanctum | `vendor` | None | Orders containing vendor items | `200` |
| `GET` | `/vendor/orders/{order}` | Sanctum | `vendor` | None | Order details with vendor items | `200` |
| `PUT` | `/vendor/orders/{order}/status` | Sanctum | `vendor` | `status` (`pending`, `confirmed`, `processing`, `shipped`, `delivered`, `cancelled`) | Update order status | `200` |
| `GET` | `/vendor/inventory` | Sanctum | `vendor` | `search`, `low_stock` | Stock quantity monitor | `200` |
| `GET` | `/vendor/inventory/transactions` | Sanctum | `vendor` | `type`, `product_id` | Historical stock change logs | `200` |

---

## 7. Admin Management Endpoints

Requires `Authorization: Bearer <admin_token>`.

| Method | Endpoint | Auth | Role | Body | Description | Status |
|---|---|---|---|---|---|---|
| `GET` | `/admin/dashboard` | Sanctum | `admin` | None | Sales, counts, top products/vendors | `200` |
| `POST` | `/admin/categories` | Sanctum | `admin` | `name`, `description`, `image`, `status` | Create category | `201` |
| `PUT` | `/admin/categories/{category}` | Sanctum | `admin` | Category fields | Update category | `200` |
| `DELETE` | `/admin/categories/{category}` | Sanctum | `admin` | None | Delete category | `200` |
| `GET` | `/admin/orders` | Sanctum | `admin` | `status`, `search`, `per_page` | View all platform orders | `200` |
| `GET` | `/admin/orders/{order}` | Sanctum | `admin` | None | Full order details | `200` |
| `PUT` | `/admin/orders/{order}/status` | Sanctum | `admin` | `status` | Update any order status | `200` |

#### Example: Admin Dashboard Response
`GET /api/v1/admin/dashboard`
```json
{
  "success": true,
  "message": "Admin dashboard metrics retrieved successfully",
  "data": {
    "metrics": {
      "total_customers": 20,
      "total_vendors": 5,
      "total_products": 52,
      "total_categories": 10,
      "total_orders": 100,
      "pending_orders": 12,
      "completed_orders": 45,
      "total_sales": 24890.50
    },
    "recent_orders": [],
    "top_products": [],
    "top_vendors": []
  }
}
```
