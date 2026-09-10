/// Enumeration of Notion-style block types supported by FlowSpace
enum BlockType {
  text,
  heading1,
  heading2,
  heading3,
  bulletList,
  numberedList,
  checklist,
  quote,
  divider,
  code,
  image,
  link,
  table,
  callout;

  String get label {
    switch (this) {
      case BlockType.text:
        return 'Text';
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      case BlockType.bulletList:
        return 'Bulleted List';
      case BlockType.numberedList:
        return 'Numbered List';
      case BlockType.checklist:
        return 'To-do list';
      case BlockType.quote:
        return 'Quote';
      case BlockType.divider:
        return 'Divider';
      case BlockType.code:
        return 'Code Block';
      case BlockType.image:
        return 'Image';
      case BlockType.link:
        return 'Web Bookmark';
      case BlockType.table:
        return 'Table';
      case BlockType.callout:
        return 'Callout';
    }
  }

  String get slashCommand {
    switch (this) {
      case BlockType.text:
        return '/text';
      case BlockType.heading1:
        return '/h1';
      case BlockType.heading2:
        return '/h2';
      case BlockType.heading3:
        return '/h3';
      case BlockType.bulletList:
        return '/bullet';
      case BlockType.numberedList:
        return '/num';
      case BlockType.checklist:
        return '/todo';
      case BlockType.quote:
        return '/quote';
      case BlockType.divider:
        return '/divider';
      case BlockType.code:
        return '/code';
      case BlockType.image:
        return '/image';
      case BlockType.link:
        return '/link';
      case BlockType.table:
        return '/table';
      case BlockType.callout:
        return '/callout';
    }
  }
}

/// Immutable block item in a Notion-style document page
class EditorBlock {
  final String id;
  final BlockType type;
  final String content;
  final bool isChecked; // For checklist
  final String? calloutIcon; // For callout e.g. "💡"
  final String? codeLanguage; // For code block e.g. "dart"
  final String? imageUrl; // For image block
  final List<List<String>> tableData; // For table block rows and columns
  final DateTime createdAt;
  final DateTime updatedAt;

  const EditorBlock({
    required this.id,
    required this.type,
    required this.content,
    this.isChecked = false,
    this.calloutIcon = '💡',
    this.codeLanguage = 'dart',
    this.imageUrl,
    this.tableData = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  EditorBlock copyWith({
    String? id,
    BlockType? type,
    String? content,
    bool? isChecked,
    String? calloutIcon,
    String? codeLanguage,
    String? imageUrl,
    List<List<String>>? tableData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EditorBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      isChecked: isChecked ?? this.isChecked,
      calloutIcon: calloutIcon ?? this.calloutIcon,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      imageUrl: imageUrl ?? this.imageUrl,
      tableData: tableData ?? this.tableData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'isChecked': isChecked,
      'calloutIcon': calloutIcon,
      'codeLanguage': codeLanguage,
      'imageUrl': imageUrl,
      'tableData': tableData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EditorBlock.fromJson(Map<String, dynamic> json) {
    return EditorBlock(
      id: json['id'] as String,
      type: BlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BlockType.text,
      ),
      content: json['content'] as String? ?? '',
      isChecked: json['isChecked'] as bool? ?? false,
      calloutIcon: json['calloutIcon'] as String? ?? '💡',
      codeLanguage: json['codeLanguage'] as String? ?? 'dart',
      imageUrl: json['imageUrl'] as String?,
      tableData: (json['tableData'] as List<dynamic>?)
              ?.map((row) => (row as List<dynamic>).map((c) => c.toString()).toList())
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
