import 'package:flutter/material.dart';

import '../../core/constants/task_visuals.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/remote_task.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.initialTask});

  final RemoteTask? initialTask;

  static Future<RemoteTask?> show(BuildContext context, {RemoteTask? task}) {
    return showModalBottomSheet<RemoteTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditorSheet(initialTask: task),
    );
  }

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _scriptController;

  late String _selectedIcon;
  late String _selectedAccent;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialTask?.description ?? '',
    );
    _scriptController = TextEditingController(
      text: widget.initialTask?.script ?? '',
    );
    _selectedIcon =
        widget.initialTask?.iconName ?? TaskVisuals.iconMap.keys.first;
    _selectedAccent =
        widget.initialTask?.accentHex ?? TaskVisuals.accentPalette.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scriptController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      RemoteTask(
        id: widget.initialTask?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        script: _scriptController.text.trim(),
        accentHex: _selectedAccent,
        iconName: _selectedIcon,
        createdAt: widget.initialTask?.createdAt,
        updatedAt: widget.initialTask?.updatedAt,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final accentColor = colorFromHex(_selectedAccent);

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 18, 14, 14 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.94),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? const [
                      Color(0xFF0E1521),
                      Color(0xFF131E2D),
                      Color(0xFF1A2838),
                    ]
                  : const [
                      Color(0xFFFFFBF5),
                      Color(0xFFF2E8DB),
                      Color(0xFFEDE3D5),
                    ],
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.44),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 34,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -46,
                right: -14,
                child: _SheetGlow(
                  size: 180,
                  color: accentColor.withValues(alpha: 0.16),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.initialTask == null
                                            ? 'Nouvelle tâche'
                                            : 'Modifier la tâche',
                                        style: theme.textTheme.displaySmall,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Le backend reste inchangé: tu modifies uniquement la présentation de la tâche et le script transmis à l’agent.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.66),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton.filledTonal(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _titleController,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  Validators.validateRequired(value, 'Title'),
                              decoration: _decoration(
                                label: 'Titre',
                                hint: 'Restart Explorer',
                                prefixIcon: const Icon(Icons.title_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              textInputAction: TextInputAction.next,
                              maxLines: 2,
                              decoration: _decoration(
                                label: 'Description',
                                hint: 'Décrit brièvement le comportement',
                                prefixIcon: const Icon(Icons.notes_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('Icône', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedIcon,
                              isExpanded: true,
                              dropdownColor: theme.colorScheme.surface,
                              items: TaskVisuals.iconMap.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Row(
                                    children: [
                                      Icon(entry.value, size: 18),
                                      const SizedBox(width: 12),
                                      Text(entry.key),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedIcon = value);
                                }
                              },
                              decoration: _decoration(
                                label: 'Icône de la tâche',
                                prefixIcon: const Icon(Icons.apps_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Couleur d’accent',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: TaskVisuals.accentPalette.map((accent) {
                                final isSelected = accent == _selectedAccent;
                                return _AccentSwatch(
                                  color: colorFromHex(accent),
                                  isSelected: isSelected,
                                  onTap: () =>
                                      setState(() => _selectedAccent = accent),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: theme.brightness == Brightness.dark
                                      ? 0.18
                                      : 0.05,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.38,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Script PowerShell',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(color: accentColor),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${_scriptController.text.trim().length} caractères',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.52),
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _scriptController,
                                    minLines: 8,
                                    maxLines: 12,
                                    onChanged: (_) => setState(() {}),
                                    validator: (value) =>
                                        Validators.validateRequired(
                                          value,
                                          'PowerShell script',
                                        ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'monospace',
                                      height: 1.55,
                                    ),
                                    decoration: _decoration(
                                      label: 'Script',
                                      hint:
                                          'Stop-Process -Name explorer -Force; Start-Process explorer.exe',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 340;

                        if (stacked) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Annuler'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _submit,
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text('Enregistrer'),
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.save_rounded),
                                label: const Text('Enregistrer'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.96),
              Color.lerp(color, Colors.white, 0.16) ?? color,
            ],
          ),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.38),
            width: isSelected ? 3 : 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: isSelected ? 22 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetGlow extends StatelessWidget {
  const _SheetGlow({required this.size, required this.color});

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
