import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 📍 보안 저장소 임포트

part 'security_provider.g.dart';

@riverpod
class SecurityNotifier extends _$SecurityNotifier {
  // 📍 보안 저장소 인스턴스 (iOS: Keychain, Android: KeyStore 사용)
  // 다국어 환경에서도 데이터 키값은 고정되어야 하므로 'user_pin_secure'를 유지합니다.
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin_secure';

  // 현재 세션에서 인증이 되었는지 여부 (앱 실행 중 메모리에서만 관리)
  // 다국어 설정 페이지 진입 시나 민감한 리포트 열람 시 이 상태를 체크합니다.
  final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

  @override
  Future<bool> build() async {
    // 📍 앱 시작 시 보안 저장소에 PIN이 있는지 확인합니다.
    // 이 값의 존재 유무에 따라 초기 다국어 환영 메시지나 잠금 화면 노출 여부가 결정됩니다.
    final savedPin = await _storage.read(key: _pinKey);
    return savedPin != null; // PIN이 존재하면 true 반환
  }

  // 📍 PIN 저장 (OS 레벨에서 자동 암호화되어 저장됨)
  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    ref.invalidateSelf(); // 상태를 갱신하여 UI에 즉시 반영
  }

  // 📍 PIN 확인 (보안 저장소의 값과 입력값 비교)
  Future<bool> verifyPin(String input) async {
    final savedPin = await _storage.read(key: _pinKey);
    return savedPin == input;
  }

  // 📍 PIN 삭제 (설정 해제 시 사용)
  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    ref.invalidateSelf();
  }
}