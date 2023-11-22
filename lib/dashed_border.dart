import 'dart:ui';

import 'package:flutter/material.dart';

class DashedBorder extends StatefulWidget {
  const DashedBorder({
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dotsWidth = 5.0,
    this.gap = 3.0,
    this.radius = 0,
    required this.child,
    this.padding,
  });

  final Color color;
  final double strokeWidth;
  final double dotsWidth;
  final double gap;
  final double radius;
  final Widget child;
  final EdgeInsets? padding;

  @override
  State<DashedBorder> createState() => _DashedBorderState();
}

class _DashedBorderState extends State<DashedBorder> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedCustomPaint(
        color: widget.color,
        dottedLength: widget.dotsWidth,
        space: widget.gap,
        strokeWidth: widget.strokeWidth,
        radius: widget.radius,
      ),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(2),
        child: widget.child,
      ),
    );
  }
}

class _DottedCustomPaint extends CustomPainter {
  Color? color;
  double? dottedLength;
  double? space;
  double? strokeWidth;
  double? radius;

  _DottedCustomPaint({this.color, this.dottedLength, this.space, this.strokeWidth, this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth!;
    Path path = Path();
    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(radius!)));
    Path draw = buildDashPath(path, dottedLength!, space!);
    canvas.drawPath(draw, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Path buildDashPath(Path path, double d, double space) {
    final Path r = Path();
    for(PathMetric metric in path.computeMetrics()){
      double start = 0.0;
      while(start < metric.length){
        double end = start + d;
        r.addPath(metric.extractPath(start, end), Offset.zero);
        start = end + space;
      }
    }
    return r;
  }
}
