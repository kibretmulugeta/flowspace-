import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/project_model.dart';
import '../project_provider.dart';

class ProjectEditSheet extends ConsumerStatefulWidget {
  final Project? existingProject;

  const ProjectEditSheet({super.key, this.existingProject});

  static Future<void> show(BuildContext context, {Project? existingProject}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProjectEditSheet(existingProject: existingProject),
    );
  }

  @override
  ConsumerState<ProjectEditSheet> createState() => _ProjectEditSheetState();
}

class _ProjectEditSheetState extends ConsumerState<ProjectEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String _icon = '🚀';
  Color _color = AppColors.accentIndigo;
  ProjectStatus _status = ProjectStatus.active;
  DateTime? _startDate;
  DateTime? _dueDate;

  final List<String> _icons = ['🚀', '🔬', '⚡', '💻', '📁', '💡', '🌐', '📚', '🎯', '🎨'];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProject;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');

    if (p != null) {
      _icon = p.icon;
      _color = p.color;
      _status = p.status;
      _startDate = p.startDate;
      _dueDate = p.dueDate;
    } else {
      _startDate = DateTime.now();
      _dueDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final projNotifier = ref.read(projectProvider.notifier);

    if (widget.existingProject != null) {
      final updated = widget.existingProject!.copyWith(
        name: name,
        description: _descriptionController.text.trim(),
        icon: _icon,
        colorValue: _color.toARGB32(),
        status: _status,
        startDate: _startDate,
        dueDate: _dueDate,
      );
      await projNotifier.updateProject(updated);
    } else {
      await projNotifier.createProject(
        name: name,
        description: _descriptionController.text.trim(),
        icon: _icon,
        color: _color,
        status: _status,
        startDate: _startDate,
        dueDate: _dueDate,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingProject != null ? 'Edit Project' : 'New Project',
                  style: AppTypography.titleLarge,
                ),
                FilledButton(
                  onPressed: _onSave,
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Icon Picker
            Text('Project Icon', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _icons.map((ic) {
                  final isSel = ic == _icon;
                  return GestureDetector(
                    onTap: () => setState(() => _icon = ic),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSel
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(10),
                        border: isSel
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Text(ic, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description / Purpose'),
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            DropdownButtonFormField<ProjectStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ProjectStatus.values.map((st) {
                return DropdownMenuItem(
                  value: st,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: st.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(st.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 16),

            // Due Date
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Target Due Date'),
                      child: Text(
                        _dueDate != null ? DateFormatter.formatShort(_dueDate!) : 'No Due Date',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Selector
            Text('Accent Color', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: AppColors.categoryPalette.take(6).map((c) {
                final isSel = _color.toARGB32() == c.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
