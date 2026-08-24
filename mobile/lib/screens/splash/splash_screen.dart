import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shopping_bag_icon.dart';
import '../../core/widgets/wave_background.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Wait for animation & auth initialization
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final results = await Future.wait([
      authProvider.initialize(),
      Future.delayed(const Duration(milliseconds: 2600)),
    ]);

    if (!mounted) return;

    final isLoggedIn = results[0] as bool;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background soft shopping watermarks
          Positioned(
            top: size.height * 0.12,
            right: 24,
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 44,
              color: Color(0x1F9E9E9E),
            ),
          ),
          Positioned(
            top: size.height * 0.22,
            left: 36,
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 38,
              color: Color(0x1A9E9E9E),
            ),
          ),
          Positioned(
            top: size.height * 0.23,
            right: 48,
            child: const Icon(
              Icons.local_offer_outlined,
              size: 36,
              color: Color(0x1A9E9E9E),
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            right: 32,
            child: const Icon(
              Icons.headphones_outlined,
              size: 32,
              color: Color(0x149E9E9E),
            ),
          ),

          // Central Hero Illustration and Typography
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shopping Bag with Cart Icon
                    const ShoppingBagIcon(size: 160),

                    const SizedBox(height: 28),

                    // "E-Commerce" Title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'E-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Commerce',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Shop Everything\nYou Love',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Pagination indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xCCCBD5E1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xCCCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Curved Orange Wave with Loading Spinner
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomCurvedWave(
              height: size.height * 0.24,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Loading your experience...',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
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
}
