import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller for 2 seconds
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Glow animation controller (continuous pulse)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale animation for the flag with bounce
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Subtle rotation animation
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _controller.forward();

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
        print('✅ [SPLASH] Navigating to home screen');
      }
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // No user authenticated → show onboarding flow
      if (kDebugMode) {
        print('ℹ️ [SPLASH] No user authenticated');
        print('ℹ️ [SPLASH] Navigating to onboarding');
      }
      Navigator.of(context).pushReplacementNamed('/onboarding');
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
              const Color(0xFFF5EBE0), // Cream from logo
              const Color(0xFFFFF7F0), // Lighter cream
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pink Flag Icon with enhanced animations
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
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
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // PINK FLAG Text with shimmer and hero animation
                Hero(
                  tag: 'app_title',
                  child: Material(
                    color: Colors.transparent,
                    child:
                        Text(
                              'PINK FLAG',
                              style: AppTextStyles.displayLargePrimary,
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tagline with delayed fade-in
                Text('Stay Safe, Stay Aware', style: AppTextStyles.tagline)
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
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
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    // Draw flag pole (gray)
    final polePaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.2, size.height * 0.9),
      polePaint,
    );

    // Draw flag with gradient (hot pink to soft pink)
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
        AppColors.deepPink, // Hot pink
        AppColors.primaryPink,
        AppColors.softPink, // Soft pink
      ],
    );

    paint.shader = gradient.createShader(rect);

    // Draw triangular flag shape
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.15); // Top of pole
    path.lineTo(size.width * 0.7, size.height * 0.25); // Right point
    path.lineTo(size.width * 0.2, size.height * 0.5); // Bottom of flag on pole
    path.close();

    canvas.drawPath(path, paint);

    // Add subtle shadow
    final shadowPath = Path();
    shadowPath.moveTo(size.width * 0.2, size.height * 0.15);
    shadowPath.lineTo(size.width * 0.7, size.height * 0.25);
    shadowPath.lineTo(size.width * 0.2, size.height * 0.5);
    shadowPath.close();

    canvas.drawShadow(
      shadowPath,
      AppColors.primaryPink.withValues(alpha: 0.3),
      8,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
