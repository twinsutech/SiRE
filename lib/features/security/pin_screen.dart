import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import 'security_provider.dart';
import '../../main_screen.dart';

class PinScreen extends ConsumerStatefulWidget {
  final bool isSetting; // PIN 설정 모드 여부
  final VoidCallback? onSuccess; // 📍 [추가] main.dart의 Gateway에서 전달받을 성공 콜백

  const PinScreen({
    super.key,
    this.isSetting = false,
    this.onSuccess, // 📍 [추가] 파라미터 등록
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _input = "";

  // 📍 숫자 입력 처리 로직
  void _onKeyPress(String value) async {
    if (value == "⌫") {
      if (_input.isNotEmpty) {
        setState(() => _input = _input.substring(0, _input.length - 1));
      }
      return;
    }

    if (_input.length < 4) {
      setState(() => _input += value);

      if (_input.length == 4) {
        final notifier = ref.read(securityNotifierProvider.notifier);

        if (widget.isSetting) {
          // 1. PIN 신규 설정/변경 모드 (설정창에서 들어온 경우)
          await notifier.setPin(_input);
          if (mounted) Navigator.pop(context);
        } else {
          // 2. PIN 확인(로그인) 모드
          final isValid = await notifier.verifyPin(_input);
          if (isValid) {
            if (mounted) {
              // 📍 [핵심 수정] Gateway(main.dart)에서 onSuccess를 보냈다면 실행
              if (widget.onSuccess != null) {
                widget.onSuccess!(); // Gateway의 _isUnlocked를 true로 변경함
              } else {
                // 일반적인 경우(사용 중 다시 잠겼을 때 등) 메인으로 이동
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              }
            }
          } else {
            // 비밀번호 틀림
            setState(() => _input = "");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("SEC_PIN_INVALID".tr(ref)),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📍 뒤로가기 제어
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A237E),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isSetting ? "SEC_PIN_SET_TITLE".tr(ref) : "SEC_PIN_ENTER_TITLE".tr(ref),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 40),
              // PIN 입력 표시 (점)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _input.length ? Colors.amber : Colors.white24,
                  ),
                )),
              ),
              const SizedBox(height: 60),
              // 숫자 키패드
              _buildKeyboard(),
            ],
          ),
        ),
      ),
    );
  }

  // 📍 키패드 레이아웃 빌더
  Widget _buildKeyboard() {
    final keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["", "0", "⌫"]
    ];

    return Column(
      children: keys.map((row) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) => _buildKey(key)).toList(),
        ),
      )).toList(),
    );
  }

  // 📍 개별 숫자 버튼 빌더
  Widget _buildKey(String label) {
    return SizedBox(
      width: 80,
      height: 50,
      child: TextButton(
        onPressed: label.isEmpty ? null : () => _onKeyPress(label),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          foregroundColor: Colors.white10,
        ),
        child: label == "⌫"
            ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 28)
            : Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 28)
        ),
      ),
    );
  }
}