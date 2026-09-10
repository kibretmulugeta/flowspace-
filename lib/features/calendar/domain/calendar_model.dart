import 'package:flutter/material.dart';

/// Calendar entity representing a collection of events (e.g. Work, Personal)
class Calendar {
  final String id;
  final String name;
  final int colorValue;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Calendar({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color => Color(colorValue);

  Calendar copyWith({
    String? id,
    String? name,
    int? colorValue,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Calendar(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'isVisible': isVisible,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
      isVisible: json['isVisible'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
