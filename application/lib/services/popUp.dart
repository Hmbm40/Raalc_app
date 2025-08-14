import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../ui/squareButtons.dart';

// Dedicated dialog pages
import 'otpDialog.dart';
import 'forgotPasswordDialog.dart';

/// ─────────────────────────────────────────────────────────────
/// BasePopupDialog: reusable shell (keyboard-aware, no overflow)
/// ─────────────────────────────────────────────────────────────
abstract class BasePopupDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;

  const BasePopupDialog({
    super.key,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final size = MediaQuery.of(context).size;
    final kb = MediaQuery.of(context).viewInsets.bottom;

    // Bound dialog height to visible viewport; no overflow banners.
    final double maxH =
        (size.height - kb - 32.h).clamp(240.h, size.height * 0.9).toDouble();

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white, // avoid M3 surface tint (purple/grey)
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ClipRect(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // clip, don't scroll
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.section),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.h, right: 16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // shrink when needed
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20.sp * textScale,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        SpacingExtensions(AppSpacing.smallVertical).verticalSpace,

                        // Body
                        body,

                        SpacingExtensions(AppSpacing.largeVertical).verticalSpace,

                        // Primary button
                        SquareButton(
                          text: primaryLabel,
                          onPressed: onPrimaryPressed,
                          backgroundColor: AppTheme.warmGold,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),

                  // Close (X)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, color: Colors.black, size: 20.sp),
                    ),
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

/// ─────────────────────────────────────────────────────────────
/// PopupService — one place to open app dialogs
/// ─────────────────────────────────────────────────────────────
class PopupService {
  static Future<void> showOtpDialog({
    required BuildContext context,
    required String email,
    required Future<void> Function(String code) onVerified,
    required Future<void> Function() onBiometric,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpDialog(
        email: email,
        onVerify: onVerified,
        onBiometric: onBiometric,
      ),
    );
  }

  static Future<void> showForgotPasswordDialog({
    required BuildContext context,
    required TextEditingController emailController,
    required Future<void> Function(String email) onSendLink,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ForgotPasswordDialog(
        emailController: emailController,
        onSend: () async {
          Navigator.of(context).pop();
          await onSendLink(emailController.text.trim());
        },
      ),
    );
  }
}
