import 'package:equatable/equatable.dart';

enum TileState { normal, selected, matched }

class Tile extends Equatable {
  final int id;
  final int value;
  final int row;
  final int column;
  final TileState state;

  const Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.column,
    this.state = TileState.normal,
  });

  Tile copyWith({TileState? state}) {
    return Tile(
      id: id,
      value: value,
      row: row,
      column: column,
      state: state ?? this.state,
    );
  }

  // Game logic: Check if two tiles can match
  bool canMatchWith(Tile other) {
    return value == other.value || (value + other.value == 10);
  }

  // Game logic: Check adjacency (including line breaks)
  bool isAdjacentTo(Tile other) {
    int rowDiff = (row - other.row).abs();
    int colDiff = (column - other.column).abs();
    
    // Same row, adjacent columns
    if (rowDiff == 0 && colDiff == 1) return true;
    // Same column, adjacent rows  
    if (colDiff == 0 && rowDiff == 1) return true;
    // Line break: end of row to start of next row
    if (rowDiff == 1 && 
        ((row < other.row && column == 6 && other.column == 0) ||
         (row > other.row && other.column == 6 && column == 0))) {
      return true;
    }
    
    return false;
  }

  @override
  List<Object?> get props => [id, value, row, column, state];
}
