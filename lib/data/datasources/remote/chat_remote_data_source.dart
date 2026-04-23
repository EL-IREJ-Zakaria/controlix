import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/connection_config.dart';
import '../../models/chat_message_model.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> _postChat(
    ConnectionConfig config,
    List<ChatMessageModel> messages,
  ) {
    return _apiClient.post(
      config,
      '/api/chat',
      body: <String, dynamic>{
        'messages': messages.map((message) => message.toRequestJson()).toList(),
      },
    );
  }

  Future<Map<String, dynamic>?> _tryNodeFallback(
    ConnectionConfig config,
    List<ChatMessageModel> messages,
  ) async {
    if (config.port == 8787) {
      return null;
    }

    final nodeConfig = ConnectionConfig(
      ipAddress: config.ipAddress,
      secretKey: config.secretKey,
      port: 8787,
    );

    try {
      return await _postChat(nodeConfig, messages);
    } on AppException catch (nodeError) {
      if (nodeError.statusCode == 401 || nodeError.statusCode == 403) {
        throw const AppException(
          'Le serveur chat répond, mais la clé partagée est invalide. '
          'Si tu utilises le backend Node, configure CONTROLIX_SHARED_KEY et mets la même valeur dans l’app.',
          statusCode: 401,
        );
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> _sendChatRequest(
    ConnectionConfig config,
    List<ChatMessageModel> messages,
  ) async {
    try {
      return await _postChat(config, messages);
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const AppException(
          'Clé partagée invalide. Vérifie que la clé dans l’app correspond à celle du serveur '
          '(CONTROLIX_SECRET_KEY pour l’agent, ou CONTROLIX_SHARED_KEY pour le backend Node).',
          statusCode: 401,
        );
      }

      // Common setup: tasks on the agent (8765), chat on the Node example (8787).
      // If /api/chat is missing (404) OR the target port is unreachable (statusCode == null),
      // retry the chat request on 8787 automatically.
      if ((error.statusCode == null || error.statusCode == 404)) {
        final fallback = await _tryNodeFallback(config, messages);
        if (fallback != null) {
          return fallback;
        }
      }

      if (error.statusCode == 404) {
        // Still failing: distinguish "agent reachable but missing chat route" vs "wrong port/service".
        try {
          await _apiClient.get(config, '/health');
          throw AppException(
            'Ton agent répond bien sur ${config.baseUrl}, mais la route /api/chat est absente. '
            'Mets à jour/redémarre l’agent Windows (version avec la route /api/chat), ou utilise le port 8787 si tu passes par le backend Node.',
            statusCode: 404,
          );
        } on AppException catch (healthError) {
          if (healthError.statusCode == 401 || healthError.statusCode == 403) {
            throw const AppException(
              'Clé partagée invalide. Vérifie que la clé dans l’app correspond à celle du serveur '
              '(CONTROLIX_SECRET_KEY pour l’agent, ou CONTROLIX_SHARED_KEY pour le backend Node).',
              statusCode: 401,
            );
          }

          throw AppException(
            'Endpoint /api/chat introuvable sur ${config.baseUrl}. '
            'Vérifie l’IP/le port (agent: 8765, backend Node: 8787), puis redémarre/met à jour le serveur.',
            statusCode: 404,
          );
        }
      }

      if (error.statusCode == null) {
        throw AppException(
          'Impossible de joindre le serveur sur ${config.baseUrl}. '
          'Vérifie que le PC Windows est allumé, sur le même Wi‑Fi, et que le port est correct (agent: 8765, backend Node: 8787).',
        );
      }

      final message = error.message.toLowerCase();
      if (error.statusCode == 500 &&
          (message.contains('openai_api_key') ||
              message.contains('gemini_api_key'))) {
        throw const AppException(
          'Clé API manquante sur le PC Windows. Ajoute OPENAI_API_KEY ou GEMINI_API_KEY dans le fichier `.env` du serveur, puis redémarre.',
          statusCode: 500,
        );
      }

      if (error.statusCode == 503 &&
          (message.contains('openai sdk') ||
              message.contains('pip install openai') ||
              message.contains('gemini api error') ||
              message.contains('gemini api request failed'))) {
        throw AppException(
          'Le serveur chat n’arrive pas à contacter le fournisseur IA. '
          'Vérifie GEMINI_API_KEY/OPENAI_API_KEY sur le PC Windows, puis redémarre le serveur. '
          'Détail: ${error.message}',
          statusCode: 503,
        );
      }

      rethrow;
    }
  }

  Future<ChatMessageModel> sendChat(
    ConnectionConfig config, {
    required List<ChatMessageModel> messages,
  }) async {
    final response = await _sendChatRequest(config, messages);

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
