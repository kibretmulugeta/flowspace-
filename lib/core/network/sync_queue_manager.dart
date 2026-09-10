/// Offline Sync Outbox Queue Manager
/// Persists pending offline operations and synchronizes with FastAPI /api/v1/sync/batch.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'dio_client.dart';

final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
  return SyncQueueManager();
});

class SyncQueueManager {
  static const String _storageKey = 'fs_offline_sync_queue';
  static const int maxRetries = 3;

  final List<SyncQueueItem> _queue = [];
  bool _isSyncing = false;

  List<SyncQueueItem> get pendingItems => List.unmodifiable(_queue);
  int get queueCount => _queue.length;
  bool get isSyncing => _isSyncing;

  /// Loads stored queue items from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];
      _queue.clear();
      for (final raw in rawList) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _queue.add(SyncQueueItem.fromJson(decoded));
      }
    } catch (_) {
      // Gracefully handle parsing issues
    }
  }

  /// Enqueue an offline mutation
  Future<void> enqueue(SyncQueueItem item) async {
    _queue.add(item);
    await _persist();
  }

  /// Removes an item from the queue
  Future<void> remove(String id) async {
    _queue.removeWhere((item) => item.id == id);
    await _persist();
  }

  /// Flushes pending queue to backend batch sync endpoint
  Future<bool> processQueue(DioClient dioClient, {String clientId = 'flutter-client'}) async {
    if (_isSyncing || _queue.isEmpty) return false;
    _isSyncing = true;

    try {
      final batchPayload = {
        'client_id': clientId,
        'actions': _queue
            .map((item) => {
                  'action_id': item.id,
                  'entity_type': item.entityType,
                  'action_type': item.action,
                  'entity_id': item.payload['id'] ?? item.id,
                  'payload': item.payload,
                  'timestamp': item.timestamp.toIso8601String(),
                })
            .toList(),
      };

      final response = await dioClient.post('/sync/batch', data: batchPayload);

      if (response.statusCode == 200 && response.data is Map) {
        final processedIds = List<String>.from(response.data['processed_action_ids'] ?? []);
        _queue.removeWhere((item) => processedIds.contains(item.id));
        await _persist();
        return true;
      }
    } catch (_) {
      // Increment retry counts and prune items exceeding maxRetries
      for (int i = 0; i < _queue.length; i++) {
        final item = _queue[i];
        _queue[i] = item.copyWith(retryCount: item.retryCount + 1);
      }
      _queue.removeWhere((item) => item.retryCount >= maxRetries);
      await _persist();
    } finally {
      _isSyncing = false;
    }

    return false;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _queue.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (_) {
      // Memory persistence retained
    }
  }
}
