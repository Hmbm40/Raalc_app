// lib/LoginSignup/login.dart
import 'package:application/services/authForm.dart';
import 'package:application/services/popUp.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui/theme.dart';               // ThemeX: context.t / context.palette
import '../ui/spacing.dart';             // Space / Insets / Gap
import '../global/basePage.dart';
import '../global/splitPage.dart';
import '../ui/textField.dart';
import '../ui/squareButtons.dart';
import 'signUp.dart';
import '../ui/logoAnimation.dart';
import '../ui/showSufix.dart';
import 'package:application/ui/errorText.dart';
import 'package:application/ErrorHandling/validationHooks.dart';
import 'package:application/ui/textButton.dart';

class LoginPage extends HookConsumerWidget {

  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kbOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

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
      final emailOk = RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$').hasMatch(t);
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
        onVerified: (code) async {},
        onBiometric: () async {},
      );
    }

    Future<void> onForgotPasswordPressed() async {
      isForgotButtonFaded.value = true;
      await PopupService.showForgotPasswordDialog(
        context: context,
        emailController: emailController,
        onSendLink: (email) async {},
      );
      await Future.delayed(const Duration(milliseconds: 120));
      isForgotButtonFaded.value = false;
    }

    void onRegisterPressed() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    }

    final palette = context.palette;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor; // ← single source

    // Header
    final header = Padding(
      padding: EdgeInsets.only(
        top: kbOpen ? 12.h : 24.h,
        left: Spacing.h(Space.xxl),
        right: Spacing.h(Space.xxl),
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
          ],
        ),
    );


    // Body (match Scaffold background; remove hard-coded FAFAFA)
    final body = Container(
      color: scaffoldBg, // ← fixes the mismatch
      child: Padding(
        padding: Insets.symmetric(h: Space.xl, v: Space.xl),
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
                      onTap: () =>
                          isPasswordVisible.value = !isPasswordVisible.value,
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
                  ? palette.goldenTan
                  : palette.goldenTan.withOpacity(0.7),
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
                        color: palette.gray.withOpacity(0.45), // one gray
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
                        color: palette.gray.withOpacity(0.45), // one gray
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
              backgroundColor: Colors.black,
              fontFamily: 'Montserrat',
            ),

            Center(
              child: CustomTextButton(
                text: 'Forgot Password',
                onPressed: onForgotPasswordPressed,
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                opacity: isForgotButtonFaded.value ? 0.5 : 1.0,
              ),
            ),
          ],

          secondaryItemsSpaceToken: Space.xxl,   // ⬅️ NEW


          footer: Padding(
            padding: Insets.symmetric(h: Space.xl),
            child: SizedBox(
              width: 1.0.sw,
              child: Text(
                'Sign in is protected by Google reCAPTCHA to ensure you are not a robot.',
                textAlign: TextAlign.center,
                textWidthBasis: TextWidthBasis.parent,
                style: TextStyle(
                  fontSize: 11,
                  color: palette.gray, // single gray
                  fontFamily: 'Montserrat',
                ),
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
        bodyBuilder: (_) => body,
      ),
    );
  }
}
