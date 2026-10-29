import 'package:material_ui/material_ui.dart';

/// Animated shimmer placeholder used while page thumbnails load.
final class ShimmerBox extends StatefulWidget {
  /// Creates a shimmer placeholder.
  const ShimmerBox({super.key, this.borderRadius = 8});

  /// Corner radius of the placeholder.
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final t = _controller.value;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(-1.6 + 3.2 * t, 0),
            end: Alignment(-0.6 + 3.2 * t, 0),
            colors: const [Color(0xFFE9E9EC), Color(0xFFF7F7F8), Color(0xFFE9E9EC)],
            stops: const [0.2, 0.5, 0.8],
          ),
        ),
      );
    },
  );
}
