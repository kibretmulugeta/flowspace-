import 'editor_block_model.dart';

/// NotePage entity supporting hierarchical tree nesting and block content
class NotePage {
  final String id;
  final String title;
  final String icon; // Emoji or icon identifier e.g. "📄", "🚀", "💡"
  final String? coverUrl;
  final bool isFavorite;
  final bool isArchived;
  final bool isTrash;
  final String? workspaceId;
  final String? parentPageId; // For nested subpage hierarchy
  final String? projectId; // If linked to a project
  final List<String> tags;
  final List<EditorBlock> blocks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotePage({
    required this.id,
    required this.title,
    this.icon = '📄',
    this.coverUrl,
    this.isFavorite = false,
    this.isArchived = false,
    this.isTrash = false,
    this.workspaceId,
    this.parentPageId,
    this.projectId,
    this.tags = const [],
    this.blocks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  NotePage copyWith({
    String? id,
    String? title,
    String? icon,
    String? coverUrl,
    bool? isFavorite,
    bool? isArchived,
    bool? isTrash,
    String? workspaceId,
    String? parentPageId,
    String? projectId,
    List<String>? tags,
    List<EditorBlock>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotePage(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      coverUrl: coverUrl ?? this.coverUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isTrash: isTrash ?? this.isTrash,
      workspaceId: workspaceId ?? this.workspaceId,
      parentPageId: parentPageId ?? this.parentPageId,
      projectId: projectId ?? this.projectId,
      tags: tags ?? this.tags,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'coverUrl': coverUrl,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isTrash': isTrash,
      'workspaceId': workspaceId,
      'parentPageId': parentPageId,
      'projectId': projectId,
      'tags': tags,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotePage.fromJson(Map<String, dynamic> json) {
    return NotePage(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '📄',
      coverUrl: json['coverUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isTrash: json['isTrash'] as bool? ?? false,
      workspaceId: json['workspaceId'] as String?,
      parentPageId: json['parentPageId'] as String?,
      projectId: json['projectId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => EditorBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
