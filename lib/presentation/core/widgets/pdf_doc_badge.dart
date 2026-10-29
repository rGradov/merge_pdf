import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// White mini page preview with gray text lines and a red PDF chip.
final class PdfDocBadge extends StatelessWidget {
  /// Creates the mini page badge.
  const PdfDocBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 56,
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Line(width: double.infinity),
            SizedBox(height: 4),
            _Line(width: 22.5),
            SizedBox(height: 4),
            _Line(width: 15),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(color: AppColors.badgeBackground, borderRadius: BorderRadius.circular(3)),
          child: const Text(
            'PDF',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.primary, height: 1),
          ),
        ),
      ],
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 2,
    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)),
  );
}
