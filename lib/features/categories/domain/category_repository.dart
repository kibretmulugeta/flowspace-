import '../domain/category_model.dart';
import '../domain/tag_model.dart';

/// Category and Tag repository interface
abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category?> getCategoryById(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);

  Future<List<Tag>> getTags();
  Future<Tag> createTag(Tag tag);
  Future<void> deleteTag(String id);
}
