import 'package:equatable/equatable.dart';
import 'tile.dart';

enum GameStatus { idle, playing, paused, won, lost }

class GameState extends Equatable {
  final List<Tile> tiles;
  final int score;
  final int timeRemaining;
  final GameStatus status;
  final int level;
  final Tile? selectedTile;
  final String? message;

  const GameState({
    required this.tiles,
    required this.score,
    required this.timeRemaining,
    required this.status,
    required this.level,
    this.selectedTile,
    this.message,
  });

  GameState copyWith({
    List<Tile>? tiles,
    int? score,
    int? timeRemaining,
    GameStatus? status,
    int? level,
    Tile? selectedTile,
    String? message,
    bool clearSelectedTile = false,
    bool clearMessage = false,
  }) {
    return GameState(
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      status: status ?? this.status,
      level: level ?? this.level,
      selectedTile: clearSelectedTile ? null : (selectedTile ?? this.selectedTile),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  // Utility: Get progress percentage
  double get progress {
    if (tiles.isEmpty) return 0.0;
    final matchedCount = tiles.where((t) => t.state == TileState.matched).length;
    return matchedCount / tiles.length;
  }

  // Utility: Check if level is complete
  bool get isLevelComplete => tiles.every((t) => t.state == TileState.matched);

  // Utility: Get tiles as 2D grid for display
  List<List<Tile?>> get tilesGrid {
    if (tiles.isEmpty) return [];
    
    final maxRow = tiles.map((t) => t.row).reduce((a, b) => a > b ? a : b);
    final grid = List.generate(maxRow + 1, (row) => 
      List.generate(7, (col) => null as Tile?)
    );
    
    for (final tile in tiles) {
      grid[tile.row][tile.column] = tile;
    }
    
    return grid;
  }

  @override
  List<Object?> get props => [tiles, score, timeRemaining, status, level, selectedTile, message];
}
