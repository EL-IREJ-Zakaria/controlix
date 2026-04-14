import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/connection_config_model.dart';

class ConfigLocalDataSource {
  const ConfigLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  Future<ConnectionConfigModel?> loadConnectionConfig() async {
    final raw = _preferences.getString(AppConstants.prefsConfigKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return ConnectionConfigModel.fromJson(decoded);
  }

  Future<void> saveConnectionConfig(ConnectionConfigModel config) async {
    await _preferences.setString(
      AppConstants.prefsConfigKey,
      jsonEncode(config.toJson()),
    );
  }

  Future<void> clearConnectionConfig() async {
    await _preferences.remove(AppConstants.prefsConfigKey);
  }

  Future<ThemeMode> loadThemeMode() async {
    final rawValue = _preferences.getString(AppConstants.prefsThemeModeKey);
    return switch (rawValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final serialized = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _preferences.setString(AppConstants.prefsThemeModeKey, serialized);
  }
}
