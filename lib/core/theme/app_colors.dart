import 'package:flutter/material.dart';

abstract class AppColors {
  // 1. 브랜드 컬러 (Brand Colors)
  static const Color primaryNavy = Color(0xFF1A3B6E); // 메인 남색
  static const Color accentGold = Color(0xFFD4AF37);  // 포인트 금색
  static const Color background = Color(0xFFF5F7FA);  // 배경 연회색

  // 2. 상태 컬러 (Status Colors)
  static const Color incomeGreen = Color(0xFF2E7D32); // 수입/정상 (초록)
  static const Color expenseRed = Color(0xFFC62828);  // 지출/연체 (빨강)
  static const Color warningYellow = Color(0xFFF9A825); // 만기 임박 (노랑)

  // 3. 텍스트 컬러 (Text Colors)
  static const Color textPrimary = Color(0xFF212121); // 진한 검정
  static const Color textSecondary = Color(0xFF757575); // 연한 회색
}