import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/features/pdf_tools/view_models/view_models.dart';
import 'package:merge_pdf/features/pdf_tools/views/result_screen.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Merge page-trimming screen: review each file, trim its page range, merge.
final class MergeTrimScreen extends ConsumerStatefulWidget {
  /// Creates the trimming screen for the picked [files].
  const MergeTrimScreen({super.key, required this.files});

  /// Files in merge order.
  final List<PdfFile> files;

  @override
  ConsumerState<MergeTrimScreen> createState() => _MergeTrimScreenState();
}

class _MergeTrimScreenState extends ConsumerState<MergeTrimScreen> {
  int _active = 0;
  bool _running = false;
  final Map<String, (int, int)> _ranges = {};
  bool _initialized = false;
  Map<String, int> _countsCache = const {};

  List<PdfFile> get _files => widget.files;

  void _setStart(String path, int value) {
    final range = _ranges[path];
    if (range == null) return;
    setState(() => _ranges[path] = (value.clamp(0, range.$2), range.$2));
  }

  void _setEnd(String path, int value) {
    final range = _ranges[path];
    if (range == null) return;
    final last = (_countsCache[path] ?? 1) - 1;
    setState(() => _ranges[path] = (range.$1, value.clamp(range.$1, last)));
  }

  Future<void> _merge() async {
    setState(() => _running = true);
    final repo = getIt.get<PdfToolsRepository>();
    final result = await repo.mergeSelected(_files, Map.of(_ranges));
    if (!mounted) return;
    setState(() => _running = false);
    switch (result) {
      case Success(:final value):
        ref.invalidate(recentFilesProvider);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(results: [value], sourceCount: _files.length)),
        );
      case Failure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.localized(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final file in _files) {
      final value = ref.watch(pdfPagesProvider(file.path));
      counts[file.path] = value.value?.valueOrNull ?? 0;
    }
    _countsCache = counts;
    if (!_initialized && counts.values.every((value) => value > 0)) {
      _initialized = true;
      for (final file in _files) {
        _ranges[file.path] = (0, counts[file.path]! - 1);
      }
    }
    final activeFile = _files[_active.clamp(0, _files.length - 1)];
    final activeRange = _ranges[activeFile.path] ?? (0, (counts[activeFile.path] ?? 1) - 1);
    final activeTotal = counts[activeFile.path] ?? 0;
    final totalPages = _files.fold<int>(0, (sum, file) {
      final range = _ranges[file.path];
      if (range == null) return sum;
      return sum + (range.$2 - range.$1 + 1);
    });
    final totalBytes = _files.fold<int>(0, (sum, file) => sum + file.sizeBytes);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolAppBar(
              title: context.tr('merge.title'),
              titleSize: 22,
              onBack: () => Navigator.of(context).maybePop(),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    for (final file in _files) {
                      _ranges[file.path] = (0, (counts[file.path] ?? 1) - 1);
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(child: Icon(Icons.delete_outline, size: 22, color: AppColors.textSecondary)),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _PreviewArea(file: activeFile, range: activeRange, total: activeTotal),
                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                  _Filmstrip(
                    files: _files,
                    active: _active,
                    ranges: _ranges,
                    counts: counts,
                    onSelect: (index) => setState(() => _active = index),
                    onSetStart: _setStart,
                    onSetEnd: _setEnd,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 13, 20, 12),
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
                          context.tr('merge.filesPages', namedArgs: {'files': '${_files.length}', 'pages': '$totalPages'}),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('merge.totalSize', namedArgs: {'n': formatBytes(context, totalBytes)}),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _running ? null : _merge,
                    child: Opacity(
                      opacity: _running ? 0.7 : 1,
                      child: Container(
                        height: AppDimens.ctaHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9999)),
                        child: Center(
                          child: _running
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                              : Text(
                                  context.tr('merge.action'),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white),
                                ),
                        ),
                      ),
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

class _PreviewArea extends StatelessWidget {
  const _PreviewArea({required this.file, required this.range, required this.total});

  final PdfFile file;
  final (int, int) range;
  final int total;

  @override
  Widget build(BuildContext context) {
    final start = range.$1 + 1;
    final end = range.$2 + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr('page.of', namedArgs: {'a': '$start', 'b': '$total'}),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              width: 200,
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusPage),
                border: Border.all(color: AppColors.border),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: const _FakePage(),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x80FFDAD6),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              context.tr('merge.trim.keepPages', namedArgs: {'a': '$start', 'b': '$end'}),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFB90D10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakePage extends StatelessWidget {
  const _FakePage();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 60, height: 8, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
      const SizedBox(height: 24),
      for (final width in const [1.0, 0.85, 1.0, 0.7, 0.9, 0.6]) ...[
        FractionallySizedBox(
          widthFactor: width,
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ],
      const Spacer(),
      Container(height: 60, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4))),
    ],
  );
}

class _Filmstrip extends StatelessWidget {
  const _Filmstrip({
    required this.files,
    required this.active,
    required this.ranges,
    required this.counts,
    required this.onSelect,
    required this.onSetStart,
    required this.onSetEnd,
  });

  final List<PdfFile> files;
  final int active;
  final Map<String, (int, int)> ranges;
  final Map<String, int> counts;
  final ValueChanged<int> onSelect;
  final void Function(String path, int value) onSetStart;
  final void Function(String path, int value) onSetEnd;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final file = files[index];
        final total = counts[file.path] ?? 0;
        final isActive = index == active;
        final range = ranges[file.path] ?? (0, (total - 1).clamp(0, total));
        return GestureDetector(
          onTap: () => onSelect(index),
          child: SizedBox(
            width: isActive ? 280 : 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppColors.text : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive
                          ? context.tr('merge.trim.keepPages', namedArgs: {'a': '${range.$1 + 1}', 'b': '${range.$2 + 1}'})
                          : context.tr('merge.trim.shortPages', namedArgs: {'n': '$total'}),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isActive)
                  _ActiveClip(
                    total: total,
                    range: range,
                    onSetStart: (value) => onSetStart(file.path, value),
                    onSetEnd: (value) => onSetEnd(file.path, value),
                  )
                else
                  _MiniClip(total: total),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _ActiveClip extends StatelessWidget {
  const _ActiveClip({required this.total, required this.range, required this.onSetStart, required this.onSetEnd});

  final int total;
  final (int, int) range;
  final ValueChanged<int> onSetStart;
  final ValueChanged<int> onSetEnd;

  @override
  Widget build(BuildContext context) {
    const double clipWidth = 280;
    const double clipHeight = 96;
    return Container(
      width: clipWidth,
      height: clipHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB90D10), width: 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sliceWidth = constraints.maxWidth / (total == 0 ? 1 : total);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < total; i++)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: i >= range.$1 && i <= range.$2 ? AppColors.white : const Color(0x66DADADB),
                              border: Border(right: BorderSide(color: AppColors.border, width: i == total - 1 ? 0 : 1)),
                            ),
                            child: i >= range.$1 && i <= range.$2
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(width: 12, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.line))),
                                        SizedBox(height: 6),
                                        SizedBox(width: 10, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.line))),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: range.$1 * sliceWidth - 6,
                top: 16,
                bottom: 16,
                child: _TrimHandle(
                  index: range.$1,
                  min: 0,
                  max: range.$2,
                  sliceWidth: sliceWidth,
                  onChanged: onSetStart,
                ),
              ),
              Positioned(
                left: (range.$2 + 1) * sliceWidth - 6,
                top: 16,
                bottom: 16,
                child: _TrimHandle(
                  index: range.$2,
                  min: range.$1,
                  max: total - 1,
                  sliceWidth: sliceWidth,
                  onChanged: onSetEnd,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniClip extends StatelessWidget {
  const _MiniClip({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 96,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        for (var i = 0; i < total.clamp(0, 4); i++)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(width: 12, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.line))),
                    SizedBox(height: 6),
                    SizedBox(width: 8, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.line))),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _TrimHandle extends StatefulWidget {
  const _TrimHandle({
    required this.index,
    required this.min,
    required this.max,
    required this.sliceWidth,
    required this.onChanged,
  });

  final int index;
  final int min;
  final int max;
  final double sliceWidth;
  final ValueChanged<int> onChanged;

  @override
  State<_TrimHandle> createState() => _TrimHandleState();
}

class _TrimHandleState extends State<_TrimHandle> {
  double _acc = 0;

  @override
  void didUpdateWidget(_TrimHandle old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _acc = 0;
  }

  void _update(DragUpdateDetails details) {
    _acc += details.delta.dx;
    final step = (_acc / widget.sliceWidth).round();
    if (step == 0) return;
    _acc -= step * widget.sliceWidth;
    final next = (widget.index + step).clamp(widget.min, widget.max);
    if (next != widget.index) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onHorizontalDragUpdate: _update,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 12,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFB90D10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(999)),
      ),
    ),
  );
}
