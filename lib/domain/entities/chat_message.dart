enum ChatRole { user, assistant, developer }

enum ChatDeliveryStatus { sending, sent, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.deliveryStatus = ChatDeliveryStatus.sent,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final ChatDeliveryStatus deliveryStatus;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
  bool get isDeveloper => role == ChatRole.developer;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? createdAt,
    ChatDeliveryStatus? deliveryStatus,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
