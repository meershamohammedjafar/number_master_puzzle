import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_state.dart';
import 'package:number_master_puzzle/features/game/data/models/tile.dart';
import 'package:number_master_puzzle/core/constants/app_constants.dart';

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(const GameState());
  
  Timer? _gameTimer;
  final Random _random = Random();
  int _tileIdCounter = 0;
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
  
  // Initialize a new game
  void initializeGame(int level) {
    _gameTimer?.cancel();
    _tileIdCounter = 0;
    
    final config = LevelConfig.levels[level]!;
    final tiles = _generateInitialTiles(
      config['initialNumbers'] as int,
      config['allowedNumbers'] as List<int>,
    );
    
    state = GameState(
      tiles: tiles,
      currentLevel: level,
      score: 0,
      status: GameStatus.initial,
      timeRemaining: GameConstants.levelTimeLimit,
      maxAddRows: config['addRowLimit'] as int,
    );
  }
  
  // Start the game
  void startGame() {
    if (state.status != GameStatus.initial && state.status != GameStatus.paused) return;
    
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
  }
  
  // Pause the game
  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    
    _gameTimer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }
  
  // Resume the game
  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
  }
  
  // Handle tile tap
  void onTileTapped(Tile tappedTile) {
    if (state.status != GameStatus.playing || state.isAnimating) return;
    if (tappedTile.state == TileState.matched) return;
    
    final currentSelected = state.selectedTile;
    
    if (currentSelected == null) {
      // First tile selection
      _selectTile(tappedTile);
    } else if (currentSelected.id == tappedTile.id) {
      // Deselect the same tile
      _deselectTile();
    } else {
      // Second tile selection - check for match
      _attemptMatch(currentSelected, tappedTile);
    }
  }
  
  // Select a tile
  void _selectTile(Tile tile) {
    final updatedTiles = state.tiles.map((t) {
      if (t.id == tile.id) {
        return t.copyWith(state: TileState.selected);
      }
      return t;
    }).toList();
    
    state = state.copyWith(
      tiles: updatedTiles,
      selectedTile: tile.copyWith(state: TileState.selected),
    );
  }
  
  // Deselect current tile
  void _deselectTile() {
    final updatedTiles = state.tiles.map((t) {
      if (t.id == state.selectedTile?.id) {
        return t.copyWith(state: TileState.normal);
      }
      return t;
    }).toList();
    
    state = state.copyWith(
      tiles: updatedTiles,
      clearSelectedTile: true,
    );
  }
  
  // Attempt to match two tiles
  void _attemptMatch(Tile tile1, Tile tile2) {
    if (tile1.canMatchWith(tile2) && tile1.isAdjacentTo(tile2, GameConstants.gridColumns)) {
      _performMatch(tile1, tile2);
    } else {
      _performInvalidMatch(tile2);
    }
  }
  
  // Perform a valid match
  void _performMatch(Tile tile1, Tile tile2) {
    state = state.copyWith(isAnimating: true);
    
    final updatedTiles = state.tiles.map((t) {
      if (t.id == tile1.id || t.id == tile2.id) {
        return t.copyWith(state: TileState.matched);
      }
      return t;
    }).toList();
    
    final newScore = state.score + GameConstants.matchScore;
    
    // Simulate animation delay
    Future.delayed(GameConstants.matchAnimationDuration, () {
      state = state.copyWith(
        tiles: updatedTiles,
        score: newScore,
        clearSelectedTile: true,
        isAnimating: false,
        message: 'Great match! +${GameConstants.matchScore} points',
      );
      
      // Clear message after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          state = state.copyWith(clearMessage: true);
        }
      });
      
      // Check if level is completed
      _checkLevelCompletion();
    });
  }
  
  // Perform invalid match animation
  void _performInvalidMatch(Tile tile2) {
    state = state.copyWith(isAnimating: true);
    
    final updatedTiles = state.tiles.map((t) {
      if (t.id == tile2.id) {
        return t.copyWith(state: TileState.selected);
      } else if (t.id == state.selectedTile?.id) {
        return t.copyWith(state: TileState.normal);
      }
      return t;
    }).toList();
    
    // Simulate shake animation
    Future.delayed(GameConstants.invalidAnimationDuration, () {
      if (mounted) {
        final finalTiles = updatedTiles.map((t) {
          if (t.state == TileState.selected) {
            return t.copyWith(state: TileState.normal);
          }
          return t;
        }).toList();
        
        state = state.copyWith(
          tiles: finalTiles,
          clearSelectedTile: true,
          isAnimating: false,
          message: 'Invalid match! Try adjacent tiles.',
        );
        
        // Clear message after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            state = state.copyWith(clearMessage: true);
          }
        });
      }
    });
  }
  
  // Add a new row of tiles
  void addRow() {
    if (!state.canAddRow || state.status != GameStatus.playing) return;
    
    final currentMaxRow = state.tiles.isEmpty ? -1 : 
        state.tiles.map((t) => t.row).reduce((a, b) => a > b ? a : b);
    final newRow = currentMaxRow + 1;
    
    final newTiles = <Tile>[];
    final allowedNumbers = LevelConfig.levels[state.currentLevel]!['allowedNumbers'] as List<int>;
    
    for (int col = 0; col < GameConstants.gridColumns; col++) {
      final value = allowedNumbers[_random.nextInt(allowedNumbers.length)];
      newTiles.add(Tile(
        id: _tileIdCounter++,
        value: value,
        row: newRow,
        column: col,
      ));
    }
    
    state = state.copyWith(
      tiles: [...state.tiles, ...newTiles],
      addRowsUsed: state.addRowsUsed + 1,
      message: 'New row added!',
    );
    
    // Clear message after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        state = state.copyWith(clearMessage: true);
      }
    });
  }
  
  // Check if level is completed
  void _checkLevelCompletion() {
    if (state.isLevelCompleted) {
      _gameTimer?.cancel();
      
      final timeBonus = state.timeRemaining.inSeconds * GameConstants.timeBonus;
      final totalScore = state.score + GameConstants.levelCompleteBonus + timeBonus;
      
      state = state.copyWith(
        status: GameStatus.completed,
        score: totalScore,
        message: 'Level completed! Bonus: ${GameConstants.levelCompleteBonus + timeBonus}',
      );
    }
  }
  
  // Start game timer
  void _startTimer() {
    _gameTimer?.cancel();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final newTime = Duration(seconds: state.timeRemaining.inSeconds - 1);
      
      if (newTime.inSeconds <= 0) {
        timer.cancel();
        state = state.copyWith(
          timeRemaining: Duration.zero,
          status: GameStatus.gameOver,
          message: 'Time\'s up! Game over.',
        );
      } else {
        state = state.copyWith(timeRemaining: newTime);
      }
    });
  }
  
  // Generate initial tiles for the level
  List<Tile> _generateInitialTiles(int count, List<int> allowedNumbers) {
    final tiles = <Tile>[];
    final rows = (count / GameConstants.gridColumns).ceil();
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < GameConstants.gridColumns; col++) {
        if (tiles.length >= count) break;
        
        final value = allowedNumbers[_random.nextInt(allowedNumbers.length)];
        tiles.add(Tile(
          id: _tileIdCounter++,
          value: value,
          row: row,
          column: col,
        ));
      }
    }
    
    return tiles;
  }
  
  // Reset game
  void resetGame() {
    _gameTimer?.cancel();
    initializeGame(state.currentLevel);
  }
  
  // Go to next level
  void nextLevel() {
    if (state.currentLevel < GameConstants.totalLevels) {
      initializeGame(state.currentLevel + 1);
    }
  }
}

// Game provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});