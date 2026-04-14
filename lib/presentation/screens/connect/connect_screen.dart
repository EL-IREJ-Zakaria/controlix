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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verifyConnection
                  ? 'Connection saved and agent verified.'
                  : 'Connection settings saved locally.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -40,
              child: _GlowOrb(
                size: 260,
                color: theme.colorScheme.primary.withValues(alpha: 0.20),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -20,
              child: _GlowOrb(
                size: 300,
                color: theme.colorScheme.secondary.withValues(alpha: 0.18),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Connect your Windows agent',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Point the mobile app to your Windows machine over LAN, save the shared secret locally, and start dispatching PowerShell automations.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassPanel(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Agent endpoint',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  endpointPreview,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _ipController,
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.next,
                                  validator: Validators.validateIpAddress,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Windows machine IP',
                                    hintText: '192.168.1.24',
                                    prefixIcon: Icon(Icons.lan_rounded),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _secretController,
                                  obscureText: true,
                                  validator: Validators.validateSecretKey,
                                  decoration: const InputDecoration(
                                    labelText: 'Shared secret key',
                                    hintText:
                                        'Enter the same key configured on the agent',
                                    prefixIcon: Icon(Icons.key_rounded),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const _FeatureHint(
                                  icon: Icons.verified_user_rounded,
                                  text:
                                      'The secret is stored locally with SharedPreferences.',
                                ),
                                const SizedBox(height: 10),
                                const _FeatureHint(
                                  icon: Icons.shield_moon_rounded,
                                  text:
                                      'The backend rejects non-LAN requests before authentication.',
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: _isSubmitting
                                            ? null
                                            : () =>
                                                  _save(verifyConnection: true),
                                        icon: _isSubmitting
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.wifi_find_rounded,
                                              ),
                                        label: const Text('Save & connect'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _save(verifyConnection: false),
                                    icon: const Icon(Icons.save_outlined),
                                    label: const Text('Save locally only'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _FeatureHint extends StatelessWidget {
  const _FeatureHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
