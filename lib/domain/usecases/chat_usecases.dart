import '../entities/chat_message.dart';
import '../entities/connection_config.dart';
import '../repositories/chat_repository.dart';

class SendChatMessageUseCase {
  const SendChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<ChatMessage> call(
    ConnectionConfig config, {
    required List<ChatMessage> messages,
  }) {
    return _repository.sendChat(config, messages: messages);
  }
}
