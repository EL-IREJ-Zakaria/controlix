import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/glass_panel.dart';
import '../../domain/entities/execution_history_entry.dart';

class ExecutionHistoryList extends StatelessWidget {
  const ExecutionHistoryList({super.key, required this.history});

  final List<ExecutionHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const GlassPanel(
        child: Text(
          'No execution history yet. Run a task to see local execution logs on this device.',
        ),
      );
    }

    return Column(
      children: history.take(6).map((entry) {
        final theme = Theme.of(context);
        final accent = entry.success
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.taskTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, HH:mm').format(entry.executedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  entry.output.isEmpty
                      ? 'No output was returned.'
                      : entry.output,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Exit code ${entry.errorCode} • ${entry.durationMs} ms',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
