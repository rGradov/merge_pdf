import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// Stacked-pages illustration with the empty-state copy.
final class EmptyState extends StatelessWidget {
  /// Creates the empty-state block.
  const EmptyState({super.key, required this.title, required this.subtitle});

  /// Heading, e.g. "No files yet".
  final String title;

  /// Supporting text, e.g. "Add two or more PDFs...".
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 180,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(angle: -7 * math.pi / 180, child: const _PageSheet()),
            Transform.rotate(angle: 4 * math.pi / 180, child: const _PageSheet()),
            const _PageSheet(withLines: true),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 26),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  height: 28 / 22,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 22 / 15,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _PageSheet extends StatelessWidget {
  const _PageSheet({this.withLines = false});

  final bool withLines;

  @override
  Widget build(BuildContext context) => Container(
    width: 112,
    height: 144,
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppDimens.radiusPage),
    ),
    child: withLines
        ? const Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetLine(width: 64),
                SizedBox(height: 10),
                _SheetLine(width: 80),
                SizedBox(height: 10),
                _SheetLine(width: 56),
                SizedBox(height: 10),
                _SheetLine(width: double.infinity),
              ],
            ),
          )
        : null,
  );
}

class _SheetLine extends StatelessWidget {
  const _SheetLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 5,
    decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(9999)),
  );
}
