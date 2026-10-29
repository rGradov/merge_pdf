import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/core/widgets/pdf_page_image.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// One selectable page thumbnail in the split / rotate grids, rendering the
/// real page content with the page number overlaid on top.
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PdfPageImage(path: path, page: page, maxDim: 220),
            Positioned(
              top: 6,
              right: 6,
              child: selected
                  ? Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 12, color: AppColors.white),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xB3FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$number',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
