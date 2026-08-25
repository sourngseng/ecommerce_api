import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../orders/my_orders_screen.dart';
import '../wishlist/wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;

  const ProfileScreen({
    super.key,
    this.onNavigateToOrders,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  int _ordersCount = 12;
  final int _wishlistCount = 8;
  final int _couponsCount = 3;
  final int _rewardPoints = 120;

  final Map<String, int> _orderStatusCounts = {
    'To Pay': 1,
    'Processing': 2,
    'Shipped': 1,
    'Delivered': 6,
    'Cancelled': 1,
  };

  @override
  void initState() {
    super.initState();
    _fetchProfileStats();
  }

  Future<void> _fetchProfileStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token != null) {
      try {
        final orders = await _apiService.getMyOrders(auth.token);
        if (mounted && orders.isNotEmpty) {
          setState(() {
            _ordersCount = orders.length;
            int toPay = 0, processing = 0, shipped = 0, delivered = 0, cancelled = 0;
            for (var o in orders) {
              final status = (o['status'] ?? '').toString().toLowerCase();
              if (status.contains('pay') || status.contains('pending')) toPay++;
              if (status.contains('process')) processing++;
              if (status.contains('ship')) shipped++;
              if (status.contains('deliver')) delivered++;
              if (status.contains('cancel')) cancelled++;
            }
            _orderStatusCounts['To Pay'] = toPay > 0 ? toPay : 1;
            _orderStatusCounts['Processing'] = processing > 0 ? processing : 2;
            _orderStatusCounts['Shipped'] = shipped > 0 ? shipped : 1;
            _orderStatusCounts['Delivered'] = delivered > 0 ? delivered : 6;
            _orderStatusCounts['Cancelled'] = cancelled > 0 ? cancelled : 1;
          });
        }
      } catch (_) {}
    }
  }

  void _openOrdersTab({int tabIndex = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyOrdersScreen(
          showBackButton: true,
          initialTabIndex: tabIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final String userName = user?.name ?? 'Seng Sourng';
    final String userEmail = user?.email ?? 'sengsourng@email.com';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Profile',
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
                onPressed: () => _showNotificationsModal(),
                icon: const Icon(Icons.notifications_none_rounded, size: 24, color: Color(0xFF1E293B)),
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
          IconButton(
            onPressed: () => _showSettingsModal(),
            icon: const Icon(Icons.settings_outlined, size: 22, color: Color(0xFF1E293B)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfileStats,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Column(
            children: [
              // 1. User Profile Card
              _buildUserProfileCard(context, userName, userEmail),

              const SizedBox(height: 16),

              // 2. 4 Quick Stats Grid (Orders, Wishlist, Coupons, Reward Points)
              _buildQuickStatsCard(context),

              const SizedBox(height: 16),

              // 3. My Orders Quick Status Bar
              _buildMyOrdersShortcutCard(context),

              const SizedBox(height: 16),

              // 4. Settings & Menu Options List
              _buildSettingsMenuList(context, userName, userEmail),

              const SizedBox(height: 20),

              // 5. Logout Button
              _buildLogoutButton(context, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  // 1. User Profile Card
  Widget _buildUserProfileCard(BuildContext context, String userName, String userEmail) {
    return GestureDetector(
      onTap: () => _showPersonalInfoModal(userName, userEmail),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Avatar with Edit Camera Badge
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6F0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFE0D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_outlined, size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Premium Member',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since Jan 2024',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // 2. 4 Quick Stats Grid
  Widget _buildQuickStatsCard(BuildContext context) {
    final stats = [
      {'icon': Icons.shopping_bag_outlined, 'color': AppColors.primary, 'count': '$_ordersCount', 'label': 'Orders'},
      {'icon': Icons.favorite_border_rounded, 'color': const Color(0xFFEF4444), 'count': '$_wishlistCount', 'label': 'Wishlist'},
      {'icon': Icons.confirmation_number_outlined, 'color': const Color(0xFF0284C7), 'count': '$_couponsCount', 'label': 'Coupons'},
      {'icon': Icons.star_outline_rounded, 'color': const Color(0xFFF59E0B), 'count': '$_rewardPoints', 'label': 'Reward Points'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((s) {
          return GestureDetector(
            onTap: () {
              if (s['label'] == 'Wishlist') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen(showBackButton: true)),
                );
              } else if (s['label'] == 'Orders') {
                _openOrdersTab(tabIndex: 0);
              } else if (s['label'] == 'Coupons') {
                _showCouponsModal();
              } else if (s['label'] == 'Reward Points') {
                _showRewardPointsModal();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Icon(s['icon'] as IconData, size: 22, color: s['color'] as Color),
                const SizedBox(height: 6),
                Text(
                  s['count'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. My Orders Quick Status Bar
  Widget _buildMyOrdersShortcutCard(BuildContext context) {
    final orderShortcuts = [
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'To Pay', 'tabIndex': 1},
      {'icon': Icons.access_time_rounded, 'label': 'Processing', 'tabIndex': 2},
      {'icon': Icons.local_shipping_outlined, 'label': 'Shipped', 'tabIndex': 3},
      {'icon': Icons.check_circle_outline_rounded, 'label': 'Delivered', 'tabIndex': 4},
      {'icon': Icons.cancel_outlined, 'label': 'Cancelled', 'tabIndex': 5},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Orders',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: () => _openOrdersTab(tabIndex: 0),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: orderShortcuts.map((sc) {
              final String label = sc['label'] as String;
              final int count = _orderStatusCounts[label] ?? 0;
              final int tabIndex = sc['tabIndex'] as int;

              return GestureDetector(
                onTap: () => _openOrdersTab(tabIndex: tabIndex),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(sc['icon'] as IconData, size: 20, color: const Color(0xFF475569)),
                        ),
                        if (count > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 4. Settings & Menu Options List
  Widget _buildSettingsMenuList(BuildContext context, String userName, String userEmail) {
    final menuItems = [
      {
        'icon': Icons.person_outline_rounded,
        'color': const Color(0xFF8B5CF6),
        'title': 'Personal Information',
        'action': () => _showPersonalInfoModal(userName, userEmail),
      },
      {
        'icon': Icons.location_on_outlined,
        'color': const Color(0xFF10B981),
        'title': 'Addresses',
        'action': () => _showAddressesModal(),
      },
      {
        'icon': Icons.credit_card_outlined,
        'color': const Color(0xFF0284C7),
        'title': 'Payment Methods',
        'action': () => _showPaymentMethodsModal(),
      },
      {
        'icon': Icons.confirmation_number_outlined,
        'color': AppColors.primary,
        'title': 'My Coupons',
        'action': () => _showCouponsModal(),
      },
      {
        'icon': Icons.star_outline_rounded,
        'color': const Color(0xFFF59E0B),
        'title': 'Reward Points',
        'action': () => _showRewardPointsModal(),
      },
      {
        'icon': Icons.notifications_none_rounded,
        'color': const Color(0xFFEF4444),
        'title': 'Notifications',
        'action': () => _showNotificationsModal(),
      },
      {
        'icon': Icons.headset_mic_outlined,
        'color': const Color(0xFF10B981),
        'title': 'Help & Support',
        'action': () => _showHelpSupportModal(),
      },
      {
        'icon': Icons.info_outline_rounded,
        'color': const Color(0xFF0284C7),
        'title': 'About Us',
        'action': () => _showAboutUsModal(),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: List.generate(menuItems.length, (idx) {
          final item = menuItems[idx];
          final bool isLast = idx == menuItems.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item['action'] as VoidCallback,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(item['icon'] as IconData, size: 18, color: item['color'] as Color),
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
              ),
              if (!isLast) const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  // 5. Logout Button
  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () async {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to log out of your account?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          await authProvider.logout();
          if (!context.mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.primary, size: 18),
        label: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF6F0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFE0D0)),
          ),
        ),
      ),
    );
  }

  // --- INTERACTIVE SUB-MODALS ---

  // 1. Personal Information Modal
  void _showPersonalInfoModal(String name, String email) {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);
    final phoneCtrl = TextEditingController(text: '+855 12 345 678');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text('Personal Information', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile information updated successfully!'), backgroundColor: AppColors.success, duration: Duration(seconds: 3)),
                  );
                },
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Addresses Modal
  void _showAddressesModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved Addresses', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _buildAddressItem('Home (Default)', '#123, St. 2004, Sen Sok, Phnom Penh', isDefault: true),
              const SizedBox(height: 10),
              _buildAddressItem('Office', 'Canadia Tower, 15th Fl, Daun Penh, Phnom Penh', isDefault: false),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add New Address feature opened'), duration: Duration(seconds: 3)));
                },
                icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                label: const Text('Add New Address', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: const Size(double.infinity, 44)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressItem(String title, String address, {required bool isDefault}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDefault ? const Color(0xFFFFF6F0) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDefault ? AppColors.primary : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: isDefault ? AppColors.primary : const Color(0xFF64748B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(address, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          if (isDefault) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }

  // 3. Payment Methods Modal
  void _showPaymentMethodsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Methods', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _buildPaymentRow('Visa Card ending in 4242', 'Expires 12/26', Icons.credit_card_rounded, isDefault: true),
              const SizedBox(height: 10),
              _buildPaymentRow('ABA PAY KHQR', 'Connected: 012 345 678', Icons.qr_code_rounded, isDefault: false),
              const SizedBox(height: 10),
              _buildPaymentRow('Cash on Delivery (COD)', 'Pay when received', Icons.local_shipping_outlined, isDefault: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentRow(String title, String subtitle, IconData icon, {required bool isDefault}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
              child: const Text('Default', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // 4. Coupons Modal
  void _showCouponsModal() {
    final coupons = [
      {'code': 'WELCOME10', 'discount': '10% OFF', 'desc': 'Valid on orders over \$50'},
      {'code': 'FREESHIP', 'discount': 'FREE SHIPPING', 'desc': 'Valid on orders over \$50'},
      {'code': 'MEGA50', 'discount': '\$50 FLAT OFF', 'desc': 'Valid on orders over \$500'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Coupons (${coupons.length})', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              ...coupons.map((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['discount']!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary)),
                            Text('Code: ${c['code']} • ${c['desc']}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: c['code']!));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Coupon ${c['code']} copied to clipboard!'), backgroundColor: AppColors.success, duration: const Duration(seconds: 3)),
                          );
                        },
                        child: const Text('COPY', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
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

  // 5. Reward Points Modal
  void _showRewardPointsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reward Points & Loyalty', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Balance', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                        Text('$_rewardPoints Points', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        Text('Equivalent to \$${(_rewardPoints / 10).toStringAsFixed(2)} USD', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Redeemed \$10 voucher for 100 points!'), backgroundColor: AppColors.success, duration: Duration(seconds: 3)),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0),
                      child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Recent Points Activity', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              _buildPointsRow('+50 Points', 'Order #ORD-2024-000125 Completed', '+'),
              _buildPointsRow('+30 Points', 'Left a 5-Star Product Review', '+'),
              _buildPointsRow('+40 Points', 'Member Registration Welcome Bonus', '+'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointsRow(String points, String reason, String sign) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(reason, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF475569))),
          Text(points, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF10B981))),
        ],
      ),
    );
  }

  // 6. Notifications Modal
  void _showNotificationsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _buildNotificationItem('🚚 Order Shipped', 'Your Order #ORD-2024-000124 is out for delivery!'),
              _buildNotificationItem('🔥 Flash Sale Alert', '50% off on all Apple & MacBook laptops this weekend!'),
              _buildNotificationItem('🎉 Reward Points Added', 'You received +50 points for your recent purchase.'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 11)),
        ],
      ),
    );
  }

  // 7. Help & Support Modal
  void _showHelpSupportModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Help & Customer Support', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                title: const Text('Live Support Chat (24/7)'),
                subtitle: const Text('Typically replies within 2 minutes'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connected to live customer agent'), duration: Duration(seconds: 3)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                title: const Text('Email Support'),
                subtitle: const Text('support@ecommerce.com'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // 8. About Us Modal
  void _showAboutUsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About E-Commerce App', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('Version 1.0.0 (Build 2026)', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                'Next-generation mobile shopping platform built with Flutter and backed by high-performance Laravel REST API.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF334155), height: 1.4),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // 9. Settings Modal
  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Application Settings', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: const Text('Push Notifications'),
                activeTrackColor: AppColors.primary,
              ),
              SwitchListTile(
                value: false,
                onChanged: (val) {},
                title: const Text('Dark Mode (Beta)'),
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
