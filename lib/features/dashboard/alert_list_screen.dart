import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// 📍 전화 및 문자 기능을 위한 임포트
import 'package:url_launcher/url_launcher.dart';
import 'alert_provider.dart';

class AlertListScreen extends ConsumerWidget {
  const AlertListScreen({super.key});

  // 📍 전화 걸기 실행 함수
  Future<void> _makeCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("등록된 세입자 연락처가 없습니다.")),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // 📍 문자 보내기 실행 함수
  Future<void> _sendSms(BuildContext context, String? room, String? phone, String message) async {
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$room호의 저장된 전화번호가 비어있습니다.")),
      );
      return;
    }

    // 하이픈 제거
    final String cleanPhone = phone.replaceAll('-', '');

    // 📍 queryParameters 대신 직접 경로(path)에 인코딩된 문자열을 합쳐서 생성합니다.
    // Uri.encodeFull을 사용하면 공백이 '+' 대신 '%20'으로 변환되어 문자 앱에서 정상적으로 보입니다.
    final Uri launchUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("문자 앱을 실행할 수 없습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(appAlertProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("알림 센터", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: alerts.isEmpty
          ? const Center(child: Text("표시할 알림이 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final isOverdue = alert.type == AlertType.overdue;

          // 📍 디버깅용: 터미널에 현재 불러온 번호 출력 (에러 확인용)
          debugPrint("Room: ${alert.roomNumber}, Phone: ${alert.phoneNumber}");

          return Card(
            elevation: 0.5,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // 📍 ListTile을 ExpansionTile로 변경하여 클릭 시 액션 버튼이 나오도록 구성
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                // 📍 [수정] 펼쳐졌을 때 배경색을 살짝 주어 클릭됨을 인지시킴
                backgroundColor: const Color(0xFF1A237E).withOpacity(0.03),
                leading: CircleAvatar(
                  backgroundColor: isOverdue
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    isOverdue ? Icons.priority_high : Icons.event_note,
                    color: isOverdue ? Colors.orange : Colors.blue,
                  ),
                ),
                title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(alert.body),
                // 📍 [수정] 우측 영역에 날짜와 함께 '연락 아이콘'을 추가하여 클릭 유도
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MM.dd').format(alert.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, size: 16, color: Color(0xFF1A237E)),
                        Icon(Icons.expand_more, size: 14, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
                // 📍 클릭 시 펼쳐지는 영역 (연락하기 버튼)
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 📍 [수정] 문자 보내기 버튼 (에러 해결 지점)
                        TextButton.icon(
                          onPressed: () {
                            _sendSms(
                                context,
                                alert.roomNumber,
                                alert.phoneNumber,
                                "[관리인] ${alert.roomNumber ?? ''}호 관련 연락드립니다."
                            );
                          },
                          icon: const Icon(Icons.sms, size: 18),
                          label: const Text("문자 보내기"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          // 📍 버튼을 항상 활성화하고 클릭 시 체크하도록 변경
                          onPressed: () => _makeCall(context, alert.phoneNumber),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text("전화 걸기"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}