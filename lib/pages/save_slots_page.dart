import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/command_card.dart';
import '../services/game_storage_service.dart';
import '../services/question_service.dart';
import '../game_state.dart';
import '../map_page.dart';

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

        final gameState = GameState(
          teams: [],
          countries: [],
          questionService: questionService,
        );

        gameState.restoreState(gameStateMap);

        // Pass the slot ID to the GameState or manage it globally so next save uses same slot
        // For now, we assumption verification of loading is key.
        // TODO: Ensure MapPage knows current slot to save back to it.

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: gameState,
                child: MapPage(
                    slotId: slotId,
                    mapAsset: 'assets/original_full_map(42).svg'),
              ),
            ),
          ).then((_) => _loadSlots());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load game')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSlot(int slotId) async {
    await _storageService.clearSlot(slotId);
    _loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.darkBackground, // Ensure consistency if transparent
      body: Container(
        // For bg image or gradient
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
          Text(
            'اختر ملف الحفظ',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3, // Fixed 3 slots
      itemBuilder: (context, index) {
        final slotId = index + 1;
        final metadata = _slots[slotId];
        return _buildSlotCard(slotId, metadata);
      },
    );
  }

  Widget _buildSlotCard(int slotId, SaveSlotMetadata? metadata) {
    bool isOccupied = metadata != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CommandCard(
        height: 120,
        onTap: isOccupied ? () => _loadGame(slotId) : null,
        glowColor: isOccupied ? AppTheme.primaryNeon : Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Slot Number / Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOccupied ? AppTheme.primaryNeon : Colors.white24,
                    width: 2,
                  ),
                  color: isOccupied
                      ? AppTheme.primaryNeon.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    '$slotId',
                    style: TextStyle(
                      color: isOccupied ? AppTheme.primaryNeon : Colors.white24,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Info
              Expanded(
                child: isOccupied
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'حفظ تلقائي $slotId', // Could allow custom names later
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${metadata.teamCount} فرق • ${metadata.countryCount} دولة • ${_formatDate(metadata.lastPlayed)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'فتحة فارغة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 18,
                        ),
                      ),
              ),

              // Actions
              if (isOccupied)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.warningRed),
                  onPressed: () => _deleteSlot(slotId),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
