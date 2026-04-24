import '../../../core/network/api_client.dart';
import '../../../core/error/app_exception.dart';
import '../../../domain/entities/connection_config.dart';
import '../../models/execution_result_model.dart';
import '../../models/remote_task_model.dart';

class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<void> verifyConnection(ConnectionConfig config) async {
    await _apiClient.get(config, '/health');
  }

  Future<List<RemoteTaskModel>> fetchTasks(ConnectionConfig config) async {
    final response = await _apiClient.get(config, '/tasks');
    final tasks = (response['tasks'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return tasks.map(RemoteTaskModel.fromJson).toList();
  }

  Future<RemoteTaskModel> saveTask(
    ConnectionConfig config,
    RemoteTaskModel task,
  ) async {
    final response = task.id == null
        ? await _apiClient.post(config, '/tasks', body: task.toJson())
        : await _apiClient.put(
            config,
            '/tasks/${task.id}',
            body: task.toJson(),
          );

    return RemoteTaskModel.fromJson(response['task'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(ConnectionConfig config, String taskId) async {
    await _apiClient.delete(config, '/tasks/$taskId');
  }

  Future<ExecutionResultModel> executeTask(
    ConnectionConfig config,
    String taskId,
  ) async {
    final response = await _apiClient.post(
      config,
      '/execute',
      body: <String, dynamic>{'task_id': taskId},
    );

    return ExecutionResultModel.fromJson(response);
  }

  Future<String> generatePowerShellScript(
    ConnectionConfig config,
    String prompt,
  ) async {
    late final Map<String, dynamic> response;
    try {
      response = await _apiClient.post(
        config,
        '/assistant/gemini/powershell',
        body: <String, dynamic>{'prompt': prompt},
      );
    } on AppException catch (error) {
      if (error.statusCode == 404) {
        throw const AppException(
          'Ton agent Windows est trop ancien (endpoint Gemini introuvable). Mets à jour/redémarre l’agent.',
          statusCode: 404,
        );
      }
      rethrow;
    }

    final script = response['script'];
    if (script is String) {
      return script;
    }
    throw StateError('Invalid assistant response.');
  }
}
