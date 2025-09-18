// lib/ui/numberField.dart
import 'package:application/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffixIcon;

  /// Unfocused underline color (fallback uses theme.onSurface with opacity).
  final Color? underlineColor;

  /// Focused underline color (fallback uses theme.primary).
  final Color? focusedUnderlineColor;

  /// Hint/label text style override (keeps legacy Montserrat look if null).
  final TextStyle? hintStyle;

  /// Optional hard limit for digits.
  final int? maxLength;

  /// Input text color (falls back to themed body color).
  final Color? textColor;

  /// Cursor color (falls back to black for parity).
  final Color? cursorColor;

  /// Font family for input text (defaults to 'Montserrat' for parity).
  final String? fontFamily;

  const NumberTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.underlineColor,
    this.focusedUnderlineColor,
    this.hintStyle,
    this.maxLength,
    this.textColor,
    this.cursorColor,
    this.fontFamily,
  });

  @override
  State<NumberTextField> createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  late final FocusNode _focusNode;

  bool get _isLabelFloating =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;
  bool get _isFocused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final theme = Theme.of(context);

    // Colors (theme-driven defaults, overridable to match your exact old palette)
    final Color unfocusedColor =
        widget.underlineColor ?? theme.colorScheme.onSurface.withOpacity(0.4);
    final Color focusedColor =
        widget.focusedUnderlineColor ?? AppColors.light.goldenTan;
    final Color inputColor =
        widget.textColor ?? (theme.textTheme.bodyLarge?.color ?? Colors.black);
    final Color caretColor = widget.cursorColor ?? Colors.black;

    final underline = BorderSide(
      color: _isFocused ? focusedColor : unfocusedColor,
      width: 1.5,
    );

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: underline),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // ── Floating Label ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            left: 4.w,
            top: _isLabelFloating ? 6.h : 14.h,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: widget.hintStyle ??
                  TextStyle(
                    fontSize: (_isLabelFloating ? 10.sp : 14.sp) * textScale,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    color: Palette.gray,
                  ),
              child: Text(widget.hintText),
            ),
          ),

          // ── Text Input Field ──
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              if (widget.maxLength != null)
                LengthLimitingTextInputFormatter(widget.maxLength),
            ],
            cursorColor: caretColor,
            style: TextStyle(
              fontFamily: widget.fontFamily ?? 'Montserrat',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp * textScale,
              color: inputColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              isDense: true,
              suffixIcon: widget.suffixIcon,
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              contentPadding: EdgeInsetsDirectional.only(
                top: 20.h,
                bottom: 4.h,
                end: 0.w,
                start: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
