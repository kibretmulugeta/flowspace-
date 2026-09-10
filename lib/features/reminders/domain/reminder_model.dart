enum ReminderTargetType {
  standalone,
  task,
  event,
  note;

  String get label {
    switch (this) {
      case ReminderTargetType.standalone:
        return 'Reminder';
      case ReminderTargetType.task:
        return 'Task';
      case ReminderTargetType.event:
        return 'Event';
      case ReminderTargetType.note:
        return 'Note';
    }
  }
}

enum ReminderRecurrence {
  none,
  daily,
  weekly,
  monthly,
  custom;

  String get label {
    switch (this) {
      case ReminderRecurrence.none:
        return 'Does not repeat';
      case ReminderRecurrence.daily:
        return 'Daily';
      case ReminderRecurrence.weekly:
        return 'Weekly';
      case ReminderRecurrence.monthly:
        return 'Monthly';
      case ReminderRecurrence.custom:
        return 'Custom';
    }
  }
}

/// Reminder entity
class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final ReminderTargetType targetType;
  final String? targetId;
  final ReminderRecurrence recurrence;
  final bool isCompleted;
  final bool isSnoozed;
  final DateTime? snoozeUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    this.description = '',
    required this.scheduledAt,
    this.targetType = ReminderTargetType.standalone,
    this.targetId,
    this.recurrence = ReminderRecurrence.none,
    this.isCompleted = false,
    this.isSnoozed = false,
    this.snoozeUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    ReminderTargetType? targetType,
    String? targetId,
    ReminderRecurrence? recurrence,
    bool? isCompleted,
    bool? isSnoozed,
    DateTime? snoozeUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      recurrence: recurrence ?? this.recurrence,
      isCompleted: isCompleted ?? this.isCompleted,
      isSnoozed: isSnoozed ?? this.isSnoozed,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt.toIso8601String(),
      'targetType': targetType.name,
      'targetId': targetId,
      'recurrence': recurrence.name,
      'isCompleted': isCompleted,
      'isSnoozed': isSnoozed,
      'snoozeUntil': snoozeUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      targetType: ReminderTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => ReminderTargetType.standalone,
      ),
      targetId: json['targetId'] as String?,
      recurrence: ReminderRecurrence.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => ReminderRecurrence.none,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isSnoozed: json['isSnoozed'] as bool? ?? false,
      snoozeUntil: json['snoozeUntil'] != null ? DateTime.parse(json['snoozeUntil'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
