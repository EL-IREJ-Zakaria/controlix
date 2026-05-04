import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ControlixAnimatedBackground extends StatefulWidget {
  const ControlixAnimatedBackground({
    super.key,
    this.child,
    this.particleCount = 32,
    this.speed = 1.0,
    this.blurSigma = 10,
    this.colors = const ControlixBackgroundColors(),
    this.enableParticles = true,
  });

  final Widget? child;
  final int particleCount;
  final double speed;
  final double blurSigma;
  final ControlixBackgroundColors colors;
  final bool enableParticles;

  @override
  State<ControlixAnimatedBackground> createState() =>
      _ControlixAnimatedBackgroundState();
}

@immutable
class ControlixBackgroundColors {
  const ControlixBackgroundColors({
    this.top = const Color(0xFF05060A),
    this.bottom = const Color(0xFF071634),
    this.neonBlue = const Color(0xFF34D6FF),
    this.neonPurple = const Color(0xFFB04CFF),
  });

  final Color top;
  final Color bottom;
  final Color neonBlue;
  final Color neonPurple;
}

class _ControlixAnimatedBackgroundState
    extends State<ControlixAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 18 * 1000),
    )..repeat();

    _particles = _buildParticles(widget.particleCount, widget.colors);
  }

  @override
  void didUpdateWidget(covariant ControlixAnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount ||
        oldWidget.colors != widget.colors) {
      _particles = _buildParticles(widget.particleCount, widget.colors);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ControlixBackgroundPainter(
                animation: _controller,
                particles: _particles,
                speed: widget.speed,
                blurSigma: widget.blurSigma,
                colors: widget.colors,
                enableParticles: widget.enableParticles,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        child ?? const SizedBox.shrink(),
      ],
    );
  }
}

List<_Particle> _buildParticles(int count, ControlixBackgroundColors colors) {
  final cappedCount = count.clamp(0, 96).toInt();
  final random = Random(0x0C011701);
  final particles = <_Particle>[];
  particles.length = cappedCount;

  for (var i = 0; i < cappedCount; i++) {
    final isBlue = random.nextDouble() < 0.64;
    final tint = isBlue ? colors.neonBlue : colors.neonPurple;

    final radius = ui.lerpDouble(1.6, 5.2, random.nextDouble())!;
    final glowRadius = radius * ui.lerpDouble(1.8, 3.4, random.nextDouble())!;

    particles[i] = _Particle(
      baseX: random.nextDouble(),
      baseY: random.nextDouble(),
      radius: radius,
      glowRadius: glowRadius,
      driftX: ui.lerpDouble(0.012, 0.07, random.nextDouble())!,
      driftY: ui.lerpDouble(0.006, 0.05, random.nextDouble())!,
      speed: ui.lerpDouble(0.12, 0.75, random.nextDouble())!,
      phase: random.nextDouble() * pi * 2,
      tint: tint,
      pulse: ui.lerpDouble(0.4, 1.1, random.nextDouble())!,
    );
  }

  return particles;
}

@immutable
class _Particle {
  const _Particle({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.glowRadius,
    required this.driftX,
    required this.driftY,
    required this.speed,
    required this.phase,
    required this.tint,
    required this.pulse,
  });

  final double baseX;
  final double baseY;
  final double radius;
  final double glowRadius;
  final double driftX;
  final double driftY;
  final double speed;
  final double phase;
  final Color tint;
  final double pulse;
}

class _ControlixBackgroundPainter extends CustomPainter {
  _ControlixBackgroundPainter({
    required this.animation,
    required this.particles,
    required this.speed,
    required this.blurSigma,
    required this.colors,
    required this.enableParticles,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Particle> particles;
  final double speed;
  final double blurSigma;
  final ControlixBackgroundColors colors;
  final bool enableParticles;

  final Paint _backgroundPaint = Paint();
  final Paint _glowPaint = Paint()..blendMode = BlendMode.plus;
  final Paint _corePaint = Paint();
  final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..blendMode = BlendMode.plus;
  final Paint _vignettePaint = Paint();

  ui.Shader? _shader;
  Size? _shaderSize;
  ui.Shader? _vignetteShader;
  Size? _vignetteShaderSize;

  @override
  void paint(Canvas canvas, Size size) {
    _ensureShader(size);
    _backgroundPaint.shader = _shader;
    canvas.drawRect(Offset.zero & size, _backgroundPaint);

    _paintNeonVignette(canvas, size);

    if (!enableParticles || particles.isEmpty) return;

    final t = ((animation.value) * speed) % 1.0;
    final minSide = min(size.width, size.height);
    final blur = ui.clampDouble(blurSigma, 0, 32);
    final glowBlur = MaskFilter.blur(BlurStyle.normal, blur);

    _glowPaint.maskFilter = glowBlur;

    for (final p in particles) {
      final driftT = (t * p.speed + p.phase / (pi * 2)) % 1.0;
      final wobble = sin((driftT * pi * 2) + p.phase);
      final wobble2 = cos((driftT * pi * 2) + p.phase * 0.7);

      final x = (p.baseX + wobble * p.driftX) % 1.0;
      final y = (p.baseY - driftT * 0.35 + wobble2 * p.driftY) % 1.0;

      final px = x * size.width;
      final py = y * size.height;

      final pulse = (sin((t * pi * 2) + p.phase) * 0.5 + 0.5) * p.pulse;
      final coreOpacity = ui.clampDouble(0.45 + pulse * 0.35, 0.0, 1.0);
      final glowOpacity = ui.clampDouble(0.18 + pulse * 0.22, 0.0, 1.0);

      final coreRadius = p.radius * (0.88 + pulse * 0.38);
      final glowRadius = p.glowRadius * (0.9 + pulse * 0.6);

      final tint = p.tint;
      _glowPaint.color = tint.withValues(alpha: glowOpacity);
      _corePaint.color = tint.withValues(alpha: coreOpacity);

      canvas.drawCircle(Offset(px, py), glowRadius, _glowPaint);
      canvas.drawCircle(Offset(px, py), coreRadius, _corePaint);

      if (minSide > 420 && glowOpacity > 0.22) {
        final flareRadius = coreRadius * 0.85;
        _corePaint.color = Colors.white.withValues(alpha: glowOpacity * 0.28);
        canvas.drawCircle(Offset(px, py), flareRadius, _corePaint);
      }
    }
  }

  void _ensureShader(Size size) {
    if (_shader != null && _shaderSize == size) return;
    _shaderSize = size;

    _shader = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      [colors.top, Color.lerp(colors.top, colors.bottom, 0.4)!, colors.bottom],
      [0.0, 0.55, 1.0],
    );
  }

  void _paintNeonVignette(Canvas canvas, Size size) {
    final minSide = min(size.width, size.height);
    final center = Offset(size.width * 0.72, size.height * 0.28);

    _ringPaint
      ..strokeWidth = minSide * 0.0032
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, minSide * 0.02);

    _ringPaint.color = colors.neonBlue.withValues(alpha: 0.08);
    canvas.drawCircle(center, minSide * 0.42, _ringPaint);

    _ringPaint.color = colors.neonPurple.withValues(alpha: 0.06);
    canvas.drawCircle(center, minSide * 0.29, _ringPaint);

    if (_vignetteShader == null || _vignetteShaderSize != size) {
      _vignetteShaderSize = size;
      _vignetteShader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.55),
        minSide * 0.85,
        [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.55),
        ],
        [0.0, 0.72, 1.0],
      );
    }

    _vignettePaint.shader = _vignetteShader;
    canvas.drawRect(Offset.zero & size, _vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _ControlixBackgroundPainter oldDelegate) {
    return oldDelegate.particles != particles ||
        oldDelegate.speed != speed ||
        oldDelegate.blurSigma != blurSigma ||
        oldDelegate.colors != colors ||
        oldDelegate.enableParticles != enableParticles;
  }
}
