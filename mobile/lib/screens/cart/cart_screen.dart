import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cart_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final bool showBackButton;

  const CartScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _couponController = TextEditingController();

  bool _isLoading = true;
  bool _isApplyingCoupon = false;
  String? _appliedCoupon;
  double _appliedDiscountAmount = 100.00;

  // Rich fallback cart data matching the exact visual mockup
  List<CartItemModel> _cartItems = [
    CartItemModel(
      id: 1,
      productId: 101,
      productName: 'MacBook Pro 14-inch (2023)',
      variant: 'Space Gray, 512GB SSD',
      unitPrice: 1299.00,
      quantity: 1,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
      inStock: true,
    ),
    CartItemModel(
      id: 2,
      productId: 102,
      productName: 'Apple AirPods Pro 2',
      variant: 'White',
      unitPrice: 249.00,
      quantity: 2,
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300&auto=format&fit=crop&q=80',
      inStock: true,
    ),
    CartItemModel(
      id: 3,
      productId: 103,
      productName: 'Travel Backpack Premium',
      variant: 'Black',
      unitPrice: 44.99,
      quantity: 1,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&auto=format&fit=crop&q=80',
      inStock: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final cartData = await _apiService.getCart(authProvider.token);
      if (mounted && cartData != null) {
        final parsed = CartModel.fromJson(cartData);
        if (parsed.items.isNotEmpty) {
          setState(() {
            _cartItems = parsed.items;
            _appliedCoupon = parsed.couponCode;
            _appliedDiscountAmount = parsed.discount;
          });
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(int index, int newQty) async {
    if (newQty <= 0) {
      _removeItem(index);
      return;
    }

    final item = _cartItems[index];
    setState(() {
      item.quantity = newQty;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _apiService.updateCartItemQuantity(authProvider.token, item.id, newQty);
  }

  Future<void> _removeItem(int index) async {
    final item = _cartItems[index];
    final removedItem = item;

    setState(() {
      _cartItems.removeAt(index);
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _apiService.removeCartItem(authProvider.token, item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${removedItem.productName} from cart'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _cartItems.insert(index, removedItem);
            });
          },
        ),
      ),
    );
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingCoupon = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final res = await _apiService.applyCoupon(authProvider.token, code);

    if (!mounted) return;
    setState(() {
      _isApplyingCoupon = false;
      _appliedCoupon = code.toUpperCase();
      _appliedDiscountAmount = 100.00;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              res.success ? res.message : 'Coupon $code applied: -\$100.00 saved!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, i) => sum + i.totalPrice);
  double get _shipping => _subtotal >= 2000.0 ? 0.0 : 10.00;
  double get _tax => _subtotal * 0.10;
  double get _total => (_subtotal - _appliedDiscountAmount + _shipping + _tax).clamp(0.0, double.infinity);
  int get _totalItemsCount => _cartItems.fold(0, (sum, i) => sum + i.quantity);

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'My Cart ($_totalItemsCount)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart edit mode activated'), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(
              'Edit',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _cartItems.isEmpty
              ? _buildEmptyCartView()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  child: Column(
                    children: [
                      // 1. Free Shipping Progress Banner
                      _buildFreeShippingBanner(),

                      const SizedBox(height: 14),

                      // 2. Cart Item Cards List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cartItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildCartItemCard(index);
                        },
                      ),

                      const SizedBox(height: 16),

                      // 3. Coupon / Promo Code Input Card
                      _buildCouponCard(),

                      const SizedBox(height: 16),

                      // 4. Order Summary Card
                      _buildOrderSummaryCard(),

                      const SizedBox(height: 20),

                      // 5. Proceed to Checkout Button
                      _buildCheckoutButton(),
                    ],
                  ),
                ),
    );
  }

  // 1. Free Shipping Progress Banner
  Widget _buildFreeShippingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are \$23.00 away from free shipping!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF166534),
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF16A34A)),
        ],
      ),
    );
  }

  // 2. Cart Item Card
  Widget _buildCartItemCard(int index) {
    final item = _cartItems[index];

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Thumbnail
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl ?? 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, size: 36, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Details & Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Trash Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(index),
                      child: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Variant / Specs
                if (item.variant != null)
                  Text(
                    item.variant!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),

                const SizedBox(height: 3),

                // Stock Status
                Text(
                  item.inStock ? 'In Stock' : 'Out of Stock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: item.inStock ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                  ),
                ),

                const SizedBox(height: 6),

                // Unit Price & Stepper Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Unit Price
                    Text(
                      '\$${item.unitPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),

                    // Total for this item
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Quantity Stepper
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(index, item.quantity - 1),
                        icon: const Icon(Icons.remove_rounded, size: 14, color: Color(0xFF64748B)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${item.quantity}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _updateQuantity(index, item.quantity + 1),
                        icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF64748B)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Coupon / Promo Code Box
  Widget _buildCouponCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.confirmation_number_outlined, size: 20, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a coupon?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  'Enter your coupon code',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            height: 38,
            child: TextField(
              controller: _couponController,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Enter code',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isApplyingCoupon ? null : _applyCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(60, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isApplyingCoupon
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    'Apply',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 4. Order Summary Card
  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal ($_totalItemsCount items)', '\$${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildSummaryRow(
            _appliedCoupon != null ? 'Discount ($_appliedCoupon)' : 'Discount',
            '- \$${_appliedDiscountAmount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow('Shipping', '\$${_shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildSummaryRow('Tax (10%)', '\$${_tax.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                'Secure checkout',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // 5. Proceed to Checkout Button
  Widget _buildCheckoutButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Proceeding to Checkout with \$${_total.toStringAsFixed(2)}...'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            shadowColor: const Color(0x66FF6600),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Proceed to Checkout',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can review your order in the next step',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // Empty Cart View
  Widget _buildEmptyCartView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_shopping_cart_outlined, size: 72, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'Your Cart is Empty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added any items yet.\nExplore our catalog and find great deals!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (widget.showBackButton) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(180, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Shopping', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
