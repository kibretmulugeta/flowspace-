import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/note_page_model.dart';
import '../notes_provider.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final notesNotifier = ref.read(notesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPages = notesState.filteredPages;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navNotes),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search notes',
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All Pages, Favorites, Recent, Trash)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: NotesFilterTab.values.map((tab) {
                final isSelected = notesState.activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(tab.label),
                    selected: isSelected,
                    onSelected: (_) => notesNotifier.setActiveTab(tab),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Pages List or Empty State
          Expanded(
            child: filteredPages.isEmpty
                ? EmptyStateView(
                    icon: Icons.article_outlined,
                    title: AppStrings.emptyNotesTitle,
                    subtitle: AppStrings.emptyNotesSubtitle,
                    actionLabel: 'New Page',
                    onAction: () async {
                      final newPage = await notesNotifier.createPage();
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteEditorScreen(pageId: newPage.id),
                          ),
                        );
                      }
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredPages.length,
                    itemBuilder: (context, index) {
                      final page = filteredPages[index];
                      return _buildPageCard(context, ref, page, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPage = await notesNotifier.createPage();
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(pageId: newPage.id),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPageCard(BuildContext context, WidgetRef ref, NotePage page, bool isDark) {
    final notesNotifier = ref.read(notesProvider.notifier);
    final subpages = ref.watch(notesProvider).getSubpagesOf(page.id);

    return InkWell(
      onTap: () {
        if (page.isTrash) {
          _showTrashOptionsDialog(context, ref, page);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NoteEditorScreen(pageId: page.id),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(page.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title.isEmpty ? 'Untitled' : page.title,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${page.blocks.length} blocks • ${DateFormatter.formatRelative(page.updatedAt)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!page.isTrash)
                  IconButton(
                    icon: Icon(
                      page.isFavorite ? Icons.star : Icons.star_border,
                      size: 20,
                      color: page.isFavorite ? AppColors.accentAmber : null,
                    ),
                    onPressed: () => notesNotifier.toggleFavorite(page.id),
                  ),
              ],
            ),
            if (subpages.isNotEmpty && !page.isTrash) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${subpages.length} subpages: ${subpages.map((s) => s.title).join(', ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTrashOptionsDialog(BuildContext context, WidgetRef ref, NotePage page) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Restore or Delete Permanently?'),
        content: Text('"${page.title}" is in trash.'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).restoreFromTrash(page.id);
              Navigator.of(context).pop();
            },
            child: const Text('Restore'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deletePermanently(page.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete Permanently', style: TextStyle(color: AppColors.priorityUrgent)),
          ),
        ],
      ),
    );
  }
}
