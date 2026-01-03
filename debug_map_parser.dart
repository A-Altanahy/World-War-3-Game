import 'dart:io';

void main() {
  final file = File('assets/original_map(20).svg');
  if (!file.existsSync()) {
    print('Error: File not found');
    return;
  }
  final svgString = file.readAsStringSync();

  print('Loaded SVG length: ${svgString.length}');

  // Regex to find IDs (supports double and single quotes)
  final idRegex = RegExp(r'id=["\047]([^"\047]+)["\047]');
  final allIdMatches = idRegex.allMatches(svgString);

  print('Found ${allIdMatches.length} ID matches.');

  int matchesFound = 0;

  // Simulate Country List
  // From getQuickMapCountries:
  // Country 100 -> svgId: Vector
  // Country 101 -> svgId: Vector_2
  // ...
  final targetIds = {
    'Vector',
    'Vector_2',
    'Vector_3',
    'Vector_4',
    'Vector_5',
    'Vector_6',
    'Vector_7',
    'Vector_8',
    'Vector_9',
    'Vector_10',
    'Vector_11',
    'Vector_12',
    'Vector_13',
    'Vector_14',
    'Vector_15',
    'Vector_16',
    'Vector_17'
  };

  for (final match in allIdMatches) {
    String originalId = match.group(1)!;

    // Normalized check used in VectorMap (flawed for Vector IDs?)
    String normId =
        'Country${int.tryParse(originalId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0}';

    if (targetIds.contains(originalId)) {
      print('MATCH FOUND: $originalId (Norm: $normId)');
      matchesFound++;

      // Check D attribute logic
      int tagStart = svgString.lastIndexOf('<', match.start);
      if (tagStart == -1) tagStart = match.start;

      int tagEnd = svgString.indexOf('>', match.start);
      if (tagEnd == -1) tagEnd = svgString.length;

      String tagContent = svgString.substring(tagStart, tagEnd + 1);

      var dMatch = RegExp(r'(?:^|\s)d="([^"]+)"').firstMatch(tagContent);
      dMatch ??= RegExp(r"(?:^|\s)d='([^']+)'").firstMatch(tagContent);

      if (dMatch != null) {
        print('  -> Direct d attribute found.');
      } else {
        print('  -> No direct d attribute. Checking children...');
        int childSearchEnd = (tagEnd + 50000).clamp(0, svgString.length);
        final childContext = svgString.substring(tagEnd, childSearchEnd);
        final childDMatch =
            RegExp(r'<path[^>]*d="([^"]+)"').firstMatch(childContext);
        if (childDMatch != null) {
          print('  -> Child path d found!');
        } else {
          print('  -> NO PATH DATA FOUND for $originalId');
        }
      }
    } else {
      // print('Ignored: $originalId');
    }
  }

  print('Total Matches with Target IDs: $matchesFound / ${targetIds.length}');
}
