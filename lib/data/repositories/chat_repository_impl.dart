import '../../domain/entities/chat_message.dart';
import '../../domain/entities/connection_config.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<ChatMessage> sendChat(
    ConnectionConfig config, {
    required List<ChatMessage> messages,
  }) async {
    final payload = messages
        .where((message) => message.content.trim().isNotEmpty)
        .where((message) => message.role != ChatRole.developer)
        .map(ChatMessageModel.fromEntity)
        .toList(growable: false);

    return _remoteDataSource.sendChat(config, messages: payload);
  }
}
