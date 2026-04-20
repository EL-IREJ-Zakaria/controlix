import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../domain/entities/connection_config.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/task_controller.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _secretController = TextEditingController();

  bool _seededControllers = false;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededControllers) {
      return;
    }

    final config = context.read<AppController>().connectionConfig;
    if (config != null) {
      _ipController.text = config.ipAddress;
      _secretController.text = config.secretKey;
    }
    _seededControllers = true;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _save({required bool verifyConnection}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appController = context.read<AppController>();
    final taskController = context.read<TaskController>();
    final config = ConnectionConfig(
      ipAddress: _ipController.text.trim(),
      secretKey: _secretController.text.trim(),
    );

    setState(() => _isSubmitting = true);

    try {
      if (verifyConnection) {
        await taskController.verifyConnection(config);
      }

      await appController.saveConnectionConfig(config);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verifyConnection
                ? 'Connexion vérifiée et enregistrée.'
                : 'Paramètres enregistrés localement.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = AppTheme.pageGradient(theme.brightness);
    final endpointPreview =
        'http://${_ipController.text.trim().isEmpty ? '192.168.1.24' : _ipController.text.trim()}:${AppConstants.agentPort}';

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
            const Positioned.fill(
              child: IgnorePointer(child: _ConnectionGrid()),
            ),
            Positioned(
              top: -80,
              left: -20,
              child: _AmbientGlow(
                size: 240,
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              right: -60,
              bottom: -120,
              child: _AmbientGlow(
                size: 320,
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 980;
                  final horizontalPadding = isWide ? 28.0 : 18.0;

                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        28,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _IntroPanel(
                                      endpointPreview: endpointPreview,
                                    ),
                                  ),
                                  const SizedBox(width: 22),
                                  SizedBox(
                                    width: 440,
                                    child: _FormPanel(
                                      formKey: _formKey,
                                      ipController: _ipController,
                                      secretController: _secretController,
                                      endpointPreview: endpointPreview,
                                      isSubmitting: _isSubmitting,
                                      onChanged: () => setState(() {}),
                                      onSave: _save,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _IntroPanel(
                                    endpointPreview: endpointPreview,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 18),
                                  _FormPanel(
                                    formKey: _formKey,
                                    ipController: _ipController,
                                    secretController: _secretController,
                                    endpointPreview: endpointPreview,
                                    isSubmitting: _isSubmitting,
                                    onChanged: () => setState(() {}),
                                    onSave: _save,
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
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.endpointPreview, this.compact = false});

  final String endpointPreview;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = theme.colorScheme.primary;

    return GlassPanel(
      padding: EdgeInsets.all(compact ? 22 : 28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.brightness == Brightness.dark
              ? const Color(0xFF101826).withValues(alpha: 0.90)
              : const Color(0xFFFBF7F0).withValues(alpha: 0.92),
          theme.brightness == Brightness.dark
              ? const Color(0xFF172232).withValues(alpha: 0.84)
              : const Color(0xFFF0E6D8).withValues(alpha: 0.84),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: highlight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: highlight.withValues(alpha: 0.20)),
            ),
            child: Text(
              'LOCAL CONTROL LINK',
              style: theme.textTheme.labelLarge?.copyWith(
                color: highlight,
                letterSpacing: 0.7,
              ),
            ),
          ),
          SizedBox(height: compact ? 20 : 26),
          Text(
            'Connecter le mobile\nau poste Windows',
            style: compact
                ? theme.textTheme.displaySmall
                : theme.textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'L’application mobile parle uniquement au service Windows sur le LAN. Configure l’IP locale, enregistre la clé partagée, puis pilote tes automatisations sans changer la couche backend.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ),
          SizedBox(height: compact ? 22 : 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _SignalChip(
                icon: Icons.lan_rounded,
                label: 'LAN only',
                value: 'Privé',
              ),
              _SignalChip(
                icon: Icons.key_rounded,
                label: 'Secret',
                value: 'Persisté localement',
              ),
              _SignalChip(
                icon: Icons.flash_on_rounded,
                label: 'Dispatch',
                value: 'PowerShell distant',
              ),
            ],
          ),
          SizedBox(height: compact ? 22 : 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.18 : 0.05,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.42),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route actuelle',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  endpointPreview,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Après validation, le dashboard synchronisera les tâches exposées par l’agent Windows et gardera un historique local sur cet appareil.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
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

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.formKey,
    required this.ipController,
    required this.secretController,
    required this.endpointPreview,
    required this.isSubmitting,
    required this.onChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController ipController;
  final TextEditingController secretController;
  final String endpointPreview;
  final bool isSubmitting;
  final VoidCallback onChanged;
  final Future<void> Function({required bool verifyConnection}) onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session endpoint', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Renseigne l’IP du PC et la clé secrète déjà configurée sur l’agent.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                endpointPreview,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: ipController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              validator: Validators.validateIpAddress,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                labelText: 'IP du poste Windows',
                hintText: '192.168.1.24',
                prefixIcon: Icon(Icons.router_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: secretController,
              obscureText: true,
              validator: Validators.validateSecretKey,
              decoration: const InputDecoration(
                labelText: 'Clé secrète partagée',
                hintText: 'Même valeur que sur l’agent',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const _InlineNote(
              icon: Icons.shield_outlined,
              text:
                  'Le backend refuse les requêtes hors réseau local avant même l’authentification.',
            ),
            const SizedBox(height: 10),
            const _InlineNote(
              icon: Icons.storage_rounded,
              text:
                  'La configuration de connexion est stockée localement sur le mobile.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () => onSave(verifyConnection: true),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.wifi_tethering_rounded),
                label: const Text('Sauvegarder et tester'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () => onSave(verifyConnection: false),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Sauvegarder sans test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.16 : 0.04,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConnectionGrid extends StatelessWidget {
  const _ConnectionGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _ConnectionGridPainter(
        lineColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        accentColor: theme.colorScheme.secondary.withValues(alpha: 0.10),
      ),
    );
  }
}

class _ConnectionGridPainter extends CustomPainter {
  const _ConnectionGridPainter({
    required this.lineColor,
    required this.accentColor,
  });

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final accentPaint = Paint()..color = accentColor;
    final nodes = [
      Offset(size.width * 0.12, size.height * 0.16),
      Offset(size.width * 0.82, size.height * 0.22),
      Offset(size.width * 0.26, size.height * 0.72),
      Offset(size.width * 0.74, size.height * 0.78),
    ];
    for (final node in nodes) {
      canvas.drawCircle(node, 4, accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

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
