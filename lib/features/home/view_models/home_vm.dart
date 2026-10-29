import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_vm.g.dart';

/// Home screen actions: deleting recent files.
final class HomeVm {
  /// Runs the remove-recent action.
  final Command1<Empty, int> remove = Command1(getIt.get<RemoveRecentFileUseCase>().call);
}

/// Provides the home screen view model.
@riverpod
HomeVm homeVm(Ref ref) => HomeVm();
