import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/command_card.dart';
import '../services/game_storage_service.dart';
import '../services/question_service.dart';
import '../game_state.dart';
import '../map_page.dart';
import '../models/country.dart';
import '../models/country_positions.dart';

class SaveSlotsPage extends StatefulWidget {
  const SaveSlotsPage({super.key});

  @override
  State<SaveSlotsPage> createState() => _SaveSlotsPageState();
}

class _SaveSlotsPageState extends State<SaveSlotsPage> {
  final GameStorageService _storageService = GameStorageService();
  Map<int, SaveSlotMetadata> _slots = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    try {
      final slots = await _storageService.getSlotsMetadata();
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGame(int slotId) async {
    setState(() => _isLoading = true);

    try {
      final gameStateMap = await _storageService.loadGame(slotId);

      if (gameStateMap != null) {
        final questionService = QuestionService();
        await questionService.initialize();

        // Determine map type from saved data
        // Determine map type from saved data
        bool is20Map = false;
        List countriesList = [];
        try {
          countriesList = gameStateMap['countries'] as List;
        } catch (e) {
          print('Error reading countries list: $e');
        }

        // 1. Check explicitly saved mapAsset (Preferred)
        if (gameStateMap.containsKey('mapAsset')) {
          final savedMapAsset = gameStateMap['mapAsset'] as String;
          print('Loading Game: Found mapAsset: $savedMapAsset'); // Debug log
          if (savedMapAsset.contains('(20)')) {
            is20Map = true;
          }
        }

        // 2. Fallback: Check country count (Robust)
        // Note: The "20 country" map actually has 16 defined countries in code.
        // We allow a small range to account for potential variations or miscounting.
        if (!is20Map && countriesList.isNotEmpty) {
          if (countriesList.length >= 15 && countriesList.length <= 22) {
            print(
                'Loading Game: Detected Quick Map by count (${countriesList.length}). forcing is20Map = true');
            is20Map = true;
          }
        }

        // 3. Fallback: Check IDs (Legacy)
        if (!is20Map && countriesList.isNotEmpty) {
          is20Map = countriesList.any((c) {
            final id = int.tryParse(c['id'].toString()) ?? 0;
            return id >= 100;
          });
        }

        print('Loading Game: is20Map = $is20Map');

        List<Country> baseCountries;
        String determinedMapAsset;

        if (is20Map) {
          determinedMapAsset = 'assets/original_map(20).svg';
          baseCountries = getInitialCountries(count: 20);
        } else {
          determinedMapAsset = 'assets/original_full_map(42).svg';
          baseCountries = getInitialCountries(count: 42);
        }

        final gameState = GameState(
          teams: [],
          countries: baseCountries,
          questionService: questionService,
          mapAsset: determinedMapAsset,
        );

        gameState.restoreState(gameStateMap);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: gameState,
                child: MapPage(
                  slotId: slotId,
                  mapAsset: determinedMapAsset,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل اللعبة')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSlot(int slotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('حذف الحفظ', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد من حذف هذا الحفظ؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warningRed),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearSlot(slotId);
      _loadSlots();
    }
  }

  Future<void> _renameSlot(int slotId, String currentName) async {
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('تغيير اسم الحفظ',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'اسم الحفظ',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryNeon),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryNeon, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('حفظ',
                style: TextStyle(color: AppTheme.primaryNeon)),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _storageService.renameSave(slotId, newName);
      _loadSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    : _slots.isEmpty
                        ? _buildEmptyState()
                        : _buildSlotsList(),
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'استكمال المعركة',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد ألعاب محفوظة',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ معركة جديدة واحفظها للمتابعة لاحقاً',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsList() {
    final sortedSlots = _slots.entries.toList()
      ..sort((a, b) => b.value.lastPlayed.compareTo(a.value.lastPlayed));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: sortedSlots.length,
      itemBuilder: (context, index) {
        final entry = sortedSlots[index];
        return _buildSlotCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildSlotCard(int slotId, SaveSlotMetadata metadata) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CommandCard(
        height: 100,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        onTap: () => _loadGame(slotId),
        glowColor: AppTheme.accentOrange,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              // Slot Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentOrange, width: 2),
                  color: AppTheme.accentOrange.withOpacity(0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.save,
                    color: AppTheme.accentOrange,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      metadata.saveName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${metadata.teamCount} فرق • ${metadata.countryCount} دولة',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(metadata.lastPlayed),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Buttons - constrained row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppTheme.primaryNeon, size: 20),
                    onPressed: () => _renameSlot(slotId, metadata.saveName),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.warningRed, size: 20),
                    onPressed: () => _deleteSlot(slotId),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
