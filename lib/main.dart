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