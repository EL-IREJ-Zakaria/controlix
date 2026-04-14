import 'package:flutter/material.dart';

import '../../domain/entities/connection_config.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/local/config_local_data_source.dart';
import '../models/connection_config_model.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  const AppSettingsRepositoryImpl(this._localDataSource);

  final ConfigLocalDataSource _localDataSource;

  @override
  Future<void> clearConnectionConfig() {
    return _localDataSource.clearConnectionConfig();
  }

  @override
  Future<ConnectionConfig?> loadConnectionConfig() {
    return _localDataSource.loadConnectionConfig();
  }

  @override
  Future<ThemeMode> loadThemeMode() {
    return _localDataSource.loadThemeMode();
  }

  @override
  Future<void> saveConnectionConfig(ConnectionConfig config) {
    return _localDataSource.saveConnectionConfig(
      ConnectionConfigModel.fromEntity(config),
    );
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _localDataSource.saveThemeMode(themeMode);
  }
}
