import '../../domain/entities/execution_history_entry.dart';

class ExecutionHistoryEntryModel extends ExecutionHistoryEntry {
  const ExecutionHistoryEntryModel({
    required super.id,
    required super.taskId,
    required super.taskTitle,
    required super.success,
    required super.output,
    required super.errorCode,
    required super.executedAt,
    required super.durationMs,
  });

  factory ExecutionHistoryEntryModel.fromEntity(ExecutionHistoryEntry entity) {
    return ExecutionHistoryEntryModel(
      id: entity.id,
      taskId: entity.taskId,
      taskTitle: entity.taskTitle,
      success: entity.success,
      output: entity.output,
      errorCode: entity.errorCode,
      executedAt: entity.executedAt,
      durationMs: entity.durationMs,
    );
  }

  factory ExecutionHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return ExecutionHistoryEntryModel(
      id: json['id'] as String? ?? '',
      taskId: json['task_id'] as String? ?? '',
      taskTitle: json['task_title'] as String? ?? 'Task',
      success: json['success'] as bool? ?? false,
      output: json['output'] as String? ?? '',
      errorCode: json['error_code'] as int? ?? -1,
      executedAt:
          DateTime.tryParse(json['executed_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      durationMs: json['duration_ms'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'task_id': taskId,
      'task_title': taskTitle,
      'success': success,
      'output': output,
      'error_code': errorCode,
      'executed_at': executedAt.toIso8601String(),
      'duration_ms': durationMs,
    };
  }
}
