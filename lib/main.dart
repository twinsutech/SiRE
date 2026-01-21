import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/data_seeder.dart'; // 📍 여기서 카테고리 시딩이 일어납니다.
import 'core/database/database_provider.dart';
import 'features/security/pin_screen.dart';
import 'features/security/security_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  // 📍 앱 시작 시 건물, 유닛, 그리고 "카테고리" 초기 데이터를 생성합니다.
  await seedDatabase(database);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      // 💡 보안 로직을 위해 SecurityGateway를 첫 시작점으로 설정할 수 있습니다.
      // 만약 SireApp 내부에서 자체적으로 분기한다면 SireApp()을 사용하세요.
      child: const SecurityGateway(),
    ),
  );
}

// 📍 보안 진입점 관리용 위젯
class SecurityGateway extends ConsumerWidget {
  const SecurityGateway({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityAsync = ref.watch(securityNotifierProvider);

    return securityAsync.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const SireApp(),
      data: (hasPin) {
        if (hasPin) {
          // 🔒 PIN이 설정되어 있다면 보안 입력 화면 표시
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: PinScreen(),
          );
        } else {
          // ✅ PIN이 없다면 바로 메인 앱 실행
          return const SireApp();
        }
      },
    );
  }
}