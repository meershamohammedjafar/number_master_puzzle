import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFFFF9800);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Tile Colors
  static const Color tileNormal = Color(0xFFE3F2FD);
  static const Color tileSelected = Color(0xFF2196F3);
  static const Color tileMatched = Color(0xFFE8F5E8);
  static const Color tileFaded = Color(0xFFEEEEEE);
  
  // Game State Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  
  // Timer Colors
  static const Color timerGood = Color(0xFF4CAF50);
  static const Color timerWarning = Color(0xFFFF9800);
  static const Color timerDanger = Color(0xFFF44336);
  
  // Level Colors
  static const List<Color> levelColors = [
    Color(0xFF4CAF50), // Beginner
    Color(0xFFFF9800), // Intermediate  
    Color(0xFFF44336), // Expert
  ];
}

class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
  );
  
  static const LinearGradient tileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
  );
  
  static const LinearGradient selectedTileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );
}
