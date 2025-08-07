import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../ui/squareButtons.dart';
import '../ui/textField.dart';
import 'otpDialog.dart'; // ✅ Import the NEW OTP dialog from the correct file


// ─────────────────────────────────────────────────────────────
// BasePopupDialog: Reusable base for legacy-style dialogs
// ─────────────────────────────────────────────────────────────

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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 280.h),
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
                    body,
                    SpacingExtensions(AppSpacing.largeVertical).verticalSpace,
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

// ─────────────────────────────────────────────────────────────
// Forgot Password dialog using BasePopupDialog
// ─────────────────────────────────────────────────────────────

class ForgotPasswordDialog extends BasePopupDialog {
  ForgotPasswordDialog({
    super.key,
    required TextEditingController emailController,
    required VoidCallback onSend,
  }) : super(
          title: 'Reset Password',
          body: AuthTextField(
            controller: emailController,
            hintText: 'Email address',
            keyboardType: TextInputType.emailAddress,
          ),
          primaryLabel: 'Send Link',
          onPrimaryPressed: onSend,
        );
}

// ─────────────────────────────────────────────────────────────
// PopupService — Use this to show dialogs
// ─────────────────────────────────────────────────────────────

class PopupService {
  /// ✅ Show modern OTP dialog (from otpDialog.dart)
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

  /// Forgot password dialog (still using legacy design)
  static Future<void> showForgotPasswordDialog({
    required BuildContext context,
    required TextEditingController emailController,
    required Future<void> Function(String email) onSendLink,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
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
