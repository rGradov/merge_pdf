import 'dart:async';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/shimmer.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Shows a near-fullscreen, real page preview with horizontal swipe to flip
/// between pages.
Future<void> showPdfPreview(
  BuildContext context, {
  required String path,
  required int page,
  required int total,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
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
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.page.clamp(0, widget.total - 1);
    _controller = PageController(initialPage: _current);
    unawaited(_prefetch());
  }

  Future<void> _prefetch() async {
    final start = (_current - 2).clamp(0, widget.total - 1);
    final end = (_current + 2).clamp(0, widget.total - 1);
    await getIt.get<PdfEngineService>().renderPages(
      widget.path,
      [for (var i = start; i <= end; i++) i],
      maxDim: 800,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.92;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
                  ),
                  Positioned(
                    right: 4,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.close, size: 24, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              context.tr('page.of', namedArgs: {'a': '${_current + 1}', 'b': '${widget.total}'}),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.total,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _PageRender(path: widget.path, page: index),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PageRender extends StatefulWidget {
  const _PageRender({required this.path, required this.page});

  final String path;
  final int page;

  @override
  State<_PageRender> createState() => _PageRenderState();
}

class _PageRenderState extends State<_PageRender> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_render());
  }

  @override
  void didUpdateWidget(_PageRender old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path || old.page != widget.page) {
      _bytes = null;
      _failed = false;
      unawaited(_render());
    }
  }

  Future<void> _render() async {
    final path = widget.path;
    final page = widget.page;
    final result = await getIt.get<PdfEngineService>().renderPage(path, page);
    if (!mounted) return;
    if (path != widget.path || page != widget.page) return;
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
  Widget build(BuildContext context) {
    if (_failed) {
      return Center(child: Text(context.tr('error.unknown'), style: const TextStyle(color: AppColors.textSecondary)));
    }
    if (_bytes == null) return const ShimmerBox(borderRadius: AppDimens.radiusPage);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusPage),
      child: Image.memory(_bytes!, fit: BoxFit.contain),
    );
  }
}
