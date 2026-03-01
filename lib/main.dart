// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
// // // // // import 'app.dart';
// // // // // import 'core/database/app_database.dart';
// // // // // import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// // // // // import 'core/database/database_provider.dart';
// // // // // import 'features/security/pin_screen.dart';
// // // // // import 'features/security/security_provider.dart';
// // // // //
// // // // // void main() async {
// // // // //   // 📍 플러터 엔진과 위젯 바인딩 초기화
// // // // //   WidgetsFlutterBinding.ensureInitialized();
// // // // //
// // // // //   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
// // // // //   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
// // // // //   await initializeDateFormatting(null, null);
// // // // //
// // // // //   // 📍 데이터베이스 싱글톤 인스턴스 생성
// // // // //   final database = AppDatabase();
// // // // //
// // // // //   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
// // // // //   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
// // // // //   await seedDatabase(database);
// // // // //
// // // // //   runApp(
// // // // //     ProviderScope(
// // // // //       overrides: [
// // // // //         // 생성된 DB 인스턴스를 프로바이더에 주입
// // // // //         databaseProvider.overrideWithValue(database),
// // // // //       ],
// // // // //       // 💡 보안 진입점(Gateway)을 통해 앱 시작
// // // // //       child: const SecurityGateway(),
// // // // //     ),
// // // // //   );
// // // // // }
// // // // //
// // // // // // 📍 보안 진입점 관리용 위젯
// // // // // // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// // // // // class SecurityGateway extends ConsumerWidget {
// // // // //   const SecurityGateway({super.key});
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // //     // 📍 사용자의 PIN 설정 여부 비동기 확인
// // // // //     final securityAsync = ref.watch(securityNotifierProvider);
// // // // //
// // // // //     return securityAsync.when(
// // // // //       loading: () => const MaterialApp(
// // // // //         debugShowCheckedModeBanner: false,
// // // // //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // // // //       ),
// // // // //       // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
// // // // //       error: (_, __) => const SireApp(),
// // // // //       data: (hasPin) {
// // // // //         if (hasPin) {
// // // // //           // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
// // // // //           // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
// // // // //           return const MaterialApp(
// // // // //             debugShowCheckedModeBanner: false,
// // // // //             home: PinScreen(),
// // // // //           );
// // // // //         } else {
// // // // //           // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
// // // // //           // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
// // // // //           return const SireApp();
// // // // //         }
// // // // //       },
// // // // //     );
// // // // //   }
// // // // // }
// // // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
// // // //
// // // // import 'app.dart';
// // // // import 'core/database/app_database.dart';
// // // // import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// // // // import 'core/database/database_provider.dart';
// // // // import 'features/security/pin_screen.dart';
// // // // import 'features/security/security_provider.dart';
// // // //
// // // // // ✅ [추가] Play Integrity 호출 클라이언트
// // // // import 'core/platform/integrity_client.dart';
// // // //
// // // // // ✅ [추가] 점진적 제한(유예/제한) 상태 저장용
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // //
// // // // import 'core/license/license_model.dart';
// // // // import 'core/license/mock_license_service.dart';
// // // //
// // // // import 'package:flutter/services.dart'; // ✅ SystemNavigator.pop() 사용
// // // //
// // // // void main() async {
// // // //   // 📍 플러터 엔진과 위젯 바인딩 초기화
// // // //   WidgetsFlutterBinding.ensureInitialized();
// // // //
// // // //   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
// // // //   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
// // // //   await initializeDateFormatting(null, null);
// // // //
// // // //   // 📍 데이터베이스 싱글톤 인스턴스 생성
// // // //   final database = AppDatabase();
// // // //
// // // //   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
// // // //   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
// // // //   await seedDatabase(database);
// // // //
// // // //   runApp(
// // // //     ProviderScope(
// // // //       overrides: [
// // // //         // 생성된 DB 인스턴스를 프로바이더에 주입
// // // //         databaseProvider.overrideWithValue(database),
// // // //       ],
// // // //       // 💡 보안 진입점(Gateway)을 통해 앱 시작
// // // //       child: const SecurityGateway(),
// // // //     ),
// // // //   );
// // // // }
// // // //
// // // // // ✅ [추가] Integrity 체크 결과를 담기 위한 간단 모델
// // // // class IntegrityCheckResult {
// // // //   final bool ok;
// // // //   final String? token; // 성공 시 토큰(서버 없으므로 판독은 못 하지만, “성공 여부” 신호로 사용)
// // // //   final String? errorMessage;
// // // //
// // // //   const IntegrityCheckResult({
// // // //     required this.ok,
// // // //     this.token,
// // // //     this.errorMessage,
// // // //   });
// // // // }
// // // //
// // // // // ✅ [추가] 점진적 제한(유예/제한) 게이트 상태
// // // // enum IntegrityGateState {
// // // //   ok, // 정상 진입
// // // //   grace, // 유예(사용 허용)
// // // //   restricted, // 제한(잠금/차단)
// // // // }
// // // //
// // // // // ✅ [추가] (테스트용) “시간 이동” 기능
// // // // // - 정상 구매자가 오랫동안 접속하지 못해 grace가 만료되는 케이스를 Play 배포 없이 재현하기 위함
// // // // // - 사용법: flutter run --dart-define=MOCK_TIME_TRAVEL_DAYS=15
// // // // class _TimeTravel {
// // // //   static int _readDays() {
// // // //     const s = String.fromEnvironment('MOCK_TIME_TRAVEL_DAYS', defaultValue: '0');
// // // //     return int.tryParse(s) ?? 0;
// // // //   }
// // // //
// // // //   static int nowMs() {
// // // //     final base = DateTime.now().millisecondsSinceEpoch;
// // // //     final days = _readDays();
// // // //     if (days <= 0) return base;
// // // //     return base + Duration(days: days).inMilliseconds;
// // // //   }
// // // // }
// // // //
// // // // // ✅ [추가] (테스트용) licensed인데도 lastLicensed/grace 갱신을 막아서
// // // // // “오래 미접속” 상황을 재현하기 위한 플래그
// // // // // 사용법:
// // // // // flutter run --dart-define=MOCK_LICENSE=licensed --dart-define=MOCK_TIME_TRAVEL_DAYS=15 --dart-define=MOCK_FREEZE_LICENSE_LAST_OK=true
// // // // const bool MOCK_FREEZE_LICENSE_LAST_OK =
// // // // bool.fromEnvironment('MOCK_FREEZE_LICENSE_LAST_OK', defaultValue: false);
// // // //
// // // // // ✅ [추가] (1번 방식 테스트 확장) “구매 상태(licensed/unknown)”에서도
// // // // // 일정 기간(예: 14일) 동안 재확인이 안 되면 “권한 재확인 필요” 화면으로 보내기 위한 정책
// // // // enum LicenseGateState {
// // // //   ok, // 정상 진입
// // // //   needsVerification, // 권한 재확인 필요(장기 미접속/오프라인 등)
// // // //   unlicensed, // 미구매/환불(즉시 제한 화면)
// // // // }
// // // //
// // // // // ✅ [추가] 점진적 제한(유예/제한) 저장 키/정책
// // // // class _IntegrityPolicy {
// // // //   static const _kLastOkMs = 'integrity_last_ok_ms';
// // // //   static const _kFailCount = 'integrity_fail_count';
// // // //   static const _kGraceUntilMs = 'integrity_grace_until_ms';
// // // //
// // // //   // 운영 추천값 (서버 없는 앱에서 CS 최소화 중심)
// // // //   // - 실패 몇 번은 "네트워크/Play서비스 일시 문제"일 수 있으므로 유예로 처리
// // // //   static const int maxFailsBeforeRestricted = 4; // 1~3회 실패는 유예
// // // //   static const Duration graceDuration = Duration(days: 7); // 최근 7일 내 성공이면 오프라인이어도 사용 허용
// // // //
// // // //   static Future<IntegrityGateState> evaluate({
// // // //     required bool integrityOkNow,
// // // //   }) async {
// // // //     final sp = await SharedPreferences.getInstance();
// // // //     final now = _TimeTravel.nowMs();
// // // //
// // // //     final lastOk = sp.getInt(_kLastOkMs) ?? 0;
// // // //     final failCount = sp.getInt(_kFailCount) ?? 0;
// // // //     final graceUntil = sp.getInt(_kGraceUntilMs) ?? 0;
// // // //
// // // //     if (integrityOkNow) {
// // // //       // ✅ 성공하면 실패 누적 리셋 + 유예 갱신
// // // //       await sp.setInt(_kLastOkMs, now);
// // // //       await sp.setInt(_kFailCount, 0);
// // // //       await sp.setInt(_kGraceUntilMs, now + graceDuration.inMilliseconds);
// // // //       return IntegrityGateState.ok;
// // // //     }
// // // //
// // // //     // ❌ 실패한 경우: 우선 실패 누적
// // // //     final newFailCount = failCount + 1;
// // // //     await sp.setInt(_kFailCount, newFailCount);
// // // //
// // // //     // 삭제 해야 함. =============================================================
// // // //     // 삭제 해야 함. =============================================================
// // // //     // 삭제 해야 함. =============================================================
// // // //     // ✅ [테스트용] 네트워크 OFF 같은 실패가 4회 이상이면 유예와 상관없이 제한을 확인할 수 있게 함
// // // //     const bool FORCE_RESTRICT_FOR_TEST = true;
// // // //     if (FORCE_RESTRICT_FOR_TEST && newFailCount >= maxFailsBeforeRestricted) {
// // // //       return IntegrityGateState.restricted;
// // // //     }
// // // //     // 삭제 해야 함. =============================================================
// // // //     // 삭제 해야 함. =============================================================
// // // //     // 삭제 해야 함. =============================================================
// // // //
// // // //     // ✅ 최근에 성공한 적이 있고(graceUntil 내) 현재 실패해도 "유예"로 앱 진입 허용
// // // //     final withinGraceWindow = lastOk > 0 && now <= graceUntil;
// // // //     if (withinGraceWindow) {
// // // //       return IntegrityGateState.grace;
// // // //     }
// // // //
// // // //     // ✅ grace window가 없고 실패 누적이 많아지면 제한
// // // //     if (newFailCount >= maxFailsBeforeRestricted) {
// // // //       return IntegrityGateState.restricted;
// // // //     }
// // // //
// // // //     // 기본은 유예(사용자 보호)
// // // //     return IntegrityGateState.grace;
// // // //   }
// // // // }
// // // //
// // // // // ✅ [추가] 라이선스(구매 상태) 점진적 제한 정책 (14일 유예)
// // // // // - licensed/unknown 상태에서도 장기간 재확인이 없으면 “권한 재확인 필요”로 보냄
// // // // class _LicensePolicy {
// // // //   static const _kLastLicensedMs = 'license_last_licensed_ms';
// // // //   static const _kGraceUntilMs = 'license_grace_until_ms';
// // // //
// // // //   // ✅ 운영 정책(권장): 14일
// // // //   static const Duration graceDuration = Duration(days: 14);
// // // //
// // // //   static Future<LicenseGateState> evaluate({
// // // //     required LicenseStatus? license,
// // // //   }) async {
// // // //     final sp = await SharedPreferences.getInstance();
// // // //     final now = _TimeTravel.nowMs();
// // // //
// // // //     final lastLicensed = sp.getInt(_kLastLicensedMs) ?? 0;
// // // //     final graceUntil = sp.getInt(_kGraceUntilMs) ?? 0;
// // // //
// // // //     // ✅ unlicensed는 즉시 제한(환불/미구매 확정)
// // // //     if (license != null && license.state == LicenseState.unlicensed) {
// // // //       return LicenseGateState.unlicensed;
// // // //     }
// // // //
// // // //     // ✅ licensed면 “정상 구매 확인”으로 간주하고 유예 갱신
// // // //     // ✅ [변경] 테스트 플래그(MOCK_FREEZE_LICENSE_LAST_OK)가 true면 갱신하지 않고 아래 grace 체크로 내려가게 함
// // // //     if (license != null && license.state == LicenseState.licensed) {
// // // //       if (!MOCK_FREEZE_LICENSE_LAST_OK) {
// // // //         await sp.setInt(_kLastLicensedMs, now);
// // // //         await sp.setInt(_kGraceUntilMs, now + graceDuration.inMilliseconds);
// // // //         return LicenseGateState.ok;
// // // //       }
// // // //       // ✅ freeze 상태에서는 일부러 “licensed 신호로 갱신하지 않고”
// // // //       // lastLicensed/graceUntil 기반으로 needsVerification을 재현합니다.
// // // //     }
// // // //
// // // //     // ✅ unknown(확인 불가) 또는 freeze(licensed지만 갱신 금지)면 유예 정책 적용
// // // //     final hasGrace = lastLicensed > 0 && now <= graceUntil;
// // // //     if (hasGrace) {
// // // //       return LicenseGateState.ok; // 유예 내면 정상 진입 허용(구매자 보호)
// // // //     }
// // // //
// // // //     // 유예가 없다면 “권한 재확인 필요”(장기 미접속/오프라인) 케이스를 재현
// // // //     return LicenseGateState.needsVerification;
// // // //   }
// // // //
// // // //   // ✅ [추가] Verify Access 버튼용 강제 갱신
// // // //   // - MOCK_FREEZE_LICENSE_LAST_OK가 켜져 있어도, 버튼 클릭 시에는 "정상 구매 확인"으로 갱신되게 함
// // // //   static Future<LicenseGateState> forceRefreshFromMock() async {
// // // //     final sp = await SharedPreferences.getInstance();
// // // //     final now = _TimeTravel.nowMs();
// // // //
// // // //     // ✅ MockBilling(=MockLicenseService) 재조회
// // // //     final svc = MockLicenseService();
// // // //     final license = await svc.fetch();
// // // //
// // // //     // ✅ 환불/미구매면 즉시 unlicensed
// // // //     if (license.state == LicenseState.unlicensed) {
// // // //       return LicenseGateState.unlicensed;
// // // //     }
// // // //
// // // //     // ✅ licensed/unknown 이면 여기서는 "확인 성공"으로 처리할지 정책이 갈림
// // // //     // 지금 단계 목표는 버튼 누르면 정상 진입이므로:
// // // //     // - licensed면 확실히 갱신 후 ok
// // // //     // - unknown이면 여전히 needsVerification 유지(보수적으로)
// // // //     if (license.state == LicenseState.licensed) {
// // // //       await sp.setInt(_kLastLicensedMs, now);
// // // //       await sp.setInt(_kGraceUntilMs, now + graceDuration.inMilliseconds);
// // // //       return LicenseGateState.ok;
// // // //     }
// // // //
// // // //     return LicenseGateState.needsVerification;
// // // //   }
// // // // }
// // // //
// // // // // ✅ [추가] Integrity 체크 Provider (앱 시작 시 1회 호출)
// // // // // - 여기서 Integrity 결과만 가져옴(성공/실패)
// // // // // - 실제 차단/유예 판단은 아래 integrityGateProvider에서 수행
// // // // final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
// // // //   try {
// // // //     final res = await IntegrityClient.requestToken();
// // // //
// // // //     print('Integrity raw result = $res');
// // // //
// // // //     final ok = res['ok'] == true;
// // // //     if (ok) {
// // // //       final token = res['token'] as String?;
// // // //       // 토큰 문자열이 존재하면 Integrity 호출 성공으로 간주
// // // //       return IntegrityCheckResult(ok: true, token: token);
// // // //     } else {
// // // //       final msg = res['errorMessage']?.toString() ?? 'Integrity check failed';
// // // //       return IntegrityCheckResult(ok: false, errorMessage: msg);
// // // //     }
// // // //   } catch (e) {
// // // //     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
// // // //   }
// // // // });
// // // //
// // // // // ✅ [추가] 점진적 제한(유예/제한) 게이트 Provider
// // // // // - Integrity 성공/실패를 기반으로 "ok/grace/restricted" 상태를 계산
// // // // // - SharedPreferences로 누적 상태를 저장하여, 오프라인 등에서 CS 폭탄을 줄임
// // // // final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
// // // //   final check = await ref.watch(integrityCheckProvider.future);
// // // //   return _IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// // // // });
// // // //
// // // // // ✅ [추가] (1번 방식 테스트 확장) Mock License 기반 “장기 미접속/오프라인” 재현 게이트
// // // // final licenseGateProvider = FutureProvider<LicenseGateState>((ref) async {
// // // //   final license = await ref.watch(mockLicenseProvider.future);
// // // //   return _LicensePolicy.evaluate(license: license);
// // // // });
// // // //
// // // // // 📍 보안 진입점 관리용 위젯
// // // // // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// // // // class SecurityGateway extends ConsumerWidget {
// // // //   const SecurityGateway({super.key});
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     // ✅ [추가] Integrity 체크를 먼저 수행 (점진적 제한 게이트)
// // // //     final gateAsync = ref.watch(integrityGateProvider);
// // // //
// // // //     // ✅ [추가] (1번 방식 테스트) Play 배포 없이 “구매/환불”을 흉내내는 Mock License
// // // //     // - flutter run --dart-define=MOCK_LICENSE=licensed
// // // //     // - flutter run --dart-define=MOCK_LICENSE=unlicensed
// // // //     // - flutter run --dart-define=MOCK_LICENSE=unknown
// // // //     final licenseAsync = ref.watch(mockLicenseProvider);
// // // //
// // // //     // ✅ [추가] (확장) 정상 구매자 장기 미접속(유예 만료) 테스트용 게이트
// // // //     final licenseGateAsync = ref.watch(licenseGateProvider);
// // // //
// // // //     // ✅ [추가] 둘 중 하나라도 로딩이면 스플래시
// // // //     if (gateAsync.isLoading || licenseAsync.isLoading || licenseGateAsync.isLoading) {
// // // //       return const MaterialApp(
// // // //         debugShowCheckedModeBanner: false,
// // // //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // // //       );
// // // //     }
// // // //
// // // //     // ✅ [추가] Mock License 에러가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// // // //     // 우선은 “license unknown”과 동일하게 취급(진입 허용)합니다.
// // // //     final license = licenseAsync.valueOrNull;
// // // //
// // // //     // ✅ [추가] (1번 방식 핵심) MOCK_LICENSE=unlicensed 이면 즉시 제한 화면으로
// // // //     // - 실제 운영에서는 Play Billing 조회 결과(환불/미구매)로 여기로 보내게 됩니다.
// // // //     if (license != null && license.state == LicenseState.unlicensed) {
// // // //       return const RestrictedScreen();
// // // //     }
// // // //
// // // //     // ✅ [추가] (테스트 확장) licensed/unknown 상태라도 “장기 미접속(유예 만료)”이면
// // // //     // “권한 재확인 필요” 화면으로 보내는 케이스를 재현합니다.
// // // //     final licenseGate = licenseGateAsync.valueOrNull;
// // // //     if (licenseGate == LicenseGateState.needsVerification) {
// // // //       return const NeedsVerificationScreen();
// // // //     }
// // // //
// // // //     return gateAsync.when(
// // // //       loading: () => const MaterialApp(
// // // //         debugShowCheckedModeBanner: false,
// // // //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // // //       ),
// // // //       error: (err, __) {
// // // //         // Integrity 체크 자체에서 예외가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// // // //         // 우선은 앱 진입 허용(나중에 정책/유예로 강화)
// // // //         return const SireApp();
// // // //       },
// // // //       data: (gateState) {
// // // //         // ✅ 제한 상태면 Continue 없이 잠금(또는 제한) 화면으로 이동
// // // //         if (gateState == IntegrityGateState.restricted) {
// // // //           //return const RestrictedScreen();
// // // //         }
// // // //
// // // //         // 📍 사용자의 PIN 설정 여부 비동기 확인
// // // //         final securityAsync = ref.watch(securityNotifierProvider);
// // // //
// // // //         return securityAsync.when(
// // // //           loading: () => const MaterialApp(
// // // //             debugShowCheckedModeBanner: false,
// // // //             home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // // //           ),
// // // //           // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
// // // //           error: (_, __) => const SireApp(),
// // // //           data: (hasPin) {
// // // //             // ✅ [변경] gateState가 grace여도 즉시 차단하지 않고 정상 진입 허용
// // // //             // - 필요하다면 grace 상태에서만 배너/토스트/안내 화면을 띄울 수 있음
// // // //             // - 현재는 "CS 최소화"를 위해 그냥 진입하도록 둠
// // // //
// // // //             if (hasPin) {
// // // //               // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
// // // //               // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
// // // //               return const MaterialApp(
// // // //                 debugShowCheckedModeBanner: false,
// // // //                 home: PinScreen(),
// // // //               );
// // // //             } else {
// // // //               // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
// // // //               // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
// // // //               return const SireApp();
// // // //             }
// // // //           },
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // ✅ [추가] 제한(Restricted) 화면
// // // // // - Continue 버튼 없이 “구매 상태/실행 환경 확인 불가” 상태를 명확히 전달
// // // // // - 서버 없는 구조에서 네트워크/일시 오류로 잠금이 되는 CS를 줄이기 위해
// // // // //   restricted 조건을 "연속 실패 누적"으로 만들었음
// // // // class RestrictedScreen extends StatelessWidget {
// // // //   const RestrictedScreen({super.key});
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       debugShowCheckedModeBanner: false,
// // // //       home: Scaffold(
// // // //         body: Center(
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.all(20),
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 // 🔹 Title (조금 더 크게, 상태 메시지 느낌)
// // // //                 const Text(
// // // //                   'Unable to verify app access',
// // // //                   textAlign: TextAlign.center,
// // // //                   style: TextStyle(
// // // //                     fontSize: 20,
// // // //                     fontWeight: FontWeight.w600,
// // // //                   ),
// // // //                 ),
// // // //
// // // //                 const SizedBox(height: 20),
// // // //
// // // //                 // 🔹 Body (센터 정렬이지만 줄 흐름이 자연스럽게)
// // // //                 const Text(
// // // //                   'This app can only be used with the Google account\n'
// // // //                       'used to purchase it.\n\n'
// // // //                       'Please check the account you are signed in with\n'
// // // //                       'on the Play Store.',
// // // //                   textAlign: TextAlign.center,
// // // //                   style: TextStyle(
// // // //                     fontSize: 14,
// // // //                     height: 1.4, // 줄 간격 조정 (가독성 핵심)
// // // //                   ),
// // // //                 ),
// // // //
// // // //                 const SizedBox(height: 32),
// // // //
// // // //                 // ✅ [추가] 나가기 버튼: 앱 종료
// // // //                 ElevatedButton(
// // // //                   onPressed: () {
// // // //                     SystemNavigator.pop(); // Android에서 앱 닫기
// // // //                   },
// // // //                   //child: const Text('나가기'),
// // // //                   child: const Text('Exit'),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // ✅ [추가] “정상 구매자였지만 장기 미접속/오프라인으로 권한 재확인이 필요” 화면(테스트용)
// // // // // - 버튼 누르면 Billing 재조회(Mock에서는 다시 fetch)
// // // // // - licensed면 grace 갱신 → 즉시 정상 진입
// // // // class NeedsVerificationScreen extends ConsumerStatefulWidget {
// // // //   const NeedsVerificationScreen({super.key});
// // // //
// // // //   @override
// // // //   ConsumerState<NeedsVerificationScreen> createState() =>
// // // //       _NeedsVerificationScreenState();
// // // // }
// // // //
// // // // class _NeedsVerificationScreenState
// // // //     extends ConsumerState<NeedsVerificationScreen> {
// // // //   bool _checking = false;
// // // //   String? _error;
// // // //
// // // //   Future<void> _verifyAccess() async {
// // // //     setState(() {
// // // //       _checking = true;
// // // //       _error = null;
// // // //     });
// // // //
// // // //     try {
// // // //       // ✅ [변경] Verify Access 버튼은 "강제 갱신"으로 처리
// // // //       final gate = await _LicensePolicy.forceRefreshFromMock();
// // // //
// // // //       // ✅ [추가] UI/게이트 상태도 최신화
// // // //       ref.invalidate(mockLicenseProvider);
// // // //       ref.invalidate(licenseGateProvider);
// // // //
// // // //       if (!mounted) return;
// // // //
// // // //       if (gate == LicenseGateState.ok) {
// // // //         // ✅ licensed(또는 grace 내 ok) → 정상 진입
// // // //         final hasPin = await ref.read(securityNotifierProvider.future);
// // // //
// // // //         if (!mounted) return;
// // // //
// // // //         Navigator.of(context).pushReplacement(
// // // //           MaterialPageRoute(
// // // //             builder: (_) => hasPin ? const PinScreen() : const SireApp(),
// // // //           ),
// // // //         );
// // // //         return;
// // // //       }
// // // //
// // // //       if (gate == LicenseGateState.unlicensed) {
// // // //         // ✅ 환불/미구매 확정이면 제한 화면으로 이동
// // // //         Navigator.of(context).pushReplacement(
// // // //           MaterialPageRoute(builder: (_) => const RestrictedScreen()),
// // // //         );
// // // //         return;
// // // //       }
// // // //
// // // //       // needsVerification 유지
// // // //       setState(() {
// // // //         _error =
// // // //         'Still unable to verify access.\nPlease check your internet connection and try again.';
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         _error = e.toString();
// // // //       });
// // // //     } finally {
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           _checking = false;
// // // //         });
// // // //       }
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       debugShowCheckedModeBanner: false,
// // // //       home: Scaffold(
// // // //         body: Center(
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.all(20),
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 const Text(
// // // //                   'Access verification required',
// // // //                   textAlign: TextAlign.center,
// // // //                   style: TextStyle(
// // // //                     fontSize: 20,
// // // //                     fontWeight: FontWeight.w600,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 20),
// // // //                 const Text(
// // // //                   'We need to verify your access to continue.\n\n'
// // // //                       'Please connect to the internet and try again.',
// // // //                   textAlign: TextAlign.center,
// // // //                   style: TextStyle(
// // // //                     fontSize: 14,
// // // //                     height: 1.4,
// // // //                   ),
// // // //                 ),
// // // //
// // // //                 if (_error != null) ...[
// // // //                   const SizedBox(height: 16),
// // // //                   Text(
// // // //                     _error!,
// // // //                     textAlign: TextAlign.center,
// // // //                     style: const TextStyle(
// // // //                       fontSize: 13,
// // // //                       height: 1.4,
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //
// // // //                 const SizedBox(height: 28),
// // // //
// // // //                 // ✅ [추가] Verify Access 버튼
// // // //                 ElevatedButton(
// // // //                   onPressed: _checking ? null : _verifyAccess,
// // // //                   child: _checking
// // // //                       ? const SizedBox(
// // // //                     width: 18,
// // // //                     height: 18,
// // // //                     child: CircularProgressIndicator(strokeWidth: 2),
// // // //                   )
// // // //                       : const Text('Verify Access'),
// // // //                 ),
// // // //
// // // //                 const SizedBox(height: 12),
// // // //
// // // //                 // ✅ [추가] Exit 버튼
// // // //                 TextButton(
// // // //                   onPressed: () {
// // // //                     SystemNavigator.pop(); // Android에서 앱 닫기
// // // //                   },
// // // //                   child: const Text('Exit'),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // ✅ [유지] Integrity 실패 시 테스트용 경고 화면
// // // // // - 점진적 제한 적용 후에는 기본적으로 바로 사용자가 보지 않게 됨(grace 정책 때문)
// // // // // - 다만 개발 단계에서 “실패 사유 확인” 등에 유용하므로 유지
// // // // class _IntegrityWarningScreen extends StatelessWidget {
// // // //   final String message;
// // // //   final bool hasPin;
// // // //
// // // //   const _IntegrityWarningScreen({
// // // //     required this.message,
// // // //     required this.hasPin,
// // // //   });
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(title: const Text('Integrity Check')),
// // // //       body: Padding(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             const Text(
// // // //               'Integrity check failed (TEST MODE)',
// // // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // //             ),
// // // //             const SizedBox(height: 12),
// // // //             Text('Reason: $message'),
// // // //             const SizedBox(height: 24),
// // // //             const Text(
// // // //               '현재는 서버 없는 구조이므로 즉시 차단하지 않고 진입을 허용합니다.\n'
// // // //                   '다음 단계에서 실패 누적/유예/제한 정책을 연결합니다.',
// // // //             ),
// // // //             const SizedBox(height: 24),
// // // //             ElevatedButton(
// // // //               onPressed: () {
// // // //                 // PIN 여부에 따라 기존 진입 흐름 유지
// // // //                 if (hasPin) {
// // // //                   Navigator.of(context).pushReplacement(
// // // //                     MaterialPageRoute(builder: (_) => const PinScreen()),
// // // //                   );
// // // //                 } else {
// // // //                   Navigator.of(context).pushReplacement(
// // // //                     MaterialPageRoute(builder: (_) => const SireApp()),
// // // //                   );
// // // //                 }
// // // //               },
// // // //               child: const Text('Continue'),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // final mockLicenseProvider = FutureProvider<LicenseStatus>((ref) async {
// // // //   final svc = MockLicenseService();
// // // //   return svc.fetch();
// // // // });
// // //
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
// // //
// // // import 'app.dart';
// // // import 'core/database/app_database.dart';
// // // import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// // // import 'core/database/database_provider.dart';
// // // import 'features/security/pin_screen.dart';
// // // import 'features/security/security_provider.dart';
// // //
// // // // ✅ [추가] Play Integrity 호출 클라이언트
// // // import 'core/platform/integrity_client.dart';
// // //
// // // // ✅ [정리] Integrity 정책은 별도 파일로 분리
// // // import 'core/platform/integrity_policy.dart';
// // //
// // // // ✅ [추가] 점진적 제한(유예/제한) 상태 저장용
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import 'core/license/license_model.dart';
// // // import 'core/license/mock_license_service.dart';
// // //
// // // import 'package:flutter/services.dart'; // ✅ SystemNavigator.pop() 사용
// // //
// // // void main() async {
// // //   // 📍 플러터 엔진과 위젯 바인딩 초기화
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //
// // //   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
// // //   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
// // //   await initializeDateFormatting(null, null);
// // //
// // //   // 📍 데이터베이스 싱글톤 인스턴스 생성
// // //   final database = AppDatabase();
// // //
// // //   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
// // //   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
// // //   await seedDatabase(database);
// // //
// // //   runApp(
// // //     ProviderScope(
// // //       overrides: [
// // //         // 생성된 DB 인스턴스를 프로바이더에 주입
// // //         databaseProvider.overrideWithValue(database),
// // //       ],
// // //       // 💡 보안 진입점(Gateway)을 통해 앱 시작
// // //       child: const SecurityGateway(),
// // //     ),
// // //   );
// // // }
// // //
// // // // ✅ [유지] Integrity 체크 결과를 담기 위한 간단 모델
// // // class IntegrityCheckResult {
// // //   final bool ok;
// // //   final String? token; // 성공 시 토큰(서버 없으므로 판독은 못 하지만, “성공 여부” 신호로 사용)
// // //   final String? errorMessage;
// // //
// // //   const IntegrityCheckResult({
// // //     required this.ok,
// // //     this.token,
// // //     this.errorMessage,
// // //   });
// // // }
// // //
// // // // ✅ [유지] (테스트용) “시간 이동” 기능
// // // // - 정상 구매자가 오랫동안 접속하지 못해 grace가 만료되는 케이스를 Play 배포 없이 재현하기 위함
// // // // - 사용법: flutter run --dart-define=MOCK_TIME_TRAVEL_DAYS=15
// // // //
// // // // ✅ [정리 포인트]
// // // // - IntegrityPolicy는 별도 파일로 분리했지만, TimeTravel은 "테스트 런"을 위한 것이므로
// // // //   main.dart에 유지합니다(운영 반영 시 제거 가능).
// // // class _TimeTravel {
// // //   static int _readDays() {
// // //     const s = String.fromEnvironment('MOCK_TIME_TRAVEL_DAYS', defaultValue: '0');
// // //     return int.tryParse(s) ?? 0;
// // //   }
// // //
// // //   static int nowMs() {
// // //     final base = DateTime.now().millisecondsSinceEpoch;
// // //     final days = _readDays();
// // //     if (days <= 0) return base;
// // //     return base + Duration(days: days).inMilliseconds;
// // //   }
// // // }
// // //
// // // // ✅ [유지] (테스트용) licensed인데도 lastLicensed/grace 갱신을 막아서
// // // // “오래 미접속” 상황을 재현하기 위한 플래그
// // // // 사용법:
// // // // flutter run --dart-define=MOCK_LICENSE=licensed --dart-define=MOCK_TIME_TRAVEL_DAYS=15 --dart-define=MOCK_FREEZE_LICENSE_LAST_OK=true
// // // const bool MOCK_FREEZE_LICENSE_LAST_OK =
// // // bool.fromEnvironment('MOCK_FREEZE_LICENSE_LAST_OK', defaultValue: false);
// // //
// // // // ✅ [유지] (1번 방식 테스트 확장) “구매 상태(licensed/unknown)”에서도
// // // // 일정 기간(예: 14일) 동안 재확인이 안 되면 “권한 재확인 필요” 화면으로 보내기 위한 정책
// // // enum LicenseGateState {
// // //   ok, // 정상 진입
// // //   needsVerification, // 권한 재확인 필요(장기 미접속/오프라인 등)
// // //   unlicensed, // 미구매/환불(즉시 제한 화면)
// // // }
// // //
// // // // ✅ [유지/정리] 라이선스(구매 상태) 점진적 제한 정책 (14일 유예)
// // // // - licensed/unknown 상태에서도 장기간 재확인이 없으면 “권한 재확인 필요”로 보냄
// // // //
// // // // ✅ [정리 포인트]
// // // // - 실제 운영에서는 MockLicenseService가 아니라 Play Billing 조회로 교체됩니다.
// // // // - 이 정책 자체는 운영에서도 그대로 가져갈 수 있습니다.
// // // class _LicensePolicy {
// // //   static const _kLastLicensedMs = 'license_last_licensed_ms';
// // //   static const _kGraceUntilMs = 'license_grace_until_ms';
// // //
// // //   // ✅ 운영 정책(권장): 14일
// // //   static const Duration graceDuration = Duration(days: 14);
// // //
// // //   static Future<LicenseGateState> evaluate({
// // //     required LicenseStatus? license,
// // //   }) async {
// // //     final sp = await SharedPreferences.getInstance();
// // //     final now = _TimeTravel.nowMs();
// // //
// // //     final lastLicensed = sp.getInt(_kLastLicensedMs) ?? 0;
// // //     final graceUntil = sp.getInt(_kGraceUntilMs) ?? 0;
// // //
// // //     // ✅ unlicensed는 즉시 제한(환불/미구매 확정)
// // //     if (license != null && license.state == LicenseState.unlicensed) {
// // //       return LicenseGateState.unlicensed;
// // //     }
// // //
// // //     // ✅ licensed면 “정상 구매 확인”으로 간주하고 유예 갱신
// // //     // ✅ [변경] 테스트 플래그(MOCK_FREEZE_LICENSE_LAST_OK)가 true면 갱신하지 않고 아래 grace 체크로 내려가게 함
// // //     if (license != null && license.state == LicenseState.licensed) {
// // //       if (!MOCK_FREEZE_LICENSE_LAST_OK) {
// // //         await sp.setInt(_kLastLicensedMs, now);
// // //         await sp.setInt(_kGraceUntilMs, now + graceDuration.inMilliseconds);
// // //         return LicenseGateState.ok;
// // //       }
// // //       // ✅ freeze 상태에서는 일부러 “licensed 신호로 갱신하지 않고”
// // //       // lastLicensed/graceUntil 기반으로 needsVerification을 재현합니다.
// // //     }
// // //
// // //     // ✅ unknown(확인 불가) 또는 freeze(licensed지만 갱신 금지)면 유예 정책 적용
// // //     final hasGrace = lastLicensed > 0 && now <= graceUntil;
// // //     if (hasGrace) {
// // //       return LicenseGateState.ok; // 유예 내면 정상 진입 허용(구매자 보호)
// // //     }
// // //
// // //     // 유예가 없다면 “권한 재확인 필요”(장기 미접속/오프라인) 케이스를 재현
// // //     return LicenseGateState.needsVerification;
// // //   }
// // //
// // //   // ✅ [추가] Verify Access 버튼용 강제 갱신
// // //   // - MOCK_FREEZE_LICENSE_LAST_OK가 켜져 있어도, 버튼 클릭 시에는 "정상 구매 확인"으로 갱신되게 함
// // //   static Future<LicenseGateState> forceRefreshFromMock() async {
// // //     final sp = await SharedPreferences.getInstance();
// // //     final now = _TimeTravel.nowMs();
// // //
// // //     // ✅ MockBilling(=MockLicenseService) 재조회
// // //     final svc = MockLicenseService();
// // //     final license = await svc.fetch();
// // //
// // //     // ✅ 환불/미구매면 즉시 unlicensed
// // //     if (license.state == LicenseState.unlicensed) {
// // //       return LicenseGateState.unlicensed;
// // //     }
// // //
// // //     // ✅ licensed/unknown 이면 여기서는 "확인 성공"으로 처리할지 정책이 갈림
// // //     // 지금 단계 목표는 버튼 누르면 정상 진입이므로:
// // //     // - licensed면 확실히 갱신 후 ok
// // //     // - unknown이면 여전히 needsVerification 유지(보수적으로)
// // //     if (license.state == LicenseState.licensed) {
// // //       await sp.setInt(_kLastLicensedMs, now);
// // //       await sp.setInt(_kGraceUntilMs, now + graceDuration.inMilliseconds);
// // //       return LicenseGateState.ok;
// // //     }
// // //
// // //     return LicenseGateState.needsVerification;
// // //   }
// // // }
// // //
// // // // ✅ [정리] Integrity 체크 Provider (앱 시작 시 1회 호출)
// // // // - 여기서 Integrity 결과만 가져옴(성공/실패)
// // // // - 실제 차단/유예 판단은 아래 integrityGateProvider에서 수행
// // // final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
// // //   try {
// // //     final res = await IntegrityClient.requestToken();
// // //
// // //     // ignore: avoid_print
// // //     print('Integrity raw result = $res');
// // //
// // //     final ok = res['ok'] == true;
// // //     if (ok) {
// // //       final token = res['token'] as String?;
// // //       // 토큰 문자열이 존재하면 Integrity 호출 성공으로 간주
// // //       return IntegrityCheckResult(ok: true, token: token);
// // //     } else {
// // //       final msg = res['errorMessage']?.toString() ?? 'Integrity check failed';
// // //       return IntegrityCheckResult(ok: false, errorMessage: msg);
// // //     }
// // //   } catch (e) {
// // //     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
// // //   }
// // // });
// // //
// // // // ✅ [정리] 점진적 제한(유예/제한) 게이트 Provider
// // // // - Integrity 성공/실패를 기반으로 "ok/grace/restricted" 상태를 계산
// // // // - SharedPreferences로 누적 상태를 저장하여, 오프라인 등에서 CS 폭탄을 줄임
// // // final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
// // //   final check = await ref.watch(integrityCheckProvider.future);
// // //
// // //   // ✅ [정리] IntegrityPolicy는 별도 파일(integrity_policy.dart)로 이동
// // //   return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// // // });
// // //
// // // // ✅ [정리] (1번 방식 테스트) Play 배포 없이 “구매/환불”을 흉내내는 Mock License
// // // final mockLicenseProvider = FutureProvider<LicenseStatus>((ref) async {
// // //   final svc = MockLicenseService();
// // //   return svc.fetch();
// // // });
// // //
// // // // ✅ [정리] (1번 방식 테스트 확장) Mock License 기반 “장기 미접속/오프라인” 재현 게이트
// // // final licenseGateProvider = FutureProvider<LicenseGateState>((ref) async {
// // //   final license = await ref.watch(mockLicenseProvider.future);
// // //   return _LicensePolicy.evaluate(license: license);
// // // });
// // //
// // // // 📍 보안 진입점 관리용 위젯
// // // // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// // // class SecurityGateway extends ConsumerWidget {
// // //   const SecurityGateway({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context, WidgetRef ref) {
// // //     // ✅ [추가] Integrity 체크를 먼저 수행 (점진적 제한 게이트)
// // //     final gateAsync = ref.watch(integrityGateProvider);
// // //
// // //     // ✅ [유지] (1번 방식 테스트) Mock License
// // //     // - flutter run --dart-define=MOCK_LICENSE=licensed
// // //     // - flutter run --dart-define=MOCK_LICENSE=unlicensed
// // //     // - flutter run --dart-define=MOCK_LICENSE=unknown
// // //     final licenseAsync = ref.watch(mockLicenseProvider);
// // //
// // //     // ✅ [유지] (확장) 정상 구매자 장기 미접속(유예 만료) 테스트용 게이트
// // //     final licenseGateAsync = ref.watch(licenseGateProvider);
// // //
// // //     // ✅ [유지] 둘 중 하나라도 로딩이면 스플래시
// // //     if (gateAsync.isLoading || licenseAsync.isLoading || licenseGateAsync.isLoading) {
// // //       return const MaterialApp(
// // //         debugShowCheckedModeBanner: false,
// // //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // //       );
// // //     }
// // //
// // //     // ✅ [유지] Mock License 에러가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// // //     // 우선은 “license unknown”과 동일하게 취급(진입 허용)합니다.
// // //     final license = licenseAsync.valueOrNull;
// // //
// // //     // ✅ [유지] (핵심) MOCK_LICENSE=unlicensed 이면 즉시 제한 화면으로
// // //     // - 실제 운영에서는 Play Billing 조회 결과(환불/미구매)로 여기로 보내게 됩니다.
// // //     if (license != null && license.state == LicenseState.unlicensed) {
// // //       return const RestrictedScreen();
// // //     }
// // //
// // //     // ✅ [유지] (테스트 확장) licensed/unknown 상태라도 “장기 미접속(유예 만료)”이면
// // //     // “권한 재확인 필요” 화면으로 보내는 케이스를 재현합니다.
// // //     final licenseGate = licenseGateAsync.valueOrNull;
// // //     if (licenseGate == LicenseGateState.needsVerification) {
// // //       return const NeedsVerificationScreen();
// // //     }
// // //
// // //     return gateAsync.when(
// // //       loading: () => const MaterialApp(
// // //         debugShowCheckedModeBanner: false,
// // //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // //       ),
// // //       error: (err, __) {
// // //         // Integrity 체크 자체에서 예외가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// // //         // 우선은 앱 진입 허용(나중에 정책/유예로 강화)
// // //         return const SireApp();
// // //       },
// // //       data: (gateState) {
// // //         // ✅ 제한 상태면 Continue 없이 잠금(또는 제한) 화면으로 이동
// // //         if (gateState == IntegrityGateState.restricted) {
// // //           //return const RestrictedScreen();
// // //         }
// // //
// // //         // 📍 사용자의 PIN 설정 여부 비동기 확인
// // //         final securityAsync = ref.watch(securityNotifierProvider);
// // //
// // //         return securityAsync.when(
// // //           loading: () => const MaterialApp(
// // //             debugShowCheckedModeBanner: false,
// // //             home: Scaffold(body: Center(child: CircularProgressIndicator())),
// // //           ),
// // //           // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
// // //           error: (_, __) => const SireApp(),
// // //           data: (hasPin) {
// // //             // ✅ [변경] gateState가 grace여도 즉시 차단하지 않고 정상 진입 허용
// // //             // - 필요하다면 grace 상태에서만 배너/토스트/안내 화면을 띄울 수 있음
// // //             // - 현재는 "CS 최소화"를 위해 그냥 진입하도록 둠
// // //
// // //             if (hasPin) {
// // //               // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
// // //               // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
// // //               return const MaterialApp(
// // //                 debugShowCheckedModeBanner: false,
// // //                 home: PinScreen(),
// // //               );
// // //             } else {
// // //               // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
// // //               // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
// // //               return const SireApp();
// // //             }
// // //           },
// // //         );
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // // ✅ [유지] 제한(Restricted) 화면
// // // // - Continue 버튼 없이 “구매 상태/실행 환경 확인 불가” 상태를 명확히 전달
// // // // - 서버 없는 구조에서 네트워크/일시 오류로 잠금이 되는 CS를 줄이기 위해
// // // //   restricted 조건을 "연속 실패 누적"으로 만들었음
// // // class RestrictedScreen extends StatelessWidget {
// // //   const RestrictedScreen({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       home: Scaffold(
// // //         body: Center(
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(20),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 // 🔹 Title (조금 더 크게, 상태 메시지 느낌)
// // //                 const Text(
// // //                   'Unable to verify app access',
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(
// // //                     fontSize: 20,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 20),
// // //
// // //                 // 🔹 Body (센터 정렬이지만 줄 흐름이 자연스럽게)
// // //                 const Text(
// // //                   'This app can only be used with the Google account\n'
// // //                       'used to purchase it.\n\n'
// // //                       'Please check the account you are signed in with\n'
// // //                       'on the Play Store.',
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(
// // //                     fontSize: 14,
// // //                     height: 1.4, // 줄 간격 조정 (가독성 핵심)
// // //                   ),
// // //                 ),
// // //
// // //                 const SizedBox(height: 32),
// // //
// // //                 // ✅ [추가] 나가기 버튼: 앱 종료
// // //                 ElevatedButton(
// // //                   onPressed: () {
// // //                     SystemNavigator.pop(); // Android에서 앱 닫기
// // //                   },
// // //                   //child: const Text('나가기'),
// // //                   child: const Text('Exit'),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ✅ [유지] “정상 구매자였지만 장기 미접속/오프라인으로 권한 재확인이 필요” 화면(테스트용)
// // // // - 버튼 누르면 Billing 재조회(Mock에서는 다시 fetch)
// // // // - licensed면 grace 갱신 → 즉시 정상 진입
// // // class NeedsVerificationScreen extends ConsumerStatefulWidget {
// // //   const NeedsVerificationScreen({super.key});
// // //
// // //   @override
// // //   ConsumerState<NeedsVerificationScreen> createState() =>
// // //       _NeedsVerificationScreenState();
// // // }
// // //
// // // class _NeedsVerificationScreenState extends ConsumerState<NeedsVerificationScreen> {
// // //   bool _checking = false;
// // //   String? _error;
// // //
// // //   Future<void> _verifyAccess() async {
// // //     setState(() {
// // //       _checking = true;
// // //       _error = null;
// // //     });
// // //
// // //     try {
// // //       // ✅ [유지] Verify Access 버튼은 "강제 갱신"으로 처리
// // //       final gate = await _LicensePolicy.forceRefreshFromMock();
// // //
// // //       // ✅ [유지] UI/게이트 상태도 최신화
// // //       ref.invalidate(mockLicenseProvider);
// // //       ref.invalidate(licenseGateProvider);
// // //
// // //       if (!mounted) return;
// // //
// // //       if (gate == LicenseGateState.ok) {
// // //         // ✅ licensed(또는 grace 내 ok) → 정상 진입
// // //         final hasPin = await ref.read(securityNotifierProvider.future);
// // //
// // //         if (!mounted) return;
// // //
// // //         Navigator.of(context).pushReplacement(
// // //           MaterialPageRoute(
// // //             builder: (_) => hasPin ? const PinScreen() : const SireApp(),
// // //           ),
// // //         );
// // //         return;
// // //       }
// // //
// // //       if (gate == LicenseGateState.unlicensed) {
// // //         // ✅ 환불/미구매 확정이면 제한 화면으로 이동
// // //         Navigator.of(context).pushReplacement(
// // //           MaterialPageRoute(builder: (_) => const RestrictedScreen()),
// // //         );
// // //         return;
// // //       }
// // //
// // //       // needsVerification 유지
// // //       setState(() {
// // //         _error =
// // //         'Still unable to verify access.\nPlease check your internet connection and try again.';
// // //       });
// // //     } catch (e) {
// // //       setState(() {
// // //         _error = e.toString();
// // //       });
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() {
// // //           _checking = false;
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       home: Scaffold(
// // //         body: Center(
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(20),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 const Text(
// // //                   'Access verification required',
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(
// // //                     fontSize: 20,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //                 const Text(
// // //                   'We need to verify your access to continue.\n\n'
// // //                       'Please connect to the internet and try again.',
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(
// // //                     fontSize: 14,
// // //                     height: 1.4,
// // //                   ),
// // //                 ),
// // //                 if (_error != null) ...[
// // //                   const SizedBox(height: 16),
// // //                   Text(
// // //                     _error!,
// // //                     textAlign: TextAlign.center,
// // //                     style: const TextStyle(
// // //                       fontSize: 13,
// // //                       height: 1.4,
// // //                     ),
// // //                   ),
// // //                 ],
// // //                 const SizedBox(height: 28),
// // //
// // //                 // ✅ [추가] Verify Access 버튼
// // //                 ElevatedButton(
// // //                   onPressed: _checking ? null : _verifyAccess,
// // //                   child: _checking
// // //                       ? const SizedBox(
// // //                     width: 18,
// // //                     height: 18,
// // //                     child: CircularProgressIndicator(strokeWidth: 2),
// // //                   )
// // //                       : const Text('Verify Access'),
// // //                 ),
// // //
// // //                 const SizedBox(height: 12),
// // //
// // //                 // ✅ [추가] Exit 버튼
// // //                 TextButton(
// // //                   onPressed: () {
// // //                     SystemNavigator.pop(); // Android에서 앱 닫기
// // //                   },
// // //                   child: const Text('Exit'),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ✅ [유지] Integrity 실패 시 테스트용 경고 화면
// // // // - 점진적 제한 적용 후에는 기본적으로 바로 사용자가 보지 않게 됨(grace 정책 때문)
// // // // - 다만 개발 단계에서 “실패 사유 확인” 등에 유용하므로 유지
// // // class _IntegrityWarningScreen extends StatelessWidget {
// // //   final String message;
// // //   final bool hasPin;
// // //
// // //   const _IntegrityWarningScreen({
// // //     required this.message,
// // //     required this.hasPin,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('Integrity Check')),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             const Text(
// // //               'Integrity check failed (TEST MODE)',
// // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //             ),
// // //             const SizedBox(height: 12),
// // //             Text('Reason: $message'),
// // //             const SizedBox(height: 24),
// // //             const Text(
// // //               '현재는 서버 없는 구조이므로 즉시 차단하지 않고 진입을 허용합니다.\n'
// // //                   '다음 단계에서 실패 누적/유예/제한 정책을 연결합니다.',
// // //             ),
// // //             const SizedBox(height: 24),
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 // PIN 여부에 따라 기존 진입 흐름 유지
// // //                 if (hasPin) {
// // //                   Navigator.of(context).pushReplacement(
// // //                     MaterialPageRoute(builder: (_) => const PinScreen()),
// // //                   );
// // //                 } else {
// // //                   Navigator.of(context).pushReplacement(
// // //                     MaterialPageRoute(builder: (_) => const SireApp()),
// // //                   );
// // //                 }
// // //               },
// // //               child: const Text('Continue'),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// //
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
// //
// // import 'app.dart';
// // import 'core/database/app_database.dart';
// // import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// // import 'core/database/database_provider.dart';
// // import 'features/security/pin_screen.dart';
// // import 'features/security/security_provider.dart';
// //
// // // ✅ [추가] Play Integrity 호출 클라이언트
// // import 'core/platform/integrity_client.dart';
// //
// // // ✅ [정리] Integrity 정책은 core/platform/integrity_policy.dart
// // import 'core/platform/integrity_policy.dart';
// //
// // // ✅ [추가] 점진적 제한(유예/제한) 상태 저장용
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import 'core/license/license_model.dart';
// // import 'core/license/mock_license_service.dart';
// //
// // // ✅ [정리] License 정책은 core/license/license_policy.dart로 분리
// // import 'core/license/license_policy.dart';
// //
// // import 'package:flutter/services.dart'; // ✅ SystemNavigator.pop() 사용
// //
// // void main() async {
// //   // 📍 플러터 엔진과 위젯 바인딩 초기화
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
// //   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
// //   await initializeDateFormatting(null, null);
// //
// //   // 📍 데이터베이스 싱글톤 인스턴스 생성
// //   final database = AppDatabase();
// //
// //   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
// //   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
// //   await seedDatabase(database);
// //
// //   runApp(
// //     ProviderScope(
// //       overrides: [
// //         // 생성된 DB 인스턴스를 프로바이더에 주입
// //         databaseProvider.overrideWithValue(database),
// //       ],
// //       // 💡 보안 진입점(Gateway)을 통해 앱 시작
// //       child: const SecurityGateway(),
// //     ),
// //   );
// // }
// //
// // // ✅ [추가] Integrity 체크 결과를 담기 위한 간단 모델
// // class IntegrityCheckResult {
// //   final bool ok;
// //   final String? token; // 성공 시 토큰(서버 없으므로 판독은 못 하지만, “성공 여부” 신호로 사용)
// //   final String? errorMessage;
// //
// //   const IntegrityCheckResult({
// //     required this.ok,
// //     this.token,
// //     this.errorMessage,
// //   });
// // }
// //
// // // ✅ [정리] Integrity 체크 Provider (앱 시작 시 1회 호출)
// // // - 여기서 Integrity 결과만 가져옴(성공/실패)
// // // - 실제 차단/유예 판단은 아래 integrityGateProvider에서 수행
// // final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
// //   try {
// //     final res = await IntegrityClient.requestToken();
// //
// //     // ignore: avoid_print
// //     print('Integrity raw result = $res');
// //
// //     final ok = res['ok'] == true;
// //     if (ok) {
// //       final token = res['token'] as String?;
// //       // 토큰 문자열이 존재하면 Integrity 호출 성공으로 간주
// //       return IntegrityCheckResult(ok: true, token: token);
// //     } else {
// //       final msg = res['errorMessage']?.toString() ?? 'Integrity check failed';
// //       return IntegrityCheckResult(ok: false, errorMessage: msg);
// //     }
// //   } catch (e) {
// //     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
// //   }
// // });
// //
// // // ✅ [추가] 점진적 제한(유예/제한) 게이트 Provider
// // // - Integrity 성공/실패를 기반으로 "ok/grace/restricted" 상태를 계산
// // // - SharedPreferences로 누적 상태를 저장하여, 오프라인 등에서 CS 폭탄을 줄임
// // final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
// //   final check = await ref.watch(integrityCheckProvider.future);
// //   return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// // });
// //
// // // ✅ [정리] (1번 방식 테스트) Play 배포 없이 “구매/환불”을 흉내내는 Mock License
// // final mockLicenseProvider = FutureProvider<LicenseStatus>((ref) async {
// //   final svc = MockLicenseService();
// //   return svc.fetch();
// // });
// //
// // // ✅ [정리] (1번 방식 테스트 확장) Mock License 기반 “장기 미접속/오프라인” 재현 게이트
// // final licenseGateProvider = FutureProvider<LicenseGateState>((ref) async {
// //   final license = await ref.watch(mockLicenseProvider.future);
// //   return LicensePolicy.evaluate(license: license);
// // });
// //
// // // 📍 보안 진입점 관리용 위젯
// // // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// // class SecurityGateway extends ConsumerWidget {
// //   const SecurityGateway({super.key});
// //
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     // ✅ [추가] Integrity 체크를 먼저 수행 (점진적 제한 게이트)
// //     final gateAsync = ref.watch(integrityGateProvider);
// //
// //     // ✅ [추가] (1번 방식 테스트) Play 배포 없이 “구매/환불”을 흉내내는 Mock License
// //     // - flutter run --dart-define=MOCK_LICENSE=licensed
// //     // - flutter run --dart-define=MOCK_LICENSE=unlicensed
// //     // - flutter run --dart-define=MOCK_LICENSE=unknown
// //     final licenseAsync = ref.watch(mockLicenseProvider);
// //
// //     // ✅ [추가] (확장) 정상 구매자 장기 미접속(유예 만료) 테스트용 게이트
// //     final licenseGateAsync = ref.watch(licenseGateProvider);
// //
// //     // ✅ [추가] 둘 중 하나라도 로딩이면 스플래시
// //     if (gateAsync.isLoading || licenseAsync.isLoading || licenseGateAsync.isLoading) {
// //       return const MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// //       );
// //     }
// //
// //     // ✅ [추가] Mock License 에러가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// //     // 우선은 “license unknown”과 동일하게 취급(진입 허용)합니다.
// //     final license = licenseAsync.valueOrNull;
// //
// //     // ✅ [추가] (1번 방식 핵심) MOCK_LICENSE=unlicensed 이면 즉시 제한 화면으로
// //     // - 실제 운영에서는 Play Billing 조회 결과(환불/미구매)로 여기로 보내게 됩니다.
// //     if (license != null && license.state == LicenseState.unlicensed) {
// //       return const RestrictedScreen();
// //     }
// //
// //     // ✅ [추가] (테스트 확장) licensed/unknown 상태라도 “장기 미접속(유예 만료)”이면
// //     // “권한 재확인 필요” 화면으로 보내는 케이스를 재현합니다.
// //     final licenseGate = licenseGateAsync.valueOrNull;
// //     if (licenseGate == LicenseGateState.needsVerification) {
// //       return const NeedsVerificationScreen();
// //     }
// //
// //     return gateAsync.when(
// //       loading: () => const MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// //       ),
// //       error: (err, __) {
// //         // Integrity 체크 자체에서 예외가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// //         // 우선은 앱 진입 허용(나중에 정책/유예로 강화)
// //         return const SireApp();
// //       },
// //       data: (gateState) {
// //         // ✅ 제한 상태면 Continue 없이 잠금(또는 제한) 화면으로 이동
// //         if (gateState == IntegrityGateState.restricted) {
// //           //return const RestrictedScreen();
// //         }
// //
// //         // 📍 사용자의 PIN 설정 여부 비동기 확인
// //         final securityAsync = ref.watch(securityNotifierProvider);
// //
// //         return securityAsync.when(
// //           loading: () => const MaterialApp(
// //             debugShowCheckedModeBanner: false,
// //             home: Scaffold(body: Center(child: CircularProgressIndicator())),
// //           ),
// //           // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
// //           error: (_, __) => const SireApp(),
// //           data: (hasPin) {
// //             // ✅ [변경] gateState가 grace여도 즉시 차단하지 않고 정상 진입 허용
// //             // - 필요하다면 grace 상태에서만 배너/토스트/안내 화면을 띄울 수 있음
// //             // - 현재는 "CS 최소화"를 위해 그냥 진입하도록 둠
// //
// //             if (hasPin) {
// //               // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
// //               // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
// //               return const MaterialApp(
// //                 debugShowCheckedModeBanner: false,
// //                 home: PinScreen(),
// //               );
// //             } else {
// //               // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
// //               // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
// //               return const SireApp();
// //             }
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ✅ [추가] 제한(Restricted) 화면
// // // - Continue 버튼 없이 “구매 상태/실행 환경 확인 불가” 상태를 명확히 전달
// // // - 서버 없는 구조에서 네트워크/일시 오류로 잠금이 되는 CS를 줄이기 위해
// // //   restricted 조건을 "연속 실패 누적"으로 만들었음
// // class RestrictedScreen extends StatelessWidget {
// //   const RestrictedScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: Scaffold(
// //         body: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // 🔹 Title (조금 더 크게, 상태 메시지 느낌)
// //                 const Text(
// //                   'Unable to verify app access',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 20),
// //
// //                 // 🔹 Body (센터 정렬이지만 줄 흐름이 자연스럽게)
// //                 const Text(
// //                   'This app can only be used with the Google account\n'
// //                       'used to purchase it.\n\n'
// //                       'Please check the account you are signed in with\n'
// //                       'on the Play Store.',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     height: 1.4, // 줄 간격 조정 (가독성 핵심)
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 32),
// //
// //                 // ✅ [추가] 나가기 버튼: 앱 종료
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     SystemNavigator.pop(); // Android에서 앱 닫기
// //                   },
// //                   //child: const Text('나가기'),
// //                   child: const Text('Exit'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ✅ [추가] “정상 구매자였지만 장기 미접속/오프라인으로 권한 재확인이 필요” 화면(테스트용)
// // // - 버튼 누르면 Billing 재조회(Mock에서는 다시 fetch)
// // // - licensed면 grace 갱신 → 즉시 정상 진입
// // class NeedsVerificationScreen extends ConsumerStatefulWidget {
// //   const NeedsVerificationScreen({super.key});
// //
// //   @override
// //   ConsumerState<NeedsVerificationScreen> createState() =>
// //       _NeedsVerificationScreenState();
// // }
// //
// // class _NeedsVerificationScreenState extends ConsumerState<NeedsVerificationScreen> {
// //   bool _checking = false;
// //   String? _error;
// //
// //   Future<void> _verifyAccess() async {
// //     setState(() {
// //       _checking = true;
// //       _error = null;
// //     });
// //
// //     try {
// //       // ✅ [변경] Verify Access 버튼은 "강제 갱신"으로 처리
// //       final gate = await LicensePolicy.forceRefreshFromMock();
// //
// //       // ✅ [추가] UI/게이트 상태도 최신화
// //       ref.invalidate(mockLicenseProvider);
// //       ref.invalidate(licenseGateProvider);
// //
// //       if (!mounted) return;
// //
// //       if (gate == LicenseGateState.ok) {
// //         // ✅ licensed(또는 grace 내 ok) → 정상 진입
// //         final hasPin = await ref.read(securityNotifierProvider.future);
// //
// //         if (!mounted) return;
// //
// //         Navigator.of(context).pushReplacement(
// //           MaterialPageRoute(
// //             builder: (_) => hasPin ? const PinScreen() : const SireApp(),
// //           ),
// //         );
// //         return;
// //       }
// //
// //       if (gate == LicenseGateState.unlicensed) {
// //         // ✅ 환불/미구매 확정이면 제한 화면으로 이동
// //         Navigator.of(context).pushReplacement(
// //           MaterialPageRoute(builder: (_) => const RestrictedScreen()),
// //         );
// //         return;
// //       }
// //
// //       // needsVerification 유지
// //       setState(() {
// //         _error =
// //         'Still unable to verify access.\nPlease check your internet connection and try again.';
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _error = e.toString();
// //       });
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _checking = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: Scaffold(
// //         body: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Text(
// //                   'Access verification required',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 const Text(
// //                   'We need to verify your access to continue.\n\n'
// //                       'Please connect to the internet and try again.',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     height: 1.4,
// //                   ),
// //                 ),
// //
// //                 if (_error != null) ...[
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     _error!,
// //                     textAlign: TextAlign.center,
// //                     style: const TextStyle(
// //                       fontSize: 13,
// //                       height: 1.4,
// //                     ),
// //                   ),
// //                 ],
// //
// //                 const SizedBox(height: 28),
// //
// //                 // ✅ [추가] Verify Access 버튼
// //                 ElevatedButton(
// //                   onPressed: _checking ? null : _verifyAccess,
// //                   child: _checking
// //                       ? const SizedBox(
// //                     width: 18,
// //                     height: 18,
// //                     child: CircularProgressIndicator(strokeWidth: 2),
// //                   )
// //                       : const Text('Verify Access'),
// //                 ),
// //
// //                 const SizedBox(height: 12),
// //
// //                 // ✅ [추가] Exit 버튼
// //                 TextButton(
// //                   onPressed: () {
// //                     SystemNavigator.pop(); // Android에서 앱 닫기
// //                   },
// //                   child: const Text('Exit'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
// //
// // import 'app.dart';
// // import 'core/database/app_database.dart';
// // import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// // import 'core/database/database_provider.dart';
// // import 'features/security/pin_screen.dart';
// // import 'features/security/security_provider.dart';
// //
// // // ✅ [추가] Play Integrity 호출 클라이언트
// // import 'core/platform/integrity_client.dart';
// //
// // // ✅ [정리] Integrity 정책은 core/platform/integrity_policy.dart
// // import 'core/platform/integrity_policy.dart';
// //
// // // ✅ [추가] 점진적 제한(유예/제한) 상태 저장용
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // // ❌ [정리] 유료앱(license) 기반 게이트는 인앱 결제 전환을 위해 제거합니다.
// // // import 'core/license/license_model.dart';
// // // import 'core/license/mock_license_service.dart';
// // // import 'core/license/license_policy.dart';
// //
// // import 'package:flutter/services.dart'; // ✅ SystemNavigator.pop() 사용
// //
// // // ✅ [정리] RestrictedScreen / NeedsVerificationScreen 분리
// // // - 인앱 전환 단계에서는 "유료앱 환불/권한 재확인" 흐름을 제거하므로 NeedsVerificationScreen은 사용하지 않습니다.
// // // - RestrictedScreen은 보안/정책(예: Integrity restricted) 화면으로 "유지"할 수 있으나, 현재는 CS 최소화를 위해 기본 차단은 비활성화합니다.
// // import 'restricted_screen.dart';
// // // import 'needs_verification_screen.dart';
// //
// // void main() async {
// //   // 📍 플러터 엔진과 위젯 바인딩 초기화
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
// //   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
// //   await initializeDateFormatting(null, null);
// //
// //   // 📍 데이터베이스 싱글톤 인스턴스 생성
// //   final database = AppDatabase();
// //
// //   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
// //   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
// //   await seedDatabase(database);
// //
// //   runApp(
// //     ProviderScope(
// //       overrides: [
// //         // 생성된 DB 인스턴스를 프로바이더에 주입
// //         databaseProvider.overrideWithValue(database),
// //       ],
// //       // 💡 보안 진입점(Gateway)을 통해 앱 시작
// //       child: const SecurityGateway(),
// //     ),
// //   );
// // }
// //
// // // ✅ [추가] Integrity 체크 결과를 담기 위한 간단 모델
// // class IntegrityCheckResult {
// //   final bool ok;
// //   final String? token; // 성공 시 토큰(서버 없으므로 판독은 못 하지만, “성공 여부” 신호로 사용)
// //   final String? errorMessage;
// //
// //   const IntegrityCheckResult({
// //     required this.ok,
// //     this.token,
// //     this.errorMessage,
// //   });
// // }
// //
// // // ✅ [정리] Integrity 체크 Provider (앱 시작 시 1회 호출)
// // // - 여기서 Integrity 결과만 가져옴(성공/실패)
// // // - 실제 차단/유예 판단은 아래 integrityGateProvider에서 수행
// // final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
// //   try {
// //     final res = await IntegrityClient.requestToken();
// //
// //     // ignore: avoid_print
// //     print('Integrity raw result = $res');
// //
// //     final ok = res['ok'] == true;
// //     if (ok) {
// //       final token = res['token'] as String?;
// //       // 토큰 문자열이 존재하면 Integrity 호출 성공으로 간주
// //       return IntegrityCheckResult(ok: true, token: token);
// //     } else {
// //       final msg = res['errorMessage']?.toString() ?? 'Integrity check failed';
// //       return IntegrityCheckResult(ok: false, errorMessage: msg);
// //     }
// //   } catch (e) {
// //     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
// //   }
// // });
// //
// // // ✅ [추가] 점진적 제한(유예/제한) 게이트 Provider
// // // - Integrity 성공/실패를 기반으로 "ok/grace/restricted" 상태를 계산
// // // - SharedPreferences로 누적 상태를 저장하여, 오프라인 등에서 CS 폭탄을 줄임
// // final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
// //   final check = await ref.watch(integrityCheckProvider.future);
// //   return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// // });
// //
// // // ❌ [정리] (유료앱 테스트용) Mock License 기반 게이트는 인앱 결제 전환을 위해 제거합니다.
// // // final mockLicenseProvider = FutureProvider<LicenseStatus>((ref) async {
// // //   final svc = MockLicenseService();
// // //   return svc.fetch();
// // // });
// // //
// // // final licenseGateProvider = FutureProvider<LicenseGateState>((ref) async {
// // //   final license = await ref.watch(mockLicenseProvider.future);
// // //   return LicensePolicy.evaluate(license: license);
// // // });
// //
// // // 📍 보안 진입점 관리용 위젯
// // // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// // class SecurityGateway extends ConsumerWidget {
// //   const SecurityGateway({super.key});
// //
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     // ✅ [추가] Integrity 체크를 먼저 수행 (점진적 제한 게이트)
// //     final gateAsync = ref.watch(integrityGateProvider);
// //
// //     // ✅ [정리] 인앱 전환 단계에서는 유료앱(license) 기반 분기를 제거합니다.
// //     // - 기존: mockLicenseProvider / licenseGateProvider 로딩까지 기다림
// //     // - 변경: Integrity + PIN만으로 게이트를 구성
// //
// //     // ✅ [추가] 로딩이면 스플래시
// //     if (gateAsync.isLoading) {
// //       return const MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// //       );
// //     }
// //
// //     return gateAsync.when(
// //       loading: () => const MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         home: Scaffold(body: Center(child: CircularProgressIndicator())),
// //       ),
// //       error: (err, __) {
// //         // Integrity 체크 자체에서 예외가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
// //         // 우선은 앱 진입 허용(나중에 정책/유예로 강화)
// //         return const SireApp();
// //       },
// //       data: (gateState) {
// //         // ✅ 제한 상태면 Continue 없이 잠금(또는 제한) 화면으로 이동
// //         // - 현재는 "CS 최소화"를 위해 기본 차단을 비활성화합니다.
// //         // - 추후 인앱 결제 도입 이후에도, Integrity restricted는 "보안 정책"으로만 사용하세요(구매/환불 판별용 아님).
// //         if (gateState == IntegrityGateState.restricted) {
// //           //return const RestrictedScreen();
// //         }
// //
// //         // 📍 사용자의 PIN 설정 여부 비동기 확인
// //         final securityAsync = ref.watch(securityNotifierProvider);
// //
// //         return securityAsync.when(
// //           loading: () => const MaterialApp(
// //             debugShowCheckedModeBanner: false,
// //             home: Scaffold(body: Center(child: CircularProgressIndicator())),
// //           ),
// //           // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
// //           error: (_, __) => const SireApp(),
// //           data: (hasPin) {
// //             // ✅ [변경] gateState가 grace여도 즉시 차단하지 않고 정상 진입 허용
// //             // - 필요하다면 grace 상태에서만 배너/토스트/안내 화면을 띄울 수 있음
// //             // - 현재는 "CS 최소화"를 위해 그냥 진입하도록 둠
// //
// //             if (hasPin) {
// //               // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
// //               // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
// //               return const MaterialApp(
// //                 debugShowCheckedModeBanner: false,
// //                 home: PinScreen(),
// //               );
// //             } else {
// //               // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
// //               // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
// //               return const SireApp();
// //             }
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// //
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
//
// import 'app.dart';
// import 'core/database/app_database.dart';
// import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// import 'core/database/database_provider.dart';
// import 'features/security/pin_screen.dart';
// import 'features/security/security_provider.dart';
//
// // ✅ [추가] Play Integrity 호출 클라이언트
// import 'core/platform/integrity_client.dart';
//
// // ✅ [정리] Integrity 정책은 core/platform/integrity_policy.dart
// import 'core/platform/integrity_policy.dart';
//
// // ✅ [추가] 점진적 제한(유예/제한) 상태 저장용
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ❌ [정리] 유료앱(license) 기반 게이트는 인앱 결제 전환을 위해 제거합니다.
// // import 'core/license/license_model.dart';
// // import 'core/license/mock_license_service.dart';
// // import 'core/license/license_policy.dart';
//
// import 'package:flutter/services.dart'; // ✅ SystemNavigator.pop() 사용
//
// // ✅ [정리] RestrictedScreen / NeedsVerificationScreen 분리
// // - 인앱 전환 단계에서는 "유료앱 환불/권한 재확인" 흐름을 제거하므로 NeedsVerificationScreen은 사용하지 않습니다.
// // - RestrictedScreen은 보안/정책(예: Integrity restricted) 화면으로 "유지"할 수 있으나, 현재는 CS 최소화를 위해 기본 차단은 비활성화합니다.
// import 'restricted_screen.dart';
// // import 'needs_verification_screen.dart';
//
// // ✅ [추가] IAP 구매 상태 Provider (앱 시작 시점 소유 검증을 확실히 트리거하기 위해)
// import 'core/purchase/state/purchase_provider.dart';
//
// void main() async {
//   // 📍 플러터 엔진과 위젯 바인딩 초기화
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
//   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
//   await initializeDateFormatting(null, null);
//
//   // 📍 데이터베이스 싱글톤 인스턴스 생성
//   final database = AppDatabase();
//
//   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
//   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
//   await seedDatabase(database);
//
//   runApp(
//     ProviderScope(
//       overrides: [
//         // 생성된 DB 인스턴스를 프로바이더에 주입
//         databaseProvider.overrideWithValue(database),
//       ],
//       // 💡 보안 진입점(Gateway)을 통해 앱 시작
//       child: const SecurityGateway(),
//     ),
//   );
// }
//
// // ✅ [추가] Integrity 체크 결과를 담기 위한 간단 모델
// class IntegrityCheckResult {
//   final bool ok;
//   final String? token; // 성공 시 토큰(서버 없으므로 판독은 못 하지만, “성공 여부” 신호로 사용)
//   final String? errorMessage;
//
//   const IntegrityCheckResult({
//     required this.ok,
//     this.token,
//     this.errorMessage,
//   });
// }
//
// // ✅ [정리] Integrity 체크 Provider (앱 시작 시 1회 호출)
// // - 여기서 Integrity 결과만 가져옴(성공/실패)
// // - 실제 차단/유예 판단은 아래 integrityGateProvider에서 수행
// final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
//   try {
//     final res = await IntegrityClient.requestToken();
//
//     // ignore: avoid_print
//     print('Integrity raw result = $res');
//
//     final ok = res['ok'] == true;
//     if (ok) {
//       final token = res['token'] as String?;
//       // 토큰 문자열이 존재하면 Integrity 호출 성공으로 간주
//       return IntegrityCheckResult(ok: true, token: token);
//     } else {
//       final msg = res['errorMessage']?.toString() ?? 'Integrity check failed';
//       return IntegrityCheckResult(ok: false, errorMessage: msg);
//     }
//   } catch (e) {
//     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
//   }
// });
//
// // ✅ [추가] 점진적 제한(유예/제한) 게이트 Provider
// // - Integrity 성공/실패를 기반으로 "ok/grace/restricted" 상태를 계산
// // - SharedPreferences로 누적 상태를 저장하여, 오프라인 등에서 CS 폭탄을 줄임
// final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
//   final check = await ref.watch(integrityCheckProvider.future);
//   return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// });
//
// // ❌ [정리] (유료앱 테스트용) Mock License 기반 게이트는 인앱 결제 전환을 위해 제거합니다.
// // final mockLicenseProvider = FutureProvider<LicenseStatus>((ref) async {
// //   final svc = MockLicenseService();
// //   return svc.fetch();
// // });
// //
// // final licenseGateProvider = FutureProvider<LicenseGateState>((ref) async {
// //   final license = await ref.watch(mockLicenseProvider.future);
// //   return LicensePolicy.evaluate(license: license);
// // });
//
// // 📍 보안 진입점 관리용 위젯
// // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// class SecurityGateway extends ConsumerWidget {
//   const SecurityGateway({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // ✅ [추가] IAP 구매 컨트롤러를 "앱 시작 시점"에 생성/초기화시키기 위한 트리거
//     // - PurchaseController 내부에서:
//     //   1) SharedPreferences 기반 빠른 복원
//     //   2) 스토어 소유(owned) 재검증(환불/취소 반영) 을 수행합니다.
//     //
//     // ⚠️ 중요:
//     // - 이 줄이 없으면, 앱 흐름상 Settings에 들어가기 전까지 구매 provider가 생성되지 않아
//     //   "앱 시작 시점 소유 검증"이 늦게 실행될 수 있습니다.
//     ref.watch(purchaseControllerProvider);
//
//     // ✅ [추가] Integrity 체크를 먼저 수행 (점진적 제한 게이트)
//     final gateAsync = ref.watch(integrityGateProvider);
//
//     // ✅ [정리] 인앱 전환 단계에서는 유료앱(license) 기반 분기를 제거합니다.
//     // - 기존: mockLicenseProvider / licenseGateProvider 로딩까지 기다림
//     // - 변경: Integrity + PIN만으로 게이트를 구성
//
//     // ✅ [추가] 로딩이면 스플래시
//     if (gateAsync.isLoading) {
//       return const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(body: Center(child: CircularProgressIndicator())),
//       );
//     }
//
//     return gateAsync.when(
//       loading: () => const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(body: Center(child: CircularProgressIndicator())),
//       ),
//       error: (err, __) {
//         // Integrity 체크 자체에서 예외가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
//         // 우선은 앱 진입 허용(나중에 정책/유예로 강화)
//         return const SireApp();
//       },
//       data: (gateState) {
//         // ✅ 제한 상태면 Continue 없이 잠금(또는 제한) 화면으로 이동
//         // - 현재는 "CS 최소화"를 위해 기본 차단을 비활성화합니다.
//         // - 추후 인앱 결제 도입 이후에도, Integrity restricted는 "보안 정책"으로만 사용하세요(구매/환불 판별용 아님).
//         if (gateState == IntegrityGateState.restricted) {
//           //return const RestrictedScreen();
//         }
//
//         // 📍 사용자의 PIN 설정 여부 비동기 확인
//         final securityAsync = ref.watch(securityNotifierProvider);
//
//         return securityAsync.when(
//           loading: () => const MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(body: Center(child: CircularProgressIndicator())),
//           ),
//           // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
//           error: (_, __) => const SireApp(),
//           data: (hasPin) {
//             // ✅ [변경] gateState가 grace여도 즉시 차단하지 않고 정상 진입 허용
//             // - 필요하다면 grace 상태에서만 배너/토스트/안내 화면을 띄울 수 있음
//             // - 현재는 "CS 최소화"를 위해 그냥 진입하도록 둠
//
//             if (hasPin) {
//               // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
//               // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
//               return const MaterialApp(
//                 debugShowCheckedModeBanner: false,
//                 home: PinScreen(),
//               );
//             } else {
//               // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
//               // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
//               return const SireApp();
//             }
//           },
//         );
//       },
//     );
//   }
// }
//
//

//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
//
// import 'app.dart';
// import 'core/database/app_database.dart';
// import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
// import 'core/database/database_provider.dart';
// import 'features/security/pin_screen.dart';
// import 'features/security/security_provider.dart';
//
// // ✅ [추가] Play Integrity 호출 클라이언트
// import 'core/platform/integrity_client.dart';
//
// // ✅ [정리] Integrity 정책은 core/platform/integrity_policy.dart
// import 'core/platform/integrity_policy.dart';
//
// // ✅ [추가] 점진적 제한(유예/제한) 상태 저장용
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ❌ [정리] 유료앱(license) 기반 게이트는 인앱 결제 전환을 위해 제거합니다.
// // import 'core/license/license_model.dart';
// // import 'core/license/mock_license_service.dart';
// // import 'core/license/license_policy.dart';
//
// import 'package:flutter/services.dart'; // ✅ SystemNavigator.pop() 사용
//
// // ✅ [정리] RestrictedScreen / NeedsVerificationScreen 분리
// // - 인앱 전환 단계에서는 "유료앱 환불/권한 재확인" 흐름을 제거하므로 NeedsVerificationScreen은 사용하지 않습니다.
// // - RestrictedScreen은 보안/정책(예: Integrity restricted) 화면으로 "유지"할 수 있으나, 현재는 CS 최소화를 위해 기본 차단은 비활성화합니다.
// import 'restricted_screen.dart';
// // import 'needs_verification_screen.dart';
//
// // ✅ [추가] IAP 구매 상태 Provider (앱 시작 시점 소유 검증을 확실히 트리거하기 위해)
// import 'core/purchase/state/purchase_provider.dart';
//
// void main() async {
//   // 📍 플러터 엔진과 위젯 바인딩 초기화
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
//   // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
//   await initializeDateFormatting(null, null);
//
//   // 📍 데이터베이스 싱글톤 인스턴스 생성
//   final database = AppDatabase();
//
//   // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
//   // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
//   await seedDatabase(database);
//
//   runApp(
//     ProviderScope(
//       overrides: [
//         // 생성된 DB 인스턴스를 프로바이더에 주입
//         databaseProvider.overrideWithValue(database),
//       ],
//       // 💡 보안 진입점(Gateway)을 통해 앱 시작
//       child: const SecurityGateway(),
//     ),
//   );
// }
//
// // ✅ [추가] Integrity 체크 결과를 담기 위한 간단 모델
// class IntegrityCheckResult {
//   final bool ok;
//   final String? token; // 성공 시 토큰(서버 없으므로 판독은 못 하지만, “성공 여부” 신호로 사용)
//   final String? errorMessage;
//
//   const IntegrityCheckResult({
//     required this.ok,
//     this.token,
//     this.errorMessage,
//   });
// }
//
// // ✅ [정리] Integrity 체크 Provider (앱 시작 시 1회 호출)
// // - 여기서 Integrity 결과만 가져옴(성공/실패)
// // - 실제 차단/유예 판단은 아래 integrityGateProvider에서 수행
// final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
//   try {
//     final res = await IntegrityClient.requestToken();
//
//     // ignore: avoid_print
//     print('Integrity raw result = $res');
//
//     final ok = res['ok'] == true;
//     if (ok) {
//       final token = res['token'] as String?;
//       // 토큰 문자열이 존재하면 Integrity 호출 성공으로 간주
//       return IntegrityCheckResult(ok: true, token: token);
//     } else {
//       final msg = res['errorMessage']?.toString() ?? 'Integrity check failed';
//       return IntegrityCheckResult(ok: false, errorMessage: msg);
//     }
//   } catch (e) {
//     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
//   }
// });
//
// // ✅ [추가] 점진적 제한(유예/제한) 게이트 Provider
// // - Integrity 성공/실패를 기반으로 "ok/grace/restricted" 상태를 계산
// // - SharedPreferences로 누적 상태를 저장하여, 오프라인 등에서 CS 폭탄을 줄임
// final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
//   final check = await ref.watch(integrityCheckProvider.future);
//   return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// });
//
// // ❌ [정리] (유료앱 테스트용) Mock License 기반 게이트는 인앱 결제 전환을 위해 제거합니다.
// // final mockLicenseProvider = FutureProvider<LicenseStatus>((ref) async {
// //   final svc = MockLicenseService();
// //   return svc.fetch();
// // });
// //
// // final licenseGateProvider = FutureProvider<LicenseGateState>((ref) async {
// //   final license = await ref.watch(mockLicenseProvider.future);
// //   return LicensePolicy.evaluate(license: license);
// // });
//
// // 📍 보안 진입점 관리용 위젯
// // 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
// class SecurityGateway extends ConsumerWidget {
//   const SecurityGateway({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // ✅ [추가] IAP 구매 컨트롤러를 "앱 시작 시점"에 생성/초기화시키기 위한 트리거
//     // - PurchaseController 내부에서:
//     //   1) SharedPreferences 기반 빠른 복원
//     //   2) 스토어 소유(owned) 재검증(환불/취소 반영) 을 수행합니다.
//     //
//     // ⚠️ 중요:
//     // - 이 줄이 없으면, 앱 흐름상 Settings에 들어가기 전까지 구매 provider가 생성되지 않아
//     //   "앱 시작 시점 소유 검증"이 늦게 실행될 수 있습니다.
//     ref.watch(purchaseControllerProvider);
//
//     // ✅ [추가] Integrity 체크를 먼저 수행 (점진적 제한 게이트)
//     final gateAsync = ref.watch(integrityGateProvider);
//
//     // ✅ [정리] 인앱 전환 단계에서는 유료앱(license) 기반 분기를 제거합니다.
//     // - 기존: mockLicenseProvider / licenseGateProvider 로딩까지 기다림
//     // - 변경: Integrity + PIN만으로 게이트를 구성
//
//     // ✅ [추가] 로딩이면 스플래시
//     if (gateAsync.isLoading) {
//       return const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(body: Center(child: CircularProgressIndicator())),
//       );
//     }
//
//     return gateAsync.when(
//       loading: () => const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(body: Center(child: CircularProgressIndicator())),
//       ),
//       error: (err, __) {
//         // Integrity 체크 자체에서 예외가 나도, 서버 없는 구조에서는 바로 차단하면 CS 폭탄 가능
//         // 우선은 앱 진입 허용(나중에 정책/유예로 강화)
//         return const SireApp();
//       },
//       data: (gateState) {
//         // ✅ 제한 상태면 Continue 없이 잠금(또는 제한) 화면으로 이동
//         // - 현재는 "CS 최소화"를 위해 기본 차단을 비활성화합니다.
//         // - 추후 인앱 결제 도입 이후에도, Integrity restricted는 "보안 정책"으로만 사용하세요(구매/환불 판별용 아님).
//         if (gateState == IntegrityGateState.restricted) {
//           //return const RestrictedScreen();
//         }
//
//         // 📍 사용자의 PIN 설정 여부 비동기 확인
//         final securityAsync = ref.watch(securityNotifierProvider);
//
//         return securityAsync.when(
//           loading: () => const MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(body: Center(child: CircularProgressIndicator())),
//           ),
//           // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
//           error: (_, __) => const SireApp(),
//           data: (hasPin) {
//             // ✅ [변경] gateState가 grace여도 즉시 차단하지 않고 정상 진입 허용
//             // - 필요하다면 grace 상태에서만 배너/토스트/안내 화면을 띄울 수 있음
//             // - 현재는 "CS 최소화"를 위해 그냥 진입하도록 둠
//
//             if (hasPin) {
//               // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
//               // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
//               return const MaterialApp(
//                 debugShowCheckedModeBanner: false,
//                 home: PinScreen(),
//               );
//             } else {
//               // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
//               // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
//               return const SireApp();
//             }
//           },
//         );
//       },
//     );
//   }
// }
//

//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'app.dart';
// import 'core/database/app_database.dart';
// import 'core/database/data_seeder.dart';
// import 'core/database/database_provider.dart';
// import 'features/security/pin_screen.dart';
// import 'features/security/security_provider.dart';
// import 'core/platform/integrity_client.dart';
// import 'core/platform/integrity_policy.dart';
// import 'core/purchase/state/purchase_provider.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeDateFormatting(null, null);
//   final database = AppDatabase();
//   await seedDatabase(database);
//
//   runApp(
//     ProviderScope(
//       overrides: [databaseProvider.overrideWithValue(database)],
//       child: const SecurityGateway(),
//     ),
//   );
// }
//
// class IntegrityCheckResult {
//   final bool ok;
//   final String? errorMessage;
//   const IntegrityCheckResult({required this.ok, this.errorMessage});
// }
//
// final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
//   try {
//     final res = await IntegrityClient.requestToken();
//     return IntegrityCheckResult(ok: res['ok'] == true, errorMessage: res['errorMessage']?.toString());
//   } catch (e) {
//     return IntegrityCheckResult(ok: false, errorMessage: e.toString());
//   }
// });
//
// final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
//   final check = await ref.watch(integrityCheckProvider.future);
//   return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
// });
//
// class SecurityGateway extends ConsumerStatefulWidget {
//   const SecurityGateway({super.key});
//   @override
//   ConsumerState<SecurityGateway> createState() => _SecurityGatewayState();
// }
//
// class _SecurityGatewayState extends ConsumerState<SecurityGateway> {
//   bool _isUnlocked = false; // 📍 잠금 해제 상태 관리
//
//   @override
//   Widget build(BuildContext context) {
//     ref.watch(purchaseControllerProvider);
//     final gateAsync = ref.watch(integrityGateProvider);
//
//     if (gateAsync.isLoading) {
//       return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
//     }
//
//     final securityAsync = ref.watch(securityNotifierProvider);
//     return securityAsync.when(
//       loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
//       error: (_, __) => const SireApp(),
//       data: (hasPin) {
//         // 📍 PIN이 없거나 이미 풀었다면 메인 앱 실행
//         if (!hasPin || _isUnlocked) {
//           return const SireApp();
//         }
//
//         // 📍 PIN이 있으면 PIN 화면을 독립적으로 먼저 띄움
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           home: PinScreen(
//             onSuccess: () {
//               setState(() => _isUnlocked = true); // 성공 시 상태 변경 -> SireApp으로 교체됨
//             },
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/data_seeder.dart';
import 'core/database/database_provider.dart';
import 'features/security/pin_screen.dart';
import 'features/security/security_provider.dart';
import 'core/platform/integrity_client.dart';
import 'core/platform/integrity_policy.dart';
import 'core/purchase/state/purchase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(null, null);
  final database = AppDatabase();
  await seedDatabase(database);

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const SecurityGateway(),
    ),
  );
}

class IntegrityCheckResult {
  final bool ok;
  final String? errorMessage;
  const IntegrityCheckResult({required this.ok, this.errorMessage});
}

final integrityCheckProvider = FutureProvider<IntegrityCheckResult>((ref) async {
  try {
    final res = await IntegrityClient.requestToken();
    return IntegrityCheckResult(ok: res['ok'] == true, errorMessage: res['errorMessage']?.toString());
  } catch (e) {
    return IntegrityCheckResult(ok: false, errorMessage: e.toString());
  }
});

final integrityGateProvider = FutureProvider<IntegrityGateState>((ref) async {
  final check = await ref.watch(integrityCheckProvider.future);
  return IntegrityPolicy.evaluate(integrityOkNow: check.ok);
});

class SecurityGateway extends ConsumerStatefulWidget {
  const SecurityGateway({super.key});
  @override
  ConsumerState<SecurityGateway> createState() => _SecurityGatewayState();
}

class _SecurityGatewayState extends ConsumerState<SecurityGateway> {
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(purchaseControllerProvider);
    final gateAsync = ref.watch(integrityGateProvider);

    // 📍 로딩 화면에서 디버그 띠 제거
    if (gateAsync.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final securityAsync = ref.watch(securityNotifierProvider);
    return securityAsync.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const SireApp(),
      data: (hasPin) {
        if (!hasPin || _isUnlocked) {
          return const SireApp();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false, // 📍 PIN 화면에서 디버그 띠 제거
          home: PinScreen(
            onSuccess: () {
              setState(() => _isUnlocked = true);
            },
          ),
        );
      },
    );
  }
}