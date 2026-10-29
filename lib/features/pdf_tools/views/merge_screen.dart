import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/core/navigation/app_router.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/utils/utils.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Merge flow: pick files, arrange them, run the merge.
final class MergeScreen extends HookConsumerWidget {
  /// Creates the merge screen.
  const MergeScreen({super.key});

  static const int _maxFileBytes = 100 * 1024 * 1024;

  void _showError(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.localized(context))));
  }

  Future<void> _addFiles(BuildContext context, MergeVm vm) async {
    final picked = await pickPdfFiles(allowMultiple: true);
    if (!context.mounted) return;
    for (final file in picked) {
      if (file.sizeBytes > _maxFileBytes) {
        _showError(context, Exception('file_too_large'));
        continue;
      }
      vm.add(file);
    }
  }

  Future<void> _run(BuildContext context, MergeVm vm, List<PdfFile> files) async {
    final result = await vm.merge.call(files);
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        await ResultRoute($extra: [value]).push<void>(context);
      case Failure(:final error):
        _showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mergeVmProvider);
    final files = useValueListenable(vm.files);
    final running = useValueListenable(vm.merge.isRunning);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainAppBar(title: context.tr('merge.title'), onSettings: () => const SettingsRoute().push<void>(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
              child: Text(
                context.tr('merge.subtitle', args: ['${files.length}']),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: files.isEmpty
                  ? EmptyState(title: context.tr('merge.empty'), subtitle: context.tr('merge.hint'))
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                      buildDefaultDragHandles: false,
                      itemCount: files.length,
                      onReorderItem: vm.reorder,
                      itemBuilder: (context, index) => _FileTile(
                        key: ValueKey(files[index].path),
                        file: files[index],
                        index: index,
                        onRemove: () => vm.removeAt(index),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.horizontalPadding, 8, AppDimens.horizontalPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => _addFiles(context, vm),
                    child: Container(
                      height: AppDimens.recentTileHeight,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('merge.add'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: context.tr('merge.action'),
                    enabled: files.length >= 2,
                    loading: running,
                    onTap: () => _run(context, vm, files),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({super.key, required this.file, required this.index, required this.onRemove});

  final PdfFile file;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sizeMb = (file.sizeBytes / 1024 / 1024).toStringAsFixed(1);
    final meta = context.tr('file.size', args: [sizeMb]);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: AppDimens.recentTileHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            const PdfDocBadge(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_indicator, size: 20, color: AppColors.textHint),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
