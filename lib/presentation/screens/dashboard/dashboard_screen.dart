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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(task == null ? 'Task created.' : 'Task updated.'),
          ),
        );
      }
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
          title: const Text('Delete task'),
          content: Text('Delete "${task.title}" from the Windows agent?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
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
        ).showSnackBar(const SnackBar(content: Text('Task deleted.')));
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
                  ? 'Task completed successfully.'
                  : 'Execution finished without any output.'
            : result.output;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: GlassPanel(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              result.taskTitle,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          Icon(
                            result.success
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: result.success
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Exit code ${result.errorCode} - ${result.durationMs} ms',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.68,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.22
                                : 0.06,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SelectableText(
                          displayOutput,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
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
          title: const Text('Edit connection'),
          content: const Text(
            'This returns you to the connection screen and keeps task history stored on the device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
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
    final isCompact = width < 720;
    final cardWidth = width > 1280
        ? (width - 88) / 3
        : width > 860
        ? (width - 72) / 2
        : width - 48;

    return Scaffold(
      body: Container(
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
              top: -140,
              right: -60,
              child: _GlowOrb(
                size: 320,
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _GlowOrb(
                size: 340,
                color: theme.colorScheme.secondary.withValues(alpha: 0.14),
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
                    48,
                  ),
                  children: [
                    _DashboardHeader(
                      config: config,
                      onRefresh: () =>
                          context.read<TaskController>().refreshTasks(config),
                      onEditConnection: _resetConnection,
                      onCreateTask: () => _openTaskEditor(),
                    ),
                    const SizedBox(height: 24),
                    const _DashboardErrorBanner(),
                    _TaskSection(
                      isCompact: isCompact,
                      cardWidth: cardWidth,
                      onCreateTask: () => _openTaskEditor(),
                      onEditTask: (task) => _openTaskEditor(task: task),
                      onDeleteTask: _deleteTask,
                      onExecuteTask: _executeTask,
                    ),
                    const SizedBox(height: 32),
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
      statusLabel: hasConnectionIssue ? 'Connection issue' : 'Connected to PC',
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
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.18),
                  const Color(0xFFF97316).withValues(alpha: 0.12),
                ],
              ),
              child: Text(errorMessage),
            ),
            const SizedBox(height: 24),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Automation tasks', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Tap any card to execute the PowerShell script on the Windows agent.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
            if (!isCompact) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: onCreateTask,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add task'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (taskState.isLoading && tasks.isEmpty)
              const GlassPanel(
                enableBlur: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (tasks.isEmpty)
              _EmptyState(onCreateTask: onCreateTask)
            else if (isCompact)
              Column(
                children: tasks
                    .map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TaskCard(
                          task: task,
                          isExecuting: taskState.executingTaskId == task.id,
                          onExecute: () => onExecuteTask(task),
                          onEdit: () => onEditTask(task),
                          onDelete: () => onDeleteTask(task),
                        ),
                      );
                    })
                    .toList(growable: false),
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: tasks
                    .map((task) {
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
                    })
                    .toList(growable: false),
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
                  child: Text(
                    'Local execution history',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        context.read<TaskController>().clearHistory(),
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: const Text('Clear'),
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
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
          Text('No tasks yet', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Create your first automation task and it will be stored on the Windows agent immediately.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create first task'),
          ),
        ],
      ),
    );
  }
}
