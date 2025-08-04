import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color? underlineColor; // ✅ ADD THIS


  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false, this.suffixIcon,
    this.underlineColor, // ✅ ADD THIS

  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

  class _AuthTextFieldState extends State<AuthTextField> {
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
        color: Colors.transparent, // ✅ No fill color
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
              style: TextStyle(
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
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
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
