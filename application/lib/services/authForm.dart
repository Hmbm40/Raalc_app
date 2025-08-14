import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../ui/spacing.dart';

class AuthForm extends HookConsumerWidget {
  final List<Widget> fields;
  final List<Widget> primaryButtons;
  final List<Widget> secondaryActions;
  final Widget? footer;
  final EdgeInsets? padding;
  final List<Widget>? extraWidgets;
  final GlobalKey<FormState>? formKey;
  final bool wrapInForm;
  final double? maxContentWidth;

  /// Let these be nullable so we can set them in build()
  final double? fieldSpacing;
  final double? sectionSpacing;
  final double? primaryButtonsSpacing;

  const AuthForm({
    super.key,
    required this.fields,
    required this.primaryButtons,
    this.secondaryActions = const [],
    this.footer,
    this.padding,
    this.extraWidgets,
    this.formKey,
    this.wrapInForm = true,
    this.maxContentWidth,
    this.fieldSpacing,
    this.sectionSpacing,
    this.primaryButtonsSpacing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveFieldSpacing =
        fieldSpacing ?? AppSpacing.mediumVertical;
    final effectiveSectionSpacing =
        sectionSpacing ?? AppSpacing.largeVertical;
    final effectivePrimaryButtonsSpacing =
        primaryButtonsSpacing ?? AppSpacing.largeVertical;

    final localFormKey =
        useMemoized(() => GlobalKey<FormState>(), const []);

    Widget content = Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.page),
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Montserrat'),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth ?? double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        fields[i],
                        if (i != fields.length - 1)
                          SpacingExtensions(effectiveFieldSpacing)
                              .verticalSpace,
                      ],
                    ],
                  ),
                ),

                SpacingExtensions(effectiveSectionSpacing).verticalSpace,

                if (extraWidgets != null && extraWidgets!.isNotEmpty) ...[
                  for (var i = 0; i < extraWidgets!.length; i++) ...[
                    extraWidgets![i],
                    if (i != extraWidgets!.length - 1)
                      SpacingExtensions(effectiveFieldSpacing).verticalSpace,
                  ],
                  SpacingExtensions(effectiveSectionSpacing).verticalSpace,
                ],

                for (var i = 0; i < primaryButtons.length; i++) ...[
                  primaryButtons[i],
                  if (i != primaryButtons.length - 1)
                    SpacingExtensions(effectivePrimaryButtonsSpacing)
                        .verticalSpace,
                ],

                if (secondaryActions.isNotEmpty) ...[
                  SpacingExtensions(effectiveSectionSpacing).verticalSpace,
                  for (var i = 0; i < secondaryActions.length; i++) ...[
                    secondaryActions[i],
                    if (i != secondaryActions.length - 1)
                      SpacingExtensions(effectiveFieldSpacing).verticalSpace,
                  ],
                ],

                if (footer != null) ...[
                  SpacingExtensions(effectiveSectionSpacing).verticalSpace,
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (wrapInForm) {
      content = Form(
        key: formKey ?? localFormKey,
        child: content,
      );
    }

    return content;
  }
}
