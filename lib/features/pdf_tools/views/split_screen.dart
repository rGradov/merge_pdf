import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/core/navigation/app_router.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/features/pdf_tools/utils/utils.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Split flow: pick a document, choose a strategy, run the split.
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

  Future<void> _run(BuildContext context, SplitVm vm) async {
    final result = await vm.split.call();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        await ResultRoute($extra: value).push<void>(context);
      case Failure(:final error):
        _showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(splitVmProvider);
    final file = useValueListenable(vm.file);
    final mode = useValueListenable(vm.mode);
    final running = useValueListenable(vm.split.isRunning);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainAppBar(title: context.tr('split.title'), onSettings: () => const SettingsRoute().push<void>(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (file == null)
                    GestureDetector(
                      onTap: () => _pickFile(context, vm),
                      child: Container(
                        height: AppDimens.recentTileHeight,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                        ),
                        child: Center(
                          child: Text(
                            context.tr('split.select'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primary),
                          ),
                        ),
                      ),
                    )
                  else
                    _SelectedFileTile(
                      file: file,
                      pages: ref.watch(pdfPagesProvider(file.path)),
                      onClear: () => vm.setFile(null),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _ModePill(
                        label: context.tr('split.mode.all'),
                        selected: mode == SplitMode.everyPage,
                        onTap: () => vm.setMode(SplitMode.everyPage),
                      ),
                      const SizedBox(width: 12),
                      _ModePill(
                        label: context.tr('split.mode.ranges'),
                        selected: mode == SplitMode.ranges,
                        onTap: () => vm.setMode(SplitMode.ranges),
                      ),
                    ],
                  ),
                  if (mode == SplitMode.ranges) ...[
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: vm.setRanges,
                      style: const TextStyle(fontSize: 15, color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: context.tr('split.ranges.hint'),
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.horizontalPadding, 8, AppDimens.horizontalPadding, 24),
              child: PrimaryButton(
                label: context.tr('split.action'),
                enabled: file != null,
                loading: running,
                onTap: () => _run(context, vm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedFileTile extends StatelessWidget {
  const _SelectedFileTile({required this.file, required this.pages, required this.onClear});

  final PdfFile file;
  final AsyncValue<Result<int>> pages;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final pagesText = switch (pages) {
      AsyncData(:final value) => switch (value) {
        Success(:final value) => context.tr('split.subtitle', namedArgs: {'n': '$value'}),
        Failure() => '',
      },
      _ => '',
    };
    return Container(
      height: AppDimens.recentTileHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
      child: Row(
        children: [
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
                if (pagesText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    pagesText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.text,
          ),
        ),
      ),
    ),
  );
}
