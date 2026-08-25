import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/banner_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../products/category_products_screen.dart';
import '../products/product_detail_screen.dart';
import '../wishlist/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;
  final ApiService _apiService = ApiService();

  // Dynamic API state
  bool _isLoading = true;
  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _flashSaleProducts = [];
  List<ProductModel> _newArrivals = [];

  // Countdown timer for Flash Sale
  late Timer _countdownTimer;
  Duration _timeLeft = const Duration(hours: 2, minutes: 18, seconds: 45);

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchHomeData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getBanners(),
        _apiService.getCategories(),
        _apiService.getFlashSaleProducts(),
        _apiService.getNewArrivals(),
      ]);

      if (mounted) {
        setState(() {
          _banners = results[0] as List<BannerModel>;
          _categories = results[1] as List<CategoryModel>;
          _flashSaleProducts = results[2] as List<ProductModel>;
          _newArrivals = results[3] as List<ProductModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentBottomNavIndex == 0
            ? _buildHomeTab(user)
            : _buildOtherTabs(_currentBottomNavIndex, user),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab(dynamic user) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetchHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 1. Top Header: User Profile Greeting & Notification Bell
            _buildTopHeader(user),

            const SizedBox(height: 16),

            // 2. Search Bar
            _buildSearchBar(),

            const SizedBox(height: 20),

            // 3. Hero Promo Banner Slider
            _buildHeroBannerSlider(),

            const SizedBox(height: 24),

            // 4. Categories Section
            _buildCategoriesSection(),

            const SizedBox(height: 24),

            // 5. Flash Sale ⚡ with Live Countdown Timer
            _buildFlashSaleSection(),

            const SizedBox(height: 24),

            // 6. New Arrivals Section
            _buildNewArrivalsSection(),
          ],
        ),
      ),
    );
  }

  // 1. Top Header: User Profile Greeting & Notification Bell
  Widget _buildTopHeader(dynamic user) {
    final String displayName = user != null && user.name.isNotEmpty
        ? user.name.split(' ').first
        : 'Customer';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar & Greeting
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hi, $displayName',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('👋', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'What are you shopping today?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Notification Bell with Badge
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: Color(0xFF1E293B),
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      '3',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Modern Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search for products, brands and more...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  // 3. Hero Promo Banner Slider
  Widget _buildHeroBannerSlider() {
    final banner = _banners.isNotEmpty ? _banners.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 155,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0E8), Color(0xFFFFE3D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                // Text Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SPECIAL OFFER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner?.title.isNotEmpty == true ? banner!.title : 'Up to 50% OFF',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner?.subtitle?.isNotEmpty == true ? banner!.subtitle! : 'On selected items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner?.buttonText ?? 'Shop Now',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Image Showcase
                Positioned(
                  right: 10,
                  top: 10,
                  bottom: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: banner?.imageUrl.isNotEmpty == true
                        ? Image.network(
                            banner!.imageUrl,
                            width: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackBannerGraphics(),
                          )
                        : _buildFallbackBannerGraphics(),
                  ),
                ),

                // 50% Off badge sticker
                Positioned(
                  right: 18,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '50%\nOFF',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Pagination Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCBD5E1)),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBannerGraphics() {
    return Row(
      children: [
        Icon(Icons.headphones_rounded, size: 68, color: const Color(0xFFC29B7F).withAlpha(200)),
        const SizedBox(width: 4),
        Icon(Icons.watch_rounded, size: 54, color: const Color(0xFF1E293B).withAlpha(180)),
      ],
    );
  }

  // 4. Categories Section
  Widget _buildCategoriesSection() {
    final List<Map<String, dynamic>> defaultCategories = [
      {'name': 'Phones', 'icon': '📱', 'color': const Color(0xFFEFF6FF)},
      {'name': 'Laptops', 'icon': '💻', 'color': const Color(0xFFF1F5F9)},
      {'name': 'Fashion', 'icon': '👕', 'color': const Color(0xFFFFF1F2)},
      {'name': 'Shoes', 'icon': '👟', 'color': const Color(0xFFF8FAFC)},
      {'name': 'Beauty', 'icon': '💄', 'color': const Color(0xFFFFF7ED)},
      {'name': 'Home', 'icon': '🛋️', 'color': const Color(0xFFECFDF5)},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentBottomNavIndex = 1),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.isNotEmpty ? _categories.length : defaultCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              String name = 'Category';
              String icon = '🛍️';
              Color bg = const Color(0xFFF8FAFC);

              if (_categories.isNotEmpty && index < _categories.length) {
                name = _categories[index].name;
                final def = defaultCategories[index % defaultCategories.length];
                icon = def['icon'];
                bg = def['color'];
              } else {
                name = defaultCategories[index]['name'];
                icon = defaultCategories[index]['icon'];
                bg = defaultCategories[index]['color'];
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        title: name,
                        emoji: icon,
                        category: _categories.isNotEmpty && index < _categories.length ? _categories[index] : null,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 5. Flash Sale ⚡ Section with Countdown Timer
  Widget _buildFlashSaleSection() {
    final String hrs = _timeLeft.inHours.toString().padLeft(2, '0');
    final String mins = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final String secs = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    final List<Map<String, dynamic>> fallbackProducts = [
      {
        'title': 'Wireless Earbuds Pro 2',
        'price': 39.99,
        'old_price': 49.99,
        'discount': '-20%',
        'rating': 4.8,
        'reviews': 128,
        'image': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300&auto=format&fit=crop&q=80',
      },
      {
        'title': 'Smart Watch Series 9',
        'price': 229.00,
        'old_price': 269.00,
        'discount': '-15%',
        'rating': 4.7,
        'reviews': 96,
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300&auto=format&fit=crop&q=80',
      },
      {
        'title': 'Travel Backpack Premium',
        'price': 44.99,
        'old_price': 59.90,
        'discount': '-25%',
        'rating': 4.6,
        'reviews': 74,
        'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&auto=format&fit=crop&q=80',
      },
      {
        'title': 'Running Shoes Sporty',
        'price': 55.99,
        'old_price': 79.99,
        'discount': '-30%',
        'rating': 4.9,
        'reviews': 210,
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&auto=format&fit=crop&q=80',
      },
    ];

    return Column(
      children: [
        // Flash Sale Header & Timer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Flash Sale',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('⚡', style: TextStyle(fontSize: 16)),
                ],
              ),

              // Countdown timer boxes
              Row(
                children: [
                  _buildTimerBadge(hrs, 'Hrs'),
                  const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                  _buildTimerBadge(mins, 'Min'),
                  const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                  _buildTimerBadge(secs, 'Sec'),
                ],
              ),

              Row(
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Product Cards Horizontal Slider
        SizedBox(
          height: 236,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _flashSaleProducts.isNotEmpty ? _flashSaleProducts.length : fallbackProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (_flashSaleProducts.isNotEmpty && index < _flashSaleProducts.length) {
                final p = _flashSaleProducts[index];
                return _buildProductCard(
                  title: p.name,
                  price: p.price,
                  oldPrice: p.discountPrice != null ? p.price * 1.2 : null,
                  discount: p.discountPercent != null ? '-${p.discountPercent}%' : '-20%',
                  rating: p.rating,
                  reviews: p.reviewsCount,
                  imageUrl: p.imageUrl ?? fallbackProducts[index % fallbackProducts.length]['image'],
                );
              } else {
                final fp = fallbackProducts[index];
                return _buildProductCard(
                  title: fp['title'],
                  price: fp['price'],
                  oldPrice: fp['old_price'],
                  discount: fp['discount'],
                  rating: fp['rating'],
                  reviews: fp['reviews'],
                  imageUrl: fp['image'],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBadge(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EB),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFFFCCBA)),
          ),
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 8.5,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 6. New Arrivals Section
  Widget _buildNewArrivalsSection() {
    final List<String> arrivalImages = [
      'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=300&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=300&auto=format&fit=crop&q=80',
    ];

    final int count = _newArrivals.isNotEmpty ? _newArrivals.length : arrivalImages.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Arrivals',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: count,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              String imgUrl = arrivalImages[index % arrivalImages.length];
              if (_newArrivals.isNotEmpty && index < _newArrivals.length && _newArrivals[index].imageUrl != null) {
                imgUrl = _newArrivals[index].imageUrl!;
              }

              return Container(
                width: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Common Product Card Widget
  Widget _buildProductCard({
    required String title,
    required double price,
    double? oldPrice,
    required String discount,
    required double rating,
    required int reviews,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: ProductModel(
                id: 1,
                name: title,
                slug: title.toLowerCase().replaceAll(' ', '-'),
                description: 'High performance device with advanced features and warranty.',
                price: price,
                discountPrice: oldPrice,
                stock: 20,
                rating: rating,
                reviewsCount: reviews,
                imageUrl: imageUrl,
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 152,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Box with Discount Sticker & Wishlist Heart
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                  ),
                ),
              ),

              // Discount Tag
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    discount,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Wishlist Heart Icon
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 15,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          // Title & Prices
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    if (oldPrice != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '\$${oldPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '($reviews)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // 7. Bottom Navigation Bar with 5 Tabs
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.grid_view_rounded, 'Categories'),
          _buildNavItem(2, Icons.shopping_cart_outlined, 'Cart', badgeCount: 2),
          _buildNavItem(3, Icons.favorite_border_rounded, 'Wishlist'),
          _buildNavItem(4, Icons.person_outline_rounded, 'Account'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {int? badgeCount}) {
    final bool isSelected = _currentBottomNavIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentBottomNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
              if (badgeCount != null)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? AppColors.primary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Alternate Tab Views (Categories, Cart, Wishlist, Account)
  Widget _buildOtherTabs(int tabIndex, dynamic user) {
    if (tabIndex == 1) {
      return const CategoriesScreen();
    }
    if (tabIndex == 2) {
      return const CartScreen();
    }
    if (tabIndex == 3) {
      return const WishlistScreen();
    }

    final titles = ['Home', 'All Categories', 'My Shopping Cart', 'My Wishlist', 'My Account'];
    final icons = [Icons.home, Icons.grid_view_rounded, Icons.shopping_cart_rounded, Icons.favorite_rounded, Icons.person_rounded];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[tabIndex], size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              titles[tabIndex],
              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              tabIndex == 4
                  ? 'Logged in as ${user?.name ?? 'User'} (${user?.role ?? 'Customer'})\nEmail: ${user?.email ?? 'N/A'}'
                  : 'Connected to live Laravel 12 API backend.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 14),
            ),
            if (tabIndex == 4) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  minimumSize: const Size(180, 46),
                ),
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
