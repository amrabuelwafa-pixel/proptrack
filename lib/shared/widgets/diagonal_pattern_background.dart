import 'package:flutter/material.dart';

/// Full-screen diagonal striped background rendered with CustomPainter.
/// [lineColor] defaults to a light-grey appropriate for the active theme;
/// pass an explicit value to override.
class DiagonalPatternBackground extends StatelessWidget {
  const DiagonalPatternBackground({
    super.key,
    this.lineColor,
    this.spacing = 30,
    this.strokeWidth = 1,
    this.child,
  });

  final Color? lineColor;
  final double spacing;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = lineColor ??
        (isDark ? const Color(0xFF1A2E42) : const Color(0xFFE2E8F0));

    return CustomPaint(
      painter: _DiagonalPainter(
        lineColor: color,
        spacing: spacing,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  const _DiagonalPainter({
    required this.lineColor,
    required this.spacing,
    required this.strokeWidth,
  });

  final Color lineColor;
  final double spacing;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Diagonal at 45° — draw lines from top-right to bottom-left.
    // We offset by up to size.width + size.height in steps of `spacing`.
    final diag = size.width + size.height;
    final steps = (diag / spacing).ceil() + 2;

    for (var i = -1; i < steps; i++) {
      final offset = i * spacing;
      final x1 = offset.clamp(0.0, size.width);
      final y1 = (offset - size.width).clamp(0.0, size.height);
      final x2 = (offset - size.height).clamp(0.0, size.width);
      final y2 = offset.clamp(0.0, size.height);
      if (x1 != x2 || y1 != y2) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DiagonalPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.spacing != spacing ||
      oldDelegate.strokeWidth != strokeWidth;
}
