import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../ui/squareButtons.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ⬅️ Add this at the top


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
    final textScale = MediaQuery.textScaleFactorOf(context);
    final codeController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 80.h),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close (X) ──
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 20.sp, color: Colors.black),
              ),
            ),

            // ── Illustration ──
                    SizedBox(height: 12.h),
            SvgPicture.asset(
              'assets/images/otp_image.svg',
              width: 100.w,
              height: 100.h,
              semanticsLabel: 'OTP Verification Image',
            ),
            // ── Title ──
            SizedBox(height: 16.h),
            Text(
              'Verify your account',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18.sp * textScale,
                fontWeight: FontWeight.w800,
                color: AppTheme.navyBlue,
              ),
            ),

            SpacingExtensions(AppSpacing.smallVertical).verticalSpace,

            // ── Description ──
            SizedBox(height: 8.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp * textScale,
                  color: AppTheme.gray,
                ),
                children: [
                  const TextSpan(text: 'Enter 5-digit verification code we sent to\n'),
                  TextSpan(
                    text: email,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppTheme.navyBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── OTP input ──
         PinCodeTextField(
            appContext: context,
            length: 5,
            controller: codeController,
            animationType: AnimationType.fade,
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.underline,
              fieldHeight: 48.h,
              fieldWidth: 40.w,
              activeColor: AppTheme.navyBlue,
              selectedColor: AppTheme.warmGold,
              inactiveColor: Colors.grey.shade400,
              borderWidth: 1.5,
              // ❌ DO NOT include borderRadius for underline shape
            ),
            textStyle: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
              fontFamily: 'Montserrat',
            ),
            onChanged: (_) {},
            validator: (v) => (v?.length == 5) ? null : 'Enter all digits',
          ),

            SizedBox(height: 24.h),

             SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,


            // ── Verify button ──
            SquareButton(
              text: 'Verify',
              backgroundColor: AppTheme.black,
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await onVerify(codeController.text.trim());
                }
              },
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),

            SizedBox(height: 16.h),

            SpacingExtensions(AppSpacing.smallVertical).verticalSpace,

            // ── Biometric button ──
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                side: BorderSide(color: AppTheme.gray),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.r)),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await onBiometric();
              },
              icon: const Icon(Icons.fingerprint, color: AppTheme.navyBlue),
              label: const Text(
                'Biometric Verification',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
