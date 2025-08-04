import 'package:application/services/authForm.dart';
import 'package:application/ui/lastSlide.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../global/base_page.dart';
import '../services/popUp.dart';
import '../ui/textField.dart';
import '../ui/squareButtons.dart';
import 'signUp.dart';

class LoginPage extends HookConsumerWidget {
  final String title;
  final String? description;

  const LoginPage({
    super.key,
    this.title = lastSlideTitle,
    this.description = lastSlideDescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = MediaQuery.textScaleFactorOf(context);
    const headerImagePath = 'assets/images/RAALC Golden Circle transparent - HQ.png';
    final double maxLogoHeight = (0.16.sh).clamp(72.h, 120.h).toDouble();

    // 🧠 Controllers and State
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final isButtonEnabled = useState(false);
    final isForgotButtonFaded = useState(false);

    // 🧠 Validation logic
    useEffect(() {
      void validate() {
        final email = emailController.text.trim();
        final password = passwordController.text;
        final emailValid = RegExp(
          r"^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$",
        ).hasMatch(email);
        final passwordValid = password.length >= 8;
        isButtonEnabled.value = emailValid && passwordValid;
      }

      emailController.addListener(validate);
      passwordController.addListener(validate);
      return () {
        emailController.removeListener(validate);
        passwordController.removeListener(validate);
      };
    }, []);

    // 🧠 Callbacks
    void onOtpRequested() async {
      await PopupService.showOtpDialog(
        context: context,
        email: emailController.text.trim(),
        onVerified: (code) async {
          // Handle verification
        },
        onBiometric: () async {
          // Handle biometric
        },
      );
    }

    void onForgotPasswordPressed() async {
      isForgotButtonFaded.value = true;
      await Future.delayed(const Duration(milliseconds: 100));
      await PopupService.showForgotPasswordDialog(
        context: context,
        emailController: emailController,
        onSendLink: (email) async {
          // Handle reset link
        },
      );
      await Future.delayed(const Duration(milliseconds: 100));
      isForgotButtonFaded.value = false;
    }

    void onRegisterPressed() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    }

    return BasePage(
      contentBuilder: (context) {
        return Column(
          children: [
            // ⬆️ Header
            Expanded(
              flex: 3,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 32.h,
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
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(headerImagePath),
                          ),
                        ),
                      ),
                      SpacingExtensions(35).verticalSpace,
                      Text(
                        title,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: AppTheme.headlineFont * textScale,
                          fontFamily: 'Poppins-ExtraBold',
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      if (description != null) ...[
                        SpacingExtensions(8).verticalSpace,
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            description!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: AppTheme.bodyFont * textScale,
                              fontFamily: 'Poppins-medium',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ⬇️ Form Section
            Expanded(
              flex: 8,
              child: Container(
                color: const Color(0xFFFAFAFA),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.mediumHorizontal,
                  vertical: AppSpacing.mediumVertical,
                ),
                child: AuthForm(
                  fields: [
                    AuthTextField(
                      controller: emailController,
                      hintText: 'Email or phone number',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AuthTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: !isPasswordVisible.value,
                      suffixIcon: InkWell(
                        onTap: () => isPasswordVisible.value = !isPasswordVisible.value,
                        child: Container(
                          alignment: Alignment.center,
                          width: 60.w,
                          child: Text(
                            isPasswordVisible.value ? 'HIDE' : 'SHOW',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppTheme.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  primaryButtons: [
                    SquareButton(
                      text: 'Sign In',
                      onPressed: isButtonEnabled.value ? onOtpRequested : () {},
                      backgroundColor: isButtonEnabled.value
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
                              style: const TextStyle(
                                color: Colors.grey,
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
                      child: Opacity(
                        opacity: isForgotButtonFaded.value ? 0.5 : 1.0,
                        child: TextButton(
                          onPressed: onForgotPasswordPressed,
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  footer: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.largeHorizontal,
                    ),
                    child: SizedBox(
                      width: 1.0.sw,
                      child: Text.rich(
                        TextSpan(
                          text:
                              'Sign in is protected by Google reCAPTCHA to ensure you are not a robot.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.gray,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.parent,
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
