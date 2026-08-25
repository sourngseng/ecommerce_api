import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cart_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/product_review_modal.dart';
import '../orders/my_orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double subtotal;
  final double discount;
  final String? couponCode;
  final int totalItems;

  const CheckoutScreen({
    super.key,
    this.subtotal = 1841.99,
    this.discount = 100.00,
    this.couponCode = 'WELCOME10',
    this.totalItems = 3,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _apiService = ApiService();

  int _currentStep = 1; // 1: Checkout, 2: Shipping, 3: Payment, 4: Review
  int _selectedAddressIndex = 0;
  int _selectedShippingIndex = 0;
  int _selectedPaymentIndex = 0;
  bool _isCartExpanded = false;
  bool _isPlacingOrder = false;

  final List<Map<String, dynamic>> _addresses = [
    {
      'title': 'Home',
      'name': 'Seng Sourng',
      'address': '#123, Street 456, Sangkat Boeung Keng Kang 1, Khan Chamkarmon, Phnom Penh, Cambodia',
      'phone': '+855 12 345 678',
      'isDefault': true,
    },
    {
      'title': 'Office',
      'name': 'Seng Sourng',
      'address': 'Canadia Tower 18th Floor, Monivong Blvd, Phnom Penh, Cambodia',
      'phone': '+855 12 345 678',
      'isDefault': false,
    },
  ];

  final List<Map<String, dynamic>> _shippingMethods = [
    {
      'id': 'standard',
      'title': 'Standard Shipping',
      'duration': '3 - 5 business days',
      'price': 5.00,
      'priceText': '\$5.00',
    },
    {
      'id': 'express',
      'title': 'Express Shipping',
      'duration': '1 - 2 business days',
      'price': 12.00,
      'priceText': '\$12.00',
    },
    {
      'id': 'pickup',
      'title': 'Pickup at Store',
      'duration': 'Pick up from our store',
      'price': 0.00,
      'priceText': 'Free',
    },
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cod',
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when you receive your order',
      'icon': '💵',
    },
    {
      'id': 'card',
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, MasterCard, JCB, AMEX',
      'badge': '💳',
    },
    {
      'id': 'bank',
      'title': 'Bank Transfer',
      'subtitle': 'Transfer directly from your bank',
      'icon': '🏛️',
    },
    {
      'id': 'ewallet',
      'title': 'e-Wallet',
      'subtitle': 'Pay with ABA Pay, Wing, TrueMoney',
      'badge': '📱',
    },
  ];

  double get _shippingCost => _shippingMethods[_selectedShippingIndex]['price'] as double;
  double get _taxAmount => (widget.subtotal - widget.discount) * 0.10;
  double get _grandTotal => (widget.subtotal - widget.discount + _shippingCost + _taxAmount).clamp(0.0, double.infinity);

  Future<void> _handleProceedToCheckout() async {
    setState(() => _isPlacingOrder = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final selectedAddress = _addresses[_selectedAddressIndex];
    final selectedShipping = _shippingMethods[_selectedShippingIndex];
    final selectedPayment = _paymentMethods[_selectedPaymentIndex];

    final formattedAddress = {
      'recipient_name': selectedAddress['recipient'] ?? selectedAddress['recipient_name'] ?? 'Seng Sourng',
      'phone': selectedAddress['phone'] ?? '+855 12 345 678',
      'address_line_1': selectedAddress['address'] ?? selectedAddress['address_line_1'] ?? '#123, St. 2004, Sen Sok, Phnom Penh',
      'city': 'Phnom Penh',
      'province': 'Phnom Penh',
    };

    String paymentKey = 'demo_card';
    if (selectedPayment['id'] == 'cod') paymentKey = 'cash_on_delivery';
    if (selectedPayment['id'] == 'bank' || selectedPayment['id'] == 'ewallet') paymentKey = 'bank_transfer';
    if (selectedPayment['id'] == 'card') paymentKey = 'demo_card';

    final cartItemsSnapshot = List<CartItemModel>.from(cartProvider.items);
    final cartItemsPayload = cartItemsSnapshot.map((i) => {
      'product_id': i.productId,
      'quantity': i.quantity,
      'name': i.productName,
      'unit_price': i.unitPrice,
    }).toList();

    final res = await _apiService.createOrder(
      token: authProvider.token,
      shippingAddress: formattedAddress,
      shippingMethod: selectedShipping['id'] ?? 'standard',
      paymentMethod: paymentKey,
      couponCode: widget.couponCode,
      items: cartItemsPayload,
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    // WIPE/CLEAR CART AUTOMATICALLY ON CHECKOUT & PAYMENT COMPLETE
    await cartProvider.clearCart(authProvider.token);

    final String createdOrderNumber = res.data?['order_number'] ?? 'ORD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _showOrderSuccessDialog(createdOrderNumber, cartItemsSnapshot);
  }

  void _onPayButtonPressed() {
    final selectedPayment = _paymentMethods[_selectedPaymentIndex];
    if (selectedPayment['id'] == 'cod') {
      _handleProceedToCheckout();
    } else {
      _showPaymentConfirmationSheet(selectedPayment);
    }
  }

  void _showPaymentConfirmationSheet(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      payment['badge'] ?? payment['icon'] ?? '💳',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment via ${payment['title']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          payment['subtitle'] ?? 'Secure online gateway',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visual representation according to payment method
              if (payment['id'] == 'ewallet') ...[
                // ABA Pay KHQR Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003057),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE31B23),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'KHQR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ABA PAY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${_grandTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.qr_code_2_rounded, size: 140, color: Color(0xFF003057)),
                            const SizedBox(height: 4),
                            Text(
                              'ECOMMERCE STORE CO., LTD.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Scan with ABA Mobile or any Banking App',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (payment['id'] == 'card') ...[
                // Credit Card Representation
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x2A000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.credit_card_rounded, color: Colors.white, size: 28),
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEB001B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(-6, 0),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF79E1B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '••••  ••••  ••••  4242',
                        style: GoogleFonts.spaceMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARD HOLDER',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'SENG SOURNG',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'EXPIRES',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '12/28',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Bank Transfer Representation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bank Name:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                          Text('ABA Bank (USD)', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                        ],
                      ),
                      const Divider(height: 16, color: Color(0xFFE2E8F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Account Number:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                          Text('001 234 567', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      const Divider(height: 16, color: Color(0xFFE2E8F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Account Name:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B))),
                          Text('ECOMMERCE STORE LTD', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Pay & Place Order Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleProceedToCheckout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Authorize & Pay \$${_grandTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderSuccessDialog(String orderNumber, List<CartItemModel> purchasedItems) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your purchase. Your order $orderNumber has been confirmed and paid.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid:',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '\$${_grandTotal.toStringAsFixed(2)} USD',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. PRIMARY ACTION: Rate & Review Products
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    if (purchasedItems.isNotEmpty) {
                      _showProductReviewSelector(purchasedItems);
                    } else {
                      ProductReviewModal.show(
                        context,
                        productId: 1,
                        productName: 'Purchased Item',
                        price: _grandTotal,
                      );
                    }
                  },
                  icon: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                  label: Text(
                    'Rate & Review Products',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // 2. SECONDARY ACTION: View My Orders
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOrdersScreen(showBackButton: true, initialTabIndex: 0),
                      ),
                    );
                  },
                  icon: const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
                  label: Text(
                    'View My Orders',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),

                // 3. TERTIARY ACTION: Continue Shopping
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductReviewSelector(List<CartItemModel> items) {
    if (items.length == 1) {
      final item = items.first;
      ProductReviewModal.show(
        context,
        productId: item.productId,
        productName: item.productName,
        imageUrl: item.imageUrl,
        price: item.unitPrice,
        onReviewSubmitted: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
                'Select Product to Review',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose an item from your recent order to rate:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: item.imageUrl != null
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                                )
                              : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${item.unitPrice.toStringAsFixed(2)} · Qty: ${item.quantity}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ProductReviewModal.show(
                            context,
                            productId: item.productId,
                            productName: item.productName,
                            imageUrl: item.imageUrl,
                            price: item.unitPrice,
                            onReviewSubmitted: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                          );
                        },
                        icon: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
                        label: Text(
                          'Rate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        title: Text(
          'Checkout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            child: Column(
              children: [
                // 1. 4-Step Progress Header
                _buildStepProgressHeader(),

                const SizedBox(height: 16),

                // 2. Shipping Address Section Card
                _buildShippingAddressCard(),

                const SizedBox(height: 16),

                // 3. Shipping Method Section Card
                _buildShippingMethodCard(),

                const SizedBox(height: 16),

                // 4. Payment Method Section Card
                _buildPaymentMethodCard(),

                const SizedBox(height: 16),

                // 5. Order Summary Collapsible Card
                _buildOrderSummaryCard(),
              ],
            ),
          ),

          // 6. Bottom Sticky Checkout Action Bar
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

  // 1. 4-Step Progress Header
  Widget _buildStepProgressHeader() {
    final steps = ['Checkout', 'Shipping', 'Payment', 'Review'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (idx) {
          final stepNum = idx + 1;
          final isCurrent = _currentStep == stepNum;
          final isPast = _currentStep > stepNum;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentStep = stepNum),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (idx > 0)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isPast ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                        ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent || isPast ? AppColors.primary : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isCurrent || isPast ? AppColors.primary : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$stepNum',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isCurrent || isPast ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      if (idx < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isPast ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[idx],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                      color: isCurrent ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 2. Shipping Address Section Card
  Widget _buildShippingAddressCard() {
    final addr = _addresses[_selectedAddressIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Shipping Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAddressIndex = (_selectedAddressIndex + 1) % _addresses.length;
                  });
                },
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Selected Address Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD4BA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio indicator
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 5),
                  ),
                ),
                const SizedBox(width: 10),

                // Home Icon Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Icon(Icons.home_outlined, size: 20, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),

                // Address Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addr['title'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addr['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addr['address'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        addr['phone'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
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

          const SizedBox(height: 12),

          // Add New Address Button (Dashed outline style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Add New Address',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Shipping Method Section Card
  Widget _buildShippingMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Shipping Method',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Options List
          ...List.generate(_shippingMethods.length, (idx) {
            final opt = _shippingMethods[idx];
            final bool isSel = _selectedShippingIndex == idx;

            return GestureDetector(
              onTap: () => setState(() => _selectedShippingIndex = idx),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFFFF6F0) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                    width: isSel ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? AppColors.primary : const Color(0xFFCBD5E1),
                          width: isSel ? 5 : 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            opt['duration'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      opt['priceText'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: opt['price'] == 0 ? const Color(0xFF16A34A) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4. Payment Method Section Card
  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Payment Method',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Options List
          ...List.generate(_paymentMethods.length, (idx) {
            final opt = _paymentMethods[idx];
            final bool isSel = _selectedPaymentIndex == idx;

            return GestureDetector(
              onTap: () => setState(() => _selectedPaymentIndex = idx),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFFFF6F0) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
                    width: isSel ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? AppColors.primary : const Color(0xFFCBD5E1),
                          width: isSel ? 5 : 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            opt['subtitle'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (opt['icon'] != null)
                      Text(opt['icon'], style: const TextStyle(fontSize: 18))
                    else if (opt['id'] == 'card')
                      Row(
                        children: [
                          _buildCardBrandBadge('VISA', const Color(0xFF1A1F71)),
                          const SizedBox(width: 4),
                          _buildCardBrandBadge('MC', const Color(0xFFEB001B)),
                          const SizedBox(width: 4),
                          _buildCardBrandBadge('JCB', const Color(0xFF003087)),
                        ],
                      )
                    else if (opt['id'] == 'ewallet')
                      Row(
                        children: [
                          _buildCardBrandBadge('ABA', const Color(0xFF005E7D)),
                          const SizedBox(width: 4),
                          _buildCardBrandBadge('Wing', const Color(0xFF86B817)),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardBrandBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 5. Order Summary Collapsible Card
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
          // Header with Expand Toggle
          GestureDetector(
            onTap: () => setState(() => _isCartExpanded = !_isCartExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Order Summary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View Cart (${widget.totalItems} Items)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      _isCartExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _buildSummaryRow('Subtotal', '\$${widget.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Shipping', '\$${_shippingCost.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Discount (${widget.couponCode ?? 'WELCOME10'})',
            '- \$${widget.discount.toStringAsFixed(2)}',
            valueColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax (10%)', '\$${_taxAmount.toStringAsFixed(2)}'),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${_grandTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '(USD)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
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
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // 6. Bottom Sticky Checkout Action Bar
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
          // Total on the left
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${_grandTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(USD)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Dynamic Make Payment Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : _onPayButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                shadowColor: const Color(0x66FF6600),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedPaymentIndex == 0
                              ? Icons.local_shipping_outlined
                              : (_selectedPaymentIndex == 1
                                  ? Icons.credit_card_rounded
                                  : (_selectedPaymentIndex == 3 ? Icons.qr_code_2_rounded : Icons.account_balance_outlined)),
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedPaymentIndex == 0
                              ? 'Place Order'
                              : (_selectedPaymentIndex == 1
                                  ? 'Pay Now'
                                  : (_selectedPaymentIndex == 3 ? 'Pay with ABA' : 'Make Payment')),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
