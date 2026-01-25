import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // 📍 날짜 및 숫자 포맷 초기화를 위해 필수
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/data_seeder.dart'; // 📍 기본 카테고리 데이터 생성
import 'core/database/database_provider.dart';
import 'features/security/pin_screen.dart';
import 'features/security/security_provider.dart';

void main() async {
  // 📍 플러터 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 📍 [다국어 핵심] 전 세계 모든 로케일의 날짜/통화 포맷 데이터를 메모리에 로드합니다.
  // 이 과정이 없으면 Ledger나 Stats 화면에서 특정 국가 로케일 사용 시 에러가 발생할 수 있습니다.
  await initializeDateFormatting(null, null);

  // 📍 데이터베이스 싱글톤 인스턴스 생성
  final database = AppDatabase();

  // 📍 [데이터 무결성] 앱 최초 실행 시 '월세(CAT_RENT)'와 같은 필수 다국어 키 카테고리를 생성합니다.
  // 실제 금액 데이터와 상관없는 '구조적 키'를 생성하므로 화폐 다국어 처리에 안전합니다.
  await seedDatabase(database);

  runApp(
    ProviderScope(
      overrides: [
        // 생성된 DB 인스턴스를 프로바이더에 주입
        databaseProvider.overrideWithValue(database),
      ],
      // 💡 보안 진입점(Gateway)을 통해 앱 시작
      child: const SecurityGateway(),
    ),
  );
}

// 📍 보안 진입점 관리용 위젯
// 다국어 초기화가 이루어지는 SireApp 진입 전, 보안 상태에 따라 화면을 분기합니다.
class SecurityGateway extends ConsumerWidget {
  const SecurityGateway({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📍 사용자의 PIN 설정 여부 비동기 확인
    final securityAsync = ref.watch(securityNotifierProvider);

    return securityAsync.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      // 에러 발생 시 시스템 보호를 위해 메인 앱으로 안전하게 우회 진입
      error: (_, __) => const SireApp(),
      data: (hasPin) {
        if (hasPin) {
          // 🔒 보안 잠금이 활성화된 경우: PIN 입력 화면으로 이동
          // 📍 PinScreen 내에서 사용자의 현재 로케일에 맞는 다국어 제목이 표시됩니다.
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: PinScreen(),
          );
        } else {
          // ✅ 보안 잠금이 없는 경우: 즉시 메인 앱(SireApp) 실행
          // 📍 SireApp 내부에서 MaterialApp 로케일 설정이 최종 적용됩니다.
          return const SireApp();
        }
      },
    );
  }
}