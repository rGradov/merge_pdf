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

/// Rotate flow: pick a document, select pages, choose a direction, rotate.
final class RotateScreen extends HookConsumerWidget {
  /// Creates the rotate screen.
  const RotateScreen({super.key});

  static const int _maxFileBytes = 100 * 1024 * 1024;

  void _showError(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.localized(context))));
  }

  Future<bool> _pickFile(BuildContext context, RotateVm vm) async {
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

  Future<void> _run(BuildContext context, WidgetRef ref, RotateVm vm) async {
    final result = await vm.rotate.call();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        ref.invalidate(recentFilesProvider);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(results: [value], sourceCount: value.pages)),
        );
      case Failure(:final error):
        _showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(rotateVmProvider);
    final file = useValueListenable(vm.file);
    final direction = useValueListenable(vm.direction);
    final selected = useValueListenable(vm.selected);
    final running = useValueListenable(vm.rotate.isRunning);

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
    final dirLabel = direction == RotateDirection.clockwise
        ? context.tr('rotate.direction.cw')
        : context.tr('rotate.direction.ccw');

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAppBar(
              title: context.tr('rotate.title'),
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
                          const SizedBox(height: 16),
                          _DirectionControl(
                            isRight: direction == RotateDirection.clockwise,
                            onSelectLeft: () => vm.setDirection(RotateDirection.counterClockwise),
                            onSelectRight: () => vm.setDirection(RotateDirection.clockwise),
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
                                      childAspectRatio: 0.76,
                                    ),
                                    itemCount: pageCount,
                                    itemBuilder: (context, index) => PageTile(
                                      number: index + 1,
                                      selected: selected.contains(index),
                                      rotated: selected.contains(index),
                                      onTap: () => vm.toggle(index),
                                      onLongPress: () => showPdfPreview(context, path: file.path, page: index, total: pageCount),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                context.tr('file.pages', namedArgs: {'n': '$pageCount'}).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.28,
                                  color: Color(0xB35F5E60),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (file != null)
              _RotateSummaryBar(
                selectedCount: selectedCount,
                total: pageCount,
                dirLabel: dirLabel,
                running: running,
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(
      children: [
        const Icon(Icons.description, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

class _DirectionControl extends StatelessWidget {
  const _DirectionControl({
    required this.isRight,
    required this.onSelectLeft,
    required this.onSelectRight,
  });

  final bool isRight;
  final VoidCallback onSelectLeft;
  final VoidCallback onSelectRight;

  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F3F4),
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('↺', style: TextStyle(fontSize: 14, color: isRight ? AppColors.textSecondary : AppColors.text)),
                  const SizedBox(width: 4),
                  Text('90°', style: TextStyle(fontSize: 15, fontWeight: isRight ? FontWeight.w500 : FontWeight.w600, color: isRight ? AppColors.textSecondary : AppColors.text)),
                ],
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
                boxShadow: isRight ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1))] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('↻', style: TextStyle(fontSize: 14, fontWeight: isRight ? FontWeight.w700 : FontWeight.w400, color: isRight ? AppColors.text : AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Text('90°', style: TextStyle(fontSize: 15, fontWeight: isRight ? FontWeight.w600 : FontWeight.w500, color: isRight ? AppColors.text : AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RotateSummaryBar extends StatelessWidget {
  const _RotateSummaryBar({
    required this.selectedCount,
    required this.total,
    required this.dirLabel,
    required this.running,
    required this.onRun,
  });

  final int selectedCount;
  final int total;
  final String dirLabel;
  final bool running;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) => Container(
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
                context.tr('rotate.selected', namedArgs: {'sel': '$selectedCount', 'total': '$total'}),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
              ),
              const SizedBox(height: 2),
              Text(
                dirLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
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
              decoration: BoxDecoration(color: const Color(0xFFB90D10), borderRadius: BorderRadius.circular(9999)),
              child: Center(
                child: running
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                    : Text(
                        context.tr('rotate.action', namedArgs: {'n': '$selectedCount'}),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
                      ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
