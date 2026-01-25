import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'localization_provider.g.dart';

@Riverpod(keepAlive: true)
class Localization extends _$Localization {
  Map<String, dynamic> _localizedStrings = {};
  String _currentLang = 'en'; // 기본값은 한국어

  @override
  Future<void> build() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('selectedLanguage') ?? 'en';

    // 📍 assets/localization.json 파일 로드
    final String jsonContent = await rootBundle.loadString('assets/localization.json');
    _localizedStrings = json.decode(jsonContent);
  }

  // 📍 문자열 번역 함수
  String translate(String key) {
    print("검색하려는 키: $key"); // 📍 로그 확인
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key][_currentLang] ?? _localizedStrings[key]['en'] ?? key;
    }
    print("❌ 키를 찾지 못했습니다: $key");
    return key;
  }

  // 📍 실시간 언어 변경 (앱 재시작 필요 없음)
  Future<void> changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', langCode);
    _currentLang = langCode;

    ref.invalidateSelf(); // 프로바이더 갱신 -> 모든 UI 리빌드
    await future;
  }

  String get currentLang => _currentLang;
}

// 📍 편리한 사용을 위한 Extension
extension TransExtension on String {
  String tr(WidgetRef ref) {
    // 로딩 중이거나 에러 시에도 키값은 보여주도록 처리
    return ref.watch(localizationProvider).maybeWhen(
      data: (_) => ref.read(localizationProvider.notifier).translate(this),
      orElse: () => this,
    );
  }
}