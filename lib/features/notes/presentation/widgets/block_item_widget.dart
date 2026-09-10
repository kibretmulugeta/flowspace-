import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/editor_block_model.dart';
import 'slash_command_palette.dart';

class BlockItemWidget extends StatefulWidget {
  final EditorBlock block;
  final int index;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<BlockType> onTypeChanged;
  final VoidCallback onToggleChecklist;
  final VoidCallback onDelete;
  final VoidCallback onAddBlockBelow;

  const BlockItemWidget({
    super.key,
    required this.block,
    required this.index,
    required this.onContentChanged,
    required this.onTypeChanged,
    required this.onToggleChecklist,
    required this.onDelete,
    required this.onAddBlockBelow,
  });

  @override
  State<BlockItemWidget> createState() => _BlockItemWidgetState();
}

class _BlockItemWidgetState extends State<BlockItemWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
  }

  @override
  void didUpdateWidget(covariant BlockItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content &&
        _controller.text != widget.block.content) {
      _controller.text = widget.block.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange(String text) {
    // Markdown-style shortcuts
    if (text == '# ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.heading1);
      return;
    }
    if (text == '## ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.heading2);
      return;
    }
    if (text == '### ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.heading3);
      return;
    }
    if (text == '[] ' || text == '- [ ] ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.checklist);
      return;
    }
    if (text == '- ' || text == '* ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.bulletList);
      return;
    }
    if (text == '1. ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.numberedList);
      return;
    }
    if (text == '> ') {
      _controller.clear();
      widget.onTypeChanged(BlockType.quote);
      return;
    }

    // Slash command trigger
    if (text == '/') {
      SlashCommandPalette.show(context, (newType) {
        _controller.clear();
        widget.onTypeChanged(newType);
      });
      return;
    }

    widget.onContentChanged(text);
  }

  void _showBlockOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Transform block type'),
                onTap: () {
                  Navigator.of(context).pop();
                  SlashCommandPalette.show(context, widget.onTypeChanged);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Insert block below'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onAddBlockBelow();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.priorityUrgent),
                title: const Text('Delete block', style: TextStyle(color: AppColors.priorityUrgent)),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle & options button
          GestureDetector(
            onTap: _showBlockOptionsMenu,
            child: Container(
              width: 24,
              height: 28,
              alignment: Alignment.center,
              child: Icon(
                Icons.drag_indicator,
                size: 16,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Render block content by type
          Expanded(
            child: _buildBlockBody(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockBody(BuildContext context, bool isDark) {
    switch (widget.block.type) {
      case BlockType.text:
        return TextField(
          controller: _controller,
          onChanged: _handleTextChange,
          maxLines: null,
          style: AppTypography.blockBody.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            hintText: "Type '/' for commands...",
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        );

      case BlockType.heading1:
        return TextField(
          controller: _controller,
          onChanged: _handleTextChange,
          maxLines: null,
          style: AppTypography.blockH1.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Heading 1',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        );

      case BlockType.heading2:
        return TextField(
          controller: _controller,
          onChanged: _handleTextChange,
          maxLines: null,
          style: AppTypography.blockH2.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Heading 2',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        );

      case BlockType.heading3:
        return TextField(
          controller: _controller,
          onChanged: _handleTextChange,
          maxLines: null,
          style: AppTypography.blockH3.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Heading 3',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        );

      case BlockType.checklist:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onToggleChecklist,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Icon(
                  widget.block.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: widget.block.isChecked
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _handleTextChange,
                maxLines: null,
                style: AppTypography.blockBody.copyWith(
                  color: widget.block.isChecked
                      ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  decoration: widget.block.isChecked ? TextDecoration.lineThrough : null,
                ),
                decoration: const InputDecoration(
                  hintText: 'To-do',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        );

      case BlockType.bulletList:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 10, left: 4),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _handleTextChange,
                maxLines: null,
                style: AppTypography.blockBody.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        );

      case BlockType.numberedList:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Text(
                '${widget.index + 1}.',
                style: AppTypography.blockBody.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _handleTextChange,
                maxLines: null,
                style: AppTypography.blockBody.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        );

      case BlockType.quote:
        return Container(
          padding: const EdgeInsets.only(left: 14, top: 4, bottom: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
            ),
          ),
          child: TextField(
            controller: _controller,
            onChanged: _handleTextChange,
            maxLines: null,
            style: AppTypography.blockBody.copyWith(
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            decoration: const InputDecoration(
              hintText: 'Empty quote...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        );

      case BlockType.callout:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.block.calloutIcon ?? '💡',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _handleTextChange,
                  maxLines: null,
                  style: AppTypography.blockBody,
                  decoration: const InputDecoration(
                    hintText: 'Callout content...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        );

      case BlockType.code:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.block.codeLanguage ?? 'dart',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const Icon(Icons.copy, size: 14),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                onChanged: _handleTextChange,
                maxLines: null,
                style: AppTypography.blockCode.copyWith(
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                ),
                decoration: const InputDecoration(
                  hintText: '// Paste or write code...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ],
          ),
        );

      case BlockType.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(thickness: 1.5),
        );

      case BlockType.table:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.table_chart_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text('Table Block', style: AppTypography.labelSmall),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                onChanged: _handleTextChange,
                style: AppTypography.bodySmall,
                decoration: const InputDecoration(
                  hintText: 'Enter table data (e.g. Item 1 | Value 1)...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ],
          ),
        );

      case BlockType.image:
      case BlockType.link:
        return TextField(
          controller: _controller,
          onChanged: _handleTextChange,
          style: AppTypography.blockBody,
          decoration: InputDecoration(
            hintText: 'Paste web URL or markdown link...',
            prefixIcon: const Icon(Icons.link, size: 18),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        );
    }
  }
}
