import '../entities/connection_config.dart';
import '../entities/execution_result.dart';
import '../entities/remote_task.dart';
import '../repositories/task_repository.dart';

class VerifyConnectionUseCase {
  const VerifyConnectionUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(ConnectionConfig config) {
    return _repository.verifyConnection(config);
  }
}

class FetchTasksUseCase {
  const FetchTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<RemoteTask>> call(ConnectionConfig config) {
    return _repository.fetchTasks(config);
  }
}

class SaveTaskUseCase {
  const SaveTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<RemoteTask> call(ConnectionConfig config, RemoteTask task) {
    return _repository.saveTask(config, task);
  }
}

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(ConnectionConfig config, String taskId) {
    return _repository.deleteTask(config, taskId);
  }
}

class ExecuteTaskUseCase {
  const ExecuteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<ExecutionResult> call(ConnectionConfig config, String taskId) {
    return _repository.executeTask(config, taskId);
  }
}
