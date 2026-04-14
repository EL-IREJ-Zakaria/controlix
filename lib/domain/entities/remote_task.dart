class RemoteTask {
  const RemoteTask({
    this.id,
    required this.title,
    required this.description,
    required this.script,
    required this.accentHex,
    required this.iconName,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String title;
  final String description;
  final String script;
  final String accentHex;
  final String iconName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RemoteTask copyWith({
    String? id,
    String? title,
    String? description,
    String? script,
    String? accentHex,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RemoteTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      script: script ?? this.script,
      accentHex: accentHex ?? this.accentHex,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
