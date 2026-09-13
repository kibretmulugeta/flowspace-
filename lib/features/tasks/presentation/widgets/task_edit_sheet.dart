import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/presentation/category_provider.dart';
import '../../../categories/presentation/widgets/category_edit_sheet.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../../projects/presentation/widgets/project_edit_sheet.dart';
import '../../domain/task_model.dart';
import '../task_provider.dart';

class TaskEditSheet extends ConsumerStatefulWidget {
  final Task? existingTask;

  const TaskEditSheet({super.key, this.existingTask});

  static Future<void> show(BuildContext context, {Task? existingTask}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditSheet(existingTask: existingTask),
    );
  }

  @override
  ConsumerState<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends ConsumerState<TaskEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _subtaskInputController;
  DateTime? _dueDate;
  String? _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  String? _projectId;
  String? _categoryId;
  List<String> _subtasks = [];
  List<bool> _subtasksCompleted = [];
  List<String> _tags = [];
  int _estimatedDuration = 30;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _subtaskInputController = TextEditingController();

    if (t != null) {
      _dueDate = t.dueDate;
      _dueTime = t.dueTime;
      _priority = t.priority;
      _status = t.status;
      _projectId = t.projectId;
      _categoryId = t.categoryId;
      _subtasks = List.from(t.subtasks);
      _subtasksCompleted = List.from(t.subtasksCompleted);
      _tags = List.from(t.tags);
      _estimatedDuration = t.estimatedDurationMinutes;
    } else {
      _dueDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final taskNotifier = ref.read(taskProvider.notifier);

    if (widget.existingTask != null) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        dueTime: _dueTime,
        priority: _priority,
        status: _status,
        projectId: _projectId,
        categoryId: _categoryId,
        subtasks: _subtasks,
        subtasksCompleted: _subtasksCompleted,
        tags: _tags,
        estimatedDurationMinutes: _estimatedDuration,
        isCompleted: _status == TaskStatus.completed,
      );
      await taskNotifier.updateTask(updated);
    } else {
      await taskNotifier.addTask(
        title: title,
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        dueTime: _dueTime,
        priority: _priority,
        status: _status,
        projectId: _projectId,
        categoryId: _categoryId,
        subtasks: _subtasks,
        tags: _tags,
        estimatedMinutes: _estimatedDuration,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _pickDueTime() async {
    TimeOfDay initial = TimeOfDay.now();
    if (_dueTime != null) {
      final parts = _dueTime!.split(':');
      if (parts.length == 2) {
        initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? initial.hour,
          minute: int.tryParse(parts[1]) ?? initial.minute,
        );
      }
    }
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (time != null) {
      setState(() {
        _dueTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(text);
      _subtasksCompleted.add(false);
      _subtaskInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = ref.watch(projectProvider).projects;
    final categories = ref.watch(categoryProvider).categories;
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 24,
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
            // Handle Bar
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

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingTask != null ? 'Edit Task' : 'New Task',
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                FilledButton(
                  onPressed: _onSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title Field
            TextField(
              controller: _titleController,
              autofocus: widget.existingTask == null,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Task title...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 10),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              minLines: 1,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Add description, context, or links...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(height: 28),

            // Quick Pickers Row: Date, Time, Priority
            Row(
              children: [
                // Due Date button
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _dueDate != null ? DateFormatter.formatShort(_dueDate!) : 'No Date',
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Due Time button
                InkWell(
                  onTap: _pickDueTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _dueTime ?? 'Time',
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Priority dropdown
                PopupMenuButton<TaskPriority>(
                  initialValue: _priority,
                  onSelected: (p) => setState(() => _priority = p),
                  itemBuilder: (context) => TaskPriority.values.map((p) {
                    return PopupMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 16, color: p.color),
                          const SizedBox(width: 8),
                          Text(p.label, style: AppTypography.labelSmall),
                        ],
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _priority.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _priority.color.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, size: 14, color: _priority.color),
                        const SizedBox(width: 4),
                        Text(
                          _priority.label,
                          style: AppTypography.labelSmall.copyWith(color: _priority.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Project & Category Pickers
            Row(
              children: [
                // Project Selector
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('proj_$_projectId'),
                    initialValue: projects.any((p) => p.id == _projectId) ? _projectId : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Project',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        tooltip: 'New Project',
                        onPressed: () async {
                          final newProj = await ProjectEditSheet.show(context);
                          if (newProj != null) {
                            setState(() => _projectId = newProj.id);
                          }
                        },
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final proj in projects)
                        DropdownMenuItem(
                          value: proj.id,
                          child: Text('${proj.icon} ${proj.name}', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (val) => setState(() => _projectId = val),
                  ),
                ),
                const SizedBox(width: 12),

                // Category Selector
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('cat_$_categoryId'),
                    initialValue: categories.any((c) => c.id == _categoryId) ? _categoryId : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        tooltip: 'New Category',
                        onPressed: () async {
                          final newCat = await CategoryEditSheet.show(context);
                          if (newCat != null) {
                            setState(() => _categoryId = newCat.id);
                          }
                        },
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final cat in categories)
                        DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (val) => setState(() => _categoryId = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subtasks Section
            Text('Subtasks & Checklist', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            for (int i = 0; i < _subtasks.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _subtasksCompleted[i] = !_subtasksCompleted[i];
                        });
                      },
                      child: Icon(
                        _subtasksCompleted[i] ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _subtasks[i],
                        style: AppTypography.bodySmall.copyWith(
                          decoration: _subtasksCompleted[i] ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _subtasks.removeAt(i);
                          _subtasksCompleted.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Add Subtask input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskInputController,
                    onSubmitted: (_) => _addSubtask(),
                    style: AppTypography.bodySmall,
                    decoration: const InputDecoration(
                      hintText: 'Add a subtask...',
                      prefixIcon: Icon(Icons.add, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.arrow_forward, size: 18),
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
