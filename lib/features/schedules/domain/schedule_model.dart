import 'package:flutter/material.dart';

enum ScheduleMode {
  delay,
  bounded,
  recurrent,
  dependent;

  String get label {
    switch (this) {
      case ScheduleMode.delay:
        return 'Delay';
      case ScheduleMode.bounded:
        return 'Time-Bounded';
      case ScheduleMode.recurrent:
        return 'Routine / Recurrent';
      case ScheduleMode.dependent:
        return 'Prerequisite';
    }
  }

  IconData get icon {
    switch (this) {
      case ScheduleMode.delay:
        return Icons.hourglass_top_rounded;
      case ScheduleMode.bounded:
        return Icons.date_range_rounded;
      case ScheduleMode.recurrent:
        return Icons.repeat_rounded;
      case ScheduleMode.dependent:
        return Icons.account_tree_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ScheduleMode.delay:
        return const Color(0xFFF59E0B); // Amber
      case ScheduleMode.bounded:
        return const Color(0xFF3B82F6); // Blue
      case ScheduleMode.recurrent:
        return const Color(0xFF10B981); // Emerald
      case ScheduleMode.dependent:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  static ScheduleMode fromString(String val) {
    switch (val.toLowerCase()) {
      case 'bounded':
        return ScheduleMode.bounded;
      case 'recurrent':
        return ScheduleMode.recurrent;
      case 'dependent':
        return ScheduleMode.dependent;
      case 'delay':
      default:
        return ScheduleMode.delay;
    }
  }
}

enum ScheduleStatus {
  pending,
  active,
  completed,
  blocked;

  String get label {
    switch (this) {
      case ScheduleStatus.pending:
        return 'Pending';
      case ScheduleStatus.active:
        return 'Active';
      case ScheduleStatus.completed:
        return 'Completed';
      case ScheduleStatus.blocked:
        return 'Blocked';
    }
  }

  Color get color {
    switch (this) {
      case ScheduleStatus.pending:
        return const Color(0xFFF59E0B);
      case ScheduleStatus.active:
        return const Color(0xFF10B981);
      case ScheduleStatus.completed:
        return const Color(0xFF6B7280);
      case ScheduleStatus.blocked:
        return const Color(0xFFEF4444);
    }
  }

  static ScheduleStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'active':
        return ScheduleStatus.active;
      case 'completed':
        return ScheduleStatus.completed;
      case 'blocked':
        return ScheduleStatus.blocked;
      case 'pending':
      default:
        return ScheduleStatus.pending;
    }
  }
}

class ScheduleModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String? description;
  final ScheduleMode mode;

  // Time Dimension Fields
  final String? delayOffset;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final String? rrule;
  final String? prerequisiteId;

  // State Tracking
  final ScheduleStatus status;
  final DateTime? completedAt;
  final DateTime? nextRunAt;
  final DateTime createdAt;

  const ScheduleModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    this.description,
    this.mode = ScheduleMode.delay,
    this.delayOffset,
    this.windowStart,
    this.windowEnd,
    this.rrule,
    this.prerequisiteId,
    this.status = ScheduleStatus.pending,
    this.completedAt,
    this.nextRunAt,
    required this.createdAt,
  });

  bool get isBlocked => status == ScheduleStatus.blocked;
  bool get isActive => status == ScheduleStatus.active;
  bool get isCompleted => status == ScheduleStatus.completed;
  bool get isPending => status == ScheduleStatus.pending;

  String get timingDescription {
    switch (mode) {
      case ScheduleMode.delay:
        return delayOffset != null ? '+${delayOffset!}' : '+2 hours';
      case ScheduleMode.bounded:
        if (windowStart != null && windowEnd != null) {
          final start = '${windowStart!.month}/${windowStart!.day} ${windowStart!.hour}:${windowStart!.minute.toString().padLeft(2, '0')}';
          final end = '${windowEnd!.month}/${windowEnd!.day} ${windowEnd!.hour}:${windowEnd!.minute.toString().padLeft(2, '0')}';
          return '$start → $end';
        }
        return 'Time Window Set';
      case ScheduleMode.recurrent:
        return rrule ?? 'Repeats Periodically';
      case ScheduleMode.dependent:
        return prerequisiteId != null ? 'Waiting for parent task' : 'No Prerequisite Set';
    }
  }

  ScheduleModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    ScheduleMode? mode,
    String? delayOffset,
    DateTime? windowStart,
    DateTime? windowEnd,
    String? rrule,
    String? prerequisiteId,
    ScheduleStatus? status,
    DateTime? completedAt,
    DateTime? nextRunAt,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      delayOffset: delayOffset ?? this.delayOffset,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      rrule: rrule ?? this.rrule,
      prerequisiteId: prerequisiteId ?? this.prerequisiteId,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'mode': mode.name,
      'delay_offset': delayOffset,
      'window_start': windowStart?.toIso8601String(),
      'window_end': windowEnd?.toIso8601String(),
      'rrule': rrule,
      'prerequisite_id': prerequisiteId,
      'status': status.name,
      'completed_at': completedAt?.toIso8601String(),
      'next_run_at': nextRunAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? 'default_user',
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      mode: ScheduleMode.fromString(json['mode'] as String? ?? 'delay'),
      delayOffset: json['delay_offset'] as String?,
      windowStart: json['window_start'] != null ? DateTime.tryParse(json['window_start'] as String) : null,
      windowEnd: json['window_end'] != null ? DateTime.tryParse(json['window_end'] as String) : null,
      rrule: json['rrule'] as String?,
      prerequisiteId: json['prerequisite_id'] as String?,
      status: ScheduleStatus.fromString(json['status'] as String? ?? 'pending'),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      nextRunAt: json['next_run_at'] != null ? DateTime.tryParse(json['next_run_at'] as String) : null,
      createdAt: json['created_at'] != null ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()) : DateTime.now(),
    );
  }
}