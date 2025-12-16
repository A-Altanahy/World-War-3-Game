// lib/widgets/debug_overlay.dart

import 'package:flutter/material.dart';
import '../utils/coordinate_converter.dart';

class DebugOverlay extends StatelessWidget {
  final Size containerSize;
  final bool showGrid;
  final bool showSvgBounds;

  const DebugOverlay({
    super.key,
    required this.containerSize,
    this.showGrid = false,
    this.showSvgBounds = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGrid && !showSvgBounds) return const SizedBox.shrink();

    final svgLayout = CoordinateConverter.calculateSvgLayout(containerSize);

    return IgnorePointer(
      child: CustomPaint(
        size: containerSize,
        painter: _DebugPainter(
          svgLayout: svgLayout,
          showGrid: showGrid,
          showSvgBounds: showSvgBounds,
        ),
      ),
    );
  }
}

class _DebugPainter extends CustomPainter {
  final SvgLayout svgLayout;
  final bool showGrid;
  final bool showSvgBounds;

  _DebugPainter({
    required this.svgLayout,
    required this.showGrid,
    required this.showSvgBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw SVG bounds
    if (showSvgBounds) {
      final boundsPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final svgRect = Rect.fromLTWH(
        svgLayout.offsetX,
        svgLayout.offsetY,
        svgLayout.svgWidth,
        svgLayout.svgHeight,
      );

      canvas.drawRect(svgRect, boundsPaint);

      // Draw center lines
      final centerPaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..strokeWidth = 1;

      // Vertical center line
      canvas.drawLine(
        Offset(svgLayout.offsetX + svgLayout.svgWidth / 2, svgLayout.offsetY),
        Offset(svgLayout.offsetX + svgLayout.svgWidth / 2,
            svgLayout.offsetY + svgLayout.svgHeight),
        centerPaint,
      );

      // Horizontal center line
      canvas.drawLine(
        Offset(svgLayout.offsetX, svgLayout.offsetY + svgLayout.svgHeight / 2),
        Offset(svgLayout.offsetX + svgLayout.svgWidth,
            svgLayout.offsetY + svgLayout.svgHeight / 2),
        centerPaint,
      );
    }

    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = 0.5;

      // Draw grid lines every 10% of SVG size
      for (int i = 1; i < 10; i++) {
        final x = svgLayout.offsetX + (svgLayout.svgWidth * i / 10);
        final y = svgLayout.offsetY + (svgLayout.svgHeight * i / 10);

        // Vertical lines
        canvas.drawLine(
          Offset(x, svgLayout.offsetY),
          Offset(x, svgLayout.offsetY + svgLayout.svgHeight),
          gridPaint,
        );

        // Horizontal lines
        canvas.drawLine(
          Offset(svgLayout.offsetX, y),
          Offset(svgLayout.offsetX + svgLayout.svgWidth, y),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
