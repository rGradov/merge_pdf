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

/// Split flow: pick a document, select pages, split or extract.
final class SplitScreen extends HookConsumerWidget {
  /// Creates the split screen.
  const SplitScreen({super.key});

  static const int _maxFileBytes = 100 * 1024 * 1024;

  void _showError(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.localized(context))));
  }

  Future<void> _pickFile(BuildContext context, SplitVm vm) async {
    final picked = await pickPdfFiles();
    if (!context.mounted) return;
    if (picked.isEmpty) return;
    final file = picked.first;
    if (file.sizeBytes > _maxFileBytes) {
      _showError(context, Exception('file_too_large'));
      return;
    }
    vm.setFile(file);
  }

  Future<void> _run(BuildContext context, WidgetRef ref, SplitVm vm, int selectedCount) async {
    final result = await vm.split.call();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        ref.invalidate(recentFilesProvider);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(results: value, sourceCount: selectedCount)),
        );
      case Failure(:final error):
        _showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(splitVmProvider);
    final file = useValueListenable(vm.file);
    final mode = useValueListenable(vm.mode);
    final selected = useValueListenable(vm.selected);
    final running = useValueListenable(vm.split.isRunning);

    final pagesValue = file == null ? null : ref.watch(pdfPagesProvider(file.path));
    final pageCount = pagesValue?.value?.valueOrNull ?? 0;

    useEffect(() {
      final current = file;
      if (current != null && pageCount > 0) vm.ensureInitialized(current.path, pageCount);
      return null;
    }, [file?.path, pageCount]);

    final selectedCount = selected.length;
    final total = pageCount;

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
                  ? _EmptyPicker(onPick: () => _pickFile(context, vm), label: context.tr('split.select'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SourceRow(fileName: file.name),
                          const SizedBox(height: 12),
                          _SegmentedControl(
                            left: context.tr('split.mode.separate'),
                            right: context.tr('split.mode.extract'),
                            isRight: mode == SplitSelectionMode.extract,
                            onSelectLeft: () => vm.setMode(SplitSelectionMode.separate),
                            onSelectRight: () => vm.setMode(SplitSelectionMode.extract),
                          ),
                          const SizedBox(height: 16),
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
                                      number: index + 1,
                                      selected: selected.contains(index),
                                      onTap: () => vm.toggle(index),
                                      onLongPress: () => showPagePreview(context, page: index + 1, total: pageCount),
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
                total: total,
                sizeBytes: file.sizeBytes,
                extract: mode == SplitSelectionMode.extract,
                running: running,
                onRun: () => _run(context, ref, vm, selectedCount),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker({required this.onPick, required this.label});

  final VoidCallback onPick;
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      child: GestureDetector(
        onTap: onPick,
        child: Container(
          height: AppDimens.ctaHeight,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD6D6DB)),
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          ),
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ),
        ),
      ),
    ),
  );
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

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.left,
    required this.right,
    required this.isRight,
    required this.onSelectLeft,
    required this.onSelectRight,
  });

  final String left;
  final String right;
  final bool isRight;
  final VoidCallback onSelectLeft;
  final VoidCallback onSelectRight;

  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEF),
      borderRadius: BorderRadius.circular(9999),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSelectLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isRight ? Colors.transparent : AppColors.white,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: isRight
                    ? null
                    : const [BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1))],
              ),
              child: Text(
                left,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isRight ? AppColors.textSecondary : AppColors.text,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onSelectRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isRight ? AppColors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: isRight
                    ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1))]
                    : null,
              ),
              child: Text(
                right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isRight ? AppColors.text : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SplitSummaryBar extends StatelessWidget {
  const _SplitSummaryBar({
    required this.selectedCount,
    required this.total,
    required this.sizeBytes,
    required this.extract,
    required this.running,
    required this.onRun,
  });

  final int selectedCount;
  final int total;
  final int sizeBytes;
  final bool extract;
  final bool running;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final action = extract
        ? context.tr('split.extractAction', namedArgs: {'n': '$selectedCount'})
        : context.tr('split.separateAction', namedArgs: {'n': '$selectedCount'});
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
                  context.tr('split.selected', namedArgs: {'sel': '$selectedCount', 'total': '$total'}),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('split.selectedMeta', namedArgs: {'pages': '$selectedCount', 'size': formatBytes(context, sizeBytes)}),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: running ? null : onRun,
            child: Opacity(
              opacity: running ? 0.7 : 1,
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
    );
  }
}
