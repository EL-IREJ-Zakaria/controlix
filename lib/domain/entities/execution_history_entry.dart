class ExecutionHistoryEntry {
  const ExecutionHistoryEntry({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.success,
    required this.output,
    required this.errorCode,
    required this.executedAt,
    required this.durationMs,
  });

  final String id;
  final String taskId;
  final String taskTitle;
  final bool success;
  final String output;
  final int errorCode;
  final DateTime executedAt;
  final int durationMs;
}
