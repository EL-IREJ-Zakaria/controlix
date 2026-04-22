class Validators {
  const Validators._();

  static final RegExp _ipv4Pattern = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  static String? validatePort(String? value) {
    final candidate = value?.trim() ?? '';
    if (candidate.isEmpty) {
      return null;
    }

    final port = int.tryParse(candidate);
    if (port == null) {
      return 'Use a numeric port.';
    }
    if (port < 1 || port > 65535) {
      return 'Use a port between 1 and 65535.';
    }
    return null;
  }

  static String? validateIpAddress(String? value) {
    final candidate = value?.trim() ?? '';
    if (candidate.isEmpty) {
      return 'Enter the Windows machine IP address.';
    }
    if (!_ipv4Pattern.hasMatch(candidate)) {
      return 'Use a valid LAN IPv4 address.';
    }
    return null;
  }

  static String? validateSecretKey(String? value) {
    final candidate = value?.trim() ?? '';
    if (candidate.isEmpty) {
      return 'Enter the shared secret key.';
    }
    if (candidate.length < 8) {
      return 'Use at least 8 characters for the shared secret.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    final candidate = value?.trim() ?? '';
    if (candidate.isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
