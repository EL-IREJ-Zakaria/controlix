import 'package:flutter/foundation.dart';

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
    required VerifyConnectionUseCase verifyConnection,
    required LoadHistoryUseCase loadHistory,
    required SaveHistoryEntryUseCase saveHistoryEntry,
    required ClearHistoryUseCase clearHistory,
  }) : _fetchTasks = fetchTasks,
       _saveTask = saveTask,
       _deleteTask = deleteTask,
       _executeTask = executeTask,
       _verifyConnection = verifyConnection,
       _loadHistory = loadHistory,
       _saveHistoryEntry = saveHistoryEntry,
       _clearHistory = clearHistory;

  final FetchTasksUseCase _fetchTasks;
  final SaveTaskUseCase _saveTask;
  final DeleteTaskUseCase _deleteTask;
  final ExecuteTaskUseCase _executeTask;
  final VerifyConnectionUseCase _verifyConnection;
  final LoadHistoryUseCase _loadHistory;
  final SaveHistoryEntryUseCase _saveHistoryEntry;
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
    if (_connectionFingerprint == fingerprint &&
        _historyLoaded &&
        _remoteLoaded) {
      return;
    }

    _connectionFingerprint = fingerprint;
    await Future.wait<void>(<Future<void>>[
      if (!_historyLoaded) _hydrateHistory(),
      refreshTasks(config),
    ]);
  }

  Future<void> verifyConnection(ConnectionConfig config) {
    return _verifyConnection(config);
  }

  Future<void> refreshTasks(ConnectionConfig config) async {
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
        taskTitle: result.taskTitle,
        success: result.success,
        output: result.output,
        errorCode: result.errorCode,
        executedAt: result.executedAt,
        durationMs: result.durationMs,
      );
      await _saveHistoryEntry(historyEntry);
      await _hydrateHistory();
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
