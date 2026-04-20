import '../entities/chat_message.dart';
import '../entities/connection_config.dart';

abstract class ChatRepository {
  Future<ChatMessage> sendChat(
    ConnectionConfig config, {
    required List<ChatMessage> messages,
  });
}
