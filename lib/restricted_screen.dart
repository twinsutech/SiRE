import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator.pop()

// ✅ [추가] 제한(Restricted) 화면
// - Continue 버튼 없이 “실행 환경 확인 불가 / 보안 정책 위반 가능” 상태를 명확히 전달
// - 인앱 결제 전환 이후에는 "구매/환불" 제한 화면으로 사용하지 않습니다.
//   (결제 필요 화면은 별도의 Paywall/Unlock 화면으로 분리 권장)
// - 서버 없는 구조에서 네트워크/일시 오류로 잠금이 되는 CS를 줄이기 위해
//   restricted 조건은 "연속 실패 누적"처럼 충분히 보수적으로 운용하는 것을 권장합니다.
class RestrictedScreen extends StatelessWidget {
  const RestrictedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Title (조금 더 크게, 상태 메시지 느낌)
                const Text(
                  'App access is temporarily restricted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Body
                const Text(
                  'We were unable to confirm a secure app environment.\n\n'
                      'Please make sure:\n'
                      '- Google Play services are up to date\n'
                      '- Your internet connection is stable\n'
                      '- Your device is not in a modified environment\n\n'
                      'If the issue continues, please contact support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // ✅ Exit 버튼
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop(); // Android에서 앱 종료
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
