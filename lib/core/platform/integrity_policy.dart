import 'package:shared_preferences/shared_preferences.dart';

enum IntegrityGateState { ok, grace, restricted }

class IntegrityPolicy {
  static const _kLastOkMs = 'integrity_last_ok_ms';
  static const _kFailCount = 'integrity_fail_count';
  static const _kGraceUntilMs = 'integrity_grace_until_ms';

  // 운영 추천값
  static const int maxFailsBeforeRestricted = 4; // 1~3회 실패는 유예
  static const Duration graceDuration = Duration(days: 30); // 최근 7일 내 성공이면 오프라인 허용
  static const Duration restrictedDelay = Duration(hours: 24); // (확장 여지) 실패 장기화 시 가속용

  static Future<IntegrityGateState> evaluate({
    required bool integrityOkNow,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    final lastOk = sp.getInt(_kLastOkMs) ?? 0;
    final failCount = sp.getInt(_kFailCount) ?? 0;
    final graceUntil = sp.getInt(_kGraceUntilMs) ?? 0;

    if (integrityOkNow) {
      // 성공하면 모든 실패 누적 리셋 + 유예 갱신
      await sp.setInt(_kLastOkMs, now);
      await sp.setInt(_kFailCount, 0);
      await sp.setInt(_kGraceUntilMs, now + graceDuration.inMilliseconds);
      return IntegrityGateState.ok;
    }

    // 실패한 경우: 최근 성공 기록이 유효하면 유예
    final withinGraceWindow = now <= graceUntil && lastOk > 0;

    // 실패 누적
    final newFailCount = failCount + 1;
    await sp.setInt(_kFailCount, newFailCount);

    // 유예 기간이 이미 있다면 계속 유예
    if (withinGraceWindow) {
      return IntegrityGateState.grace;
    }

    // 유예가 없고, 실패가 많이 누적되면 제한 후보
    if (newFailCount >= maxFailsBeforeRestricted) {
      return IntegrityGateState.restricted;
    }

    // 기본은 유예(사용자 보호)
    return IntegrityGateState.grace;
  }

  static Future<Map<String, dynamic>> debugState() async {
    final sp = await SharedPreferences.getInstance();
    return {
      _kLastOkMs: sp.getInt(_kLastOkMs),
      _kFailCount: sp.getInt(_kFailCount),
      _kGraceUntilMs: sp.getInt(_kGraceUntilMs),
    };
  }

  static Future<void> reset() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kLastOkMs);
    await sp.remove(_kFailCount);
    await sp.remove(_kGraceUntilMs);
  }
}
