import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../projects/presentation/project_provider.dart';
import '../../domain/calendar_event_model.dart';
import '../calendar_provider.dart';

class EventEditSheet extends ConsumerStatefulWidget {
  final CalendarEvent? existingEvent;
  final DateTime? defaultDate;

  const EventEditSheet({super.key, this.existingEvent, this.defaultDate});

  static Future<void> show(BuildContext context, {CalendarEvent? existingEvent, DateTime? defaultDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventEditSheet(existingEvent: existingEvent, defaultDate: defaultDate),
    );
  }

  @override
  ConsumerState<EventEditSheet> createState() => _EventEditSheetState();
}

class _EventEditSheetState extends ConsumerState<EventEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  Color _selectedColor = AppColors.accentIndigo;
  String _calendarId = 'cal-work';
  String? _projectId;
  String _recurrence = 'none';
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    final ev = widget.existingEvent;
    _titleController = TextEditingController(text: ev?.title ?? '');
    _descriptionController = TextEditingController(text: ev?.description ?? '');
    _locationController = TextEditingController(text: ev?.location ?? '');

    if (ev != null) {
      _startDate = ev.startDateTime;
      _startTime = TimeOfDay.fromDateTime(ev.startDateTime);
      _endDate = ev.endDateTime;
      _endTime = TimeOfDay.fromDateTime(ev.endDateTime);
      _selectedColor = ev.color;
      _calendarId = ev.calendarId;
      _projectId = ev.projectId;
      _recurrence = ev.recurrence ?? 'none';
      _isAllDay = ev.isAllDay;
    } else {
      final base = widget.defaultDate ?? DateTime.now();
      _startDate = DateTime(base.year, base.month, base.day);
      _startTime = const TimeOfDay(hour: 10, minute: 0);
      _endDate = DateTime(base.year, base.month, base.day);
      _endTime = const TimeOfDay(hour: 11, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final start = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final calNotifier = ref.read(calendarProvider.notifier);

    if (widget.existingEvent != null) {
      final updated = widget.existingEvent!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        startDateTime: start,
        endDateTime: end,
        colorValue: _selectedColor.toARGB32(),
        calendarId: _calendarId,
        projectId: _projectId,
        recurrence: _recurrence,
        isAllDay: _isAllDay,
      );
      await calNotifier.updateEvent(updated);
    } else {
      await calNotifier.addEvent(
        title: title,
        description: _descriptionController.text.trim(),
        startDateTime: start,
        endDateTime: end,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        color: _selectedColor,
        calendarId: _calendarId,
        projectId: _projectId,
        recurrence: _recurrence,
        isAllDay: _isAllDay,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendars = ref.watch(calendarProvider).calendars;
    final projects = ref.watch(projectProvider).projects;

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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingEvent != null ? 'Edit Event' : 'New Event',
                  style: AppTypography.titleLarge,
                ),
                Row(
                  children: [
                    if (widget.existingEvent != null) ...[
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Duplicate event',
                        onPressed: () async {
                          await ref
                              .read(calendarProvider.notifier)
                              .duplicateEvent(widget.existingEvent!.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.priorityUrgent),
                        tooltip: 'Delete event',
                        onPressed: () async {
                          await ref
                              .read(calendarProvider.notifier)
                              .deleteEvent(widget.existingEvent!.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                    const SizedBox(width: 4),
                    FilledButton(
                      onPressed: _onSave,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              autofocus: widget.existingEvent == null,
              style: AppTypography.headlineMedium,
              decoration: const InputDecoration(
                hintText: 'Event title...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),

            // All Day switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Day', style: AppTypography.labelLarge),
                Switch(
                  value: _isAllDay,
                  onChanged: (val) => setState(() => _isAllDay = val),
                ),
              ],
            ),
            const Divider(height: 20),

            // Start Date & Time
            Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Text(DateFormatter.formatShort(_startDate), style: AppTypography.bodyMedium),
                  ),
                ),
                if (!_isAllDay)
                  InkWell(
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _startTime);
                      if (t != null) setState(() => _startTime = t);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_startTime.format(context), style: AppTypography.labelSmall),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // End Date & Time
            Row(
              children: [
                const SizedBox(width: 32),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                    child: Text(DateFormatter.formatShort(_endDate), style: AppTypography.bodyMedium),
                  ),
                ),
                if (!_isAllDay)
                  InkWell(
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: _endTime);
                      if (t != null) setState(() => _endTime = t);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_endTime.format(context), style: AppTypography.labelSmall),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),

            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                hintText: 'Add location or conference link',
              ),
            ),
            const SizedBox(height: 12),

            // Color Palette Selector
            Text('Color Marker', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: AppColors.categoryPalette.take(6).map((color) {
                final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Calendar & Project Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _calendarId,
                    decoration: const InputDecoration(labelText: 'Calendar'),
                    items: calendars.map((cal) {
                      return DropdownMenuItem(value: cal.id, child: Text(cal.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _calendarId = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _projectId,
                    decoration: const InputDecoration(labelText: 'Project'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final p in projects)
                        DropdownMenuItem(value: p.id, child: Text('${p.icon} ${p.name}')),
                    ],
                    onChanged: (val) => setState(() => _projectId = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description / Notes
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add notes, agenda items, or participants...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
