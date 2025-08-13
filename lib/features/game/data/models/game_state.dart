import 'package:equatable/equatable.dart';
import 'tile.dart';

enum GameStatus {
  initial,
  playing,
  paused,
  completed,
  gameOver,
}

class GameState extends Equatable {
  final List<Tile> tiles;
  final int currentLevel;
  final int score;
  final GameStatus status;
  final Duration timeRemaining;
  final Tile? selectedTile;
  final int addRowsUsed;
  final int maxAddRows;
  final String? message;
  final bool isAnimating;
  
  const GameState({
    this.tiles = const [],
    this.currentLevel = 1,
    this.score = 0,
    this.status = GameStatus.initial,
    this.timeRemaining = const Duration(minutes: 2),
    this.selectedTile,
    this.addRowsUsed = 0,
    this.maxAddRows = 2,
    this.message,
    this.isAnimating = false,
  });
  
  GameState copyWith({
    List<Tile>? tiles,
    int? currentLevel,
    int? score,
    GameStatus? status,
    Duration? timeRemaining,
    Tile? selectedTile,
    int? addRowsUsed,
    int? maxAddRows,
    String? message,
    bool? isAnimating,
    bool clearSelectedTile = false,
    bool clearMessage = false,
  }) {
    return GameState(
      tiles: tiles ?? this.tiles,
      currentLevel: currentLevel ?? this.currentLevel,
      score: score ?? this.score,
      status: status ?? this.status,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      selectedTile: clearSelectedTile ? null : (selectedTile ?? this.selectedTile),
      addRowsUsed: addRowsUsed ?? this.addRowsUsed,
      maxAddRows: maxAddRows ?? this.maxAddRows,
      message: clearMessage ? null : (message ?? this.message),
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
  
  // Get tiles organized by grid structure
  List<List<Tile?>> get tilesGrid {
    if (tiles.isEmpty) return [];
    
    final maxRow = tiles.map((t) => t.row).reduce((a, b) => a > b ? a : b);
    final maxCol = tiles.map((t) => t.column).reduce((a, b) => a > b ? a : b);
    
    final grid = List.generate(
      maxRow + 1, 
      (row) => List.generate(maxCol + 1, (col) => null as Tile?),
    );
    
    for (final tile in tiles) {
      if (tile.isVisible) {
        grid[tile.row][tile.column] = tile;
      }
    }
    
    return grid;
  }
  
  // Get visible tiles only
  List<Tile> get visibleTiles => tiles.where((tile) => tile.isVisible).toList();
  
  // Get matched tiles count
  int get matchedTilesCount => tiles.where((tile) => tile.state == TileState.matched).length;
  
  // Check if level is completed (all tiles matched or no valid moves)
  bool get isLevelCompleted {
    final visible = visibleTiles;
    if (visible.isEmpty) return true;
    
    // Check if all visible tiles are matched
    final unmatched = visible.where((tile) => tile.state != TileState.matched).toList();
    if (unmatched.isEmpty) return true;
    
    // Check if any valid moves remain
    return !hasValidMoves;
  }
  
  // Check if there are any valid moves available
  bool get hasValidMoves {
    final visible = visibleTiles.where((tile) => tile.state != TileState.matched).toList();
    
    for (int i = 0; i < visible.length - 1; i++) {
      for (int j = i + 1; j < visible.length; j++) {
        final tile1 = visible[i];
        final tile2 = visible[j];
        
        if (tile1.canMatchWith(tile2) && tile1.isAdjacentTo(tile2, 7)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  // Calculate progress as percentage
  double get progress {
    if (tiles.isEmpty) return 0.0;
    return matchedTilesCount / tiles.length;
  }
  
  // Check if game is over (time up or no moves)
  bool get isGameOver {
    return status == GameStatus.gameOver || 
           timeRemaining.inSeconds <= 0 || 
           (status == GameStatus.playing && !hasValidMoves && !canAddRow);
  }
  
  // Check if can add more rows
  bool get canAddRow => addRowsUsed < maxAddRows;
  
  @override
  List<Object?> get props => [
    tiles,
    currentLevel,
    score,
    status,
    timeRemaining,
    selectedTile,
    addRowsUsed,
    maxAddRows,
    message,
    isAnimating,
  ];
  
  @override
  String toString() {
    return 'GameState(level: $currentLevel, score: $score, status: $status, tiles: ${tiles.length})';
  }
}