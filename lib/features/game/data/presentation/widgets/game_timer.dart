import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'package:number_master_puzzle/core/constants/colors.dart';
import 'package:number_master_puzzle/features/game/data/models/game_state.dart';

class GameTimer extends ConsumerWidget {
  const GameTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer display
          _buildTimerDisplay(gameState),
          
          // Score display
          _buildScoreDisplay(gameState),
        ],
      ),
    );
  }
  
  Widget _buildTimerDisplay(GameState gameState) {
    final timeRemaining = gameState.timeRemaining;
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;
    
    // Determine timer color based on remaining time
    Color timerColor;
    if (timeRemaining.inSeconds > 60) {
      timerColor = AppColors.timerNormal;
    } else if (timeRemaining.inSeconds > 30) {
      timerColor = AppColors.timerWarning;
    } else {
      timerColor = AppColors.timerCritical;
    }
    
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
          Icon(
            Icons.timer,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
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
  
  Widget _buildScoreDisplay(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            gameState.score.toString(),
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
}

// Game status widget
class GameStatus extends ConsumerWidget {
  const GameStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    
    if (gameState.message == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getMessageColor(gameState).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getMessageColor(gameState),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getMessageIcon(gameState),
            color: _getMessageColor(gameState),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              gameState.message!,
              style: TextStyle(
                color: _getMessageColor(gameState),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getMessageColor(GameState gameState) {
    if (gameState.message!.contains('Great match') || 
        gameState.message!.contains('completed') ||
        gameState.message!.contains('New row added')) {
      return AppColors.success;
    } else if (gameState.message!.contains('Invalid') || 
               gameState.message!.contains('Game over') ||
               gameState.message!.contains('Time\'s up')) {
      return AppColors.error;
    } else {
      return AppColors.info;
    }
  }
  
  IconData _getMessageIcon(GameState gameState) {
    if (gameState.message!.contains('Great match') || 
        gameState.message!.contains('completed')) {
      return Icons.check_circle;
    } else if (gameState.message!.contains('Invalid') || 
               gameState.message!.contains('Game over') ||
               gameState.message!.contains('Time\'s up')) {
      return Icons.error;
    } else if (gameState.message!.contains('New row added')) {
      return Icons.add_circle;
    } else {
      return Icons.info;
    }
  }
}

// Level progress indicator
class LevelProgress extends ConsumerWidget {
  const LevelProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final progress = gameState.progress;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${gameState.currentLevel}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.levelColors[(gameState.currentLevel - 1) % AppColors.levelColors.length],
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}