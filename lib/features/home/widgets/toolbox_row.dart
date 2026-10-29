import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';

/// The Merge / Split / Rotate toolbox row on the home screen.
final class ToolboxRow extends StatelessWidget {
  /// Creates the toolbox row.
  const ToolboxRow({super.key, required this.onTool});

  /// Called with the tapped tool.
  final ValueChanged<ToolKind> onTool;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ToolCard(
        icon: 'assets/icons/merge.svg',
        iconSize: const Size(20, 20),
        label: context.tr('toolbox.merge'),
        onTap: () => onTool(ToolKind.merge),
      ),
      const SizedBox(width: 12),
      ToolCard(
        icon: 'assets/icons/split.svg',
        iconSize: const Size(20, 20),
        label: context.tr('toolbox.split'),
        onTap: () => onTool(ToolKind.split),
      ),
      const SizedBox(width: 12),
      ToolCard(
        icon: 'assets/icons/rotate.svg',
        iconSize: const Size(17.95, 20.95),
        label: context.tr('toolbox.rotate'),
        onTap: () => onTool(ToolKind.rotate),
      ),
    ],
  );
}
