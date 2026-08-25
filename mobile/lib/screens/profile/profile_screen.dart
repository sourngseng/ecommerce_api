import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../orders/my_orders_screen.dart';
import '../wishlist/wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToOrders;

  const ProfileScreen({
    super.key,
    this.onNavigateToOrders,
  });

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
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You have 3 unread notifications'), duration: Duration(seconds: 3)),
                  );
                },
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
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App Settings opened'), duration: Duration(seconds: 3)),
              );
            },
            icon: const Icon(Icons.settings_outlined, size: 22, color: Color(0xFF1E293B)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
            _buildSettingsMenuList(context),

            const SizedBox(height: 20),

            // 5. Logout Button
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  // 1. User Profile Card
  Widget _buildUserProfileCard(BuildContext context, String userName, String userEmail) {
    return Container(
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
    );
  }

  // 2. 4 Quick Stats Grid
  Widget _buildQuickStatsCard(BuildContext context) {
    final stats = [
      {'icon': Icons.shopping_bag_outlined, 'color': AppColors.primary, 'count': '12', 'label': 'Orders'},
      {'icon': Icons.favorite_border_rounded, 'color': const Color(0xFFEF4444), 'count': '8', 'label': 'Wishlist'},
      {'icon': Icons.confirmation_number_outlined, 'color': const Color(0xFF0284C7), 'count': '3', 'label': 'Coupons'},
      {'icon': Icons.star_outline_rounded, 'color': const Color(0xFFF59E0B), 'count': '120', 'label': 'Reward Points'},
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
                if (onNavigateToOrders != null) {
                  onNavigateToOrders!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersScreen(showBackButton: true)),
                  );
                }
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
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'To Pay', 'badge': '1'},
      {'icon': Icons.access_time_rounded, 'label': 'Processing', 'badge': '2'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Shipped', 'badge': '1'},
      {'icon': Icons.check_circle_outline_rounded, 'label': 'Delivered', 'badge': '6'},
      {'icon': Icons.cancel_outlined, 'label': 'Cancelled', 'badge': '1'},
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
                onTap: () {
                  if (onNavigateToOrders != null) {
                    onNavigateToOrders!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyOrdersScreen(showBackButton: true)),
                    );
                  }
                },
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
              return GestureDetector(
                onTap: () {
                  if (onNavigateToOrders != null) {
                    onNavigateToOrders!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyOrdersScreen(showBackButton: true)),
                    );
                  }
                },
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
                                sc['badge'] as String,
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
                      sc['label'] as String,
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
  Widget _buildSettingsMenuList(BuildContext context) {
    final menuItems = [
      {'icon': Icons.person_outline_rounded, 'color': const Color(0xFF8B5CF6), 'title': 'Personal Information'},
      {'icon': Icons.location_on_outlined, 'color': const Color(0xFF10B981), 'title': 'Addresses'},
      {'icon': Icons.credit_card_outlined, 'color': const Color(0xFF0284C7), 'title': 'Payment Methods'},
      {'icon': Icons.confirmation_number_outlined, 'color': AppColors.primary, 'title': 'My Coupons'},
      {'icon': Icons.star_outline_rounded, 'color': const Color(0xFFF59E0B), 'title': 'Reward Points'},
      {'icon': Icons.notifications_none_rounded, 'color': const Color(0xFFEF4444), 'title': 'Notifications'},
      {'icon': Icons.headset_mic_outlined, 'color': const Color(0xFF10B981), 'title': 'Help & Support'},
      {'icon': Icons.info_outline_rounded, 'color': const Color(0xFF0284C7), 'title': 'About Us'},
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
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['title']} section opened'), duration: const Duration(seconds: 3)),
                  );
                },
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
}
