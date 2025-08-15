// lib/LoginSignup/start.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:application/global/basePage.dart';
import 'package:application/ui/progressLine.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/spacing.dart';
import 'package:application/ui/circleButton.dart';
import 'package:application/LoginSignup/login.dart';
import 'dart:math' as math; // for cacheWidth calc

class StartPage extends HookConsumerWidget {
  const StartPage({super.key});

  static const List<String> images = [
    'assets/images/test1.webp', // converted to webp
    'assets/images/test2.webp',
    'assets/images/test3.webp',
  ];

  int _targetCacheWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return math.max(1, (size.width * dpr).round());
  }

  Future<void> _precacheAround(
    BuildContext context, {
    required int index,
  }) async {
    final candidates = <int>{index, index - 1, index + 1}
        .where((i) => i >= 0 && i < images.length);
    for (final i in candidates) {
      await precacheImage(AssetImage(images[i]), context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final hasViewedLastPage = useState(false);

    // Precache first + neighbors on mount
    useEffect(() {
      Future.microtask(() async {
        await _precacheAround(context, index: 0);
      });
      return null;
    }, []);

    void nextSlide() {
      if (currentPage.value < StartPage.images.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    Widget buildTag(String tag) {
      final textScale = MediaQuery.textScaleFactorOf(context);
      final double tagSize = (context.t.labelLarge?.fontSize ?? 14.sp) * textScale;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return SlideTransition(
            position: slide,
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
              fontSize: tagSize,
              color: Palette.gray, // your single gray
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
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
                builder: (context) => const LoginPage(),
              ),
            );
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: context.palette.goldenTan,
              shape: BoxShape.circle,
              boxShadow: const [
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

    final textScale = MediaQuery.textScaleFactorOf(context);
    final double headlineSize = (context.t.headlineSmall?.fontSize ?? 24.sp) * textScale;
    final double bodySize = (context.t.bodyMedium?.fontSize ?? 14.sp) * textScale;

    /// Render per-slide copy (0, 1 unchanged; 2 now has its own placeholder)
    Widget buildSlideCopy(int index) {
      switch (index) {
        case 0:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EVERYTHING YOU NEED, ALL IN ONE PLACE',
                style: TextStyle(
                  fontFamily: 'Poppins-ExtraBold',
                  fontSize: headlineSize,
                  color: Colors.black,
                ),
              ),
              Gap.vx(Space.xl),
              Text(
                'All the tools and resources you need in one platform. '
                'Accessing your essentials is fast and hassle-free.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Poppins-Regular',
                  fontSize: bodySize,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          );
        case 1:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TAILORED FOR YOUR NEEDS',
                style: TextStyle(
                  fontFamily: 'Poppins-ExtraBold',
                  fontSize: headlineSize,
                  color: Colors.black,
                ),
              ),
              Gap.vx(Space.xl),
              Text(
                'Custom solutions that adapt to your workflow, giving you full '
                'control and flexibility.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Poppins-Regular',
                  fontSize: bodySize,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          );
        case 2: // ✅ new placeholder content for slide 3
        default:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SECURITY & PRIVACY',
                style: TextStyle(
                  fontFamily: 'Poppins-ExtraBold',
                  fontSize: headlineSize,
                  color: Colors.black,
                ),
              ),
              Gap.vx(Space.xl),
              Text(
                'Your data is encrypted and your trust is never compromised. '
                'This is a placeholder section — adjust copy as needed.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'Poppins-Regular',
                  fontSize: bodySize,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          );
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
                onPageChanged: (index) async {
                  currentPage.value = index;
                  if (index == StartPage.images.length - 1) {
                    hasViewedLastPage.value = true;
                  }
                  // Keep current & neighbors hot
                  await _precacheAround(context, index: index);
                },
                itemCount: StartPage.images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    StartPage.images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    cacheWidth: _targetCacheWidth(context),
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                  );
                },
              ),
            ),
            Expanded(
              child: Container
              (
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  Spacing.h(Space.xl),
                  Spacing.v(Space.xl),
                  Spacing.h(Space.xl),
                  40.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.tokens.radiusLg),
                    topRight: Radius.circular(context.tokens.radiusLg),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ProgressLine(
                        currentPage: currentPage.value,
                        totalPages: StartPage.images.length,
                      ),
                    ),
                    Gap.vx(Space.xl),

                    // 🔁 Per-slide content (slide 3 now has its own placeholder)
                    buildSlideCopy(currentPage.value),

                    Gap.v(40),
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
