import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 30,
    this.gradient,
    this.blurSigma = 14,
    this.enableBlur = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final double blurSigma;
  final bool enableBlur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final panelGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            isDark
                ? const Color(0xFF121B29).withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.84),
            isDark
                ? const Color(0xFF0F1724).withValues(alpha: 0.76)
                : const Color(0xFFF7F1E8).withValues(alpha: 0.78),
          ],
        );

    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: panelGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.colorScheme.outline.withValues(alpha: 0.54),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.09),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - 2),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.44),
            ),
          ),
        ),
        child: child,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: enableBlur && blurSigma > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: panel,
            )
          : panel,
    );
  }
}
