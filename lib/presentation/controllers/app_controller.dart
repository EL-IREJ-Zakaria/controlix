import 'package:flutter/material.dart';

import '../../domain/entities/connection_config.dart';
import '../../domain/usecases/settings_usecases.dart';

class AppController extends ChangeNotifier {
  AppController({
    required LoadConnectionConfigUseCase loadConnectionConfig,
    required SaveConnectionConfigUseCase saveConnectionConfig,
    required ClearConnectionConfigUseCase clearConnectionConfig,
    required LoadThemeModeUseCase loadThemeMode,
    required SaveThemeModeUseCase saveThemeMode,
  }) : _loadConnectionConfig = loadConnectionConfig,
       _saveConnectionConfig = saveConnectionConfig,
       _clearConnectionConfig = clearConnectionConfig,
       _loadThemeMode = loadThemeMode,
       _saveThemeMode = saveThemeMode;

  final LoadConnectionConfigUseCase _loadConnectionConfig;
  final SaveConnectionConfigUseCase _saveConnectionConfig;
  final ClearConnectionConfigUseCase _clearConnectionConfig;
  final LoadThemeModeUseCase _loadThemeMode;
  final SaveThemeModeUseCase _saveThemeMode;

  bool _isReady = false;
  ConnectionConfig? _connectionConfig;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isReady => _isReady;
  ConnectionConfig? get connectionConfig => _connectionConfig;
  ThemeMode get themeMode => _themeMode;
  bool get isConfigured => _connectionConfig?.isComplete ?? false;

  Future<void> bootstrap() async {
    _connectionConfig = await _loadConnectionConfig();
    _themeMode = await _loadThemeMode();
    _isReady = true;
    notifyListeners();
  }

  Future<void> saveConnectionConfig(ConnectionConfig config) async {
    await _saveConnectionConfig(config);
    _connectionConfig = config;
    notifyListeners();
  }

  Future<void> clearConnectionConfig() async {
    await _clearConnectionConfig();
    _connectionConfig = null;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemeMode(mode);
  }
}
