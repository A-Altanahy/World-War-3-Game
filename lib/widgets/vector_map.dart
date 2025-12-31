import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_risk/models/country.dart';
import 'package:custom_risk/utils/svg_path_parser.dart';
import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter_svg/flutter_svg.dart';

class VectorMap extends StatefulWidget {
  final String mapAsset;
  final List<Country> countries;
  final Function(Country) onCountryTap;

  const VectorMap({
    super.key,
    required this.mapAsset,
    required this.countries,
    required this.onCountryTap,
  });

  @override
  State<VectorMap> createState() => _VectorMapState();
}

class _VectorMapState extends State<VectorMap> {
  Map<String, Path> _paths = {}; // Map SVG ID to Path
  Size _originalSize = const Size(900, 600); // Default, update from viewBox
  bool _isLoading = true;
  String? _debugError;

  @override
  void initState() {
    super.initState();
    _loadAndParseSvg();
  }

  @override
  void didUpdateWidget(VectorMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapAsset != widget.mapAsset) {
      _loadAndParseSvg();
    }
  }

  Future<void> _loadAndParseSvg() async {
    setState(() {
      _isLoading = true;
      _debugError = null;
    });
    try {
      final svgString = await rootBundle.loadString(widget.mapAsset);
      _parseSvg(svgString);
    } catch (e) {
      debugPrint('Error loading SVG: $e');
      setState(() => _debugError = 'Failed to load SVG: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseSvg(String svgString) {
    try {
      final paths = <String, Path>{};

      // 1. Extract ViewBox (Robust parsing)
      // Standard viewBox is "min-x min-y width height"
      final viewBoxMatch = RegExp(r'viewBox="([^"]+)"').firstMatch(svgString);
      if (viewBoxMatch != null) {
        final parts = viewBoxMatch.group(1)!.trim().split(RegExp(r'\s+'));
        if (parts.length == 4) {
          // We care about width and height (indices 2 and 3)
          _originalSize = Size(
            double.tryParse(parts[2]) ?? 900,
            double.tryParse(parts[3]) ?? 600,
          );
        }
      }

      // Strategy: Iterate through all <path> tags that have an ID starting with Country
      // We look for the pattern: <path ... id="CountryXX" ... d="..." ... />
      // OR nested in groups. The simplest way is to find keys that look like IDs and finding the closest d attribute.

      // Expanded regex to catch ID and D attribute regardless of order, within reasonably close proximity
      // We search for "id="CountryXX"" then scan forward/backward for "d".
      // But standard grep showed they are on the same line/tag usually.

      // Regex to find IDs (supports double and single quotes)
      final idRegex = RegExp(r'id=["\047]([^"\047]+)["\047]');
      final allIdMatches = idRegex.allMatches(svgString);

      for (final match in allIdMatches) {
        String originalId = match.group(1)!;
        String normId =
            'Country${int.tryParse(originalId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0}';

        // Find the "d" attribute. It should be in the same tag.
        // We look ahead from the ID match.
        // Dynamic Tag Extraction: Find the full tag content surrounding this ID
        // 1. Search backwards for the start of the tag '<path' or '<g'
        int tagStart = svgString.lastIndexOf('<', match.start);
        if (tagStart == -1) tagStart = match.start; // Fallback

        // 2. Search forwards for the end of the tag '>'
        int tagEnd = svgString.indexOf('>', match.start);
        if (tagEnd == -1) tagEnd = svgString.length;

        // Extract the full tag content
        String tagContent = svgString.substring(tagStart, tagEnd + 1);

        // Find d attribute in this tag content
        // Note: d attribute can use single or double quotes.
        // We use (?:\s|^) to ensure we match ' d=' and not 'id=' or 'solid=' etc.
        var dMatch = RegExp(r'(?:^|\s)d="([^"]+)"').firstMatch(tagContent);
        dMatch ??= RegExp(r"(?:^|\s)d='([^']+)'").firstMatch(tagContent);

        if (dMatch != null) {
          if (widget.countries
              .any((c) => c.svgId == normId || c.svgId == originalId)) {
            try {
              final path = SvgPathParser.parse(dMatch.group(1)!);

              // Check if fill-rule="evenodd" is present
              if (tagContent.contains('fill-rule="evenodd"')) {
                path.fillType = PathFillType.evenOdd;
              }

              paths[normId] = path;
              // Debug: Confirm it was added
              print(
                  'Creating Map: Success! Added path for "$originalId" (norm: "$normId")');
            } catch (e) {
              // Silent catch to prevent console spam
            }
          } else {
            // Debug: Log ignored IDs to help user find mismatches
            print(
                'Creating Map: Ignored SVG ID "$originalId" (norm: "$normId") - Not found in Country list.');
          }
        } else {
          // Case 2: ID is on a Group <g id="...">, path is inside.
          // Search for the first <path ... d="..."> after the ID tag.
          // We search forward a reasonable amount (e.g. 50k chars) to find child path
          int childSearchEnd = (tagEnd + 50000).clamp(0, svgString.length);
          final childContext = svgString.substring(tagEnd, childSearchEnd);

          final childDMatch =
              RegExp(r'<path[^>]*d="([^"]+)"').firstMatch(childContext);
          final childDMatchSingle =
              RegExp(r"<path[^>]*d='([^']+)'").firstMatch(childContext);

          final matchToUse = childDMatch ?? childDMatchSingle;

          if (matchToUse != null) {
            if (widget.countries
                .any((c) => c.svgId == normId || c.svgId == originalId)) {
              try {
                paths[normId] = SvgPathParser.parse(matchToUse.group(1)!);
              } catch (e) {
                // Silent catch
              }
            }
          }
        }
      }

      print('Parsed ${paths.length} paths for map.');
      if (paths.isEmpty) {
        setState(() {
          _debugError = 'Parsed 0 paths! Check SVG IDs vs Country Model names.';
        });
      }

      setState(() {
        _paths = paths;
      });
    } catch (e) {
      debugPrint('Error parsing SVG paths: $e');
      setState(() => _debugError = 'Error parsing: $e');
    }
  }

  void _handleTap(TapUpDetails details, Size renderSize) {
    if (_paths.isEmpty) return;

    // Calculate scale factor
    final scaleX = renderSize.width / _originalSize.width;
    final scaleY = renderSize.height / _originalSize.height;

    // Maintain aspect ratio: BoxFit.contain usually
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Offset to center content
    final offsetX = (renderSize.width - _originalSize.width * scale) / 2;
    final offsetY = (renderSize.height - _originalSize.height * scale) / 2;

    final localPoint = details.localPosition;

    // Inverse transform point to SVG coordinates
    final svgX = (localPoint.dx - offsetX) / scale;
    final svgY = (localPoint.dy - offsetY) / scale;
    final svgPoint = Offset(svgX, svgY);

    // Check hit
    for (final entry in _paths.entries) {
      if (entry.value.contains(svgPoint)) {
        final country = widget.countries.firstWhere(
          (c) => c.svgId == entry.key,
          orElse: () => Country(
              id: 'unknown', name: 'Unknown', normalizedPosition: Offset.zero),
        );

        if (country.id != 'unknown') {
          widget.onCountryTap(country);
          return; // Stop after first hit
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_debugError != null) {
      return Center(
        child: Text(
          _debugError!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full Map Background (Oceans, Labels, Decoration)
              SvgPicture.asset(
                widget.mapAsset,
                fit: BoxFit.contain,
              ),
              // 2. Interactive Layer (Lands)
              GestureDetector(
                onTapUp: (details) => _handleTap(details, size),
                child: CustomPaint(
                  size: size,
                  painter: VectorMapPainter(
                    paths: _paths,
                    countries: widget.countries,
                    originalSize: _originalSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VectorMapPainter extends CustomPainter {
  final Map<String, Path> paths;
  final List<Country> countries;
  final Size originalSize;

  VectorMapPainter({
    required this.paths,
    required this.countries,
    required this.originalSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scaling to Fit Contain
    final scaleX = size.width / originalSize.width;
    final scaleY = size.height / originalSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - originalSize.width * scale) / 2;
    final offsetY = (size.height - originalSize.height * scale) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Removed default border to keep original SVG look
    // final borderPaint = Paint().. ...

    for (final entry in paths.entries) {
      final id = entry.key;
      final path = entry.value;

      Country? country;
      Color fillColor = Colors.transparent;

      try {
        country = countries.firstWhere((c) => c.svgId == id);
        if (country.owner != null) {
          fillColor = country.owner!.color.withOpacity(0.6);
        }
      } catch (_) {}

      // Only draw fill if captured
      if (fillColor != Colors.transparent && fillColor.opacity > 0) {
        final paint = Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, paint);
      }

      // Draw star for base lands
      if (country != null && country.isBase) {
        final bounds = path.getBounds();
        final center = bounds.center;

        final textPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(Icons.star.codePoint),
            style: TextStyle(
                fontSize: 24, // Slightly larger for visibility
                fontFamily: Icons.star.fontFamily,
                color: Colors.amber,
                package: Icons.star.fontPackage),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas,
            center - Offset(textPainter.width / 2, textPainter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant VectorMapPainter oldDelegate) {
    return true;
  }
}
