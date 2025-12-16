// lib/utils/coordinate_converter.dart

import 'package:flutter/material.dart';

class CoordinateConverter {
  // Standard SVG dimensions that both editor and game should use
  static const double standardSvgWidth = 900.0;
  static const double standardSvgHeight = 600.0;

  // Calculate how BoxFit.contain positions the SVG within a container
  static SvgLayout calculateSvgLayout(Size containerSize) {
    const double svgAspectRatio = standardSvgWidth / standardSvgHeight;
    final double containerAspectRatio =
        containerSize.width / containerSize.height;

    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (containerAspectRatio > svgAspectRatio) {
      // Container is wider - SVG height fills container, width is centered
      scale = containerSize.height / standardSvgHeight;
      offsetX = (containerSize.width - standardSvgWidth * scale) / 2;
    } else {
      // Container is taller - SVG width fills container, height is centered
      scale = containerSize.width / standardSvgWidth;
      offsetY = (containerSize.height - standardSvgHeight * scale) / 2;
    }

    return SvgLayout(
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      svgWidth: standardSvgWidth * scale,
      svgHeight: standardSvgHeight * scale,
    );
  }

  // Convert editor local coordinates to normalized coordinates (0-1 range)
  static Offset editorToNormalized(Offset editorPosition, Size containerSize) {
    final svgLayout = calculateSvgLayout(containerSize);

    // Adjust for SVG offset within container
    final adjustedX = editorPosition.dx - svgLayout.offsetX;
    final adjustedY = editorPosition.dy - svgLayout.offsetY;

    // Convert to normalized coordinates relative to SVG
    return Offset(
      adjustedX / svgLayout.svgWidth,
      adjustedY / svgLayout.svgHeight,
    );
  }

  // Convert normalized coordinates to editor coordinates
  static Offset normalizedToEditor(
      Offset normalizedPosition, Size containerSize) {
    final svgLayout = calculateSvgLayout(containerSize);

    return Offset(
      svgLayout.offsetX + normalizedPosition.dx * svgLayout.svgWidth,
      svgLayout.offsetY + normalizedPosition.dy * svgLayout.svgHeight,
    );
  }

  // Convert normalized coordinates to game map coordinates (with scaling)
  static Offset normalizedToGameMap(
      Offset normalizedPosition, double scale, double dx, double dy) {
    return Offset(
      dx + normalizedPosition.dx * standardSvgWidth * scale,
      dy + normalizedPosition.dy * standardSvgHeight * scale,
    );
  }

  // Get the scaling parameters for the game map (same as calculateSvgLayout)
  static MapScaling calculateGameMapScaling(Size containerSize) {
    final svgLayout = calculateSvgLayout(containerSize);
    return MapScaling(
        scale: svgLayout.scale, dx: svgLayout.offsetX, dy: svgLayout.offsetY);
  }
}

class SvgLayout {
  final double scale;
  final double offsetX;
  final double offsetY;
  final double svgWidth;
  final double svgHeight;

  const SvgLayout({
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.svgWidth,
    required this.svgHeight,
  });
}

class MapScaling {
  final double scale;
  final double dx;
  final double dy;

  const MapScaling({
    required this.scale,
    required this.dx,
    required this.dy,
  });
}
