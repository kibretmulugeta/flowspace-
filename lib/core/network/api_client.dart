/// REST API Client contract & endpoint interfaces for FlowSpace
/// Pre-architected for FastAPI / PostgreSQL / SQLAlchemy / Redis backend.
library;

abstract class AuthApi {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String email, String password, String displayName);
  Future<void> requestPasswordReset(String email);
  Future<void> logout();
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}

abstract class TaskApi {
  Future<List<Map<String, dynamic>>> getTasks();
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskJson);
  Future<Map<String, dynamic>> updateTask(String id, Map<String, dynamic> taskJson);
  Future<void> deleteTask(String id);
}

abstract class CalendarApi {
  Future<List<Map<String, dynamic>>> getEvents();
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventJson);
  Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> eventJson);
  Future<void> deleteEvent(String id);
}

abstract class ReminderApi {
  Future<List<Map<String, dynamic>>> getReminders();
  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> reminderJson);
  Future<Map<String, dynamic>> updateReminder(String id, Map<String, dynamic> reminderJson);
  Future<void> deleteReminder(String id);
}

abstract class NotesApi {
  Future<List<Map<String, dynamic>>> getPages();
  Future<Map<String, dynamic>> createPage(Map<String, dynamic> pageJson);
  Future<Map<String, dynamic>> updatePage(String id, Map<String, dynamic> pageJson);
  Future<void> deletePage(String id);
}

abstract class ProjectApi {
  Future<List<Map<String, dynamic>>> getProjects();
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> projectJson);
  Future<Map<String, dynamic>> updateProject(String id, Map<String, dynamic> projectJson);
  Future<void> deleteProject(String id);
}

abstract class CategoryApi {
  Future<List<Map<String, dynamic>>> getCategories();
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryJson);
  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> categoryJson);
  Future<void> deleteCategory(String id);
}

/// Sync action queue item for recording offline mutations
class SyncQueueItem {
  final String id;
  final String entityType; // "task", "event", "note", "project", "reminder"
  final String action; // "create", "update", "delete"
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.action,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });

  SyncQueueItem copyWith({
    String? id,
    String? entityType,
    String? action,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'action': action,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      action: json['action'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: (json['retryCount'] as int?) ?? 0,
    );
  }
}
