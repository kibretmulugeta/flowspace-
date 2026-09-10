import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/editor_block_model.dart';
import '../../domain/note_page_model.dart';
import '../notes_provider.dart';
import '../widgets/block_item_widget.dart';
import '../widgets/slash_command_palette.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String pageId;

  const NoteEditorScreen({super.key, required this.pageId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  final List<String> _emojiPickerOptions = [
    '📄', '🧠', '⚡', '💡', '🚀', '🔬', '📝', '🎯', '✨', '📚', '💻', '🎨'
  ];

  @override
  void initState() {
    super.initState();
    final page = ref.read(notesProvider).pages.firstWhere(
          (p) => p.id == widget.pageId,
          orElse: () => NotePage(
            id: widget.pageId,
            title: 'Untitled',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    _titleController = TextEditingController(text: page.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showEmojiPicker(NotePage page) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Page Icon', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _emojiPickerOptions.map((emoji) {
                  return InkWell(
                    onTap: () {
                      ref.read(notesProvider.notifier).updatePageIcon(page.id, emoji);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createSubpage(String parentId) async {
    final newPage = await ref.read(notesProvider.notifier).createPage(
          title: 'Untitled Subpage',
          parentPageId: parentId,
        );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(pageId: newPage.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final notesNotifier = ref.read(notesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final page = notesState.pages.cast<NotePage?>().firstWhere(
          (p) => p?.id == widget.pageId,
          orElse: () => null,
        );

    if (page == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Page not found')),
      );
    }

    // Breadcrumbs if nested
    final parentPage = page.parentPageId != null
        ? notesState.pages.cast<NotePage?>().firstWhere(
              (p) => p?.id == page.parentPageId,
              orElse: () => null,
            )
        : null;

    final subpages = notesState.getSubpagesOf(page.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: parentPage != null
            ? Row(
                children: [
                  Text(
                    '${parentPage.icon} ${parentPage.title}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const Text(' / '),
                  Text(
                    page.title,
                    style: AppTypography.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              page.isFavorite ? Icons.star : Icons.star_border,
              color: page.isFavorite ? AppColors.accentAmber : null,
            ),
            tooltip: 'Favorite',
            onPressed: () => notesNotifier.toggleFavorite(page.id),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'trash') {
                notesNotifier.moveToTrash(page.id);
                Navigator.of(context).pop();
              } else if (val == 'subpage') {
                _createSubpage(page.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'subpage',
                child: Row(
                  children: [
                    Icon(Icons.add_to_photos_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Add Subpage'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'trash',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.priorityUrgent),
                    SizedBox(width: 8),
                    Text('Move to Trash', style: TextStyle(color: AppColors.priorityUrgent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Icon picker & Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showEmojiPicker(page),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(page.icon, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          onChanged: (newTitle) =>
                              notesNotifier.updatePageTitle(page.id, newTitle),
                          style: AppTypography.displaySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Page title...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metadata updated timestamp
                  Text(
                    'Updated ${DateFormatter.formatShort(page.updatedAt)} at ${DateFormatter.formatTime(page.updatedAt)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),

                  // Nested Subpages Section (if any exist)
                  if (subpages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Subpages', style: AppTypography.labelLarge),
                    const SizedBox(height: 6),
                    for (final sub in subpages)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteEditorScreen(pageId: sub.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(sub.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(sub.title, style: AppTypography.titleMedium),
                              const Spacer(),
                              const Icon(Icons.chevron_right, size: 18),
                            ],
                          ),
                        ),
                      ),
                  ],

                  const Divider(height: 24),

                  // Block list
                  for (int i = 0; i < page.blocks.length; i++)
                    BlockItemWidget(
                      key: ValueKey(page.blocks[i].id),
                      block: page.blocks[i],
                      index: i,
                      onContentChanged: (newContent) {
                        notesNotifier.updateBlockContent(page.id, page.blocks[i].id, newContent);
                      },
                      onTypeChanged: (newType) {
                        notesNotifier.setBlockType(page.id, page.blocks[i].id, newType);
                      },
                      onToggleChecklist: () {
                        notesNotifier.toggleChecklistBlock(page.id, page.blocks[i].id);
                      },
                      onDelete: () {
                        notesNotifier.removeBlock(page.id, page.blocks[i].id);
                      },
                      onAddBlockBelow: () {
                        notesNotifier.addBlock(page.id, afterIndex: i);
                      },
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Bottom Quick Block Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      SlashCommandPalette.show(context, (type) {
                        notesNotifier.addBlock(page.id, type: type);
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Block'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.check_box_outlined, size: 20),
                    tooltip: 'Checklist',
                    onPressed: () => notesNotifier.addBlock(page.id, type: BlockType.checklist),
                  ),
                  IconButton(
                    icon: const Icon(Icons.title, size: 20),
                    tooltip: 'Heading',
                    onPressed: () => notesNotifier.addBlock(page.id, type: BlockType.heading2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.code, size: 20),
                    tooltip: 'Code',
                    onPressed: () => notesNotifier.addBlock(page.id, type: BlockType.code),
                  ),
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline, size: 20),
                    tooltip: 'Callout',
                    onPressed: () => notesNotifier.addBlock(page.id, type: BlockType.callout),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
