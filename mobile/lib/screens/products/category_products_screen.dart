import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel? category;
  final String title;
  final String? emoji;

  const CategoryProductsScreen({
    super.key,
    this.category,
    this.title = 'Laptops & Computers',
    this.emoji = '💻',
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isGridView = true;
  List<ProductModel> _products = [];
  String _selectedSubcategory = 'All';
  String _selectedSort = 'Popular';
  final Set<int> _wishlistIds = {};

  final List<String> _subcategories = [
    'All',
    'Laptops',
    'Desktops',
    'Monitors',
    'Accessories',
  ];

  // High-fidelity fallback catalog matching the user's mockup
  final List<Map<String, dynamic>> _mockFallbackProducts = [
    {
      'id': 101,
      'name': 'MacBook Pro 14-inch',
      'spec': 'M3 Pro Chip, 16GB RAM, 512GB SSD',
      'price': 1299.00,
      'old_price': 1499.00,
      'discount': '-13%',
      'tag': 'Bestseller',
      'rating': 4.8,
      'reviews': 125,
      'imageUrl': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 102,
      'name': 'ASUS Vivobook 15',
      'spec': 'Intel Core i5, 8GB RAM, 512GB SSD',
      'price': 549.00,
      'old_price': 609.00,
      'discount': '-10%',
      'tag': '-10%',
      'rating': 4.6,
      'reviews': 89,
      'imageUrl': 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 103,
      'name': 'HP Pavilion 14',
      'spec': 'Intel Core i7, 16GB RAM, 512GB SSD',
      'price': 699.00,
      'old_price': 759.00,
      'discount': '-8%',
      'tag': 'New',
      'rating': 4.7,
      'reviews': 64,
      'imageUrl': 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 104,
      'name': 'Dell XPS 13',
      'spec': 'Intel Core i7, 16GB RAM, 1TB SSD',
      'price': 1099.00,
      'old_price': 1199.00,
      'discount': '-8%',
      'tag': null,
      'rating': 4.9,
      'reviews': 102,
      'imageUrl': 'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 105,
      'name': 'ASUS ROG Strix G16',
      'spec': 'Intel Core i7, 16GB RAM, 1TB SSD',
      'price': 1399.00,
      'old_price': 1649.00,
      'discount': '-15%',
      'tag': '-15%',
      'rating': 4.9,
      'reviews': 192,
      'imageUrl': 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 106,
      'name': 'Apple iMac 24-inch (M3)',
      'spec': '8-core CPU, 8GB RAM, 256GB SSD',
      'price': 1249.00,
      'old_price': 1399.00,
      'discount': '-11%',
      'tag': 'New',
      'rating': 4.8,
      'reviews': 76,
      'imageUrl': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      String? sortBy = 'price';
      String? sortOrder = 'asc';
      if (_selectedSort == 'Popular') {
        sortBy = 'created_at';
        sortOrder = 'desc';
      } else if (_selectedSort == 'Price: High to Low') {
        sortBy = 'price';
        sortOrder = 'desc';
      }

      final products = await _apiService.getProducts(
        categoryId: widget.category?.id,
        sortBy: sortBy,
        sortOrder: sortOrder,
        search: _selectedSubcategory != 'All' ? _selectedSubcategory : null,
      );

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final sortOptions = [
          'Popular',
          'Price: Low to High',
          'Price: High to Low',
          'Customer Rating',
          'Newest Arrivals',
        ];

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
                  'Sort Products By',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                ...sortOptions.map((opt) {
                  final isSel = _selectedSort == opt;
                  return ListTile(
                    title: Text(
                      opt,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        color: isSel ? AppColors.primary : const Color(0xFF334155),
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedSort = opt);
                      Navigator.pop(context);
                      _fetchProducts();
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter Options',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Price Range',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('\$100 (Min)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('\$2,500 (Max)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Shipping',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(value: true, activeColor: AppColors.primary, onChanged: (_) {}),
                      const Text('Free Shipping Only'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _fetchProducts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int count = _products.isNotEmpty ? _products.length : _mockFallbackProducts.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.emoji ?? '💻',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  '$count Products',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF1E293B)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistScreen(showBackButton: true),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border_rounded, size: 22, color: Color(0xFF1E293B)),
          ),
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
                icon: const Icon(Icons.shopping_cart_outlined, size: 24, color: Color(0xFF1E293B)),
              ),
              Positioned(
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
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 4),

              // 1. Control Toolbar (Sort, Filter, Grid View)
              _buildControlToolbar(),

              const SizedBox(height: 10),

              // 2. Subcategory Filter Pills
              _buildSubcategoryPills(),

              const SizedBox(height: 10),

              // 3. Results Summary Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count Products found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubcategory = 'All';
                          _selectedSort = 'Popular';
                        });
                        _fetchProducts();
                      },
                      child: Text(
                        'Clear All ✕',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 4. Products Grid / List View
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _buildProductListing(),
              ),
            ],
          ),

          // 5. Floating Bottom Filter Pill
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6F0),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFFFD4BA)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF1E293B)),
                      const SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Control Toolbar (Sort, Filter, Grid View)
  Widget _buildControlToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Sort Dropdown
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _showSortBottomSheet,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_vert_rounded, size: 18, color: Color(0xFF475569)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Sort\n$_selectedSort',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          height: 1.1,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Filter Button
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _showFilterModal,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined, size: 16, color: Color(0xFF475569)),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Grid / List Toggle
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => setState(() => _isGridView = !_isGridView),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
                      size: 16,
                      color: const Color(0xFF475569),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isGridView ? 'Grid' : 'List',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Subcategory Filter Pills
  Widget _buildSubcategoryPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _subcategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sub = _subcategories[index];
          final bool isSelected = _selectedSubcategory == sub;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedSubcategory = sub);
              _fetchProducts();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF6F0) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.4 : 1,
                ),
              ),
              child: Text(
                sub,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
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

  // 4. Products Grid / List View
  Widget _buildProductListing() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isGridView ? 2 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: _isGridView ? 0.65 : 1.9,
      ),
      itemCount: _products.isNotEmpty ? _products.length : _mockFallbackProducts.length,
      itemBuilder: (context, index) {
        if (_products.isNotEmpty && index < _products.length) {
          final p = _products[index];
          return _buildProductCard(
            id: p.id,
            name: p.name,
            spec: p.description ?? 'High performance device',
            price: p.price,
            oldPrice: p.discountPrice != null ? p.price * 1.2 : null,
            discount: p.discountPercent != null ? '-${p.discountPercent}%' : null,
            tag: p.tag,
            rating: p.rating,
            reviews: p.reviewsCount,
            imageUrl: p.imageUrl ?? _mockFallbackProducts[index % _mockFallbackProducts.length]['imageUrl'],
          );
        } else {
          final fp = _mockFallbackProducts[index];
          return _buildProductCard(
            id: fp['id'],
            name: fp['name'],
            spec: fp['spec'],
            price: fp['price'],
            oldPrice: fp['old_price'],
            discount: fp['discount'],
            tag: fp['tag'],
            rating: fp['rating'],
            reviews: fp['reviews'],
            imageUrl: fp['imageUrl'],
          );
        }
      },
    );
  }

  Widget _buildProductCard({
    required int id,
    required String name,
    required String spec,
    required double price,
    double? oldPrice,
    String? discount,
    String? tag,
    required double rating,
    required int reviews,
    required String imageUrl,
  }) {
    final bool isWishlisted = _wishlistIds.contains(id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: id,
              product: ProductModel(
                id: id,
                name: name,
                slug: name.toLowerCase().replaceAll(' ', '-'),
                description: spec,
                price: price,
                discountPrice: oldPrice,
                stock: 25,
                rating: rating,
                reviewsCount: reviews,
                imageUrl: imageUrl,
                tag: tag,
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
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area with Tag & Wishlist
          Stack(
            children: [
              Container(
                height: 130,
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
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.laptop_chromebook_rounded, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // Bestseller / New / Discount Tag
              if (tag != null)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: tag == 'Bestseller'
                          ? const Color(0xFFE8F5E9)
                          : (tag == 'New' ? const Color(0xFFE0F2FE) : const Color(0xFFFFF1F2)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: tag == 'Bestseller'
                            ? const Color(0xFF2E7D32)
                            : (tag == 'New' ? const Color(0xFF0284C7) : const Color(0xFFE11D48)),
                      ),
                    ),
                  ),
                ),

              // Wishlist Heart Button
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isWishlisted) {
                        _wishlistIds.remove(id);
                      } else {
                        _wishlistIds.add(id);
                      }
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x14000000), blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 16,
                      color: isWishlisted ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),

                // Spec / description
                Text(
                  spec,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),

                // Rating
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
                const SizedBox(height: 6),

                // Prices & Discount
                Row(
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
                    if (discount != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discount,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Free Shipping Tag
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 13, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      'Free Shipping',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
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
}
