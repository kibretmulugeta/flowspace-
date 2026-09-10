import '../domain/note_page_model.dart';

/// Notes and Pages repository interface
abstract class NotesRepository {
  Future<List<NotePage>> getPages();
  Future<NotePage?> getPageById(String id);
  Future<List<NotePage>> getSubpages(String parentId);
  Future<NotePage> createPage(NotePage page);
  Future<NotePage> updatePage(NotePage page);
  Future<void> deletePage(String id);
  Future<void> toggleFavorite(String id);
  Future<void> moveToTrash(String id);
  Future<void> restoreFromTrash(String id);
  Future<void> reorderBlocks(String pageId, int oldIndex, int newIndex);
}
