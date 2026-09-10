import 'package:flutter/material.dart';

/// Calendar Event entity
class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? location;
  final int colorValue;
  final String calendarId;
  final List<String> participants;
  final String? reminderMinutesBefore;
  final String? recurrence; // e.g. "daily", "weekly", "monthly", "none"
  final String? notes;
  final String? projectId;
  final bool isAllDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDateTime,
    required this.endDateTime,
    this.location,
    required this.colorValue,
    required this.calendarId,
    this.participants = const [],
    this.reminderMinutesBefore,
    this.recurrence,
    this.notes,
    this.projectId,
    this.isAllDay = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color => Color(colorValue);

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    int? colorValue,
    String? calendarId,
    List<String>? participants,
    String? reminderMinutesBefore,
    String? recurrence,
    String? notes,
    String? projectId,
    bool? isAllDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      colorValue: colorValue ?? this.colorValue,
      calendarId: calendarId ?? this.calendarId,
      participants: participants ?? this.participants,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      recurrence: recurrence ?? this.recurrence,
      notes: notes ?? this.notes,
      projectId: projectId ?? this.projectId,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'location': location,
      'colorValue': colorValue,
      'calendarId': calendarId,
      'participants': participants,
      'reminderMinutesBefore': reminderMinutesBefore,
      'recurrence': recurrence,
      'notes': notes,
      'projectId': projectId,
      'isAllDay': isAllDay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      location: json['location'] as String?,
      colorValue: json['colorValue'] as int,
      calendarId: json['calendarId'] as String,
      participants: (json['participants'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      reminderMinutesBefore: json['reminderMinutesBefore'] as String?,
      recurrence: json['recurrence'] as String?,
      notes: json['notes'] as String?,
      projectId: json['projectId'] as String?,
      isAllDay: json['isAllDay'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
