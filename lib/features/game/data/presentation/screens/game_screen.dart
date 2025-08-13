import 'package:flutter/material.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<int?>> grid = [];
  int? selectedTile;
  int score = 0;
  int timeRemaining = 120; // 2 minutes in seconds
  Timer? gameTimer;
  bool isGameActive = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Create grid based on level (4, 5, or 6 rows)
    int rows =
        3 + widget.level; // Level 1=4 rows, Level 2=5 rows, Level 3=6 rows

    grid = List.generate(
      rows,
      (i) => List.generate(7, (j) => (i * 7 + j + 1) % 9 + 1),
    );

    setState(() {
      score = 0;
      selectedTile = null;
      timeRemaining = 120;
      isGameActive = true;
    });
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0 && isGameActive) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _gameOver();
      }
    });
  }

  void _gameOver() {
    setState(() {
      isGameActive = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(timeRemaining <= 0 ? 'Time\'s Up!' : 'Game Complete!'),
        content: Text('Final Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Back to Menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
              _startTimer();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (timeRemaining > 60) return Colors.green;
    if (timeRemaining > 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Timer and Score Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTimerColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _getTimerColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: _getTimerColor(), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(timeRemaining),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getTimerColor(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Game Grid
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildGrid(),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isGameActive
                      ? () {
                          _initializeGame();
                          _startTimer();
                        }
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isGameActive ? _addRow : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Row'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addRow() {
    setState(() {
      // Add a new row with random numbers
      List<int?> newRow = List.generate(7, (j) => (j + 1) % 9 + 1);
      grid.add(newRow);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New row added!'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildGrid() {
    return SingleChildScrollView(
      child: Column(
        children: grid.asMap().entries.map((rowEntry) {
          int rowIndex = rowEntry.key;
          List<int?> row = rowEntry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: row.asMap().entries.map((colEntry) {
                int colIndex = colEntry.key;
                int? value = colEntry.value;
                int tileIndex = rowIndex * 7 + colIndex;

                return Expanded(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.all(2),
                    child: _buildTile(value, tileIndex),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTile(int? value, int index) {
    if (value == null) return Container();

    bool isSelected = selectedTile == index;
    bool isMatched = value < 0; // Negative values are matched tiles
    int displayValue = value.abs();

    return GestureDetector(
      onTap: isGameActive && !isMatched ? () => _onTileTap(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.grey.shade300
              : isSelected
              ? Colors.blue.shade200
              : Colors.blue.shade50,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$displayValue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isMatched
                  ? Colors.grey.shade600
                  : isSelected
                  ? Colors.blue.shade800
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _onTileTap(int index) {
    if (!isGameActive) return;

    setState(() {
      if (selectedTile == null) {
        selectedTile = index;
      } else if (selectedTile == index) {
        selectedTile = null;
      } else {
        _attemptMatch(selectedTile!, index);
        selectedTile = null;
      }
    });
  }

  void _attemptMatch(int index1, int index2) {
    int row1 = index1 ~/ 7;
    int col1 = index1 % 7;
    int row2 = index2 ~/ 7;
    int col2 = index2 % 7;

    if (row1 >= grid.length || row2 >= grid.length) return;

    int? value1 = grid[row1][col1];
    int? value2 = grid[row2][col2];

    if (value1 == null || value2 == null || value1 < 0 || value2 < 0) return;

    // Check if values can match and are adjacent
    bool canMatch = (value1 == value2) || (value1 + value2 == 10);
    bool isAdjacent = _checkAdjacent(row1, col1, row2, col2);

    if (canMatch && isAdjacent) {
      setState(() {
        // Mark as matched (negative value)
        grid[row1][col1] = -value1;
        grid[row2][col2] = -value2;
        score += 10;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Great match! +10 points'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      // Check if level complete
      if (_isLevelComplete()) {
        gameTimer?.cancel();
        _gameOver();
      }
    } else {
      String message = !canMatch
          ? 'Numbers don\'t match!'
          : 'Tiles must be adjacent!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  bool _checkAdjacent(int row1, int col1, int row2, int col2) {
    int rowDiff = (row1 - row2).abs();
    int colDiff = (col1 - col2).abs();

    // Same row, adjacent columns
    if (rowDiff == 0 && colDiff == 1) return true;

    // Same column, adjacent rows
    if (colDiff == 0 && rowDiff == 1) return true;

    // Line break: end of row to start of next row
    if (rowDiff == 1 &&
        ((row1 < row2 && col1 == 6 && col2 == 0) ||
            (row1 > row2 && col2 == 6 && col1 == 0))) {
      return true;
    }

    return false;
  }

  bool _isLevelComplete() {
    for (var row in grid) {
      for (var value in row) {
        if (value != null && value > 0) {
          // Check if this tile has any valid moves
          // For now, simplified - you can enhance this
          return false;
        }
      }
    }
    return true;
  }
}
