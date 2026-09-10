import '../../../core/constants/sample_data.dart';
import '../domain/category_model.dart';
import '../domain/category_repository.dart';
import '../domain/tag_model.dart';

/// Concrete CategoryRepository implementation
class CategoryRepositoryImpl implements CategoryRepository {
  final List<Category> _categories = List.from(SampleData.categories);
  final List<Tag> _tags = List.from(SampleData.tags);

  @override
  Future<List<Category>> getCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    _categories.add(category);
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    } else {
      _categories.add(category);
    }
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<Tag>> getTags() async {
    return List.unmodifiable(_tags);
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    _tags.add(tag);
    return tag;
  }

  @override
  Future<void> deleteTag(String id) async {
    _tags.removeWhere((t) => t.id == id);
  }
}
