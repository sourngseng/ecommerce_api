import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../products/category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedSidebarIndex = 0;
  bool _isLoading = true;
  List<CategoryModel> _apiCategories = [];
  String _searchQuery = '';

  // Rich fallback category data matching the visual mockup
  final List<Map<String, dynamic>> _catalogItems = [
    {
      'id': 0,
      'name': 'All Categories',
      'icon': Icons.grid_view_rounded,
      'emoji': '🟧',
    },
    {
      'id': 1,
      'name': 'Electronics',
      'icon': Icons.phone_iphone_rounded,
      'emoji': '📱',
      'itemsCount': '245 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 2,
      'name': 'Laptops & Computers',
      'icon': Icons.laptop_mac_rounded,
      'emoji': '💻',
      'itemsCount': '128 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 3,
      'name': 'Fashion',
      'icon': Icons.checkroom_rounded,
      'emoji': '👕',
      'itemsCount': '362 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 4,
      'name': 'Shoes',
      'icon': Icons.snowshoeing_rounded,
      'emoji': '👟',
      'itemsCount': '158 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 5,
      'name': 'Beauty',
      'icon': Icons.brush_rounded,
      'emoji': '💄',
      'itemsCount': '214 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 6,
      'name': 'Home & Kitchen',
      'icon': Icons.chair_rounded,
      'emoji': '🛋️',
      'itemsCount': '276 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 7,
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'emoji': '🏀',
      'itemsCount': '189 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 8,
      'name': 'Books',
      'icon': Icons.menu_book_rounded,
      'emoji': '📘',
      'itemsCount': '132 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 9,
      'name': 'Accessories',
      'icon': Icons.shopping_bag_rounded,
      'emoji': '👜',
      'itemsCount': '198 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 10,
      'name': 'Toys & Games',
      'icon': Icons.videogame_asset_rounded,
      'emoji': '🎮',
      'itemsCount': '156 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 11,
      'name': 'Automotive',
      'icon': Icons.directions_car_rounded,
      'emoji': '🚗',
      'itemsCount': '74 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1578844251758-2f71da64c96f?w=300&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _apiCategories = categories;
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Categories',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(showBackButton: true),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 24,
                  color: Color(0xFF1E293B),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar with Filter Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    )
                  else
                    const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // 2. Master-Detail 2-Column Layout (Sidebar + Grid)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Vertical Category Sidebar
                Container(
                  width: 124,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(
                      right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _catalogItems.length,
                    itemBuilder: (context, index) {
                      final item = _catalogItems[index];
                      final bool isSelected = _selectedSidebarIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedSidebarIndex = index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFF6F0) : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 3.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                item['emoji'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : const Color(0xFF334155),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right Category Grid / Content Area
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _buildRightContentGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContentGrid() {
    // Filter display items
    final List<Map<String, dynamic>> gridItems = _catalogItems
        .where((item) => item['id'] != 0) // Skip 'All Categories' item in grid
        .where((item) {
          if (_selectedSidebarIndex != 0) {
            return item['name'] == _catalogItems[_selectedSidebarIndex]['name'];
          }
          if (_searchQuery.isNotEmpty) {
            return item['name'].toString().toLowerCase().contains(_searchQuery);
          }
          return true;
        })
        .toList();

    if (gridItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'No categories found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        final item = gridItems[index];

        // Match with API Category if available
        String countText = item['itemsCount'] ?? '100+ Items';
        final apiMatch = _apiCategories.where(
          (c) => c.name.toLowerCase().contains(item['name'].toString().toLowerCase()) ||
                 item['name'].toString().toLowerCase().contains(c.name.toLowerCase()),
        );
        if (apiMatch.isNotEmpty && apiMatch.first.productsCount != null) {
          countText = '${apiMatch.first.productsCount} Items';
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProductsScreen(
                  title: item['name'],
                  emoji: item['emoji'],
                  category: apiMatch.isNotEmpty ? apiMatch.first : null,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Product Showcase Image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['imageUrl'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          item['emoji'],
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // Item Count
              Text(
                countText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
  }
}
