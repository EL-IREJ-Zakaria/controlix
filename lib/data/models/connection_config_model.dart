import '../../domain/entities/connection_config.dart';

class ConnectionConfigModel extends ConnectionConfig {
  const ConnectionConfigModel({
    required super.ipAddress,
    required super.secretKey,
    required super.port,
  });

  factory ConnectionConfigModel.fromEntity(ConnectionConfig entity) {
    return ConnectionConfigModel(
      ipAddress: entity.ipAddress,
      secretKey: entity.secretKey,
      port: entity.port,
    );
  }

  factory ConnectionConfigModel.fromJson(Map<String, dynamic> json) {
    return ConnectionConfigModel(
      ipAddress: json['ipAddress'] as String? ?? '',
      secretKey: json['secretKey'] as String? ?? '',
      port: json['port'] as int? ?? 8765,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ipAddress': ipAddress,
      'secretKey': secretKey,
      'port': port,
    };
  }
}
