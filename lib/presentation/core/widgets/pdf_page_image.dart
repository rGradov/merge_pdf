import 'dart:async';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Renders a single PDF page (0-based [page]) to an image on the fly.
final class PdfPageImage extends StatefulWidget {
  /// Creates a page renderer.
  const PdfPageImage({
    super.key,
    required this.path,
    required this.page,
    this.maxDim = 800,
    this.fit = BoxFit.contain,
  });

  /// Absolute path to the PDF.
  final String path;

  /// 0-based page index.
  final int page;

  /// Maximum dimension of the rendered bitmap in pixels.
  final int maxDim;

  /// How the rendered page fits its box.
  final BoxFit fit;

  @override
  State<PdfPageImage> createState() => _PdfPageImageState();
}

class _PdfPageImageState extends State<PdfPageImage> with AutomaticKeepAliveClientMixin {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    unawaited(_render());
  }

  @override
  void didUpdateWidget(PdfPageImage old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path || old.page != widget.page || old.maxDim != widget.maxDim) {
      _bytes = null;
      _failed = false;
      unawaited(_render());
    }
  }

  Future<void> _render() async {
    final path = widget.path;
    final page = widget.page;
    final maxDim = widget.maxDim;
    final result = await getIt.get<PdfEngineService>().renderPage(path, page, maxDim: maxDim);
    if (!mounted) return;
    if (path != widget.path || page != widget.page || maxDim != widget.maxDim) return;
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
    super.build(context);
    if (_failed) {
      return Center(child: Icon(Icons.description, size: 20, color: AppColors.textHint));
    }
    if (_bytes == null) {
      return const Center(
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Image.memory(_bytes!, fit: widget.fit);
  }
}
