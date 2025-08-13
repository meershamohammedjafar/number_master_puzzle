// Game Configuration Constants
class GameConstants {
  // Game Rules
  static const int targetSum = 10;
  static const int maxNumber = 9;
  static const int minNumber = 1;
  
  // Level Configuration
  static const int totalLevels = 3;
  static const Duration levelTimeLimit = Duration(minutes: 2);
  
  // Grid Configuration
  static const int gridColumns = 7;
  static const int initialRows = 4;
  static const int maxRows = 8;
  
  // Animation Durations
  static const Duration tileAnimationDuration = Duration(milliseconds: 300);
  static const Duration matchAnimationDuration = Duration(milliseconds: 500);
  static const Duration invalidAnimationDuration = Duration(milliseconds: 400);
  
  // Scoring
  static const int matchScore = 10;
  static const int levelCompleteBonus = 100;
  static const int timeBonus = 5; // Points per second remaining
}

// Level Configurations
class LevelConfig {
  static const Map<int, Map<String, dynamic>> levels = {
    1: {
      'name': 'Beginner',
      'description': 'Easy start with simple patterns',
      'initialNumbers': 28, // 4 rows * 7 columns
      'allowedNumbers': [1, 2, 3, 4, 5, 6, 7, 8, 9],
      'addRowLimit': 2,
    },
    2: {
      'name': 'Intermediate', 
      'description': 'More challenging with mixed numbers',
      'initialNumbers': 35, // 5 rows * 7 columns
      'allowedNumbers': [1, 2, 3, 4, 5, 6, 7, 8, 9],
      'addRowLimit': 3,
    },
    3: {
      'name': 'Expert',
      'description': 'Maximum difficulty with complex patterns',
      'initialNumbers': 42, // 6 rows * 7 columns
      'allowedNumbers': [1, 2, 3, 4, 5, 6, 7, 8, 9],
      'addRowLimit': 4,
    },
  };
}