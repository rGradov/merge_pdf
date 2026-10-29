import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// Storage summary tile: icon, usage text and a red "free up" action.
final class StorageTile extends StatelessWidget {
  /// Creates the storage summary tile.
  const StorageTile({super.key, required this.usedLabel, required this.onFreeUp});

  /// Localized usage line, e.g. "14.4 MB used".
  final String usedLabel;

  /// Called when "Free up space" is tapped.
  final VoidCallback onFreeUp;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Center(child: SvgPicture.asset('assets/icons/storage.svg', width: 15, height: 13.3)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('home.storage'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            Text(
              usedLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onFreeUp,
          child: Text(
            context.tr('home.storage.free'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
      ],
    ),
  );
}
