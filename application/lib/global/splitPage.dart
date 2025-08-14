// lib/global/splitPage.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pinned header + keyboard-safe scrollable body.
/// Uses a builder for the body to avoid re-parenting when insets change.
class SplitPage extends StatelessWidget {
  final Widget header;
  final WidgetBuilder bodyBuilder;

  final double baseHeaderFraction;
  final double minHeader;
  final double maxHeader;
  final double gap;

  final bool ignoreBottomSafeArea;
  final bool collapseOnKeyboard;
  final double? collapsedHeaderHeight;

  const SplitPage({
    super.key,
    required this.header,
    required this.bodyBuilder,        // ⬅️ builder instead of a Widget
    this.baseHeaderFraction = 0.35,
    this.minHeader = 120.0,
    this.maxHeader = 460.0,
    this.gap = 8.0,
    this.ignoreBottomSafeArea = false,
    this.collapseOnKeyboard = true,
    this.collapsedHeaderHeight,
  });

  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.of(context).size;
    final insets   = MediaQuery.viewInsetsOf(context);   // keyboard
    final padding  = MediaQuery.viewPaddingOf(context);  // safe areas
    final kbOpen   = insets.bottom > 0;

    double headerH =
        (size.height * baseHeaderFraction).clamp(minHeader, maxHeader);
    if (collapseOnKeyboard && kbOpen) {
      headerH = (collapsedHeaderHeight ?? minHeader).clamp(minHeader, maxHeader);
    }

    final bottomPad = insets.bottom + (ignoreBottomSafeArea ? 0.0 : padding.bottom);

    return SafeArea(
      bottom: !ignoreBottomSafeArea,
      child: Column(
        children: [
          // Keep a stable identity for the header.
          SizedBox(
            height: headerH,
            width: double.infinity,
            child: KeyedSubtree(
              key: const ValueKey('split-header'),
              child: header,
            ),
          ),
          SizedBox(height: gap.h),
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('split-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: bottomPad),
              clipBehavior: Clip.none,
              // Build a fresh body each frame so it never gets re-parented.
              child: KeyedSubtree(
                key: const ValueKey('split-body'),
                child: Builder(builder: bodyBuilder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
