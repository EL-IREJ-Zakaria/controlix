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
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const AppException(
          'Clé partagée invalide. Vérifie que la clé dans l’app correspond à celle du serveur '
          '(CONTROLIX_SECRET_KEY pour l’agent, ou CONTROLIX_SHARED_KEY pour le backend Node).',
          statusCode: 401,
        );
      }

      if (error.statusCode == 404) {
        throw AppException(
          'Endpoint /api/chat introuvable sur ${config.baseUrl}. '
          'Vérifie l’IP/le port, puis mets à jour/redémarre l’agent Windows (version avec la route /api/chat).',
          statusCode: 404,
        );
      }

      final message = error.message.toLowerCase();
      if (error.statusCode == 500 && message.contains('openai_api_key')) {
        throw const AppException(
          'OPENAI_API_KEY manquante sur le PC Windows. Ajoute-la dans le fichier `.env` de l’agent, puis redémarre.',
          statusCode: 500,
        );
      }

      if (error.statusCode == 503 &&
          (message.contains('openai sdk') ||
              message.contains('pip install openai'))) {
        throw const AppException(
          'Le SDK OpenAI n’est pas installé sur le PC Windows. Installe-le (ex: `pip install -r agent/requirements.txt`) puis redémarre l’agent.',
          statusCode: 503,
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
