import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/utils/utils.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/features/pdf_tools/views/merge_trim_screen.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Merge workspace: pick files, arrange them, then continue to page trimming.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mergeVmProvider);
    final files = useValueListenable(vm.files);
    final pageCounts = <String, AsyncValue<Result<int>>>{
      for (final file in files) file.path: ref.watch(pdfPagesProvider(file.path)),
    };
    final totalPages = pageCounts.values.fold<int>(
      0,
      (sum, value) => sum + (value.value?.valueOrNull ?? 0),
    );
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAppBar(
              title: context.tr('merge.title'),
              titleSize: 28,
              onBack: () => Navigator.of(context).maybePop(),
              trailing: files.isEmpty
                  ? null
                  : GestureDetector(
                      onTap: vm.clear,
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: Icon(Icons.delete_outline, size: 22, color: AppColors.textSecondary)),
                      ),
                    ),
            ),
            Expanded(
              child: files.isEmpty
                  ? Center(
                      child: EmptyState(
                        title: context.tr('home.empty.title'),
                        subtitle: context.tr('home.empty.subtitle'),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding, vertical: 16),
                      buildDefaultDragHandles: false,
                      itemCount: files.length,
                      onReorderItem: vm.reorder,
                      itemBuilder: (context, index) => _MergeFileTile(
                        key: ValueKey(files[index].path),
                        file: files[index],
                        index: index,
                        pages: pageCounts[files[index].path],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
              child: GestureDetector(
                onTap: () => _addFiles(context, vm),
                child: Container(
                  height: AppDimens.ctaHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD6D6DB)),
                    borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('merge.add'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _MergeSummaryBar(
              fileCount: files.length,
              pageCount: totalPages,
              sizeBytes: totalBytes,
              enabled: files.length >= 2,
              onMerge: () => unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => MergeTrimScreen(files: files)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeFileTile extends StatelessWidget {
  const _MergeFileTile({super.key, required this.file, required this.index, required this.pages});

  final PdfFile file;
  final int index;
  final AsyncValue<Result<int>>? pages;

  @override
  Widget build(BuildContext context) {
    final pageText = switch (pages) {
      AsyncData(:final value) => switch (value) {
        Success(:final value) => context.tr('file.pages', namedArgs: {'n': '$value'}),
        Failure() => null,
      },
      _ => null,
    };
    final pageCount = switch (pages) {
      AsyncData(:final value) => value.valueOrNull ?? 0,
      _ => 0,
    };
    final meta = pageText == null
        ? formatBytes(context, file.sizeBytes)
        : '$pageText · ${formatBytes(context, file.sizeBytes)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showPagePreview(context, page: 1, total: pageCount == 0 ? 1 : pageCount),
        onLongPress: () => showPagePreview(context, page: 1, total: pageCount == 0 ? 1 : pageCount),
        behavior: HitTestBehavior.opaque,
        child: Container(
        height: AppDimens.recentTileHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
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
          ],
        ),
        ),
      ),
    );
  }
}

class _MergeSummaryBar extends StatelessWidget {
  const _MergeSummaryBar({
    required this.fileCount,
    required this.pageCount,
    required this.sizeBytes,
    required this.enabled,
    required this.onMerge,
  });

  final int fileCount;
  final int pageCount;
  final int sizeBytes;
  final bool enabled;
  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    final summary = context.tr(
      'merge.filesPages',
      namedArgs: {'files': '$fileCount', 'pages': '$pageCount'},
    );
    final total = context.tr('merge.totalSize', namedArgs: {'n': formatBytes(context, sizeBytes)});
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  summary,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  total,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: enabled ? onMerge : null,
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: Container(
                height: AppDimens.ctaHeight,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call_merge, size: 20, color: AppColors.white),
                    SizedBox(width: 8),
                    Text(
                      'Merge PDF',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
