import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/execution_history_entry_model.dart';

class HistoryLocalDataSource {
  const HistoryLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  Future<List<ExecutionHistoryEntryModel>> loadHistory() async {
    final raw = _preferences.getString(AppConstants.prefsHistoryKey);
    if (raw == null || raw.isEmpty) {
      return <ExecutionHistoryEntryModel>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded
        .cast<Map<String, dynamic>>()
        .map(ExecutionHistoryEntryModel.fromJson)
        .toList();
    entries.sort((left, right) => right.executedAt.compareTo(left.executedAt));
    return entries;
  }

  Future<void> saveHistoryEntry(ExecutionHistoryEntryModel entry) async {
    final currentEntries = await loadHistory();
    final nextEntries = <ExecutionHistoryEntryModel>[
      entry,
      ...currentEntries.where((item) => item.id != entry.id),
    ].take(AppConstants.executionHistoryLimit).toList();

    await _preferences.setString(
      AppConstants.prefsHistoryKey,
      jsonEncode(nextEntries.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    await _preferences.remove(AppConstants.prefsHistoryKey);
  }
}
