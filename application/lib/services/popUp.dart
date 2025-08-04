import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../ui/squareButtons.dart';
import '../services/otpDialog.dart'; 
import '../services/forgotPasswordDialog.dart'; // import the file above

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

  /// ---------------------------------------------------------------------------
  /// Base class for all our pop-up dialogs. Provides title, body widget,
  /// and primary/secondary actions. Sized responsively via ScreenUtil.
  /// ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ), // 🔳 Hard corners
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 280.h, // 🔽 Minimal height constraint
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.section),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.h, right: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──
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

                    // ── Body ──
                    body,

                    SpacingExtensions(AppSpacing.largeVertical).verticalSpace,

                    // ── Primary Button ──
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

              // ── Close Button (X) ──
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
    );
  }
}

class PopupService {
  /// ──────────────────────────────────────────────────────────
  /// OTP Dialog
  /// ──────────────────────────────────────────────────────────
  static Future<void> showOtpDialog({
    required BuildContext context,
    required String email,
    required Future<void> Function(String code) onVerified,
    required Future<void> Function() onBiometric,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => OtpDialog(
        email: email,
        onVerify: onVerified,
        onBiometric: onBiometric,
      ),
    );
  }

  /// ──────────────────────────────────────────────────────────
  /// Forgot-Password Dialog
  /// ──────────────────────────────────────────────────────────
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
