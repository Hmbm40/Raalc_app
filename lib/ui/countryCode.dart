// lib/widgets/country_picker_launcher.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:country_code_picker/src/country_codes.dart' as ccp_data;
import '../ui/countryCodeBridge.dart';

/// Presents a country dial code selector:
/// • iOS → true native UIKit sheet via MethodChannel
/// • Others → simple Material bottom sheet fallback
///
/// Returns the selected dial code (e.g. "+971") or null if cancelled.
Future<String?> pickCountryDialCode(
  BuildContext context, {
  String? initialDialCode,
}) async {
  // Build once per run; cache to avoid repeated mapping work.
  final countries = _countriesCache ??= ccp_data.codes
      .map<Map<String, String>>((c) => {
            'name': (c['name'] ?? '').toString(),
            'code': (c['code'] ?? '').toString(),
            'dialCode': (c['dial_code'] ?? '').toString(),
          })
      .where((m) => m['dialCode']!.isNotEmpty)
      .toList(growable: false);

  if (Platform.isIOS) {
    final res = await NativeCountryPicker.present(
      countries,
      initialDialCode: initialDialCode,
    );
    return res?['dialCode'];
  }

  // Material fallback for non-iOS
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (_) => ListView.separated(
      itemCount: countries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = countries[i];
        return ListTile(
          dense: true,
          title: Text('${c['dialCode']}  •  ${c['name']}'),
          onTap: () => Navigator.pop(context, c['dialCode']),
          trailing: (c['dialCode'] == initialDialCode)
              ? const Icon(Icons.check, size: 18)
              : null,
        );
      },
    ),
  );
}

// Simple in-memory cache of the mapped list
List<Map<String, String>>? _countriesCache;
