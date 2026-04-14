import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_panel.dart';
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
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: GlassPanel(
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.22 : 0.06,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SelectableText(
                    result.output.isEmpty
                        ? 'No output returned.'
                        : result.output,
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
    return Consumer2<AppController, TaskController>(
      builder: (context, appController, taskController, _) {
        final config = appController.connectionConfig;
        if (config == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final gradient = AppTheme.pageGradient(theme.brightness);
        final tasks = taskController.tasks;
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
                    onRefresh: () => taskController.refreshTasks(config),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        isCompact ? 16 : 24,
                        16,
                        isCompact ? 16 : 24,
                        48,
                      ),
                      children: [
                        ConnectionStatusCard(
                          config: config,
                          themeMode: appController.themeMode,
                          taskCount: tasks.length,
                          statusLabel: taskController.errorMessage == null
                              ? 'Agent synced'
                              : 'Connection issue',
                          isRefreshing: taskController.isLoading,
                          onRefresh: () => taskController.refreshTasks(config),
                          onEditConnection: _resetConnection,
                          onThemeChanged: appController.updateThemeMode,
                          onCreateTask: () => _openTaskEditor(),
                          hasConnectionIssue:
                              taskController.errorMessage != null,
                        ),
                        const SizedBox(height: 24),
                        if (taskController.errorMessage != null) ...[
                          GlassPanel(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFEF4444).withValues(alpha: 0.18),
                                const Color(0xFFF97316).withValues(alpha: 0.12),
                              ],
                            ),
                            child: Text(taskController.errorMessage!),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automation tasks',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap any card to execute the PowerShell script on the Windows agent.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isCompact) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () => _openTaskEditor(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add task'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (taskController.isLoading && tasks.isEmpty)
                          const GlassPanel(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                        else if (tasks.isEmpty)
                          _EmptyState(onCreateTask: () => _openTaskEditor())
                        else
                          isCompact
                              ? Column(
                                  children: tasks.map((task) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: TaskCard(
                                        task: task,
                                        isExecuting:
                                            taskController.executingTaskId ==
                                            task.id,
                                        onExecute: () => _executeTask(task),
                                        onEdit: () =>
                                            _openTaskEditor(task: task),
                                        onDelete: () => _deleteTask(task),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: tasks.map((task) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: TaskCard(
                                        task: task,
                                        isExecuting:
                                            taskController.executingTaskId ==
                                            task.id,
                                        onExecute: () => _executeTask(task),
                                        onEdit: () =>
                                            _openTaskEditor(task: task),
                                        onDelete: () => _deleteTask(task),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Local execution history',
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            if (taskController.history.isNotEmpty)
                              TextButton.icon(
                                onPressed: taskController.clearHistory,
                                icon: const Icon(Icons.delete_sweep_rounded),
                                label: const Text('Clear'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ExecutionHistoryList(history: taskController.history),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
