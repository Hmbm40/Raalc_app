import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../ui/spacing.dart';

class AuthForm extends HookConsumerWidget {
  final List<Widget> fields;
  final List<Widget> primaryButtons;
  final List<Widget> secondaryActions;
  final Widget? footer;
  final EdgeInsets? padding;
  final List<Widget>? extraWidgets; // ✅ NEW

  const AuthForm({
    super.key,
    required this.fields,
    required this.primaryButtons,
    this.secondaryActions = const [],
    this.footer,
    this.padding,
    this.extraWidgets, // ✅ NEW
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.page),
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Montserrat'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var field in fields) ...[
              field,
              SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,
            ],

            SpacingExtensions(AppSpacing.smallVertical).verticalSpace,

            if (extraWidgets != null) ...[
              for (var widget in extraWidgets!) ...[
                widget,
                SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,
              ],
            ],

            for (var button in primaryButtons) ...[
              button,
              SpacingExtensions(AppSpacing.largeVertical).verticalSpace,
            ],

            if (secondaryActions.isNotEmpty) ...[
              for (var action in secondaryActions) ...[
                action,
                SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,
              ]
            ],

            if (footer != null) ...[
              footer!,
              SpacingExtensions(AppSpacing.mediumVertical).verticalSpace,
            ],
          ],
        ),
      ),
    );
  }
}
