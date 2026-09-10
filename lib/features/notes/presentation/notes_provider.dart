import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/notes_repository_impl.dart';
import '../domain/editor_block_model.dart';
import '../domain/note_page_model.dart';
import '../domain/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});

enum NotesFilterTab {
  allPages,
  favorites,
  recent,
  trash;

  String get label {
    switch (this) {
      case NotesFilterTab.allPages:
        return 'All Pages';
      case NotesFilterTab.favorites:
        return 'Favorites';
      case NotesFilterTab.recent:
        return 'Recent';
      case NotesFilterTab.trash:
        return 'Trash';
    }
  }
}

class NotesState {
  final List<NotePage> pages;
  final String? activePageId;
  final NotesFilterTab activeTab;
  final bool isLoading;

  const NotesState({
    this.pages = const [],
    this.activePageId,
    this.activeTab = NotesFilterTab.allPages,
    this.isLoading = false,
  });

  NotesState copyWith({
    List<NotePage>? pages,
    String? activePageId,
    NotesFilterTab? activeTab,
    bool? isLoading,
    bool clearActivePage = false,
  }) {
    return NotesState(
      pages: pages ?? this.pages,
      activePageId: clearActivePage ? null : (activePageId ?? this.activePageId),
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  NotePage? get activePage {
    if (activePageId == null) return null;
    try {
      return pages.firstWhere((p) => p.id == activePageId);
    } catch (_) {
      return null;
    }
  }

  List<NotePage> get filteredPages {
    switch (activeTab) {
      case NotesFilterTab.allPages:
        return pages.where((p) => !p.isTrash).toList();
      case NotesFilterTab.favorites:
        return pages.where((p) => p.isFavorite && !p.isTrash).toList();
      case NotesFilterTab.recent:
        final list = pages.where((p) => !p.isTrash).toList();
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return list;
      case NotesFilterTab.trash:
        return pages.where((p) => p.isTrash).toList();
    }
  }

  List<NotePage> getSubpagesOf(String parentId) {
    return pages.where((p) => p.parentPageId == parentId && !p.isTrash).toList();
  }

  List<NotePage> get rootPages {
    return pages.where((p) => p.parentPageId == null && !p.isTrash).toList();
  }
}

class NotesNotifier extends Notifier<NotesState> {
  late final NotesRepository _repository;
  final _uuid = const Uuid();

  @override
  NotesState build() {
    _repository = ref.read(notesRepositoryProvider);
    Future.microtask(() => loadPages());
    return const NotesState();
  }

  Future<void> loadPages() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getPages();
    state = state.copyWith(pages: list, isLoading: false);
  }

  void setActiveTab(NotesFilterTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setActivePage(String? pageId) {
    if (pageId == null) {
      state = state.copyWith(clearActivePage: true);
    } else {
      state = state.copyWith(activePageId: pageId);
    }
  }

  Future<NotePage> createPage({
    String title = 'Untitled',
    String icon = '📄',
    String? parentPageId,
    String? projectId,
  }) async {
    final now = DateTime.now();
    final newPage = NotePage(
      id: _uuid.v4(),
      title: title,
      icon: icon,
      parentPageId: parentPageId,
      projectId: projectId,
      blocks: [
        EditorBlock(
          id: _uuid.v4(),
          type: BlockType.text,
          content: '',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createPage(newPage);
    state = state.copyWith(
      pages: [newPage, ...state.pages],
      activePageId: newPage.id,
    );
    return newPage;
  }

  Future<void> updatePageTitle(String pageId, String title) async {
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final updated = page.copyWith(title: title, updatedAt: DateTime.now());
    await _repository.updatePage(updated);
    _updatePageInState(updated);
  }

  Future<void> updatePageIcon(String pageId, String icon) async {
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final updated = page.copyWith(icon: icon, updatedAt: DateTime.now());
    await _repository.updatePage(updated);
    _updatePageInState(updated);
  }

  Future<void> toggleFavorite(String pageId) async {
    await _repository.toggleFavorite(pageId);
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final updated = page.copyWith(isFavorite: !page.isFavorite, updatedAt: DateTime.now());
    _updatePageInState(updated);
  }

  Future<void> moveToTrash(String pageId) async {
    await _repository.moveToTrash(pageId);
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final updated = page.copyWith(isTrash: true, updatedAt: DateTime.now());
    _updatePageInState(updated);
  }

  Future<void> restoreFromTrash(String pageId) async {
    await _repository.restoreFromTrash(pageId);
    final page = state.pages.firstWhere((p) => p.id == pageId);
    final updated = page.copyWith(isTrash: false, updatedAt: DateTime.now());
    _updatePageInState(updated);
  }

  Future<void> deletePermanently(String pageId) async {
    await _repository.deletePage(pageId);
    state = state.copyWith(
      pages: state.pages.where((p) => p.id != pageId).toList(),
      clearActivePage: state.activePageId == pageId,
    );
  }

  // --- Block Editing Engine ---

  Future<void> addBlock(String pageId, {int? afterIndex, BlockType type = BlockType.text}) async {
    final pageIndex = state.pages.indexWhere((p) => p.id == pageId);
    if (pageIndex == -1) return;

    final page = state.pages[pageIndex];
    final blocks = List<EditorBlock>.from(page.blocks);
    final now = DateTime.now();
    final newBlock = EditorBlock(
      id: _uuid.v4(),
      type: type,
      content: '',
      createdAt: now,
      updatedAt: now,
    );

    if (afterIndex != null && afterIndex >= 0 && afterIndex < blocks.length) {
      blocks.insert(afterIndex + 1, newBlock);
    } else {
      blocks.add(newBlock);
    }

    final updatedPage = page.copyWith(blocks: blocks, updatedAt: now);
    await _repository.updatePage(updatedPage);
    _updatePageInState(updatedPage);
  }

  Future<void> updateBlockContent(String pageId, String blockId, String content) async {
    final pageIndex = state.pages.indexWhere((p) => p.id == pageId);
    if (pageIndex == -1) return;

    final page = state.pages[pageIndex];
    final blockIndex = page.blocks.indexWhere((b) => b.id == blockId);
    if (blockIndex == -1) return;

    final block = page.blocks[blockIndex];
    final updatedBlock = block.copyWith(content: content, updatedAt: DateTime.now());

    final blocks = List<EditorBlock>.from(page.blocks);
    blocks[blockIndex] = updatedBlock;

    final updatedPage = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
    await _repository.updatePage(updatedPage);
    _updatePageInState(updatedPage);
  }

  Future<void> setBlockType(String pageId, String blockId, BlockType type) async {
    final pageIndex = state.pages.indexWhere((p) => p.id == pageId);
    if (pageIndex == -1) return;

    final page = state.pages[pageIndex];
    final blockIndex = page.blocks.indexWhere((b) => b.id == blockId);
    if (blockIndex == -1) return;

    final block = page.blocks[blockIndex];
    final updatedBlock = block.copyWith(type: type, updatedAt: DateTime.now());

    final blocks = List<EditorBlock>.from(page.blocks);
    blocks[blockIndex] = updatedBlock;

    final updatedPage = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
    await _repository.updatePage(updatedPage);
    _updatePageInState(updatedPage);
  }

  Future<void> toggleChecklistBlock(String pageId, String blockId) async {
    final pageIndex = state.pages.indexWhere((p) => p.id == pageId);
    if (pageIndex == -1) return;

    final page = state.pages[pageIndex];
    final blockIndex = page.blocks.indexWhere((b) => b.id == blockId);
    if (blockIndex == -1) return;

    final block = page.blocks[blockIndex];
    final updatedBlock = block.copyWith(
      isChecked: !block.isChecked,
      updatedAt: DateTime.now(),
    );

    final blocks = List<EditorBlock>.from(page.blocks);
    blocks[blockIndex] = updatedBlock;

    final updatedPage = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
    await _repository.updatePage(updatedPage);
    _updatePageInState(updatedPage);
  }

  Future<void> removeBlock(String pageId, String blockId) async {
    final pageIndex = state.pages.indexWhere((p) => p.id == pageId);
    if (pageIndex == -1) return;

    final page = state.pages[pageIndex];
    if (page.blocks.length <= 1) return;

    final blocks = page.blocks.where((b) => b.id != blockId).toList();
    final updatedPage = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
    await _repository.updatePage(updatedPage);
    _updatePageInState(updatedPage);
  }

  Future<void> reorderBlocks(String pageId, int oldIndex, int newIndex) async {
    await _repository.reorderBlocks(pageId, oldIndex, newIndex);
    final pageIndex = state.pages.indexWhere((p) => p.id == pageId);
    if (pageIndex == -1) return;

    final page = state.pages[pageIndex];
    final blocks = List<EditorBlock>.from(page.blocks);
    if (oldIndex < newIndex) newIndex -= 1;
    final b = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, b);

    final updatedPage = page.copyWith(blocks: blocks, updatedAt: DateTime.now());
    _updatePageInState(updatedPage);
  }

  void _updatePageInState(NotePage updated) {
    final list = state.pages.map((p) => p.id == updated.id ? updated : p).toList();
    state = state.copyWith(pages: list);
  }
}

final notesProvider = NotifierProvider<NotesNotifier, NotesState>(NotesNotifier.new);
