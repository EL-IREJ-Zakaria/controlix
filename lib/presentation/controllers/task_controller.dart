import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/connection_config.dart';
import '../../domain/entities/execution_history_entry.dart';
import '../../domain/entities/execution_result.dart';
import '../../domain/entities/remote_task.dart';
import '../../domain/usecases/history_usecases.dart';
import '../../domain/usecases/task_usecases.dart';

class TaskController extends ChangeNotifier {
  TaskController({
    required FetchTasksUseCase fetchTasks,
    required SaveTaskUseCase saveTask,
    required DeleteTaskUseCase deleteTask,
    required ExecuteTaskUseCase executeTask,
    required GeneratePowerShellScriptUseCase generatePowerShellScript,
    required VerifyConnectionUseCase verifyConnection,
    required LoadHistoryUseCase loadHistory,
    required SaveHistoryUseCase saveHistory,
    required ClearHistoryUseCase clearHistory,
  }) : _fetchTasks = fetchTasks,
       _saveTask = saveTask,
       _deleteTask = deleteTask,
       _executeTask = executeTask,
       _generatePowerShellScript = generatePowerShellScript,
       _verifyConnection = verifyConnection,
       _loadHistory = loadHistory,
       _saveHistory = saveHistory,
       _clearHistory = clearHistory;

  final FetchTasksUseCase _fetchTasks;
  final SaveTaskUseCase _saveTask;
  final DeleteTaskUseCase _deleteTask;
  final ExecuteTaskUseCase _executeTask;
  final GeneratePowerShellScriptUseCase _generatePowerShellScript;
  final VerifyConnectionUseCase _verifyConnection;
  final LoadHistoryUseCase _loadHistory;
  final SaveHistoryUseCase _saveHistory;
  final ClearHistoryUseCase _clearHistory;

  List<RemoteTask> _tasks = const <RemoteTask>[];
  List<ExecutionHistoryEntry> _history = const <ExecutionHistoryEntry>[];
  bool _isLoading = false;
  String? _errorMessage;
  String? _executingTaskId;
  String? _connectionFingerprint;
  bool _historyLoaded = false;
  bool _remoteLoaded = false;

  List<RemoteTask> get tasks => _tasks;
  List<ExecutionHistoryEntry> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get executingTaskId => _executingTaskId;

  Future<void> initialize(ConnectionConfig config) async {
    final fingerprint = '${config.baseUrl}|${config.secretKey}';
    final connectionChanged = _connectionFingerprint != fingerprint;
    if (!connectionChanged && _historyLoaded && (_remoteLoaded || _isLoading)) {
      return;
    }

    _connectionFingerprint = fingerprint;
    if (connectionChanged) {
      _remoteLoaded = false;
      _errorMessage = null;
    }

    if (!_remoteLoaded && !_isLoading) {
      unawaited(refreshTasks(config));
    }

    if (!_historyLoaded) {
      await _hydrateHistory();
    }
  }

  Future<void> verifyConnection(ConnectionConfig config) {
    return _verifyConnection(config);
  }

  Future<String> generatePowerShellScript(
    ConnectionConfig config,
    String prompt,
  ) {
    return _generatePowerShellScript(config, prompt);
  }

  Future<void> refreshTasks(ConnectionConfig config) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _fetchTasks(config);
    } on AppException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Unexpected error: $error';
    } finally {
      _remoteLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RemoteTask> saveTask(ConnectionConfig config, RemoteTask task) async {
    final savedTask = await _saveTask(config, task);
    final updated =
        <RemoteTask>[
          savedTask,
          ..._tasks.where((item) => item.id != savedTask.id),
        ]..sort(
          (left, right) =>
              left.title.toLowerCase().compareTo(right.title.toLowerCase()),
        );
    _tasks = updated;
    _errorMessage = null;
    notifyListeners();
    return savedTask;
  }

  Future<void> deleteTask(ConnectionConfig config, String taskId) async {
    await _deleteTask(config, taskId);
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();
  }

  Future<ExecutionResult> executeTask(
    ConnectionConfig config,
    RemoteTask task,
  ) async {
    _executingTaskId = task.id;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _executeTask(config, task.id ?? '');
      final historyEntry = ExecutionHistoryEntry(
        id: '${task.id}-${result.executedAt.toUtc().toIso8601String()}-${result.errorCode}',
        taskId: task.id ?? '',
        taskTitle: task.title,
        success: result.success,
        output: result.output,
        errorCode: result.errorCode,
        executedAt: result.executedAt,
        durationMs: result.durationMs,
      );
      _history = <ExecutionHistoryEntry>[
        historyEntry,
        ..._history.where((item) => item.id != historyEntry.id),
      ].take(AppConstants.executionHistoryLimit).toList(growable: false);
      _historyLoaded = true;
      await _saveHistory(_history);
      return result;
    } finally {
      _executingTaskId = null;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    await _clearHistory();
    _history = const <ExecutionHistoryEntry>[];
    notifyListeners();
  }

  Future<void> _hydrateHistory() async {
    _history = await _loadHistory();
    _historyLoaded = true;
    notifyListeners();
  }
}
