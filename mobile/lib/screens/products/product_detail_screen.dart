import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel? product;
  final int? productId;

  const ProductDetailScreen({
    super.key,
    this.product,
    this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();

  late ProductModel _currentProduct;
  bool _isLoading = false;
  bool _isWishlisted = false;
  bool _isDescriptionExpanded = false;

  int _selectedImageIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedStorageIndex = 0;
  int _quantity = 1;

  final List<String> _galleryImages = [
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&auto=format&fit=crop&q=80',
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Space Gray', 'color': const Color(0xFF374151)},
    {'name': 'Silver', 'color': const Color(0xFFE2E8F0)},
    {'name': 'Starlight Gold', 'color': const Color(0xFFFDE68A)},
  ];

  final List<String> _storageOptions = [
    '512GB SSD',
    '1TB SSD',
    '2TB SSD',
  ];

  final List<Map<String, dynamic>> _keyFeatures = [
    {'icon': Icons.memory_rounded, 'title': 'M3 Pro Chip', 'subtitle': '11-core CPU'},
    {'icon': Icons.developer_board_rounded, 'title': '16GB', 'subtitle': 'Unified RAM'},
    {'icon': Icons.storage_rounded, 'title': '512GB', 'subtitle': 'SSD Storage'},
    {'icon': Icons.laptop_chromebook_rounded, 'title': '14.2-inch', 'subtitle': 'Liquid Retina XDR'},
    {'icon': Icons.battery_charging_full_rounded, 'title': 'Up to 18 hrs', 'subtitle': 'Battery Life'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _currentProduct = widget.product!;
      if (_currentProduct.imageUrl != null) {
        _galleryImages[0] = _currentProduct.imageUrl!;
      }
    } else {
      _currentProduct = ProductModel(
        id: widget.productId ?? 1,
        name: 'MacBook Pro 14-inch (2023)',
        slug: 'macbook-pro-14-inch',
        description: 'Supercharged by M3 Pro or M3 Max chips, MacBook Pro delivers extreme performance for demanding workflows and pro apps. With up to 18 hours of battery life and a stunning Liquid Retina XDR display, it is built for pros on the go.',
        price: 1299.00,
        discountPrice: 1499.00,
        stock: 45,
        rating: 4.8,
        reviewsCount: 125,
        imageUrl: _galleryImages[0],
        tag: 'Bestseller',
      );
      _fetchProductDetails();
    }
  }

  Future<void> _fetchProductDetails() async {
    if (widget.productId == null) return;
    setState(() => _isLoading = true);
    final p = await _apiService.getProductDetails(widget.productId!);
    if (mounted && p != null) {
      setState(() {
        _currentProduct = p;
        if (p.imageUrl != null) _galleryImages[0] = p.imageUrl!;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await _apiService.addToCart(authProvider.token, _currentProduct.id, _quantity);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added $_quantity x ${_currentProduct.name} to Cart!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(showBackButton: true),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                // Scrollable Content Body
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Image Carousel with Index Badge
                      _buildImageCarousel(),

                      const SizedBox(height: 16),

                      // 2. Product Title, Rating, Prices
                      _buildProductInfoSection(),

                      const SizedBox(height: 14),

                      // 3. Trust / Perks Banner (Free Shipping & 1 Year Warranty)
                      _buildTrustBanner(),

                      const SizedBox(height: 18),

                      // 4. Color Variant Selector
                      _buildColorSelector(),

                      const SizedBox(height: 18),

                      // 5. Storage Variant Selector
                      _buildStorageSelector(),

                      const SizedBox(height: 18),

                      // 6. Quantity Stepper
                      _buildQuantitySelector(),

                      const SizedBox(height: 22),

                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      const SizedBox(height: 18),

                      // 7. Key Features Grid
                      _buildKeyFeaturesSection(),

                      const SizedBox(height: 22),

                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      const SizedBox(height: 18),

                      // 8. Description Section
                      _buildDescriptionSection(),

                      const SizedBox(height: 22),

                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      const SizedBox(height: 18),

                      // 9. Customer Reviews & Breakdown
                      _buildCustomerReviewsSection(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Top Floating Back, Wishlist & Cart Actions
                _buildTopNavigationOverlay(),

                // Sticky Bottom Action Bar (Add to Cart & Buy Now)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomActionBar(),
                ),
              ],
            ),
    );
  }

  // 1. Top Floating Navigation Buttons Overlay
  Widget _buildTopNavigationOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              _buildFloatingCircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
              ),

              // Wishlist & Cart Buttons
              Row(
                children: [
                  _buildFloatingCircleBtn(
                    icon: _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _isWishlisted ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
                    onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      _buildFloatingCircleBtn(
                        icon: Icons.shopping_cart_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(showBackButton: true),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCircleBtn({
    required IconData icon,
    Color iconColor = const Color(0xFF1E293B),
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }

  // 1. Hero Image Carousel with Index Badge
  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Container(
          height: 310,
          width: double.infinity,
          color: const Color(0xFFFAFAFC),
          child: PageView.builder(
            itemCount: _galleryImages.length,
            onPageChanged: (idx) => setState(() => _selectedImageIndex = idx),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Image.network(
                  _galleryImages[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.laptop_mac_rounded, size: 100, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),

        // Index Badge (1/6)
        Positioned(
          left: 20,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0x801E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedImageIndex + 1}/${_galleryImages.length}',
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // Pagination Dots
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_galleryImages.length, (idx) {
              final isSel = _selectedImageIndex == idx;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSel ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isSel ? AppColors.primary : const Color(0xFFCBD5E1),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 2. Product Title, Rating, Prices
  Widget _buildProductInfoSection() {
    final double price = _currentProduct.price;
    final double? oldPrice = _currentProduct.discountPrice ?? (price > 0 ? price * 1.15 : null);
    final String discountStr = _currentProduct.discountPercent != null
        ? '-${_currentProduct.discountPercent}%'
        : '-13%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bestseller Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _currentProduct.tag ?? 'Bestseller',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Title & Share Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _currentProduct.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product link copied!'), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle / Specs
          Text(
            _currentProduct.description?.split('.').first ?? 'M3 Pro Chip, 16GB RAM, 512GB SSD',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 8),

          // Rating & Social Proof
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 3),
              Text(
                _currentProduct.rating.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_currentProduct.reviewsCount} Reviews)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              const Text('|', style: TextStyle(color: Color(0xFFCBD5E1))),
              const SizedBox(width: 8),
              Text(
                '212 Sold',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price Row
          Row(
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  '\$${oldPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  discountStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Trust / Perks Banner
  Widget _buildTrustBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDCFCE7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Text(
                  'Free Shipping',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 16, color: const Color(0xFF86EFAC)),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Text(
                  '1 Year Warranty',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. Color Variant Selector
  Widget _buildColorSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_colorOptions.length, (idx) {
              final isSel = _selectedColorIndex == idx;
              final col = _colorOptions[idx];

              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = idx),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSel ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: col['color'],
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 5. Storage Variant Selector
  Widget _buildStorageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_storageOptions.length, (idx) {
              final isSel = _selectedStorageIndex == idx;
              final st = _storageOptions[idx];

              return GestureDetector(
                onTap: () => setState(() => _selectedStorageIndex = idx),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFFFF6F0) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: isSel ? 1.4 : 1,
                    ),
                  ),
                  child: Text(
                    st,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? AppColors.primary : const Color(0xFF334155),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 6. Quantity Stepper
  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantity',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  icon: const Icon(Icons.remove_rounded, size: 16, color: Color(0xFF64748B)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '$_quantity',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF64748B)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Key Features Section
  Widget _buildKeyFeaturesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Features',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
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
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _keyFeatures.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final feat = _keyFeatures[index];
              return Container(
                width: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feat['icon'] as IconData, size: 20, color: const Color(0xFF475569)),
                    const SizedBox(height: 4),
                    Text(
                      feat['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      feat['subtitle'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
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

  // 8. Description Section
  Widget _buildDescriptionSection() {
    final desc = _currentProduct.description ??
        'Supercharged by M3 Pro or M3 Max chips, MacBook Pro delivers extreme performance for demanding workflows and pro apps. With up to 18 hours of battery life and a stunning Liquid Retina XDR display, it is built for pros on the go.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            maxLines: _isDescriptionExpanded ? null : 3,
            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isDescriptionExpanded ? 'Show Less' : '... Read More',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 9. Customer Reviews & Breakdown
  Widget _buildCustomerReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentProduct.rating.toStringAsFixed(1),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(${_currentProduct.reviewsCount} Reviews)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 18),

              // Star Breakdown Bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 100, 0.85),
                    _buildRatingBar(4, 18, 0.15),
                    _buildRatingBar(3, 5, 0.05),
                    _buildRatingBar(2, 1, 0.01),
                    _buildRatingBar(1, 1, 0.01),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Customer Photo/Video Review Thumbnail
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=200&auto=format&fit=crop&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0x99000000),
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Text('$stars ★', style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('$count', style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // Sticky Bottom Action Bar
  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Add to Cart (Outlined)
          Expanded(
            child: OutlinedButton(
              onPressed: _handleAddToCart,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.primary, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Add to Cart',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Buy Now (Solid Orange)
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await _handleAddToCart();
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      subtotal: _currentProduct.price * _quantity,
                      discount: _currentProduct.discountPrice != null
                          ? (_currentProduct.discountPrice! - _currentProduct.price) * _quantity
                          : 50.00,
                      couponCode: 'DIRECTBUY',
                      totalItems: _quantity,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                shadowColor: const Color(0x66FF6600),
              ),
              child: Text(
                'Buy Now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
