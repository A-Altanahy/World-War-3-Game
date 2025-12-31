import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/country.dart';

class InteractiveMap extends StatefulWidget {
  final String mapAsset;
  final List<Country> countries;
  final Function(Country) onCountryTap;

  const InteractiveMap({
    Key? key,
    required this.mapAsset,
    required this.countries,
    required this.onCountryTap,
  }) : super(key: key);

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  String? _svgContent;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAndColorMap();
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapAsset != widget.mapAsset ||
        oldWidget.countries != widget.countries) {
      _loadAndColorMap();
    }
  }

  Future<void> _loadAndColorMap() async {
    try {
      String rawSvg =
          await DefaultAssetBundle.of(context).loadString(widget.mapAsset);
      String coloredSvg = _applyColorsToSvg(rawSvg, widget.countries);
      if (mounted) {
        setState(() {
          _svgContent = coloredSvg;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading map: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _applyColorsToSvg(String rawSvg, List<Country> countries) {
    String result = rawSvg;
    for (var country in countries) {
      if (country.owner != null && country.svgId != null) {
        final colorHex =
            '#${country.owner!.color.value.toRadixString(16).substring(2)}';

        // This Regex looks for the ID, then scans forward for the 'fill' attribute.
        // It uses a lazy match ([\s\S]*?) to find the closest fill.
        // It checks to ensure we don't cross another 'id="' definition to prevent bleeding into other groups.
        // Pattern: id="SVG_ID" ... fill="OLD_COLOR"
        final pattern = RegExp(r'(id="' +
            RegExp.escape(country.svgId!) +
            r'"[^>]*>[\s\S]*?fill=")([^"]*)');

        result = result.replaceAllMapped(pattern, (match) {
          // Safety check: if the matched segment contains another id definition, abort this replacement
          // because it means we skipped over another element's start.
          // We exclude the starting id itself from this check.
          String contentAfterId = match.group(1)!;
          // Find index of the first id="
          int firstIdIndex = contentAfterId.indexOf('id="');
          if (firstIdIndex >= 0) {
            // Check if there is ANOTHER id=" after the initial one.
            // The regex starts with id="TARGET", so indexOf will return 0.
            // We check if there is a second occurrence.
            if (contentAfterId.indexOf('id="', firstIdIndex + 1) != -1) {
              return match
                  .group(0)!; // Return original string, unsafe replacement
            }
          }

          return '${match.group(1)}$colorHex';
        });
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_svgContent == null) {
      return const Center(child: Text('Failed to load map'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // The SVG Map
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: SvgPicture.string(
                _svgContent!,
                fit: BoxFit.contain,
              ),
            ),
            // Transparent touch targets
            // Note: This relies on fixed positions overlay.
            // Ideally, we would detect taps on the SVG directly, but flutter_svg hit testing is limited.
            // Keeping existing GestureDetector logic for now.
            ...widget.countries.map((country) {
              // Convert normalized position to local coordinates
              // Assuming the SVG aspect ratio is preserved and centered "contain"
              // We need to calculate the actual rect of the rendered SVG.

              // For a simple implementation, assuming 900x600 aspect ratio of the map
              double mapAspectRatio = 900 / 600;
              double widgetAspectRatio =
                  constraints.maxWidth / constraints.maxHeight;

              double displayedWidth, displayedHeight;
              double offsetX, offsetY;

              if (widgetAspectRatio > mapAspectRatio) {
                // Height constrained
                displayedHeight = constraints.maxHeight;
                displayedWidth = displayedHeight * mapAspectRatio;
                offsetX = (constraints.maxWidth - displayedWidth) / 2;
                offsetY = 0;
              } else {
                // Width constrained
                displayedWidth = constraints.maxWidth;
                displayedHeight = displayedWidth / mapAspectRatio;
                offsetX = 0;
                offsetY = (constraints.maxHeight - displayedHeight) / 2;
              }

              final left =
                  offsetX + (country.normalizedPosition.dx * displayedWidth);
              final top =
                  offsetY + (country.normalizedPosition.dy * displayedHeight);

              // Touch target size
              final size = 40.0;

              return Positioned(
                left: left - (size / 2),
                top: top - (size / 2),
                child: GestureDetector(
                  onTap: () => widget.onCountryTap(country),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Invisible click target
                      // border: Border.all(color: Colors.red), // Debug borders
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
