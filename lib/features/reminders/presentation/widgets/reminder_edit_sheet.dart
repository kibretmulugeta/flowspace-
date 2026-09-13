import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/reminder_model.dart';
import '../reminder_provider.dart';

class ReminderEditSheet extends ConsumerStatefulWidget {
  final Reminder? existingReminder;

  const ReminderEditSheet({super.key, this.existingReminder});

  static Future<void> show(BuildContext context, {Reminder? existingReminder}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReminderEditSheet(existingReminder: existingReminder),
    );
  }

  @override
  ConsumerState<ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends ConsumerState<ReminderEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _scheduledDate;
  late TimeOfDay _scheduledTime;
  ReminderTargetType _targetType = ReminderTargetType.standalone;
  ReminderRecurrence _recurrence = ReminderRecurrence.none;
  String? _titleError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReminder;
    _titleController = TextEditingController(text: r?.title ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');

    if (r != null) {
      _scheduledDate = r.scheduledAt;
      _scheduledTime = TimeOfDay.fromDateTime(r.scheduledAt);
      _targetType = r.targetType;
      _recurrence = r.recurrence;
    } else {
      _scheduledDate = DateTime.now();
      _scheduledTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Please enter a reminder title';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reminder title'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final scheduledAt = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      final remNotifier = ref.read(reminderProvider.notifier);

      if (widget.existingReminder != null) {
        final updated = widget.existingReminder!.copyWith(
          title: title,
          description: _descriptionController.text.trim(),
          scheduledAt: scheduledAt,
          targetType: _targetType,
          recurrence: _recurrence,
        );
        await remNotifier.updateReminder(updated);
      } else {
        await remNotifier.addReminder(
          title: title,
          description: _descriptionController.text.trim(),
          scheduledAt: scheduledAt,
          targetType: _targetType,
          recurrence: _recurrence,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingReminder != null ? 'Reminder updated' : 'Reminder saved'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reminder: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    widget.existingReminder != null ? 'Edit Reminder' : 'New Reminder',
                    style: AppTypography.titleLarge,
                  ),
                  FilledButton(
                    onPressed: _isSaving ? null : _onSave,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                autofocus: widget.existingReminder == null,
                onChanged: (_) {
                  if (_titleError != null) {
                    setState(() => _titleError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  errorText: _titleError,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 16),

              // Date & Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate,
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
                        if (picked != null) setState(() => _scheduledDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(DateFormatter.formatShort(_scheduledDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _scheduledTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              child: child ?? const SizedBox(),
                            );
                          },
                        );
                        if (picked != null) setState(() => _scheduledTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(_scheduledTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recurrence dropdown
              DropdownButtonFormField<ReminderRecurrence>(
                initialValue: _recurrence,
                decoration: const InputDecoration(labelText: 'Recurrence'),
                items: ReminderRecurrence.values.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r.label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _recurrence = val);
                },
              ),
              const SizedBox(height: 24),

              // Full-width bottom action button for easy one-tap saving on mobile
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.existingReminder != null ? 'Save Changes' : 'Create Reminder',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
