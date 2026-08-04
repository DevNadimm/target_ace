import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/inline_error_widget.dart';

class ProfileSetupInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? label;
  final String? errorText;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final bool readOnly;
  final bool isRequired;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const ProfileSetupInputField({
    super.key,
    this.controller,
    required this.hintText,
    this.label,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.isRequired = false,
    this.onTap,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  State<ProfileSetupInputField> createState() => _ProfileSetupInputFieldState();
}

class _ProfileSetupInputFieldState extends State<ProfileSetupInputField> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  Widget _buildIcon(dynamic iconData, Color color) {
    if (iconData is IconData) {
      return Icon(iconData, size: 20, color: color);
    }
    return HugeIcon(icon: iconData, color: color, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    const double depth = 3.0;

    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final Color resolvedBorderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : AppColors.inputBorder;

    final Color resolvedShadowColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : AppColors.inputBorder;

    // Solid opaque background colors matching SelectionCard exactly
    final Color resolvedFaceColor = _isFocused
        ? Color.alphaBlend(AppColors.primary10, AppColors.card)
        : AppColors.card;

    final Color iconColor = _isFocused ? AppColors.primary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Bottom 3D Lip Base
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: depth,
                child: Container(
                  decoration: BoxDecoration(
                    color: resolvedShadowColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // 2. Top Face Input Container (Solid uniform opaque color matching SelectionCard)
              Padding(
                padding: const EdgeInsets.only(bottom: depth),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  constraints: const BoxConstraints(minHeight: 56.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: resolvedFaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: resolvedBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        _buildIcon(widget.prefixIcon, iconColor),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _effectiveFocusNode,
                          readOnly: widget.readOnly,
                          onTap: widget.onTap,
                          keyboardType: widget.keyboardType,
                          maxLength: widget.maxLength,
                          inputFormatters: widget.inputFormatters,
                          cursorColor: AppColors.primary,
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLight,
                            ),
                            fillColor: Colors.transparent,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            counterText: '',
                          ),
                        ),
                      ),
                      if (widget.suffixIcon != null) ...[
                        const SizedBox(width: 12),
                        _buildIcon(widget.suffixIcon, iconColor),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          InlineErrorWidget(widget.errorText!),
        ],
      ],
    );
  }
}
