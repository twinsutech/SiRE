import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/localization_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/property/property_screen.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/security/pin_screen.dart';
import 'features/security/security_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  static bool isExternalActionInProgress = false; // 📍 갤러리 작업 플래그
  static bool isPinShowing = false;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PropertyScreen(),
    const LedgerScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 📍 초기 보안 체크(addPostFrameCallback)를 삭제했습니다.
    // main.dart에서 이미 검증했기 때문입니다.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 📍 사용 중 백그라운드 갔다가 돌아올 때만 체크
    if (state == AppLifecycleState.resumed) {
      if (!MainScreen.isExternalActionInProgress) {
        _checkSecurity();
      }
    }
  }

  Future<void> _checkSecurity() async {
    final hasPin = ref.read(securityNotifierProvider).value ?? false;
    if (!hasPin || MainScreen.isPinShowing) return;

    MainScreen.isPinShowing = true;
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/pin_lock_screen'),
        builder: (context) => const PinScreen(),
        fullscreenDialog: true,
      ),
    );
    MainScreen.isPinShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1A237E),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'NAV_HOME'.tr(ref)),
          BottomNavigationBarItem(icon: const Icon(Icons.apartment), label: 'NAV_BUILDINGS'.tr(ref)),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: 'NAV_LEDGER'.tr(ref)),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: 'NAV_REPORTS'.tr(ref)),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'NAV_SETTINGS'.tr(ref)),
        ],
      ),
    );
  }
}
