import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/revenuecat_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller for 1.6 seconds (tighter timing)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // Glow animation controller (single pulse)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale animation for the flag with gentle ease
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _controller.forward();
    _glowController.forward(); // Single glow pulse

    // Navigate based on authentication state after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      _navigateToNextScreen();
    });
  }

  /// Navigate to the appropriate screen based on auth state
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Check if user is authenticated (Supabase handles persistence automatically)
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser != null) {
      // User is logged in → skip onboarding and login, go straight to home
      if (kDebugMode) {
        print('✅ [SPLASH] User authenticated: ${currentUser.id}');
        print('✅ [SPLASH] Email: ${currentUser.email}');
      }

      // CRITICAL: Initialize RevenueCat for existing session
      // Without this, purchases are attributed to anonymous/wrong user
      // See: RevenueCat purchase attribution fix (Jan 2026)
      try {
        if (kDebugMode) {
          print('🛒 [SPLASH] Initializing RevenueCat for existing session...');
        }
        await RevenueCatService().initialize(currentUser.id);
        if (kDebugMode) {
          print('✅ [SPLASH] RevenueCat initialized with user: ${currentUser.id}');
        }
      } catch (e) {
        // Don't block navigation if RC init fails - user can still use app
        // Purchases may not work correctly but app remains functional
        if (kDebugMode) {
          print('⚠️ [SPLASH] RevenueCat init failed: $e');
        }
      }

      if (kDebugMode) {
        print('✅ [SPLASH] Navigating to home screen');
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // No user authenticated → show onboarding flow
      if (kDebugMode) {
        print('ℹ️ [SPLASH] No user authenticated');
        print('ℹ️ [SPLASH] Navigating to onboarding');
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.softWhite,  // Warm white top
              AppColors.lightPink,  // Soft blush middle
              AppColors.rose,       // Gentle blush bottom
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Pink Flag Icon with radial vignette and subtle glow
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.softPink.withValues(alpha: 0.15),
                              AppColors.lightPink.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withValues(
                                    alpha: 0.3 + (_glowController.value * 0.3),
                                  ),
                                  blurRadius: 30 + (_glowController.value * 20),
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              size: const Size(140, 140),
                              painter: PinkFlagPainter(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // PINK FLAG Text with single shimmer pass
                Hero(
                  tag: 'app_title',
                  child: Material(
                    color: Colors.transparent,
                    child:
                        Text(
                              'PINK FLAG',
                              style: AppTextStyles.displayLargePrimary,
                            )
                            .animate()
                            .shimmer(
                              delay: 800.ms,
                              duration: 800.ms,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tagline with delayed fade-in
                Text('Stay Safe, Stay Aware', style: AppTextStyles.tagline)
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 40),

                // Status line with subtle loading indicator
                Text(
                  'Preparing your account…',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText.withValues(alpha: 0.6),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1000.ms),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PinkFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw flag pole with subtle vertical gradient for depth
    final poleRect = Rect.fromLTWH(
      size.width * 0.2 - 2,
      size.height * 0.1,
      4,
      size.height * 0.8,
    );

    final poleGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF9CA3AF), // Lighter gray top
        const Color(0xFF6B7280), // Medium gray middle
        const Color(0xFF4B5563), // Darker gray base
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final polePaint = Paint()
      ..shader = poleGradient.createShader(poleRect)
      ..style = PaintingStyle.fill;

    // Draw pole with rounded ends
    canvas.drawRRect(
      RRect.fromRectAndRadius(poleRect, const Radius.circular(2)),
      polePaint,
    );

    // Draw flag with gradient and rounded corners
    final rect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.35,
    );

    // Create gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.deepPink,
        AppColors.primaryPink,
        AppColors.softPink,
      ],
    );

    final flagPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw triangular flag shape with rounded corners
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.15); // Top of pole
    path.lineTo(size.width * 0.68, size.height * 0.24); // Before right point
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.25, // Control point (right point)
      size.width * 0.68, size.height * 0.26, // After right point
    );
    path.lineTo(size.width * 0.2, size.height * 0.5); // Bottom of flag on pole
    path.close();

    // Add subtle shadow
    canvas.drawShadow(
      path,
      AppColors.primaryPink.withValues(alpha: 0.3),
      8,
      false,
    );

    canvas.drawPath(path, flagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
