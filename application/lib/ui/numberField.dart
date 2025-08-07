import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';

class NumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffixIcon;
  final Color? underlineColor;
  final TextStyle? hintStyle;
  final int? maxLength;

  const NumberTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.underlineColor,
    this.hintStyle,
    required this.maxLength,
  });

  @override
  State<NumberTextField> createState() => _NumberTextFieldState();
}

class _NumberTextFieldState extends State<NumberTextField> {
  late FocusNode _focusNode;

  bool get _isLabelFloating => _focusNode.hasFocus || widget.controller.text.isNotEmpty;
  bool get _isFocused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: widget.underlineColor ?? (_isFocused ? AppTheme.goldenTan : AppTheme.gray),
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
                    color: AppTheme.gray,
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
            cursorColor: Colors.black,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp * textScale,
              color: AppTheme.black,
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
              contentPadding: EdgeInsets.only(
                top: 20.h,
                bottom: 4.h,
                right: 0.w,
                left: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
