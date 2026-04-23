import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../domain/entities/connection_config.dart';
import '../../../domain/entities/execution_history_entry.dart';
import '../../../domain/entities/execution_result.dart';
import '../../../domain/entities/remote_task.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/task_controller.dart';
import '../../widgets/connection_status_card.dart';
import '../../widgets/execution_history_list.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_editor_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _initializedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = context.read<AppController>().connectionConfig;
    final taskController = context.read<TaskController>();
    if (config == null) {
      return;
    }

    final fingerprint = '${config.baseUrl}|${config.secretKey}';
    if (_initializedFor == fingerprint) {
      return;
    }
    _initializedFor = fingerprint;
    Future.microtask(() => taskController.initialize(config));
  }

  Future<void> _openTaskEditor({RemoteTask? task}) async {
    final config = context.read<AppController>().connectionConfig;
    final taskController = context.read<TaskController>();
    if (config == null) {
      return;
    }

    final draft = await TaskEditorSheet.show(context, task: task);
    if (!mounted || draft == null) {
      return;
    }

    try {
      await taskController.saveTask(config, draft);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(task == null ? 'Tâche créée.' : 'Tâche mise à jour.'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _deleteTask(RemoteTask task) async {
    final config = context.read<AppController>().connectionConfig;
    final taskController = context.read<TaskController>();
    if (config == null || task.id == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la tâche'),
          content: Text('Supprimer "${task.title}" de l’agent Windows ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await taskController.deleteTask(config, task.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tâche supprimée.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _executeTask(RemoteTask task) async {
    final config = context.read<AppController>().connectionConfig;
    final taskController = context.read<TaskController>();
    if (config == null) {
      return;
    }

    try {
      final result = await taskController.executeTask(config, task);
      if (!mounted) {
        return;
      }
      _showExecutionResult(result);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  void _showExecutionResult(ExecutionResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final displayOutput = result.output.isEmpty
            ? result.success
                  ? 'La tâche s’est terminée sans sortie console.'
                  : 'Exécution terminée sans message exploitable.'
            : result.output;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.86,
            ),
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.taskTitle,
                                style: theme.textTheme.displaySmall,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${result.success ? 'Succès' : 'Erreur'} • code ${result.errorCode} • ${result.durationMs} ms',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.66,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          result.success
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          size: 30,
                          color: result.success
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.18
                              : 0.05,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.34,
                          ),
                        ),
                      ),
                      child: SelectableText(
                        displayOutput,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _resetConnection() async {
    final appController = context.read<AppController>();
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la connexion'),
          content: const Text(
            'Tu reviendras à l’écran de connexion. L’historique local sur cet appareil sera conservé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true && mounted) {
      await appController.clearConnectionConfig();
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
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 840;
    final cardWidth = width > 1380
        ? (width - 112) / 3
        : width > 980
        ? (width - 88) / 2
        : width - 40;

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
            const Positioned.fill(
              child: IgnorePointer(child: _DashboardGrid()),
            ),
            Positioned(
              top: -90,
              right: -40,
              child: _SceneGlow(
                size: 260,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -110,
              child: _SceneGlow(
                size: 320,
                color: theme.colorScheme.secondary.withValues(alpha: 0.10),
              ),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<TaskController>().refreshTasks(config),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 16 : 24,
                    16,
                    isCompact ? 16 : 24,
                    40,
                  ),
                  children: [
                    _TopStrip(config: config),
                    const SizedBox(height: 16),
                    _DashboardHeader(
                      config: config,
                      onRefresh: () =>
                          context.read<TaskController>().refreshTasks(config),
                      onEditConnection: _resetConnection,
                      onCreateTask: () => _openTaskEditor(),
                    ),
                    const SizedBox(height: 22),
                    const _DashboardErrorBanner(),
                    _TaskSection(
                      isCompact: isCompact,
                      cardWidth: cardWidth,
                      onCreateTask: () => _openTaskEditor(),
                      onEditTask: (task) => _openTaskEditor(task: task),
                      onDeleteTask: _deleteTask,
                      onExecuteTask: _executeTask,
                    ),
                    const SizedBox(height: 28),
                    const _HistorySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStrip extends StatelessWidget {
  const _TopStrip({required this.config});

  final ConnectionConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _TopPill(
          icon: Icons.radar_rounded,
          text: 'Controlix UI',
          accent: theme.colorScheme.primary,
        ),
        _TopPill(
          icon: Icons.computer_rounded,
          text: config.ipAddress,
          accent: theme.colorScheme.secondary,
        ),
        _TopPill(
          icon: Icons.lock_outline_rounded,
          text: 'Backend inchangé',
          accent: theme.colorScheme.onSurface.withValues(alpha: 0.72),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.config,
    required this.onRefresh,
    required this.onEditConnection,
    required this.onCreateTask,
  });

  final ConnectionConfig config;
  final VoidCallback onRefresh;
  final VoidCallback onEditConnection;
  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppController, ThemeMode>(
      (controller) => controller.themeMode,
    );
    final taskCount = context.select<TaskController, int>(
      (controller) => controller.tasks.length,
    );
    final isRefreshing = context.select<TaskController, bool>(
      (controller) => controller.isLoading,
    );
    final hasConnectionIssue = context.select<TaskController, bool>(
      (controller) => controller.errorMessage != null,
    );

    return ConnectionStatusCard(
      config: config,
      themeMode: themeMode,
      taskCount: taskCount,
      statusLabel: hasConnectionIssue ? 'Liaison dégradée' : 'Liaison active',
      isRefreshing: isRefreshing,
      onRefresh: onRefresh,
      onEditConnection: onEditConnection,
      onThemeChanged: context.read<AppController>().updateThemeMode,
      onCreateTask: onCreateTask,
      hasConnectionIssue: hasConnectionIssue,
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Selector<TaskController, String?>(
      selector: (_, controller) => controller.errorMessage,
      builder: (context, errorMessage, _) {
        if (errorMessage == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            GlassPanel(
              enableBlur: false,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.14),
                  const Color(0xFFF97316).withValues(alpha: 0.10),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.isCompact,
    required this.cardWidth,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onExecuteTask,
  });

  final bool isCompact;
  final double cardWidth;
  final VoidCallback onCreateTask;
  final Future<void> Function(RemoteTask task) onEditTask;
  final Future<void> Function(RemoteTask task) onDeleteTask;
  final Future<void> Function(RemoteTask task) onExecuteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<
      TaskController,
      ({List<RemoteTask> tasks, bool isLoading, String? executingTaskId})
    >(
      selector: (_, controller) => (
        tasks: controller.tasks,
        isLoading: controller.isLoading,
        executingTaskId: controller.executingTaskId,
      ),
      builder: (context, taskState, _) {
        final tasks = taskState.tasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tâches d’automatisation',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chaque carte pilote un script PowerShell stocké sur l’agent Windows. Le redesign change seulement l’interface, pas le flux d’exécution.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 20),
                  FilledButton.icon(
                    onPressed: onCreateTask,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Créer une tâche'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            if (taskState.isLoading && tasks.isEmpty)
              const GlassPanel(
                enableBlur: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (tasks.isEmpty)
              _EmptyState(onCreateTask: onCreateTask)
            else if (isCompact)
              Column(
                children: tasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TaskCard(
                      task: task,
                      isExecuting: taskState.executingTaskId == task.id,
                      onExecute: () => onExecuteTask(task),
                      onEdit: () => onEditTask(task),
                      onDelete: () => onDeleteTask(task),
                    ),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: tasks.map((task) {
                  return SizedBox(
                    width: cardWidth,
                    child: TaskCard(
                      task: task,
                      isExecuting: taskState.executingTaskId == task.id,
                      onExecute: () => onExecuteTask(task),
                      onEdit: () => onEditTask(task),
                      onDelete: () => onDeleteTask(task),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Selector<TaskController, List<ExecutionHistoryEntry>>(
      selector: (_, controller) => controller.history,
      builder: (context, history, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique local',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stocké sur cet appareil, indépendamment de l’historique côté agent.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.66,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        context.read<TaskController>().clearHistory(),
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: const Text('Vider'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ExecutionHistoryList(history: history),
          ],
        );
      },
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({
    required this.icon,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.18 : 0.05,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTask});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aucune tâche distante', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Crée ta première automatisation. Elle sera envoyée immédiatement à l’agent Windows via l’API existante.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer la première tâche'),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _DashboardGridPainter(
        lineColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
    );
  }
}

class _DashboardGridPainter extends CustomPainter {
  const _DashboardGridPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _SceneGlow extends StatelessWidget {
  const _SceneGlow({required this.size, required this.color});

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
