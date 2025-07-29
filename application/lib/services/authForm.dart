import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../ui/circleButton.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthForm extends HookConsumerWidget {
  const AuthForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogin = useState(true);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isPasswordVisible = useState(false);
    final rememberMe = useState(false);
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Padding(
      padding: EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle: Login / Register
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                ...['Login', 'Register'].map((label) {
                  final selected = (label == 'Login') == isLogin.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => isLogin.value = label == 'Login',
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: selected
                              ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp * textScale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,

          // Email Field
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.navyBlue),
              hintText: 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
          SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,

          // Password Field
          TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible.value,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.navyBlue),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    isPasswordVisible.value = !isPasswordVisible.value,
              ),
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
          SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,

          // Remember me & Forgot password
          Row(
            children: [
              Checkbox(
                value: rememberMe.value,
                onChanged: (value) => rememberMe.value = value ?? false,
                activeColor: AppTheme.navyBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                'Remember me',
                style: TextStyle(fontSize: 12.sp * textScale),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12.sp * textScale,
                    color: AppTheme.navyBlue,
                  ),
                ),
              ),
            ],
          ),
          SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,

          // Login/Register Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                print('${isLogin.value ? "Login" : "Register"} attempted');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                isLogin.value ? 'Login' : 'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp * textScale,
                ),
              ),
            ),
          ),
          SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade400)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'Or login with',
                  style: TextStyle(
                    fontSize: 12.sp * textScale,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade400)),
            ],
          ),
          SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,

          // Social Login Buttons (Circle Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => print('Google login tapped'),
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.widgetShadow,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
                      'assets/images/google.svg',
                      height: 20.h,
                    ),
                  ),
                ),
              ),
              SpacingExtensions(AppSpacing.mediumHorizontal).horizontalSpace,
              GestureDetector(
                onTap: () => print('Facebook login tapped'),
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.widgetShadow,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
                      'assets/images/facebook.svg',
                      height: 20.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SpacingExtensions(AppSpacing.xlVertical).verticalSpace,
        ],
      ),
    );
  }
}
