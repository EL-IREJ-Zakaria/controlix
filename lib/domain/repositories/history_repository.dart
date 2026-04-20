import '../entities/execution_history_entry.dart';

abstract class HistoryRepository {
  Future<List<ExecutionHistoryEntry>> loadHistory();

  Future<void> saveHistory(List<ExecutionHistoryEntry> entries);

  Future<void> saveHistoryEntry(ExecutionHistoryEntry entry);

  Future<void> clearHistory();
}
