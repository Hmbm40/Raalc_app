// lib/ui/loading.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../ui/theme.dart';

/// ---------------------------------------------------------------------------
/// Full-screen loading page with spinner and optional message.
/// ---------------------------------------------------------------------------
class LoadingPage extends StatelessWidget {
  /// Optional message displayed below the spinner.
  final String? message;

  const LoadingPage({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Scaffold(
      // was: AppTheme.ivoryWhite
      backgroundColor: context.palette.ivoryWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // was: AppTheme.navyBlue
              SpinKitCircle(
                color: context.palette.navyBlue,
                size: 50.w,
              ),
              if (message != null) ...[
                SizedBox(height: 16.h),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp * textScale,
                    fontWeight: FontWeight.w400,
                    // was: AppTheme.midnightBlue -> use themed onSurface for readability
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Show a modal "Please wait" loading dialog (non-dismissible).
/// Use [hideLoadingDialog] to close.
/// ---------------------------------------------------------------------------
Future<void> showLoadingDialog(
  BuildContext context, {
  String message = 'Please wait...',
}) {
  final cs = Theme.of(context).colorScheme;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        // was: AppTheme.ivoryWhite
        backgroundColor: context.palette.ivoryWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // was: AppTheme.navyBlue
            SpinKitFadingCircle(
              color: context.palette.navyBlue,
              size: 40.w,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                // was: AppTheme.midnightBlue
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// ---------------------------------------------------------------------------
/// Hide the currently shown loading dialog.
/// ---------------------------------------------------------------------------
void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

/// ---------------------------------------------------------------------------
/// IconButton with internal loading state. Replaces icon with spinner when
/// pressed until the async callback completes.
/// ---------------------------------------------------------------------------
class LoadingIconButton extends HookWidget {
  /// Async function to execute when pressed.
  final Future<void> Function() onPressed;

  /// Icon to display when not loading.
  final Widget icon;

  /// Spinner color. If null, uses `context.palette.navyBlue`.
  final Color? spinnerColor;

  /// Spinner size (logical; scaled with .w).
  final double spinnerSize;

  /// Optional tooltip.
  final String? tooltip;

  const LoadingIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.spinnerColor,
    this.spinnerSize = 24.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final color = spinnerColor ?? context.palette.navyBlue;

    return IconButton(
      iconSize: spinnerSize.w,
      tooltip: tooltip,
      icon: isLoading.value
          ? SpinKitWave(
              color: color,
              size: spinnerSize.w,
            )
          : icon,
      onPressed: isLoading.value
          ? null
          : () async {
              isLoading.value = true;
              try {
                await onPressed();
              } finally {
                isLoading.value = false;
              }
            },
    );
  }
}
