# Laravel 12 E-Commerce REST API Demo Project

Act as a senior Laravel 12 API architect and backend developer.

Build a complete **RESTful E-Commerce Demo API using Laravel 12**.

## Technology

- Laravel 12
- PHP 8.2+
- Laravel Sanctum
- MySQL or MariaDB
- REST API
- JSON responses
- Eloquent ORM
- Form Request Validation
- API Resources
- Policies / Authorization
- API pagination
- Database Seeders
- Factories
- Migrations
- Feature Tests

Do NOT build the frontend. Focus only on the Laravel REST API backend.

---

## 1. Authentication

Implement authentication using Laravel Sanctum.

Create:

- Register
- Login
- Logout
- Current authenticated user

Endpoints:

POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/logout
GET /api/v1/auth/me

Support these roles:

- admin
- vendor
- customer

Implement proper role-based authorization.

---

## 2. Categories

Create Category model, migration, factory, seeder, controller, API Resource and validation.

Fields:

- id
- name
- slug
- description
- image
- status
- created_at
- updated_at

Endpoints:

GET    /api/v1/categories
GET    /api/v1/categories/{category}
POST   /api/v1/admin/categories
PUT    /api/v1/admin/categories/{category}
DELETE /api/v1/admin/categories/{category}

Also provide:

GET /api/v1/categories/{category}/products

Support:

- pagination
- search
- status filtering
- sorting

---

## 3. Products

Create Product model and complete CRUD functionality.

Fields:

- id
- vendor_id
- category_id
- name
- slug
- sku
- description
- price
- discount_price
- stock
- image
- status
- created_at
- updated_at

Endpoints:

GET    /api/v1/products
GET    /api/v1/products/{product}
POST   /api/v1/vendor/products
PUT    /api/v1/vendor/products/{product}
DELETE /api/v1/vendor/products/{product}

Product listing must support:

- category filter
- vendor filter
- price range
- search
- sorting
- pagination
- featured products
- latest products

Add:

GET /api/v1/products/search
GET /api/v1/products/{product}/related

---

## 4. Vendors

Create Vendor functionality.

Fields:

- id
- user_id
- shop_name
- slug
- description
- logo
- phone
- email
- address
- status

Endpoints:

GET    /api/v1/vendors
GET    /api/v1/vendors/{vendor}
GET    /api/v1/vendor/profile
PUT    /api/v1/vendor/profile

A vendor can manage only their own products and orders.

---

## 5. Customers

Create customer profile functionality.

Endpoints:

GET /api/v1/customer/profile
PUT /api/v1/customer/profile

Create address management:

GET    /api/v1/customer/addresses
POST   /api/v1/customer/addresses
GET    /api/v1/customer/addresses/{address}
PUT    /api/v1/customer/addresses/{address}
DELETE /api/v1/customer/addresses/{address}

A customer can only access their own profile and addresses.

---

## 6. Shopping Cart

Create:

- carts
- cart_items

Endpoints:

GET    /api/v1/cart
POST   /api/v1/cart/items
PUT    /api/v1/cart/items/{item}
DELETE /api/v1/cart/items/{item}
DELETE /api/v1/cart/clear

Add item request:

{
    "product_id": 1,
    "quantity": 2
}

Automatically calculate:

- subtotal
- discount
- tax
- shipping
- grand_total

Validate product stock before adding or updating cart items.

---

## 7. Wishlist

Create wishlist functionality.

Endpoints:

GET    /api/v1/wishlist
POST   /api/v1/wishlist/items
DELETE /api/v1/wishlist/items/{product}
DELETE /api/v1/wishlist/clear

Prevent duplicate wishlist items.

---

## 8. Orders

Create:

- orders
- order_items

Customer endpoints:

GET    /api/v1/customer/orders
POST   /api/v1/customer/orders
GET    /api/v1/customer/orders/{order}
POST   /api/v1/customer/orders/{order}/cancel

Admin endpoints:

GET    /api/v1/admin/orders
GET    /api/v1/admin/orders/{order}
PUT    /api/v1/admin/orders/{order}/status

Vendor endpoints:

GET    /api/v1/vendor/orders
GET    /api/v1/vendor/orders/{order}
PUT    /api/v1/vendor/orders/{order}/status

Order status:

- pending
- confirmed
- processing
- shipped
- delivered
- cancelled
- refunded

Customers must only see and manage their own orders.

Vendors must only see orders containing their products.

Admins can manage all orders.

---

## 9. Payments

Create a demo payment module.

Do not integrate a real payment gateway.

Support:

- cash_on_delivery
- demo_card
- bank_transfer

Create payment status:

- pending
- paid
- failed
- refunded

Endpoints:

GET /api/v1/customer/orders/{order}/payment
POST /api/v1/customer/orders/{order}/payment

---

## 10. Reviews and Ratings

Create product reviews.

Fields:

- customer_id
- product_id
- order_id
- rating
- comment
- status

Endpoints:

GET    /api/v1/products/{product}/reviews
POST   /api/v1/products/{product}/reviews
PUT    /api/v1/reviews/{review}
DELETE /api/v1/reviews/{review}

Only customers who purchased the product can submit a review.

Calculate product average rating.

---

## 11. Coupons

Create coupon functionality.

Fields:

- code
- type
- value
- minimum_order_amount
- maximum_discount
- start_date
- end_date
- usage_limit
- status

Endpoints:

POST /api/v1/cart/apply-coupon
DELETE /api/v1/cart/coupon

Validate coupon expiration, usage limit and minimum order amount.

---

## 12. Product Images

Create product_images table.

Allow vendors to manage multiple product images.

Endpoints:

POST   /api/v1/vendor/products/{product}/images
DELETE /api/v1/vendor/products/{product}/images/{image}

---

## 13. Inventory

Create inventory management.

Track:

- stock quantity
- stock increases
- stock decreases
- order deductions
- cancelled order restoration

Create inventory transaction history.

Endpoints:

GET /api/v1/vendor/inventory
GET /api/v1/vendor/inventory/transactions

---

## 14. Admin Dashboard

Create:

GET /api/v1/admin/dashboard

Return:

- total customers
- total vendors
- total products
- total categories
- total orders
- pending orders
- completed orders
- total sales
- recent orders
- top products
- top vendors

---

## 15. Demo Data

Create factories and seeders.

Generate at least:

- 1 admin
- 5 vendors
- 20 customers
- 10 categories
- 50 products
- 20 addresses
- 30 wishlist items
- 50 cart items
- 100 orders
- order items
- reviews
- coupons
- payments

Use realistic Cambodian e-commerce demo data where appropriate.

Examples:

Categories:

- Electronics
- Mobile Phones
- Laptops
- Fashion
- Shoes
- Beauty
- Home & Kitchen
- Sports
- Books
- Accessories

---

## 16. API Response Standard

Use a consistent JSON response.

Success:

{
    "success": true,
    "message": "Products retrieved successfully",
    "data": [],
    "meta": {}
}

Error:

{
    "success": false,
    "message": "Validation failed",
    "errors": {}
}

Use HTTP status codes correctly:

200
201
204
400
401
403
404
422
500

---

## 17. API Resources

Use Laravel API Resources for:

- UserResource
- CategoryResource
- ProductResource
- VendorResource
- CartResource
- CartItemResource
- WishlistResource
- OrderResource
- OrderItemResource
- PaymentResource
- ReviewResource

Avoid returning raw Eloquent models directly from controllers.

---

## 18. Validation

Use Form Request classes.

Examples:

StoreProductRequest
UpdateProductRequest
AddCartItemRequest
UpdateCartItemRequest
CreateOrderRequest
UpdateOrderStatusRequest
StoreCategoryRequest
StoreReviewRequest
StoreCouponRequest

Provide clear validation messages.

---

## 19. Authorization

Implement Policies or Gates.

Rules:

- Customer can manage only their own cart.
- Customer can manage only their own wishlist.
- Customer can view only their own orders.
- Customer can cancel only eligible orders.
- Vendor can manage only their own products.
- Vendor can view only relevant orders.
- Admin can manage everything.

Prevent IDOR/security vulnerabilities.

---

## 20. Database Relationships

Implement proper Eloquent relationships.

Examples:

User:

hasOne Vendor
hasMany Orders
hasOne Cart
hasOne Wishlist
hasMany Addresses
hasMany Reviews

Category:

hasMany Products

Vendor:

belongsTo User
hasMany Products

Product:

belongsTo Category
belongsTo Vendor
hasMany ProductImages
hasMany CartItems
hasMany OrderItems
hasMany Reviews

Order:

belongsTo Customer/User
hasMany OrderItems
hasOne Payment

Cart:

belongsTo Customer/User
hasMany CartItems

---

## 21. API Routes

Organize routes into:

routes/api.php

Use route groups:

/api/v1/auth
/api/v1/products
/api/v1/categories
/api/v1/cart
/api/v1/wishlist
/api/v1/customer
/api/v1/vendor
/api/v1/admin

Use middleware appropriately.

---

## 22. Testing

Create Laravel Feature Tests for:

- authentication
- category listing
- product listing
- product filtering
- add to cart
- update cart
- wishlist
- customer orders
- vendor orders
- admin orders
- authorization
- reviews
- coupon validation

Test both successful and failed requests.

---

## 23. API Documentation

Generate a complete API documentation table containing:

- HTTP Method
- Endpoint
- Authentication
- Role
- Request Parameters
- Request Body
- Response
- HTTP Status

Also provide example JSON requests and responses.

---

## 24. Development Order

Implement the project in this order:

1. Laravel project setup
2. Database migrations
3. Models and relationships
4. Factories
5. Seeders
6. Authentication
7. Categories
8. Products
9. Vendors
10. Customers
11. Cart
12. Wishlist
13. Orders
14. Payments
15. Reviews
16. Coupons
17. Inventory
18. Admin dashboard
19. API Resources
20. Form Requests
21. Policies
22. Feature Tests
23. API documentation

For every step, provide:

- file path
- complete code
- Artisan command
- explanation
- API endpoint
- example request
- example response
- testing instructions

Ensure all code is compatible with **Laravel 12** and follows clean REST API architecture.