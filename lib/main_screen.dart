// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'core/localization/localization_provider.dart'; // 📍 다국어 임포트 추가
// import 'features/dashboard/dashboard_screen.dart';
// import 'features/property/property_screen.dart';
// import 'features/ledger/ledger_screen.dart';
// import 'features/reports/reports_screen.dart';
// import 'features/settings/settings_screen.dart';
// import 'features/security/pin_screen.dart'; // 📍 추가
// import 'features/security/security_provider.dart'; // 📍 추가
//
// class MainScreen extends ConsumerStatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   ConsumerState<MainScreen> createState() => _MainScreenState();
// }
//
// // WidgetsBindingObserver를 믹스인하여 앱의 라이프사이클(백그라운드 진입/복귀)을 감시합니다.
// class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
//   int _selectedIndex = 0;
//
//   // 탭별 화면 리스트
//   final List<Widget> _screens = [
//     const DashboardScreen(),
//     const PropertyScreen(),
//     const LedgerScreen(),
//     const ReportsScreen(),
//     const SettingsScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // 📍 라이프사이클 관찰자 등록
//     WidgetsBinding.instance.addObserver(this);
//   }
//
//   @override
//   void dispose() {
//     // 📍 관찰자 해제
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // 📍 앱이 백그라운드에서 다시 돌아올 때 (Resumed) 실행
//     if (state == AppLifecycleState.resumed) {
//       _checkSecurity();
//     }
//   }
//
//   void _checkSecurity() {
//     // PIN 설정 여부를 확인합니다.
//     final hasPin = ref.read(securityNotifierProvider).value ?? false;
//
//     if (hasPin) {
//       // 🔒 앱이 활성화될 때 PIN 입력 화면을 최상단에 띄웁니다.
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => const PinScreen(),
//           fullscreenDialog: true, // 모달 형태로 띄워 가독성 높임
//         ),
//       );
//     }
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: const Color(0xFF1A237E),
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         items: [
//           // 📍 하단 탭 메뉴 다국어 적용
//           BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'NAV_HOME'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.apartment), label: 'NAV_BUILDINGS'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: 'NAV_LEDGER'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: 'NAV_REPORTS'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'NAV_SETTINGS'.tr(ref)),
//         ],
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'core/localization/localization_provider.dart'; // 📍 다국어 임포트 추가
// import 'features/dashboard/dashboard_screen.dart';
// import 'features/property/property_screen.dart';
// import 'features/ledger/ledger_screen.dart';
// import 'features/reports/reports_screen.dart';
// import 'features/settings/settings_screen.dart';
// import 'features/security/pin_screen.dart'; // 📍 추가
// import 'features/security/security_provider.dart'; // 📍 추가
//
// class MainScreen extends ConsumerStatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   ConsumerState<MainScreen> createState() => _MainScreenState();
// }
//
// // WidgetsBindingObserver를 믹스인하여 앱의 라이프사이클을 감시합니다.
// class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
//   int _selectedIndex = 0;
//
//   // 📍 [물리적 차단 핵심] static 변수는 위젯이 리빌드되어도 상태가 유지됩니다.
//   static bool _isProcessingSecurity = false; // 중복 진입 방지 락
//   static DateTime? _lastPinSuccessTime;      // 마지막 보안 해제 시간
//
//   // 탭별 화면 리스트
//   final List<Widget> _screens = [
//     const DashboardScreen(),
//     const PropertyScreen(),
//     const LedgerScreen(),
//     const ReportsScreen(),
//     const SettingsScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // 📍 앱이 복귀(Resumed)할 때만 실행
//     if (state == AppLifecycleState.resumed) {
//       _checkSecurity();
//     }
//   }
//
//   // 📍 [핵심 수정] 갤러리 복귀 시 무한 루프를 원천 차단하는 로직
//   Future<void> _checkSecurity() async {
//     final hasPin = ref.read(securityNotifierProvider).value ?? false;
//
//     // 1. PIN 미설정 시 즉시 종료
//     if (!hasPin) return;
//
//     // 2. [물리적 락] 이미 보안 로직이 작동 중이면 어떤 이벤트도 무시
//     if (_isProcessingSecurity) return;
//
//     // 3. [시간 쿨다운] 보안 해제 후 5초 이내에는 다시 묻지 않음 (갤러리 중복 복귀 대응)
//     if (_lastPinSuccessTime != null) {
//       final diff = DateTime.now().difference(_lastPinSuccessTime!);
//       if (diff.inSeconds < 5) return;
//     }
//
//     // 4. [내비게이션 스택 검사] 현재 화면 위에 이미 PIN 창이 있는지 이름으로 확인
//     bool alreadyShowing = false;
//     if (mounted) {
//       Navigator.popUntil(context, (route) {
//         if (route.settings.name == '/pin_lock_screen') {
//           alreadyShowing = true;
//         }
//         return true; // 스택을 제거하지 않고 검사만 수행
//       });
//     }
//
//     if (alreadyShowing) return;
//
//     // --- 보안 검문소 통과, 잠금 시작 ---
//     _isProcessingSecurity = true;
//
//     if (!mounted) return;
//
//     try {
//       // 🔒 PIN 화면을 fullscreenDialog로 띄움
//       await Navigator.of(context).push(
//         MaterialPageRoute(
//           settings: const RouteSettings(name: '/pin_lock_screen'),
//           builder: (context) => const PinScreen(),
//           fullscreenDialog: true,
//         ),
//       );
//
//       // 🔓 보안 해제 성공 시점 기록
//       _lastPinSuccessTime = DateTime.now();
//     } finally {
//       // 어떤 상황에서도 락은 마지막에 해제
//       _isProcessingSecurity = false;
//     }
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: const Color(0xFF1A237E),
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         items: [
//           BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'NAV_HOME'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.apartment), label: 'NAV_BUILDINGS'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: 'NAV_LEDGER'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: 'NAV_REPORTS'.tr(ref)),
//           BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'NAV_SETTINGS'.tr(ref)),
//         ],
//       ),
//     );
//   }
// }

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
