// 파일 경로: lib/features/settings/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  // 📍 테마 전환 로직 (다국어 설정 화면의 스위치와 연동됨)
  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // 📍 시스템 설정에 따른 테마 모드 설정
  void setSystemTheme() {
    state = ThemeMode.system;
  }
}

// [중요] 이 변수 이름이 'themeProvider' 여야 합니다!
// app.dart에서 이 이름을 찾고 있습니다.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});