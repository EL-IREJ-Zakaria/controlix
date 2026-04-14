import 'package:flutter/material.dart';

import '../../core/widgets/glass_panel.dart';
import '../../domain/entities/connection_config.dart';

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({
    super.key,
    required this.config,
    required this.themeMode,
    required this.taskCount,
    required this.statusLabel,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onEditConnection,
    required this.onThemeChanged,
  });

  final ConnectionConfig config;
  final ThemeMode themeMode;
  final int taskCount;
  final String statusLabel;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onEditConnection;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          theme.colorScheme.primary.withValues(alpha: isDark ? 0.28 : 0.16),
          theme.colorScheme.secondary.withValues(alpha: isDark ? 0.20 : 0.12),
          (isDark ? Colors.white : Colors.white).withValues(alpha: 0.08),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.12 : 0.72,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Windows agent ready on your LAN',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Route tasks to ${config.baseUrl} with a shared secret and a single tap.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Refresh tasks',
                    onPressed: isRefreshing ? null : onRefresh,
                    icon: isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Edit connection',
                    onPressed: onEditConnection,
                    icon: const Icon(Icons.router_rounded),
                  ),
                  PopupMenuButton<ThemeMode>(
                    tooltip: 'Theme mode',
                    onSelected: onThemeChanged,
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: ThemeMode.system,
                          child: Text('Follow system'),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light mode'),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark mode'),
                        ),
                      ];
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: isDark ? 0.45 : 0.72),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(switch (themeMode) {
                        ThemeMode.light => Icons.light_mode_rounded,
                        ThemeMode.dark => Icons.dark_mode_rounded,
                        ThemeMode.system => Icons.brightness_auto_rounded,
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                icon: Icons.lan_rounded,
                label: config.ipAddress,
                value: 'Port ${config.port}',
              ),
              _InfoChip(
                icon: Icons.grid_view_rounded,
                label: '$taskCount tasks',
                value: 'Synced from agent',
              ),
              const _InfoChip(
                icon: Icons.verified_user_rounded,
                label: 'Shared secret',
                value: 'Stored locally',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
