import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:merge_pdf/app.dart';
import 'package:merge_pdf/core/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/localization.dart';
import 'package:merge_pdf/utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLog.instance.logDeviceInfo();
  AppLog.instance.info('app.main=starting');
  configureDependencies();
  await getIt.get<StorageService>().init();
  AppLog.instance.info('app.main=ready');
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/lang',
      assetLoader: const AllCsvAssetLoader(),
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const MergePdfApp(),
    ),
  );
}
