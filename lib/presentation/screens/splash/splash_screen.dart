import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_panel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final gradient = AppTheme.pageGradient(theme.brightness);
        final isCompact = MediaQuery.sizeOf(context).width < 760;

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SplashFieldPainter(
                        lineColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        nodeColor: theme.colorScheme.secondary.withValues(
                          alpha: 0.10,
                        ),
                        progress: progress,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -90,
                  right: -30,
                  child: _GlowHalo(
                    size: 280,
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -20,
                  child: _GlowHalo(
                    size: 320,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: GlassPanel(
                          borderRadius: 36,
                          padding: EdgeInsets.all(isCompact ? 22 : 30),
                          child: isCompact
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SplashIdentity(
                                      progress: progress,
                                      compact: true,
                                    ),
                                    const SizedBox(height: 26),
                                    Center(
                                      child: _ControlHub(progress: progress),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 11,
                                      child: _SplashIdentity(
                                        progress: progress,
                                      ),
                                    ),
                                    const SizedBox(width: 28),
                                    Expanded(
                                      flex: 9,
                                      child: _ControlHub(progress: progress),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SplashIdentity extends StatelessWidget {
  const _SplashIdentity({required this.progress, this.compact = false});

  final double progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reveal = Curves.easeOutBack
        .transform((progress / 0.78).clamp(0, 1))
        .clamp(0.0, 1.0);
    final titleStyle = compact
        ? theme.textTheme.displaySmall
        : theme.textTheme.displayLarge?.copyWith(fontSize: 62);

    return Opacity(
      opacity: reveal,
      child: Transform.translate(
        offset: Offset(0, (1 - reveal) * 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                'CONTROL ROOM STARTUP',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('Controlix', style: titleStyle),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 420 : 520),
              child: Text(
                'Une nouvelle UI plus nette, plus structurée et plus crédible pour piloter des tâches PowerShell à distance sans toucher au backend.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _SplashChip(
                  icon: Icons.dashboard_customize_rounded,
                  label: 'UI redesign',
                ),
                _SplashChip(icon: Icons.lan_rounded, label: 'LAN workflow'),
                _SplashChip(icon: Icons.code_rounded, label: 'Backend intact'),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.18 : 0.05,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.38),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Préparation de la session',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _ProgressRail(progress: progress),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StepBadge(label: 'Config', active: progress < 0.34),
                      _StepBadge(
                        label: 'Restore',
                        active: progress >= 0.34 && progress < 0.72,
                      ),
                      _StepBadge(label: 'Open', active: progress >= 0.72),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlHub extends StatelessWidget {
  const _ControlHub({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final phase = Curves.easeInOutSine.transform(progress);

    return Center(
      child: SizedBox(
        width: 340,
        height: 340,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(340),
              painter: _RadarPainter(
                progress: phase,
                primary: primary,
                secondary: secondary,
              ),
            ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Icon(Icons.memory_rounded, color: Colors.white, size: 54),
            ),
            const Positioned(
              top: 28,
              right: 36,
              child: _MetricBadge(label: 'Agent', value: 'Ready'),
            ),
            const Positioned(
              left: 18,
              bottom: 56,
              child: _MetricBadge(label: 'Tasks', value: 'Sync'),
            ),
            const Positioned(
              right: 22,
              bottom: 28,
              child: _MetricBadge(label: 'Theme', value: 'New UI'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashChip extends StatelessWidget {
  const _SplashChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 10,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.28 + (progress * 0.58),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.24)
              : theme.colorScheme.outline.withValues(alpha: 0.40),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: active
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.62),
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.22 : 0.06,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowHalo extends StatelessWidget {
  const _GlowHalo({required this.size, required this.color});

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

class _SplashFieldPainter extends CustomPainter {
  const _SplashFieldPainter({
    required this.lineColor,
    required this.nodeColor,
    required this.progress,
  });

  final Color lineColor;
  final Color nodeColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 42) {
      final drift = math.sin((y / size.height) * math.pi + progress) * 10;
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.45, y + drift, size.width, y - 6);
      canvas.drawPath(path, linePaint);
    }

    final nodePaint = Paint()..color = nodeColor;
    final points = [
      Offset(size.width * 0.14, size.height * 0.20),
      Offset(size.width * 0.72, size.height * 0.16),
      Offset(size.width * 0.28, size.height * 0.66),
      Offset(size.width * 0.84, size.height * 0.72),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashFieldPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.nodeColor != nodeColor ||
        oldDelegate.progress != progress;
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  final double progress;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;

    for (final factor in [0.34, 0.52, 0.70, 0.88]) {
      final paint = Paint()
        ..color = Color.lerp(
          primary,
          secondary,
          factor,
        )!.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = factor == 0.34 ? 2 : 1;
      canvas.drawCircle(center, maxRadius * factor, paint);
    }

    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          primary.withValues(alpha: 0),
          primary,
          secondary,
          primary.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.34, 0.68, 1.0],
        transform: GradientRotation(progress * math.pi * 0.5),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.74))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.74),
      -0.7,
      1.4,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
