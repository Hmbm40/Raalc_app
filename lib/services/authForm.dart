// lib/ui/authForm.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../ui/spacing.dart'; // Space, Insets, Spacing, Gap

class AuthForm extends HookConsumerWidget {
  /// Main input widgets (TextFields etc.)
  final List<Widget> fields;

  /// Primary actions (e.g., Submit, Continue)
  final List<Widget> primaryButtons;

  /// Secondary actions (e.g., "Forgot password", links)
  final List<Widget> secondaryActions;

  /// Optional footer (e.g., terms text, disclaimers)
  final Widget? footer;

  /// Optional page padding; if null, uses Insets.page(context)
  final EdgeInsets? padding;

  /// Any extra widgets to insert between fields and primary buttons
  final List<Widget>? extraWidgets;

  /// Provide your own Form key, or one will be created if [wrapInForm] is true
  final GlobalKey<FormState>? formKey;

  /// If true, wraps everything in a Form
  final bool wrapInForm;

  /// Constrain column width (e.g., 480) — useful on tablets/desktop
  final double? maxContentWidth;

  // ── Token-based spacing (preferred) ────────────────────────────────────────
  final Space? fieldSpaceToken;            // spacing between input fields
  final Space? sectionSpaceToken;          // spacing between sections
  final Space? primaryButtonsSpaceToken;   // spacing between stacked primary buttons
  final Space? secondaryActionsSpaceToken; // spacing above & below the whole secondary block  ✅
  final Space? secondaryItemsSpaceToken;   // spacing between items inside secondary block     ✅

  // ── Back-compat absolute spacing (already scaled). If set, overrides token.
  final double? fieldSpacing;
  final double? sectionSpacing;
  final double? primaryButtonsSpacing;
  final double? secondaryActionsSpacing; // above & below the whole block
  final double? secondaryItemsSpacing;   // between items inside the block

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
    // token-based (preferred)
    this.fieldSpaceToken,
    this.sectionSpaceToken,
    this.primaryButtonsSpaceToken,
    this.secondaryActionsSpaceToken,
    this.secondaryItemsSpaceToken,
    // back-compat
    this.fieldSpacing,
    this.sectionSpacing,
    this.primaryButtonsSpacing,
    this.secondaryActionsSpacing,
    this.secondaryItemsSpacing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve spacings
    final double gapFields = fieldSpaceToken != null
        ? Spacing.v(fieldSpaceToken!)
        : (fieldSpacing ?? Spacing.v(Space.lg));       // ~12.h

    final double gapSections = sectionSpaceToken != null
        ? Spacing.v(sectionSpaceToken!)
        : (sectionSpacing ?? Spacing.v(Space.xl));     // ~24.h

    final double gapPrimaryButtons = primaryButtonsSpaceToken != null
        ? Spacing.v(primaryButtonsSpaceToken!)
        : (primaryButtonsSpacing ?? Spacing.v(Space.xxl)); // ~24.h

    // Larger margins around the whole secondary block
    final double gapSecondaryBlock = secondaryActionsSpaceToken != null
        ? Spacing.v(secondaryActionsSpaceToken!)
        : (secondaryActionsSpacing ?? Spacing.v(Space.xxl)); // ~32.h default

    // Spacing **between** secondary items (e.g., between Register and Forgot Password)
    final double gapSecondaryItems = secondaryItemsSpaceToken != null
        ? Spacing.v(secondaryItemsSpaceToken!)
        : (secondaryItemsSpacing ?? gapFields); // default to field gap for BC

    final localFormKey = useMemoized(() => GlobalKey<FormState>(), const []);

    Widget content = Padding(
      padding: padding ?? Insets.page(context),
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
                // Fields
                AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        fields[i],
                        if (i != fields.length - 1)
                          SizedBox(height: gapFields),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: gapSections),

                // Extra widgets
                if (extraWidgets != null && extraWidgets!.isNotEmpty) ...[
                  for (var i = 0; i < extraWidgets!.length; i++) ...[
                    extraWidgets![i],
                    if (i != extraWidgets!.length - 1)
                      SizedBox(height: gapFields),
                  ],
                  SizedBox(height: gapSections),
                ],

                // Primary buttons
                for (var i = 0; i < primaryButtons.length; i++) ...[
                  primaryButtons[i],
                  if (i != primaryButtons.length - 1)
                    SizedBox(height: gapPrimaryButtons),
                ],

                // Secondary actions
                if (secondaryActions.isNotEmpty) ...[
                  SizedBox(height: gapSecondaryBlock), // ↑ bigger top margin
                  for (var i = 0; i < secondaryActions.length; i++) ...[
                    secondaryActions[i],
                    if (i != secondaryActions.length - 1)
                      SizedBox(height: gapSecondaryItems), // ← between items
                  ],
                  SizedBox(height: gapSecondaryBlock), // ↓ bigger bottom margin
                ],

                // Footer
                if (footer != null) ...[
                  SizedBox(height: gapSections),
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
