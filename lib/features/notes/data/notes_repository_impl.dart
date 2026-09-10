import '../../../core/constants/sample_data.dart';
import '../domain/editor_block_model.dart';
import '../domain/note_page_model.dart';
import '../domain/notes_repository.dart';

/// Concrete NotesRepository implementation
class NotesRepositoryImpl implements NotesRepository {
  final List<NotePage> _pages = List.from(SampleData.notePages);

  @override
  Future<List<NotePage>> getPages() async {
    return List.unmodifiable(_pages);
  }

  @override
  Future<NotePage?> getPageById(String id) async {
    try {
      return _pages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<NotePage>> getSubpages(String parentId) async {
    return _pages.where((p) => p.parentPageId == parentId && !p.isTrash).toList();
  }

  @override
  Future<NotePage> createPage(NotePage page) async {
    _pages.insert(0, page);
    return page;
  }

  @override
  Future<NotePage> updatePage(NotePage page) async {
    final index = _pages.indexWhere((p) => p.id == page.id);
    if (index != -1) {
      _pages[index] = page;
    } else {
      _pages.insert(0, page);
    }
    return page;
  }

  @override
  Future<void> deletePage(String id) async {
    _pages.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _pages.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _pages[index];
      _pages[index] = current.copyWith(
        isFavorite: !current.isFavorite,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> moveToTrash(String id) async {
    final index = _pages.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pages[index] = _pages[index].copyWith(isTrash: true, updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> restoreFromTrash(String id) async {
    final index = _pages.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pages[index] = _pages[index].copyWith(isTrash: false, updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> reorderBlocks(String pageId, int oldIndex, int newIndex) async {
    final index = _pages.indexWhere((p) => p.id == pageId);
    if (index != -1) {
      final page = _pages[index];
      final blocks = List<EditorBlock>.from(page.blocks);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final block = blocks.removeAt(oldIndex);
      blocks.insert(newIndex, block);
      _pages[index] = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
    }
  }
}
