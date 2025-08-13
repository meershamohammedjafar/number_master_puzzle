import 'dart:math';
import '../constants/app_constants.dart';

class GameUtils {
  static final Random _random = Random();
  
  // Generate random numbers for tiles based on level
  static List<int> generateRandomNumbers(int count, List<int> allowedNumbers) {
    final numbers = <int>[];
    
    for (int i = 0; i < count; i++) {
      numbers.add(allowedNumbers[_random.nextInt(allowedNumbers.length)]);
    }
    
    return numbers;
  }
  
  // Check if two numbers can form a valid match
  static bool canMatch(int number1, int number2) {
    // Same numbers
    if (number1 == number2) return true;
    
    // Numbers that sum to 10
    if (number1 + number2 == GameConstants.targetSum) return true;
    
    return false;
  }
  
  // Calculate distance between two grid positions
  static double calculateDistance(int row1, int col1, int row2, int col2) {
    final dx = (col2 - col1).abs();
    final dy = (row2 - row1).abs();
    return sqrt(dx * dx + dy * dy);
  }
  
  // Check if two grid positions are adjacent
  static bool arePositionsAdjacent(
    int row1, 
    int col1, 
    int row2, 
    int col2, 
    int gridColumns
  ) {
    final rowDiff = (row1 - row2).abs();
    final colDiff = (col1 - col2).abs();
    
    // Same row, adjacent columns
    if (rowDiff == 0 && colDiff == 1) return true;
    
    // Same column, adjacent rows
    if (colDiff == 0 && rowDiff == 1) return true;
    
    // Across line breaks: end of line to beginning of next line
    if (rowDiff == 1 && 
        ((row1 < row2 && col1 == gridColumns - 1 && col2 == 0) ||
         (row1 > row2 && col2 == gridColumns - 1 && col1 == 0))) {
      return true;
    }
    
    return false;
  }
  
  // Convert 1D index to 2D grid coordinates
  static Map<String, int> indexToCoordinates(int index, int columns) {
    return {
      'row': index ~/ columns,
      'column': index % columns,
    };
  }
  
  // Convert 2D grid coordinates to 1D index
  static int coordinatesToIndex(int row, int column, int columns) {
    return row * columns + column;
  }
  
  // Format duration for display (MM:SS)
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Calculate score bonus based on time remaining
  static int calculateTimeBonus(Duration timeRemaining) {
    return timeRemaining.inSeconds * GameConstants.timeBonus;
  }
  
  // Get level configuration
  static Map<String, dynamic> getLevelConfig(int level) {
    return LevelConfig.levels[level] ?? LevelConfig.levels[1]!;
  }
  
  // Validate if a move is possible in current game state
  static bool isMoveValid(
    List<int> grid, 
    int index1, 
    int index2, 
    int columns,
  ) {
    if (index1 < 0 || index1 >= grid.length) return false;
    if (index2 < 0 || index2 >= grid.length) return false;
    if (index1 == index2) return false;
    
    final value1 = grid[index1];
    final value2 = grid[index2];
    
    // Check if numbers can match
    if (!canMatch(value1, value2)) return false;
    
    // Check if positions are adjacent
    final coord1 = indexToCoordinates(index1, columns);
    final coord2 = indexToCoordinates(index2, columns);
    
    return arePositionsAdjacent(
      coord1['row']!,
      coord1['column']!,
      coord2['row']!,
      coord2['column']!,
      columns,
    );
  }
  
  // Find all possible valid moves in current grid
  static List<Map<String, int>> findValidMoves(
    List<int> grid,
    int columns,
    {List<int> excludeIndices = const []}
  ) {
    final validMoves = <Map<String, int>>[];
    
    for (int i = 0; i < grid.length - 1; i++) {
      if (excludeIndices.contains(i)) continue;
      
      for (int j = i + 1; j < grid.length; j++) {
        if (excludeIndices.contains(j)) continue;
        
        if (isMoveValid(grid, i, j, columns)) {
          validMoves.add({'index1': i, 'index2': j});
        }
      }
    }
    
    return validMoves;
  }
  
  // Generate hint for next possible move
  static Map<String, int>? getHint(
    List<int> grid,
    int columns,
    {List<int> excludeIndices = const []}
  ) {
    final validMoves = findValidMoves(grid, columns, excludeIndices: excludeIndices);
    
    if (validMoves.isEmpty) return null;
    
    // Return a random valid move as hint
    return validMoves[_random.nextInt(validMoves.length)];
  }
  
  // Check if game is in winning state
  static bool isGameWon(List<int> visibleGrid) {
    if (visibleGrid.isEmpty) return true;
    
    // Check if any valid moves remain
    final validMoves = findValidMoves(visibleGrid, GameConstants.gridColumns);
    return validMoves.isEmpty;
  }
  
  // Shuffle an array using Fisher-Yates algorithm
  static List<T> shuffleList<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    
    return shuffled;
  }
  
  // Generate balanced number distribution for better gameplay
  static List<int> generateBalancedNumbers(int count, List<int> allowedNumbers) {
    final numbers = <int>[];
    final targetPairs = count ~/ 4; // Aim for some matching pairs
    
    // Add some matching pairs
    for (int i = 0; i < targetPairs; i++) {
      final number = allowedNumbers[_random.nextInt(allowedNumbers.length)];
      numbers.add(number);
      numbers.add(number);
    }
    
    // Add some pairs that sum to 10
    final sumTenPairs = [
      [1, 9], [2, 8], [3, 7], [4, 6], [5, 5]
    ];
    
    for (int i = 0; i < targetPairs ~/ 2 && numbers.length < count - 1; i++) {
      final pair = sumTenPairs[_random.nextInt(sumTenPairs.length)];
      numbers.add(pair[0]);
      numbers.add(pair[1]);
    }
    
    // Fill remaining with random numbers
    while (numbers.length < count) {
      numbers.add(allowedNumbers[_random.nextInt(allowedNumbers.length)]);
    }
    
    return shuffleList(numbers);
  }
}