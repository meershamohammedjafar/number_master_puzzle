import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_master_puzzle/core/constants/colors.dart';
import 'package:number_master_puzzle/features/game/data/presentation/providers/game_notifier.dart';
import '../features/game/data/models/game_state.dart';
import '../features/game/data/models/tile.dart';
import 'dart:math';

class GameScreen extends ConsumerStatefulWidget {
  final int level;
  
  const GameScreen({super.key, required this.level});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  
  int? shakingTileIndex;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Initialize game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initializeGame(widget.level);
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsBar(gameState),
          _buildProgressBar(gameState),
          if (gameState.message != null) _buildMessageBar(gameState),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _buildGrid(gameState, gameNotifier),
            ),
          ),
          _buildControlsBar(gameState, gameNotifier),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Level ${widget.level}'),
      backgroundColor: AppColors.levelColors[(widget.level - 1) % AppColors.levelColors.length],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _showHelpDialog,
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }

  Widget _buildStatsBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerWidget(gameState),
          _buildScoreWidget(gameState),
        ],
      ),
    );
  }

  Widget _buildTimerWidget(GameState gameState) {
    Color timerColor = _getTimerColor(gameState.timeRemaining);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: gameState.timeRemaining <= 30 ? _pulseAnimation : 
                      const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: gameState.timeRemaining <= 30 ? _pulseAnimation.value : 1.0,
                child: Icon(Icons.timer, color: timerColor, size: 20),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(gameState.timeRemaining),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreWidget(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            '${gameState.score}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress: ${(gameState.progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: gameState.progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.levelColors[(widget.level - 1) % AppColors.levelColors.length],
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBar(GameState gameState) {
    if (gameState.message == null) return const SizedBox.shrink();
    
    Color messageColor = gameState.message!.contains('Great') 
        ? AppColors.success 
        : AppColors.error;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: messageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: messageColor),
      ),
      child: Row(
        children: [
          Icon(
            gameState.message!.contains('Great') ? Icons.check_circle : Icons.error,
            color: messageColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              gameState.message!,
              style: TextStyle(
                color: messageColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar(GameState gameState, GameNotifier gameNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reset',
            color: Colors.grey.shade600,
            onPressed: gameState.status == GameStatus.playing 
                ? () => gameNotifier.resetGame()
                : null,
          ),
          _buildControlButton(
            icon: Icons.add,
            label: 'Add Row',
            color: Colors.orange,
            onPressed: gameState.status == GameStatus.playing 
                ? () => gameNotifier.addRow()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  Widget _buildGrid(GameState gameState, GameNotifier gameNotifier) {
    final tilesGrid = gameState.tilesGrid;
    
    if (tilesGrid.isEmpty) {
      return const Center(
        child: Text('Loading game...', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: tilesGrid.asMap().entries.map((rowEntry) {
          List<Tile?> row = rowEntry.value;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: row.asMap().entries.map((colEntry) {
                Tile? tile = colEntry.value;
                
                if (tile == null) {
                  return Expanded(
                    child: Container(height: 50, margin: const EdgeInsets.all(2)),
                  );
                }
                
                return Expanded(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.all(2),
                    child: _buildAnimatedTile(tile, gameNotifier),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedTile(Tile tile, GameNotifier gameNotifier) {
    bool isSelected = tile.state == TileState.selected;
    bool isMatched = tile.state == TileState.matched;
    bool isShaking = shakingTileIndex == tile.id;
    
    return AnimatedBuilder(
      animation: isShaking ? _shakeAnimation : const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        double shake = isShaking ? sin(_shakeAnimation.value * 4 * pi) * 3 : 0;
        
        return Transform.translate(
          offset: Offset(shake, 0),
          child: GestureDetector(
            onTap: gameNotifier.state.status == GameStatus.playing && !isMatched 
                ? () => gameNotifier.onTileTapped(tile)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: _getTileGradient(isSelected, isMatched),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getTileBorderColor(isSelected, isMatched),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: _getTileShadow(isSelected, isMatched),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getTileTextColor(isSelected, isMatched),
                  ),
                  child: Text('${tile.value}'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getTimerColor(int timeRemaining) {
    if (timeRemaining > 60) return AppColors.timerGood;
    if (timeRemaining > 30) return AppColors.timerWarning;
    return AppColors.timerDanger;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Gradient _getTileGradient(bool isSelected, bool isMatched) {
    if (isMatched) {
      return LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200]);
    } else if (isSelected) {
      return AppGradients.selectedTileGradient;
    } else {
      return AppGradients.tileGradient;
    }
  }

  Color _getTileBorderColor(bool isSelected, bool isMatched) {
    if (isMatched) return Colors.grey.shade400;
    if (isSelected) return AppColors.primary;
    return Colors.grey.shade300;
  }

  List<BoxShadow> _getTileShadow(bool isSelected, bool isMatched) {
    if (isMatched) return [];
    if (isSelected) {
      return [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))];
    }
    return [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))];
  }

  Color _getTileTextColor(bool isSelected, bool isMatched) {
    if (isMatched) return Colors.grey.shade600;
    if (isSelected) return Colors.white;
    return const Color(0xFF1976D2);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 Match identical numbers (5-5, 8-8)'),
              SizedBox(height: 8),
              Text('🎯 Match pairs that sum to 10 (3-7, 4-6)'),
              SizedBox(height: 8),
              Text('📍 Tiles must be adjacent'),
              SizedBox(height: 8),
              Text('⏰ Complete within 2 minutes'),
              SizedBox(height: 8),
              Text('💡 Use "Add Row" when stuck'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
