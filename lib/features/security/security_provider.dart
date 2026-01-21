import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'security_provider.g.dart';

@riverpod
class SecurityNotifier extends _$SecurityNotifier {
  static const _pinKey = 'user_pin';

  // 현재 세션에서 인증이 되었는지 여부 (앱 실행 중 관리)
  final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey); // PIN 설정 여부 반환
  }

  // PIN 저장
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    ref.invalidateSelf();
  }

  // PIN 확인
  Future<bool> verifyPin(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    return savedPin == input;
  }

  // 📍 추가: PIN 삭제 (해제)
  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    ref.invalidateSelf();
  }
}