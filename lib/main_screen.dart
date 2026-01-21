import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/property/property_screen.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/security/pin_screen.dart'; // 📍 추가
import 'features/security/security_provider.dart'; // 📍 추가

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

// WidgetsBindingObserver를 믹스인하여 앱의 라이프사이클(백그라운드 진입/복귀)을 감시합니다.
class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  // 탭별 화면 리스트
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
    // 📍 라이프사이클 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 📍 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 📍 앱이 백그라운드에서 다시 돌아올 때 (Resumed) 실행
    if (state == AppLifecycleState.resumed) {
      _checkSecurity();
    }
  }

  void _checkSecurity() {
    // PIN 설정 여부를 확인합니다.
    final hasPin = ref.read(securityNotifierProvider).value ?? false;

    if (hasPin) {
      // 🔒 앱이 활성화될 때 PIN 입력 화면을 최상단에 띄웁니다.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PinScreen(),
          fullscreenDialog: true, // 모달 형태로 띄워 가독성 높임
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Buildings'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ledger'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}