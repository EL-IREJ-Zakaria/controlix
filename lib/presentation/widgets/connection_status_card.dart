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
    final foregroundColor = isDark ? Colors.white : const Color(0xFF15203D);
    final mutedColor = foregroundColor.withValues(alpha: isDark ? 0.66 : 0.72);
    final shellGradient = hasConnectionIssue
        ? <Color>[
            isDark ? const Color(0xFF4F2033) : const Color(0xFFF4CAD4),
            isDark ? const Color(0xFF31172C) : const Color(0xFFE9B8C7),
            isDark ? const Color(0xFF1D1730) : const Color(0xFFD8D3FF),
          ]
        : <Color>[
            isDark ? const Color(0xFF314B88) : const Color(0xFFCFDBFF),
            isDark ? const Color(0xFF212F61) : const Color(0xFFB8C7F2),
            isDark ? const Color(0xFF181C48) : const Color(0xFFA7B9E6),
          ];
    final frameColor = Colors.white.withValues(alpha: isDark ? 0.10 : 0.48);
    final title = hasConnectionIssue
        ? 'Windows agent needs attention'
        : 'Windows agent ready on your LAN';
    final description = hasConnectionIssue
        ? 'Refresh tasks or update the route to ${config.baseUrl} before dispatching automations.'
        : 'Route tasks to ${config.baseUrl} with a shared secret and a single tap.';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final titleStyle =
            (compact
                    ? theme.textTheme.headlineMedium
                    : theme.textTheme.displaySmall)
                ?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  height: 0.96,
                  letterSpacing: -1.4,
                );

        return ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 34 : 40),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              compact ? 18 : 28,
              compact ? 18 : 24,
              compact ? 18 : 28,
              compact ? 18 : 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: shellGradient,
              ),
              borderRadius: BorderRadius.circular(compact ? 34 : 40),
              border: Border.all(color: frameColor),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -44,
                  right: -10,
                  child: _Halo(
                    size: compact ? 160 : 220,
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: -30,
                  child: _Halo(
                    size: compact ? 190 : 240,
                    color:
                        (hasConnectionIssue
                                ? const Color(0xFFFF7C93)
                                : const Color(0xFF79A8FF))
                            .withValues(alpha: isDark ? 0.14 : 0.20),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(
                      statusLabel: statusLabel,
                      isDark: isDark,
                      hasConnectionIssue: hasConnectionIssue,
                      foregroundColor: foregroundColor,
                      isRefreshing: isRefreshing,
                      onRefresh: onRefresh,
                      onEditConnection: onEditConnection,
                      themeMode: themeMode,
                      onThemeChanged: onThemeChanged,
                    ),
                    SizedBox(height: compact ? 28 : 34),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 190 : 360,
                      ),
                      child: Text(title, style: titleStyle),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 170 : 340,
                      ),
                      child: Text(
                        description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: mutedColor,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 28 : 34),
                    if (compact)
                      _CompactFooter(
                        config: config,
                        taskCount: taskCount,
                        onCreateTask: onCreateTask,
                        foregroundColor: foregroundColor,
                        isDark: isDark,
                      )
                    else
                      _WideFooter(
                        config: config,
                        taskCount: taskCount,
                        onCreateTask: onCreateTask,
                        foregroundColor: foregroundColor,
                        isDark: isDark,
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

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.statusLabel,
    required this.isDark,
    required this.hasConnectionIssue,
    required this.foregroundColor,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onEditConnection,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final String statusLabel;
  final bool isDark;
  final bool hasConnectionIssue;
  final Color foregroundColor;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onEditConnection;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionButton(
          tooltip: 'Refresh tasks',
          onPressed: isRefreshing ? null : onRefresh,
          child: isRefreshing
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Icon(Icons.refresh_rounded, color: foregroundColor, size: 20),
        ),
        _ActionButton(
          tooltip: 'Edit connection',
          onPressed: onEditConnection,
          child: Icon(Icons.router_rounded, color: foregroundColor, size: 20),
        ),
        _ThemeModeButton(
          themeMode: themeMode,
          foregroundColor: foregroundColor,
          onThemeChanged: onThemeChanged,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackedHeader = constraints.maxWidth < 430;

        if (stackedHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusPill(
                label: statusLabel,
                isDark: isDark,
                hasConnectionIssue: hasConnectionIssue,
                foregroundColor: foregroundColor,
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatusPill(
                label: statusLabel,
                isDark: isDark,
                hasConnectionIssue: hasConnectionIssue,
                foregroundColor: foregroundColor,
              ),
            ),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

class _CompactFooter extends StatelessWidget {
  const _CompactFooter({
    required this.config,
    required this.taskCount,
    required this.onCreateTask,
    required this.foregroundColor,
    required this.isDark,
  });

  final ConnectionConfig config;
  final int taskCount;
  final VoidCallback onCreateTask;
  final Color foregroundColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FractionallySizedBox(
          widthFactor: 0.54,
          child: _InfoChip(
            icon: Icons.device_hub_rounded,
            label: config.ipAddress,
            value: 'Port ${config.port}',
            foregroundColor: foregroundColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _InfoChip(
                icon: Icons.dashboard_customize_rounded,
                label: '$taskCount tasks',
                value: 'Synced from agent',
                foregroundColor: foregroundColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _CreateTaskButton(onPressed: onCreateTask),
            ),
          ],
        ),
      ],
    );
  }
}

class _WideFooter extends StatelessWidget {
  const _WideFooter({
    required this.config,
    required this.taskCount,
    required this.onCreateTask,
    required this.foregroundColor,
    required this.isDark,
  });

  final ConnectionConfig config;
  final int taskCount;
  final VoidCallback onCreateTask;
  final Color foregroundColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 210,
                child: _InfoChip(
                  icon: Icons.device_hub_rounded,
                  label: config.ipAddress,
                  value: 'Port ${config.port}',
                  foregroundColor: foregroundColor,
                  isDark: isDark,
                ),
              ),
              SizedBox(
                width: 210,
                child: _InfoChip(
                  icon: Icons.dashboard_customize_rounded,
                  label: '$taskCount tasks',
                  value: 'Synced from agent',
                  foregroundColor: foregroundColor,
                  isDark: isDark,
                ),
              ),
              SizedBox(
                width: 210,
                child: _InfoChip(
                  icon: Icons.key_rounded,
                  label: 'Shared secret',
                  value: 'Stored locally',
                  foregroundColor: foregroundColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 188, child: _CreateTaskButton(onPressed: onCreateTask)),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.isDark,
    required this.hasConnectionIssue,
    required this.foregroundColor,
  });

  final String label;
  final bool isDark;
  final bool hasConnectionIssue;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final statusColor = hasConnectionIssue
        ? const Color(0xFFFB7185)
        : const Color(0xFF22C55E);
    final labelColor = hasConnectionIssue ? foregroundColor : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: hasConnectionIssue
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF22C55E), Color(0xFF16A34A)],
              ),
        color: hasConnectionIssue
            ? statusColor.withValues(alpha: isDark ? 0.20 : 0.28)
            : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasConnectionIssue
              ? Colors.white.withValues(alpha: isDark ? 0.10 : 0.52)
              : statusColor.withValues(alpha: 0.84),
        ),
        boxShadow: hasConnectionIssue
            ? null
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x3322C55E),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(
            hasConnectionIssue
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            size: 18,
            color: labelColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.themeMode,
    required this.foregroundColor,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final Color foregroundColor;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme mode',
      onSelected: onThemeChanged,
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: ThemeMode.system, child: Text('Follow system')),
          PopupMenuItem(value: ThemeMode.light, child: Text('Light mode')),
          PopupMenuItem(value: ThemeMode.dark, child: Text('Dark mode')),
        ];
      },
      child: _ActionFrame(
        child: Icon(
          switch (themeMode) {
            ThemeMode.light => Icons.light_mode_rounded,
            ThemeMode.dark => Icons.dark_mode_rounded,
            ThemeMode.system => Icons.brightness_auto_rounded,
          },
          color: foregroundColor,
          size: 20,
        ),
      ),
    );
  }
}

class _ActionFrame extends StatelessWidget {
  const _ActionFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Center(child: child),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.child,
    this.onPressed,
  });

  final String tooltip;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: _ActionFrame(child: child),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.foregroundColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color foregroundColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.11 : 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: foregroundColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.64),
                    fontWeight: FontWeight.w500,
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

class _CreateTaskButton extends StatelessWidget {
  const _CreateTaskButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF5A83D1), Color(0xFF4669B6)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x3322396A),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 21),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'New task',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.size, required this.color});

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
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
