// lib/utils/phone.dart
String buildE164(String cc, String local) {
  final country = cc.startsWith('+') ? cc : '+$cc';
  final digits = local.replaceAll(RegExp(r'\D'), '');
  return '$country$digits';
}
