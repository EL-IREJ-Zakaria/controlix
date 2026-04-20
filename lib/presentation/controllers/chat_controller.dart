import 'package:flutter/foundation.dart';

import '../../core/error/app_exception.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/connection_config.dart';
import '../../domain/usecases/chat_usecases.dart';

class ChatController extends ChangeNotifier {
  ChatController({required SendChatMessageUseCase sendChatMessage})
    : _sendChatMessage = sendChatMessage;

  final SendChatMessageUseCase _sendChatMessage;

  List<ChatMessage> _messages = const <ChatMessage>[];
  bool _isSending = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  void bootstrap() {
    if (_messages.isNotEmpty) {
      return;
    }

    _messages = <ChatMessage>[
      ChatMessage(
        id: _simpleId('dev'),
        role: ChatRole.developer,
        content:
            'You are Controlix Assistant, a concise professional assistant for a Windows automation app. '
            'Be clear, practical, and safe. When needed, ask one short clarifying question.',
        createdAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  void clear() {
    _messages = const <ChatMessage>[];
    _errorMessage = null;
    _isSending = false;
    notifyListeners();
    bootstrap();
  }

  Future<void> send(ConnectionConfig config, {required String prompt}) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || _isSending) {
      return;
    }

    final userMessage = ChatMessage(
      id: _simpleId('user'),
      role: ChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
      deliveryStatus: ChatDeliveryStatus.sending,
    );

    _messages = <ChatMessage>[..._messages, userMessage];
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final context = _buildContext(window: 24);
      final assistant = await _sendChatMessage(config, messages: context);

      _messages = _markDelivery(
        userMessage.id,
        ChatDeliveryStatus.sent,
        messages: <ChatMessage>[..._messages, assistant],
      );
    } on AppException catch (error) {
      _messages = _markDelivery(
        userMessage.id,
        ChatDeliveryStatus.failed,
        messages: _messages,
      );
      _errorMessage = error.message;
    } catch (error) {
      _messages = _markDelivery(
        userMessage.id,
        ChatDeliveryStatus.failed,
        messages: _messages,
      );
      _errorMessage = 'Unexpected error: $error';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> retryFailed(ConnectionConfig config, String messageId) async {
    if (_isSending) {
      return;
    }

    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1) {
      return;
    }

    final message = _messages[index];
    if (!message.isUser ||
        message.deliveryStatus != ChatDeliveryStatus.failed) {
      return;
    }

    _messages = _replaceMessage(
      messageId,
      message.copyWith(deliveryStatus: ChatDeliveryStatus.sending),
      messages: _messages,
    );
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final context = _buildContext(window: 24);
      final assistant = await _sendChatMessage(config, messages: context);
      _messages = _markDelivery(
        messageId,
        ChatDeliveryStatus.sent,
        messages: <ChatMessage>[..._messages, assistant],
      );
    } on AppException catch (error) {
      _messages = _markDelivery(
        messageId,
        ChatDeliveryStatus.failed,
        messages: _messages,
      );
      _errorMessage = error.message;
    } catch (error) {
      _messages = _markDelivery(
        messageId,
        ChatDeliveryStatus.failed,
        messages: _messages,
      );
      _errorMessage = 'Unexpected error: $error';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  List<ChatMessage> _buildContext({required int window}) {
    final usable = _messages
        .where(
          (message) =>
              message.deliveryStatus != ChatDeliveryStatus.failed &&
              message.content.trim().isNotEmpty,
        )
        .toList(growable: false);

    if (usable.length <= window) {
      return usable;
    }

    final developer = usable.where((message) => message.isDeveloper).toList();
    final tail = usable.where((message) => !message.isDeveloper).toList();
    final slice = tail.skip((tail.length - window).clamp(0, tail.length));
    return <ChatMessage>[...developer, ...slice];
  }

  List<ChatMessage> _markDelivery(
    String messageId,
    ChatDeliveryStatus status, {
    required List<ChatMessage> messages,
  }) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) {
      return messages;
    }
    final updated = messages[index].copyWith(deliveryStatus: status);
    return _replaceMessage(messageId, updated, messages: messages);
  }

  List<ChatMessage> _replaceMessage(
    String messageId,
    ChatMessage replacement, {
    required List<ChatMessage> messages,
  }) {
    return <ChatMessage>[
      for (final message in messages)
        if (message.id == messageId) replacement else message,
    ];
  }

  String _simpleId(String prefix) {
    final micros = DateTime.now().microsecondsSinceEpoch;
    return '${prefix}_$micros';
  }
}
