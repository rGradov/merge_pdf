import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:open_filex/open_filex.dart';

/// Success screen: produced files with share / open actions.
final class ResultScreen extends StatelessWidget {
  /// Creates the success screen for [results].
  const ResultScreen({super.key, required this.results});

  /// Produced files, one or many.
  final List<PdfResult> results;

  Future<void> _share(PdfResult result) => getIt.get<SharePdfUseCase>().call(result);

  Future<void> _open(PdfResult result) => OpenFilex.open(result.path);

  @override
  Widget build(BuildContext context) {
    final result = results.first;
    if (results.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: Text(context.tr('error.unknown'))),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
              child: Row(
                children: [
                  const SizedBox(width: 44, height: 44),
                  const Spacer(),
                  Text(
                    context.tr('result.title'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44, height: 44),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                child: Column(
                  children: [
                    const Spacer(),
                    const Icon(Icons.check_circle, size: 64, color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('result.subtitle'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                    if (results.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.tr('result.files', namedArgs: {'n': '${results.length}'}),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Column(
                        children: [
                          for (final item in results)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ResultTile(result: item, onShare: () => _share(item), onOpen: () => _open(item)),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.horizontalPadding, 8, AppDimens.horizontalPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(label: context.tr('common.share'), onTap: () => _share(result)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _open(result),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(AppDimens.ctaHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: Text(
                      context.tr('common.open'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(
                      context.tr('result.again'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    ),
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

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onShare, required this.onOpen});

  final PdfResult result;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final sizeMb = (result.sizeBytes / 1024 / 1024).toStringAsFixed(1);
    final meta =
        '${context.tr('file.pages', namedArgs: {'n': '${result.pages}'})} · '
        '${context.tr('file.size', namedArgs: {'n': sizeMb})}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
      child: Row(
        children: [
          const PdfDocBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.name,
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
          IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share, size: 20, color: AppColors.primary),
          ),
          IconButton(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new, size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
