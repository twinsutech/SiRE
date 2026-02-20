// // lib/core/purchase/ui/paywall_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../models/purchase_status.dart';
// import '../state/purchase_provider.dart';
//
// /// ✅ [정리] Pro 결제/복원 공용 Paywall Screen
// /// - Reports 같은 Pro 전용 기능 화면에서 "게이트"로 재사용합니다.
// /// - 서버 없는 구조이므로 결제 성공/복원 성공은 purchaseStream을 통해 반영됩니다.
// /// - 필요 시 다른 기능 화면에서도 동일 PaywallScreen을 그대로 사용 가능합니다.
// ///
// /// ✅ 사용 예:
// /// if (!isPro) return const PaywallScreen();
// class PaywallScreen extends ConsumerWidget {
//   const PaywallScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final purchaseState = ref.watch(purchaseControllerProvider);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         title: const Text(
//           "SiRE Pro",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: _buildPaywallBody(context, ref, purchaseState),
//     );
//   }
//
//   // ✅ [공용] Pro Paywall UI
//   // - ReportsScreen에 있던 Paywall UI를 그대로 이동했습니다.
//   Widget _buildPaywallBody(
//       BuildContext context,
//       WidgetRef ref,
//       PurchaseState purchaseState,
//       ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 📍 섹션 타이틀 형태를 유지하면서 "잠금" 메시지를 표시합니다.
//           _buildSectionTitle(Icons.lock_outline, "SiRE Pro"),
//           const SizedBox(height: 10),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Reports / 분석 / Export 기능은 Pro에서 제공됩니다.",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "• Financial Analytics (월별 추세 / 카테고리 분석)\n"
//                       "• Tax Excel Export\n"
//                       "• Unpaid Excel Export / Image Share\n"
//                       "• Annual Summary",
//                   style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // ✅ Pro 구매 버튼
//                 // - 이제 IAP 연동 완료 상태이므로 실제 purchaseProLifetime() 호출로 연결합니다.
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1A237E),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onPressed: purchaseState.isLoading
//                         ? null
//                         : () async {
//                       // ✅ 구매 시작
//                       await ref.read(purchaseControllerProvider.notifier).purchaseProLifetime();
//
//                       // 에러가 있으면 스낵바로 안내(선택)
//                       final latest = ref.read(purchaseControllerProvider);
//                       final msg = latest.errorMessage;
//                       if (msg != null && msg.isNotEmpty) {
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text("결제 시작 실패: $msg"),
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                         }
//                         return;
//                       }
//
//                       // ✅ 에러가 없으면 결제 진행 안내
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("결제 화면이 표시되면 안내에 따라 진행해주세요."),
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                     icon: purchaseState.isLoading
//                         ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
//                         : const Icon(Icons.workspace_premium_outlined),
//                     label: const Text("Pro 구매 (평생)", style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//
//                 // ✅ 구매 복원 / 상태 새로고침
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onPressed: purchaseState.isLoading
//                         ? null
//                         : () async {
//                       await ref.read(purchaseControllerProvider.notifier).restorePurchases();
//
//                       // 로컬 상태 표시 정리
//                       await ref.read(purchaseControllerProvider.notifier).reload();
//
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("구매 복원 요청을 보냈습니다. 복원 결과는 잠시 후 반영될 수 있습니다."),
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.restore),
//                     label: const Text("구매 복원/상태 새로고침"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(IconData icon, String title) {
//     return Row(
//       children: [
//         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }

//
// // lib/core/purchase/ui/paywall_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../localization/localization_provider.dart'; // 📍 [추가] 다국어 tr(ref) 사용
// import '../models/purchase_status.dart';
// import '../state/purchase_provider.dart';
//
// /// ✅ [정리] Pro 결제/복원 공용 Paywall Screen
// /// - Reports 같은 Pro 전용 기능 화면에서 "게이트"로 재사용합니다.
// /// - 서버 없는 구조이므로 결제 성공/복원 성공은 purchaseStream을 통해 반영됩니다.
// /// - 필요 시 다른 기능 화면에서도 동일 PaywallScreen을 그대로 사용 가능합니다.
// ///
// /// ✅ 사용 예:
// /// if (!isPro) return const PaywallScreen();
// class PaywallScreen extends ConsumerWidget {
//   const PaywallScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final purchaseState = ref.watch(purchaseControllerProvider);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         title: Text(
//           "PAYWALL_TITLE".tr(ref),
//           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: _buildPaywallBody(context, ref, purchaseState),
//     );
//   }
//
//   // ✅ [공용] Pro Paywall UI
//   // - ReportsScreen에 있던 Paywall UI를 그대로 이동했습니다.
//   Widget _buildPaywallBody(
//       BuildContext context,
//       WidgetRef ref,
//       PurchaseState purchaseState,
//       ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 📍 섹션 타이틀 형태를 유지하면서 "잠금" 메시지를 표시합니다.
//           _buildSectionTitle(Icons.lock_outline, "PAYWALL_SECTION_TITLE".tr(ref)),
//           const SizedBox(height: 10),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "PAYWALL_HEADLINE".tr(ref),
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "PAYWALL_FEATURES".tr(ref),
//                   style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // ✅ Pro 구매 버튼
//                 // - 이제 IAP 연동 완료 상태이므로 실제 purchaseProLifetime() 호출로 연결합니다.
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1A237E),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onPressed: purchaseState.isLoading
//                         ? null
//                         : () async {
//                       // ✅ 구매 시작
//                       await ref.read(purchaseControllerProvider.notifier).purchaseProLifetime();
//
//                       // 에러가 있으면 스낵바로 안내(선택)
//                       final latest = ref.read(purchaseControllerProvider);
//                       final msg = latest.errorMessage;
//                       if (msg != null && msg.isNotEmpty) {
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text("${'IAP_PURCHASE_START_FAILED'.tr(ref)}: $msg"),
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                         }
//                         return;
//                       }
//
//                       // ✅ 에러가 없으면 결제 진행 안내
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("IAP_FOLLOW_STORE_INSTRUCTIONS".tr(ref)),
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                     icon: purchaseState.isLoading
//                         ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
//                         : const Icon(Icons.workspace_premium_outlined),
//                     label: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//
//                 // ✅ 구매 복원 / 상태 새로고침
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onPressed: purchaseState.isLoading
//                         ? null
//                         : () async {
//                       await ref.read(purchaseControllerProvider.notifier).restorePurchases();
//
//                       // 로컬 상태 표시 정리
//                       await ref.read(purchaseControllerProvider.notifier).reload();
//
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("SETTINGS_PRO_RESTORE_REQUEST_SENT".tr(ref)),
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.restore),
//                     label: Text("PAYWALL_RESTORE_AND_REFRESH".tr(ref)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(IconData icon, String title) {
//     return Row(
//       children: [
//         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }


// lib/core/purchase/ui/paywall_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/localization_provider.dart'; // 📍 [추가] 다국어 tr(ref) 사용
import '../models/purchase_status.dart';
import '../state/purchase_provider.dart';
import 'refund_policy_sheet.dart'; // 📍 [추가] 환불 정책 시트 임포트

/// ✅ [정리] Pro 결제/복원 공용 Paywall Screen
/// - Reports 같은 Pro 전용 기능 화면에서 "게이트"로 재사용합니다.
/// - 서버 없는 구조이므로 결제 성공/복원 성공은 purchaseStream을 통해 반영됩니다.
/// - 필요 시 다른 기능 화면에서도 동일 PaywallScreen을 그대로 사용 가능합니다.
///
/// ✅ 사용 예:
/// if (!isPro) return const PaywallScreen();
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "PAYWALL_TITLE".tr(ref),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildPaywallBody(context, ref, purchaseState),
    );
  }

  // ✅ [공용] Pro Paywall UI
  // - ReportsScreen에 있던 Paywall UI를 그대로 이동했습니다.
  Widget _buildPaywallBody(
      BuildContext context,
      WidgetRef ref,
      PurchaseState purchaseState,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📍 섹션 타이틀 형태를 유지하면서 "잠금" 메시지를 표시합니다.
          _buildSectionTitle(Icons.lock_outline, "PAYWALL_SECTION_TITLE".tr(ref)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PAYWALL_HEADLINE".tr(ref),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "PAYWALL_FEATURES".tr(ref),
                  style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // ✅ Pro 구매 버튼
                // - 이제 IAP 연동 완료 상태이므로 실제 purchaseProLifetime() 호출로 연결합니다.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: purchaseState.isLoading
                        ? null
                        : () async {
                      // ✅ 구매 시작
                      await ref.read(purchaseControllerProvider.notifier).purchaseProLifetime();

                      // 에러가 있으면 스낵바로 안내(선택)
                      final latest = ref.read(purchaseControllerProvider);
                      final msg = latest.errorMessage;
                      if (msg != null && msg.isNotEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${'IAP_PURCHASE_START_FAILED'.tr(ref)}: $msg"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }

                      // ✅ 에러가 없으면 결제 진행 안내
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("IAP_FOLLOW_STORE_INSTRUCTIONS".tr(ref)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: purchaseState.isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.workspace_premium_outlined),
                    label: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ 구매 복원 / 상태 새로고침
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: purchaseState.isLoading
                        ? null
                        : () async {
                      await ref.read(purchaseControllerProvider.notifier).restorePurchases();

                      // 로컬 상태 표시 정리
                      await ref.read(purchaseControllerProvider.notifier).reload();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("SETTINGS_PRO_RESTORE_REQUEST_SENT".tr(ref)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.restore),
                    label: Text("PAYWALL_RESTORE_AND_REFRESH".tr(ref)),
                  ),
                ),
                const SizedBox(height: 16), // 📍 [추가] 간격 추가

                // 📍 [추가] 결제 및 환불 정책 보기 텍스트 버튼 (구글 심사용)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      RefundPolicySheet.show(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF1A237E), // 메인 색상으로 변경
                    ),
                    label: Text(
                      "PAYWALL_REFUND_POLICY_BTN".tr(ref), // 다국어 키 연결
                      style: const TextStyle(
                        fontSize: 14, // 글자 크기 키움 (12 -> 14)
                        fontWeight: FontWeight.bold, // 글자 굵게
                        color: Color(0xFF1A237E), // 색상을 진한 파란색으로 변경
                        // decoration: TextDecoration.underline,
                        // decorationColor: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
