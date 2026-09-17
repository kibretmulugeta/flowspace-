import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/schedule_model.dart';
import '../schedule_provider.dart';

class AddScheduleSheet extends ConsumerStatefulWidget {
  final ScheduleModel? existingSchedule;

  const AddScheduleSheet({super.key, this.existingSchedule});

  @override
  ConsumerState<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends ConsumerState<AddScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late ScheduleMode _selectedMode;

  // Delay Mode
  String _delayOffset = '2 hours';

  // Bounded Mode
  DateTime? _windowStart;
  DateTime? _windowEnd;

  // Recurrent Mode
  String _rrule = 'FREQ=DAILY;INTERVAL=1';

  // Prerequisite Mode
  String? _selectedPrereqId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existingSchedule;
    _titleController = TextEditingController(text: s?.title ?? '');
    _descController = TextEditingController(text: s?.description ?? '');
    _selectedMode = s?.mode ?? ScheduleMode.delay;
    _delayOffset = s?.delayOffset ?? '2 hours';
    _windowStart = s?.windowStart ?? DateTime.now().add(const Duration(hours: 1));
    _windowEnd = s?.windowEnd ?? DateTime.now().add(const Duration(hours: 4));
    _rrule = s?.rrule ?? 'FREQ=DAILY;INTERVAL=1';
    _selectedPrereqId = s?.prerequisiteId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.existingSchedule != null) {
        final updated = widget.existingSchedule!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          mode: _selectedMode,
          delayOffset: _selectedMode == ScheduleMode.delay ? _delayOffset : null,
          windowStart: _selectedMode == ScheduleMode.bounded ? _windowStart : null,
          windowEnd: _selectedMode == ScheduleMode.bounded ? _windowEnd : null,
          rrule: _selectedMode == ScheduleMode.recurrent ? _rrule : null,
          prerequisiteId: _selectedMode == ScheduleMode.dependent ? _selectedPrereqId : null,
        );
        await ref.read(scheduleProvider.notifier).updateSchedule(updated);
      } else {
        await ref.read(scheduleProvider.notifier).createSchedule(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          mode: _selectedMode,
          delayOffset: _selectedMode == ScheduleMode.delay ? _delayOffset : null,
          windowStart: _selectedMode == ScheduleMode.bounded ? _windowStart : null,
          windowEnd: _selectedMode == ScheduleMode.bounded ? _windowEnd : null,
          rrule: _selectedMode == ScheduleMode.recurrent ? _rrule : null,
          prerequisiteId: _selectedMode == ScheduleMode.dependent ? _selectedPrereqId : null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingSchedule != null ? 'Schedule updated!' : 'Schedule created!'),
            backgroundColor: AppColors.accentIndigo,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allSchedules = ref.watch(scheduleProvider).schedules;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingSchedule != null ? 'Edit Schedule' : 'New Advanced Schedule',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g. Database Migration, Code Review',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF222631) : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),

              // Description input
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details or notes',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF222631) : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // 4-Mode Selector
              const Text('Scheduling Dimension', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ScheduleMode.values.map((mode) {
                  final isSelected = _selectedMode == mode;
                  return ChoiceChip(
                    avatar: Icon(mode.icon, size: 16, color: isSelected ? Colors.white : mode.color),
                    label: Text(mode.label),
                    selected: isSelected,
                    selectedColor: mode.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMode = mode);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Mode Specific Configuration
              _buildModeConfiguration(isDark, allSchedules),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMode.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.existingSchedule != null ? 'Save Changes' : 'Create Schedule', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeConfiguration(bool isDark, List<ScheduleModel> allSchedules) {
    switch (_selectedMode) {
      case ScheduleMode.delay:
        final options = ['30 minutes', '1 hour', '2 hours', '4 hours', '1 day', '3 days'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Relative Offset Delay', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: options.map((opt) {
                final isSelected = _delayOffset == opt;
                return ChoiceChip(
                  label: Text('+$opt'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFF59E0B),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                  ),
                  onSelected: (s) {
                    if (s) setState(() => _delayOffset = opt);
                  },
                );
              }).toList(),
            ),
          ],
        );

      case ScheduleMode.bounded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Execution Time Window', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.login_rounded, size: 16),
                    label: Text(_windowStart != null ? '${_windowStart!.month}/${_windowStart!.day} ${_windowStart!.hour}:${_windowStart!.minute.toString().padLeft(2, '0')}' : 'Start Time'),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _windowStart ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_windowStart ?? DateTime.now()),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _windowStart = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: Text(_windowEnd != null ? '${_windowEnd!.month}/${_windowEnd!.day} ${_windowEnd!.hour}:${_windowEnd!.minute.toString().padLeft(2, '0')}' : 'End Time'),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _windowEnd ?? DateTime.now().add(const Duration(hours: 4)),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null && mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_windowEnd ?? DateTime.now().add(const Duration(hours: 4))),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _windowEnd = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );

      case ScheduleMode.recurrent:
        final rules = [
          {'label': 'Every Day', 'rrule': 'FREQ=DAILY;INTERVAL=1'},
          {'label': 'Weekdays (Mon-Fri)', 'rrule': 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'},
          {'label': 'Weekly', 'rrule': 'FREQ=WEEKLY;INTERVAL=1'},
          {'label': 'Monthly', 'rrule': 'FREQ=MONTHLY;INTERVAL=1'},
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recurrence Rule (RFC 5545)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: rules.map((r) {
                final isSelected = _rrule == r['rrule'];
                return ChoiceChip(
                  label: Text(r['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                  ),
                  onSelected: (s) {
                    if (s) setState(() => _rrule = r['rrule']!);
                  },
                );
              }).toList(),
            ),
          ],
        );

      case ScheduleMode.dependent:
        final candidates = allSchedules.where((s) => s.id != widget.existingSchedule?.id).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prerequisite Schedule (Parent Task)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            if (candidates.isEmpty)
              const Text('No other schedules exist to set as prerequisite.', style: TextStyle(fontSize: 12, color: Colors.grey))
            else
              DropdownButtonFormField<String>(
                value: _selectedPrereqId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF222631) : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Select prerequisite schedule',
                ),
                items: candidates.map((s) {
                  return DropdownMenuItem<String>(
                    value: s.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.mode.icon, size: 14, color: s.mode.color),
                        const SizedBox(width: 8),
                        Text(s.title, overflow: TextOverflow.ellipsis),
                        const SizedBox(width: 6),
                        Text('(${s.status.label})', style: TextStyle(fontSize: 11, color: s.status.color)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPrereqId = val),
              ),
          ],
        );
    }
  }
}