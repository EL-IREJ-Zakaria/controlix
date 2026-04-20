import '../entities/execution_history_entry.dart';
import '../repositories/history_repository.dart';

class LoadHistoryUseCase {
  const LoadHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<List<ExecutionHistoryEntry>> call() => _repository.loadHistory();
}

class SaveHistoryUseCase {
  const SaveHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<void> call(List<ExecutionHistoryEntry> entries) {
    return _repository.saveHistory(entries);
  }
}

class SaveHistoryEntryUseCase {
  const SaveHistoryEntryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<void> call(ExecutionHistoryEntry entry) {
    return _repository.saveHistoryEntry(entry);
  }
}

class ClearHistoryUseCase {
  const ClearHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<void> call() => _repository.clearHistory();
}
