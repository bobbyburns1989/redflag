import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// Enhanced text field with gradient borders, clear button, and animations
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool showClearButton;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.showClearButton = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    if (_hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusMd,
            gradient: _hasFocus && widget.enabled
                ? LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.deepPink],
                  )
                : null,
          ),
          padding: _hasFocus && widget.enabled
              ? const EdgeInsets.all(2)
              : EdgeInsets.zero,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              errorText: widget.errorText,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: _hasFocus && widget.enabled
                    ? AppColors.primaryPink
                    : AppColors.mediumText,
              ),
              floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
                color: _hasFocus && widget.enabled
                    ? AppColors.primaryPink
                    : AppColors.mediumText,
                backgroundColor: Colors.white,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _hasFocus && widget.enabled
                          ? AppColors.primaryPink
                          : AppColors.mediumText,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              filled: true,
              fillColor: widget.enabled ? Colors.white : AppColors.lightPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                borderSide: BorderSide(
                  color: AppColors.lightPink,
                  width: AppDimensions.borderWidthThin,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                borderSide: BorderSide(
                  color: AppColors.softPink,
                  width: AppDimensions.borderWidthThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                borderSide: BorderSide(
                  color: AppColors.deepPink,
                  width: AppDimensions.borderWidthThin,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                borderSide: BorderSide(
                  color: AppColors.deepPink,
                  width: AppDimensions.borderWidthMedium,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                borderSide: BorderSide(
                  color: AppColors.lightPink,
                  width: AppDimensions.borderWidthThin,
                ),
              ),
              counterText: widget.maxLength != null ? '' : null,
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.showClearButton && _hasText && widget.enabled) {
      return IconButton(
        icon: Icon(Icons.clear, color: AppColors.mediumText, size: 20),
        onPressed: _clearText,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _hasFocus && widget.enabled
              ? AppColors.primaryPink
              : AppColors.mediumText,
        ),
        onPressed: widget.onSuffixTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return null;
  }
}
