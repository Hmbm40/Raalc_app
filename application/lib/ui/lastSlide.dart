import 'package:flutter/material.dart';
import 'package:application/ui/theme.dart';
import 'package:application/ui/spacing.dart';

const String lastSlideTitle = 'WELCOME TO RAALC';
const String lastSlideDescription = 'Your data is encrypted and your trust is never compromised.';

class LastSlideContent extends StatelessWidget {
  final String title;
  final String description;

  const LastSlideContent({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins-ExtraBold',
            fontSize: AppTheme.headlineFont * textScale,
            color: AppTheme.navyBlue,
          ),
        ),
        SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Poppins-Regular',
            fontSize: AppTheme.bodyFont * textScale,
            color: AppTheme.midnightBlue,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
