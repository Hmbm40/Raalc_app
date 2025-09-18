// lib/LoginSignup/signUp.dart
import 'package:application/services/reqChecker.dart';
import 'package:application/ui/countryCode.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:application/global/basePage.dart';
import 'package:application/global/splitPage.dart';

import 'package:application/ui/spacing.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/textField.dart';
import 'package:application/ui/numberField.dart';
import 'package:application/ui/textButton.dart';
import 'package:application/ui/squareButtons.dart';
import 'package:application/ui/errorText.dart';
import 'package:application/ui/showSufix.dart';
import 'package:application/services/popUp.dart';

import 'package:application/services/authForm.dart';
import 'package:application/utils/validators.dart';
import 'package:application/ErrorHandling/validationHooks.dart';

import 'package:application/LoginSignup/login.dart';

// 🔗 API + OTP state + helpers
import 'package:dio/dio.dart';
import 'package:application/services/authApi.dart';
import 'package:application/state/otpState.dart';
import 'package:application/utils/phone.dart';
import 'package:application/network/errorMapper.dart';

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
    final selectedCountry = useState<CountryPickResult?>(null); // 🇦🇪 + meta
    final agreeToTOS = useState(false);

    // Focus / visibility
    final passwordFocus = useFocusNode();
    final isPasswordFocused = useState(false);
    final isPasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);

    // UI state
    final loading = useState(false);

    // Keys for scroll-to-error
    final nameKey = useMemoized(() => GlobalKey());
    final emailKey = useMemoized(() => GlobalKey());
    final phoneKey = useMemoized(() => GlobalKey());
    final passKey = useMemoized(() => GlobalKey());
    final confirmKey = useMemoized(() => GlobalKey());

    // Validation hooks
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

    // Server-side external error holders
    final extEmailError = useState<String?>(null);
    final extPhoneError = useState<String?>(null);

    // Clear external errors as soon as user edits the field
    useEffect(() {
      void clearEmail() => extEmailError.value = null;
      void clearPhone() => extPhoneError.value = null;
      emailController.addListener(clearEmail);
      phoneController.addListener(clearPhone);
      return () {
        emailController.removeListener(clearEmail);
        phoneController.removeListener(clearPhone);
      };
    }, [emailController, phoneController]);

    // Track password focus
    useEffect(() {
      void listener() => isPasswordFocused.value = passwordFocus.hasFocus;
      passwordFocus.addListener(listener);
      return () => passwordFocus.removeListener(listener);
    }, [passwordFocus]);

    // Initialize selected country from current dial code (to show correct flag on first build)
    useEffect(() {
      selectedCountry.value = countryForDial(countryCode.value);
      return null;
    }, const []);

    final api = ref.read(authApiProvider);

    // Submit with API + OTP flow (in-memory, TTL + attempts)
    Future<void> onSubmit() async {
      if (loading.value) return;
      loading.value = true;

      extEmailError.value = null;
      extPhoneError.value = null;

      validateAll([nameFV, emailFV, phoneFV, passFV, confirmFV]);
      if (hasAnyError([nameFV, emailFV, phoneFV, passFV, confirmFV]) ||
          !agreeToTOS.value) {
        await scrollToFirstError(keyed);
        loading.value = false;
        return;
      }

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = buildE164(countryCode.value, phoneController.text);
      final password = passwordController.text;

      final reg = await api.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      await reg.when(
        ok: (res) async {
          final serverOtp = (res['otp'] ?? res['data']?['otp'])?.toString();
          final otpToken = (res['otp_token'] ?? res['data']?['otp_token'])?.toString();

          ref.read(otpStateProvider.notifier).state = OtpPayload(
            email: email,
            phone: phone,
            name: name,
            password: password,
            otpFromServer: serverOtp,
            otpToken: otpToken,
            expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          );

          await PopupService.showOtpDialog(
            context: context,
            email: email,
            onVerified: (typedCode) async {
              var payload = ref.read(otpStateProvider);
              if (payload == null || payload.isExpired) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP expired. Please request a new code.')),
                );
                return;
              }
              if (payload.attempts >= 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Too many attempts. Please request a new code.')),
                );
                return;
              }

              ref.read(otpStateProvider.notifier).state = payload.incAttempts();
              payload = ref.read(otpStateProvider)!;

              if (payload.otpFromServer != null &&
                  typedCode.trim() != payload.otpFromServer) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect OTP. Please try again.')),
                );
                return;
              }

              final save = await api.saveRegisterData(
                name: payload.name,
                email: payload.email,
                phone: payload.phone,
                password: payload.password,
                otp: typedCode.trim(),
                otpToken: payload.otpToken,
              );

              await save.when(
                ok: (_) async {
                  ref.read(otpStateProvider.notifier).state = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration complete. You can sign in now.')),
                  );
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
                err: (e, _) async {
                  if (e is DioException) {
                    final status = e.response?.statusCode ?? 0;
                    if (status == 400 || status == 401 || status == 422) {
                      handleDioError(
                        context,
                        e,
                        resetLoading: () => loading.value = false,
                      );
                      return;
                    }
                  }
                  ref.read(otpStateProvider.notifier).state = null;
                  handleDioError(
                    context,
                    e,
                    resetLoading: () => loading.value = false,
                  );
                },
              );
            },
            onBiometric: () async {},
          );
        },
        err: (e, _) async {
          if (e is DioException) {
            final status = e.response?.statusCode ?? 0;
            final data = e.response?.data;

            if (status == 422 || status == 409) {
              final errors = (data is Map && data['errors'] is Map)
                  ? Map<String, dynamic>.from(data['errors'])
                  : {};
              if (errors['email'] is List && (errors['email'] as List).isNotEmpty) {
                extEmailError.value = (errors['email'] as List).first.toString();
              }
              if (errors['phone'] is List && (errors['phone'] as List).isNotEmpty) {
                extPhoneError.value = (errors['phone'] as List).first.toString();
              }
            }
          }

          handleDioError(
            context,
            e,
            resetLoading: () => loading.value = false,
          );
        },
      );

      loading.value = false;
    }

    Future<void> showCountryPicker(BuildContext context) async {
      final picked = await pickCountryDialCode(
        context,
        initialDialCode: countryCode.value,
      );
      if (picked != null) {
        countryCode.value = picked.dialCode;
        selectedCountry.value = picked; // update flag + meta
      }
    }

    final palette = context.palette;
    final textScale = MediaQuery.textScaleFactorOf(context);

    // Header
    final header = Padding(
      padding: Insets.only(top: Space.xl, left: Space.xxl, right: Space.xxl),
      child: Center(
        child: Text(
          'Create Your Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (context.t.titleLarge?.fontSize ?? 34.sp) * textScale,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );

    // Body
    final body = Padding(
      padding: Insets.symmetric(h: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  FormErrorText(message: emailFV.error ?? extEmailError.value),
                ],
              ),

              // Country Code + Phone (with flag)
              Column(
                key: phoneKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ---------- ONLY CHANGE: content-sized dial code ----------
                      IntrinsicWidth(
                        child: Container(
                          // width removed to allow content-driven width
                          height: 48.h,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: palette.goldenTan,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => showCountryPicker(context),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // hug content
                              children: [
                                Text(
                                  (selectedCountry.value?.flagEmoji ?? '🏳️'),
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  countryCode.value,
                                  style: TextStyle(
                                    fontSize: 14.sp * textScale,
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ---------- END ONLY CHANGE ----------
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Focus(
                          onFocusChange: phoneFV.onFocusChange,
                          child: NumberTextField(
                            controller: phoneController,
                            hintText: 'Phone Number',
                            maxLength: 9,
                            underlineColor:
                                phoneFV.error != null ? Colors.red : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  FormErrorText(message: phoneFV.error ?? extPhoneError.value),
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
                      focusNode: passwordFocus,
                      keyboardType: TextInputType.visiblePassword,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                      underlineColor: passFV.error != null ? Colors.red : null,
                      suffixIcon: ShowHideSuffix(
                        isVisible: isPasswordVisible.value,
                        onTap: () => isPasswordVisible.value = !isPasswordVisible.value,
                      ),
                    ),
                  ),
                  ExpandableFade(
                    visible: isPasswordFocused.value,
                    duration: const Duration(milliseconds: 220),
                    child: Padding(
                      padding: EdgeInsets.only(top: 6.h, left: 4.w),
                      child: RequirementChecker(
                        controller: passwordController,
                        requirements: [
                          Requirement(label: 'At least 8 characters',        validator: (v) => v.length >= 8),
                          Requirement(label: 'At least 1 special character',  validator: (v) => RegExp(r'[!@#\$&*~]').hasMatch(v)),
                          Requirement(label: 'At least 1 number',             validator: (v) => RegExp(r'\d').hasMatch(v)),
                          Requirement(label: 'At least 1 capital letter',     validator: (v) => RegExp(r'[A-Z]').hasMatch(v)),
                        ],
                      ),
                    ),
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
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
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

            // ToS row
            extraWidgets: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agreeToTOS.value,
                    onChanged: (val) => agreeToTOS.value = val ?? false,
                    activeColor: palette.goldenTan,
                  ),
                  Flexible(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'I agree to the ',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'Montserrat',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        CustomTextButton(
                          text: 'Terms of Service',
                          onPressed: () {
                            // TODO: open ToS page / dialog
                          },
                          color: palette.goldenTan,
                          fontSize: 12.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            primaryButtons: [
              SquareButton(
                text: loading.value ? 'Please wait…' : 'Register',
                onPressed: () {
                  if (loading.value) return;
                  onSubmit();
                },
                backgroundColor: loading.value
                    ? palette.goldenTan.withOpacity(0.5)
                    : palette.goldenTan,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ],

            // Back to Login
            secondaryActions: [
              Center(
                child: CustomTextButton(
                  text: 'Back to Login',
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  },
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return BasePage(
      contentBuilder: (context) => SplitPage(
        baseHeaderFraction: 0.001,
        ignoreBottomSafeArea: false,
        header: header,
        bodyBuilder: (_) => body,
      ),
    );
  }
}

/// Smooth expand/collapse with fade, keeping subtree mounted for perf.
class ExpandableFade extends HookWidget {
  const ExpandableFade({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.curveIn = Curves.easeOutCubic,
    this.curveOut = Curves.easeInCubic,
    this.maintainState = true,
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curveIn;
  final Curve curveOut;
  final bool maintainState;

  @override
  Widget build(BuildContext context) {
    final controller =
        useAnimationController(duration: duration, vsync: useSingleTickerProvider());

    useEffect(() {
      if (visible) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [visible]);

    final sizeAnim =
        CurvedAnimation(parent: controller, curve: curveIn, reverseCurve: curveOut);
    final fadeAnim =
        CurvedAnimation(parent: controller, curve: curveIn, reverseCurve: curveOut);

    return TickerMode(
      enabled: visible,
      child: AbsorbPointer(
        absorbing: !visible,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final content =
                maintainState ? child : (visible ? child : const SizedBox.shrink());
            return FadeTransition(
              opacity: fadeAnim,
              child: SizeTransition(
                sizeFactor: sizeAnim,
                axisAlignment: -1.0, // expand from top
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}
