import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFFFF9800);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Game-specific Colors
  static const Color tileDefault = Color(0xFFE3F2FD);
  static const Color tileSelected = Color(0xFFBBDEFB);
  static const Color tileMatched = Color(0xFFE8F5E8);
  static const Color tileFaded = Color(0xFFEEEEEE);
  
  // Game State Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFF2196F3);
  static const Color buttonSecondary = Color(0xFFE0E0E0);
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  
  // Timer Colors
  static const Color timerNormal = Color(0xFF4CAF50);
  static const Color timerWarning = Color(0xFFFF9800);
  static const Color timerCritical = Color(0xFFF44336);
  
  // Level Colors
  static const List<Color> levelColors = [
    Color(0xFF4CAF50), // Beginner - Green
    Color(0xFFFF9800), // Intermediate - Orange
    Color(0xFFF44336), // Expert - Red
  ];
}