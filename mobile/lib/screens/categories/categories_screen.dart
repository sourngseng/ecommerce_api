import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../providers/cart_provider.dart';
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

  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  List<CategoryModel> _apiCategories = [];
  String _searchQuery = '';

  // Rich category catalog matching the visual mockup and API
  final List<Map<String, dynamic>> _catalogItems = [
    {
      'id': 0,
      'name': 'All Categories',
      'icon': Icons.grid_view_rounded,
      'emoji': '✨',
      'itemsCount': '1,450 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 1,
      'name': 'Electronics',
      'icon': Icons.phone_iphone_rounded,
      'emoji': '📱',
      'itemsCount': '245 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 2,
      'name': 'Laptops & Computers',
      'icon': Icons.laptop_mac_rounded,
      'emoji': '💻',
      'itemsCount': '128 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 3,
      'name': 'Fashion',
      'icon': Icons.checkroom_rounded,
      'emoji': '👗',
      'itemsCount': '362 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 4,
      'name': 'Shoes',
      'icon': Icons.snowshoeing_rounded,
      'emoji': '👟',
      'itemsCount': '158 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 5,
      'name': 'Beauty',
      'icon': Icons.brush_rounded,
      'emoji': '💄',
      'itemsCount': '214 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 6,
      'name': 'Home & Kitchen',
      'icon': Icons.chair_rounded,
      'emoji': '🛋️',
      'itemsCount': '276 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 7,
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'emoji': '🏀',
      'itemsCount': '189 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 8,
      'name': 'Books',
      'icon': Icons.menu_book_rounded,
      'emoji': '📚',
      'itemsCount': '132 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 9,
      'name': 'Accessories',
      'icon': Icons.watch_outlined,
      'emoji': '👜',
      'itemsCount': '95 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 10,
      'name': 'Toys & Games',
      'icon': Icons.sports_esports_rounded,
      'emoji': '🎮',
      'itemsCount': '112 Items',
      'imageUrl': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _apiService.getCategories();
      if (mounted && categories.isNotEmpty) {
        setState(() {
          _apiCategories = categories;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Merge API categories with visual presentation
    final List<Map<String, dynamic>> displayCategories = [];

    if (_apiCategories.isNotEmpty) {
      displayCategories.add({
        'id': 0,
        'name': 'All Categories',
        'icon': Icons.grid_view_rounded,
        'emoji': '✨',
        'itemsCount': '${_apiCategories.length * 15} Items',
        'imageUrl': 'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=400&auto=format&fit=crop&q=80',
      });

      for (var cat in _apiCategories) {
        final match = _catalogItems.firstWhere(
          (c) => c['name'].toString().toLowerCase() == cat.name.toLowerCase(),
          orElse: () => {
            'icon': Icons.category_rounded,
            'emoji': '📦',
            'imageUrl': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80',
          },
        );

        displayCategories.add({
          'id': cat.id,
          'name': cat.name,
          'icon': match['icon'] ?? Icons.category_rounded,
          'emoji': match['emoji'] ?? '📦',
          'itemsCount': '${(cat.productsCount != null && cat.productsCount! > 0) ? cat.productsCount : 5} Items',
          'imageUrl': cat.imageUrl ?? match['imageUrl'],
          'model': cat,
        });
      }
    } else {
      displayCategories.addAll(_catalogItems);
    }

    // Filter by search query
    final filteredCategories = displayCategories.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Filter grid based on active horizontal pill selection
    final gridItems = _selectedCategoryIndex == 0
        ? filteredCategories.where((c) => c['id'] != 0).toList()
        : filteredCategories.where((c) => c['id'] == displayCategories[_selectedCategoryIndex]['id']).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Categories',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
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
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.itemCount <= 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          '${cart.itemCount}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        color: AppColors.primary,
        child: Column(
          children: [
            // 1. Search Bar with Filter Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF64748B), size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // 2. Horizontal Scrollable Category Filter Pills
            _buildHorizontalCategoryScroll(displayCategories),

            const SizedBox(height: 12),

            // 3. 2-Column Full Width Category Cards Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : gridItems.isEmpty
                      ? _buildEmptyView()
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: gridItems.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(gridItems[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Horizontal Scrollable Category Filter Pills
  Widget _buildHorizontalCategoryScroll(List<Map<String, dynamic>> categories) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x33FF6600),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat['emoji'] ?? '📦',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Category Card
  Widget _buildCategoryCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        CategoryModel? model;
        if (item['model'] is CategoryModel) {
          model = item['model'] as CategoryModel;
        } else {
          model = CategoryModel(
            id: item['id'] as int,
            name: item['name'] as String,
            slug: (item['name'] as String).toLowerCase().replaceAll(' ', '-'),
            productsCount: int.tryParse(item['itemsCount'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 5,
            image: item['imageUrl'],
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              category: model,
              title: item['name'] as String,
              emoji: item['emoji'] as String?,
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
          children: [
            // Top Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    item['imageUrl'] ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(item['icon'] as IconData? ?? Icons.category_rounded, size: 44, color: AppColors.primaryLight),
                    ),
                  ),
                ),
              ),
            ),

            // Title & Items Count
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                children: [
                  Text(
                    item['name'],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['itemsCount'] ?? '5 Items',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 14),
            Text(
              'No Categories Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching for another category keyword.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
