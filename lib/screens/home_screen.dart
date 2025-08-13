import 'package:flutter/material.dart';
import 'package:number_master_puzzle/core/constants/colors.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Animated Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildHeader(),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated Description Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildDescriptionCard(),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated Level Buttons
                  ...List.generate(3, (index) => 
                    FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.4 + (index * 0.1), 
                          1.0, 
                          curve: Curves.easeOut,
                        ),
                      )),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.5, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.4 + (index * 0.1), 
                            1.0, 
                            curve: Curves.easeOut,
                          ),
                        )),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildLevelCard(index + 1),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Animated Tip Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTipCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.apps,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Number Master',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          'Puzzle Challenge',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            'Match identical numbers or pairs that sum to 10!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Complete each level within 2 minutes by matching adjacent tiles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int level) {
    final levelData = _getLevelData(level);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToGame(level),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: levelData['color'].withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: levelData['color'].withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level Number Circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      levelData['color'],
                      levelData['color'].withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: levelData['color'].withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Level Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelData['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      levelData['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.grid_3x3,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${3 + level}x7 grid',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2 min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Play Arrow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: levelData['color'].withOpacity(0.1),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: levelData['color'],
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: Colors.orange.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tip: Match same numbers (5-5) or pairs that sum to 10 (3-7)',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getLevelData(int level) {
    switch (level) {
      case 1:
        return {
          'name': 'Beginner',
          'description': 'Easy start with simple patterns',
          'color': AppColors.levelColors[0],
        };
      case 2:
        return {
          'name': 'Intermediate',
          'description': 'More challenging combinations',
          'color': AppColors.levelColors[1],
        };
      case 3:
        return {
          'name': 'Expert',
          'description': 'Maximum difficulty challenge',
          'color': AppColors.levelColors[2],
        };
      default:
        return {
          'name': 'Level $level',
          'description': 'Challenge yourself!',
          'color': AppColors.primary,
        };
    }
  }

  void _navigateToGame(int level) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            GameScreen(level: level),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }
}
