import 'package:flutter/material.dart';
import '../models/country_configuration.dart';
import '../theme/app_theme.dart';
import '../widgets/map_preview_card.dart';
import 'team_setup_page.dart';
import '../models/country_positions.dart';

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage>
    with TickerProviderStateMixin {
  List<CountryConfiguration> _configurations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
  }

  Future<void> _loadConfigurations() async {
    // Hardcoded configurations for the two maps
    final config42 = CountryConfiguration(
      id: 'map_42',
      name: 'خريطة 42 منطقة', // 42 Lands Map
      countries: getInitialCountries(),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      interactiveMapAsset: 'assets/original_full_map(42).svg',
    );

    final config20 = CountryConfiguration(
      id: 'map_20',
      name: 'خريطة 20 منطقة', // 20 Lands Map
      countries: getInitialCountries(count: 20),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      interactiveMapAsset: 'assets/original_map(20).svg',
    );

    setState(() {
      _configurations = [config42, config20];
      _isLoading = false;
    });
  }

  // Removed _createDefaultConfiguration and _navigateToEditor as we don't want custom maps now

  void _selectConfiguration(CountryConfiguration config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamSetupPage(configuration: config),
      ),
    );
  }

  // Removed _deleteConfiguration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryNeon))
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Text(
                'اختر الخريطة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          // "Design Map" button removed
        ],
      ),
    );
  }

  Widget _buildContent() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _configurations.length,
      itemBuilder: (context, index) {
        final config = _configurations[index];
        return MapPreviewCard(
          config: config,
          onTap: () => _selectConfiguration(config),
          // Disable edit/delete
          onEdit: null,
          onDelete: null,
        );
      },
    );
  }
}
