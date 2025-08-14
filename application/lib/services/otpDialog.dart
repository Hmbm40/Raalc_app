import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ui/theme.dart';
import '../ui/spacing.dart';
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

    final size = MediaQuery.of(context).size;
    final kb = MediaQuery.of(context).viewInsets.bottom;
    final double maxH =
        (size.height - kb - 32.h).clamp(240.h, size.height * 0.9).toDouble();

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ClipRect(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // clip, don't scroll
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.section),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // shrink when keyboard shows
                  children: [
                    // Close (X)
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close, size: 20.sp, color: Colors.black),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Illustration
                    SvgPicture.asset(
                      'assets/images/otp_image.svg',
                      width: 100.w,
                      height: 100.h,
                      semanticsLabel: 'OTP Verification Image',
                    ),

                    SizedBox(height: 16.h),

                    const Text(
                      'Verify your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navyBlue,
                      ),
                    ),

                    SpacingExtensions(AppSpacing.smallVertical).verticalSpace,

                    SizedBox(height: 8.h),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: AppTheme.gray,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Enter 5-digit verification code we sent to\n',
                          ),
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: AppTheme.navyBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // OTP input
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
                        activeColor: AppTheme.navyBlue,
                        selectedColor: AppTheme.warmGold,
                        inactiveColor: Colors.grey.shade400,
                        borderWidth: 1.5,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyBlue,
                        fontFamily: 'Montserrat',
                      ),
                      validator: (v) => (v?.length == 5) ? null : 'Enter all digits',
                      onChanged: (_) {},
                    ),

                    SizedBox(height: 24.h),

                    // Verify
                    SquareButton(
                      text: 'Verify',
                      backgroundColor: AppTheme.black,
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

                    SizedBox(height: 16.h),

                    // Biometric
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        side: const BorderSide(color: AppTheme.gray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.r),
                        ),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                        await onBiometric();
                      },
                      icon: const Icon(Icons.fingerprint, color: AppTheme.navyBlue),
                      label: const Text(
                        'Biometric Verification',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navyBlue,
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
