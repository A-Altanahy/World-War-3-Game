import 'dart:ui';
import 'package:flutter/material.dart';

class SvgPathParser {
  /// Parses an SVG path data string into a Flutter Path object.
  static Path parse(String pathData) {
    final Path path = Path();
    final RegExp commandRegex = RegExp(r'[a-zA-Z]');

    String currentCommand = '';
    // Use list of doubles for efficient parameter extraction

    // Simplistic parser: split by commands and process
    // Better approach: Iterate through string

    double currentX = 0;
    double currentY = 0;
    double startX = 0;
    double startY = 0;

    // Control points for smooth curves (S and T)
    double lastControlX = 0;
    double lastControlY = 0;

    final parts = _tokenize(pathData);

    int i = 0;
    while (i < parts.length) {
      final part = parts[i];
      if (commandRegex.hasMatch(part)) {
        currentCommand = part;
        i++;
      }

      switch (currentCommand) {
        case 'M':
          currentX = double.parse(parts[i++]);
          currentY = double.parse(parts[i++]);
          path.moveTo(currentX, currentY);
          startX = currentX;
          startY = currentY;
          // Subsequent pairs are L
          currentCommand = 'L';
          break;
        case 'm':
          final x = double.parse(parts[i++]);
          final y = double.parse(parts[i++]);
          currentX += x;
          currentY += y;
          path.moveTo(currentX, currentY);
          startX = currentX;
          startY = currentY;
          currentCommand = 'l';
          break;
        case 'L':
          currentX = double.parse(parts[i++]);
          currentY = double.parse(parts[i++]);
          path.lineTo(currentX, currentY);
          break;
        case 'l':
          currentX += double.parse(parts[i++]);
          currentY += double.parse(parts[i++]);
          path.lineTo(currentX, currentY);
          break;
        case 'H':
          currentX = double.parse(parts[i++]);
          path.lineTo(currentX, currentY);
          break;
        case 'h':
          currentX += double.parse(parts[i++]);
          path.lineTo(currentX, currentY);
          break;
        case 'V':
          currentY = double.parse(parts[i++]);
          path.lineTo(currentX, currentY);
          break;
        case 'v':
          currentY += double.parse(parts[i++]);
          path.lineTo(currentX, currentY);
          break;
        case 'C':
          final x1 = double.parse(parts[i++]);
          final y1 = double.parse(parts[i++]);
          final x2 = double.parse(parts[i++]);
          final y2 = double.parse(parts[i++]);
          final x = double.parse(parts[i++]);
          final y = double.parse(parts[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastControlX = x2;
          lastControlY = y2;
          currentX = x;
          currentY = y;
          break;
        case 'c':
          final x1 = currentX + double.parse(parts[i++]);
          final y1 = currentY + double.parse(parts[i++]);
          final x2 = currentX + double.parse(parts[i++]);
          final y2 = currentY + double.parse(parts[i++]);
          final x = currentX + double.parse(parts[i++]);
          final y = currentY + double.parse(parts[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastControlX = x2;
          lastControlY = y2;
          currentX = x;
          currentY = y;
          break;
        case 'Z':
        case 'z':
          path.close();
          currentX = startX;
          currentY = startY;
          break;
        // Add S, Q, T, A if needed. For now assuming M, L, C, Z
        default:
          // Skip if unknown
          break;
      }
    }

    return path;
  }

  static List<String> _tokenize(String pathData) {
    final List<String> tokens = [];
    final RegExp tokenRegex =
        RegExp(r'[a-zA-Z]|[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?');
    final matches = tokenRegex.allMatches(pathData);
    for (final match in matches) {
      if (match.group(0) != null && match.group(0)!.isNotEmpty) {
        tokens.add(match.group(0)!);
      }
    }
    return tokens;
  }
}
