import '../../core/utils/powershell_output_formatter.dart';
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
    final output = PowerShellOutputFormatter.sanitize(
      json['output'] as String? ?? '',
    );
    final stdout = PowerShellOutputFormatter.sanitize(
      json['stdout'] as String? ?? '',
    );
    final stderr = PowerShellOutputFormatter.sanitize(
      json['stderr'] as String? ?? '',
    );

    return ExecutionResultModel(
      success: json['success'] as bool? ?? false,
      output: output,
      errorCode: json['error_code'] as int? ?? -1,
      executedAt:
          DateTime.tryParse(json['executed_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      stdout: stdout,
      stderr: stderr,
      taskTitle: json['task_title'] as String? ?? 'Task',
      durationMs: json['duration_ms'] as int? ?? 0,
    );
  }
}
