import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/core/navigation/app_router.dart';
import 'package:merge_pdf/features/pdf_tools/utils/utils.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Rotate flow: pick a document, choose an angle, run the rotation.
final class RotateScreen extends HookConsumerWidget {
  /// Creates the rotate screen.
  const RotateScreen({super.key});

  static const int _maxFileBytes = 100 * 1024 * 1024;
  static const List<int> _angles = [90, 180, 270];

  void _showError(BuildContext context, Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.localized(context))));
  }

  Future<void> _pickFile(BuildContext context, RotateVm vm) async {
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

  Future<void> _run(BuildContext context, RotateVm vm) async {
    final result = await vm.rotate.call();
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
    final vm = ref.watch(rotateVmProvider);
    final file = useValueListenable(vm.file);
    final angle = useValueListenable(vm.angle);
    final running = useValueListenable(vm.rotate.isRunning);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainAppBar(title: context.tr('rotate.title'), onSettings: () => const SettingsRoute().push<void>(context)),
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
                            context.tr('rotate.select'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primary),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: AppDimens.recentTileHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      ),
                      child: Row(
                        children: [
                          const PdfDocBadge(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => vm.setFile(null),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('rotate.subtitle'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final value in _angles) ...[
                        _AnglePill(label: '$value°', selected: angle == value, onTap: () => vm.setAngle(value)),
                        if (value != _angles.last) const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.horizontalPadding, 8, AppDimens.horizontalPadding, 24),
              child: PrimaryButton(
                label: context.tr('rotate.action'),
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

class _AnglePill extends StatelessWidget {
  const _AnglePill({required this.label, required this.selected, required this.onTap});

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
