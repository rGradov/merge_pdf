import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Settings: storage summary and the "free up space" action.
final class SettingsScreen extends HookConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  Future<void> _freeUpSpace(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(context.tr('home.storage.free')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              context.tr('common.delete'),
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await getIt.get<ClearStorageUseCase>().call();
    ref.invalidate(recentFilesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentFilesProvider);
    final usedMb = switch (recents) {
      AsyncData(:final value) => switch (value) {
        Success(:final value) => switch (value) {
          HasData(:final data) =>
            (data.fold<int>(0, (sum, file) => sum + file.sizeBytes) /
                    1024 /
                    1024)
                .toStringAsFixed(1),
          NoData() => '0.0',
        },
        Failure() => '0.0',
      },
      _ => '0.0',
    };
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainAppBar(
              title: context.tr('settings.title'),
              onSettings: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.horizontalPadding,
              ),
              child: StorageTile(
                usedLabel: context.tr(
                  'home.storage.used',
                  namedArgs: {'n': usedMb},
                ),
                onFreeUp: () => _freeUpSpace(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
