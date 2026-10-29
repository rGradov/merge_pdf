import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';
import 'package:open_filex/open_filex.dart';

/// Success screen: produced files with share / save / done actions.
final class ResultScreen extends StatelessWidget {
  /// Creates the success screen for [results].
  const ResultScreen({super.key, required this.results, this.sourceCount = 0});

  /// Produced files, one or many.
  final List<PdfResult> results;

  /// Source count used for the merge subtitle (e.g. "3 files combined").
  final int sourceCount;

  Future<void> _share(PdfResult result) => getIt.get<SharePdfUseCase>().call(result);

  Future<void> _open(PdfResult result) => OpenFilex.open(result.path);

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: Text(context.tr('error.unknown'))),
      );
    }
    final result = results.first;
    final (title, subtitle) = switch (result.tool) {
      ToolKind.merge => (
        context.tr('result.title.merge'),
        context.tr('result.subtitle.merge', namedArgs: {'n': '$sourceCount'}),
      ),
      ToolKind.split => (
        context.tr('result.title.split'),
        context.tr('result.subtitle.split', namedArgs: {'n': '${results.length}'}),
      ),
      ToolKind.rotate => (context.tr('result.title.rotate'), context.tr('result.subtitle.rotate')),
    };

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(color: Color(0xFFECFDF3), shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 32, color: Color(0xFF12946A)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: results.length == 1
                          ? _ResultCard(result: result)
                          : Column(
                              children: [
                                for (final item in results)
                                  Padding(padding: const EdgeInsets.only(bottom: 10), child: _ResultCard(result: item)),
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
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _open(result),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size.fromHeight(AppDimens.ctaHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: Text(
                      context.tr('result.save'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: Text(
                      context.tr('result.done'),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final PdfResult result;

  @override
  Widget build(BuildContext context) {
    final meta =
        '${context.tr('file.pages', namedArgs: {'n': '${result.pages}'})} · '
        '${formatBytes(context, result.sizeBytes)}';
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
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
        ],
      ),
    );
  }
}
