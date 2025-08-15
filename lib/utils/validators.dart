class AppValidators {
  static String? requiredField(String v, {String label = 'This field'}) {
    if (v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(t);
    return ok ? null : 'Enter a valid email';
  }

  static String? phone(String v, {int min = 7}) {
    final t = v.trim();
    if (t.isEmpty) return 'Phone number is required';
    if (t.length < min) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(v)) return 'Add a special character';
    if (!RegExp(r'\d').hasMatch(v)) return 'Add a number';
    return null;
  }

  static String? confirm(String v, String p) {
    if (v.isEmpty) return 'Confirm your password';
    if (v != p) return 'Passwords do not match';
    return null;
  }
}
