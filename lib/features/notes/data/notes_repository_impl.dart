import '../../../core/storage/local_database_service.dart';
import '../domain/editor_block_model.dart';
import '../domain/note_page_model.dart';
import '../domain/notes_repository.dart';

/// Concrete persistent NotesRepository backed by LocalDatabaseService
class NotesRepositoryImpl implements NotesRepository {
  List<NotePage>? _pages;
  final LocalDatabaseService _db = LocalDatabaseService.instance;

  Future<List<NotePage>> _ensureLoaded() async {
    _pages ??= await _db.loadNotes();
    return _pages!;
  }

  @override
  Future<List<NotePage>> getPages() async {
    final pages = await _ensureLoaded();
    return List.unmodifiable(pages);
  }

  @override
  Future<NotePage?> getPageById(String id) async {
    final pages = await _ensureLoaded();
    try {
      return pages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<NotePage>> getSubpages(String parentId) async {
    final pages = await _ensureLoaded();
    return pages.where((p) => p.parentPageId == parentId && !p.isTrash).toList();
  }

  @override
  Future<NotePage> createPage(NotePage page) async {
    final pages = await _ensureLoaded();
    pages.insert(0, page);
    await _db.saveNotes(pages);
    return page;
  }

  @override
  Future<NotePage> updatePage(NotePage page) async {
    final pages = await _ensureLoaded();
    final index = pages.indexWhere((p) => p.id == page.id);
    if (index != -1) {
      pages[index] = page;
    } else {
      pages.insert(0, page);
    }
    await _db.saveNotes(pages);
    return page;
  }

  @override
  Future<void> deletePage(String id) async {
    final pages = await _ensureLoaded();
    pages.removeWhere((p) => p.id == id);
    await _db.saveNotes(pages);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final pages = await _ensureLoaded();
    final index = pages.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = pages[index];
      pages[index] = current.copyWith(
        isFavorite: !current.isFavorite,
        updatedAt: DateTime.now(),
      );
      await _db.saveNotes(pages);
    }
  }

  @override
  Future<void> moveToTrash(String id) async {
    final pages = await _ensureLoaded();
    final index = pages.indexWhere((p) => p.id == id);
    if (index != -1) {
      pages[index] = pages[index].copyWith(isTrash: true, updatedAt: DateTime.now());
      await _db.saveNotes(pages);
    }
  }

  @override
  Future<void> restoreFromTrash(String id) async {
    final pages = await _ensureLoaded();
    final index = pages.indexWhere((p) => p.id == id);
    if (index != -1) {
      pages[index] = pages[index].copyWith(isTrash: false, updatedAt: DateTime.now());
      await _db.saveNotes(pages);
    }
  }

  @override
  Future<void> reorderBlocks(String pageId, int oldIndex, int newIndex) async {
    final pages = await _ensureLoaded();
    final index = pages.indexWhere((p) => p.id == pageId);
    if (index != -1) {
      final page = pages[index];
      final blocks = List<EditorBlock>.from(page.blocks);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final block = blocks.removeAt(oldIndex);
      blocks.insert(newIndex, block);
      pages[index] = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
      await _db.saveNotes(pages);
    }
  }
}
