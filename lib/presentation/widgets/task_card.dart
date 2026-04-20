import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/task_visuals.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_panel.dart';
import '../../domain/entities/remote_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.isExecuting,
    required this.onExecute,
    required this.onEdit,
    required this.onDelete,
  });

  final RemoteTask task;
  final bool isExecuting;
  final VoidCallback onExecute;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = AppTheme.accentGradient(task.accentHex);
    final icon = TaskVisuals.iconMap[task.iconName] ?? Icons.bolt_rounded;
    final updatedLabel = task.updatedAt != null
        ? DateFormat('MMM d, HH:mm').format(task.updatedAt!)
        : 'Just created';

    return GlassPanel(
      enableBlur: false,
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          gradient.first.withValues(alpha: 0.18),
          gradient[1].withValues(alpha: 0.10),
          theme.brightness == Brightness.dark
              ? const Color(0xFF101826).withValues(alpha: 0.80)
              : Colors.white.withValues(alpha: 0.78),
        ],
        stops: const [0.0, 0.36, 1.0],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      task.description.isEmpty
                          ? 'Aucune description fournie.'
                          : task.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TaskMetaChip(
                icon: Icons.terminal_rounded,
                label: 'Script masqué',
              ),
              _TaskMetaChip(icon: icon, label: task.iconName),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isExecuting ? null : onExecute,
                  icon: isExecuting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(isExecuting ? 'Exécution…' : 'Exécuter'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Modifier',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton.filledTonal(
                tooltip: 'Supprimer',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: gradient.first,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mis à jour $updatedLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskMetaChip extends StatelessWidget {
  const _TaskMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.16 : 0.05,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
