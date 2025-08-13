import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_master_puzzle/features/game/data/models/game_state.dart';
import '../providers/game_provider.dart';
import 'tile_widget.dart';
import 'package:number_master_puzzle/core/constants/app_constants.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game board grid
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(8),
              child: _buildGameGrid(gameState, gameNotifier),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Add row button
          if (gameState.status == GameStatus.playing)
            _buildAddRowButton(gameState, gameNotifier),
        ],
      ),
    );
  }
  
  Widget _buildGameGrid(GameState gameState, GameNotifier gameNotifier) {
    if (gameState.tiles.isEmpty) {
      return const Center(
        child: Text(
          'Start a new game to begin!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    
    final tilesGrid = gameState.tilesGrid;
    
    return SingleChildScrollView(
      child: Column(
        children: tilesGrid.asMap().entries.map((rowEntry) {
          final rowIndex = rowEntry.key;
          final row = rowEntry.value;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: row.asMap().entries.map((colEntry) {
                final colIndex = colEntry.key;
                final tile = colEntry.value;
                
                if (tile == null) {
                  // Empty cell
                  return Expanded(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  );
                }
                
                return Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TileWidget(
                      tile: tile,
                      onTap: () => gameNotifier.onTileTapped(tile),
                      isAnimating: gameState.isAnimating &&
                          (tile.id == gameState.selectedTile?.id),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildAddRowButton(GameState gameState, GameNotifier gameNotifier) {
    final canAddRow = gameState.canAddRow;
    final remainingRows = gameState.maxAddRows - gameState.addRowsUsed;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: canAddRow ? () => gameNotifier.addRow() : null,
            icon: const Icon(Icons.add),
            label: Text(
              canAddRow 
                  ? 'Add Row ($remainingRows left)'
                  : 'No More Rows Available',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canAddRow ? Colors.orange : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          if (!canAddRow)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No valid moves? Game will end soon!',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Game controls widget
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Start/Resume button
          if (gameState.status == GameStatus.initial)
            ElevatedButton.icon(
              onPressed: () => gameNotifier.startGame(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          
          // Pause/Resume button
          if (gameState.status == GameStatus.playing)
            ElevatedButton.icon(
              onPressed: () => gameNotifier.pauseGame(),
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          
          if (gameState.status == GameStatus.paused)
            ElevatedButton.icon(
              onPressed: () => gameNotifier.resumeGame(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          
          // Reset button
          ElevatedButton.icon(
            onPressed: () => gameNotifier.resetGame(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
            ),
          ),
          
          // Next level button (only when completed)
          if (gameState.status == GameStatus.completed && 
              gameState.currentLevel < GameConstants.totalLevels)
            ElevatedButton.icon(
              onPressed: () => gameNotifier.nextLevel(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Level'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}