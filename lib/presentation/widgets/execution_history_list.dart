import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/glass_panel.dart';
import '../../domain/entities/execution_history_entry.dart';

class ExecutionHistoryList extends StatelessWidget {
  const ExecutionHistoryList({super.key, required this.history});

  final List<ExecutionHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return GlassPanel(
        enableBlur: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aucun historique local', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Lance une tâche pour voir ici le dernier résultat exécuté depuis cet appareil.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: history.take(6).map((entry) {
        final accent = entry.success
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
        final output = entry.output.trim().isEmpty
            ? 'Aucune sortie console.'
            : entry.output.trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            enableBlur: false,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.taskTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.success ? 'Succès' : 'Échec'} • code ${entry.errorCode} • ${entry.durationMs} ms',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM d, HH:mm').format(entry.executedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.58,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.16 : 0.05,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Text(
                    output,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
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
