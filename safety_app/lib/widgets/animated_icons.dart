import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Collection of animated icons for success, error, warning, and info states
class AnimatedIcons {
  /// Animated success checkmark icon
  /// Shows a circular checkmark with scale and fade animation
  static Widget success({double size = 80, Color? color, Duration? duration}) {
    return _AnimatedStatusIcon(
      icon: Icons.check_circle,
      color: color ?? Colors.green,
      size: size,
      duration: duration ?? const Duration(milliseconds: 600),
    );
  }

  /// Animated error icon
  /// Shows a circular X with shake and scale animation
  static Widget error({double size = 80, Color? color, Duration? duration}) {
    return _AnimatedStatusIcon(
      icon: Icons.error,
      color: color ?? AppColors.deepPink,
      size: size,
      duration: duration ?? const Duration(milliseconds: 600),
      shake: true,
    );
  }

  /// Animated warning icon
  /// Shows a warning triangle with pulse animation
  static Widget warning({double size = 80, Color? color, Duration? duration}) {
    return _AnimatedStatusIcon(
      icon: Icons.warning_amber,
      color: color ?? Colors.orange,
      size: size,
      duration: duration ?? const Duration(milliseconds: 600),
      pulse: true,
    );
  }

  /// Animated info icon
  /// Shows an info circle with fade and scale animation
  static Widget info({double size = 80, Color? color, Duration? duration}) {
    return _AnimatedStatusIcon(
      icon: Icons.info,
      color: color ?? AppColors.primaryPink,
      size: size,
      duration: duration ?? const Duration(milliseconds: 600),
    );
  }

  /// Animated loading spinner
  /// Shows a circular progress indicator with rotation
  static Widget loading({double size = 60, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryPink,
        ),
      ),
    );
  }
}

class _AnimatedStatusIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;
  final bool shake;
  final bool pulse;

  const _AnimatedStatusIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.duration,
    this.shake = false,
    this.pulse = false,
  });

  @override
  State<_AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(widget.icon, size: widget.size * 0.6, color: widget.color),
    );

    // Apply animations
    if (widget.shake) {
      iconWidget = iconWidget
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .shake(duration: 500.ms, hz: 3, curve: Curves.easeInOut);
    } else if (widget.pulse) {
      iconWidget = iconWidget
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(duration: 300.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 1000.ms,
          );
    } else {
      iconWidget = ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(opacity: _fadeAnimation, child: iconWidget),
      );
    }

    return iconWidget;
  }
}

/// Simple animated checkmark for inline use
class AnimatedCheckmark extends StatelessWidget {
  final double size;
  final Color color;

  const AnimatedCheckmark({
    super.key,
    this.size = 24,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.check_circle, size: size, color: color)
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }
}

/// Simple animated error X for inline use
class AnimatedErrorIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AnimatedErrorIcon({super.key, this.size = 24, this.color = Colors.red});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error,
      size: size,
      color: color,
    ).animate().shake(duration: 400.ms, hz: 4).fadeIn(duration: 200.ms);
  }
}
