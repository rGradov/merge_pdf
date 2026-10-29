import 'dart:async';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Shows a real page preview as a bottom sheet, rendering the page on the fly.
Future<void> showPdfPreview(
  BuildContext context, {
  required String path,
  required int page,
  required int total,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PdfPreviewSheet(path: path, page: page, total: total),
  );
}

class _PdfPreviewSheet extends StatefulWidget {
  const _PdfPreviewSheet({required this.path, required this.page, required this.total});

  final String path;
  final int page;
  final int total;

  @override
  State<_PdfPreviewSheet> createState() => _PdfPreviewSheetState();
}

class _PdfPreviewSheetState extends State<_PdfPreviewSheet> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_render());
  }

  Future<void> _render() async {
    final result = await getIt.get<PdfEngineService>().renderPage(widget.path, widget.page);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Success(:final value):
          _bytes = value;
        case Failure():
          _failed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('page.of', namedArgs: {'a': '${widget.page + 1}', 'b': '${widget.total}'}),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 380,
            width: double.infinity,
            child: Center(
              child: _failed
                  ? Text(context.tr('error.unknown'), style: const TextStyle(color: AppColors.textSecondary))
                  : _bytes == null
                      ? const CircularProgressIndicator()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimens.radiusPage),
                          child: Image.memory(_bytes!, fit: BoxFit.contain),
                        ),
            ),
          ),
        ],
      ),
    ),
  );
}
