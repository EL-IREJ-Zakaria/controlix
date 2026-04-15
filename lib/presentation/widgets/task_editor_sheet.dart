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

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0x9ECFD3E6),
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFF3A3D4E).withValues(alpha: 0.82),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorFromHex(_selectedAccent).withValues(alpha: 0.72),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final accentColor = colorFromHex(_selectedAccent);

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 16, 14, 14 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.96),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF2B2F3D),
                Color(0xFF242837),
                Color(0xFF1C202D),
              ],
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 34,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -48,
                right: -26,
                child: _GlowOrb(
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                bottom: 120,
                right: 18,
                child: _GlowOrb(
                  size: 140,
                  color: accentColor.withValues(alpha: 0.16),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Theme(
                      data: theme.copyWith(
                        inputDecorationTheme: theme.inputDecorationTheme,
                        dividerColor: Colors.transparent,
                      ),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -1.2,
                                          ),
                                    ),
                                  ),
                                  _TopIconButton(
                                    icon: Icons.close_rounded,
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Each task stores its PowerShell script on the Windows agent and can be executed with one tap.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xB8D2D7E6),
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              TextFormField(
                                controller: _titleController,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                                validator: (value) =>
                                    Validators.validateRequired(value, 'Title'),
                                decoration: _inputDecoration(
                                  hintText: 'Task title',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _descriptionController,
                                textInputAction: TextInputAction.next,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Description',
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _SectionLabel('Task icon'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedIcon,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF2E3242),
                                iconEnabledColor: const Color(0xFFD5DBEE),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Task icon',
                                ),
                                items: TaskVisuals.iconMap.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Row(
                                      children: [
                                        Icon(
                                          entry.value,
                                          size: 18,
                                          color: Colors.white,
                                        ),
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
                              ),
                              const SizedBox(height: 18),
                              const _SectionLabel('Accent color'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: TaskVisuals.accentPalette.map((
                                  accent,
                                ) {
                                  final isSelected = accent == _selectedAccent;
                                  final color = colorFromHex(accent);
                                  return _AccentSwatch(
                                    color: color,
                                    isSelected: isSelected,
                                    onTap: () => setState(
                                      () => _selectedAccent = accent,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF343844,
                                  ).withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.04),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _scriptController,
                                  minLines: 7,
                                  maxLines: 11,
                                  validator: (value) =>
                                      Validators.validateRequired(
                                        value,
                                        'PowerShell script',
                                      ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                  decoration:
                                      _inputDecoration(
                                        hintText: 'PowerShell script',
                                      ).copyWith(
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                              22,
                                              26,
                                              22,
                                              26,
                                            ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final useColumn = constraints.maxWidth < 310;
                        final buttons = <Widget>[
                          Expanded(
                            child: _SheetActionButton(
                              label: 'Cancel',
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Expanded(
                            child: _SheetActionButton(
                              label: 'Save task',
                              icon: Icons.save_rounded,
                              accentColor: accentColor,
                              isPrimary: true,
                              onTap: _submit,
                            ),
                          ),
                        ];

                        if (useColumn) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: _SheetActionButton(
                                  label: 'Cancel',
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: _SheetActionButton(
                                  label: 'Save task',
                                  icon: Icons.save_rounded,
                                  accentColor: accentColor,
                                  isPrimary: true,
                                  onTap: _submit,
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            buttons.first,
                            const SizedBox(width: 12),
                            buttons.last,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: const Color(0xFFD9DDED),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Icon(icon, color: const Color(0xFFD3D8E8)),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              color.withValues(alpha: 0.92),
              Color.lerp(color, Colors.white, 0.12) ?? color,
            ],
          ),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 3 : 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.34),
              blurRadius: isSelected ? 22 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.accentColor,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final baseColor = accentColor ?? const Color(0xFF43485A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.lerp(baseColor, Colors.white, 0.08) ?? baseColor,
                      baseColor,
                    ],
                  )
                : null,
            color: isPrimary ? null : const Color(0xFF3A3F50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.05),
            ),
            boxShadow: isPrimary
                ? <BoxShadow>[
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
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
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
