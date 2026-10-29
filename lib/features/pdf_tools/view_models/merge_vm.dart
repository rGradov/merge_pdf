import 'package:flutter/foundation.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'merge_vm.g.dart';

/// Screen state and actions for the merge flow.
final class MergeVm {
  /// Creates the view model with a merge command wired to the DI graph.
  MergeVm() : merge = Command1(getIt.get<MergePdfsUseCase>().call);

  /// Picked files in merge order.
  final ValueNotifier<List<PdfFile>> files = ValueNotifier(const []);

  /// Runs the merge action on the picked files.
  final Command1<PdfResult, List<PdfFile>> merge;

  /// Adds a picked file.
  void add(PdfFile file) => files.value = [...files.value, file];

  /// Removes the file at [index].
  void removeAt(int index) {
    final next = [...files.value]..removeAt(index);
    files.value = next;
  }

  /// Moves the file from [oldIndex] to [newIndex].
  void reorder(int oldIndex, int newIndex) {
    final next = [...files.value];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    files.value = next;
  }

  /// Clears the selection.
  void clear() => files.value = const [];
}

/// Provides the merge screen view model.
@riverpod
MergeVm mergeVm(Ref ref) => MergeVm();
