import 'package:equatable/equatable.dart';

enum TileState {
  normal,
  selected,
  matched,
  faded,
}

class Tile extends Equatable {
  final int id;
  final int value;
  final int row;
  final int column;
  final TileState state;
  final bool isVisible;
  
  const Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.column,
    this.state = TileState.normal,
    this.isVisible = true,
  });
  
  Tile copyWith({
    int? id,
    int? value,
    int? row,
    int? column,
    TileState? state,
    bool? isVisible,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      column: column ?? this.column,
      state: state ?? this.state,
      isVisible: isVisible ?? this.isVisible,
    );
  }
  
  // Check if two tiles can be matched based on Number Master rules
  bool canMatchWith(Tile other) {
    if (!isVisible || !other.isVisible) return false;
    if (state == TileState.matched || other.state == TileState.matched) return false;
    
    // Rule 1: Same numbers can be matched
    if (value == other.value) return true;
    
    // Rule 2: Numbers that sum to 10 can be matched
    if (value + other.value == 10) return true;
    
    return false;
  }
  
  // Check if two tiles are adjacent (horizontally, vertically, or across line breaks)
  bool isAdjacentTo(Tile other, int gridColumns) {
    final rowDiff = (row - other.row).abs();
    final colDiff = (column - other.column).abs();
    
    // Same row, adjacent columns
    if (rowDiff == 0 && colDiff == 1) return true;
    
    // Same column, adjacent rows
    if (colDiff == 0 && rowDiff == 1) return true;
    
    // Across line breaks: end of line to beginning of next line
    if (rowDiff == 1 && 
        ((row < other.row && column == gridColumns - 1 && other.column == 0) ||
         (row > other.row && other.column == gridColumns - 1 && column == 0))) {
      return true;
    }
    
    return false;
  }
  
  @override
  List<Object?> get props => [id, value, row, column, state, isVisible];
  
  @override
  String toString() {
    return 'Tile(id: $id, value: $value, row: $row, col: $column, state: $state)';
  }
}