import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:application/ui/theme.dart';

class BasePage extends StatelessWidget {

  final Widget Function(
    BuildContext context,
  ) contentBuilder;

  const BasePage({
    required this.contentBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.ivoryWhite,
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                Expanded(
                  child: contentBuilder(
                    context,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
