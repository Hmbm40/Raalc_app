import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:application/global/base_page.dart';
import 'package:application/ui/progressLine.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/spacing.dart';
import 'package:application/ui/circleButton.dart';
import 'package:application/LoginSignup/login.dart';
import 'package:application/ui/lastSlide.dart';

class StartPage extends HookConsumerWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final hasViewedLastPage = useState(false);

    final images = [
      'assets/images/test1.jpeg',
      'assets/images/test2.jpeg',
      'assets/images/test3.jpeg',
    ];

    const lastSlideWidget = LastSlideContent(
      title: lastSlideTitle,
      description: lastSlideDescription,
    );

    void nextSlide() {
      if (currentPage.value < images.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    Widget buildTag(String tag) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Container(
          key: ValueKey<String>(tag),
          alignment: Alignment.center,
          width: 140.w,
          child: Text(
            tag,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  AppTheme.tagFont * MediaQuery.of(context).textScaleFactor,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

          Widget buildButton() {
            if (hasViewedLastPage.value) {
              return GestureDetector(
                onTap: () {
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
        builder: (context) => const LoginPage(description: null),
          ),
      );


            
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppTheme.goldenTan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Image.asset(
                'assets/images/white_logo.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      } else {
        return PrimaryCircleButton(onPressed: nextSlide);
      }
    }

    return BasePage(
      fullscreen: true,
      scrollable: false,
      contentBuilder: (context) {
        return Column(
          children: [
            SizedBox(
              height: 0.6.sh,
              width: double.infinity,
              child: PageView.builder(
                controller: pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  currentPage.value = index;
                  if (index == images.length - 1) {
                    hasViewedLastPage.value = true;
                  }
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.mediumHorizontal,
                  AppSpacing.mediumVertical,
                  AppSpacing.mediumHorizontal,
                  AppSpacing.largerVertical,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.ivoryWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.baseRadius),
                    topRight: Radius.circular(AppTheme.baseRadius),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ProgressLine(
                        currentPage: currentPage.value,
                        totalPages: images.length,
                      ),
                    ),
                    SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,
                    if (currentPage.value == images.length - 1)
                      lastSlideWidget
                    else ...[
                      Text(
                        currentPage.value == 0
                            ? 'EVERYTHING YOU NEED, ALL IN ONE PLACE'
                            : 'TAILORED FOR YOUR NEEDS',
                        style: TextStyle(
                          fontFamily: 'Poppins-ExtraBold',
                          fontSize: AppTheme.headlineFont *
                              MediaQuery.textScaleFactorOf(context),
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      SpacingExtensions(AppSpacing.mediumVertical)
                          .verticalSpace,
                      Text(
                        currentPage.value == 0
                            ? 'All the tools and resources you need in one platform. Accessing your essentials is fast and hassle-free.'
                            : 'Custom solutions that adapt to your workflow, giving you full control and flexibility.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: 'Poppins-Regular',
                          fontSize: AppTheme.bodyFont *
                              MediaQuery.textScaleFactorOf(context),
                          color: AppTheme.midnightBlue,
                        ),
                      ),
                    ],
                    SpacingExtensions(AppSpacing.largerVertical).verticalSpace,
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildTag(
                          currentPage.value == 0
                              ? 'Centralization'
                              : currentPage.value == 1
                                  ? 'Personalization'
                                  : 'Security',
                        ),
                        buildButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
