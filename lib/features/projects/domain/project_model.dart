import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ProjectStatus {
  planning,
  active,
  onHold,
  completed,
  archived;

  String get label {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return AppColors.statusPlanning;
      case ProjectStatus.active:
        return AppColors.statusActive;
      case ProjectStatus.onHold:
        return AppColors.statusOnHold;
      case ProjectStatus.completed:
        return AppColors.statusCompleted;
      case ProjectStatus.archived:
        return AppColors.statusArchived;
    }
  }
}

/// Project entity
class Project {
  final String id;
  final String name;
  final String description;
  final String icon; // e.g. "🚀", "🔬", "💻"
  final int colorValue;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final List<String> taskIds;
  final List<String> notePageIds;
  final List<String> eventIds;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = '📁',
    required this.colorValue,
    this.status = ProjectStatus.active,
    this.startDate,
    this.dueDate,
    this.taskIds = const [],
    this.notePageIds = const [],
    this.eventIds = const [],
    this.memberIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color => Color(colorValue);

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? colorValue,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? dueDate,
    List<String>? taskIds,
    List<String>? notePageIds,
    List<String>? eventIds,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      taskIds: taskIds ?? this.taskIds,
      notePageIds: notePageIds ?? this.notePageIds,
      eventIds: eventIds ?? this.eventIds,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'colorValue': colorValue,
      'status': status.name,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'taskIds': taskIds,
      'notePageIds': notePageIds,
      'eventIds': eventIds,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '📁',
      colorValue: json['colorValue'] as int,
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      taskIds: (json['taskIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      notePageIds: (json['notePageIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      eventIds: (json['eventIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      memberIds: (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
