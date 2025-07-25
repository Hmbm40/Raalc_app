import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/global/base_page.dart';
import 'package:application/ui/progressLine.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/spacing.dart';
import 'package:application/ui/buttons.dart';
import 'package:application/LoginSignup/login.dart'; // 🔸 Update this import if needed

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasViewedLastPage = false;

  final List<String> images = [
    'assets/images/test1.jpeg',
    'assets/images/test2.jpeg',
    'assets/images/test3.jpeg',
  ];

  final List<Map<String, String>> slideContent = [
    {
      'title': 'EVERYTHING YOU NEED, ALL IN ONE PLACE',
      'description':
          'All the tools and resources you need in one platform. Accessing your essentials is fast and hassle-free.',
      'tag': 'Centralization',
    },
    {
      'title': 'TAILORED FOR YOUR NEEDS',
      'description':
          'Custom solutions that adapt to your workflow, giving you full control and flexibility.',
      'tag': 'Personalization',
    },
    {
      'title': 'WELCOME TO RAALC',
      'description':
          'Your data is encrypted, your experience is stable, and your trust is never compromised.',
      'tag': 'Security',
    },
  ];

  void _nextSlide() {
    if (_currentPage < images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTag(String tag) {
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
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
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
            fontSize: AppTheme.tagFont,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    final isLastPage = _hasViewedLastPage;

    if (isLastPage) {
      return GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
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
      return PrimaryCircleButton(
        icon: Icons.arrow_forward,
        onPressed: _nextSlide,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      contentBuilder: (context) {
        return Column(
          children: [
            SizedBox(
              height: 0.6.sh,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    if (index == images.length - 1) {
                      _hasViewedLastPage = true;
                    }
                  });
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
                        currentPage: _currentPage,
                        pageCount: images.length,
                        totalPages: images.length,
                      ),
                    ),
                    SizedBox(height: AppSpacing.mediumVertical),
                    Text(
                      slideContent[_currentPage]['title']!,
                      style: TextStyle(
                        fontFamily: 'Poppins-ExtraBold',
                        fontSize: AppTheme.headlineFont,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SizedBox(height: AppSpacing.mediumVertical),
                    Text(
                      slideContent[_currentPage]['description']!,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: 'Poppins-Regular',
                        fontSize: AppTheme.bodyFont,
                        color: AppTheme.midnightBlue,
                      ),
                    ),
                    SizedBox(height: AppSpacing.largerVertical),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTag(slideContent[_currentPage]['tag']!),
                        _buildButton(),
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
