import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum TaskPriority {
  none,
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TaskPriority.none:
        return 'None';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.none:
        return AppColors.priorityNone;
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }
}

enum TaskStatus {
  inbox,
  todo,
  inProgress,
  completed,
  archived;

  String get label {
    switch (this) {
      case TaskStatus.inbox:
        return 'Inbox';
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.archived:
        return 'Archived';
    }
  }
}

/// Task entity
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? dueTime; // Format "HH:mm"
  final TaskPriority priority;
  final TaskStatus status;
  final String? projectId;
  final String? categoryId;
  final List<String> tags;
  final String? recurrence; // e.g. "daily", "weekly", "monthly"
  final int estimatedDurationMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> subtasks; // Checklist of subtasks
  final List<bool> subtasksCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.projectId,
    this.categoryId,
    this.tags = const [],
    this.recurrence,
    this.estimatedDurationMinutes = 30,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks = const [],
    this.subtasksCompleted = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    TaskPriority? priority,
    TaskStatus? status,
    String? projectId,
    String? categoryId,
    List<String>? tags,
    String? recurrence,
    int? estimatedDurationMinutes,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? subtasks,
    List<bool>? subtasksCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      recurrence: recurrence ?? this.recurrence,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
      subtasksCompleted: subtasksCompleted ?? this.subtasksCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'priority': priority.name,
      'status': status.name,
      'projectId': projectId,
      'categoryId': categoryId,
      'tags': tags,
      'recurrence': recurrence,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks,
      'subtasksCompleted': subtasksCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      dueTime: json['dueTime'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      projectId: json['projectId'] as String?,
      categoryId: json['categoryId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      recurrence: json['recurrence'] as String?,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int? ?? 30,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      subtasks: (json['subtasks'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      subtasksCompleted: (json['subtasksCompleted'] as List<dynamic>?)?.map((e) => e as bool).toList() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
