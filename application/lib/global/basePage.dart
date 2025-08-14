import 'package:flutter/material.dart';
import 'package:application/ui/theme.dart';

class BasePage extends StatelessWidget {
  final WidgetBuilder contentBuilder;
  final bool scrollable;
  final bool fullscreen; // NEW

  const BasePage({
    super.key,
    required this.contentBuilder,
    this.scrollable = false,
    this.fullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          height: constraints.maxHeight,
          width: double.infinity,
          child: contentBuilder(context),
        );

        return scrollable
            ? SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: content,
                ),
              )
            : content;
      },
    );

    return GestureDetector(
      
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild?.context?.widget is! EditableText) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.ivoryWhite,
        body: fullscreen ? body : SafeArea(child: body),
      ),
    );
  }
}
