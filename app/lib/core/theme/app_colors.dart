import 'package:flutter/material.dart';

/// Uygulama renk paleti - Tasarımdan alınmıştır
class AppColors {
  // Birincil Renkler
  static const Color primary = Color(0xFF87E444);
  static const Color primaryDark = Color(0xFF5AB51A);
  static const Color primaryLight = Color(0xFF70DF20);
  
  // Arkaplan Renkleri
  static const Color backgroundLight = Color(0xFFF7F8F6);
  static const Color backgroundDark = Color(0xFF182111);
  
  // Yüzey Renkleri
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF232D1D);
  
  // Metin Renkleri
  static const Color textPrimaryLight = Color(0xFF141711);
  static const Color textSecondaryLight = Color(0xFF728764);
  static const Color textPrimaryDark = Color(0xFFF7F8F6);
  static const Color textSecondaryDark = Color(0xFFA0B392);
  
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
