import 'package:flutter/material.dart';

import '../entities/connection_config.dart';
import '../repositories/app_settings_repository.dart';

class LoadConnectionConfigUseCase {
  const LoadConnectionConfigUseCase(this._repository);

  final AppSettingsRepository _repository;

  Future<ConnectionConfig?> call() => _repository.loadConnectionConfig();
}

class SaveConnectionConfigUseCase {
  const SaveConnectionConfigUseCase(this._repository);

  final AppSettingsRepository _repository;

  Future<void> call(ConnectionConfig config) {
    return _repository.saveConnectionConfig(config);
  }
}

class ClearConnectionConfigUseCase {
  const ClearConnectionConfigUseCase(this._repository);

  final AppSettingsRepository _repository;

  Future<void> call() => _repository.clearConnectionConfig();
}

class LoadThemeModeUseCase {
  const LoadThemeModeUseCase(this._repository);

  final AppSettingsRepository _repository;

  Future<ThemeMode> call() => _repository.loadThemeMode();
}

class SaveThemeModeUseCase {
  const SaveThemeModeUseCase(this._repository);

  final AppSettingsRepository _repository;

  Future<void> call(ThemeMode themeMode) {
    return _repository.saveThemeMode(themeMode);
  }
}
