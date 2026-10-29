import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// One selectable page thumbnail in the split / rotate grids.
///
/// The page itself is an abstract "blueprint" (gray skeleton lines) because
/// the engine does not rasterize pages; it still mirrors the design's look.
final class PageTile extends StatelessWidget {
  /// Creates a page thumbnail.
  const PageTile({
    super.key,
    required this.number,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    this.rotated = false,
    this.rotatedDegrees = 90,
  });

  /// 1-based page number shown on the tile.
  final int number;

  /// Whether the page is part of the current selection.
  final bool selected;

  /// Called on a tap (toggles selection).
  final VoidCallback onTap;

  /// Called on a long press (opens the preview overlay).
  final VoidCallback onLongPress;

  /// When true the inner blueprint is drawn rotated (rotate screen).
  final bool rotated;

  /// Rotation applied to the blueprint when [rotated].
  final int rotatedDegrees;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    onLongPress: onLongPress,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              if (selected)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: AppColors.white),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: Center(child: _Blueprint(rotated: rotated, degrees: rotatedDegrees))),
        ],
      ),
    ),
  );
}

class _Blueprint extends StatelessWidget {
  const _Blueprint({required this.rotated, required this.degrees});

  final bool rotated;
  final int degrees;

  @override
  Widget build(BuildContext context) {
    final content = FractionallySizedBox(
      widthFactor: 0.82,
      heightFactor: 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Line(width: 1.0),
          SizedBox(height: 6),
          _Line(width: 0.72),
          SizedBox(height: 6),
          _Line(width: 1.0),
          SizedBox(height: 6),
          _Line(width: 0.55),
          SizedBox(height: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
        ],
      ),
    );
    return rotated
        ? Transform.rotate(angle: degrees * 3.141592653589793 / 180, child: content)
        : content;
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: width,
    child: Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(9999),
      ),
    ),
  );
}
