import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// The three-step hint under the CTA: numbered circles joined by dividers.
final class StepRow extends StatelessWidget {
  /// Creates the numbered steps row.
  const StepRow({super.key, required this.steps});

  /// Step labels in order, e.g. Select → Arrange → Merge.
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      if (i > 0) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
        );
      }
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
              child: Text(
                '${i + 1}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              steps[i],
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return Row(children: children);
  }
}
