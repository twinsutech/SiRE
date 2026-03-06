
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import 'alert_provider.dart';

class AlertListScreen extends ConsumerWidget {
  const AlertListScreen({super.key});

  // 📍 전화 걸기 실행 함수
  Future<void> _makeCall(BuildContext context, WidgetRef ref, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ALERT_NO_PHONE_ERROR".tr(ref))),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // 📍 문자 보내기 실행 함수
  Future<void> _sendSms(BuildContext context, WidgetRef ref, String? room, String? phone, String message) async {
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${room ?? ''}${"ALERT_EMPTY_PHONE_MSG".tr(ref)}")),
      );
      return;
    }

    final String cleanPhone = phone.replaceAll('-', '');
    final Uri launchUri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ALERT_SMS_APP_ERROR".tr(ref))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(appAlertProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("NAV_ALERTS".tr(ref), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: alerts.isEmpty
          ? Center(child: Text("ALERT_EMPTY_LIST".tr(ref)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final isOverdue = alert.type == AlertType.overdue;

          // 📍 [핵심 수정] 실시간 다국어 변수 치환 로직
          // 알림 센터 리스트에서 키값을 실제 문장으로 변환합니다.
          String displayBody = "";
          if (alert.type == AlertType.overdue) {
            // 미납 알림: "{room}호 임대료가 아직 미납입니다."
            displayBody = alert.body.tr(ref).replaceAll("{room}", alert.roomNumber ?? "");
          } else {
            // 만료 알림: "{room}호 계약 만료가 {days}일 남았습니다."
            displayBody = alert.body.tr(ref)
                .replaceAll("{room}", alert.roomNumber ?? "")
                .replaceAll("{days}", alert.daysLeft?.toString() ?? "0");
          }

          return Card(
            elevation: 0.5,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                // 📍 클릭 피드백 강화를 위해 배경색 지정
                backgroundColor: const Color(0xFF1A237E).withOpacity(0.03),
                onExpansionChanged: (value) {
                  if (value) HapticFeedback.lightImpact(); // 펼칠 때 진동
                },
                leading: CircleAvatar(
                  backgroundColor: isOverdue
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    isOverdue ? Icons.priority_high : Icons.event_note,
                    color: isOverdue ? Colors.orange : Colors.blue,
                  ),
                ),
                // 📍 타이틀 키를 실시간 번역하여 표시
                title: Text(alert.title.tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
                // 📍 치환된 문장을 서브타이틀로 표시
                subtitle: Text(displayBody),
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
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 📍 문자 보내기 버튼
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _sendSms(
                                context,
                                ref,
                                alert.roomNumber,
                                alert.phoneNumber,
                                // 📍 문자 템플릿도 실시간 번역 적용
                                "${"ALERT_SMS_TEMPLATE_HEAD".tr(ref)} ${alert.roomNumber ?? ''}${"ALERT_SMS_TEMPLATE_TAIL".tr(ref)}"
                            );
                          },
                          icon: const Icon(Icons.sms, size: 18),
                          label: Text("ALERT_ACTION_SMS".tr(ref)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _makeCall(context, ref, alert.phoneNumber);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.phone, size: 18),
                          label: Text("ALERT_ACTION_CALL".tr(ref)),
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

