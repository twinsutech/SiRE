// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_screen.dart';
import 'features/settings/theme_provider.dart';
import 'features/security/security_provider.dart'; // 추가
import 'features/security/pin_screen.dart'; // 추가

class SireApp extends ConsumerWidget {
  const SireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    // 📍 보안 상태 확인
    final securityAsync = ref.watch(securityNotifierProvider);

    return securityAsync.when(
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (_, __) => const SizedBox(), // 에러 시 처리
      data: (hasPin) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SiRE',
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),

          // 📍 경로 설정: PinScreen이 /home을 찾을 수 있도록 합니다.
          routes: {
            '/home': (context) => const MainScreen(),
          },

          // 📍 시작점 결정: PIN 설정 여부에 따라 첫 화면 결정
          home: hasPin ? const PinScreen() : const MainScreen(),
        );
      },
    );
  }
}