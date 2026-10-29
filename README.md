# Merge PDF

Мобильное приложение на Flutter для работы с PDF: объединение, разделение и поворот страниц.
Поддерживаются Android и iOS, интерфейс локализован на английский и русский языки.

## Возможности

- **Merge** — объединение нескольких PDF в один документ.
- **Split** — разделение PDF на отдельные файлы.
- **Rotate** — поворот страниц.
- **Recent files** — история последних файлов на устройстве (ObjectBox).
- **Share** — отправка результата через системный share-шит.
- **Clear storage** — очистка временных файлов приложения.
- Локализация `en` / `ru` (easy_localization, один CSV на все языки).

## Требования

| Что | Версия |
| --- | --- |
| Flutter | **3.47.8** (stable) — закреплена в `.fvmrc` |
| Dart | 3.13.7 (идёт с Flutter 3.47.8) |
| FVM | 3.x — рекомендуется |
| Android | SDK 36, JDK 17 |
| iOS / macOS | Xcode 16+, CocoaPods |

## Быстрый старт

```bash
git clone https://github.com/rGradov/merge_pdf.git
cd merge_pdf
```

### Вариант A — через FVM (рекомендуется)

Версия Flutter зафиксирована в [`.fvmrc`](.fvmrc), поэтому достаточно установить FVM:

```bash
dart pub global activate fvm
fvm install                                  # поставит Flutter 3.47.8 из .fvmrc
fvm use 3.47.8                               # создаст симлинк .fvm/flutter_sdk
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run
```

> `.fvm/flutter_sdk` — симлинк на скачанный SDK, в git не попадает.
> `.fvm/fvm_config.json` оставлен для обратной совместимости с FVM 2.x;
> актуальный источник версии — `.fvmrc`.

### Вариант B — без FVM

Проверьте, что локально стоит именно Flutter 3.47.8:

```bash
flutter --version
```

Затем:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Генерация кода

Часть исходников генерируется и **не коммитится** (`*.g.dart`, `*.freezed.dart`,
`lib/objectbox.g.dart`, `lib/objectbox-model.json`) — их нужно собрать локально:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

- `injectable` → `lib/global.config.dart` (закоммичен, но перегенерируется при изменении DI);
- `freezed` / `json_serializable` → модели;
- `riverpod_generator` → провайдеры;
- `objectbox_generator` → `lib/objectbox.g.dart`. При первом запуске генератор
  скачивает бинарники ObjectBox, поэтому нужен доступ в интернет.

Во время разработки удобно держать `build_runner` в режиме наблюдения:

```bash
fvm dart run build_runner watch --delete-conflicting-outputs
```

## Запуск

| Команда | Точка входа |
| --- | --- |
| `fvm flutter run` | `lib/main.dart` → `lib/main_dev.dart` |
| `fvm flutter run -t lib/main_dev.dart` | dev-сборка |
| `fvm flutter run -t lib/main_prod.dart` | prod-сборка |
| `fvm flutter run --release` | release-сборка |

Сейчас `main_dev.dart` и `main_prod.dart` идентичны — это заготовки под разные окружения.

### Каналы дистрибуции

Канал задаётся константой `BuildConfig.variation` в [`lib/global.dart`](lib/global.dart):

```dart
abstract final class BuildConfig {
  static const Variation variation = Variation.regular; // ruStore, appGallery
}
```

`Variation` (`lib/core/enums`) влияет на регистрацию зависимостей в `getIt`
(сейчас все три канала используют локальные реализации).

## Тесты и качество кода

```bash
fvm flutter test
fvm flutter analyze
fvm dart format -l 120 .
```

Стиль проверяется через `very_good_analysis` (см. `analysis_options.yaml`),
максимальная длина строки — 120 символов.

## Сборка

### Android

```bash
fvm flutter build apk --release
fvm flutter build appbundle --release
```

`compileSdk = 36` обязателен из-за `file_picker`. Перед публикацией настройте
release-подпись: сейчас в `android/app/build.gradle.kts` используется debug-ключ.

### iOS

```bash
cd ios && pod install && cd ..
fvm flutter build ipa --release
```

## Структура проекта

```
lib/
├── core/                 # сервисы, DI, навигация, конфиг, enum'ы
├── features/
│   ├── home/             # домашний экран, недавние файлы
│   └── pdf_tools/        # merge / split / rotate: модели, репозитории,
│                         # сервисы, use cases, view models, view, widgets
├── presentation/core/    # общие UI-виджеты
├── utils/                # Result, локализация и прочие утилиты
├── app.dart              # MaterialApp + роутер
├── global.dart           # getIt, Environment, BuildConfig
├── global.config.dart    # сгенерированная регистрация DI
├── objectbox.g.dart      # сгенерированный код ObjectBox
├── main.dart             # точка входа (делегирует в main_dev)
├── main_dev.dart
└── main_prod.dart
```

Архитектура — feature-first. Цепочка вызовов:
`View → ViewModel (Riverpod) → UseCase → Repository → Service`.

## Стек

- **State / DI** — flutter_riverpod + riverpod_generator, get_it + injectable
- **Модели** — freezed
- **Навигация** — go_router (+ go_router_builder)
- **Хранилище** — ObjectBox (recent files)
- **PDF** — pdf_manipulator, file_picker, open_filex
- **Локализация** — easy_localization (CSV)
- **UI** — sizer, flutter_animate, flutter_hooks, flutter_svg

## Частые проблемы

| Проблема | Решение |
| --- | --- |
| `objectbox.g.dart` не найден | `fvm dart run build_runner build --delete-conflicting-outputs` |
| `.fvm/flutter_sdk` отсутствует | `fvm use 3.47.8` |
| Ошибка сборки Android про `compileSdk` | Установите Android SDK 36 |
| Ошибки CocoaPods на iOS | `cd ios && pod repo update && pod install` |
| Изменились зависимости | `fvm flutter pub get`, затем повторите `build_runner` |

## Лицензия

Проект распространяется без явно указанной лицензии — уточните у владельца репозитория.
