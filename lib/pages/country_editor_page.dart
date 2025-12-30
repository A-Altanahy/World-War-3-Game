// lib/pages/country_editor_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import '../models/country.dart';
import '../models/country_configuration.dart';
import '../services/configuration_service.dart';
import '../utils/coordinate_converter.dart';
import '../widgets/debug_overlay.dart';

class CountryEditorPage extends StatefulWidget {
  final CountryConfiguration? existingConfiguration;

  const CountryEditorPage({super.key, this.existingConfiguration});

  @override
  State<CountryEditorPage> createState() => _CountryEditorPageState();
}

class _CountryEditorPageState extends State<CountryEditorPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  List<Country> _countries = [];
  bool _isDragging = false;
  Offset? _lastClickPosition; // Debug: track last click position

  late String _configurationId;

  @override
  void initState() {
    super.initState();
    if (widget.existingConfiguration != null) {
      _configurationId = widget.existingConfiguration!.id;
      _nameController.text = widget.existingConfiguration!.name;
      _countries = List.from(widget.existingConfiguration!.countries);
    } else {
      _configurationId = _uuid.v4();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addCountry(Offset position, Size containerSize) {
    if (_isDragging) return;

    // Convert absolute position to normalized coordinates using proper SVG layout
    final normalizedPosition =
        CoordinateConverter.editorToNormalized(position, containerSize);

    final countryId = _uuid.v4();
    final country = Country(
      id: countryId,
      name: 'Country ${_countries.length + 1}',
      normalizedPosition: normalizedPosition,
    );

    setState(() {
      _countries.add(country);
    });
  }

  void _deleteCountry(String countryId) {
    setState(() {
      _countries.removeWhere((country) => country.id == countryId);
    });
  }

  void _editCountryName(Country country) {
    final controller = TextEditingController(text: country.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل اسم البلد'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم البلد',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  country.name = controller.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _updateCountryPosition(
      String countryId, Offset newPosition, Size containerSize) {
    final countryIndex = _countries.indexWhere((c) => c.id == countryId);
    if (countryIndex != -1) {
      // Convert absolute position to normalized coordinates using proper SVG layout
      final normalizedPosition =
          CoordinateConverter.editorToNormalized(newPosition, containerSize);

      setState(() {
        _countries[countryIndex] = _countries[countryIndex].copyWith(
          normalizedPosition: normalizedPosition,
        );
      });
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_countries.isEmpty) {
      // Error message removed
      return;
    }

    final configuration = CountryConfiguration(
      id: _configurationId,
      name: _nameController.text,
      countries: _countries,
      createdAt: widget.existingConfiguration?.createdAt ?? DateTime.now(),
      lastModified: DateTime.now(),
    );

    try {
      await ConfigurationService.saveConfiguration(configuration);
      if (mounted) {
        // Success message removed
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // Error message removed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingConfiguration != null
            ? 'تعديل التكوين'
            : 'إنشاء تكوين جديد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfiguration,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Configuration name input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم التكوين',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم التكوين';
                    }
                    return null;
                  },
                ),
              ),
            ),
            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'نقرة يسار على الخريطة لإضافة بلد • نقرة طويلة واسحب لتحريك بلد • نقرة يمين على بلد لتعديل أو حذف',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Countries count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'عدد البلدان: ${_countries.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            // Map with countries
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final containerSize =
                          Size(constraints.maxWidth, constraints.maxHeight);

                      return GestureDetector(
                        onTapUp: (details) {
                          final localPosition = details.localPosition;
                          setState(() {
                            _lastClickPosition =
                                localPosition; // Track for debugging
                          });
                          _addCountry(localPosition, containerSize);
                        },
                        child: Stack(
                          children: [
                            // SVG Map Background
                            SvgPicture.asset(
                              'assets/game_map.svg',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            // Debug overlay to visualize SVG bounds
                            DebugOverlay(
                              containerSize: containerSize,
                              showSvgBounds: true,
                              showGrid: false,
                            ),
                            // Country markers
                            ..._countries.map((country) {
                              // Convert normalized position to absolute position using proper SVG layout
                              final absolutePosition =
                                  CoordinateConverter.normalizedToEditor(
                                      country.normalizedPosition,
                                      containerSize);

                              return Positioned(
                                left: absolutePosition.dx - 20,
                                top: absolutePosition.dy - 20,
                                child: LongPressDraggable<String>(
                                  data: country.id,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: _buildCountryMarker(country,
                                        isDragging: true),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildCountryMarker(country),
                                  ),
                                  onDragStarted: () {
                                    setState(() {
                                      _isDragging = true;
                                    });
                                  },
                                  onDragEnd: (details) {
                                    setState(() {
                                      _isDragging = false;
                                    });

                                    final RenderBox renderBox =
                                        context.findRenderObject() as RenderBox;
                                    final localPosition =
                                        renderBox.globalToLocal(details.offset);

                                    // Add offset to center the marker (20 is half of 40 width/height)
                                    final centeredPosition =
                                        localPosition + const Offset(20, 20);

                                    _updateCountryPosition(country.id,
                                        centeredPosition, containerSize);
                                  },
                                  child: _buildCountryMarker(country),
                                ),
                              );
                            }).toList(),
                            // Debug: Show last click position
                            if (_lastClickPosition != null)
                              Positioned(
                                left: _lastClickPosition!.dx - 5,
                                top: _lastClickPosition!.dy - 5,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryMarker(Country country, {bool isDragging = false}) {
    return GestureDetector(
      onTap: () => _showCountryOptions(country),
      // onSecondaryTap: () => _showCountryOptions(country), // Removed in favor of onTap for better UX
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDragging ? Colors.blue.withOpacity(0.8) : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            country.name.length > 8
                ? '${country.name.substring(0, 1)}'
                : country.name.length > 4
                    ? '${country.name.substring(0, 2)}'
                    : country.name.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryOptions(Country country) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              country.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل الاسم'),
              onTap: () {
                Navigator.pop(context);
                _editCountryName(country);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('حذف البلد', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteCountry(country.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
