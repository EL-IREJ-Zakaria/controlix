import 'package:flutter/material.dart';

import '../entities/connection_config.dart';

abstract class AppSettingsRepository {
  Future<ConnectionConfig?> loadConnectionConfig();

  Future<void> saveConnectionConfig(ConnectionConfig config);

  Future<void> clearConnectionConfig();

  Future<ThemeMode> loadThemeMode();

  Future<void> saveThemeMode(ThemeMode themeMode);
}
