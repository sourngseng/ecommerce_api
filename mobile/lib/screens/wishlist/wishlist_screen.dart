import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../products/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final bool showBackButton;

  const WishlistScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Recently Added';

  final List<String> _categoryFilters = [
    'All (8)',
    'Electronics (3)',
    'Fashion (2)',
    'Beauty (1)',
    'Home (2)',
  ];

  // High-fidelity fallback catalog matching the user's visual mockup
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': 101,
      'name': 'MacBook Pro 14-inch (2023)',
      'spec': 'M3 Pro Chip, 16GB RAM, 512GB SSD',
      'category': 'Electronics',
      'price': 1299.00,
      'rating': 4.8,
      'reviews': 125,
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 102,
      'name': 'Apple AirPods Pro 2',
      'spec': 'Active Noise Cancellation',
      'category': 'Electronics',
      'price': 249.00,
      'rating': 4.7,
      'reviews': 89,
      'imageUrl': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 103,
      'name': 'Apple Watch Series 9',
      'spec': '41mm, GPS, Starlight Aluminum Case',
      'category': 'Electronics',
      'price': 429.00,
      'rating': 4.6,
      'reviews': 76,
      'imageUrl': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 104,
      'name': 'Nike Air Max 270',
      'spec': "Men's Running Shoes",
      'category': 'Fashion',
      'price': 159.00,
      'rating': 4.6,
      'reviews': 64,
      'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 105,
      'name': 'Michael Kors Hamilton Bag',
      'spec': 'Large Satchel',
      'category': 'Fashion',
      'price': 199.00,
      'rating': 4.6,
      'reviews': 48,
      'imageUrl': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 106,
      'name': 'Chanel Coco Mademoiselle',
      'spec': 'Eau de Parfum, 100ml',
      'category': 'Beauty',
      'price': 129.00,
      'rating': 4.8,
      'reviews': 37,
      'imageUrl': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 107,
      'name': 'Nordic Lounge Armchair',
      'spec': 'Modern Velvet Green Fabric',
      'category': 'Home',
      'price': 289.00,
      'rating': 4.9,
      'reviews': 52,
      'imageUrl': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 108,
      'name': 'Minimalist Floor Lamp',
      'spec': 'Warm LED Brass Finish',
      'category': 'Home',
      'price': 89.00,
      'rating': 4.7,
      'reviews': 41,
      'imageUrl': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeItem(int index) {
    final item = _wishlistItems[index];
    final removed = item;

    setState(() {
      _wishlistItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${removed['name']} from wishlist'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _wishlistItems.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> item) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _apiService.addToCart(authProvider.token, item['id'], 1);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${item['name']} to Cart!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen(showBackButton: true)),
            );
          },
        ),
      ),
    );
  }

  Future<void> _moveAllToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    for (var item in _wishlistItems) {
      await _apiService.addToCart(authProvider.token, item['id'], 1);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Moved all ${_wishlistItems.length} items to Cart!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OPEN CART',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen(showBackButton: true)),
            );
          },
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    final options = [
      'Recently Added',
      'Price: Low to High',
      'Price: High to Low',
      'Customer Rating',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sort Wishlist',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                ...options.map((opt) {
                  final isSel = _selectedSort == opt;
                  return ListTile(
                    title: Text(
                      opt,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        color: isSel ? AppColors.primary : const Color(0xFF334155),
                      ),
                    ),
                    trailing: isSel ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() {
                        _selectedSort = opt;
                        if (opt == 'Price: Low to High') {
                          _wishlistItems.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
                        } else if (opt == 'Price: High to Low') {
                          _wishlistItems.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
                        } else if (opt == 'Customer Rating') {
                          _wishlistItems.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _wishlistItems.where((item) {
      if (_selectedCategory != 'All') {
        if (!item['category'].toString().toLowerCase().contains(_selectedCategory.toLowerCase())) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        return item['name'].toString().toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF1E293B)),
                decoration: const InputDecoration(
                  hintText: 'Search saved items...',
                  border: InputBorder.none,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Wishlist (${_wishlistItems.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '${_wishlistItems.length} items saved for later',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 22,
              color: const Color(0xFF1E293B),
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen(showBackButton: true)),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, size: 24, color: Color(0xFF1E293B)),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      '2',
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
          const SizedBox(width: 6),
        ],
      ),
      body: _wishlistItems.isEmpty
          ? _buildEmptyWishlistView()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              child: Column(
                children: [
                  // 1. Move All to Cart Callout Promo Banner
                  _buildMoveAllToCartBanner(),

                  const SizedBox(height: 14),

                  // 2. Category Filter Chips
                  _buildCategoryFilterChips(),

                  const SizedBox(height: 12),

                  // 3. Sort by & Edit Row
                  _buildSortAndEditRow(),

                  const SizedBox(height: 12),

                  // 4. Wishlist 2-Column Product Cards Grid
                  _buildWishlistGrid(filteredItems),
                ],
              ),
            ),
    );
  }

  // 1. Move All to Cart Callout Promo Banner
  Widget _buildMoveAllToCartBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0D0)),
      ),
      child: Row(
        children: [
          // Circular Heart Icon
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.favorite_border_rounded, size: 22, color: Color(0xFFEF4444)),
            ),
          ),

          const SizedBox(width: 12),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Move items you love to cart',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Don't miss out on your favorites!",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Move All to Cart Outlined Button
          OutlinedButton(
            onPressed: _moveAllToCart,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              backgroundColor: Colors.white,
            ),
            child: Text(
              'Move All to Cart',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Category Filter Chips
  Widget _buildCategoryFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categoryFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final catLabel = _categoryFilters[index];
          final catName = catLabel.split(' (').first;
          final bool isSelected = _selectedCategory == catName;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = catName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF6F0) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.4 : 1,
                ),
              ),
              child: Text(
                catLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Sort by & Edit Row
  Widget _buildSortAndEditRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sort Dropdown
        GestureDetector(
          onTap: _showSortBottomSheet,
          child: Row(
            children: [
              Text(
                'Sort by: ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                _selectedSort,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
            ],
          ),
        ),

        // Edit & Trash Action
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select multiple items to delete or move'), behavior: SnackBarBehavior.floating),
                );
              },
              child: Text(
                'Edit',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Wishlist?'),
                    content: const Text('Are you sure you want to remove all saved items?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          setState(() => _wishlistItems.clear());
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Wishlist 2-Column Product Cards Grid
  Widget _buildWishlistGrid(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No matching items found in this category.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  productId: item['id'],
                  product: ProductModel(
                    id: item['id'],
                    name: item['name'],
                    slug: item['name'].toString().toLowerCase().replaceAll(' ', '-'),
                    description: item['spec'],
                    price: item['price'],
                    stock: 15,
                    rating: item['rating'],
                    reviewsCount: item['reviews'],
                    imageUrl: item['imageUrl'],
                  ),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image with Solid Red Heart & Menu Icon
                Stack(
                  children: [
                    Container(
                      height: 125,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          item['imageUrl'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),

                    // Solid Red Heart on Left
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x14000000), blurRadius: 4),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFEF4444)),
                        ),
                      ),
                    ),

                    // 3-Dots Menu on Right
                    Positioned(
                      right: 6,
                      top: 6,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Options for ${item['name']}'), behavior: SnackBarBehavior.floating),
                          );
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0x14000000), blurRadius: 4),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Details Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Specs
                      Text(
                        item['spec'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Price
                      Text(
                        '\$${(item['price'] as double).toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Star Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            (item['rating'] as double).toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${item['reviews']})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Action Buttons Row: Add to Cart & Trash Icon
                      Row(
                        children: [
                          // Add to Cart Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _addToCart(item),
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF6F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFE0D0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined, size: 13, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add to Cart',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Trash Icon Button
                          GestureDetector(
                            onTap: () => _removeItem(index),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Center(
                                child: Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFF94A3B8)),
                              ),
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
      },
    );
  }

  // Empty Wishlist View
  Widget _buildEmptyWishlistView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 72, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'Your Wishlist is Empty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore thousands of products and save your favorites here!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
