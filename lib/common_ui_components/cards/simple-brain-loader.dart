import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SimpleBrainLoader extends StatefulWidget {
  final double size;
  final bool showCircle; // New parameter to control circle visibility

  const SimpleBrainLoader({
    Key? key,
    this.size = 22,
    this.showCircle = true, // Default to showing the circle
  }) : super(key: key);

  @override
  State<SimpleBrainLoader> createState() => _SimpleBrainLoaderState();
}

class _SimpleBrainLoaderState extends State<SimpleBrainLoader>
    with TickerProviderStateMixin {
  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();

    // Controller for the circle rotation only
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showCircle) {
      // If no circle needed, just return the static brain icon
      return SvgPicture.asset(
        AssetConsts.elysiaBrainLoaderSvg,
        width: widget.size,
        height: widget.size,
      );
    }

    return SizedBox(
      width: widget.size + 8,
      height: widget.size + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating circle loader
          RotationTransition(
            turns: _circleController,
            child: SizedBox(
              width: widget.size + 6,
              height: widget.size + 6,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
              ),
            ),
          ),
          // Static brain icon in the center
                SvgPicture.asset(
    AssetConsts.elysiaBrainLoaderSvg,
    width: widget.size,
    height: widget.size,
    ),
        ],
      ),
    );
  }
}

// Alternative version with custom painted circle
class SimpleBrainLoaderWithCustomCircle extends StatefulWidget {
  final double size;
  final Color? circleColor;
  final double strokeWidth;

  const SimpleBrainLoaderWithCustomCircle({
    Key? key,
    this.size = 22,
    this.circleColor,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  State<SimpleBrainLoaderWithCustomCircle> createState() => _SimpleBrainLoaderWithCustomCircleState();
}

class _SimpleBrainLoaderWithCustomCircleState extends State<SimpleBrainLoaderWithCustomCircle>
    with TickerProviderStateMixin {
  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 10,
      height: widget.size + 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom rotating circle
          AnimatedBuilder(
            animation: _circleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size + 8, widget.size + 8),
                painter: LoadingCirclePainter(
                  progress: _circleController.value,
                  color: widget.circleColor ?? Theme.of(context).colorScheme.primary,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          // Static brain icon
          SvgPicture.asset(
            AssetConsts.elysiaBrainLoaderSvg,
            width: widget.size,
            height: widget.size,
          ),
        ],
      ),
    );
  }
}

class LoadingCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  LoadingCirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    canvas.drawCircle(center, radius, paint..color = color.withOpacity(0.1));

    // Draw progress arc
    paint.color = color.withOpacity(0.8);
    const startAngle = -3.14159 / 2; // Start from top
    final sweepAngle = 2 * 3.14159 * 0.7; // 70% of circle

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + (2 * 3.14159 * progress),
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}