<?php

namespace Database\Seeders;

use App\Models\Address;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Category;
use App\Models\Coupon;
use App\Models\InventoryTransaction;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\Review;
use App\Models\User;
use App\Models\Vendor;
use App\Models\Wishlist;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Create Admin User
        $admin = User::create([
            'name' => 'System Administrator',
            'email' => 'admin@ecommerce.test',
            'password' => Hash::make('password'),
            'phone' => '+855 12 345 678',
            'role' => 'admin',
            'avatar' => 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);

        // 2. Create 5 Vendors with realistic Cambodian stores
        $vendorProfiles = [
            [
                'name' => 'Sokha Chan',
                'email' => 'sokha@phnompenhelectronics.com',
                'shop_name' => 'Phnom Penh Electronics',
                'description' => 'Top premium smartphones, gadgets, and consumer electronics in Cambodia.',
                'address' => '#45 Preah Norodom Blvd, Khan Daun Penh, Phnom Penh',
                'phone' => '+855 12 888 999',
            ],
            [
                'name' => 'Bopha Vong',
                'email' => 'bopha@angkorfashion.com',
                'shop_name' => 'Angkor Fashion Hub',
                'description' => 'Modern lifestyle apparel, traditional silk adaptations, and trendy streetwear.',
                'address' => '#122 St. 63 (Pasteur), Khan Chamkarmon, Phnom Penh',
                'phone' => '+855 77 555 444',
            ],
            [
                'name' => 'Dara Sam',
                'email' => 'dara@sovannaphumgadgets.com',
                'shop_name' => 'Sovannaphum Gadgets',
                'description' => 'High performance computer parts, laptops, gaming accessories and repairs.',
                'address' => '#210 Kampuchea Krom Blvd, Khan 7 Makara, Phnom Penh',
                'phone' => '+855 88 222 333',
            ],
            [
                'name' => 'Chanthou Meas',
                'email' => 'chanthou@mekonghome.com',
                'shop_name' => 'Mekong Home Style',
                'description' => 'Contemporary furniture, kitchen appliances, and cozy home decor collections.',
                'address' => '#78 Russian Federation Blvd, Khan Toul Kork, Phnom Penh',
                'phone' => '+855 93 111 222',
            ],
            [
                'name' => 'Vannak Heng',
                'email' => 'vannak@khmersportswear.com',
                'shop_name' => 'Khmer Sportswear & Gear',
                'description' => 'Professional running shoes, gym attire, bicycles, and outdoor adventure gear.',
                'address' => '#15 Sivutha Blvd, Svay Dangkum, Siem Reap',
                'phone' => '+855 15 777 888',
            ],
        ];

        $vendors = [];
        foreach ($vendorProfiles as $vp) {
            $vendorUser = User::create([
                'name' => $vp['name'],
                'email' => $vp['email'],
                'password' => Hash::make('password'),
                'phone' => $vp['phone'],
                'role' => 'vendor',
                'avatar' => 'https://api.dicebear.com/7.x/avataaars/svg?seed=' . urlencode($vp['name']),
                'status' => 'active',
                'email_verified_at' => now(),
            ]);

            $vendor = Vendor::create([
                'user_id' => $vendorUser->id,
                'shop_name' => $vp['shop_name'],
                'slug' => Str::slug($vp['shop_name']),
                'description' => $vp['description'],
                'logo' => 'https://picsum.photos/seed/' . Str::slug($vp['shop_name']) . '/200/200',
                'phone' => $vp['phone'],
                'email' => $vp['email'],
                'address' => $vp['address'],
                'status' => 'active',
            ]);

            $vendors[] = $vendor;
        }

        // 3. Create 20 Customer Users with realistic Cambodian names and addresses
        $customerNames = [
            'Rithy Sok', 'Kalyan Keo', 'Sreynich Pich', 'Visal Chet', 'Pisey Seng',
            'Chenda Men', 'Sopheap Lim', 'Vicheka Touch', 'Rathana Mao', 'Theara Choun',
            'Sophal Prak', 'Channary Ros', 'Makara Ouk', 'Bunly Som', 'Kunthea Ngeth',
            'Sokhom Im', 'Thida Ly', 'Mony Long', 'Vireak Sin', 'Panha Tep'
        ];

        $customers = [];
        $khmerDistricts = [
            ['Khan Daun Penh', 'Phnom Penh'],
            ['Khan Chamkarmon', 'Phnom Penh'],
            ['Khan Toul Kork', 'Phnom Penh'],
            ['Khan Sen Sok', 'Phnom Penh'],
            ['Khan Chroy Changvar', 'Phnom Penh'],
            ['Krong Siem Reap', 'Siem Reap'],
            ['Krong Battambang', 'Battambang'],
            ['Krong Kampot', 'Kampot'],
            ['Khan Boeung Keng Kang', 'Phnom Penh'],
            ['Khan Prampir Makara', 'Phnom Penh'],
        ];

        foreach ($customerNames as $idx => $name) {
            $email = Str::slug($name, '.') . '@example.com';
            $customer = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make('password'),
                'phone' => '+855 ' . fake()->numerify('## ### ###'),
                'role' => 'customer',
                'avatar' => 'https://api.dicebear.com/7.x/avataaars/svg?seed=' . urlencode($name),
                'status' => 'active',
                'email_verified_at' => now(),
            ]);

            $loc = $khmerDistricts[$idx % count($khmerDistricts)];
            Address::create([
                'user_id' => $customer->id,
                'recipient_name' => $name,
                'phone' => $customer->phone,
                'address_line_1' => '#' . rand(1, 199) . ', St. ' . rand(100, 599) . ', ' . $loc[0],
                'city' => $loc[1],
                'province' => $loc[1],
                'postal_code' => '12' . rand(100, 999),
                'is_default' => true,
            ]);

            $customers[] = $customer;
        }

        // 4. Create 10 Categories
        $categoryData = [
            ['name' => 'Electronics', 'slug' => 'electronics', 'description' => 'Gadgets, smart home devices, and audio equipment'],
            ['name' => 'Mobile Phones', 'slug' => 'mobile-phones', 'description' => 'Flagship and budget smartphones with 5G connectivity'],
            ['name' => 'Laptops', 'slug' => 'laptops', 'description' => 'Ultrabooks, gaming rigs, and workstation computers'],
            ['name' => 'Fashion', 'slug' => 'fashion', 'description' => 'Contemporary apparel, shirts, dresses, and trousers'],
            ['name' => 'Shoes', 'slug' => 'shoes', 'description' => 'Sneakers, sports footwear, and formal shoes'],
            ['name' => 'Beauty', 'slug' => 'beauty', 'description' => 'Skincare, makeup essentials, and personal wellness'],
            ['name' => 'Home & Kitchen', 'slug' => 'home-kitchen', 'description' => 'Cookware, modern blenders, and interior home appliances'],
            ['name' => 'Sports', 'slug' => 'sports', 'description' => 'Gym equipment, sports jerseys, and outdoor outdoor gear'],
            ['name' => 'Books', 'slug' => 'books', 'description' => 'Bestsellers, educational guides, and literature in Khmer & English'],
            ['name' => 'Accessories', 'slug' => 'accessories', 'description' => 'Smart watches, backpacks, wallets, and phone cases'],
        ];

        $categories = [];
        foreach ($categoryData as $cd) {
            $categories[] = Category::create([
                'name' => $cd['name'],
                'slug' => $cd['slug'],
                'description' => $cd['description'],
                'image' => 'https://picsum.photos/seed/' . $cd['slug'] . '/400/400',
                'status' => 'active',
            ]);
        }

        // 5. Create Coupons
        $coupons = [
            Coupon::create([
                'code' => 'WELCOME10',
                'type' => 'percentage',
                'value' => 10.00,
                'minimum_order_amount' => 20.00,
                'maximum_discount' => 30.00,
                'start_date' => now()->subDays(10),
                'end_date' => now()->addDays(60),
                'usage_limit' => 500,
                'times_used' => 24,
                'status' => 'active',
            ]),
            Coupon::create([
                'code' => 'CAMBODIA50',
                'type' => 'fixed',
                'value' => 15.00,
                'minimum_order_amount' => 100.00,
                'maximum_discount' => null,
                'start_date' => now()->subDays(5),
                'end_date' => now()->addDays(30),
                'usage_limit' => 200,
                'times_used' => 12,
                'status' => 'active',
            ]),
            Coupon::create([
                'code' => 'TECHDISCOUNT',
                'type' => 'percentage',
                'value' => 15.00,
                'minimum_order_amount' => 50.00,
                'maximum_discount' => 50.00,
                'start_date' => now()->subDays(2),
                'end_date' => now()->addDays(45),
                'usage_limit' => 100,
                'times_used' => 8,
                'status' => 'active',
            ]),
            Coupon::create([
                'code' => 'EXPIRED20',
                'type' => 'percentage',
                'value' => 20.00,
                'minimum_order_amount' => 30.00,
                'start_date' => now()->subDays(30),
                'end_date' => now()->subDays(2),
                'usage_limit' => 50,
                'times_used' => 50,
                'status' => 'inactive',
            ]),
        ];

        // 6. Create 50+ Realistic Products (distributed among 5 vendors and 10 categories)
        $sampleCatalog = [
            // Mobile Phones (Category 1)
            ['name' => 'iPhone 15 Pro Max 256GB Titanium', 'category' => 1, 'vendor' => 0, 'price' => 1199.00, 'discount_price' => 1149.00, 'stock' => 25, 'featured' => true],
            ['name' => 'Samsung Galaxy S24 Ultra 512GB', 'category' => 1, 'vendor' => 0, 'price' => 1299.00, 'discount_price' => 1219.00, 'stock' => 20, 'featured' => true],
            ['name' => 'Xiaomi 14 Pro Leica Camera 256GB', 'category' => 1, 'vendor' => 2, 'price' => 799.00, 'discount_price' => 749.00, 'stock' => 30, 'featured' => false],
            ['name' => 'Google Pixel 8 Pro 128GB Obsidian', 'category' => 1, 'vendor' => 2, 'price' => 899.00, 'discount_price' => null, 'stock' => 18, 'featured' => false],
            ['name' => 'OnePlus 12 5G Emerald Green', 'category' => 1, 'vendor' => 0, 'price' => 699.00, 'discount_price' => 649.00, 'stock' => 15, 'featured' => false],

            // Laptops (Category 2)
            ['name' => 'MacBook Pro 14" M3 Pro 18GB/512GB', 'category' => 2, 'vendor' => 0, 'price' => 1999.00, 'discount_price' => 1899.00, 'stock' => 12, 'featured' => true],
            ['name' => 'Dell XPS 15 OLED Touch 32GB RAM', 'category' => 2, 'vendor' => 2, 'price' => 1749.00, 'discount_price' => 1650.00, 'stock' => 10, 'featured' => false],
            ['name' => 'ASUS ROG Zephyrus G16 RTX 4070', 'category' => 2, 'vendor' => 2, 'price' => 1899.00, 'discount_price' => null, 'stock' => 8, 'featured' => true],
            ['name' => 'Lenovo ThinkPad X1 Carbon Gen 11', 'category' => 2, 'vendor' => 0, 'price' => 1450.00, 'discount_price' => 1380.00, 'stock' => 14, 'featured' => false],
            ['name' => 'Acer Swift Go 14 AI OLED Intel Ultra 7', 'category' => 2, 'vendor' => 2, 'price' => 899.00, 'discount_price' => 829.00, 'stock' => 22, 'featured' => false],

            // Electronics & Audio (Category 0)
            ['name' => 'Sony WH-1000XM5 Noise Canceling Headphones', 'category' => 0, 'vendor' => 0, 'price' => 349.00, 'discount_price' => 299.00, 'stock' => 40, 'featured' => true],
            ['name' => 'AirPods Pro 2nd Gen USB-C', 'category' => 0, 'vendor' => 0, 'price' => 249.00, 'discount_price' => 219.00, 'stock' => 50, 'featured' => true],
            ['name' => 'Bose SoundLink Revolve+ II Bluetooth Speaker', 'category' => 0, 'vendor' => 2, 'price' => 299.00, 'discount_price' => null, 'stock' => 25, 'featured' => false],
            ['name' => 'Anker 737 Power Bank 24,000mAh 140W', 'category' => 0, 'vendor' => 2, 'price' => 129.00, 'discount_price' => 99.00, 'stock' => 60, 'featured' => false],
            ['name' => 'DJI Mini 4 Pro Drone Fly More Combo', 'category' => 0, 'vendor' => 0, 'price' => 959.00, 'discount_price' => 919.00, 'stock' => 10, 'featured' => true],

            // Fashion (Category 3)
            ['name' => 'Khmer Silk Pattern Linen Casual Shirt', 'category' => 3, 'vendor' => 1, 'price' => 35.00, 'discount_price' => 28.00, 'stock' => 80, 'featured' => true],
            ['name' => 'Urban Streetwear Heavyweight Oversized Hoodie', 'category' => 3, 'vendor' => 1, 'price' => 45.00, 'discount_price' => 39.00, 'stock' => 70, 'featured' => false],
            ['name' => 'Classic Slim Fit Chino Trousers Navy', 'category' => 3, 'vendor' => 1, 'price' => 38.00, 'discount_price' => null, 'stock' => 55, 'featured' => false],
            ['name' => 'Breathable Bamboo Fiber Polo Shirt', 'category' => 3, 'vendor' => 1, 'price' => 29.00, 'discount_price' => 24.00, 'stock' => 90, 'featured' => false],
            ['name' => 'Vintage Denim Jacket Washed Blue', 'category' => 3, 'vendor' => 1, 'price' => 59.00, 'discount_price' => 49.00, 'stock' => 40, 'featured' => true],

            // Shoes (Category 4)
            ['name' => 'Nike Air Jordan 1 Retro High OG Chicago', 'category' => 4, 'vendor' => 4, 'price' => 180.00, 'discount_price' => 165.00, 'stock' => 30, 'featured' => true],
            ['name' => 'Adidas Ultraboost Light Running Shoes', 'category' => 4, 'vendor' => 4, 'price' => 190.00, 'discount_price' => 159.00, 'stock' => 35, 'featured' => true],
            ['name' => 'New Balance 990v6 Made in USA Grey', 'category' => 4, 'vendor' => 4, 'price' => 210.00, 'discount_price' => null, 'stock' => 20, 'featured' => false],
            ['name' => 'Classic Handcrafted Leather Oxford Shoes', 'category' => 4, 'vendor' => 1, 'price' => 85.00, 'discount_price' => 75.00, 'stock' => 25, 'featured' => false],
            ['name' => 'Vans Old Skool Classic Skate Shoes', 'category' => 4, 'vendor' => 4, 'price' => 65.00, 'discount_price' => null, 'stock' => 45, 'featured' => false],

            // Beauty & Skincare (Category 5)
            ['name' => 'COSRX Snail Mucin 96% Essence Serum', 'category' => 5, 'vendor' => 1, 'price' => 22.00, 'discount_price' => 18.00, 'stock' => 120, 'featured' => true],
            ['name' => 'La Roche-Posay Anthelios SPF 50+ Sunscreen', 'category' => 5, 'vendor' => 1, 'price' => 28.00, 'discount_price' => null, 'stock' => 80, 'featured' => false],
            ['name' => 'CeraVe Hydrating Facial Cleanser 473ml', 'category' => 5, 'vendor' => 1, 'price' => 19.00, 'discount_price' => 16.50, 'stock' => 100, 'featured' => false],
            ['name' => 'Laneige Lip Sleeping Mask Berry 20g', 'category' => 5, 'vendor' => 1, 'price' => 20.00, 'discount_price' => 17.00, 'stock' => 90, 'featured' => false],
            ['name' => 'Estee Lauder Advanced Night Repair Serum', 'category' => 5, 'vendor' => 1, 'price' => 105.00, 'discount_price' => 95.00, 'stock' => 25, 'featured' => true],

            // Home & Kitchen (Category 6)
            ['name' => 'Philips Airfryer XXL Smart Sensing 7.2L', 'category' => 6, 'vendor' => 3, 'price' => 289.00, 'discount_price' => 249.00, 'stock' => 18, 'featured' => true],
            ['name' => 'Nespresso Vertuo Pop Coffee Machine', 'category' => 6, 'vendor' => 3, 'price' => 149.00, 'discount_price' => 129.00, 'stock' => 30, 'featured' => false],
            ['name' => 'Dyson V12 Detect Slim Cordless Vacuum', 'category' => 6, 'vendor' => 3, 'price' => 649.00, 'discount_price' => 599.00, 'stock' => 10, 'featured' => true],
            ['name' => 'Zwilling J.A. Henckels 7-Piece Knife Block Set', 'category' => 6, 'vendor' => 3, 'price' => 199.00, 'discount_price' => null, 'stock' => 15, 'featured' => false],
            ['name' => 'T-Fal Stainless Steel Nonstick Cookware Set 10pc', 'category' => 6, 'vendor' => 3, 'price' => 119.00, 'discount_price' => 99.00, 'stock' => 20, 'featured' => false],

            // Sports & Outdoor (Category 7)
            ['name' => 'Garmin Forerunner 265 GPS Running Smartwatch', 'category' => 7, 'vendor' => 4, 'price' => 449.00, 'discount_price' => 419.00, 'stock' => 16, 'featured' => true],
            ['name' => 'YETI Rambler 36 oz Vacuum Insulated Bottle', 'category' => 7, 'vendor' => 4, 'price' => 50.00, 'discount_price' => null, 'stock' => 60, 'featured' => false],
            ['name' => 'Spalding NBA Official Indoor/Outdoor Basketball', 'category' => 7, 'vendor' => 4, 'price' => 38.00, 'discount_price' => 32.00, 'stock' => 50, 'featured' => false],
            ['name' => 'Yonex Astrox 88D Pro Badminton Racket 4U', 'category' => 7, 'vendor' => 4, 'price' => 220.00, 'discount_price' => 199.00, 'stock' => 14, 'featured' => true],
            ['name' => 'Adjustable Dumbbell Set 24kg Pair', 'category' => 7, 'vendor' => 4, 'price' => 179.00, 'discount_price' => 149.00, 'stock' => 20, 'featured' => false],

            // Books (Category 8)
            ['name' => 'Atomic Habits by James Clear (Hardcover)', 'category' => 8, 'vendor' => 3, 'price' => 18.00, 'discount_price' => 15.00, 'stock' => 75, 'featured' => true],
            ['name' => 'First They Killed My Father by Loung Ung', 'category' => 8, 'vendor' => 3, 'price' => 16.00, 'discount_price' => null, 'stock' => 50, 'featured' => true],
            ['name' => 'Clean Code by Robert C. Martin (Developer Edition)', 'category' => 8, 'vendor' => 2, 'price' => 42.00, 'discount_price' => 36.00, 'stock' => 40, 'featured' => false],
            ['name' => 'The Psychology of Money by Morgan Housel', 'category' => 8, 'vendor' => 3, 'price' => 17.00, 'discount_price' => 14.50, 'stock' => 65, 'featured' => false],
            ['name' => 'Sapiens: A Brief History of Humankind', 'category' => 8, 'vendor' => 3, 'price' => 22.00, 'discount_price' => null, 'stock' => 45, 'featured' => false],

            // Accessories (Category 9)
            ['name' => 'Apple Watch Series 9 GPS 45mm Midnight', 'category' => 9, 'vendor' => 0, 'price' => 429.00, 'discount_price' => 399.00, 'stock' => 25, 'featured' => true],
            ['name' => 'Peak Design Everyday Backpack 20L Charcoal', 'category' => 9, 'vendor' => 0, 'price' => 259.00, 'discount_price' => null, 'stock' => 15, 'featured' => true],
            ['name' => 'Bellroy Hide & Seek Premium Leather Wallet', 'category' => 9, 'vendor' => 1, 'price' => 89.00, 'discount_price' => 79.00, 'stock' => 35, 'featured' => false],
            ['name' => 'Keychron K2 Pro Wireless Mechanical Keyboard', 'category' => 9, 'vendor' => 2, 'price' => 110.00, 'discount_price' => 98.00, 'stock' => 40, 'featured' => false],
            ['name' => 'Logitech MX Master 3S Wireless Mouse', 'category' => 9, 'vendor' => 2, 'price' => 99.00, 'discount_price' => 89.00, 'stock' => 50, 'featured' => true],
            ['name' => 'UGREEN 100W GaN Fast Charger 4 Ports', 'category' => 9, 'vendor' => 2, 'price' => 55.00, 'discount_price' => 45.00, 'stock' => 80, 'featured' => false],
            ['name' => 'Kindle Paperwhite 16GB 6.8" Warm Light', 'category' => 9, 'vendor' => 0, 'price' => 149.00, 'discount_price' => 135.00, 'stock' => 30, 'featured' => false],
        ];

        $products = [];
        foreach ($sampleCatalog as $idx => $p) {
            $catId = $categories[$p['category']]->id;
            $vendorId = $vendors[$p['vendor']]->id;
            $slug = Str::slug($p['name']) . '-' . Str::random(5);
            $sku = 'CAM-' . strtoupper(Str::random(3)) . '-' . (1000 + $idx);

            $product = Product::create([
                'vendor_id' => $vendorId,
                'category_id' => $catId,
                'name' => $p['name'],
                'slug' => $slug,
                'sku' => $sku,
                'description' => "Genuine {$p['name']} with 1-year warranty and fast delivery across Cambodia.",
                'price' => $p['price'],
                'discount_price' => $p['discount_price'],
                'stock' => $p['stock'],
                'image' => 'https://picsum.photos/seed/' . Str::slug($p['name']) . '/600/600',
                'is_featured' => $p['featured'],
                'average_rating' => 0.00,
                'reviews_count' => 0,
                'status' => 'active',
            ]);

            // Create product gallery images
            ProductImage::create([
                'product_id' => $product->id,
                'image_url' => 'https://picsum.photos/seed/' . Str::slug($p['name']) . '-primary/600/600',
                'is_primary' => true,
            ]);
            ProductImage::create([
                'product_id' => $product->id,
                'image_url' => 'https://picsum.photos/seed/' . Str::slug($p['name']) . '-angle1/600/600',
                'is_primary' => false,
            ]);
            ProductImage::create([
                'product_id' => $product->id,
                'image_url' => 'https://picsum.photos/seed/' . Str::slug($p['name']) . '-angle2/600/600',
                'is_primary' => false,
            ]);

            // Initial stock inventory log
            InventoryTransaction::create([
                'product_id' => $product->id,
                'vendor_id' => $vendorId,
                'type' => 'restock',
                'quantity_change' => $p['stock'],
                'previous_stock' => 0,
                'current_stock' => $p['stock'],
                'notes' => 'Initial seeded warehouse restock',
            ]);

            $products[] = $product;
        }

        // 7. Seed Wishlist items (30 items)
        for ($i = 0; $i < 30; $i++) {
            $customer = $customers[$i % count($customers)];
            $product = $products[$i % count($products)];

            Wishlist::firstOrCreate([
                'user_id' => $customer->id,
                'product_id' => $product->id,
            ]);
        }

        // 8. Seed Carts and Cart items (50 items across customers)
        foreach ($customers as $idx => $customer) {
            $cart = Cart::firstOrCreate(['user_id' => $customer->id]);

            if ($idx < 15) {
                // Add 2-4 items to cart
                $selectedProds = array_slice($products, ($idx * 3) % count($products), 3);
                foreach ($selectedProds as $prod) {
                    CartItem::firstOrCreate(
                        ['cart_id' => $cart->id, 'product_id' => $prod->id],
                        ['quantity' => rand(1, 2), 'unit_price' => $prod->effective_price]
                    );
                }
            }
        }

        // 9. Create 100 Orders with order items, payments, and reviews
        $statuses = ['delivered', 'delivered', 'delivered', 'shipped', 'processing', 'confirmed', 'pending', 'cancelled'];
        $paymentMethods = ['demo_card', 'bank_transfer', 'cash_on_delivery'];

        for ($i = 1; $i <= 100; $i++) {
            $customer = $customers[array_rand($customers)];
            $orderStatus = $statuses[$i % count($statuses)];
            $payMethod = $paymentMethods[$i % count($paymentMethods)];

            // Pick 1 to 3 products
            $orderProducts = [
                $products[($i * 2) % count($products)],
                $products[($i * 2 + 1) % count($products)],
            ];

            $subtotal = 0;
            $itemsData = [];
            foreach ($orderProducts as $p) {
                $qty = rand(1, 2);
                $unitPrice = $p->effective_price;
                $tot = $unitPrice * $qty;
                $subtotal += $tot;

                $itemsData[] = [
                    'product_id' => $p->id,
                    'vendor_id' => $p->vendor_id,
                    'product_name' => $p->name,
                    'unit_price' => $unitPrice,
                    'quantity' => $qty,
                    'total_price' => $tot,
                ];
            }

            $discount = ($i % 5 === 0) ? round($subtotal * 0.10, 2) : 0.00;
            $shipping = $subtotal < 50 ? 2.00 : 0.00;
            $grandTotal = max(0, $subtotal - $discount + $shipping);

            $order = Order::create([
                'order_number' => 'ORD-' . strtoupper(Str::random(10)),
                'user_id' => $customer->id,
                'coupon_id' => ($discount > 0) ? $coupons[0]->id : null,
                'status' => $orderStatus,
                'subtotal' => $subtotal,
                'discount_amount' => $discount,
                'tax_amount' => 0.00,
                'shipping_amount' => $shipping,
                'grand_total' => $grandTotal,
                'shipping_address' => [
                    'recipient_name' => $customer->name,
                    'phone' => $customer->phone,
                    'address_line_1' => '#' . rand(1, 200) . ', St. ' . rand(100, 500) . ', Khan Toul Kork',
                    'city' => 'Phnom Penh',
                    'province' => 'Phnom Penh',
                ],
                'notes' => ($i % 3 === 0) ? 'Please call before delivery.' : null,
                'created_at' => now()->subDays(rand(1, 45)),
            ]);

            foreach ($itemsData as $itemData) {
                $order->items()->create($itemData);
            }

            // Payment record
            $payStatus = in_array($orderStatus, ['confirmed', 'processing', 'shipped', 'delivered']) ? 'paid' : ($orderStatus === 'cancelled' ? 'refunded' : 'pending');
            Payment::create([
                'order_id' => $order->id,
                'payment_method' => $payMethod,
                'transaction_reference' => 'PAY-' . strtoupper(Str::random(12)),
                'amount' => $grandTotal,
                'status' => $payStatus,
                'payment_details' => [
                    'method' => $payMethod,
                    'gateway' => 'demo_gateway',
                    'card_last4' => $payMethod === 'demo_card' ? '4242' : null,
                ],
                'paid_at' => $payStatus === 'paid' ? $order->created_at : null,
                'created_at' => $order->created_at,
            ]);

            // For delivered orders, create reviews on purchased products
            if ($orderStatus === 'delivered' && $i <= 40) {
                foreach ($orderProducts as $p) {
                    Review::firstOrCreate(
                        ['user_id' => $customer->id, 'product_id' => $p->id],
                        [
                            'order_id' => $order->id,
                            'rating' => rand(4, 5),
                            'comment' => fake()->randomElement([
                                'Excellent quality! Fast delivery in Phnom Penh.',
                                'Exactly as described. Very happy with my purchase.',
                                'Super high quality and well packaged. Recommended vendor!',
                                'Great value for money. 5 stars.',
                                'Works perfectly! Super fast shipping and friendly customer support.'
                            ]),
                            'status' => 'approved',
                        ]
                    );
                }
            }
        }

        // Recalculate average ratings for all products
        foreach ($products as $product) {
            $product->updateRatingStats();
        }
    }
}
