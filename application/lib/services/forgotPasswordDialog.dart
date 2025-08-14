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
    final size = MediaQuery.of(context).size;
    final kb = MediaQuery.of(context).viewInsets.bottom;

    // Bound dialog height to visible viewport; clip anything beyond it.
    final double maxH =
        (size.height - kb - 32.h).clamp(240.h, size.height * 0.9).toDouble();

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ClipRect(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // clip; don't scroll UI
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.section),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close (X)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, size: 20.sp, color: AppTheme.black),
                    ),
                  ),

                  // Title
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

                  // Description
                  Text(
                    'Enter the email address for your account and we’ll send '
                    'a confirmation email to reset your password.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.5.sp * textScale,
                      height: 1.35,
                      color: Colors.black.withOpacity(.75),
                    ),
                  ),
                  SpacingExtensions(AppSpacing.largerVertical).verticalSpace,

                  // Email field
                  AuthTextField(
                    controller: emailController,
                    hintText: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SpacingExtensions(AppSpacing.xlVertical).verticalSpace,

                  // Send button
                  SquareButton(
                    text: 'Send Code',
                    backgroundColor: Colors.black,
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
            ),
          ),
        ),
      ),
    );
  }
}
