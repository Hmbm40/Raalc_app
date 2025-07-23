import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        backgroundColor: const Color.fromARGB(255, 255, 254, 255),
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
