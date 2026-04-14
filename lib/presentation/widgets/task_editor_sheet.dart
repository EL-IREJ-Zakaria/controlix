import 'package:flutter/material.dart';

import '../../core/constants/task_visuals.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/glass_panel.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: GlassPanel(
        borderRadius: 32,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initialTask == null
                            ? 'Create task'
                            : 'Edit task',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Each task stores its PowerShell script on the Windows agent and can be executed with one tap.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Title'),
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Restart Explorer',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What this automation does',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedIcon,
                  decoration: const InputDecoration(labelText: 'Task icon'),
                  items: TaskVisuals.iconMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(entry.value, size: 18),
                          const SizedBox(width: 10),
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
                ),
                const SizedBox(height: 18),
                Text('Accent color', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: TaskVisuals.accentPalette.map((accent) {
                    final isSelected = accent == _selectedAccent;
                    final color = colorFromHex(accent);
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => _selectedAccent = accent),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _scriptController,
                  minLines: 6,
                  maxLines: 10,
                  validator: (value) =>
                      Validators.validateRequired(value, 'PowerShell script'),
                  decoration: const InputDecoration(
                    labelText: 'PowerShell script',
                    hintText:
                        r'Stop-Process -Name explorer -Force; Start-Process explorer.exe',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
