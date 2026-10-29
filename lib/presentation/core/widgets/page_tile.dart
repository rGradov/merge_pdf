import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/core/widgets/pdf_page_image.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// One selectable page thumbnail in the split / rotate grids, rendering the
/// real page content.
final class PageTile extends StatelessWidget {
  /// Creates a page thumbnail.
  const PageTile({
    super.key,
    required this.path,
    required this.page,
    required this.number,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  /// Absolute path to the source PDF.
  final String path;

  /// 0-based page index.
  final int page;

  /// 1-based page number shown on the tile.
  final int number;

  /// Whether the page is part of the current selection.
  final bool selected;

  /// Called on a tap (toggles selection).
  final VoidCallback onTap;

  /// Called on a long press (opens the preview overlay).
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    onLongPress: onLongPress,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (selected)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 12, color: AppColors.white),
                )
              else
                Text(
                  '$number',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: PdfPageImage(path: path, page: page, maxDim: 220),
            ),
          ),
        ],
      ),
    ),
  );
}
