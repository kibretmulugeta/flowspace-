import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/editor_block_model.dart';

class SlashCommandPalette extends StatefulWidget {
  final ValueChanged<BlockType> onSelectBlockType;

  const SlashCommandPalette({super.key, required this.onSelectBlockType});

  static void show(BuildContext context, ValueChanged<BlockType> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SlashCommandPalette(onSelectBlockType: onSelect),
    );
  }

  @override
  State<SlashCommandPalette> createState() => _SlashCommandPaletteState();
}

class _SlashCommandPaletteState extends State<SlashCommandPalette> {
  final TextEditingController _filterController = TextEditingController();
  String _filter = '';

  final List<({BlockType type, IconData icon, String title, String subtitle})> _commands = const [
    (
      type: BlockType.text,
      icon: Icons.notes,
      title: 'Text',
      subtitle: 'Just start writing with plain text.',
    ),
    (
      type: BlockType.heading1,
      icon: Icons.title,
      title: 'Heading 1',
      subtitle: 'Big section heading.',
    ),
    (
      type: BlockType.heading2,
      icon: Icons.format_size,
      title: 'Heading 2',
      subtitle: 'Medium section heading.',
    ),
    (
      type: BlockType.heading3,
      icon: Icons.text_fields,
      title: 'Heading 3',
      subtitle: 'Small section heading.',
    ),
    (
      type: BlockType.checklist,
      icon: Icons.check_box_outlined,
      title: 'To-do list',
      subtitle: 'Track tasks with a checklist.',
    ),
    (
      type: BlockType.bulletList,
      icon: Icons.format_list_bulleted,
      title: 'Bulleted list',
      subtitle: 'Create a simple bulleted list.',
    ),
    (
      type: BlockType.numberedList,
      icon: Icons.format_list_numbered,
      title: 'Numbered list',
      subtitle: 'Create a numbered list.',
    ),
    (
      type: BlockType.quote,
      icon: Icons.format_quote,
      title: 'Quote',
      subtitle: 'Capture a quote or key takeaway.',
    ),
    (
      type: BlockType.callout,
      icon: Icons.lightbulb_outline,
      title: 'Callout',
      subtitle: 'Highlight important insight in a box.',
    ),
    (
      type: BlockType.code,
      icon: Icons.code,
      title: 'Code',
      subtitle: 'Syntax block with code snippet.',
    ),
    (
      type: BlockType.divider,
      icon: Icons.horizontal_rule,
      title: 'Divider',
      subtitle: 'Visually divide blocks.',
    ),
    (
      type: BlockType.table,
      icon: Icons.table_chart_outlined,
      title: 'Table',
      subtitle: 'Simple data table grid.',
    ),
  ];

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _commands.where((cmd) {
      if (_filter.isEmpty) return true;
      final q = _filter.toLowerCase();
      return cmd.title.toLowerCase().contains(q) ||
          cmd.subtitle.toLowerCase().contains(q) ||
          cmd.type.slashCommand.contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
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
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _filterController,
            autofocus: true,
            onChanged: (val) => setState(() => _filter = val),
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: 'Filter blocks or type command...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _filterController.clear();
                        setState(() => _filter = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),

          // List of commands
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cmd = filtered[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelectBlockType(cmd.type);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Icon(cmd.icon, size: 20, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cmd.title, style: AppTypography.titleMedium),
                              Text(
                                cmd.subtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          cmd.type.slashCommand,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
