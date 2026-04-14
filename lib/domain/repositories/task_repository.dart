import '../entities/connection_config.dart';
import '../entities/execution_result.dart';
import '../entities/remote_task.dart';

abstract class TaskRepository {
  Future<void> verifyConnection(ConnectionConfig config);

  Future<List<RemoteTask>> fetchTasks(ConnectionConfig config);

  Future<RemoteTask> saveTask(ConnectionConfig config, RemoteTask task);

  Future<void> deleteTask(ConnectionConfig config, String taskId);

  Future<ExecutionResult> executeTask(ConnectionConfig config, String taskId);
}
