import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.createdAt,
    super.deliveryStatus,
  });

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      role: entity.role,
      content: entity.content,
      createdAt: entity.createdAt,
      deliveryStatus: entity.deliveryStatus,
    );
  }

  factory ChatMessageModel.assistant({
    required String id,
    required String content,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id,
      role: ChatRole.assistant,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      deliveryStatus: ChatDeliveryStatus.sent,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return <String, dynamic>{
      'role': switch (role) {
        ChatRole.user => 'user',
        ChatRole.assistant => 'assistant',
        ChatRole.developer => 'developer',
      },
      'content': content,
    };
  }
}
