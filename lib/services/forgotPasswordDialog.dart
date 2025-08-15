// lib/services/forgotPasswordDialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui/theme.dart';         // ThemeX: context.t, context.palette, context.tokens
import '../ui/spacing.dart';       // Space / Insets / Gap
import '../ui/textField.dart';
import '../ui/squareButtons.dart';

class ForgotPasswordDialog extends StatelessWidget {
  final TextEditingController emailController;
  final Future<void> Function() onSend;

  /// Optional: keep previous behavior (no scrolling) by default.

  const ForgotPasswordDialog({
    super.key,
    required this.emailController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    // Keyboard-aware max height (same math as before)
    final size = MediaQuery.sizeOf(context);
    final kb   = MediaQuery.viewInsetsOf(context).bottom;
    final double maxH =
        (size.height - kb - 32.h).clamp(240.h, size.height * 0.9).toDouble();


    final Widget content = Padding(
      // was: EdgeInsets.all(AppSpacing.section) ~ 32 -> Space.xxl
      padding: Insets.all(Space.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink with keyboard
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close (X)
          Align(
            alignment: Alignment.topRight,
            child: Semantics(
              button: true,
              label: 'Close dialog',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 20.sp, color: Colors.black),
              ),
            ),
          ),

          // Title
          Text(
            'Forgot Password',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: (context.t.titleLarge?.fontSize ?? 22.sp) * textScale,
              fontWeight: FontWeight.w800,
              color: Colors.black, // preserves previous look
            ),
          ),

           Gap.vx(Space.sm), // was smallVertical (~8.h)

          // Description
          Text(
            'Enter the email address for your account and we’ll send '
            'a confirmation email to reset your password.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: (12.5.sp) * textScale,
              height: 1.35,
              color: Colors.black.withOpacity(.75),
            ),
          ),

          // was largerVertical (~40.h) -> exact gap
           Gap.v(40),

          // Email field
          AuthTextField(
            controller: emailController,
            hintText: 'Email address',
            keyboardType: TextInputType.emailAddress,
          ),

          // was xlVertical (~48.h) -> exact gap
           Gap.v(48),

          // Send button
          SquareButton(
            text: 'Send Code',
            backgroundColor: Colors.black, // preserves old color
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            onPressed: () async {
              FocusScope.of(context).unfocus(); // hide keyboard
              Navigator.of(context).pop();
              await onSend();
            },
          ),
        ],
      ),
    );

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      backgroundColor: Colors.white, // avoid M3 surface tint
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: content,
      ),
    );
  }
}
