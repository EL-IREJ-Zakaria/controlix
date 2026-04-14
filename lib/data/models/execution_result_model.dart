import '../../domain/entities/execution_result.dart';

class ExecutionResultModel extends ExecutionResult {
  const ExecutionResultModel({
    required super.success,
    required super.output,
    required super.errorCode,
    required super.executedAt,
    required super.stdout,
    required super.stderr,
    required super.taskTitle,
    required super.durationMs,
  });

  factory ExecutionResultModel.fromJson(Map<String, dynamic> json) {
    return ExecutionResultModel(
      success: json['success'] as bool? ?? false,
      output: json['output'] as String? ?? '',
      errorCode: json['error_code'] as int? ?? -1,
      executedAt:
          DateTime.tryParse(json['executed_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      stdout: json['stdout'] as String? ?? '',
      stderr: json['stderr'] as String? ?? '',
      taskTitle: json['task_title'] as String? ?? 'Task',
      durationMs: json['duration_ms'] as int? ?? 0,
    );
  }
}
