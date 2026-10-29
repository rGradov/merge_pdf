import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/home/views/logs_screen.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Settings: storage summary and app about rows.
final class SettingsScreen extends HookConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  Future<void> _freeUpSpace(BuildContext context, WidgetRef ref, int count, int sizeBytes) async {
    final confirmed = await showFreeUpSheet(context, count: count, sizeBytes: sizeBytes);
    if (confirmed != true) return;
    await getIt.get<ClearStorageUseCase>().call();
    ref.invalidate(recentFilesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentFilesProvider);
    final versionTaps = useState(0);
    final files = switch (recents) {
      AsyncData(:final value) => switch (value) {
        Success(:final value) => switch (value) {
          HasData(:final data) => data,
          NoData() => const <RecentFile>[],
        },
        Failure() => const <RecentFile>[],
      },
      _ => const <RecentFile>[],
    };
    final count = files.length;
    final sizeBytes = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAppBar(
              title: context.tr('settings.title'),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                children: [
                  const SizedBox(height: 12),
                  _SectionCaption(text: context.tr('settings.caption.storage')),
                  const SizedBox(height: 8),
                  _GroupCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.description,
                        label: context.tr('settings.exportedFiles'),
                        trailing: formatBytes(context, sizeBytes),
                        onTap: () {},
                      ),
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      _SettingsRow(
                        label: context.tr('home.storage.free'),
                        labelColor: AppColors.primary,
                        onTap: () => _freeUpSpace(context, ref, count, sizeBytes),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionCaption(text: context.tr('settings.caption.about')),
                  const SizedBox(height: 8),
                  _GroupCard(
                    children: [
                      _SettingsRow(icon: Icons.star_border, label: context.tr('settings.rate'), onTap: () {}),
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      _SettingsRow(icon: Icons.ios_share, label: context.tr('settings.shareApp'), onTap: () {}),
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      _SettingsRow(icon: Icons.headset_mic, label: context.tr('settings.support'), onTap: () {}),
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      _SettingsRow(icon: Icons.lock_outline, label: context.tr('settings.privacy'), onTap: () {}),
                      const Divider(height: 1, thickness: 1, color: AppColors.border),
                      _SettingsRow(icon: Icons.description, label: context.tr('settings.terms'), onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      versionTaps.value++;
                      if (versionTaps.value >= 5) {
                        versionTaps.value = 0;
                        if (kDebugMode) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const LogsScreen()),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        context.tr('settings.version'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCaption extends StatelessWidget {
  const _SectionCaption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      color: AppColors.textHint,
    ),
  );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    required this.label,
    this.trailing,
    this.labelColor = AppColors.text,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final String? trailing;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: icon == null ? FontWeight.w600 : FontWeight.w400, color: labelColor),
              ),
            ),
            if (trailing != null) ...[
              Text(trailing!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
            ],
            if (icon != null || trailing != null) const Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    ),
  );
}
