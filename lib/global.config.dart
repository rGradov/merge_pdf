// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:merge_pdf/core/services/local.dart' as _i854;
import 'package:merge_pdf/core/services/services.dart' as _i41;
import 'package:merge_pdf/features/pdf_tools/repositories/local.dart' as _i929;
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart'
    as _i383;
import 'package:merge_pdf/features/pdf_tools/services/local.dart' as _i308;
import 'package:merge_pdf/features/pdf_tools/services/services.dart' as _i29;
import 'package:merge_pdf/features/pdf_tools/use_cases/clear_storage_use_case.dart'
    as _i216;
import 'package:merge_pdf/features/pdf_tools/use_cases/merge_pdfs_use_case.dart'
    as _i170;
import 'package:merge_pdf/features/pdf_tools/use_cases/recent_files_use_case.dart'
    as _i520;
import 'package:merge_pdf/features/pdf_tools/use_cases/remove_recent_file_use_case.dart'
    as _i625;
import 'package:merge_pdf/features/pdf_tools/use_cases/rotate_pdf_use_case.dart'
    as _i915;
import 'package:merge_pdf/features/pdf_tools/use_cases/share_pdf_use_case.dart'
    as _i379;
import 'package:merge_pdf/features/pdf_tools/use_cases/split_pdf_use_case.dart'
    as _i324;

const String _regular = 'regular';
const String _ruStore = 'ruStore';
const String _appGallery = 'appGallery';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i41.StorageService>(
      () => _i854.LocalStorageService(),
      registerFor: {_regular, _ruStore, _appGallery},
    );
    gh.singleton<_i41.ShareService>(
      () => _i854.LocalShareService(),
      registerFor: {_regular, _ruStore, _appGallery},
    );
    gh.singleton<_i29.PdfEngineService>(
      () => _i308.LocalPdfEngineService(),
      registerFor: {_regular, _ruStore, _appGallery},
    );
    gh.factory<_i379.SharePdfUseCase>(
      () => _i379.SharePdfUseCase(gh<_i41.ShareService>()),
    );
    gh.singleton<_i29.RecentFilesService>(
      () => _i308.LocalRecentFilesService(gh<_i41.StorageService>()),
      registerFor: {_regular, _ruStore, _appGallery},
    );
    gh.factory<_i383.PdfToolsRepository>(
      () => _i929.LocalPdfToolsRepository(
        gh<_i29.PdfEngineService>(),
        gh<_i29.RecentFilesService>(),
      ),
      registerFor: {_regular, _ruStore, _appGallery},
    );
    gh.factory<_i216.ClearStorageUseCase>(
      () => _i216.ClearStorageUseCase(gh<_i383.PdfToolsRepository>()),
    );
    gh.factory<_i170.MergePdfsUseCase>(
      () => _i170.MergePdfsUseCase(gh<_i383.PdfToolsRepository>()),
    );
    gh.factory<_i520.RecentFilesUseCase>(
      () => _i520.RecentFilesUseCase(gh<_i383.PdfToolsRepository>()),
    );
    gh.factory<_i625.RemoveRecentFileUseCase>(
      () => _i625.RemoveRecentFileUseCase(gh<_i383.PdfToolsRepository>()),
    );
    gh.factory<_i915.RotatePdfUseCase>(
      () => _i915.RotatePdfUseCase(gh<_i383.PdfToolsRepository>()),
    );
    gh.factory<_i324.SplitPdfUseCase>(
      () => _i324.SplitPdfUseCase(gh<_i383.PdfToolsRepository>()),
    );
    return this;
  }
}
