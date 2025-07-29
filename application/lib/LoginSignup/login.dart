import 'package:application/services/authForm.dart';
import 'package:application/ui/lastSlide.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ui/theme.dart';
import '../ui/spacing.dart';
import '../global/base_page.dart';

class LoginPage extends HookConsumerWidget {
  final String title;
  final String description;

  const LoginPage({
    super.key,
     this.title = lastSlideTitle,
     this.description = lastSlideDescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return BasePage(
      contentBuilder: (context) {
        return Column(
          children: [
            // 🟩 Top Section – Header
            Expanded(
              flex: 3, // Reduced
              child: Padding(
                padding: EdgeInsets.only(
                  top: 80.h,
                  left: AppSpacing.mediumHorizontal,
                  right: AppSpacing.mediumHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22.sp * textScale,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SpacingExtensions(10).verticalSpace,
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp * textScale,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🟨 Divider
            Divider(
              thickness: 1.h,
              height: 0.h,
              color: Colors.grey.shade300,
            ),

            // 🟦 Bottom Section – Larger Form
            Expanded(
              flex: 7, // Increased
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFAFAFA),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.mediumHorizontal,
                  vertical: AppSpacing.mediumVertical,
                ),
                child: const AuthForm(),
              ),
            ),
          ],
        );
      },
    );
  }
}
