import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/core/widgets/primary_button.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Shows the small "Delete exported files?" confirmation sheet.
///
/// Returns `true` when the user confirms deletion, `false`/`null` otherwise.
Future<bool?> showFreeUpSheet(
  BuildContext context, {
  required int count,
  required int sizeBytes,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _FreeUpSheet(count: count, sizeBytes: sizeBytes),
  );
}

class _FreeUpSheet extends StatelessWidget {
  const _FreeUpSheet({required this.count, required this.sizeBytes});

  final int count;
  final int sizeBytes;

  @override
  Widget build(BuildContext context) {
    final sizeLabel = formatBytes(context, sizeBytes);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, size: 20, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('freeup.title'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('freeup.body', namedArgs: {'count': '$count', 'size': sizeLabel}),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 22 / 15),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: context.tr('freeup.confirm', namedArgs: {'n': '$count'}),
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size.fromHeight(AppDimens.ctaHeight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
              child: Text(
                context.tr('common.cancel'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
