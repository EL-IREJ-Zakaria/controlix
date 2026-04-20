import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/connection_config.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../widgets/chat/chat_empty_state.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  late final ChatController _chatController;

  int _lastItemCount = 0;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _chatController = Provider.of<ChatController>(context, listen: false);
    _chatController.addListener(_onChatChanged);
  }

  @override
  void dispose() {
    _chatController.removeListener(_onChatChanged);
    _scrollController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onChatChanged() {
    final visibleCount = _chatController.messages
        .where((message) => !message.isDeveloper)
        .length;
    final nextCount = visibleCount + (_chatController.isSending ? 1 : 0);
    if (nextCount != _lastItemCount) {
      _lastItemCount = nextCount;
      _scrollToBottom();
    }

    final error = _chatController.errorMessage;
    if (error != null && error != _lastError && mounted) {
      _lastError = error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final target = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send(ConnectionConfig config) async {
    final prompt = _textController.text;
    _textController.clear();
    await _chatController.send(config, prompt: prompt);
    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.select<AppController, ConnectionConfig?>(
      (controller) => controller.connectionConfig,
    );
    if (config == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final gradient = AppTheme.pageGradient(theme.brightness);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -50,
              child: _AmbientGlow(
                size: 260,
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -120,
              child: _AmbientGlow(
                size: 320,
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: _ChatHeader(onClear: () => _chatController.clear()),
                  ),
                  Expanded(
                    child: Consumer<ChatController>(
                      builder: (context, controller, _) {
                        final visibleMessages = controller.messages
                            .where((message) => !message.isDeveloper)
                            .toList(growable: false);

                        if (visibleMessages.isEmpty) {
                          return const ChatEmptyState();
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              visibleMessages.length +
                              (controller.isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= visibleMessages.length) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: ChatTypingIndicator(),
                              );
                            }

                            final message = visibleMessages[index];
                            return ChatMessageBubble(
                              message: message,
                              onRetry:
                                  message.deliveryStatus ==
                                      ChatDeliveryStatus.failed
                                  ? () => controller.retryFailed(
                                      config,
                                      message.id,
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _InputBar(
                      textController: _textController,
                      focusNode: _focusNode,
                      onSend: () => _send(config),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      enableBlur: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 26,
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text('Assistant', style: theme.textTheme.titleLarge)),
          IconButton(
            tooltip: 'Vider',
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.textController,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSending = context.select<ChatController, bool>(
      (controller) => controller.isSending,
    );

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      borderRadius: 28,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) {
                if (!isSending) {
                  onSend();
                }
              },
              decoration: const InputDecoration(hintText: 'Message…'),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            height: 44,
            child: FilledButton(
              onPressed: isSending ? null : onSend,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
