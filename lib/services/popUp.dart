// lib/ui/popUp.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui/theme.dart';               // ThemeX: context.t / context.palette / context.tokens
import '../ui/spacing.dart';             // Space, Insets, Gap
import '../ui/squareButtons.dart';       // SquareButton

// Dedicated dialog pages
import '../services/otpDialog.dart';
import '../services/forgotPasswordDialog.dart';

/// ─────────────────────────────────────────────────────────────
/// BasePopupDialog: reusable shell (keyboard-aware, no overflow)
/// ─────────────────────────────────────────────────────────────
abstract class BasePopupDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;

  /// Optional secondary actions row under the body (e.g., links).
  final List<Widget> actions;

  /// Optional override for the title style. Default preserves old look:
  /// Montserrat, 20.sp, w700, brand navy.
  final TextStyle? titleStyle;

  /// If true, body can scroll when content exceeds max height.
  /// Defaults to false to preserve previous "clip, don't scroll" behavior.
  final bool allowScroll;

  const BasePopupDialog({
    super.key,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.actions = const [],
    this.titleStyle,
    this.allowScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final size = MediaQuery.sizeOf(context);
    final kb = MediaQuery.viewInsetsOf(context).bottom;

    // Bound dialog height to visible viewport; no overflow banners.
    // Old math: (height - kb - 32.h).clamp(240.h, 0.9 * height)
    final double maxH =
        (size.height - kb - 32.h).clamp(240.h, size.height * 0.9).toDouble();

    final palette = context.palette;

    final TextStyle effectiveTitle = titleStyle ??
        TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 20.sp * textScale,
          fontWeight: FontWeight.w700,
          color: palette.navyBlue,
        );

    // Build the core content (title → body → actions → primary button)
    final contentColumn = Padding(
      padding: EdgeInsets.only(top: 16.h, right: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink when needed
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(title, style: effectiveTitle),

          // old: smallVertical (≈8.h) → Space.sm
           Gap.vx(Space.sm),

          // Body (caller provides layout)
          body,

          // old: largeVertical (≈32.h) → Space.xxl
           Gap.vx(Space.xxl),

          // Optional actions row (links, switches, etc.)
          if (actions.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  actions[i],
                  if (i != actions.length - 1)  Gap.vx(Space.md),
                ],
              ],
            ),
             Gap.vx(Space.xl),
          ],

          // Primary button (kept as SquareButton for identical visuals)
          SquareButton(
            text: primaryLabel,
            onPressed: onPrimaryPressed,
            backgroundColor: palette.goldenTan, // was AppTheme.warmGold
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );

    // By default we DO NOT scroll (to match old behavior).
    final bodyWidget = allowScroll
        ? SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: contentColumn,
          )
        : SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // clip, don't scroll
            child: contentColumn,
          );

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white, // avoid M3 surface tint (purple/grey)
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ClipRect(
          child: Padding(
            // old: EdgeInsets.all(AppSpacing.section) ≈ 32 => Space.xxl
            padding: Insets.all(Space.xxl),
            child: Stack(
              children: [
                bodyWidget,

                // Close (X)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Semantics(
                    button: true,
                    label: 'Close dialog',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Icon(Icons.close, color: Colors.black, size: 20.sp),
                    ),
                  ),
                ),
              ],
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
    bool allowScroll = false,
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
    bool allowScroll = false,
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
