// lib/core/purchase/ui/refund_policy_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization_provider.dart';
import '../../../features/settings/support_service.dart'; // 📍 [추가] SupportService 연결

/// ✅ [신규] 공통 결제 및 환불 정책 바텀시트
/// - 구매 화면(Paywall)과 설정 화면에서 공통으로 재사용합니다.
class RefundPolicySheet extends ConsumerWidget {
  const RefundPolicySheet({super.key});

  /// 바텀시트를 띄우는 헬퍼 메서드
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RefundPolicySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      // 하단 노치/홈 인디케이터 영역만큼 패딩 추가
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "REFUND_POLICY_TITLE".tr(ref), // 예: 결제 및 환불 정책
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "REFUND_POLICY_DESC".tr(ref), // 예: SiRE Pro는 결제 후 7일 이내 전액 환불이 가능합니다...
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildPolicyItem(
            ref,
            title: "REFUND_POLICY_STEP1_TITLE".tr(ref), // 예: 1. 48시간 이내 (구글 자동 환불)
            content: "REFUND_POLICY_STEP1_DESC".tr(ref), // 예: 구글 플레이 앱 > 결제 및 구독...
          ),
          const SizedBox(height: 12),
          _buildPolicyItem(
            ref,
            title: "REFUND_POLICY_STEP2_TITLE".tr(ref), // 예: 2. 48시간 ~ 7일 이내 (개발자 환불)
            content: "REFUND_POLICY_STEP2_DESC".tr(ref), // 예: 하단의 '이메일 문의'를 통해...
          ),
          const SizedBox(height: 12),
          _buildPolicyItem(
            ref,
            title: "REFUND_POLICY_STEP3_TITLE".tr(ref), // 예: 3. 7일 경과 후
            content: "REFUND_POLICY_STEP3_DESC".tr(ref), // 예: 환불 불가. 무료 체험으로 충분히...
          ),
          const SizedBox(height: 24),
          // 이메일 문의 버튼 (설정 화면에서 사용할 때 유용)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context); // 시트 닫기

                // 📍 [수정] SupportService를 호출하여 이메일 앱 실행
                // - 기기 정보 및 앱 버전이 포함된 템플릿이 자동으로 구성됩니다.
                try {
                  await SupportService.sendSupportEmail(ref);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("ERROR_NO_EMAIL_APP".tr(ref)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.email_outlined),
              label: Text("REFUND_POLICY_CONTACT_BTN".tr(ref)), // 예: 이메일로 문의하기
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(WidgetRef ref, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
      ],
    );
  }
}