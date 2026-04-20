import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final isFailed = message.deliveryStatus == ChatDeliveryStatus.failed;
    final isSending = message.deliveryStatus == ChatDeliveryStatus.sending;
    final bubbleMaxWidth = MediaQuery.sizeOf(context).width * 0.78;
    final time = DateFormat.Hm().format(message.createdAt);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.95),
                  Color.lerp(
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                        0.35,
                      )?.withValues(alpha: 0.92) ??
                      theme.colorScheme.primary.withValues(alpha: 0.92),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.82 : 0.86,
                  ),
                  theme.colorScheme.surface.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.76 : 0.88,
                  ),
                ],
              ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: Radius.circular(isUser ? 22 : 8),
          bottomRight: Radius.circular(isUser ? 8 : 22),
        ),
        border: Border.all(
          color:
              (isUser
                      ? Colors.white.withValues(alpha: 0.16)
                      : theme.colorScheme.outline.withValues(alpha: 0.40))
                  .withValues(alpha: isFailed ? 0.70 : 1),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08,
            ),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            message.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isUser ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFailed) ...[
                Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.92)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                isFailed
                    ? 'Non envoyé • $time'
                    : isSending
                    ? 'Envoi… • $time'
                    : time,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.82)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isFailed && onRetry != null) ...[
                const SizedBox(width: 10),
                InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'Renvoyer',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isUser
                            ? Colors.white
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [bubble],
      ),
    );
  }
}
