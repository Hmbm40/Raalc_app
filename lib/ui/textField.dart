// lib/ui/textField.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart'; // for ThemeX (context.palette, context.t)

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  /// Unfocused underline color (defaults to palette.lightGray).
  final Color? underlineColor;

  /// Focused underline color (defaults to palette.goldenTan).
  final Color? focusedUnderlineColor;

  /// Hint/label style override (defaults keep legacy Montserrat look).
  final TextStyle? hintStyle;

  /// Optional externally managed focus node.
  final FocusNode? focusNode;

  /// Extra input formatters (e.g., deny spaces).
  final List<TextInputFormatter>? inputFormatters;

  /// Optional input text color (defaults to themed body color).
  final Color? textColor;

  /// Optional cursor color (defaults to black for parity).
  final Color? cursorColor;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.underlineColor,
    this.focusedUnderlineColor,
    this.hintStyle,
    this.focusNode,
    this.inputFormatters,
    this.textColor,
    this.cursorColor,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;
  late final VoidCallback _focusListener;
  late final VoidCallback _textListener;

  bool get _isFocused => _focusNode.hasFocus;
  bool get _isLabelFloating =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusListener = () => setState(() {});
    _textListener = () => setState(() {});

    _focusNode.addListener(_focusListener);
    widget.controller.addListener(_textListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    widget.controller.removeListener(_textListener);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final palette = context.palette;
    final theme = Theme.of(context);

    // Colors (theme-driven, preserving legacy look)
    final Color unfocusedLine =
        widget.underlineColor ?? palette.lightGray;
    final Color focusedLine =
        widget.focusedUnderlineColor ?? palette.goldenTan;
    final Color inputColor =
        widget.textColor ?? (theme.textTheme.bodyLarge?.color ?? Colors.black);
    final Color caretColor = widget.cursorColor ?? Colors.black;

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _isFocused ? focusedLine : unfocusedLine,
            width: 1.5,
          ),
        ),
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
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            inputFormatters: widget.inputFormatters,
            cursorColor: caretColor,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp * textScale,
              color: inputColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              isDense: true,
              suffixIcon: widget.suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              contentPadding: EdgeInsetsDirectional.only(
                top: 20.h,
                bottom: 4.h,
                start: 4.w,
                end: 0.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
