import 'package:flutter/material.dart';

class TaskVisuals {
  const TaskVisuals._();

  static const Map<String, IconData> iconMap = <String, IconData>{
    'bolt': Icons.bolt_rounded,
    'desktop': Icons.desktop_windows_rounded,
    'power': Icons.power_settings_new_rounded,
    'terminal': Icons.terminal_rounded,
    'shield': Icons.shield_moon_rounded,
    'folder': Icons.folder_open_rounded,
    'network': Icons.router_rounded,
    'lock': Icons.lock_rounded,
    'settings': Icons.settings_rounded,
    'rocket': Icons.rocket_launch_rounded,
  };

  static const List<String> accentPalette = <String>[
    '#4F46E5',
    '#2563EB',
    '#0EA5E9',
    '#7C3AED',
    '#8B5CF6',
    '#14B8A6',
    '#F97316',
    '#EF4444',
  ];
}
