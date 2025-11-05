import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for 1.5 seconds
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Scale animation for the flag
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Start animation
    _controller.forward();

    // Navigate to onboarding after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pink Flag Icon
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: PinkFlagPainter(),
                  ),
                  const SizedBox(height: 32),

                  // PINK FLAG Text
                  const Text(
                    'PINK FLAG',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  const Text(
                    'Stay Safe, Stay Aware',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: Color(0xFF666666),
                    ),
                  ),
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

    canvas.drawShadow(shadowPath, AppColors.primaryPink.withOpacity(0.3), 8, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
