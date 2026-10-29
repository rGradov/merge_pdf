import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/enums/enums.dart';
import 'package:merge_pdf/global.config.dart';

/// Process-wide dependency container.
final GetIt getIt = GetIt.instance;

/// Play/App Store environment constant.
const regular = Environment('regular');

/// RuStore environment constant.
const ruStore = Environment('ruStore');

/// Huawei AppGallery environment constant.
const appGallery = Environment('appGallery');

/// Build-time configuration.
abstract final class BuildConfig {
  /// The distribution channel this binary targets.
  static const Variation variation = Variation.regular;
}

/// Wires every `@injectable` class into [getIt] for the current variation.
@InjectableInit()
void configureDependencies() => getIt.init(environment: BuildConfig.variation.name);
