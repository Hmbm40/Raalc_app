import 'package:application/ui/showSufix.dart';
import 'package:application/services/reqChecker.dart';
import 'package:application/ui/errorText.dart'; // your FormErrorText file
import 'package:application/utils/validators.dart';
import 'package:application/ErrorHandling/validationHooks.dart';

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/gestures.dart';

import 'package:application/global/base_page.dart';
import 'package:application/services/authForm.dart';
import 'package:application/ui/spacing.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/textField.dart';
import 'package:application/ui/squareButtons.dart';
import 'package:application/ui/numberField.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controllers
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Country code & ToS
    final countryCode = useState('+971');
    final agreeToTOS = useState(false);

    // Focus / visibility
    final passwordFocus = useFocusNode();
    final isPasswordFocused = useState(false);
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // Keys for scroll-to-error
    final nameKey = useMemoized(() => GlobalKey());
    final emailKey = useMemoized(() => GlobalKey());
    final phoneKey = useMemoized(() => GlobalKey());
    final passKey = useMemoized(() => GlobalKey());
    final confirmKey = useMemoized(() => GlobalKey());
    final scrollController = useScrollController();

    // Reusable validation hooks (now respect "changed" before errors on blur)
    final nameFV = useFieldValidation(
      controller: nameController,
      validator: (v) => AppValidators.requiredField(v, label: 'Full name'),
    );
    final emailFV = useFieldValidation(
      controller: emailController,
      validator: AppValidators.email,
    );
    final phoneFV = useFieldValidation(
      controller: phoneController,
      validator: (v) => AppValidators.phone(v, min: 7),
    );
    final passFV = useFieldValidation(
      controller: passwordController,
      validator: AppValidators.password,
    );
    final confirmFV = useFieldValidation(
      controller: confirmPasswordController,
      validator: (v) => AppValidators.confirm(v, passwordController.text),
    );

    final keyed = [
      MapEntry(nameKey, nameFV),
      MapEntry(emailKey, emailFV),
      MapEntry(phoneKey, phoneFV),
      MapEntry(passKey, passFV),
      MapEntry(confirmKey, confirmFV),
    ];

    // Track password focus (attached ONLY to the text field)
    useEffect(() {
      void listener() => isPasswordFocused.value = passwordFocus.hasFocus;
      passwordFocus.addListener(listener);
      return () => passwordFocus.removeListener(listener);
    }, [passwordFocus]);

    // Submit
    Future<void> onSubmit() async {
      validateAll([nameFV, emailFV, phoneFV, passFV, confirmFV]);

      if (hasAnyError([nameFV, emailFV, phoneFV, passFV, confirmFV]) ||
          !agreeToTOS.value) {
        await scrollToFirstError(keyed);
        return;
      }

      // TODO: integrate API
      // ignore: avoid_print
      print('Form valid → submit');
    }

    void showCountryPicker(BuildContext context) {
      final codes = ['+971', '+1', '+44', '+91', '+33', '+61'];
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        showCupertinoModalPopup(
          context: context,
          builder: (_) => Material(
            child: SizedBox(
              height: 250.h,
              child: CupertinoPicker(
                itemExtent: 32.h,
                scrollController: FixedExtentScrollController(
                  initialItem: codes.indexOf(countryCode.value),
                ),
                onSelectedItemChanged: (index) =>
                    countryCode.value = codes[index],
                children: codes.map((code) => Text(code)).toList(),
              ),
            ),
          ),
        );
      } else {
        showModalBottomSheet(
          context: context,
          builder: (_) => ListView.builder(
            itemCount: codes.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(codes[i]),
              onTap: () {
                countryCode.value = codes[i];
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    }

    return BasePage(
      contentBuilder: (context) => SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.mediumHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              Center(
                child: Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 22.sp * MediaQuery.textScaleFactorOf(context),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: AppTheme.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 32.h),

              AuthForm(
                fields: [
                  // Full Name
                  Column(
                    key: nameKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: nameFV.onFocusChange,
                        child: AuthTextField(
                          controller: nameController,
                          hintText: 'Full Name',
                          keyboardType: TextInputType.name,
                          underlineColor: nameFV.error != null ? Colors.red : null,
                        ),
                      ),
                      FormErrorText(message: nameFV.error),
                    ],
                  ),

                  // Email
                  Column(
                    key: emailKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: emailFV.onFocusChange,
                        child: AuthTextField(
                          controller: emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          underlineColor: emailFV.error != null ? Colors.red : null,
                        ),
                      ),
                      FormErrorText(message: emailFV.error),
                    ],
                  ),

                  // Country Code + Phone
                  Column(
                    key: phoneKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 0.25.sw,
                            height: 48.h,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppTheme.goldenTan, width: 1.5),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => showCountryPicker(context),
                              child: Text(
                                countryCode.value,
                                style: TextStyle(
                                  fontSize: 14.sp * MediaQuery.textScaleFactorOf(context),
                                  fontFamily: 'Montserrat',
                                  color: AppTheme.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Focus(
                              onFocusChange: phoneFV.onFocusChange,
                              child: NumberTextField(
                                controller: phoneController,
                                hintText: 'Phone Number',
                                maxLength: 9,
                                underlineColor: phoneFV.error != null ? Colors.red : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      FormErrorText(message: phoneFV.error),
                    ],
                  ),

                  // Password
                  Column(
                    key: passKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: (hasFocus) {
                          passFV.onFocusChange(hasFocus);
                          isPasswordFocused.value = hasFocus;
                        },
                        child: AuthTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: !isPasswordVisible.value,
                          focusNode: passwordFocus, // ONLY here
                          keyboardType: TextInputType.visiblePassword,
                          // 🚫 No spaces in passwords
                          inputFormatters: [
                            FilteringTextInputFormatter.deny( RegExp(r'\s')),
                          ],
                          underlineColor: passFV.error != null ? Colors.red : null,
                          suffixIcon: ShowHideSuffix(
                            isVisible: isPasswordVisible.value,
                            onTap: () => isPasswordVisible.value = !isPasswordVisible.value,
                          ),
                        ),
                      ),

                      // Live requirements while focused
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: isPasswordFocused.value
                            ? Padding(
                                key: const ValueKey('reqs'),
                                padding: EdgeInsets.only(top: 6.h, left: 4.w),
                                child: RequirementChecker(
                                  controller: passwordController,
                                  requirements: [
                                    Requirement(label: 'At least 8 characters',      validator: (v) => v.length >= 8),
                                    Requirement(label: 'At least 1 special character',validator: (v) =>  RegExp(r'[!@#\$&*~]').hasMatch(v)),
                                    Requirement(label: 'At least 1 number',           validator: (v) =>  RegExp(r'\d').hasMatch(v)),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('no_reqs')),
                      ),

                      FormErrorText(message: passFV.error),
                    ],
                  ),

                  // Confirm Password
                  Column(
                    key: confirmKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: confirmFV.onFocusChange,
                        child: AuthTextField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: !isConfirmPasswordVisible.value,
                          // 🚫 No spaces in confirm password
                          inputFormatters: [
                            FilteringTextInputFormatter.deny( RegExp(r'\s')),
                          ],
                          underlineColor: confirmFV.error != null ? Colors.red : null,
                          suffixIcon: ShowHideSuffix(
                            isVisible: isConfirmPasswordVisible.value,
                            onTap: () => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value,
                          ),
                        ),
                      ),
                      FormErrorText(message: confirmFV.error),
                    ],
                  ),
                ],

                extraWidgets: [
                  Row(
                    children: [
                      Checkbox(
                        value: agreeToTOS.value,
                        onChanged: (val) => agreeToTOS.value = val ?? false,
                        activeColor: AppTheme.goldenTan,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                              color: AppTheme.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: AppTheme.goldenTan,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: open TOS
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                primaryButtons: [
                  SquareButton(
                    text: 'Register',
                    onPressed: onSubmit,
                    backgroundColor: AppTheme.warmGold.withOpacity(0.7),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ],

                secondaryActions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Already a user? Sign In',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
