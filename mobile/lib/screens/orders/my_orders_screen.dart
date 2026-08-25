import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../reviews/write_review_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final bool showBackButton;
  final int initialTabIndex;

  const MyOrdersScreen({
    super.key,
    this.showBackButton = false,
    this.initialTabIndex = 0,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late int _selectedTabIdx;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  List<OrderModel> _liveOrders = [];

  final List<String> _tabs = [
    'All Orders',
    'To Pay',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIdx = widget.initialTabIndex;
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final tabKey = _tabs[_selectedTabIdx].toLowerCase().replaceAll(' ', '_');
      final fetched = await _apiService.getMyOrders(
        authProvider.token,
        status: tabKey == 'all_orders' ? null : tabKey,
      );

      if (mounted) {
        setState(() {
          _liveOrders = fetched.map((json) => OrderModel.fromJson(json)).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liveOrders = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCancelOrder(OrderModel order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Text('Are you sure you want to cancel Order #${order.orderNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Order')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _apiService.cancelOrder(authProvider.token, order.id);

    if (!mounted) return;
    setState(() {
      final idx = _liveOrders.indexWhere((o) => o.id == order.id);
      if (idx != -1) {
        _liveOrders[idx] = OrderModel(
          id: order.id,
          orderNumber: order.orderNumber,
          status: 'cancelled',
          statusLabel: 'Cancelled',
          statusSubtitle: 'Cancelled',
          statusDesc: 'This order has been cancelled.',
          subtotal: order.subtotal,
          discount: order.discount,
          tax: order.tax,
          shipping: order.shipping,
          total: order.total,
          createdAt: order.createdAt,
          items: order.items,
          thumbnails: order.thumbnails,
          extraCount: order.extraCount,
        );
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${order.orderNumber} cancelled successfully'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleBuyAgain(OrderModel order) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (order.items.isNotEmpty) {
      for (var item in order.items) {
        await cart.addToCart(
          auth.token,
          item.productId,
          item.quantity,
          productFallback: {
            'name': item.productName,
            'price': item.unitPrice,
            'image_url': item.imageUrl,
          },
        );
      }
    } else {
      // Re-add default order products
      await cart.addToCart(auth.token, 101, 1);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added items from #${order.orderNumber} to cart!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen(showBackButton: true)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _liveOrders.where((o) {
      if (_selectedTabIdx != 0) {
        final currentFilter = _tabs[_selectedTabIdx].toLowerCase().replaceAll(' ', '_');
        if (currentFilter == 'to_pay') {
          if (o.status != 'pending' && o.status != 'unpaid' && o.status != 'to_pay') return false;
        } else if (currentFilter == 'processing') {
          if (o.status != 'processing' && o.status != 'confirmed') return false;
        } else if (o.status != currentFilter) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        return o.orderNumber.toLowerCase().contains(_searchQuery);
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
                  hintText: 'Search order number...',
                  border: InputBorder.none,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Orders',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Track and manage your orders',
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
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Status Tabs Bar
          _buildStatusTabBar(),

          // 2. Orders List with Pull-to-Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchOrders,
              color: AppColors.primary,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filteredOrders.isEmpty
                      ? _buildEmptyOrdersView()
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _buildOrderCard(filteredOrders[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Status Filter Tabs Bar
  Widget _buildStatusTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final bool isSelected = _selectedTabIdx == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedTabIdx = index);
              _fetchOrders();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. Order Card Builder
  Widget _buildOrderCard(OrderModel order) {
    final String status = order.status;

    Color statusColor = const Color(0xFF10B981);
    Widget statusIcon = const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981));
    IconData boxIconData = Icons.inventory_2_outlined;
    Color boxBg = const Color(0xFFECFDF5);
    Color boxColor = const Color(0xFF10B981);

    if (status == 'shipped') {
      statusColor = const Color(0xFF0284C7);
      statusIcon = const Icon(Icons.local_shipping_rounded, size: 14, color: Color(0xFF0284C7));
      boxIconData = Icons.local_shipping_outlined;
      boxBg = const Color(0xFFF0F9FF);
      boxColor = const Color(0xFF0284C7);
    } else if (status == 'processing' || status == 'confirmed') {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFF59E0B));
      boxIconData = Icons.inventory_2_outlined;
      boxBg = const Color(0xFFFFFBEB);
      boxColor = const Color(0xFFF59E0B);
    } else if (status == 'cancelled') {
      statusColor = const Color(0xFF94A3B8);
      statusIcon = const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFF94A3B8));
      boxIconData = Icons.cancel_outlined;
      boxBg = const Color(0xFFF1F5F9);
      boxColor = const Color(0xFF94A3B8);
    } else if (status == 'pending' || status == 'to_pay' || status == 'unpaid') {
      statusColor = const Color(0xFFF97316);
      statusIcon = const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFFF97316));
      boxIconData = Icons.account_balance_wallet_outlined;
      boxBg = const Color(0xFFFFF7ED);
      boxColor = const Color(0xFFF97316);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order Number & Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  Text(
                    order.statusLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  statusIcon,
                  const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Created timestamp
          Text(
            order.createdAt,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(height: 12),

          // Status Description Box & Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: boxBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(boxIconData, size: 18, color: boxColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.statusSubtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.statusDesc,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '${order.itemsCount} ${order.itemsCount > 1 ? 'Items' : 'Item'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Product Thumbnails Row (if any)
          if (order.thumbnails.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ...order.thumbnails.map((img) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        img,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.laptop_chromebook, size: 24, color: Colors.grey),
                      ),
                    ),
                  );
                }),
                if (order.extraCount > 0)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '+${order.extraCount}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons Row
          Row(
            children: [
              // View Details
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showOrderDetailsModal(order);
                  },
                  icon: const Icon(Icons.description_outlined, size: 15, color: Color(0xFF1E293B)),
                  label: Text(
                    'View Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Contextual Action Button (Buy Again, Track Order, Cancel Order)
              Expanded(
                child: _buildContextualActionButton(order),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContextualActionButton(OrderModel order) {
    final String status = order.status;

    if (status == 'delivered') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showOrderReviewSelector(order),
              icon: const Icon(Icons.star_rounded, size: 15, color: Colors.white),
              label: Text(
                'Review',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleBuyAgain(order),
              icon: const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
              label: Text(
                'Buy Again',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'shipped') {
      return ElevatedButton.icon(
        onPressed: () {
          _showTrackingModal(order);
        },
        icon: const Icon(Icons.location_on_outlined, size: 15, color: AppColors.primary),
        label: Text(
          'Track Order',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF6F0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      );
    } else if (status == 'processing' || status == 'confirmed') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showOrderReviewSelector(order),
              icon: const Icon(Icons.star_rounded, size: 15, color: Colors.white),
              label: Text(
                'Rate Item',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleCancelOrder(order),
              icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
              label: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF1F2),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'pending') {
      return ElevatedButton.icon(
        onPressed: () => _handleCancelOrder(order),
        icon: const Icon(Icons.close_rounded, size: 15, color: Color(0xFFEF4444)),
        label: Text(
          'Cancel Order',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF1F2),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      );
    }

    return Container();
  }

  void _showOrderReviewSelector(OrderModel order) {
    final reviewItems = order.items.map((i) => ReviewItemData(
      productId: i.productId,
      productName: i.productName,
      imageUrl: i.imageUrl,
      price: i.unitPrice,
      quantity: i.quantity,
    )).toList();

    if (reviewItems.isEmpty) {
      reviewItems.add(ReviewItemData(
        productId: 1,
        productName: 'Ordered Product',
        price: order.total,
        quantity: 1,
      ));
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          orderNumber: order.orderNumber,
          items: reviewItems,
        ),
      ),
    );
  }

  void _showOrderDetailsModal(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
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
                'Order Details',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text('Order Number: #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Status: ${order.statusLabel}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Placed On: ${order.createdAt}'),
              const SizedBox(height: 6),
              Text('Total Amount: \$${order.total.toStringAsFixed(2)} USD', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              if (order.shippingAddress != null) ...[
                const SizedBox(height: 10),
                const Divider(),
                Text('Shipping Address:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${order.shippingAddress!['recipient_name'] ?? 'Recipient'}\n${order.shippingAddress!['address_line_1'] ?? ''}, ${order.shippingAddress!['city'] ?? 'Phnom Penh'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
              if (order.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                Text('Purchased Items:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.productName} (x${item.quantity})', style: const TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showOrderReviewSelector(order);
                        },
                        icon: const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        label: Text('Rate & Review', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                      ),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTrackingModal(OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Tracking: #${order.orderNumber}',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _buildTrackingStep('Order Placed', order.createdAt, isDone: true),
              _buildTrackingStep('Processing in Warehouse', 'Confirmed & Packaged', isDone: true),
              _buildTrackingStep('Shipped with Carrier (Phnom Penh Logistics Hub)', 'In Transit', isDone: true),
              _buildTrackingStep('Out for Delivery', 'Estimated delivery today', isDone: false),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackingStep(String title, String subtitle, {required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isDone ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 72, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'No Orders Found',
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any orders in this category yet.',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
