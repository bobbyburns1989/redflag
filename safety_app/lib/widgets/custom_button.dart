import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_animations.dart';

enum ButtonVariant { primary, secondary, outlined, text }
enum ButtonSize { small, medium, large }

/// Custom button with animations, haptic feedback, and multiple variants
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool iconRight;
  final double? width;
  final bool enableHaptic;
  final Gradient? customGradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.iconRight = false,
    this.width,
    this.enableHaptic = true,
    this.customGradient,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: AppAnimations.scaleNormal,
      end: AppAnimations.scalePressed,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.buttonCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _handleTap,
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    switch (widget.variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(isDisabled);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(isDisabled);
      case ButtonVariant.outlined:
        return _buildOutlinedButton(isDisabled);
      case ButtonVariant.text:
        return _buildTextButton(isDisabled);
    }
  }

  Widget _buildPrimaryButton(bool isDisabled) {
    return Container(
      width: widget.width,
      height: _getButtonHeight(),
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : (widget.customGradient ?? AppColors.pinkGradient),
        color: isDisabled ? AppColors.lightPink : null,
        borderRadius: AppDimensions.borderRadiusMd,
        boxShadow: isDisabled ? null : AppColors.softPinkShadow,
      ),
      child: _buildButtonContent(
        textColor: isDisabled ? AppColors.mediumText : Colors.white,
        iconColor: isDisabled ? AppColors.mediumText : Colors.white,
      ),
    );
  }

  Widget _buildSecondaryButton(bool isDisabled) {
    return Container(
      width: widget.width,
      height: _getButtonHeight(),
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.lightPink : AppColors.softPink,
        borderRadius: AppDimensions.borderRadiusMd,
        boxShadow: isDisabled ? null : AppColors.subtleShadow,
      ),
      child: _buildButtonContent(
        textColor: isDisabled ? AppColors.mediumText : AppColors.deepPink,
        iconColor: isDisabled ? AppColors.mediumText : AppColors.deepPink,
      ),
    );
  }

  Widget _buildOutlinedButton(bool isDisabled) {
    return Container(
      width: widget.width,
      height: _getButtonHeight(),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isDisabled ? AppColors.lightPink : AppColors.primaryPink,
          width: AppDimensions.borderWidthMedium,
        ),
        borderRadius: AppDimensions.borderRadiusMd,
      ),
      child: _buildButtonContent(
        textColor: isDisabled ? AppColors.mediumText : AppColors.primaryPink,
        iconColor: isDisabled ? AppColors.mediumText : AppColors.primaryPink,
      ),
    );
  }

  Widget _buildTextButton(bool isDisabled) {
    return Container(
      width: widget.width,
      height: _getButtonHeight(),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppDimensions.borderRadiusMd,
      ),
      child: _buildButtonContent(
        textColor: isDisabled ? AppColors.mediumText : AppColors.primaryPink,
        iconColor: isDisabled ? AppColors.mediumText : AppColors.primaryPink,
      ),
    );
  }

  Widget _buildButtonContent({
    required Color textColor,
    required Color iconColor,
  }) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: _getTextStyle().copyWith(color: textColor),
      textAlign: TextAlign.center,
    );

    if (widget.icon == null) {
      return Center(child: textWidget);
    }

    final iconWidget = Icon(
      widget.icon,
      size: _getIconSize(),
      color: iconColor,
    );

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.iconRight
            ? [
                textWidget,
                const SizedBox(width: 8),
                iconWidget,
              ]
            : [
                iconWidget,
                const SizedBox(width: 8),
                textWidget,
              ],
      ),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case ButtonSize.medium:
        return AppDimensions.buttonHeightMedium;
      case ButtonSize.large:
        return AppDimensions.buttonHeightLarge;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
      case ButtonSize.large:
        return AppTextStyles.button;
    }
  }
}
