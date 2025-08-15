// lib/dialogs/otpDialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ui/theme.dart';      // ThemeX: context.palette, context.t, etc.
import '../ui/spacing.dart';    // Space / Insets / Gap
import '../ui/squareButtons.dart';

class OtpDialog extends HookWidget {
  final String email;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function() onBiometric;

  const OtpDialog({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    final codeController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textScale = MediaQuery.textScaleFactorOf(context);
    final palette = context.palette;

    // Keyboard-aware max height (keeps prior behavior)
    final size = MediaQuery.sizeOf(context);
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final double maxH =
        (size.height - kb - 32.h).clamp(240.h, size.height * 0.9).toDouble();

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white, // avoid M3 surface tint
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ClipRect(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // clip, don't scroll
            child: Padding(
              // was: EdgeInsets.all(AppSpacing.section) ≈ 32
              padding: Insets.all(Space.xxl),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // shrink with keyboard
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Close (X)
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(Icons.close, size: 20.sp, color: Colors.black),
                      ),
                    ),

                     Gap.vx(Space.md),

                    // Illustration
                    SvgPicture.asset(
                      'assets/images/otp_image.svg',
                      width: 100.w,
                      height: 100.h,
                      semanticsLabel: 'OTP Verification Image',
                    ),

                     Gap.vx(Space.lg),

                    // Title (kept Montserrat + weight; color -> palette.navyBlue)
                    Text(
                      'Verify your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: (context.t.titleLarge?.fontSize ?? 20.sp) * textScale,
                        color: palette.navyBlue,
                      ),
                    ),

                     Gap.vx(Space.sm),

                    // Description (kept Montserrat; colors -> palette)
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: (context.t.bodyMedium?.fontSize ?? 14.sp) * textScale,
                          color: palette.gray,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Enter 5-digit verification code we sent to\n',
                          ),
                          TextSpan(
                            text: email,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: palette.navyBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                     Gap.vx(Space.xl),

                    // OTP input (visuals preserved; colors mapped to palette)
                    PinCodeTextField(
                      appContext: context,
                      length: 5,
                      controller: codeController,
                      animationType: AnimationType.fade,
                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.underline,
                        fieldHeight: 48.h,
                        fieldWidth: 40.w,
                        activeColor: palette.navyBlue,
                        selectedColor: palette.goldenTan,
                        inactiveColor: Palette.gray,
                        borderWidth: 1.5,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18.sp * textScale,
                        fontWeight: FontWeight.bold,
                        color: palette.navyBlue,
                        fontFamily: 'Montserrat',
                      ),
                      validator: (v) => (v?.length == 5) ? null : 'Enter all digits',
                      onChanged: (_) {},
                    ),

                     Gap.vx(Space.xl),

                    // Verify
                    SquareButton(
                      text: 'Verify',
                      backgroundColor: Colors.black, // was AppTheme.black
                      onPressed: () async {
                        final form = formKey.currentState;
                        if (form != null && form.validate()) {
                          FocusScope.of(context).unfocus(); // hide keyboard
                          Navigator.of(context).pop();
                          await onVerify(codeController.text.trim());
                        }
                      },
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),

                     Gap.vx(Space.lg),

                    // Biometric
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        side: BorderSide(color: palette.lightGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.r),
                        ),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                        await onBiometric();
                      },
                      icon: Icon(Icons.fingerprint, color: palette.navyBlue),
                      label: Text(
                        'Biometric Verification',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: palette.navyBlue,
                          fontSize: (context.t.labelLarge?.fontSize ?? 14.sp) * textScale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
