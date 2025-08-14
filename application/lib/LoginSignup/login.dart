// lib/LoginSignup/login.dart
import 'package:application/services/authForm.dart';
import 'package:application/ui/lastSlide.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../global/basePage.dart';
import '../global/splitPage.dart';
import '../services/popUp.dart';
import '../ui/textField.dart';
import '../ui/squareButtons.dart';
import 'signUp.dart';
import '../ui/logoAnimation.dart';
import '../ui/showSufix.dart';
import 'package:application/ui/errorText.dart';
import 'package:application/ErrorHandling/validationHooks.dart';
import '../ui/textButton.dart';


class LoginPage extends HookConsumerWidget {
  final String? title;
  final String? description;

  const LoginPage({
    super.key,
    this.title = lastSlideTitle,
    this.description = lastSlideDescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    final kbOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    const headerAnimationPath = 'assets/animations/Logo.json';
    final double maxLogoHeight = (0.16.sh).clamp(72.h, 120.h).toDouble();

    // Controllers / state
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isForgotButtonFaded = useState(false);
    final canSubmit = useState(false);

    // Validation
    bool emailOrPhoneValid(String v) {
      final t = v.trim();
      if (t.isEmpty) return false;
      final emailOk =
          RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$').hasMatch(t);
      final phoneOk = RegExp(r'^\d{7,}$').hasMatch(t);
      return emailOk || phoneOk;
    }

    String? emailOrPhoneValidator(String v) {
      if (v.trim().isEmpty) return 'Email or phone is required';
      if (!emailOrPhoneValid(v)) return 'Enter a valid email or phone';
      return null;
    }

    String? passwordValidator(String v) {
      if (v.isEmpty) return 'Password is required';
      return null;
    }

    final emailFV = useFieldValidation(
      controller: emailController,
      validator: emailOrPhoneValidator,
    );
    final passFV = useFieldValidation(
      controller: passwordController,
      validator: passwordValidator,
    );

    // Enable/disable Sign In button live
    useEffect(() {
      void recompute() {
        canSubmit.value =
            emailOrPhoneValid(emailController.text) &&
            passwordController.text.isNotEmpty;
      }

      recompute();
      emailController.addListener(recompute);
      passwordController.addListener(recompute);
      return () {
        emailController.removeListener(recompute);
        passwordController.removeListener(recompute);
      };
    }, [emailController, passwordController]);

    // Actions
    Future<void> onOtpRequested() async {
      emailFV.validateNow();
      passFV.validateNow();
      if (emailFV.error != null || passFV.error != null) return;

      await PopupService.showOtpDialog(
        context: context,
        email: emailController.text.trim(),
        onVerified: (code) async {
          // handle OTP verification
        },
        onBiometric: () async {
          // handle biometric login
        },
      );
    }

    Future<void> onForgotPasswordPressed() async {
      isForgotButtonFaded.value = true;
      await PopupService.showForgotPasswordDialog(
        context: context,
        emailController: emailController,
        onSendLink: (email) async {
          // send reset
        },
      );
      await Future.delayed(const Duration(milliseconds: 120));
      isForgotButtonFaded.value = false;
    }

    void onRegisterPressed() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    }

    // Header
    final header = Padding(
      padding: EdgeInsets.only(
        top: (kbOpen ? 12.h : 24.h),
        left: AppSpacing.xlHorizontal,
        right: AppSpacing.xlHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 0.24.sw,
                maxHeight: maxLogoHeight,
              ),
              child: HeaderAnimation(
                assetPath: headerAnimationPath,
                maxHeight: maxLogoHeight,
                maxWidth: 0.24.sw,
              ),
            ),
          ),
          if (description != null && !kbOpen) ...[
            SpacingExtensions(8).verticalSpace,
            SizedBox(
              width: double.infinity,
              child: Text(
                description!,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: AppTheme.bodyFont * textScale,
                  fontFamily: 'Poppins-medium',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Body
    final body = Container(
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.mediumHorizontal,
          vertical: AppSpacing.mediumVertical,
        ),
        child: AuthForm(
          fields: [
            // Email / Phone
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Focus(
                  onFocusChange: emailFV.onFocusChange,
                  child: AuthTextField(
                    controller: emailController,
                    hintText: 'Email or phone number',
                    keyboardType: TextInputType.emailAddress,
                    underlineColor:
                        emailFV.error != null ? Colors.red : null,
                  ),
                ),
                FormErrorText(message: emailFV.error),
              ],
            ),

            // Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Focus(
                  onFocusChange: passFV.onFocusChange,
                  child: AuthTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: !isPasswordVisible.value,
                    underlineColor:
                        passFV.error != null ? Colors.red : null,
                    suffixIcon: ShowHideSuffix(
                      isVisible: isPasswordVisible.value,
                      onTap: () => isPasswordVisible.value =
                          !isPasswordVisible.value,
                    ),
                  ),
                ),
                FormErrorText(message: passFV.error),
              ],
            ),
          ],

          primaryButtons: [
            SquareButton(
              text: 'Sign In',
              onPressed: canSubmit.value ? onOtpRequested : () {},
              backgroundColor: canSubmit.value
                  ? AppTheme.warmGold
                  : AppTheme.warmGold.withOpacity(0.7),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ],

          secondaryActions: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250.w,
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1.h,
                        endIndent: 8.w,
                      ),
                    ),
                    const Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1.h,
                        indent: 8.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CompactSquareButton(
              text: 'Register',
              onPressed: onRegisterPressed,
              backgroundColor: AppTheme.black,
              fontFamily: 'Montserrat',
            ),

              Center(
                child: CustomTextButton(
                  text: 'Forgot Password',
                  onPressed: onForgotPasswordPressed,
                  color: AppTheme.black,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  opacity: isForgotButtonFaded.value ? 0.5 : 1.0,
                ),
              ),

          ],

          footer: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.largeHorizontal,
            ),
            child: SizedBox(
              width: 1.0.sw,
              child: const Text.rich(
                TextSpan(
                  text:
                      'Sign in is protected by Google reCAPTCHA to ensure you are not a robot.',
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.gray,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
                textWidthBasis: TextWidthBasis.parent,
                softWrap: true,
              ),
            ),
          ),
        ),
      ),
    );

    return BasePage(
      fullscreen: true,
      contentBuilder: (context) => SplitPage(
        baseHeaderFraction: 0.22,
        ignoreBottomSafeArea: false,
        header: header,
        bodyBuilder: (_) => body, // builder prevents re-parenting issues
      ),
    );
  }
}
