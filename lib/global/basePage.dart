// lib/global/basePage.dart

import 'package:flutter/material.dart';
import 'package:application/ui/spacing.dart';   // for Insets.page(context)

/*
Goals:
- Keep current look/behavior IDENTICAL by default.
- Remove hard-coded colors; use theme (no AppTheme.* dependency).
- Centralize common page concerns (safe area, scroll, padding, keyboard-dismiss).
- Add optional, reusable knobs without adding boilerplate to pages.

Usage (existing pages keep working unchanged):
  BasePage(contentBuilder: (ctx) => ...)

Optional, when you’re ready:
  BasePage(
    contentBuilder: ...,
    scrollable: true,
    withPagePadding: true,          // uses tokens.screenPadding via Insets.page(context)
    backgroundColor: Colors.white,  // override if needed
    physics: const BouncingScrollPhysics(),
  )
*/

class BasePage extends StatelessWidget {
  /// Builds the page content. Use this instead of passing a raw widget to keep a uniform structure.
  final WidgetBuilder contentBuilder;

  /// If true, wraps content in a scroll view with min-height = viewport.
  final bool scrollable;

  /// If true, the body extends edge-to-edge (no SafeArea). Defaults to previous behavior (false).
  final bool fullscreen;

  /// Optional background color. Defaults to Theme.of(context).scaffoldBackgroundColor.
  final Color? backgroundColor;

  /// Optional scroll physics when [scrollable] is true.
  final ScrollPhysics? physics;

  /// Adds consistent page padding using your tokens (Insets.page(context)).
  /// Default is false to preserve current visuals exactly.
  final bool withPagePadding;

  /// Optional: custom tap handler for the background. Defaults to "dismiss keyboard".
  final VoidCallback? onBackgroundTap;

  const BasePage({
    super.key,
    required this.contentBuilder,
    this.scrollable = false,
    this.fullscreen = false,
    this.backgroundColor,
    this.physics,
    this.withPagePadding = false,
    this.onBackgroundTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keyboard-dismiss on background tap; keep it robust & cheap.
    void _dismissKeyboard() {
      final scope = FocusScope.of(context);
      if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
        scope.unfocus();
      }
    }

    final Widget builtContent = Builder(
      builder: (ctx) {
        final content = Builder(builder: contentBuilder);

        // Optional uniform page padding from tokens; off by default to keep exact visuals.
        final padded = withPagePadding
            ? Padding(padding: Insets.page(ctx), child: content)
            : content;

        if (!scrollable) return padded;

        // Scrollable: minHeight == viewport; keeps footer/pulls-to-bottom layouts stable.
        return LayoutBuilder(
          builder: (ctx, constraints) => SingleChildScrollView(
            physics: physics,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: padded,
            ),
          ),
        );
      },
    );

    final body = fullscreen ? builtContent : SafeArea(child: builtContent);

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures taps on empty areas are caught
      onTap: onBackgroundTap ?? _dismissKeyboard,
      child: Scaffold(
        // Remove hard-coded AppTheme.ivoryWhite; use theme background by default.
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        body: body,
      ),
    );
  }
}
