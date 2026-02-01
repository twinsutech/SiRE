// import 'dart:math';
// import 'dart:io'; // 📍 File 사용을 위해 추가
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../../core/theme/app_colors.dart';
// import '../ledger/add_transaction_sheet.dart';
// import '../ledger/ledger_provider.dart';
// import '../settings/user_provider.dart';
// import 'dashboard_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'alert_provider.dart';
// import 'alert_list_screen.dart';
//
// class DashboardScreen extends ConsumerWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final dashboardAsync = ref.watch(dashboardDataProvider);
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final alerts = ref.watch(appAlertProvider);
//     final currentLang = ref.watch(localizationProvider.notifier).currentLang;
//
//     // 📍 [추가] 글로벌 화폐 포매터 정의 (국가별 통화 기호 자동 포함)
//     final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: dashboardAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Error: $err')),
//         data: (data) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(context, ref, alerts),
//                 _buildUnpaidBanner(context, ref, unpaidAsync),
//
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildSummaryCard(
//                               ref,
//                               "DASHBOARD_THIS_MONTH", // 📍 다국어: "This Month"
//                               // 📍 [수정] 이번 달 수익 금액에 다국어 화폐 포맷 적용
//                               currencyFmt.format(data.totalIncome),
//                               Icons.monetization_on,
//                               AppColors.incomeGreen,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _buildSummaryCard(
//                               ref,
//                               "DASHBOARD_OCCUPANCY", // 📍 다국어: "Occupancy"
//                               "${(data.occupancyRate * 100).toStringAsFixed(0)}%",
//                               Icons.home,
//                               data.occupancyRate >= 0.9 ? AppColors.primaryNavy : Colors.orange,
//                               subtitle: "${data.vacantUnits} ${"DASHBOARD_VACANT_UNITS".tr(ref)}",
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//
//                       Text("DASHBOARD_REVENUE_TREND".tr(ref), // 📍 다국어: "Revenue Trend"
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 12),
//                       _buildRevenueChart(data, ref),
//                       const SizedBox(height: 24),
//
//                       Text("DASHBOARD_RECENT_ACTIVITY".tr(ref), // 📍 다국어: "Recent Activity"
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//
//                       if (data.recentTransactions.isEmpty)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 40),
//                           child: Center(child: Text("DASHBOARD_NO_RECENT_ACTIVITY".tr(ref), style: const TextStyle(color: Colors.grey))),
//                         )
//                       else
//                         ...data.recentTransactions.map((item) { // 📍 item(TransactionWithImages)으로 순회
//                           final tx = item.transaction; // 알맹이 추출
//                           final isIncome = tx.type == 'INC';
//                           final themeColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
//
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 4),
//                             child: Card(
//                               elevation: 0.5,
//                               color: Colors.white,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               child: ListTile(
//                                 dense: true,
//                                 // 📍 탭하면 상세 정보 보기 (장부와 동일한 경험)
//                                 onTap: () => showModalBottomSheet(
//                                   context: context,
//                                   isScrollControlled: true,
//                                   backgroundColor: Colors.transparent,
//                                   builder: (context) => AddTransactionSheet(transaction: tx),
//                                 ),
//                                 leading: CircleAvatar(
//                                   backgroundColor: themeColor.withOpacity(0.1),
//                                   child: Icon(
//                                     _getCategoryIcon(tx.category),
//                                     color: themeColor,
//                                     size: 20,
//                                   ),
//                                 ),
//                                 title: Row(
//                                   children: [
//                                     // 📍 [핵심 수정] 카테고리 명칭이 시스템 키(CAT_)일 경우 번역 처리
//                                     Text(
//                                         tx.category.startsWith('CAT_') ? tx.category.tr(ref) : tx.category,
//                                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
//                                     ),
//                                     // 📍 영수증 아이콘 추가 (장부와 일관성)
//                                     if (item.hasImages) ...[
//                                       const SizedBox(width: 4),
//                                       const Icon(Icons.receipt_long, size: 12, color: Colors.blueGrey),
//                                     ]
//                                   ],
//                                 ),
//                                 subtitle: Text("${DateFormat('MM.dd').format(tx.transactionDate)} ${tx.memo ?? ''}", style: const TextStyle(fontSize: 12)),
//                                 trailing: Text(
//                                   // 📍 [수정] 최근 활동 리스트 금액에 다국어 화폐 포맷 적용
//                                   "${isIncome ? '+' : '-'}${currencyFmt.format(tx.amount)}",
//                                   style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 15),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                       const SizedBox(height: 80),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context, WidgetRef ref, List<AppAlert> alerts) {
//     // 📍 닉네임과 이미지 정보를 모두 담고 있는 profile 데이터 구독
//     final profile = ref.watch(userNicknameProvider);
//
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//       decoration: const BoxDecoration(
//         color: Color(0xFF1A237E),
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
//       ),
//       child: Row(
//         children: [
//           // 📍 프로필 이미지 적용 (설정된 이미지가 있으면 FileImage, 없으면 기본 아이콘)
//           CircleAvatar(
//             backgroundColor: Colors.white24,
//             backgroundImage: profile.imagePath != null
//                 ? FileImage(File(profile.imagePath!))
//                 : null,
//             child: profile.imagePath == null
//                 ? const Icon(Icons.person, color: Colors.white)
//                 : null,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text("DASHBOARD_WELCOME".tr(ref), style: const TextStyle(color: Colors.white70, fontSize: 14)),
//                 ),
//                 Text(
//                   // 📍 [핵심 수정] 닉네임이 시스템 키(SETTINGS_)인 경우 번역 처리
//                   profile.nickname.startsWith('SETTINGS_') ? profile.nickname.tr(ref) : profile.nickname,
//                   style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           ShakingBellIcon(
//             alertCount: alerts.length,
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertListScreen()));
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUnpaidBanner(BuildContext context, WidgetRef ref, AsyncValue<List<UnpaidStatus>> unpaidAsync) {
//     return unpaidAsync.when(
//       data: (list) {
//         final overdueUnits = list.where((u) => u.status == 'OVERDUE').toList();
//         if (overdueUnits.isEmpty) return const SizedBox.shrink();
//
//         return InkWell(
//           onTap: () {
//             HapticFeedback.mediumImpact(); // 📍 터치 피드백 추가
//             _showUnpaidActionSheet(context, ref, overdueUnits);
//           },
//           child: Container(
//             margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.redAccent.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8)],
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("DASHBOARD_UNPAID_DETECTED".tr(ref), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
//                       Text("${"COMMON_ROOMS".tr(ref)}: ${overdueUnits.map((u) => u.unit.roomNumber).join(', ')}", style: const TextStyle(color: Colors.white, fontSize: 13)),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
//               ],
//             ),
//           ),
//         );
//       },
//       loading: () => const SizedBox.shrink(),
//       error: (_, __) => const SizedBox.shrink(),
//     );
//   }
//
//   void _showUnpaidActionSheet(BuildContext context, WidgetRef ref, List<UnpaidStatus> overdueUnits) {
//     // 📍 팝업 내부에서도 국가 설정을 가져옴
//     final currentLang = ref.read(localizationProvider.notifier).currentLang;
//     final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("DASHBOARD_UNPAID_TITLE".tr(ref), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
//                   ],
//                 ),
//                 Text("DASHBOARD_UNPAID_SUBTITLE".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 13)),
//                 const SizedBox(height: 16),
//                 Flexible(
//                   child: ListView.separated(
//                     shrinkWrap: true,
//                     itemCount: overdueUnits.length,
//                     separatorBuilder: (context, index) => const Divider(height: 1),
//                     itemBuilder: (context, index) {
//                       final unpaid = overdueUnits[index];
//                       final int rentAmount = unpaid.unit.monthlyRent;
//                       final String roomNo = unpaid.unit.roomNumber;
//                       final String tenant = unpaid.unit.tenantName ?? '세입자';
//
//                       return ListTile(
//                         contentPadding: EdgeInsets.zero,
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.redAccent.withOpacity(0.1),
//                           child: Text(roomNo, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
//                         ),
//                         title: Text("$roomNo${"COMMON_ROOM_UNIT".tr(ref)} ${"DASHBOARD_PAYMENT_CONFIRM".tr(ref)}"),
//                         // 📍 [수정] 팝업 내부 월세 금액에 다국어 화폐 포맷 적용
//                         subtitle: Text("$tenant / ${currencyFmt.format(rentAmount)}"),
//                         trailing: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF1A237E),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           onPressed: () async {
//                             await ref.read(ledgerActionProvider.notifier).processPayment(
//                               buildingId: unpaid.unit.buildingId,
//                               unitId: unpaid.unit.id,
//                               tenantName: tenant,
//                               amount: rentAmount,
//                               buildingName: "건물",
//                               unitNumber: roomNo,
//                             );
//
//                             if (context.mounted) {
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('$roomNo${"DASHBOARD_PAYMENT_COMPLETE".tr(ref)}')),
//                               );
//                             }
//                           },
//                           child: Text("COMMON_CONFIRM".tr(ref)),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildRevenueChart(dynamic data, WidgetRef ref) {
//     final currentLang = ref.watch(localizationProvider.notifier).currentLang;
//     // 📍 차트 툴팁용 축약 포맷 (예: 1,000,000 -> 1M)
//     final compactFmt = NumberFormat.compact(locale: currentLang);
//
//     return Container(
//       height: 260,
//       padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: LineChart(
//               LineChartData(
//                 showingTooltipIndicators: [
//                   ...(data.revenueSpots as List<FlSpot>).asMap().entries.map((entry) {
//                     if (entry.value.y > 0) {
//                       return ShowingTooltipIndicators([
//                         LineBarSpot(LineChartBarData(spots: data.revenueSpots), 0, entry.value),
//                       ]);
//                     }
//                     return null;
//                   }).whereType<ShowingTooltipIndicators>(),
//                 ],
//                 lineTouchData: LineTouchData(
//                   enabled: false,
//                   touchTooltipData: LineTouchTooltipData(
//                     tooltipBgColor: Colors.transparent,
//                     tooltipRoundedRadius: 0,
//                     tooltipPadding: EdgeInsets.zero,
//                     tooltipMargin: 4,
//                     getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
//                       return touchedBarSpots.map((barSpot) {
//                         final bool isRevenue = barSpot.barIndex == 0;
//                         return LineTooltipItem(
//                           // 📍 [수정] 차트 툴팁 금액에 로케일별 축약 포맷 적용
//                           compactFmt.format(barSpot.y),
//                           TextStyle(
//                             color: isRevenue ? const Color(0xFF1A237E) : Colors.red[700],
//                             fontWeight: FontWeight.bold,
//                             fontSize: 10,
//                           ),
//                         );
//                       }).toList();
//                     },
//                   ),
//                 ),
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: false,
//                   getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
//                 ),
//                 titlesData: FlTitlesData(
//                   show: true,
//                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       interval: 1,
//                       getTitlesWidget: (value, meta) {
//                         final now = DateTime.now();
//                         final date = DateTime(now.year, now.month - (5 - value.toInt()), 1);
//                         // 📍 월 표시 다국어 (단순화: '월' 접미사 처리)
//                         return SideTitleWidget(
//                           axisSide: meta.axisSide,
//                           child: Text('${date.month}${"COMMON_MONTH_UNIT".tr(ref)}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: data.revenueSpots,
//                     isCurved: true,
//                     color: const Color(0xFF1A237E),
//                     barWidth: 4,
//                     isStrokeCapRound: true,
//                     dotData: const FlDotData(show: true),
//                     belowBarData: BarAreaData(show: true, color: const Color(0xFF1A237E).withOpacity(0.05)),
//                   ),
//                   if (data.expenseSpots != null && data.expenseSpots.isNotEmpty)
//                     LineChartBarData(
//                       spots: data.expenseSpots,
//                       isCurved: true,
//                       color: Colors.red[300]!.withOpacity(0.6),
//                       barWidth: 3,
//                       dashArray: [5, 5],
//                       isStrokeCapRound: true,
//                       dotData: const FlDotData(show: false),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildLegendItem(ref, "COMMON_INCOME", const Color(0xFF1A237E)), // 📍 "수익"
//               const SizedBox(width: 16),
//               _buildLegendItem(ref, "COMMON_EXPENSE", Colors.red[300]!.withOpacity(0.6)), // 📍 "지출"
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(WidgetRef ref, String labelKey, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 3,
//           decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
//         ),
//         const SizedBox(width: 4),
//         Text(labelKey.tr(ref), style: const TextStyle(fontSize: 11, color: Colors.grey)),
//       ],
//     );
//   }
//
//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Rent': case '월세': case '임대료 수입': case 'CAT_RENT': return Icons.home_work_rounded;
//       case 'Tax': case '세금/공과금': case 'CAT_TAX': return Icons.request_quote_rounded;
//       case 'Repair': case '수리보수비': case 'CAT_REPAIR': return Icons.build_circle_rounded;
//       case 'Utility': case '전기/수도료': case 'CAT_UTILITY': return Icons.lightbulb_circle_rounded;
//       case 'Cleaning': case '청소비': case 'CAT_CLEANING': return Icons.cleaning_services_rounded;
//       case 'Maintenance': case '관리비': case 'CAT_MAINTENANCE': return Icons.settings_suggest_rounded;
//       case '보험료': case 'CAT_INSURANCE': return Icons.verified_user_rounded;
//       case 'Deposit': case '보증금': case 'CAT_DEPOSIT': return Icons.vpn_key_rounded;
//       default: return Icons.receipt_long_rounded;
//     }
//   }
//
//   Widget _buildSummaryCard(WidgetRef ref, String titleKey, String value, IconData icon, Color color, {String? subtitle}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 12),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(titleKey.tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//           if (subtitle != null) ...[
//             const SizedBox(height: 4),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(subtitle, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500)),
//             ),
//           ]
//         ],
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // 📍 ShakingBellIcon 위젯 로직 (기존 유지)
// // -----------------------------------------------------------------------------
// class ShakingBellIcon extends StatefulWidget {
//   final int alertCount;
//   final VoidCallback onTap;
//
//   const ShakingBellIcon({super.key, required this.alertCount, required this.onTap});
//
//   @override
//   State<ShakingBellIcon> createState() => _ShakingBellIconState();
// }
//
// class _ShakingBellIconState extends State<ShakingBellIcon> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
//     _startAnimationLoop();
//   }
//
//   void _startAnimationLoop() async {
//     while (mounted) {
//       if (widget.alertCount > 0) {
//         await _controller.forward();
//         await _controller.reverse();
//       }
//       await Future.delayed(const Duration(seconds: 3));
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           final double rotation = sin(_controller.value * 2 * pi) * 0.15;
//           return Transform.rotate(angle: widget.alertCount > 0 ? rotation : 0, child: child);
//         },
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             const Icon(Icons.notifications_none, color: Colors.white, size: 28),
//             if (widget.alertCount > 0)
//               Positioned(
//                 right: -4,
//                 top: -2,
//                 child: Container(
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: const Color(0xFF1A237E), width: 1.5),
//                   ),
//                   constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
//                   child: Center(
//                     child: Text(
//                       widget.alertCount > 9 ? '9+' : '${widget.alertCount}',
//                       style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:math';
import 'dart:io'; // 📍 File 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/theme/app_colors.dart';
import '../ledger/add_transaction_sheet.dart';
import '../ledger/ledger_provider.dart';
import '../settings/user_provider.dart';
import 'dashboard_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'alert_provider.dart';
import 'alert_list_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final alerts = ref.watch(appAlertProvider);
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 [추가] 글로벌 화폐 포매터 정의 (국가별 통화 기호 자동 포함)
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, alerts),
                _buildUnpaidBanner(context, ref, unpaidAsync),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              ref,
                              "DASHBOARD_THIS_MONTH", // 📍 다국어: "This Month"
                              // 📍 [수정] 이번 달 수익 금액에 다국어 화폐 포맷 적용
                              currencyFmt.format(data.totalIncome),
                              Icons.monetization_on,
                              AppColors.incomeGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              ref,
                              "DASHBOARD_OCCUPANCY", // 📍 다국어: "Occupancy"
                              "${(data.occupancyRate * 100).toStringAsFixed(0)}%",
                              Icons.home,
                              data.occupancyRate >= 0.9 ? AppColors.primaryNavy : Colors.orange,
                              subtitle: "${data.vacantUnits} ${"DASHBOARD_VACANT_UNITS".tr(ref)}",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text("DASHBOARD_REVENUE_TREND".tr(ref), // 📍 다국어: "Revenue Trend"
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      _buildRevenueChart(data, ref),
                      const SizedBox(height: 24),

                      Text("DASHBOARD_RECENT_ACTIVITY".tr(ref), // 📍 다국어: "Recent Activity"
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),

                      if (data.recentTransactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "DASHBOARD_NO_RECENT_ACTIVITY".tr(ref),
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...data.recentTransactions.map((item) { // 📍 item(TransactionWithImages)으로 순회
                          final tx = item.transaction; // 알맹이 추출
                          final isIncome = tx.type == 'INC';
                          final themeColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Card(
                              elevation: 0.5,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                dense: true,
                                // 📍 탭하면 상세 정보 보기 (장부와 동일한 경험)
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => AddTransactionSheet(transaction: tx),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: themeColor.withOpacity(0.1),
                                  child: Icon(
                                    _getCategoryIcon(tx.category),
                                    color: themeColor,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    // 📍 [핵심 수정] 카테고리 명칭이 시스템 키(CAT_)일 경우 번역 처리
                                    Expanded(
                                      child: Text(
                                        tx.category.startsWith('CAT_') ? tx.category.tr(ref) : tx.category,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // 📍 영수증 아이콘 추가 (장부와 일관성)
                                    if (item.hasImages) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.receipt_long, size: 12, color: Colors.blueGrey),
                                    ]
                                  ],
                                ),
                                subtitle: Text(
                                  "${DateFormat('MM.dd').format(tx.transactionDate)} ${tx.memo ?? ''}",
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 140),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      // 📍 [수정] 최근 활동 리스트 금액에 다국어 화폐 포맷 적용
                                      "${isIncome ? '+' : '-'}${currencyFmt.format(tx.amount)}",
                                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, List<AppAlert> alerts) {
    // 📍 닉네임과 이미지 정보를 모두 담고 있는 profile 데이터 구독
    final profile = ref.watch(userNicknameProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // 📍 프로필 이미지 적용 (설정된 이미지가 있으면 FileImage, 없으면 기본 아이콘)
          CircleAvatar(
            backgroundColor: Colors.white24,
            backgroundImage: profile.imagePath != null
                ? FileImage(File(profile.imagePath!))
                : null,
            child: profile.imagePath == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text("DASHBOARD_WELCOME".tr(ref), style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  // 📍 [핵심 수정] 닉네임이 시스템 키(SETTINGS_)인 경우 번역 처리
                  profile.nickname.startsWith('SETTINGS_') ? profile.nickname.tr(ref) : profile.nickname,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ShakingBellIcon(
            alertCount: alerts.length,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertListScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidBanner(BuildContext context, WidgetRef ref, AsyncValue<List<UnpaidStatus>> unpaidAsync) {
    return unpaidAsync.when(
      data: (list) {
        final overdueUnits = list.where((u) => u.status == 'OVERDUE').toList();
        if (overdueUnits.isEmpty) return const SizedBox.shrink();

        final roomsText = overdueUnits.map((u) => u.unit.roomNumber).join(', ');

        return InkWell(
          onTap: () {
            HapticFeedback.mediumImpact(); // 📍 터치 피드백 추가
            _showUnpaidActionSheet(context, ref, overdueUnits);
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8)],
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DASHBOARD_UNPAID_DETECTED".tr(ref),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${"COMMON_ROOMS".tr(ref)}: $roomsText",
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showUnpaidActionSheet(BuildContext context, WidgetRef ref, List<UnpaidStatus> overdueUnits) {
    // 📍 팝업 내부에서도 국가 설정을 가져옴
    final currentLang = ref.read(localizationProvider.notifier).currentLang;
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "DASHBOARD_UNPAID_TITLE".tr(ref),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                Text(
                  "DASHBOARD_UNPAID_SUBTITLE".tr(ref),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: overdueUnits.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final unpaid = overdueUnits[index];
                      final int rentAmount = unpaid.unit.monthlyRent;
                      final String roomNo = unpaid.unit.roomNumber;
                      final String tenant = unpaid.unit.tenantName ?? '세입자';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(roomNo, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        title: Text(
                          "$roomNo${"COMMON_ROOM_UNIT".tr(ref)} ${"DASHBOARD_PAYMENT_CONFIRM".tr(ref)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // 📍 [수정] 팝업 내부 월세 금액에 다국어 화폐 포맷 적용
                        subtitle: Text(
                          "$tenant / ${currencyFmt.format(rentAmount)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: const Size(0, 36),
                              ),
                              onPressed: () async {
                                await ref.read(ledgerActionProvider.notifier).processPayment(
                                  buildingId: unpaid.unit.buildingId,
                                  unitId: unpaid.unit.id,
                                  tenantName: tenant,
                                  amount: rentAmount,
                                  buildingName: "건물",
                                  unitNumber: roomNo,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$roomNo${"DASHBOARD_PAYMENT_COMPLETE".tr(ref)}')),
                                  );
                                }
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("COMMON_CONFIRM".tr(ref), maxLines: 1),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart(dynamic data, WidgetRef ref) {
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    // 📍 차트 툴팁용 축약 포맷 (예: 1,000,000 -> 1M)
    final compactFmt = NumberFormat.compact(locale: currentLang);

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                showingTooltipIndicators: [
                  ...(data.revenueSpots as List<FlSpot>).asMap().entries.map((entry) {
                    if (entry.value.y > 0) {
                      return ShowingTooltipIndicators([
                        LineBarSpot(LineChartBarData(spots: data.revenueSpots), 0, entry.value),
                      ]);
                    }
                    return null;
                  }).whereType<ShowingTooltipIndicators>(),
                ],
                lineTouchData: LineTouchData(
                  enabled: false,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipRoundedRadius: 0,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 4,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final bool isRevenue = barSpot.barIndex == 0;
                        return LineTooltipItem(
                          // 📍 [수정] 차트 툴팁 금액에 로케일별 축약 포맷 적용
                          compactFmt.format(barSpot.y),
                          TextStyle(
                            color: isRevenue ? const Color(0xFF1A237E) : Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final date = DateTime(now.year, now.month - (5 - value.toInt()), 1);
                        // 📍 월 표시 다국어 (단순화: '월' 접미사 처리)
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('${date.month}${"COMMON_MONTH_UNIT".tr(ref)}', style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.revenueSpots,
                    isCurved: true,
                    color: const Color(0xFF1A237E),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF1A237E).withOpacity(0.05)),
                  ),
                  if (data.expenseSpots != null && data.expenseSpots.isNotEmpty)
                    LineChartBarData(
                      spots: data.expenseSpots,
                      isCurved: true,
                      color: Colors.red[300]!.withOpacity(0.6),
                      barWidth: 3,
                      dashArray: [5, 5],
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(ref, "COMMON_INCOME", const Color(0xFF1A237E)), // 📍 "수익"
              const SizedBox(width: 16),
              _buildLegendItem(ref, "COMMON_EXPENSE", Colors.red[300]!.withOpacity(0.6)), // 📍 "지출"
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(WidgetRef ref, String labelKey, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(labelKey.tr(ref), style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Rent': case '월세': case '임대료 수입': case 'CAT_RENT': return Icons.home_work_rounded;
      case 'Tax': case '세금/공과금': case 'CAT_TAX': return Icons.request_quote_rounded;
      case 'Repair': case '수리보수비': case 'CAT_REPAIR': return Icons.build_circle_rounded;
      case 'Utility': case '전기/수도료': case 'CAT_UTILITY': return Icons.lightbulb_circle_rounded;
      case 'Cleaning': case '청소비': case 'CAT_CLEANING': return Icons.cleaning_services_rounded;
      case 'Maintenance': case '관리비': case 'CAT_MAINTENANCE': return Icons.settings_suggest_rounded;
      case '보험료': case 'CAT_INSURANCE': return Icons.verified_user_rounded;
      case 'Deposit': case '보증금': case 'CAT_DEPOSIT': return Icons.vpn_key_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  Widget _buildSummaryCard(WidgetRef ref, String titleKey, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            titleKey.tr(ref),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📍 ShakingBellIcon 위젯 로직 (기존 유지)
// -----------------------------------------------------------------------------
class ShakingBellIcon extends StatefulWidget {
  final int alertCount;
  final VoidCallback onTap;

  const ShakingBellIcon({super.key, required this.alertCount, required this.onTap});

  @override
  State<ShakingBellIcon> createState() => _ShakingBellIconState();
}

class _ShakingBellIconState extends State<ShakingBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted) {
      if (widget.alertCount > 0) {
        await _controller.forward();
        await _controller.reverse();
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double rotation = sin(_controller.value * 2 * pi) * 0.15;
          return Transform.rotate(angle: widget.alertCount > 0 ? rotation : 0, child: child);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            if (widget.alertCount > 0)
              Positioned(
                right: -4,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A237E), width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      widget.alertCount > 9 ? '9+' : '${widget.alertCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
