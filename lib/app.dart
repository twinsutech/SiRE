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