/// Workspace entity representing a personal or collaborative workspace
class Workspace {
  final String id;
  final String name;
  final String? icon;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workspace({
    required this.id,
    required this.name,
    this.icon,
    required this.ownerId,
    this.memberIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Workspace copyWith({
    String? id,
    String? name,
    String? icon,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      ownerId: json['ownerId'] as String,
      memberIds: (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
