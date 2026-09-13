import '../../../core/storage/local_database_service.dart';
import '../domain/category_model.dart';
import '../domain/category_repository.dart';
import '../domain/tag_model.dart';

/// Concrete persistent CategoryRepository backed by LocalDatabaseService
class CategoryRepositoryImpl implements CategoryRepository {
  List<Category>? _categories;
  List<Tag>? _tags;
  final LocalDatabaseService _db = LocalDatabaseService.instance;

  Future<List<Category>> _ensureCategoriesLoaded() async {
    _categories ??= await _db.loadCategories();
    return _categories!;
  }

  Future<List<Tag>> _ensureTagsLoaded() async {
    _tags ??= await _db.loadTags();
    return _tags!;
  }

  @override
  Future<List<Category>> getCategories() async {
    final categories = await _ensureCategoriesLoaded();
    return List.unmodifiable(categories);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final categories = await _ensureCategoriesLoaded();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    final categories = await _ensureCategoriesLoaded();
    categories.add(category);
    await _db.saveCategories(categories);
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final categories = await _ensureCategoriesLoaded();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
    } else {
      categories.add(category);
    }
    await _db.saveCategories(categories);
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final categories = await _ensureCategoriesLoaded();
    categories.removeWhere((c) => c.id == id);
    await _db.saveCategories(categories);
  }

  @override
  Future<List<Tag>> getTags() async {
    final tags = await _ensureTagsLoaded();
    return List.unmodifiable(tags);
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    final tags = await _ensureTagsLoaded();
    tags.add(tag);
    await _db.saveTags(tags);
    return tag;
  }

  @override
  Future<void> deleteTag(String id) async {
    final tags = await _ensureTagsLoaded();
    tags.removeWhere((t) => t.id == id);
    await _db.saveTags(tags);
  }
}
