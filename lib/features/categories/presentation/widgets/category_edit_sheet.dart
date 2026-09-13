import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/category_model.dart';
import '../category_provider.dart';

class CategoryEditSheet extends ConsumerStatefulWidget {
  final Category? existingCategory;

  const CategoryEditSheet({super.key, this.existingCategory});

  static Future<Category?> show(BuildContext context, {Category? existingCategory}) {
    return showModalBottomSheet<Category?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryEditSheet(existingCategory: existingCategory),
    );
  }

  @override
  ConsumerState<CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends ConsumerState<CategoryEditSheet> {
  late final TextEditingController _nameController;
  String _selectedIcon = '📁';
  Color _selectedColor = AppColors.accentIndigo;
  String? _nameError;
  bool _isSaving = false;

  final List<String> _icons = [
    '📁', '💼', '🏠', '🎓', '💡', '🏃', '💰', '🎨', '🛒', '📌', '🚀', '⭐', '❤️', '⚡'
  ];

  final List<Color> _colors = [
    AppColors.accentIndigo,
    AppColors.accentBlue,
    AppColors.accentTeal,
    AppColors.accentEmerald,
    AppColors.accentAmber,
    AppColors.accentOrange,
    AppColors.accentRose,
    AppColors.accentViolet,
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.existingCategory;
    _nameController = TextEditingController(text: c?.name ?? '');

    if (c != null) {
      _selectedIcon = c.iconCode.isNotEmpty ? c.iconCode : '📁';
      _selectedColor = c.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a category name');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(categoryProvider.notifier);

      if (widget.existingCategory != null) {
        final updated = widget.existingCategory!.copyWith(
          name: name,
          colorValue: _selectedColor.toARGB32(),
          iconCode: _selectedIcon,
        );
        await notifier.updateCategory(updated);
        if (mounted) {
          Navigator.of(context).pop(updated);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category updated'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final created = await notifier.addCategory(
          name: name,
          color: _selectedColor,
          iconCode: _selectedIcon,
        );
        if (mounted) {
          Navigator.of(context).pop(created);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category created'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save category: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.85,
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingCategory != null ? 'Edit Category' : 'New Category',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  FilledButton(
                    onPressed: _isSaving ? null : _onSave,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name Input
              TextField(
                controller: _nameController,
                autofocus: widget.existingCategory == null,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
                style: AppTypography.titleMedium,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Personal, Work, Marketing...',
                  errorText: _nameError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(_selectedIcon, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Icon Picker
              Text('Icon', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((emoji) {
                  final isSelected = _selectedIcon == emoji;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = emoji),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.18)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Color Picker
              Text('Color Accent', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((c) {
                  final isSelected = _selectedColor.toARGB32() == c.toARGB32();
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = c),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Full-width bottom action button for mobile thumb tapping
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.existingCategory != null ? 'Save Changes' : 'Create Category',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
