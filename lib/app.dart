// // lib/app.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'main_screen.dart';
// import 'features/settings/theme_provider.dart';
// import 'features/security/security_provider.dart';
// import 'features/security/pin_screen.dart';
// import 'core/localization/localization_provider.dart';
//
// class SireApp extends ConsumerWidget {
//   const SireApp({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 📍 테마 상태 감시
//     final themeMode = ref.watch(themeProvider);
//
//     // 📍 언어 변경 시 UI 리빌드를 위해 watch (언어 변경 시 앱 전체가 새로 그려짐)
//     ref.watch(localizationProvider);
//
//     // 📍 Notifier에서 현재 언어 코드를 안전하게 가져옴 (예: 'zh', 'ko', 'en')
//     final String currentLang = ref.read(localizationProvider.notifier).currentLang;
//
//     // 📍 보안 상태 확인 (PIN 설정 여부)
//     final securityAsync = ref.watch(securityNotifierProvider);
//
//     return securityAsync.when(
//       loading: () => const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(body: Center(child: CircularProgressIndicator())),
//       ),
//       error: (err, stack) => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(body: Center(child: Text('Security Error: $err'))),
//       ),
//       data: (hasPin) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'SiRE',
//
//           // --- 📍 [핵심] 다국어 로케일 설정 ---
//           // 이 설정값이 각 화면의 NumberFormat.simpleCurrency(locale: ...)로 전달되어야 합니다.
//           locale: Locale(currentLang),
//
//           supportedLocales: const [
//             Locale('ar'), Locale('bn'), Locale('zh'), Locale('nl'),
//             Locale('en'), Locale('fr'), Locale('de'), Locale('hi'),
//             Locale('id'), Locale('it'), Locale('ja'), Locale('ko'),
//             Locale('ms'), Locale('pl'), Locale('pt'), Locale('ru'),
//             Locale('es'), Locale('th'), Locale('tr'), Locale('vi'),
//           ],
//
//           // 📍 Flutter 프레임워크가 제공하는 기본 위젯(달력, 버튼 등)의 다국어 델리게이트
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           // -----------------------------------------------
//
//           themeMode: themeMode,
//           theme: ThemeData(
//             colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
//             useMaterial3: true,
//             brightness: Brightness.light,
//           ),
//           darkTheme: ThemeData(
//             colorScheme: ColorScheme.fromSeed(
//               seedColor: Colors.teal,
//               brightness: Brightness.dark,
//             ),
//             useMaterial3: true,
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//           ),
//
//           routes: {
//             '/home': (context) => const MainScreen(),
//           },
//
//           // 📍 PIN 설정 유무에 따라 보안 화면 혹은 메인 화면으로 진입
//           home: hasPin ? const PinScreen() : const MainScreen(),
//         );
//       },
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'main_screen.dart';
// import 'features/settings/theme_provider.dart';
// import 'features/security/security_provider.dart';
// import 'features/security/pin_screen.dart';
// import 'core/localization/localization_provider.dart';
//
// class SireApp extends ConsumerWidget {
//   const SireApp({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeProvider);
//     ref.watch(localizationProvider);
//     final String currentLang = ref.read(localizationProvider.notifier).currentLang;
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SiRE',
//       locale: Locale(currentLang),
//       supportedLocales: const [
//         Locale('ar'), Locale('bn'), Locale('zh'), Locale('nl'),
//         Locale('en'), Locale('fr'), Locale('de'), Locale('hi'),
//         Locale('id'), Locale('it'), Locale('ja'), Locale('ko'),
//         Locale('ms'), Locale('pl'), Locale('pt'), Locale('ru'),
//         Locale('es'), Locale('th'), Locale('tr'), Locale('vi'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       themeMode: themeMode,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
//         useMaterial3: true,
//         brightness: Brightness.light,
//       ),
//       darkTheme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: const Color(0xFF121212),
//       ),
//       // 📍 [핵심 수정] 보안 로직은 MainScreen 내부에서 라이프사이클로 관리합니다.
//       home: const MainScreen(),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'main_screen.dart';
// import 'features/settings/theme_provider.dart';
// import 'core/localization/localization_provider.dart';
//
// class SireApp extends ConsumerWidget {
//   const SireApp({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeProvider);
//     final String currentLang = ref.watch(localizationProvider.notifier).currentLang;
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SiRE',
//       locale: Locale(currentLang),
//       supportedLocales: const [
//         Locale('ar'), Locale('bn'), Locale('zh'), Locale('nl'),
//         Locale('en'), Locale('fr'), Locale('de'), Locale('hi'),
//         Locale('id'), Locale('it'), Locale('ja'), Locale('ko'),
//         Locale('ms'), Locale('pl'), Locale('pt'), Locale('ru'),
//         Locale('es'), Locale('th'), Locale('tr'), Locale('vi'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
//       darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark), useMaterial3: true),
//       themeMode: themeMode,
//       home: const MainScreen(), // 📍 바로 메인 화면으로 진입
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'main_screen.dart';
import 'features/settings/theme_provider.dart';
import 'core/localization/localization_provider.dart';

class SireApp extends ConsumerWidget {
  const SireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final String currentLang = ref.watch(localizationProvider.notifier).currentLang;

    return MaterialApp(
      debugShowCheckedModeBanner: false, // 📍 메인 앱 디버그 띠 제거
      title: 'SiRE',
      locale: Locale(currentLang),
      supportedLocales: const [
        Locale('ar'), Locale('bn'), Locale('zh'), Locale('nl'),
        Locale('en'), Locale('fr'), Locale('de'), Locale('hi'),
        Locale('id'), Locale('it'), Locale('ja'), Locale('ko'),
        Locale('ms'), Locale('pl'), Locale('pt'), Locale('ru'),
        Locale('es'), Locale('th'), Locale('tr'), Locale('vi'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}