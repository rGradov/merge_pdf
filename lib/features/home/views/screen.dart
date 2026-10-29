import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/core/navigation/app_router.dart';
import 'package:merge_pdf/features/home/view_models/view_models.dart';
import 'package:merge_pdf/features/home/widgets/widgets.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Home screen: toolbox, recent files (or empty state), storage and the CTA.
final class HomeScreen extends HookConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  Future<void> _onMore(BuildContext context, WidgetRef ref, HomeVm vm, RecentFile file) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.primary),
          title: Text(context.tr('common.delete'), style: const TextStyle(color: AppColors.primary)),
          onTap: () async {
            Navigator.of(sheetContext).pop();
            await vm.remove.call(file.id);
            ref.invalidate(recentFilesProvider);
          },
        ),
      ),
    );
  }

  Future<void> _freeUpSpace(BuildContext context, WidgetRef ref, int count, int sizeBytes) async {
    final confirmed = await showFreeUpSheet(context, count: count, sizeBytes: sizeBytes);
    if (confirmed != true) return;
    await getIt.get<ClearStorageUseCase>().call();
    ref.invalidate(recentFilesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentFilesProvider);
    final vm = ref.watch(homeVmProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            MainAppBar(title: context.tr('app.title'), onSettings: () => const SettingsRoute().push<void>(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  ToolboxRow(
                    onTool: (tool) {
                      switch (tool) {
                        case ToolKind.merge:
                          unawaited(const MergeRoute().push<void>(context));
                        case ToolKind.split:
                          unawaited(const SplitRoute().push<void>(context));
                        case ToolKind.rotate:
                          unawaited(const RotateRoute().push<void>(context));
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                child: switch (recents) {
                  AsyncData(:final value) => switch (value) {
                    Success(:final value) => switch (value) {
                      HasData(:final data) => _RecentsList(
                        files: data,
                        onMore: (file) => _onMore(context, ref, vm, file),
                        onFreeUp: (count, sizeBytes) => _freeUpSpace(context, ref, count, sizeBytes),
                      ),
                      NoData() => Center(
                        child: EmptyState(
                          title: context.tr('home.empty.title'),
                          subtitle: context.tr('home.empty.subtitle'),
                        ),
                      ),
                    },
                    Failure(:final error) => Center(child: Text(error.localized(context))),
                  },
                  AsyncError() => Center(child: Text(context.tr('error.unknown'))),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.horizontalPadding, 8, AppDimens.horizontalPadding, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                label: context.tr('home.cta'),
                iconAsset: 'assets/icons/plus.svg',
                onTap: () => const MergeRoute().push<void>(context),
              ),
              const SizedBox(height: 14),
              StepRow(
                steps: [context.tr('home.step.select'), context.tr('home.step.arrange'), context.tr('home.step.merge')],
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('home.limit'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentsList extends StatelessWidget {
  const _RecentsList({required this.files, required this.onMore, required this.onFreeUp});

  final List<RecentFile> files;
  final ValueChanged<RecentFile> onMore;
  final void Function(int count, int sizeBytes) onFreeUp;

  @override
  Widget build(BuildContext context) {
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final usedMb = (totalBytes / 1024 / 1024).toStringAsFixed(1);
    return ListView(
      children: [
        SectionHeader(
          title: context.tr('home.recent'),
          trailing: context.tr('home.recent.count', namedArgs: {'n': '${files.length}'}),
        ),
        const SizedBox(height: 12),
        for (final file in files)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RecentTile(
              name: file.name,
              subtitle: recentFileMeta(context, file),
              onTap: () {},
              onMore: () => onMore(file),
            ),
          ),
        const SizedBox(height: 6),
        StorageTile(
          usedLabel: context.tr('home.storage.used', namedArgs: {'n': usedMb}),
          onFreeUp: () => onFreeUp(files.length, totalBytes),
        ),
      ],
    );
  }
}
