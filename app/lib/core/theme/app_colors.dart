import 'package:flutter/material.dart';

/// Uygulama renk paleti - Tasarımdan alınmıştır
class AppColors {
  // Birincil Renkler
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  
  // Arkaplan Renkleri
  static const Color backgroundLight = Color(0xFFF7F8F6);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Yüzey Renkleri
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Metin Renkleri
  static const Color textPrimaryLight = Color(0xFF141711);
  static const Color textSecondaryLight = Color(0xFF728764);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  
  // Vurgu Renkleri (Ders kartları için)
  static const Color orange = Color(0xFFFF9500);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color pink = Color(0xFFEC4899);
  static const Color amber = Color(0xFFFBBF24);
  static const Color emerald = Color(0xFF059669);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color sky = Color(0xFF38BDF8);
  
  // Etiket Renkleri
  static const Color tagBiology = Color(0xFF22C55E);
  static const Color tagHistory = Color(0xFF8B5CF6);
  static const Color tagMath = Color(0xFF3B82F6);
  static const Color tagExam = Color(0xFFFF9500);
  static const Color tagBehind = Color(0xFFEF4444);
  
  // Yüzey varyantları (dark mode)
  static const Color surfaceDarkElevated = Color(0xFF2C2C2E);
  static const Color surfaceDarkBlue = Color(0xFF1E1E2E);
  static const Color canvasDark = Color(0xFF1C1C1E);
  
  // Metin varyantları (light mode)
  static const Color textHeadingLight = Color(0xFF1A1F36);
  
  // Vurgu renkleri
  static const Color indigoAccent = Color(0xFF6366F1);

  // Gölge ve Overlay
  static const Color shadowLight = Color(0x14000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color overlay = Color(0x1A000000);
  
  // Ders kartı renk listesi
  static const List<Color> courseColors = [
    primary,
    sky,
    purple,
    pink,
    amber,
    emerald,
  ];
}
