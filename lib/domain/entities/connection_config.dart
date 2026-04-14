import '../../core/constants/app_constants.dart';

class ConnectionConfig {
  const ConnectionConfig({
    required this.ipAddress,
    required this.secretKey,
    this.port = AppConstants.agentPort,
  });

  final String ipAddress;
  final String secretKey;
  final int port;

  String get baseUrl => 'http://$ipAddress:$port';

  bool get isComplete => ipAddress.isNotEmpty && secretKey.isNotEmpty;
}
