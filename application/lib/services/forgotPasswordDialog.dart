// lib/services/forgotPasswordDialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../ui/textField.dart';
import '../ui/squareButtons.dart';

class ForgotPasswordDialog extends StatelessWidget {
  final TextEditingController emailController;
  final Future<void> Function() onSend;

  const ForgotPasswordDialog({
    super.key,
    required this.emailController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // ⬛ flat edges
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── close (X) ────────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 20.sp, color: AppTheme.black),
              ),
            ),
            // ── title ────────────────────────────────────────────────────
            Text(
              'Forgot Password',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 22.sp * textScale,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SpacingExtensions(AppSpacing.smallVertical).verticalSpace,
            // ── description ─────────────────────────────────────────────
            Text(
              'Enter the email address with your account and we’ll send '
              'an email with confirmation to reset your password.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.5.sp * textScale,
                height: 1.35,
                color: Colors.black.withOpacity(.75),
              ),
            ),
            SpacingExtensions(AppSpacing.largerVertical).verticalSpace,
            // ── label + text-field ─────────────────────────────────────
         
            SpacingExtensions(AppSpacing.tinyVertical).verticalSpace,
            AuthTextField(
              controller: emailController,
              hintText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            // large spacer to push Send button down (matches screenshot)
            SpacingExtensions(AppSpacing.xlVertical).verticalSpace,
            // ── send button ─────────────────────────────────────────────
            SquareButton(
              text: 'Send Code',
              backgroundColor: Colors.black,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              onPressed: () async {
                Navigator.of(context).pop();
                await onSend();
              },
            ),
          ],
        ),
      ),
    );
  }
}
