import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// Section title row: bold title on the left, muted counter on the right.
final class SectionHeader extends StatelessWidget {
  /// Creates the section title row.
  const SectionHeader({super.key, required this.title, required this.trailing});

  /// Section title.
  final String title;

  /// Muted trailing text, e.g. a file counter.
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      const Spacer(),
      Text(
        trailing,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textHint),
      ),
    ],
  );
}
