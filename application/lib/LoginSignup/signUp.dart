import 'package:application/global/base_page.dart';
import 'package:application/ui/spacing.dart';
import 'package:application/ui/theme.dart';
import 'package:application/services/authForm.dart';
import 'package:application/ui/textField.dart';
import 'package:application/ui/squareButtons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final phoneController = useTextEditingController();
    final countryCodeController = useTextEditingController(text: '+971');
    final passwordsMatch = useState(true);
    

    useEffect(() {
      void checkMatch() {
        passwordsMatch.value =
            passwordController.text == confirmPasswordController.text &&
            confirmPasswordController.text.isNotEmpty;
      }

      passwordController.addListener(checkMatch);
      confirmPasswordController.addListener(checkMatch);

      return () {
        passwordController.removeListener(checkMatch);
        confirmPasswordController.removeListener(checkMatch);
      };
    }, []);

    return BasePage(
      contentBuilder: (context) => Column(
        children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: AppTheme.headlineFont,
                        fontFamily: 'Poppins-ExtraBold',
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SpacingExtensions(8).verticalSpace,
                    Text(
                      'Please enter your details to continue',
                      style: TextStyle(
                        fontSize: AppTheme.bodyFont,
                        fontFamily: 'Poppins-medium',
                        color: AppTheme.navyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          Expanded(
            flex: 20,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFFAFAFA),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.mediumHorizontal,
                vertical: AppSpacing.mediumVertical,
              ),
              child: AuthForm(
                fields: [
                  AuthTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    keyboardType: TextInputType.name,
                  ),
                  AuthTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 0.25.sw,
                        child: AuthTextField(
                          controller: countryCodeController,
                          hintText: '+971',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: AuthTextField(
                          controller: phoneController,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  AuthTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  AuthTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    underlineColor: passwordsMatch.value
                        ? Colors.green
                        : AppTheme.gray,
                  ),
                ],
                primaryButtons: [
                  SquareButton(
                    text: 'Register',
                    onPressed: () {},
                    backgroundColor: AppTheme.warmGold.withOpacity(0.7),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ],
                secondaryActions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
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
                            'Sign up is protected by Google reCAPTCHA to ensure you are not a robot.',
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
      ),
    );
  }
}
