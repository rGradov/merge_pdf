import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/home/views/views.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/views/views.dart';

part 'app_router.g.dart';

/// Home route.
@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  /// Creates the home route.
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

/// Merge flow route.
@TypedGoRoute<MergeRoute>(path: '/merge')
class MergeRoute extends GoRouteData with $MergeRoute {
  /// Creates the merge route.
  const MergeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MergeScreen();
}

/// Split flow route.
@TypedGoRoute<SplitRoute>(path: '/split')
class SplitRoute extends GoRouteData with $SplitRoute {
  /// Creates the split route.
  const SplitRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplitScreen();
}

/// Rotate flow route.
@TypedGoRoute<RotateRoute>(path: '/rotate')
class RotateRoute extends GoRouteData with $RotateRoute {
  /// Creates the rotate route.
  const RotateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const RotateScreen();
}

/// Success screen route carrying the produced files as extra data.
@TypedGoRoute<ResultRoute>(path: '/result')
class ResultRoute extends GoRouteData with $ResultRoute {
  /// Creates the result route carrying [ResultRoute.$extra].
  const ResultRoute({this.$extra});

  /// Produced files passed through navigation.
  final List<PdfResult>? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) => ResultScreen(results: $extra ?? const []);
}

/// Settings route.
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// Creates the settings route.
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingsScreen();
}

/// App-level router built from the generated route list.
final GoRouter appRouter = GoRouter(routes: $appRoutes);
