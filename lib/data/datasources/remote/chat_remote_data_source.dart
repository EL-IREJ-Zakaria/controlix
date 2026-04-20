import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/connection_config.dart';
import '../../models/chat_message_model.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ChatMessageModel> sendChat(
    ConnectionConfig config, {
    required List<ChatMessageModel> messages,
  }) async {
    Map<String, dynamic> response;
    try {
      response = await _apiClient.post(
        config,
        '/api/chat',
        body: <String, dynamic>{
          'messages': messages
              .map((message) => message.toRequestJson())
              .toList(),
        },
      );
    } on AppException catch (error) {
      if (error.statusCode == 404) {
        throw const AppException(
          'Endpoint /api/chat introuvable sur l’agent Windows. '
          'Mets à jour/redémarre l’agent (version avec la route /api/chat).',
          statusCode: 404,
        );
      }
      rethrow;
    }

    final reply =
        response['reply'] as String? ??
        (response['message'] is Map<String, dynamic>
            ? (response['message'] as Map<String, dynamic>)['content']
                  as String?
            : null) ??
        response['text'] as String?;

    if (reply == null || reply.trim().isEmpty) {
      throw const AppException(
        'Invalid response from /api/chat. Expected a non-empty "reply" field.',
      );
    }

    return ChatMessageModel.assistant(
      id: _simpleId(),
      content: reply.trim(),
      createdAt: DateTime.now(),
    );
  }

  String _simpleId() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    return 'asst_$micros';
  }
}
