import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/category_repository_impl.dart';
import '../domain/category_model.dart';
import '../domain/category_repository.dart';
import '../domain/tag_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl();
});

class CategoryState {
  final List<Category> categories;
  final List<Tag> tags;
  final bool isLoading;

  const CategoryState({
    this.categories = const [],
    this.tags = const [],
    this.isLoading = false,
  });

  CategoryState copyWith({
    List<Category>? categories,
    List<Tag>? tags,
    bool? isLoading,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoryNotifier extends Notifier<CategoryState> {
  late final CategoryRepository _repository;
  final _uuid = const Uuid();

  @override
  CategoryState build() {
    _repository = ref.read(categoryRepositoryProvider);
    Future.microtask(() => loadData());
    return const CategoryState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final cats = await _repository.getCategories();
    final tgs = await _repository.getTags();
    state = state.copyWith(categories: cats, tags: tgs, isLoading: false);
  }

  Future<void> loadCategories() => loadData();

  Future<Category> addCategory({
    required String name,
    required Color color,
    required String iconCode,
  }) async {
    final now = DateTime.now();
    final category = Category(
      id: _uuid.v4(),
      name: name,
      colorValue: color.toARGB32(),
      iconCode: iconCode,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createCategory(category);
    state = state.copyWith(categories: [...state.categories, category]);
    return category;
  }

  Future<void> updateCategory(Category category) async {
    final updated = category.copyWith(updatedAt: DateTime.now());
    await _repository.updateCategory(updated);
    final list = state.categories.map((c) => c.id == updated.id ? updated : c).toList();
    state = state.copyWith(categories: list);
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    state = state.copyWith(
      categories: state.categories.where((c) => c.id != id).toList(),
    );
  }

  Future<Tag> addTag(String name, Color color) async {
    final now = DateTime.now();
    final tag = Tag(
      id: _uuid.v4(),
      name: name,
      colorValue: color.toARGB32(),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createTag(tag);
    state = state.copyWith(tags: [...state.tags, tag]);
    return tag;
  }

  Future<void> deleteTag(String id) async {
    await _repository.deleteTag(id);
    state = state.copyWith(
      tags: state.tags.where((t) => t.id != id).toList(),
    );
  }
}

final categoryProvider = NotifierProvider<CategoryNotifier, CategoryState>(CategoryNotifier.new);
