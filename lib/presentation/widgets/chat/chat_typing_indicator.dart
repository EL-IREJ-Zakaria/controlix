import 'package:flutter/material.dart';

class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.82 : 0.86,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(22),
          ),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.38),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(value: t, offset: 0.0),
                const SizedBox(width: 6),
                _Dot(value: t, offset: 0.2),
                const SizedBox(width: 6),
                _Dot(value: t, offset: 0.4),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.value, required this.offset});

  final double value;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = (value + offset) % 1.0;
    final scale = 0.65 + 0.55 * Curves.easeInOut.transform(_wave(phase));
    final opacity = 0.30 + 0.60 * Curves.easeInOut.transform(_wave(phase));

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  double _wave(double t) {
    if (t < 0.5) {
      return t * 2;
    }
    return (1 - t) * 2;
  }
}
