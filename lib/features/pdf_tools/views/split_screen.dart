import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/utils/utils.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/features/pdf_tools/views/result_screen.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Split flow: pick a document, select pages to extract, optionally also save
/// the unselected pages as a second PDF.
final class SplitScreen extends HookConsumerWidget {
  /// Creates the split screen.
  const SplitScreen({super.key});

  static const int _maxFileBytes = 100 * 1024 * 1024;

  void _showError(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.localized(context))));
  }

  Future<bool> _pickFile(BuildContext context, SplitVm vm) async {
    final picked = await pickPdfFiles();
    if (!context.mounted) return false;
    if (picked.isEmpty) return false;
    final file = picked.first;
    if (file.sizeBytes > _maxFileBytes) {
      _showError(context, Exception('file_too_large'));
      return false;
    }
    vm.setFile(file);
    return true;
  }

  Future<void> _run(BuildContext context, WidgetRef ref, SplitVm vm) async {
    final result = await vm.split.call();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        ref.invalidate(recentFilesProvider);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(results: value, sourceCount: value.length)),
        );
      case Failure(:final error):
        _showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(splitVmProvider);
    final file = useValueListenable(vm.file);
    final selected = useValueListenable(vm.selected);
    final saveUnselected = useValueListenable(vm.saveUnselected);
    final running = useValueListenable(vm.split.isRunning);

    final pagesValue = file == null ? null : ref.watch(pdfPagesProvider(file.path));
    final pageCount = pagesValue?.value?.valueOrNull ?? 0;

    // Pick the source document immediately instead of showing a separate
    // "select a PDF" screen. Cancelling returns to the previous screen.
    useEffect(() {
      if (vm.file.value == null) {
        unawaited(
          _pickFile(context, vm).then((picked) {
            if (!picked && context.mounted) Navigator.of(context).maybePop();
          }),
        );
      }
      return null;
    }, const []);

    final selectedCount = selected.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAppBar(
              title: context.tr('split.title'),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: file == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SourceRow(fileName: file.name),
                          const SizedBox(height: 12),
                          Expanded(
                            child: pageCount == 0
                                ? const Center(child: CircularProgressIndicator())
                                : GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: pageCount,
                                    itemBuilder: (context, index) => PageTile(
                                      path: file.path,
                                      page: index,
                                      number: index + 1,
                                      selected: selected.contains(index),
                                      onTap: () => vm.toggle(index),
                                      onLongPress: () => showPdfPreview(context, path: file.path, page: index, total: pageCount),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (file != null)
              _SplitSummaryBar(
                selectedCount: selectedCount,
                total: pageCount,
                saveUnselected: saveUnselected,
                running: running,
                onToggleUnselected: (value) => vm.saveUnselected.value = value,
                onRun: () => _run(context, ref, vm),
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(color: Color(0x1AB90D10), borderRadius: BorderRadius.all(Radius.circular(2))),
        child: const Icon(Icons.description, size: 11, color: AppColors.primary),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}

class _SplitSummaryBar extends StatelessWidget {
  const _SplitSummaryBar({
    required this.selectedCount,
    required this.total,
    required this.saveUnselected,
    required this.running,
    required this.onToggleUnselected,
    required this.onRun,
  });

  final int selectedCount;
  final int total;
  final bool saveUnselected;
  final bool running;
  final ValueChanged<bool> onToggleUnselected;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final action = context.tr('split.extractAction', namedArgs: {'n': '$selectedCount'});
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('split.saveUnselected'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text),
                ),
              ),
              Switch(
                value: saveUnselected,
                activeThumbColor: AppColors.primary,
                onChanged: onToggleUnselected,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr('split.selected', namedArgs: {'sel': '$selectedCount', 'total': '$total'}),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('split.hint'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: running || selectedCount == 0 ? null : onRun,
                child: Opacity(
                  opacity: selectedCount == 0 ? 0.5 : 1,
                  child: Container(
                    height: AppDimens.ctaHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(color: const Color(0xFFDE2E27), borderRadius: BorderRadius.circular(9999)),
                    child: Center(
                      child: running
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                          : Text(action, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
