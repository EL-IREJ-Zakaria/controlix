import 'package:flutter/material.dart';

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
    required this.onCreateTask,
    this.hasConnectionIssue = false,
  });

  final ConnectionConfig config;
  final ThemeMode themeMode;
  final int taskCount;
  final String statusLabel;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onEditConnection;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onCreateTask;
  final bool hasConnectionIssue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shellGradient = hasConnectionIssue
        ? <Color>[
            isDark ? const Color(0xFF341B1F) : const Color(0xFFF9DEDB),
            isDark ? const Color(0xFF25161F) : const Color(0xFFF1D6CF),
          ]
        : <Color>[
            isDark ? const Color(0xFF151F2D) : const Color(0xFFFFF8EF),
            isDark ? const Color(0xFF1B2A3D) : const Color(0xFFF2E7D7),
          ];

    final title = hasConnectionIssue
        ? 'La liaison Windows a besoin d’attention'
        : 'La station Windows est prête';
    final subtitle = hasConnectionIssue
        ? 'Le contrôleur ne récupère pas les tâches. Vérifie l’agent, la route locale ou la clé partagée.'
        : 'Le contrôleur mobile est relié au poste Windows via le réseau local. Les tâches sont exécutées sans modifier le backend.';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;

        return ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Container(
            padding: EdgeInsets.all(compact ? 20 : 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: shellGradient,
              ),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.44),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
                  blurRadius: 34,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -20,
                  child: _CardGlow(
                    size: compact ? 150 : 220,
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopActions(
                      statusLabel: statusLabel,
                      hasConnectionIssue: hasConnectionIssue,
                      themeMode: themeMode,
                      isRefreshing: isRefreshing,
                      onRefresh: onRefresh,
                      onEditConnection: onEditConnection,
                      onThemeChanged: onThemeChanged,
                    ),
                    SizedBox(height: compact ? 24 : 28),
                    Text(
                      title,
                      style: compact
                          ? theme.textTheme.displaySmall
                          : theme.textTheme.displayLarge?.copyWith(
                              fontSize: 46,
                            ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 460 : 620,
                      ),
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 24 : 30),
                    if (compact)
                      Column(
                        children: [
                          _MetricsRow(config: config, taskCount: taskCount),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: onCreateTask,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Créer une tâche'),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _MetricsRow(
                              config: config,
                              taskCount: taskCount,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 220,
                            child: FilledButton.icon(
                              onPressed: onCreateTask,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Nouvelle tâche'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions({
    required this.statusLabel,
    required this.hasConnectionIssue,
    required this.themeMode,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onEditConnection,
    required this.onThemeChanged,
  });

  final String statusLabel;
  final bool hasConnectionIssue;
  final ThemeMode themeMode;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onEditConnection;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 520;

        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              tooltip: 'Rafraîchir',
              onTap: isRefreshing ? null : onRefresh,
              child: isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
            ),
            _ActionButton(
              tooltip: 'Modifier la connexion',
              onTap: onEditConnection,
              child: Icon(
                Icons.router_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            PopupMenuButton<ThemeMode>(
              tooltip: 'Thème',
              onSelected: onThemeChanged,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('Suivre le système'),
                ),
                PopupMenuItem(value: ThemeMode.light, child: Text('Clair')),
                PopupMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
              ],
              child: _ActionButton(
                tooltip: 'Thème',
                onTap: null,
                child: Icon(
                  switch (themeMode) {
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.dark => Icons.dark_mode_rounded,
                    ThemeMode.system => Icons.brightness_auto_rounded,
                  },
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );

        final pill = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: hasConnectionIssue
                ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                : theme.colorScheme.secondary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: hasConnectionIssue
                  ? const Color(0xFFEF4444).withValues(alpha: 0.24)
                  : theme.colorScheme.secondary.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasConnectionIssue
                    ? Icons.warning_amber_rounded
                    : Icons.verified_rounded,
                size: 18,
                color: hasConnectionIssue
                    ? const Color(0xFFEF4444)
                    : theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pill,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: pill),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.config, required this.taskCount});

  final ConnectionConfig config;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricTile(
          icon: Icons.dns_rounded,
          label: 'Endpoint',
          value: '${config.ipAddress}:${config.port}',
        ),
        _MetricTile(
          icon: Icons.dashboard_customize_rounded,
          label: 'Tâches',
          value: '$taskCount synchronisées',
        ),
        const _MetricTile(
          icon: Icons.key_rounded,
          label: 'Authentification',
          value: 'Clé locale active',
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.18 : 0.05,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.child,
    required this.onTap,
  });

  final String tooltip;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.20
                    : 0.05,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.40),
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _CardGlow extends StatelessWidget {
  const _CardGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
