import 'package:hooks_riverpod/hooks_riverpod.dart';

class OtpPayload {
  final String email;
  final String phone;
  final String name;
  final String password; // only until we finish register flow; not persisted
  final String? otpFromServer; // dev-only convenience if backend returns it
  final String? otpToken;      // opaque token from backend (prefer this)
  final DateTime expiresAt;
  final int attempts;

  const OtpPayload({
    required this.email,
    required this.phone,
    required this.name,
    required this.password,
    this.otpFromServer,
    this.otpToken,
    required this.expiresAt,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  OtpPayload incAttempts() => OtpPayload(
    email: email, phone: phone, name: name, password: password,
    otpFromServer: otpFromServer, otpToken: otpToken,
    expiresAt: expiresAt, attempts: attempts + 1,
  );
}

final otpStateProvider = StateProvider<OtpPayload?>((_) => null);
