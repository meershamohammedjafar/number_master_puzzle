import 'package:flutter/material.dart';
import 'package:number_master_puzzle/features/game/data/models/tile.dart';
import 'package:number_master_puzzle/core/constants/colors.dart';
import 'package:number_master_puzzle/core/constants/app_constants.dart';

class TileWidget extends StatefulWidget {
  final Tile tile;
  final VoidCallback onTap;
  final bool isAnimating;
  
  const TileWidget({
    super.key,
    required this.tile,
    required this.onTap,
    this.isAnimating = false,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: GameConstants.tileAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: _getTileColor(),
      end: _getTileColor(),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.tile.state != widget.tile.state) {
      _updateAnimations();
    }
    
    if (widget.isAnimating && oldWidget.tile.state != TileState.matched && 
        widget.tile.state == TileState.matched) {
      _playMatchAnimation();
    }
  }

  void _updateAnimations() {
    _colorAnimation = ColorTween(
      begin: _getTileColor(),
      end: _getTileColor(),
    ).animate(_animationController);
  }

  void _playMatchAnimation() {
    _animationController.forward().then((_) {
      if (mounted) {
        _animationController.reverse();
      }
    });
  }

  Color _getTileColor() {
    switch (widget.tile.state) {
      case TileState.normal:
        return AppColors.tileDefault;
      case TileState.selected:
        return AppColors.tileSelected;
      case TileState.matched:
        return AppColors.tileMatched;
      case TileState.faded:
        return AppColors.tileFaded;
    }
  }

  Color _getTextColor() {
    switch (widget.tile.state) {
      case TileState.faded:
      case TileState.matched:
        return AppColors.textHint;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.tile.state == TileState.selected || widget.isAnimating 
              ? _scaleAnimation.value 
              : 1.0,
          child: Opacity(
            opacity: widget.tile.state == TileState.matched
                ? _opacityAnimation.value
                : 1.0,
            child: GestureDetector(
              onTap: widget.tile.isVisible ? widget.onTap : null,
              child: AnimatedContainer(
                duration: GameConstants.tileAnimationDuration,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _getTileColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.tile.state == TileState.selected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    width: widget.tile.state == TileState.selected ? 2 : 1,
                  ),
                  boxShadow: widget.tile.state == TileState.selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Center(
                  child: widget.tile.isVisible
                      ? AnimatedDefaultTextStyle(
                          duration: GameConstants.tileAnimationDuration,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(),
                          ),
                          child: Text('${widget.tile.value}'),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Invalid match animation widget
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool animate;
  
  const ShakeWidget({
    super.key,
    required this.child,
    required this.animate,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: GameConstants.invalidAnimationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.animate && !oldWidget.animate) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = sin(_animation.value * 4 * 3.14159) * 3;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
    );
  }
}

// Helper function for shake animation
double sin(double value) {
  return (value - value.floor()) * 2 - 1;
}