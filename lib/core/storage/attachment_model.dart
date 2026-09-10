/// Attachment entity for tasks, notes, or events
class Attachment {
  final String id;
  final String name;
  final String uri;
  final int sizeBytes;
  final String mimeType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Attachment({
    required this.id,
    required this.name,
    required this.uri,
    required this.sizeBytes,
    required this.mimeType,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      sizeBytes: json['sizeBytes'] as int,
      mimeType: json['mimeType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
