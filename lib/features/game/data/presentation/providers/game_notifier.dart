import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_master_puzzle/features/game/data/models/game_state.dart';
import 'package:number_master_puzzle/features/game/data/models/tile.dart';

class GameNotifier extends StateNotifier<GameState> {
  Timer? _gameTimer;
  final Random _random = Random();
  int _tileIdCounter = 0;

  GameNotifier() : super(const GameState(
    tiles: [],
    score: 0,
    timeRemaining: 120,
    status: GameStatus.idle,
    level: 1,
  ));

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  // Initialize game for a specific level
  void initializeGame(int level) {
    _gameTimer?.cancel();
    _tileIdCounter = 0;
    
    final rows = 3 + level; // Level 1=4 rows, Level 2=5 rows, Level 3=6 rows
    final tiles = _generateTiles(rows, 7);
    
    state = GameState(
      tiles: tiles,
      score: 0,
      timeRemaining: 120,
      status: GameStatus.playing,
      level: level,
    );
    
    _startTimer();
  }

  // Generate tiles for the grid
  List<Tile> _generateTiles(int rows, int columns) {
    final tiles = <Tile>[];
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        tiles.add(Tile(
          id: _tileIdCounter++,
          value: _random.nextInt(9) + 1,
          row: row,
          column: col,
        ));
      }
    }
    
    return tiles;
  }

  // Start the game timer
  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0 && state.status == GameStatus.playing) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else if (state.timeRemaining <= 0) {
        timer.cancel();
        state = state.copyWith(
          status: GameStatus.lost,
          message: 'Time\'s up! Game over.',
        );
      }
    });
  }

  // Handle tile tap
  void onTileTapped(Tile tappedTile) {
    if (state.status != GameStatus.playing) return;
    if (tappedTile.state == TileState.matched) return;

    final currentSelected = state.selectedTile;

    if (currentSelected == null) {
      _selectTile(tappedTile);
    } else if (currentSelected.id == tappedTile.id) {
      _deselectTile();
    } else {
      _attemptMatch(currentSelected, tappedTile);
    }
  }

  void _selectTile(Tile tile) {
    final updatedTiles = state.tiles.map((t) {
      return t.id == tile.id ? t.copyWith(state: TileState.selected) : t;
    }).toList();

    state = state.copyWith(
      tiles: updatedTiles,
      selectedTile: tile.copyWith(state: TileState.selected),
    );
  }

  void _deselectTile() {
    final updatedTiles = state.tiles.map((t) {
      return t.id == state.selectedTile?.id ? t.copyWith(state: TileState.normal) : t;
    }).toList();

    state = state.copyWith(
      tiles: updatedTiles,
      clearSelectedTile: true,
    );
  }

  void _attemptMatch(Tile tile1, Tile tile2) {
    if (tile1.canMatchWith(tile2) && tile1.isAdjacentTo(tile2)) {
      _performMatch(tile1, tile2);
    } else {
      _performInvalidMatch();
    }
  }

  void _performMatch(Tile tile1, Tile tile2) {
    final updatedTiles = state.tiles.map((t) {
      return (t.id == tile1.id || t.id == tile2.id) 
          ? t.copyWith(state: TileState.matched)
          : t;
    }).toList();

    state = state.copyWith(
      tiles: updatedTiles,
      score: state.score + 10,
      clearSelectedTile: true,
      message: 'Great match! +10 points',
    );

    // Clear message after delay
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(clearMessage: true);
    });

    // Check if level completed
    if (state.isLevelComplete) {
      _gameTimer?.cancel();
      state = state.copyWith(
        status: GameStatus.won,
        message: 'Level completed! Well done!',
      );
    }
  }

  void _performInvalidMatch() {
    state = state.copyWith(
      clearSelectedTile: true,
      message: 'Invalid match! Tiles must be adjacent and matching.',
    );

    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(clearMessage: true);
    });
  }

  // Add new row
  void addRow() {
    if (state.status != GameStatus.playing) return;

    final currentMaxRow = state.tiles.isEmpty ? -1 : 
        state.tiles.map((t) => t.row).reduce((a, b) => a > b ? a : b);
    final newRow = currentMaxRow + 1;

    final newTiles = <Tile>[];
    for (int col = 0; col < 7; col++) {
      newTiles.add(Tile(
        id: _tileIdCounter++,
        value: _random.nextInt(9) + 1,
        row: newRow,
        column: col,
      ));
    }

    state = state.copyWith(
      tiles: [...state.tiles, ...newTiles],
      message: 'New row added!',
    );

    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(clearMessage: true);
    });
  }

  // Reset game
  void resetGame() {
    _gameTimer?.cancel();
    initializeGame(state.level);
  }

  // Pause/Resume
  void pauseGame() {
    if (state.status == GameStatus.playing) {
      _gameTimer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startTimer();
    }
  }
}

// Provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
