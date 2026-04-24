import '../../domain/entities/connection_config.dart';
import '../../domain/entities/execution_result.dart';
import '../../domain/entities/remote_task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/remote/task_remote_data_source.dart';
import '../models/remote_task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Future<void> deleteTask(ConnectionConfig config, String taskId) {
    return _remoteDataSource.deleteTask(config, taskId);
  }

  @override
  Future<ExecutionResult> executeTask(ConnectionConfig config, String taskId) {
    return _remoteDataSource.executeTask(config, taskId);
  }

  @override
  Future<List<RemoteTask>> fetchTasks(ConnectionConfig config) {
    return _remoteDataSource.fetchTasks(config);
  }

  @override
  Future<RemoteTask> saveTask(ConnectionConfig config, RemoteTask task) {
    return _remoteDataSource.saveTask(config, RemoteTaskModel.fromEntity(task));
  }

  @override
  Future<void> verifyConnection(ConnectionConfig config) {
    return _remoteDataSource.verifyConnection(config);
  }

  @override
  Future<String> generatePowerShellScript(ConnectionConfig config, String prompt) {
    return _remoteDataSource.generatePowerShellScript(config, prompt);
  }
}
