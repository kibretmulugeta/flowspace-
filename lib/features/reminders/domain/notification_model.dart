/// Notification model for in-app and local scheduled alerts
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payloadType; // "task", "event", "reminder"
  final String? payloadId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.payloadType,
    this.payloadId,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? scheduledTime,
    String? payloadType,
    String? payloadId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      payloadType: payloadType ?? this.payloadType,
      payloadId: payloadId ?? this.payloadId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'payloadType': payloadType,
      'payloadId': payloadId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      payloadType: json['payloadType'] as String?,
      payloadId: json['payloadId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
