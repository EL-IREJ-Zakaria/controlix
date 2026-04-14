import '../../domain/entities/execution_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local/history_local_data_source.dart';
import '../models/execution_history_entry_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._localDataSource);

  final HistoryLocalDataSource _localDataSource;

  @override
  Future<void> clearHistory() {
    return _localDataSource.clearHistory();
  }

  @override
  Future<List<ExecutionHistoryEntry>> loadHistory() {
    return _localDataSource.loadHistory();
  }

  @override
  Future<void> saveHistoryEntry(ExecutionHistoryEntry entry) {
    return _localDataSource.saveHistoryEntry(
      ExecutionHistoryEntryModel.fromEntity(entry),
    );
  }
}
