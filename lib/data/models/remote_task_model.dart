import '../../domain/entities/remote_task.dart';

class RemoteTaskModel extends RemoteTask {
  const RemoteTaskModel({
    super.id,
    required super.title,
    required super.description,
    required super.script,
    required super.accentHex,
    required super.iconName,
    super.createdAt,
    super.updatedAt,
  });

  factory RemoteTaskModel.fromEntity(RemoteTask entity) {
    return RemoteTaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      script: entity.script,
      accentHex: entity.accentHex,
      iconName: entity.iconName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory RemoteTaskModel.fromJson(Map<String, dynamic> json) {
    return RemoteTaskModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      script: json['script'] as String? ?? '',
      accentHex: json['accent_hex'] as String? ?? '#4F46E5',
      iconName: json['icon'] as String? ?? 'bolt',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'script': script,
      'accent_hex': accentHex,
      'icon': iconName,
    };
  }

  static DateTime? _parseDate(Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawValue)?.toLocal();
  }
}
