class ExecutionResult {
  const ExecutionResult({
    required this.success,
    required this.output,
    required this.errorCode,
    required this.executedAt,
    required this.stdout,
    required this.stderr,
    required this.taskTitle,
    required this.durationMs,
  });

  final bool success;
  final String output;
  final int errorCode;
  final DateTime executedAt;
  final String stdout;
  final String stderr;
  final String taskTitle;
  final int durationMs;
}
