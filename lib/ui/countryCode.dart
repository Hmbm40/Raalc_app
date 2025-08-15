// lib/widgets/country_picker_launcher.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:country_code_picker/src/country_codes.dart' as ccp_data;
import '../ui/countryCodeBridge.dart'; // must expose NativeCountryPicker.present(...)

/// Small model we return to the caller (dial code + ISO + flag + name).
class CountryPickResult {
  final String name;      // e.g. "United Arab Emirates"
  final String isoCode;   // e.g. "AE"
  final String dialCode;  // e.g. "+971"
  final String flagEmoji; // e.g. "🇦🇪"

  const CountryPickResult({
    required this.name,
    required this.isoCode,
    required this.dialCode,
    required this.flagEmoji,
  });

  /// Build from code/name/dialCode map.
  factory CountryPickResult.fromMap(Map<String, String> m) {
    final code = (m['code'] ?? '').toUpperCase();
    return CountryPickResult(
      name: m['name'] ?? '',
      isoCode: code,
      dialCode: m['dialCode'] ?? '',
      flagEmoji: isoToFlagEmoji(code),
    );
  }
}

/// Convert ISO-2 (e.g. "AE") to Unicode flag emoji.
String isoToFlagEmoji(String iso) {
  if (iso.length != 2) return '🏳️';
  final base = 0x1F1E6;
  final a = iso.codeUnitAt(0) - 0x41; // 'A'
  final b = iso.codeUnitAt(1) - 0x41; // 'A'
  if (a < 0 || a > 25 || b < 0 || b > 25) return '🏳️';
  return String.fromCharCode(base + a) + String.fromCharCode(base + b);
}

/// In-memory cache of parsed countries (fast + no rebuild churn)
List<CountryPickResult>? _cache;

/// Get or build the parsed/cached list once.
List<CountryPickResult> _countries() {
  return _cache ??= ccp_data.codes
      .map((raw) => {
            'name': (raw['name'] ?? '').toString(),
            'code': (raw['code'] ?? '').toString(),
            'dialCode': (raw['dial_code'] ?? '').toString(),
          })
      .where((m) => (m['dialCode'] ?? '').isNotEmpty)
      .map((m) => CountryPickResult.fromMap(m))
      .toList(growable: false);
}

/// Utility: find a country by dial code (e.g. "+971")
CountryPickResult? countryForDial(String? dial) {
  if (dial == null || dial.isEmpty) return null;
  for (final c in _countries()) {
    if (c.dialCode == dial) return c;
  }
  return null;
}

/// Presents the country code selector:
/// • iOS → native UIKit sheet via MethodChannel (returns {name, code, dialCode})
/// • Others → Material bottom sheet with flags
///
/// Returns selected country (with flag) or null if cancelled.
Future<CountryPickResult?> pickCountryDialCode(
  BuildContext context, {
  String? initialDialCode,
}) async {
  final countries = _countries();

  if (Platform.isIOS) {
    // Native iOS returns a map: { name, code, dialCode }
    final res = await NativeCountryPicker.present(
      countries
          .map((c) => {
                'name': c.name,
                'code': c.isoCode,
                'dialCode': c.dialCode,
              })
          .toList(growable: false),
      initialDialCode: initialDialCode,
    );
    if (res == null) return null;
    return CountryPickResult.fromMap(Map<String, String>.from(res));
  }

  // Material fallback with flag leading
  final selected = await showModalBottomSheet<CountryPickResult>(
    context: context,
    showDragHandle: true,
    builder: (_) => ListView.separated(
      itemCount: countries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = countries[i];
        final isSelected = c.dialCode == initialDialCode;
        return ListTile(
          dense: true,
          leading: Text(c.flagEmoji, style: const TextStyle(fontSize: 20)),
          title: Text('${c.name} (${c.dialCode})'),
          trailing: isSelected ? const Icon(Icons.check, size: 18) : null,
          onTap: () => Navigator.pop(context, c),
        );
      },
    ),
  );

  return selected;
}
