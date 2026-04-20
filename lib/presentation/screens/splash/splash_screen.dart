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
        final gradient = AppTheme.pageGradient(theme.brightness);
        final progress = Curves.easeOutCubic.transform(_controller.value);

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
                      painter: _BackdropPatternPainter(
                        progress: progress,
                        strokeColor: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        accentColor: theme.colorScheme.secondary.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -100 + (14 * progress),
                  left: -50,
                  child: _GlowOrb(
                    size: 260,
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                Positioned(
                  top: 72 - (8 * progress),
                  right: -90,
                  child: _GlowOrb(
                    size: 280,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  bottom: -150 + (18 * progress),
                  left: 12,
                  child: _GlowOrb(
                    size: 340,
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final metrics = _SplashMetrics.fromSize(
                        constraints.biggest,
                      );
                      final panelReveal = _interval(0.10, 0.55, progress);
                      final copyReveal = _interval(0.22, 0.84, progress);
                      final visualReveal = _interval(0.28, 0.92, progress);
                      final footerReveal = _interval(0.70, 1.00, progress);

                      return Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            metrics.screenPadding,
                            metrics.screenTopPadding,
                            metrics.screenPadding,
                            metrics.screenBottomPadding,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _EntranceReveal(
                                  progress: _interval(0.00, 0.24, progress),
                                  yOffset: 20,
                                  scaleFrom: 0.96,
                                  child: _ModeBadge(metrics: metrics),
                                ),
                                SizedBox(height: metrics.sectionGap),
                                _EntranceReveal(
                                  progress: panelReveal,
                                  yOffset: 32,
                                  scaleFrom: 0.985,
                                  child: GlassPanel(
                                    blurSigma: 10,
                                    borderRadius: metrics.panelRadius,
                                    padding: EdgeInsets.all(
                                      metrics.panelPadding,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(
                                          alpha:
                                              theme.brightness ==
                                                  Brightness.dark
                                              ? 0.12
                                              : 0.84,
                                        ),
                                        Colors.white.withValues(
                                          alpha:
                                              theme.brightness ==
                                                  Brightness.dark
                                              ? 0.06
                                              : 0.72,
                                        ),
                                      ],
                                    ),
                                    child: metrics.isCompact
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _EntranceReveal(
                                                progress: visualReveal,
                                                yOffset: 18,
                                                scaleFrom: 0.88,
                                                child: Center(
                                                  child: _HeroVisual(
                                                    metrics: metrics,
                                                    progress: progress,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: metrics.contentGap,
                                              ),
                                              _EntranceReveal(
                                                progress: copyReveal,
                                                yOffset: 20,
                                                child: _SplashContent(
                                                  metrics: metrics,
                                                  progress: progress,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 11,
                                                child: _EntranceReveal(
                                                  progress: copyReveal,
                                                  xOffset: -16,
                                                  yOffset: 20,
                                                  child: _SplashContent(
                                                    metrics: metrics,
                                                    progress: progress,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: metrics.visualGap,
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: _EntranceReveal(
                                                  progress: visualReveal,
                                                  xOffset: 12,
                                                  yOffset: 12,
                                                  scaleFrom: 0.88,
                                                  child: _HeroVisual(
                                                    metrics: metrics,
                                                    progress: progress,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                SizedBox(height: metrics.footerTopGap),
                                _EntranceReveal(
                                  progress: footerReveal,
                                  yOffset: 12,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      'Launching the local workspace, restoring recent activity, and preparing the Windows bridge in the background.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.62),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _interval(double begin, double end, double value) {
    final normalized = ((value - begin) / (end - begin)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(normalized);
  }
}

class _SplashMetrics {
  const _SplashMetrics({
    required this.isCompact,
    required this.screenPadding,
    required this.screenTopPadding,
    required this.screenBottomPadding,
    required this.panelPadding,
    required this.panelRadius,
    required this.sectionGap,
    required this.contentGap,
    required this.visualGap,
    required this.footerTopGap,
    required this.heroSize,
    required this.logoSize,
    required this.titleSize,
    required this.subtitleMaxWidth,
  });

  final bool isCompact;
  final double screenPadding;
  final double screenTopPadding;
  final double screenBottomPadding;
  final double panelPadding;
  final double panelRadius;
  final double sectionGap;
  final double contentGap;
  final double visualGap;
  final double footerTopGap;
  final double heroSize;
  final double logoSize;
  final double titleSize;
  final double subtitleMaxWidth;

  factory _SplashMetrics.fromSize(Size size) {
    final compact = size.width < 720;
    final tinyHeight = size.height < 760;

    return _SplashMetrics(
      isCompact: compact,
      screenPadding: compact ? 20 : 28,
      screenTopPadding: compact ? 22 : 28,
      screenBottomPadding: compact ? 22 : 30,
      panelPadding: compact ? 22 : 30,
      panelRadius: compact ? 32 : 40,
      sectionGap: compact ? 18 : 22,
      contentGap: compact ? 22 : 0,
      visualGap: compact ? 0 : 28,
      footerTopGap: tinyHeight ? 14 : 18,
      heroSize: compact ? 220 : 310,
      logoSize: compact ? 74 : 92,
      titleSize: compact ? 46 : 62,
      subtitleMaxWidth: compact ? size.width - 88 : 460,
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.metrics, required this.progress});

  final _SplashMetrics metrics;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.70);
    final soft = theme.colorScheme.onSurface.withValues(alpha: 0.58);
    final stageIndex = (progress * 3).floor().clamp(0, 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WelcomeWordmark(progress: progress, metrics: metrics),
        const SizedBox(height: 14),
        _BrandRibbon(metrics: metrics, progress: progress),
        const SizedBox(height: 18),
        Text(
          'Controlix',
          style:
              (metrics.isCompact
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.displayLarge)
                  ?.copyWith(
                    fontSize: metrics.titleSize,
                    height: 0.94,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                  ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: metrics.subtitleMaxWidth),
          child: Text(
            'A more comfortable splash screen with a calmer layout, softer motion, and a responsive composition that adapts cleanly to phones and larger displays.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: muted,
              height: 1.58,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _InfoChip(icon: Icons.tune_rounded, label: 'Adjustable layout'),
            _InfoChip(icon: Icons.waves_rounded, label: 'Soft animation'),
            _InfoChip(icon: Icons.laptop_windows_rounded, label: 'Local-first'),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.16 : 0.04,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.08 : 0.48,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusPulse(progress: progress),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preparing your workspace',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The app restores essentials first, then the dashboard arrives without blocking the first paint.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: soft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ProgressRail(progress: progress),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StepPill(label: 'Connect', active: stageIndex == 0),
                  _StepPill(label: 'Restore', active: stageIndex == 1),
                  _StepPill(label: 'Open', active: stageIndex == 2),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeWordmark extends StatelessWidget {
  const _WelcomeWordmark({required this.progress, required this.metrics});

  final double progress;
  final _SplashMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reveal = Curves.easeOutBack.transform(
      (progress / 0.68).clamp(0.0, 1.0),
    );
    final shimmer = ((math.sin((progress * math.pi * 2.2) - 0.9) + 1) * 0.5);
    final travelX = (1 - reveal) * (metrics.isCompact ? 22.0 : 34.0);
    final glowAlpha = 0.12 + (shimmer * 0.10);

    return Opacity(
      opacity: reveal,
      child: Transform.translate(
        offset: Offset(-travelX, (1 - reveal) * 10),
        child: Stack(
          children: [
            Text(
              'Welcome',
              style:
                  (metrics.isCompact
                          ? theme.textTheme.headlineMedium
                          : theme.textTheme.displaySmall)
                      ?.copyWith(
                        fontSize: metrics.isCompact ? 30 : 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        foreground: Paint()
                          ..shader =
                              LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  theme.colorScheme.onSurface.withValues(
                                    alpha: 0.92,
                                  ),
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.94,
                                  ),
                                  theme.colorScheme.secondary.withValues(
                                    alpha: 0.86,
                                  ),
                                ],
                                stops: const [0.0, 0.56, 1.0],
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  metrics.isCompact ? 180 : 240,
                                  metrics.isCompact ? 40 : 48,
                                ),
                              ),
                      ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.32,
                    child: Container(
                      height: metrics.isCompact ? 36 : 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: glowAlpha),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
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
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.metrics, required this.progress});

  final _SplashMetrics metrics;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final ringPhase = Curves.easeInOutSine.transform(progress);

    return SizedBox(
      width: metrics.heroSize,
      height: metrics.heroSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(metrics.heroSize),
            painter: _HaloRingsPainter(
              progress: ringPhase,
              primary: primary,
              secondary: secondary,
            ),
          ),
          Container(
            width: metrics.heroSize * 0.68,
            height: metrics.heroSize * 0.68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: 0.14),
                  secondary.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.58, 1.0],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -8 * (1 - progress)),
            child: Container(
              width: metrics.logoSize,
              height: metrics.logoSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, secondary],
                ),
                borderRadius: BorderRadius.circular(metrics.logoSize * 0.30),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.28),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(metrics.logoSize * 0.18),
                  child: CustomPaint(
                    size: Size.square(metrics.logoSize * 0.44),
                    painter: _ControlixLogoPainter(
                      progress: ringPhase,
                      primary: Colors.white,
                      secondary: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: metrics.heroSize * 0.16,
            top: metrics.heroSize * 0.44,
            child: _MiniMetric(
              label: 'Local link',
              value: 'Secured',
              accent: primary,
            ),
          ),
          Positioned(
            right: metrics.heroSize * 0.10,
            top: metrics.heroSize * 0.20,
            child: _MiniMetric(
              label: 'Startup',
              value: 'Smoothed',
              accent: secondary,
            ),
          ),
          Positioned(
            right: metrics.heroSize * 0.10,
            bottom: metrics.heroSize * 0.12,
            child: _MiniMetric(
              label: 'History',
              value: 'Ready',
              accent: primary.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.metrics});

  final _SplashMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.isCompact ? 14 : 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'COMFORT MODE STARTUP',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandRibbon extends StatelessWidget {
  const _BrandRibbon({required this.metrics, required this.progress});

  final _SplashMetrics metrics;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.isCompact ? 12 : 14,
        vertical: metrics.isCompact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.14 : 0.04,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.08 : 0.52,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: metrics.isCompact ? 44 : 52,
            height: metrics.isCompact ? 44 : 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: 0.22),
                  secondary.withValues(alpha: 0.14),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Center(
              child: CustomPaint(
                size: Size.square(metrics.isCompact ? 24 : 28),
                painter: _ControlixLogoPainter(
                  progress: progress,
                  primary: primary,
                  secondary: secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONTROLIX',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Modern local automation launch',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

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
          color: Colors.white.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.08 : 0.52,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPulse extends StatelessWidget {
  const _StatusPulse({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = 0.90 + (progress * 0.14);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.40),
              blurRadius: 16,
              spreadRadius: 1.5,
            ),
          ],
        ),
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
            widthFactor: 0.36 + (progress * 0.46),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.label, required this.active});

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
              ? theme.colorScheme.primary.withValues(alpha: 0.26)
              : Colors.white.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.06 : 0.42,
                ),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: active
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.68),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.22 : 0.06,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.08 : 0.46,
          ),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntranceReveal extends StatelessWidget {
  const _EntranceReveal({
    required this.progress,
    required this.child,
    this.xOffset = 0,
    this.yOffset = 0,
    this.scaleFrom = 1,
  });

  final double progress;
  final Widget child;
  final double xOffset;
  final double yOffset;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final scale = scaleFrom + ((1 - scaleFrom) * clamped);

    return Opacity(
      opacity: clamped,
      child: Transform.translate(
        offset: Offset(xOffset * (1 - clamped), yOffset * (1 - clamped)),
        child: Transform.scale(scale: scale, child: child),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

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

class _BackdropPatternPainter extends CustomPainter {
  const _BackdropPatternPainter({
    required this.progress,
    required this.strokeColor,
    required this.accentColor,
  });

  final double progress;
  final Color strokeColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final nodePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final rows = <double>[0.16, 0.34, 0.56, 0.78];
    for (var i = 0; i < rows.length; i++) {
      final y = size.height * rows[i];
      final drift = (1 - progress) * 18;
      final path = Path()
        ..moveTo(0, y + (i.isEven ? drift : -drift))
        ..quadraticBezierTo(
          size.width * 0.42,
          y - 32 + (drift * 0.4),
          size.width,
          y + 12,
        );
      canvas.drawPath(path, linePaint);
    }

    final nodes = <Offset>[
      Offset(size.width * 0.16, size.height * 0.20),
      Offset(size.width * 0.34, size.height * 0.38),
      Offset(size.width * 0.56, size.height * 0.28),
      Offset(size.width * 0.80, size.height * 0.46),
      Offset(size.width * 0.22, size.height * 0.74),
      Offset(size.width * 0.68, size.height * 0.72),
    ];

    for (final node in nodes) {
      canvas.drawCircle(node, 3, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPatternPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.accentColor != accentColor;
  }
}

class _HaloRingsPainter extends CustomPainter {
  const _HaloRingsPainter({
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
    final radii = <double>[0.28, 0.44, 0.60, 0.77];

    for (var i = 0; i < radii.length; i++) {
      final blend = i / (radii.length - 1);
      final color = Color.lerp(primary, secondary, blend)!;
      final alpha = 0.08 + ((1 - blend) * 0.06) + (progress * 0.03);
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 2.2 : 1.2;

      canvas.drawCircle(center, maxRadius * radii[i], paint);
    }

    final arcPaint = Paint()
      ..shader = LinearGradient(
        colors: [primary, secondary],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.60))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.60),
      -0.55,
      1.10 + (progress * 0.40),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HaloRingsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}

class _ControlixLogoPainter extends CustomPainter {
  const _ControlixLogoPainter({
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
    final radius = size.width * 0.34;
    final strokeWidth = size.width * 0.16;
    final ringRect = Rect.fromCircle(center: center, radius: radius);
    final rotation = progress * math.pi * 0.16;

    final ringPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        transform: GradientRotation(rotation),
        colors: [
          secondary.withValues(alpha: 0.84),
          primary,
          secondary.withValues(alpha: 0.92),
          primary.withValues(alpha: 0.72),
        ],
        stops: const [0.0, 0.30, 0.70, 1.0],
      ).createShader(ringRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(ringRect, 0.72, math.pi * 1.58, false, ringPaint);

    final slashPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [primary, Color.lerp(primary, secondary, 0.62)!],
          ).createShader(
            Rect.fromLTWH(
              center.dx - radius * 0.68,
              center.dy - radius * 0.82,
              radius * 1.28,
              radius * 1.64,
            ),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.70
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx + radius * 0.24, center.dy - radius * 0.58),
      Offset(center.dx - radius * 0.46, center.dy + radius * 0.42),
      slashPaint,
    );

    final nodeCenter = Offset(
      center.dx + (math.cos(0.72) * radius),
      center.dy + (math.sin(0.72) * radius),
    );
    canvas.drawCircle(nodeCenter, strokeWidth * 0.38, Paint()..color = primary);

    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center.translate(-radius * 0.04, -radius * 0.04),
        radius: radius * 0.76,
      ),
      -math.pi * 0.54,
      math.pi * 0.34,
      false,
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ControlixLogoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
