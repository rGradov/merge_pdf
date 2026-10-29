import 'package:material_ui/material_ui.dart';

/// Shared spacing scale; everything on screen is a multiple of [base].
abstract final class LayoutConstants {
  /// The base layout unit in logical pixels.
  static const double base = 8;

  /// Layout unit for the current form factor (phone / tablet).
  static double l(BuildContext context) => base * (context.isTablet ? 1.5 : 1);
}

/// Form-factor aware helpers used by every screen.
extension ContextLayout on BuildContext {
  /// The layout unit [LayoutConstants.l] for this context.
  double get l => LayoutConstants.l(this);

  /// Whether the window is large enough to be treated as a tablet.
  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= 600;
}

/// Brand palette taken from the design.
abstract final class AppColors {
  /// Accent red of CTAs and links.
  static const Color primary = Color(0xFFE5342B);

  /// Primary text color.
  static const Color text = Color(0xFF111113);

  /// Secondary text color.
  static const Color textSecondary = Color(0xFF6B6B70);

  /// Hint / tertiary text color.
  static const Color textHint = Color(0xFF9A9AA0);

  /// Card and tile background.
  static const Color surface = Color(0xFFF7F7F8);

  /// Hairline border color.
  static const Color border = Color(0xFFE9E9EC);

  /// Number chip background.
  static const Color chip = Color(0xFFF1F1F3);

  /// Skeleton line color.
  static const Color line = Color(0xFFEDEDF0);

  /// Red "PDF" badge background.
  static const Color badgeBackground = Color(0xFFFDECEB);

  /// Pure white.
  static const Color white = Color(0xFFFFFFFF);
}

/// Shared geometry constants taken from the design.
abstract final class AppDimens {
  /// Corner radius of cards and tiles.
  static const double radiusCard = 16;

  /// Corner radius of page-like elements.
  static const double radiusPage = 12;

  /// Corner radius of small chips and badges.
  static const double radiusSmall = 8;

  /// Height of the primary CTA button.
  static const double ctaHeight = 56;

  /// Height of a toolbox card.
  static const double toolCardHeight = 92;

  /// Height of a recent file tile.
  static const double recentTileHeight = 76;

  /// Horizontal screen padding.
  static const double horizontalPadding = 20;
}

/// The application theme: Inter everywhere, white background.
ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
);
