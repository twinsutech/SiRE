// // // // // // // // // import 'dart:io';
// // // // // // // // // import 'dart:typed_data';
// // // // // // // // // import 'dart:ui' as ui;
// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:flutter/rendering.dart';
// // // // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // // // // import 'package:fl_chart/fl_chart.dart';
// // // // // // // // // import 'package:intl/intl.dart';
// // // // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // // // import '../../core/purchase/models/purchase_status.dart';
// // // // // // // // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
// // // // // // // // //
// // // // // // // // // // ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
// // // // // // // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // // // // // //
// // // // // // // // // import '../ledger/ledger_provider.dart';
// // // // // // // // // import '../ledger/unpaid_provider.dart';
// // // // // // // // // import 'excel_export_service.dart';
// // // // // // // // //
// // // // // // // // // // ✅ [추가] Pro 인사이트 서비스
// // // // // // // // // import 'financial_insight_service.dart';
// // // // // // // // //
// // // // // // // // // class ReportsScreen extends ConsumerWidget {
// // // // // // // // //   const ReportsScreen({super.key});
// // // // // // // // //
// // // // // // // // //   // 📍 이미지 캡처를 위한 GlobalKey
// // // // // // // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // // // // // // //
// // // // // // // // //   // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
// // // // // // // // //   // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
// // // // // // // // //   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // // // // // //     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
// // // // // // // // //     final isPro = ref.watch(isProProvider);
// // // // // // // // //
// // // // // // // // //     // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
// // // // // // // // //     // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
// // // // // // // // //     // ignore: unused_local_variable
// // // // // // // // //     final purchaseState = ref.watch(purchaseControllerProvider);
// // // // // // // // //
// // // // // // // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // // // // // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // // // // // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // // // // // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // // // // // // //
// // // // // // // // //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// // // // // // // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // // // // // // //
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
// // // // // // // // //     // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
// // // // // // // // //     // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
// // // // // // // // //     //
// // // // // // // // //     // ✅ [중요]
// // // // // // // // //     // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
// // // // // // // // //     // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     ref.listen<bool>(isProProvider, (prev, next) {
// // // // // // // // //       // ✅ Pro → Free로 바뀌는 순간만 감지
// // // // // // // // //       if (prev == true && next == false) {
// // // // // // // // //         final alreadyShown = ref.read(_proDisabledToastShownProvider);
// // // // // // // // //         if (alreadyShown) return;
// // // // // // // // //
// // // // // // // // //         // ✅ 플래그 ON (연속 표시 방지)
// // // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = true;
// // // // // // // // //
// // // // // // // // //         // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
// // // // // // // // //         if (context.mounted) {
// // // // // // // // //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // //             SnackBar(
// // // // // // // // //               content: Text("REPORT_PRO_DISABLED_BY_REFUND".tr(ref)),
// // // // // // // // //               behavior: SnackBarBehavior.floating,
// // // // // // // // //             ),
// // // // // // // // //           );
// // // // // // // // //         }
// // // // // // // // //       }
// // // // // // // // //
// // // // // // // // //       // ✅ Free → Pro로 복구되면(재구매/복원 등)
// // // // // // // // //       // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
// // // // // // // // //       if (prev == false && next == true) {
// // // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = false;
// // // // // // // // //       }
// // // // // // // // //     });
// // // // // // // // //
// // // // // // // // //     // ✅ [2번 적용] Free 사용자면 Reports 전체를 공용 PaywallScreen으로 대체
// // // // // // // // //     // - ReportsScreen에 Paywall UI/구매 로직을 넣지 않습니다.
// // // // // // // // //     // - PaywallScreen은 다른 기능 화면에서도 재사용 가능합니다.
// // // // // // // // //     if (!isPro) {
// // // // // // // // //       return const PaywallScreen();
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     return Scaffold(
// // // // // // // // //       backgroundColor: Colors.grey[100],
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // // // // // //         foregroundColor: Colors.white,
// // // // // // // // //         elevation: 0,
// // // // // // // // //         scrolledUnderElevation: 0,
// // // // // // // // //         automaticallyImplyLeading: false,
// // // // // // // // //         centerTitle: false,
// // // // // // // // //         title: Text(
// // // // // // // // //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // // // // // // // //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // //         child: Column(
// // // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //           children: [
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //             // ✅ [추가] Pro 인사이트 카드 (데이터 → 해석 → 경고)
// // // // // // // // //             monthlyTrendAsync.when(
// // // // // // // // //               loading: () => const SizedBox.shrink(),
// // // // // // // // //               error: (_, __) => const SizedBox.shrink(),
// // // // // // // // //               data: (trendData) {
// // // // // // // // //                 return unpaidAsync.when(
// // // // // // // // //                   loading: () => const SizedBox.shrink(),
// // // // // // // // //                   error: (_, __) => const SizedBox.shrink(),
// // // // // // // // //                   data: (unpaidList) {
// // // // // // // // //                     int thisMonthIncome = 0;
// // // // // // // // //                     int thisMonthExpense = 0;
// // // // // // // // //                     int lastMonthExpense = 0;
// // // // // // // // //
// // // // // // // // //                     final now = DateTime.now();
// // // // // // // // //
// // // // // // // // //                     // ✅ 이번 달 데이터
// // // // // // // // //                     final thisMonthItem = trendData.where((e) =>
// // // // // // // // //                     e.month.year == now.year && e.month.month == now.month).toList();
// // // // // // // // //                     if (thisMonthItem.isNotEmpty) {
// // // // // // // // //                       thisMonthIncome = thisMonthItem.first.income;
// // // // // // // // //                       thisMonthExpense = thisMonthItem.first.expense;
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ 지난 달 데이터
// // // // // // // // //                     final last = DateTime(now.year, now.month - 1, 1);
// // // // // // // // //                     final lastMonthItem = trendData.where((e) =>
// // // // // // // // //                     e.month.year == last.year && e.month.month == last.month).toList();
// // // // // // // // //                     if (lastMonthItem.isNotEmpty) {
// // // // // // // // //                       lastMonthExpense = lastMonthItem.first.expense;
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ 미납 여부
// // // // // // // // //                     final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                     final hasUnpaid = overdue.isNotEmpty;
// // // // // // // // //
// // // // // // // // //                     final insights = FinancialInsightService.generate(
// // // // // // // // //                       thisMonthIncome: thisMonthIncome,
// // // // // // // // //                       thisMonthExpense: thisMonthExpense,
// // // // // // // // //                       lastMonthExpense: lastMonthExpense,
// // // // // // // // //                       hasUnpaid: hasUnpaid,
// // // // // // // // //                     );
// // // // // // // // //
// // // // // // // // //                     // ✅ 인사이트가 없으면 섹션 자체를 숨겨도 되고,
// // // // // // // // //                     // 안정 메시지를 서비스에서 항상 1개라도 반환하게 해도 됨.
// // // // // // // // //                     if (insights.isEmpty) return const SizedBox.shrink();
// // // // // // // // //
// // // // // // // // //                     return Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         ...insights.map((i) => _buildInsightCard(ref, i)).toList(),
// // // // // // // // //                         const SizedBox(height: 20),
// // // // // // // // //                       ],
// // // // // // // // //                     );
// // // // // // // // //                   },
// // // // // // // // //                 );
// // // // // // // // //               },
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //             // 📍 1. Financial Analytics 섹션
// // // // // // // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               height: 320,
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Row(
// // // // // // // // //                 children: [
// // // // // // // // //                   Expanded(
// // // // // // // // //                     flex: 3,
// // // // // // // // //                     child: Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // // //                         const SizedBox(height: 25),
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: monthlyTrendAsync.when(
// // // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // // //                             data: (data) => BarChart(
// // // // // // // // //                               BarChartData(
// // // // // // // // //                                 barTouchData: BarTouchData(
// // // // // // // // //                                   enabled: false,
// // // // // // // // //                                   touchTooltipData: BarTouchTooltipData(
// // // // // // // // //                                     tooltipBgColor: Colors.transparent,
// // // // // // // // //                                     tooltipPadding: EdgeInsets.zero,
// // // // // // // // //                                     tooltipMargin: 4,
// // // // // // // // //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// // // // // // // // //                                       if (rod.toY == 0) return null;
// // // // // // // // //                                       return BarTooltipItem(
// // // // // // // // //                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
// // // // // // // // //                                         currencyFmt.format(rod.toY),
// // // // // // // // //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// // // // // // // // //                                       );
// // // // // // // // //                                     },
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                                 barGroups: data.asMap().entries.map((e) {
// // // // // // // // //                                   final List<int> indicators = [];
// // // // // // // // //                                   if (e.value.income > 0) indicators.add(0);
// // // // // // // // //                                   if (e.value.expense > 0) indicators.add(1);
// // // // // // // // //
// // // // // // // // //                                   return BarChartGroupData(
// // // // // // // // //                                     x: e.key,
// // // // // // // // //                                     barsSpace: 4,
// // // // // // // // //                                     showingTooltipIndicators: indicators,
// // // // // // // // //                                     barRods: [
// // // // // // // // //                                       BarChartRodData(
// // // // // // // // //                                         toY: e.value.income.toDouble(),
// // // // // // // // //                                         color: Colors.blue,
// // // // // // // // //                                         width: 8,
// // // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // // //                                       ),
// // // // // // // // //                                       BarChartRodData(
// // // // // // // // //                                         toY: e.value.expense.toDouble(),
// // // // // // // // //                                         color: Colors.redAccent,
// // // // // // // // //                                         width: 8,
// // // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ],
// // // // // // // // //                                   );
// // // // // // // // //                                 }).toList(),
// // // // // // // // //                                 titlesData: FlTitlesData(
// // // // // // // // //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   bottomTitles: AxisTitles(
// // // // // // // // //                                     sideTitles: SideTitles(
// // // // // // // // //                                       showTitles: true,
// // // // // // // // //                                       getTitlesWidget: (value, meta) {
// // // // // // // // //                                         int index = value.toInt();
// // // // // // // // //                                         if (index >= 0 && index < data.length) {
// // // // // // // // //                                           return Padding(
// // // // // // // // //                                             padding: const EdgeInsets.only(top: 8.0),
// // // // // // // // //                                             child: Text(DateFormat.MMM(lang).format(data[index].month), style: const TextStyle(fontSize: 9)),
// // // // // // // // //                                           );
// // // // // // // // //                                         }
// // // // // // // // //                                         return const Text('');
// // // // // // // // //                                       },
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                                 gridData: const FlGridData(show: false),
// // // // // // // // //                                 borderData: FlBorderData(show: false),
// // // // // // // // //                               ),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(height: 12),
// // // // // // // // //                         Row(
// // // // // // // // //                           mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // // //                           children: [
// // // // // // // // //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // // // // // // // //                             const SizedBox(width: 12),
// // // // // // // // //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// // // // // // // // //                           ],
// // // // // // // // //                         )
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(width: 12),
// // // // // // // // //                   // 📍 연간 지출 차트 섹션
// // // // // // // // //                   Expanded(
// // // // // // // // //                     flex: 2,
// // // // // // // // //                     child: Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: categoryStatsAsync.when(
// // // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // // //                             data: (data) {
// // // // // // // // //                               if (data.isEmpty) return Center(child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// // // // // // // // //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // // // // // // //
// // // // // // // // //                               return Column(
// // // // // // // // //                                 children: [
// // // // // // // // //                                   Expanded(
// // // // // // // // //                                     flex: 3,
// // // // // // // // //                                     child: PieChart(
// // // // // // // // //                                       PieChartData(
// // // // // // // // //                                         sectionsSpace: 2,
// // // // // // // // //                                         centerSpaceRadius: 10,
// // // // // // // // //                                         sections: data.asMap().entries.map((entry) {
// // // // // // // // //                                           final double pctValue = entry.value.percentage * 100;
// // // // // // // // //                                           final String percentageStr = pctValue.toStringAsFixed(0);
// // // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // // //                                               : entry.value.category;
// // // // // // // // //
// // // // // // // // //                                           final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';
// // // // // // // // //
// // // // // // // // //                                           return PieChartSectionData(
// // // // // // // // //                                             value: entry.value.amount.toDouble(),
// // // // // // // // //                                             title: sectionTitle,
// // // // // // // // //                                             titleStyle: const TextStyle(
// // // // // // // // //                                               fontSize: 7,
// // // // // // // // //                                               fontWeight: FontWeight.bold,
// // // // // // // // //                                               color: Colors.white,
// // // // // // // // //                                               height: 1.2,
// // // // // // // // //                                             ),
// // // // // // // // //                                             color: colors[entry.key % colors.length],
// // // // // // // // //                                             radius: 40,
// // // // // // // // //                                           );
// // // // // // // // //                                         }).toList(),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                   const SizedBox(height: 12),
// // // // // // // // //                                   Expanded(
// // // // // // // // //                                     flex: 3,
// // // // // // // // //                                     child: SingleChildScrollView(
// // // // // // // // //                                       child: Column(
// // // // // // // // //                                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                                         children: data.asMap().entries.map((entry) {
// // // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // // //                                               : entry.value.category;
// // // // // // // // //                                           return Padding(
// // // // // // // // //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// // // // // // // // //                                             child: _buildLegend(
// // // // // // // // //                                               colors[entry.key % colors.length],
// // // // // // // // //                                               // 📍 [수정] 범례 금액 다국어 포맷 적용
// // // // // // // // //                                               "$categoryName (${currencyFmt.format(entry.value.amount)})",
// // // // // // // // //                                               fontSize: 9,
// // // // // // // // //                                             ),
// // // // // // // // //                                           );
// // // // // // // // //                                         }).toList(),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ],
// // // // // // // // //                               );
// // // // // // // // //                             },
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 2. Tax Data Management 섹션
// // // // // // // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Column(
// // // // // // // // //                 children: [
// // // // // // // // //                   Container(
// // // // // // // // //                     padding: const EdgeInsets.all(12),
// // // // // // // // //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                     child: Row(
// // // // // // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}"),
// // // // // // // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(height: 20),
// // // // // // // // //                   SizedBox(
// // // // // // // // //                     width: double.infinity,
// // // // // // // // //                     child: ElevatedButton.icon(
// // // // // // // // //                       style: ElevatedButton.styleFrom(
// // // // // // // // //                         backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                         foregroundColor: Colors.white,
// // // // // // // // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                       ),
// // // // // // // // //                       onPressed: () async {
// // // // // // // // //                         final transactions = await ref.read(ledgerListProvider.future);
// // // // // // // // //                         if (transactions.isEmpty) return;
// // // // // // // // //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// // // // // // // // //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// // // // // // // // //                       },
// // // // // // // // //                       icon: const Icon(Icons.file_download),
// // // // // // // // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 3. Unpaid Management 섹션
// // // // // // // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Column(
// // // // // // // // //                 children: [
// // // // // // // // //                   RepaintBoundary(
// // // // // // // // //                     key: _unpaidCaptureKey,
// // // // // // // // //                     child: Container(
// // // // // // // // //                       width: double.infinity,
// // // // // // // // //                       padding: const EdgeInsets.all(12),
// // // // // // // // //                       decoration: BoxDecoration(
// // // // // // // // //                         color: Colors.white,
// // // // // // // // //                         border: Border.all(color: Colors.grey.shade300),
// // // // // // // // //                         borderRadius: BorderRadius.circular(8),
// // // // // // // // //                       ),
// // // // // // // // //                       child: unpaidAsync.when(
// // // // // // // // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// // // // // // // // //                         data: (list) {
// // // // // // // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // // // // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // // // // // // //                           return Column(
// // // // // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                             children: [
// // // // // // // // //                               Text(
// // // // // // // // //                                 // 📍 [수정] 미납 총액 다국어 포맷 적용
// // // // // // // // //                                 "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// // // // // // // // //                                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// // // // // // // // //                               ),
// // // // // // // // //                               const SizedBox(height: 8),
// // // // // // // // //                               ...overdue.take(5).map(
// // // // // // // // //                                     (u) => Padding(
// // // // // // // // //                                   padding: const EdgeInsets.symmetric(vertical: 2),
// // // // // // // // //                                   // 📍 [수정] 개별 미납액 다국어 포맷 적용
// // // // // // // // //                                   child: Text(
// // // // // // // // //                                     "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? 'COMMON_ANONYMOUS'.tr(ref)}): ${currencyFmt.format(u.unit.monthlyRent)}",
// // // // // // // // //                                     style: const TextStyle(fontSize: 12, color: Colors.black87),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                               ),
// // // // // // // // //                             ],
// // // // // // // // //                           );
// // // // // // // // //                         },
// // // // // // // // //                       ),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(height: 20),
// // // // // // // // //                   Row(
// // // // // // // // //                     children: [
// // // // // // // // //                       Expanded(
// // // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // // //                             backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                           ),
// // // // // // // // //                           onPressed: () async {
// // // // // // // // //                             final list = await ref.read(unpaidListProvider.future);
// // // // // // // // //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                             if (overdue.isEmpty) return;
// // // // // // // // //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // // // // // // // //                           },
// // // // // // // // //                           icon: const Icon(Icons.file_download),
// // // // // // // // //                           label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                       const SizedBox(width: 10),
// // // // // // // // //                       Expanded(
// // // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // // //                             backgroundColor: Colors.orangeAccent,
// // // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                           ),
// // // // // // // // //                           onPressed: () => _captureAndShareImage(context, ref),
// // // // // // // // //                           icon: const Icon(Icons.share_outlined),
// // // // // // // // //                           label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                     ],
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 4. Annual Summary
// // // // // // // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: monthlyTrendAsync.when(
// // // // // // // // //                 loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                 error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// // // // // // // // //                 data: (trend) {
// // // // // // // // //                   final int currentYear = DateTime.now().year;
// // // // // // // // //                   final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// // // // // // // // //
// // // // // // // // //                   int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// // // // // // // // //                   int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// // // // // // // // //                   int yearlyProfit = yearlyIncome - yearlyExpense;
// // // // // // // // //
// // // // // // // // //                   return Column(
// // // // // // // // //                     children: [
// // // // // // // // //                       Row(
// // // // // // // // //                         mainAxisAlignment: MainAxisAlignment.end,
// // // // // // // // //                         children: [
// // // // // // // // //                           Text(
// // // // // // // // //                             "${'COMMON_YEAR'.tr(ref)}: $currentYear",
// // // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
// // // // // // // // //                           ),
// // // // // // // // //                         ],
// // // // // // // // //                       ),
// // // // // // // // //                       const SizedBox(height: 10),
// // // // // // // // //                       // 📍 [수정] 요약 금액들 다국어 포맷 적용
// // // // // // // // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// // // // // // // // //                       const Divider(height: 20),
// // // // // // // // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// // // // // // // // //                       const Divider(height: 20),
// // // // // // // // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// // // // // // // // //                       const SizedBox(height: 15),
// // // // // // // // //                       Text(
// // // // // // // // //                         "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// // // // // // // // //                         style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// // // // // // // // //                       )
// // // // // // // // //                     ],
// // // // // // // // //                   );
// // // // // // // // //                 },
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //             const SizedBox(height: 50),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 인사이트 카드 UI
// // // // // // // // //   // - 다국어는 messageKey.tr(ref)로 처리
// // // // // // // // //   // - 레벨별 색상/아이콘을 다르게 표시
// // // // // // // // //   Widget _buildInsightCard(WidgetRef ref, FinancialInsight insight) {
// // // // // // // // //     final Color color = switch (insight.level) {
// // // // // // // // //       InsightLevel.info => Colors.blueGrey,
// // // // // // // // //       InsightLevel.warning => Colors.orange,
// // // // // // // // //       InsightLevel.alert => Colors.redAccent,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     final IconData icon = switch (insight.level) {
// // // // // // // // //       InsightLevel.info => Icons.info_outline,
// // // // // // // // //       InsightLevel.warning => Icons.warning_amber_rounded,
// // // // // // // // //       InsightLevel.alert => Icons.report_gmailerrorred_outlined,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     return Container(
// // // // // // // // //       width: double.infinity,
// // // // // // // // //       margin: const EdgeInsets.only(bottom: 8),
// // // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: color.withOpacity(0.08),
// // // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // // //         border: Border.all(color: color.withOpacity(0.25)),
// // // // // // // // //       ),
// // // // // // // // //       child: Row(
// // // // // // // // //         children: [
// // // // // // // // //           Icon(icon, color: color, size: 18),
// // // // // // // // //           const SizedBox(width: 8),
// // // // // // // // //           Expanded(
// // // // // // // // //             child: Text(
// // // // // // // // //               insight.messageKey.tr(ref),
// // // // // // // // //               style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black87),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
// // // // // // // // //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // // //       children: [
// // // // // // // // //         Text(
// // // // // // // // //           label,
// // // // // // // // //           style: TextStyle(
// // // // // // // // //             fontSize: 14,
// // // // // // // // //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
// // // // // // // // //             color: Colors.black87,
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //         Text(
// // // // // // // // //           // 📍 국가별 통화 포맷 적용
// // // // // // // // //           fmt.format(amount),
// // // // // // // // //           style: TextStyle(
// // // // // // // // //             fontSize: 16,
// // // // // // // // //             fontWeight: FontWeight.bold,
// // // // // // // // //             color: color,
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _buildSectionTitle(IconData icon, String title) {
// // // // // // // // //     return Row(
// // // // // // // // //       children: [
// // // // // // // // //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// // // // // // // // //         const SizedBox(width: 8),
// // // // // // // // //         Text(
// // // // // // // // //           title,
// // // // // // // // //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisSize: MainAxisSize.min,
// // // // // // // // //       mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // // //       crossAxisAlignment: CrossAxisAlignment.center,
// // // // // // // // //       children: [
// // // // // // // // //         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
// // // // // // // // //         const SizedBox(width: 6),
// // // // // // // // //         Flexible(
// // // // // // // // //           child: Text(
// // // // // // // // //             label,
// // // // // // // // //             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             textAlign: TextAlign.left,
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// // // // // // // // //     try {
// // // // // // // // //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // // // // // // //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // // // // // // //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // // // // // // //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // // // // // // //       final tempDir = await getTemporaryDirectory();
// // // // // // // // //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// // // // // // // // //       await file.writeAsBytes(pngBytes);
// // // // // // // // //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// // // // // // // // //     } catch (e) {
// // // // // // // // //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // //
// // // // // // // // //
// // // // // // // // // import 'dart:io';
// // // // // // // // // import 'dart:typed_data';
// // // // // // // // // import 'dart:ui' as ui;
// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:flutter/rendering.dart';
// // // // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // // // // import 'package:fl_chart/fl_chart.dart';
// // // // // // // // // import 'package:intl/intl.dart';
// // // // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // // // import '../../core/purchase/models/purchase_status.dart';
// // // // // // // // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
// // // // // // // // //
// // // // // // // // // // ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
// // // // // // // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // // // // // //
// // // // // // // // // import '../ledger/ledger_provider.dart';
// // // // // // // // // import '../ledger/unpaid_provider.dart';
// // // // // // // // // import 'excel_export_service.dart';
// // // // // // // // //
// // // // // // // // // // ✅ [추가] Pro 인사이트 서비스
// // // // // // // // // import 'financial_insight_service.dart';
// // // // // // // // //
// // // // // // // // // class ReportsScreen extends ConsumerWidget {
// // // // // // // // //   const ReportsScreen({super.key});
// // // // // // // // //
// // // // // // // // //   // 📍 이미지 캡처를 위한 GlobalKey
// // // // // // // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // // // // // // //
// // // // // // // // //   // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
// // // // // // // // //   // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
// // // // // // // // //   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // // // // // //     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
// // // // // // // // //     final isPro = ref.watch(isProProvider);
// // // // // // // // //
// // // // // // // // //     // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
// // // // // // // // //     // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
// // // // // // // // //     // ignore: unused_local_variable
// // // // // // // // //     final purchaseState = ref.watch(purchaseControllerProvider);
// // // // // // // // //
// // // // // // // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // // // // // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // // // // // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // // // // // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // // // // // // //
// // // // // // // // //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// // // // // // // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // // // // // // //
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
// // // // // // // // //     // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
// // // // // // // // //     // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
// // // // // // // // //     //
// // // // // // // // //     // ✅ [중요]
// // // // // // // // //     // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
// // // // // // // // //     // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     ref.listen<bool>(isProProvider, (prev, next) {
// // // // // // // // //       // ✅ Pro → Free로 바뀌는 순간만 감지
// // // // // // // // //       if (prev == true && next == false) {
// // // // // // // // //         final alreadyShown = ref.read(_proDisabledToastShownProvider);
// // // // // // // // //         if (alreadyShown) return;
// // // // // // // // //
// // // // // // // // //         // ✅ 플래그 ON (연속 표시 방지)
// // // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = true;
// // // // // // // // //
// // // // // // // // //         // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
// // // // // // // // //         if (context.mounted) {
// // // // // // // // //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // //             SnackBar(
// // // // // // // // //               content: Text("REPORT_PRO_DISABLED_BY_REFUND".tr(ref)),
// // // // // // // // //               behavior: SnackBarBehavior.floating,
// // // // // // // // //             ),
// // // // // // // // //           );
// // // // // // // // //         }
// // // // // // // // //       }
// // // // // // // // //
// // // // // // // // //       // ✅ Free → Pro로 복구되면(재구매/복원 등)
// // // // // // // // //       // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
// // // // // // // // //       if (prev == false && next == true) {
// // // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = false;
// // // // // // // // //       }
// // // // // // // // //     });
// // // // // // // // //
// // // // // // // // //     // ✅ [변경] Reports 전체를 Paywall로 막지 않습니다.
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     // 기존 방식:
// // // // // // // // //     // if (!isPro) return const PaywallScreen();
// // // // // // // // //     //
// // // // // // // // //     // 현재 방식(요청 반영):
// // // // // // // // //     // - 보고서 전체 : 타이틀 + 기본 그래프 → Free
// // // // // // // // //     // - 해석/비교/경고 : 블러 + Pro 카드 (① + ③)
// // // // // // // // //     // - 엑셀/공유 : 클릭 시 Paywall (②)
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //
// // // // // // // // //     return Scaffold(
// // // // // // // // //       backgroundColor: Colors.grey[100],
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // // // // // //         foregroundColor: Colors.white,
// // // // // // // // //         elevation: 0,
// // // // // // // // //         scrolledUnderElevation: 0,
// // // // // // // // //         automaticallyImplyLeading: false,
// // // // // // // // //         centerTitle: false,
// // // // // // // // //         title: Text(
// // // // // // // // //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // // // // // // // //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // //         child: Column(
// // // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //           children: [
// // // // // // // // //             // ✅ [추가] Pro 인사이트 카드 (데이터 → 해석 → 경고)
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             // ✅ 요청 반영:
// // // // // // // // //             // - Free: 섹션은 보여주되(타이틀 노출), 내용은 블러 + 잠금 오버레이
// // // // // // // // //             // - Pro: 실제 인사이트 카드 표시
// // // // // // // // //             //
// // // // // // // // //             // ✅ [중요] 오버플로우 방지:
// // // // // // // // //             // - "블러 대상" 높이가 너무 작으면 Stack 영역이 작아져 오버레이 카드가 넘칠 수 있음
// // // // // // // // //             // - 따라서 Free에서는 "블러 대상"을 최소 높이로 보장합니다(minHeight)
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             monthlyTrendAsync.when(
// // // // // // // // //               loading: () => const SizedBox.shrink(),
// // // // // // // // //               error: (_, __) => const SizedBox.shrink(),
// // // // // // // // //               data: (trendData) {
// // // // // // // // //                 return unpaidAsync.when(
// // // // // // // // //                   loading: () => const SizedBox.shrink(),
// // // // // // // // //                   error: (_, __) => const SizedBox.shrink(),
// // // // // // // // //                   data: (unpaidList) {
// // // // // // // // //                     int thisMonthIncome = 0;
// // // // // // // // //                     int thisMonthExpense = 0;
// // // // // // // // //                     int lastMonthExpense = 0;
// // // // // // // // //
// // // // // // // // //                     final now = DateTime.now();
// // // // // // // // //
// // // // // // // // //                     // ✅ 이번 달 데이터
// // // // // // // // //                     final thisMonthItem = trendData
// // // // // // // // //                         .where((e) => e.month.year == now.year && e.month.month == now.month)
// // // // // // // // //                         .toList();
// // // // // // // // //                     if (thisMonthItem.isNotEmpty) {
// // // // // // // // //                       thisMonthIncome = thisMonthItem.first.income;
// // // // // // // // //                       thisMonthExpense = thisMonthItem.first.expense;
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ 지난 달 데이터
// // // // // // // // //                     final last = DateTime(now.year, now.month - 1, 1);
// // // // // // // // //                     final lastMonthItem = trendData
// // // // // // // // //                         .where((e) => e.month.year == last.year && e.month.month == last.month)
// // // // // // // // //                         .toList();
// // // // // // // // //                     if (lastMonthItem.isNotEmpty) {
// // // // // // // // //                       lastMonthExpense = lastMonthItem.first.expense;
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ 미납 여부
// // // // // // // // //                     final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                     final hasUnpaid = overdue.isNotEmpty;
// // // // // // // // //
// // // // // // // // //                     final insights = FinancialInsightService.generate(
// // // // // // // // //                       thisMonthIncome: thisMonthIncome,
// // // // // // // // //                       thisMonthExpense: thisMonthExpense,
// // // // // // // // //                       lastMonthExpense: lastMonthExpense,
// // // // // // // // //                       hasUnpaid: hasUnpaid,
// // // // // // // // //                     );
// // // // // // // // //
// // // // // // // // //                     // ✅ 인사이트가 없으면 섹션 자체를 숨겨도 되고,
// // // // // // // // //                     // 안정 메시지를 서비스에서 항상 1개라도 반환하게 해도 됨.
// // // // // // // // //                     if (insights.isEmpty) return const SizedBox.shrink();
// // // // // // // // //
// // // // // // // // //                     final insightList = Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         ...insights.map((i) => _buildInsightCard(ref, i)).toList(),
// // // // // // // // //                         const SizedBox(height: 20),
// // // // // // // // //                       ],
// // // // // // // // //                     );
// // // // // // // // //
// // // // // // // // //                     // // ✅ Free 사용자: 블러 + 잠금 오버레이(클릭 시 Paywall)
// // // // // // // // //                     // if (!isPro) {
// // // // // // // // //                     //   return _buildProBlurLock(
// // // // // // // // //                     //     context: context,
// // // // // // // // //                     //     ref: ref,
// // // // // // // // //                     //     // ✅ 오버플로우 방지: 최소 높이를 보장
// // // // // // // // //                     //     child: ConstrainedBox(
// // // // // // // // //                     //       constraints: const BoxConstraints(minHeight: 110),
// // // // // // // // //                     //       child: insightList,
// // // // // // // // //                     //     ),
// // // // // // // // //                     //     // ✅ (① + ③) 해석/비교/경고는 Pro
// // // // // // // // //                     //     subtitle: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE".tr(ref),
// // // // // // // // //                     //   );
// // // // // // // // //                     // }
// // // // // // // // //                     //
// // // // // // // // //                     // // ✅ Pro 사용자: 실제 인사이트 노출
// // // // // // // // //                     // return insightList;
// // // // // // // // //
// // // // // // // // //                     if (!isPro) {
// // // // // // // // //                       return Column(
// // // // // // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                         children: [
// // // // // // // // //                           _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // // //                           const SizedBox(height: 10),
// // // // // // // // //                           _buildProLockCard(
// // // // // // // // //                             context,
// // // // // // // // //                             ref,
// // // // // // // // //                             subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE",
// // // // // // // // //                             onTap: () => _openPaywall(context),
// // // // // // // // //                           ),
// // // // // // // // //                           const SizedBox(height: 20),
// // // // // // // // //                         ],
// // // // // // // // //                       );
// // // // // // // // //                     }
// // // // // // // // //                     return insightList; // Pro면 정상 표시
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //                   },
// // // // // // // // //                 );
// // // // // // // // //               },
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             // 📍 1. Financial Analytics 섹션
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             // ✅ 요청 반영:
// // // // // // // // //             // - "기본 그래프"는 Free로 그대로 노출
// // // // // // // // //             // - (추가 고도화) 그래프 해석/비교 문구를 만들면 그 부분만 블러 처리 권장
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               height: 320,
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Row(
// // // // // // // // //                 children: [
// // // // // // // // //                   Expanded(
// // // // // // // // //                     flex: 3,
// // // // // // // // //                     child: Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
// // // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // // //                         const SizedBox(height: 25),
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: monthlyTrendAsync.when(
// // // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // // //                             data: (data) => BarChart(
// // // // // // // // //                               BarChartData(
// // // // // // // // //                                 barTouchData: BarTouchData(
// // // // // // // // //                                   enabled: false,
// // // // // // // // //                                   touchTooltipData: BarTouchTooltipData(
// // // // // // // // //                                     tooltipBgColor: Colors.transparent,
// // // // // // // // //                                     tooltipPadding: EdgeInsets.zero,
// // // // // // // // //                                     tooltipMargin: 4,
// // // // // // // // //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// // // // // // // // //                                       if (rod.toY == 0) return null;
// // // // // // // // //                                       return BarTooltipItem(
// // // // // // // // //                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
// // // // // // // // //                                         currencyFmt.format(rod.toY),
// // // // // // // // //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// // // // // // // // //                                       );
// // // // // // // // //                                     },
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                                 barGroups: data.asMap().entries.map((e) {
// // // // // // // // //                                   final List<int> indicators = [];
// // // // // // // // //                                   if (e.value.income > 0) indicators.add(0);
// // // // // // // // //                                   if (e.value.expense > 0) indicators.add(1);
// // // // // // // // //
// // // // // // // // //                                   return BarChartGroupData(
// // // // // // // // //                                     x: e.key,
// // // // // // // // //                                     barsSpace: 4,
// // // // // // // // //                                     showingTooltipIndicators: indicators,
// // // // // // // // //                                     barRods: [
// // // // // // // // //                                       BarChartRodData(
// // // // // // // // //                                         toY: e.value.income.toDouble(),
// // // // // // // // //                                         color: Colors.blue,
// // // // // // // // //                                         width: 8,
// // // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // // //                                       ),
// // // // // // // // //                                       BarChartRodData(
// // // // // // // // //                                         toY: e.value.expense.toDouble(),
// // // // // // // // //                                         color: Colors.redAccent,
// // // // // // // // //                                         width: 8,
// // // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ],
// // // // // // // // //                                   );
// // // // // // // // //                                 }).toList(),
// // // // // // // // //                                 titlesData: FlTitlesData(
// // // // // // // // //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   bottomTitles: AxisTitles(
// // // // // // // // //                                     sideTitles: SideTitles(
// // // // // // // // //                                       showTitles: true,
// // // // // // // // //                                       getTitlesWidget: (value, meta) {
// // // // // // // // //                                         int index = value.toInt();
// // // // // // // // //                                         if (index >= 0 && index < data.length) {
// // // // // // // // //                                           return Padding(
// // // // // // // // //                                             padding: const EdgeInsets.only(top: 8.0),
// // // // // // // // //                                             child: Text(
// // // // // // // // //                                               DateFormat.MMM(lang).format(data[index].month),
// // // // // // // // //                                               style: const TextStyle(fontSize: 9),
// // // // // // // // //                                             ),
// // // // // // // // //                                           );
// // // // // // // // //                                         }
// // // // // // // // //                                         return const Text('');
// // // // // // // // //                                       },
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                                 gridData: const FlGridData(show: false),
// // // // // // // // //                                 borderData: FlBorderData(show: false),
// // // // // // // // //                               ),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(height: 12),
// // // // // // // // //                         Row(
// // // // // // // // //                           mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // // //                           children: [
// // // // // // // // //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // // // // // // // //                             const SizedBox(width: 12),
// // // // // // // // //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// // // // // // // // //                           ],
// // // // // // // // //                         )
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(width: 12),
// // // // // // // // //                   // 📍 연간 지출 차트 섹션
// // // // // // // // //                   Expanded(
// // // // // // // // //                     flex: 2,
// // // // // // // // //                     child: Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
// // // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: categoryStatsAsync.when(
// // // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // // //                             data: (data) {
// // // // // // // // //                               if (data.isEmpty) {
// // // // // // // // //                                 return Center(
// // // // // // // // //                                     child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// // // // // // // // //                               }
// // // // // // // // //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // // // // // // //
// // // // // // // // //                               return Column(
// // // // // // // // //                                 children: [
// // // // // // // // //                                   Expanded(
// // // // // // // // //                                     flex: 3,
// // // // // // // // //                                     child: PieChart(
// // // // // // // // //                                       PieChartData(
// // // // // // // // //                                         sectionsSpace: 2,
// // // // // // // // //                                         centerSpaceRadius: 10,
// // // // // // // // //                                         sections: data.asMap().entries.map((entry) {
// // // // // // // // //                                           final double pctValue = entry.value.percentage * 100;
// // // // // // // // //                                           final String percentageStr = pctValue.toStringAsFixed(0);
// // // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // // //                                               : entry.value.category;
// // // // // // // // //
// // // // // // // // //                                           final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';
// // // // // // // // //
// // // // // // // // //                                           return PieChartSectionData(
// // // // // // // // //                                             value: entry.value.amount.toDouble(),
// // // // // // // // //                                             title: sectionTitle,
// // // // // // // // //                                             titleStyle: const TextStyle(
// // // // // // // // //                                               fontSize: 7,
// // // // // // // // //                                               fontWeight: FontWeight.bold,
// // // // // // // // //                                               color: Colors.white,
// // // // // // // // //                                               height: 1.2,
// // // // // // // // //                                             ),
// // // // // // // // //                                             color: colors[entry.key % colors.length],
// // // // // // // // //                                             radius: 40,
// // // // // // // // //                                           );
// // // // // // // // //                                         }).toList(),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                   const SizedBox(height: 12),
// // // // // // // // //                                   Expanded(
// // // // // // // // //                                     flex: 3,
// // // // // // // // //                                     child: SingleChildScrollView(
// // // // // // // // //                                       child: Column(
// // // // // // // // //                                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                                         children: data.asMap().entries.map((entry) {
// // // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // // //                                               : entry.value.category;
// // // // // // // // //                                           return Padding(
// // // // // // // // //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// // // // // // // // //                                             child: _buildLegend(
// // // // // // // // //                                               colors[entry.key % colors.length],
// // // // // // // // //                                               // 📍 [수정] 범례 금액 다국어 포맷 적용
// // // // // // // // //                                               "$categoryName (${currencyFmt.format(entry.value.amount)})",
// // // // // // // // //                                               fontSize: 9,
// // // // // // // // //                                             ),
// // // // // // // // //                                           );
// // // // // // // // //                                         }).toList(),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ],
// // // // // // // // //                               );
// // // // // // // // //                             },
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 2. Tax Data Management 섹션
// // // // // // // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Column(
// // // // // // // // //                 children: [
// // // // // // // // //                   Container(
// // // // // // // // //                     padding: const EdgeInsets.all(12),
// // // // // // // // //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                     child: Row(
// // // // // // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // // //                       children: [
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: Text(
// // // // // // // // //                             "${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}",
// // // // // // // // //                             maxLines: 1,
// // // // // // // // //                             overflow: TextOverflow.ellipsis,
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(width: 10),
// // // // // // // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(height: 20),
// // // // // // // // //                   SizedBox(
// // // // // // // // //                     width: double.infinity,
// // // // // // // // //                     child: ElevatedButton.icon(
// // // // // // // // //                       style: ElevatedButton.styleFrom(
// // // // // // // // //                         backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                         foregroundColor: Colors.white,
// // // // // // // // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                       ),
// // // // // // // // //                       onPressed: () async {
// // // // // // // // //                         // -------------------------------------------------------------------------
// // // // // // // // //                         // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                         // -------------------------------------------------------------------------
// // // // // // // // //                         if (!isPro) {
// // // // // // // // //                           _openPaywall(context);
// // // // // // // // //                           return;
// // // // // // // // //                         }
// // // // // // // // //
// // // // // // // // //                         final transactions = await ref.read(ledgerListProvider.future);
// // // // // // // // //                         if (transactions.isEmpty) return;
// // // // // // // // //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// // // // // // // // //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// // // // // // // // //                       },
// // // // // // // // //                       icon: const Icon(Icons.file_download),
// // // // // // // // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 3. Unpaid Management 섹션
// // // // // // // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Column(
// // // // // // // // //                 children: [
// // // // // // // // //                   RepaintBoundary(
// // // // // // // // //                     key: _unpaidCaptureKey,
// // // // // // // // //                     child: Container(
// // // // // // // // //                       width: double.infinity,
// // // // // // // // //                       padding: const EdgeInsets.all(12),
// // // // // // // // //                       decoration: BoxDecoration(
// // // // // // // // //                         color: Colors.white,
// // // // // // // // //                         border: Border.all(color: Colors.grey.shade300),
// // // // // // // // //                         borderRadius: BorderRadius.circular(8),
// // // // // // // // //                       ),
// // // // // // // // //                       child: unpaidAsync.when(
// // // // // // // // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// // // // // // // // //                         data: (list) {
// // // // // // // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // // // // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // // // // // // //                           return Column(
// // // // // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                             children: [
// // // // // // // // //                               Text(
// // // // // // // // //                                 // 📍 [수정] 미납 총액 다국어 포맷 적용
// // // // // // // // //                                 "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// // // // // // // // //                                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// // // // // // // // //                               ),
// // // // // // // // //                               const SizedBox(height: 8),
// // // // // // // // //                               ...overdue.take(5).map(
// // // // // // // // //                                     (u) => Padding(
// // // // // // // // //                                   padding: const EdgeInsets.symmetric(vertical: 2),
// // // // // // // // //                                   // 📍 [수정] 개별 미납액 다국어 포맷 적용
// // // // // // // // //                                   child: Text(
// // // // // // // // //                                     "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? 'COMMON_ANONYMOUS'.tr(ref)}): ${currencyFmt.format(u.unit.monthlyRent)}",
// // // // // // // // //                                     style: const TextStyle(fontSize: 12, color: Colors.black87),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                               ),
// // // // // // // // //                             ],
// // // // // // // // //                           );
// // // // // // // // //                         },
// // // // // // // // //                       ),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(height: 20),
// // // // // // // // //                   // Row(
// // // // // // // // //                   //   children: [
// // // // // // // // //                   //     Expanded(
// // // // // // // // //                   //       child: ElevatedButton.icon(
// // // // // // // // //                   //         style: ElevatedButton.styleFrom(
// // // // // // // // //                   //           backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                   //           foregroundColor: Colors.white,
// // // // // // // // //                   //           padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // // //                   //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                   //         ),
// // // // // // // // //                   //         onPressed: () async {
// // // // // // // // //                   //           // -------------------------------------------------------------------------
// // // // // // // // //                   //           // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                   //           // -------------------------------------------------------------------------
// // // // // // // // //                   //           if (!isPro) {
// // // // // // // // //                   //             _openPaywall(context);
// // // // // // // // //                   //             return;
// // // // // // // // //                   //           }
// // // // // // // // //                   //
// // // // // // // // //                   //           final list = await ref.read(unpaidListProvider.future);
// // // // // // // // //                   //           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                   //           if (overdue.isEmpty) return;
// // // // // // // // //                   //           await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // // // // // // // //                   //         },
// // // // // // // // //                   //         icon: const Icon(Icons.file_download),
// // // // // // // // //                   //         label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                   //       ),
// // // // // // // // //                   //     ),
// // // // // // // // //                   //     const SizedBox(width: 10),
// // // // // // // // //                   //     Expanded(
// // // // // // // // //                   //       child: ElevatedButton.icon(
// // // // // // // // //                   //         style: ElevatedButton.styleFrom(
// // // // // // // // //                   //           backgroundColor: Colors.orangeAccent,
// // // // // // // // //                   //           foregroundColor: Colors.white,
// // // // // // // // //                   //           padding: const EdgeInsets.symmetric(vertical: 16),
// // // // // // // // //                   //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                   //         ),
// // // // // // // // //                   //         onPressed: () {
// // // // // // // // //                   //           // -------------------------------------------------------------------------
// // // // // // // // //                   //           // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                   //           // -------------------------------------------------------------------------
// // // // // // // // //                   //           if (!isPro) {
// // // // // // // // //                   //             _openPaywall(context);
// // // // // // // // //                   //             return;
// // // // // // // // //                   //           }
// // // // // // // // //                   //           _captureAndShareImage(context, ref);
// // // // // // // // //                   //         },
// // // // // // // // //                   //         icon: const Icon(Icons.share_outlined),
// // // // // // // // //                   //         label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                   //       ),
// // // // // // // // //                   //     ),
// // // // // // // // //                   //   ],
// // // // // // // // //                   // ),
// // // // // // // // //
// // // // // // // // //                   Row(
// // // // // // // // //                     children: [
// // // // // // // // //                       Expanded(
// // // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // // //                             backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // // //
// // // // // // // // //                             // ✅ [수정] 세로 패딩을 약간 줄이고, 가로 패딩을 명시해 공간 확보
// // // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
// // // // // // // // //
// // // // // // // // //                             // ✅ [수정] 터치 영역/밀도 조정(작은 기기에서도 줄바꿈 완화)
// // // // // // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                             visualDensity: VisualDensity.compact,
// // // // // // // // //                             minimumSize: const Size(0, 44),
// // // // // // // // //
// // // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                           ),
// // // // // // // // //                           onPressed: () async {
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             if (!isPro) {
// // // // // // // // //                               _openPaywall(context);
// // // // // // // // //                               return;
// // // // // // // // //                             }
// // // // // // // // //
// // // // // // // // //                             final list = await ref.read(unpaidListProvider.future);
// // // // // // // // //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                             if (overdue.isEmpty) return;
// // // // // // // // //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // // // // // // // //                           },
// // // // // // // // //
// // // // // // // // //                           // ✅ [수정] 아이콘 조금 축소 + 간격 축소(가로 공간 확보)
// // // // // // // // //                           icon: const Icon(Icons.file_download, size: 18),
// // // // // // // // //                           label: FittedBox(
// // // // // // // // //                             fit: BoxFit.scaleDown, // ✅ 핵심: 한 줄 유지 + 자동 축소
// // // // // // // // //                             child: Text(
// // // // // // // // //                               "REPORT_BTN_UNPAID_EXCEL".tr(ref),
// // // // // // // // //                               maxLines: 1,
// // // // // // // // //                               softWrap: false,
// // // // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                       const SizedBox(width: 10),
// // // // // // // // //                       Expanded(
// // // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // // //                             backgroundColor: Colors.orangeAccent,
// // // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // // //
// // // // // // // // //                             // ✅ [수정] 동일하게 적용
// // // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
// // // // // // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                             visualDensity: VisualDensity.compact,
// // // // // // // // //                             minimumSize: const Size(0, 44),
// // // // // // // // //
// // // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                           ),
// // // // // // // // //                           onPressed: () {
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             if (!isPro) {
// // // // // // // // //                               _openPaywall(context);
// // // // // // // // //                               return;
// // // // // // // // //                             }
// // // // // // // // //                             _captureAndShareImage(context, ref);
// // // // // // // // //                           },
// // // // // // // // //
// // // // // // // // //                           // ✅ [수정] 아이콘 조금 축소 + 간격 축소
// // // // // // // // //                           icon: const Icon(Icons.share_outlined, size: 18),
// // // // // // // // //                           label: FittedBox(
// // // // // // // // //                             fit: BoxFit.scaleDown, // ✅ 핵심: 한 줄 유지 + 자동 축소
// // // // // // // // //                             child: Text(
// // // // // // // // //                               "REPORT_BTN_UNPAID_IMAGE".tr(ref),
// // // // // // // // //                               maxLines: 1,
// // // // // // // // //                               softWrap: false,
// // // // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                     ],
// // // // // // // // //                   ),
// // // // // // // // //
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 4. Annual Summary
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             // ✅ 요청 반영:
// // // // // // // // //             // - 숫자 요약은 "해석/판단" 성격이 강하므로 Pro로 두는 편이 가격 설득에 유리
// // // // // // // // //             // - Free에선 섹션 타이틀 노출 + 내용 블러(클릭 시 Paywall)
// // // // // // // // //             //
// // // // // // // // //             // ✅ [중요] 오버플로우 방지:
// // // // // // // // //             // - 잠금 오버레이 카드가 "센터 고정(Row)"이면 작은 기기에서 overflow 발생
// // // // // // // // //             // - 오버레이는 "세로(Column) + 버튼 아래" 형태로 구성하여 안정화
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             monthlyTrendAsync.when(
// // // // // // // // //               loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //               error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// // // // // // // // //               data: (trend) {
// // // // // // // // //                 final annualCard = Container(
// // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // //                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //                   child: () {
// // // // // // // // //                     final int currentYear = DateTime.now().year;
// // // // // // // // //                     final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// // // // // // // // //
// // // // // // // // //                     int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// // // // // // // // //                     int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// // // // // // // // //                     int yearlyProfit = yearlyIncome - yearlyExpense;
// // // // // // // // //
// // // // // // // // //                     return Column(
// // // // // // // // //                       children: [
// // // // // // // // //                         Row(
// // // // // // // // //                           mainAxisAlignment: MainAxisAlignment.end,
// // // // // // // // //                           children: [
// // // // // // // // //                             Text(
// // // // // // // // //                               "${'COMMON_YEAR'.tr(ref)}: $currentYear",
// // // // // // // // //                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
// // // // // // // // //                             ),
// // // // // // // // //                           ],
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         // 📍 [수정] 요약 금액들 다국어 포맷 적용
// // // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// // // // // // // // //                         const Divider(height: 20),
// // // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// // // // // // // // //                         const Divider(height: 20),
// // // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// // // // // // // // //                         const SizedBox(height: 15),
// // // // // // // // //                         Text(
// // // // // // // // //                           "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// // // // // // // // //                           style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// // // // // // // // //                         )
// // // // // // // // //                       ],
// // // // // // // // //                     );
// // // // // // // // //                   }(),
// // // // // // // // //                 );
// // // // // // // // //
// // // // // // // // //                 // // ✅ Free 사용자: 블러 + 잠금 오버레이(클릭 시 Paywall)
// // // // // // // // //                 // if (!isPro) {
// // // // // // // // //                 //   return _buildProBlurLock(
// // // // // // // // //                 //     context: context,
// // // // // // // // //                 //     ref: ref,
// // // // // // // // //                 //     child: annualCard,
// // // // // // // // //                 //     subtitle: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE".tr(ref),
// // // // // // // // //                 //   );
// // // // // // // // //                 // }
// // // // // // // // //                 //
// // // // // // // // //                 // // ✅ Pro 사용자: 그대로 표시
// // // // // // // // //                 // return annualCard;
// // // // // // // // //
// // // // // // // // //                 // ✅ Free 사용자: 블러+오버레이 대신 "잠금 카드로 대체"
// // // // // // // // //                 if (!isPro) {
// // // // // // // // //                   return _buildProLockCard(
// // // // // // // // //                     context,
// // // // // // // // //                     ref,
// // // // // // // // //                     subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE",
// // // // // // // // //                     onTap: () => _openPaywall(context),
// // // // // // // // //                   );
// // // // // // // // //                 }
// // // // // // // // //
// // // // // // // // // // ✅ Pro 사용자: 실제 annualCard
// // // // // // // // //                 return annualCard;
// // // // // // // // //
// // // // // // // // //               },
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 50),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 인사이트 카드 UI
// // // // // // // // //   // - 다국어는 messageKey.tr(ref)로 처리
// // // // // // // // //   // - 레벨별 색상/아이콘을 다르게 표시
// // // // // // // // //   Widget _buildInsightCard(WidgetRef ref, FinancialInsight insight) {
// // // // // // // // //     final Color color = switch (insight.level) {
// // // // // // // // //       InsightLevel.info => Colors.blueGrey,
// // // // // // // // //       InsightLevel.warning => Colors.orange,
// // // // // // // // //       InsightLevel.alert => Colors.redAccent,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     final IconData icon = switch (insight.level) {
// // // // // // // // //       InsightLevel.info => Icons.info_outline,
// // // // // // // // //       InsightLevel.warning => Icons.warning_amber_rounded,
// // // // // // // // //       InsightLevel.alert => Icons.report_gmailerrorred_outlined,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     return Container(
// // // // // // // // //       width: double.infinity,
// // // // // // // // //       margin: const EdgeInsets.only(bottom: 8),
// // // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: color.withOpacity(0.08),
// // // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // // //         border: Border.all(color: color.withOpacity(0.25)),
// // // // // // // // //       ),
// // // // // // // // //       child: Row(
// // // // // // // // //         children: [
// // // // // // // // //           Icon(icon, color: color, size: 18),
// // // // // // // // //           const SizedBox(width: 8),
// // // // // // // // //           Expanded(
// // // // // // // // //             child: Text(
// // // // // // // // //               insight.messageKey.tr(ref),
// // // // // // // // //               style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black87),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 잠금 블러 오버레이 (① + ③)
// // // // // // // // //   // - 섹션은 보여주되, 내용은 블러 처리하고
// // // // // // // // //   // - 탭하면 Paywall로 이동
// // // // // // // // //   // - 별도의 Paywall 위젯을 Reports 내부에 직접 심지 않음(공용 PaywallScreen 사용)
// // // // // // // // //   //
// // // // // // // // //   // ✅ [오버플로우 해결 포인트]
// // // // // // // // //   // - 기존: Row(텍스트 + 버튼) 형태로 "센터"에 고정되면 작은 기기/긴 다국어에서 overflow가 빈번
// // // // // // // // //   // - 개선: "세로(Column)" 형태로 구성 + LayoutBuilder로 최대 폭 제한 + maxLines/ellipsis 적용
// // // // // // // // //   // - 또한 Stack의 오버레이는 child 크기에 종속되므로, child가 너무 작으면 카드가 넘칠 수 있어
// // // // // // // // //   //   상단에서 minHeight 보장(인사이트 섹션에 적용)
// // // // // // // // //   // Widget _buildProBlurLock({
// // // // // // // // //   //   required BuildContext context,
// // // // // // // // //   //   required WidgetRef ref,
// // // // // // // // //   //   required Widget child,
// // // // // // // // //   //   String? subtitle,
// // // // // // // // //   // }) {
// // // // // // // // //   //   return Stack(
// // // // // // // // //   //     alignment: Alignment.center,
// // // // // // // // //   //     children: [
// // // // // // // // //   //       // ✅ 내용 블러 + 비활성화 느낌
// // // // // // // // //   //       Opacity(
// // // // // // // // //   //         opacity: 0.92,
// // // // // // // // //   //         child: ImageFiltered(
// // // // // // // // //   //           imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
// // // // // // // // //   //           child: IgnorePointer(child: child),
// // // // // // // // //   //         ),
// // // // // // // // //   //       ),
// // // // // // // // //   //
// // // // // // // // //   //       // ✅ 잠금 오버레이
// // // // // // // // //   //       Positioned.fill(
// // // // // // // // //   //         child: Material(
// // // // // // // // //   //           color: Colors.transparent,
// // // // // // // // //   //           child: InkWell(
// // // // // // // // //   //             borderRadius: BorderRadius.circular(12),
// // // // // // // // //   //             onTap: () => _openPaywall(context),
// // // // // // // // //   //             child: Center(
// // // // // // // // //   //               child: LayoutBuilder(
// // // // // // // // //   //                 builder: (context, constraints) {
// // // // // // // // //   //                   // ✅ 카드 폭 상한/하한 설정 (작은 기기에서 버튼/텍스트가 자연폭으로 커져 overflow 방지)
// // // // // // // // //   //                   final double maxW = constraints.maxWidth;
// // // // // // // // //   //                   final double cardW = (maxW * 0.92).clamp(220.0, 520.0);
// // // // // // // // //   //
// // // // // // // // //   //                   return ConstrainedBox(
// // // // // // // // //   //                     constraints: BoxConstraints(maxWidth: cardW),
// // // // // // // // //   //                     child: Container(
// // // // // // // // //   //                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
// // // // // // // // //   //                       decoration: BoxDecoration(
// // // // // // // // //   //                         color: Colors.white.withOpacity(0.92),
// // // // // // // // //   //                         borderRadius: BorderRadius.circular(14),
// // // // // // // // //   //                         border: Border.all(color: Colors.black.withOpacity(0.08)),
// // // // // // // // //   //                         boxShadow: [
// // // // // // // // //   //                           BoxShadow(
// // // // // // // // //   //                             color: Colors.black.withOpacity(0.08),
// // // // // // // // //   //                             blurRadius: 12,
// // // // // // // // //   //                             offset: const Offset(0, 6),
// // // // // // // // //   //                           ),
// // // // // // // // //   //                         ],
// // // // // // // // //   //                       ),
// // // // // // // // //   //                       // ✅ Row 대신 Column으로 구성(가로 overflow 근본 차단)
// // // // // // // // //   //                       child: Column(
// // // // // // // // //   //                         mainAxisSize: MainAxisSize.min,
// // // // // // // // //   //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //   //                         children: [
// // // // // // // // //   //                           Row(
// // // // // // // // //   //                             children: [
// // // // // // // // //   //                               const Icon(Icons.lock_outline, size: 18, color: Color(0xFF1A237E)),
// // // // // // // // //   //                               const SizedBox(width: 8),
// // // // // // // // //   //                               Expanded(
// // // // // // // // //   //                                 child: Text(
// // // // // // // // //   //                                   "REPORTS_PRO_LOCK_TITLE".tr(ref),
// // // // // // // // //   //                                   maxLines: 1,
// // // // // // // // //   //                                   overflow: TextOverflow.ellipsis,
// // // // // // // // //   //                                   style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
// // // // // // // // //   //                                 ),
// // // // // // // // //   //                               ),
// // // // // // // // //   //                             ],
// // // // // // // // //   //                           ),
// // // // // // // // //   //                           if (subtitle != null && subtitle.isNotEmpty) ...[
// // // // // // // // //   //                             const SizedBox(height: 4),
// // // // // // // // //   //                             Text(
// // // // // // // // //   //                               subtitle,
// // // // // // // // //   //                               maxLines: 2,
// // // // // // // // //   //                               overflow: TextOverflow.ellipsis,
// // // // // // // // //   //                               style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.2),
// // // // // // // // //   //                             ),
// // // // // // // // //   //                           ],
// // // // // // // // //   //                           const SizedBox(height: 10),
// // // // // // // // //   //                           Align(
// // // // // // // // //   //                             alignment: Alignment.centerRight,
// // // // // // // // //   //                             child: ConstrainedBox(
// // // // // // // // //   //                               constraints: const BoxConstraints(maxWidth: 180),
// // // // // // // // //   //                               child: SizedBox(
// // // // // // // // //   //                                 height: 36,
// // // // // // // // //   //                                 child: ElevatedButton(
// // // // // // // // //   //                                   style: ElevatedButton.styleFrom(
// // // // // // // // //   //                                     backgroundColor: const Color(0xFF1A237E),
// // // // // // // // //   //                                     foregroundColor: Colors.white,
// // // // // // // // //   //                                     padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // // // //   //                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// // // // // // // // //   //                                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //   //                                     minimumSize: const Size(0, 36),
// // // // // // // // //   //                                   ),
// // // // // // // // //   //                                   onPressed: () => _openPaywall(context),
// // // // // // // // //   //                                   child: FittedBox(
// // // // // // // // //   //                                     fit: BoxFit.scaleDown, // ✅ 버튼 텍스트 오버플로우 방지
// // // // // // // // //   //                                     child: Text(
// // // // // // // // //   //                                       "REPORTS_PRO_LOCK_BUTTON".tr(ref),
// // // // // // // // //   //                                       maxLines: 1,
// // // // // // // // //   //                                     ),
// // // // // // // // //   //                                   ),
// // // // // // // // //   //                                 ),
// // // // // // // // //   //                               ),
// // // // // // // // //   //                             ),
// // // // // // // // //   //                           ),
// // // // // // // // //   //                         ],
// // // // // // // // //   //                       ),
// // // // // // // // //   //                     ),
// // // // // // // // //   //                   );
// // // // // // // // //   //                 },
// // // // // // // // //   //               ),
// // // // // // // // //   //
// // // // // // // // //   //
// // // // // // // // //   //             ),
// // // // // // // // //   //
// // // // // // // // //   //
// // // // // // // // //   //           ),
// // // // // // // // //   //         ),
// // // // // // // // //   //       ),
// // // // // // // // //   //     ],
// // // // // // // // //   //   );
// // // // // // // // //   // }
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 잠금 카드(오버플로우 방지 버전)
// // // // // // // // //   // - compact=true 이면 오버레이에서 쓸 때 margin 제거
// // // // // // // // //   Widget _buildProLockCard(
// // // // // // // // //       BuildContext context,
// // // // // // // // //       WidgetRef ref, {
// // // // // // // // //         required String subtitleKey,
// // // // // // // // //         required VoidCallback onTap,
// // // // // // // // //         bool compact = false, // ✅ 추가
// // // // // // // // //       }) {
// // // // // // // // //     return Container(
// // // // // // // // //       width: double.infinity,
// // // // // // // // //       margin: compact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12), // ✅ 변경
// // // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: Colors.white,
// // // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // // //         border: Border.all(color: Colors.grey.shade300),
// // // // // // // // //       ),
// // // // // // // // //       child: Column(
// // // // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //         children: [
// // // // // // // // //           // ✅ 1) 상단: 아이콘 + 타이틀(한 줄)
// // // // // // // // //           Row(
// // // // // // // // //             children: [
// // // // // // // // //               const Icon(Icons.lock_outline, color: Color(0xFF1A237E), size: 18),
// // // // // // // // //               const SizedBox(width: 10),
// // // // // // // // //               Expanded(
// // // // // // // // //                 child: Text(
// // // // // // // // //                   "REPORTS_PRO_LOCK_TITLE".tr(ref), // ✅ SiRE Pro 타이틀
// // // // // // // // //                   maxLines: 1,
// // // // // // // // //                   overflow: TextOverflow.ellipsis,
// // // // // // // // //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ],
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 6),
// // // // // // // // //
// // // // // // // // //           // ✅ 2) 중단: 설명(최대 2줄)
// // // // // // // // //           Text(
// // // // // // // // //             subtitleKey.tr(ref),
// // // // // // // // //             maxLines: 2,
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.2),
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 10),
// // // // // // // // //
// // // // // // // // //           // ✅ 3) 하단: 버튼(오른쪽 정렬, 한 줄)
// // // // // // // // //           Align(
// // // // // // // // //             alignment: Alignment.centerRight,
// // // // // // // // //             child: ConstrainedBox(
// // // // // // // // //               constraints: const BoxConstraints(maxWidth: 170), // ✅ 버튼 최대폭 제한(언어 길이 대비)
// // // // // // // // //               child: SizedBox(
// // // // // // // // //                 height: 36,
// // // // // // // // //                 child: ElevatedButton(
// // // // // // // // //                   style: ElevatedButton.styleFrom(
// // // // // // // // //                     backgroundColor: const Color(0xFF1A237E),
// // // // // // // // //                     foregroundColor: Colors.white,
// // // // // // // // //                     padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // // // //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// // // // // // // // //                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                     minimumSize: const Size(0, 36),
// // // // // // // // //                   ),
// // // // // // // // //                   onPressed: onTap,
// // // // // // // // //                   child: FittedBox(
// // // // // // // // //                     fit: BoxFit.scaleDown,
// // // // // // // // //                     child: Text(
// // // // // // // // //                       "REPORTS_PRO_LOCK_BUTTON".tr(ref),
// // // // // // // // //                       maxLines: 1,
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 잠금 블러 오버레이 (① + ③)
// // // // // // // // //   // - 섹션은 보여주되, 내용은 블러 처리하고
// // // // // // // // //   // - 탭하면 Paywall로 이동
// // // // // // // // //   // - 별도의 Paywall 위젯을 Reports 내부에 직접 심지 않음(공용 PaywallScreen 사용)
// // // // // // // // //   Widget _buildProBlurLock({
// // // // // // // // //     required BuildContext context,
// // // // // // // // //     required WidgetRef ref,
// // // // // // // // //     required Widget child,
// // // // // // // // //     String? subtitle,
// // // // // // // // //   }) {
// // // // // // // // //     return ClipRRect( // ✅ 핵심: 블러/오버레이가 부모 밖으로 “그려지지 않게” 클립
// // // // // // // // //       borderRadius: BorderRadius.circular(12),
// // // // // // // // //       child: Stack(
// // // // // // // // //         clipBehavior: Clip.hardEdge, // ✅ 핵심
// // // // // // // // //         children: [
// // // // // // // // //           // ✅ 내용 블러 + 비활성화 느낌
// // // // // // // // //           Opacity(
// // // // // // // // //             opacity: 0.92,
// // // // // // // // //             child: ImageFiltered(
// // // // // // // // //               imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
// // // // // // // // //               child: IgnorePointer(child: child),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           // ✅ 잠금 오버레이
// // // // // // // // //           Positioned.fill(
// // // // // // // // //             child: Material(
// // // // // // // // //               color: Colors.transparent,
// // // // // // // // //               child: InkWell(
// // // // // // // // //                 onTap: () => _openPaywall(context),
// // // // // // // // //                 child: LayoutBuilder(
// // // // // // // // //                   builder: (context, constraints) {
// // // // // // // // //                     return Center(
// // // // // // // // //                       child: Padding(
// // // // // // // // //                         padding: const EdgeInsets.all(12),
// // // // // // // // //                         child: ConstrainedBox(
// // // // // // // // //                           // ✅ 오버레이 카드 폭 제한(작은 폰/긴 언어 대응)
// // // // // // // // //                           constraints: BoxConstraints(
// // // // // // // // //                             maxWidth: constraints.maxWidth,
// // // // // // // // //                           ),
// // // // // // // // //                           // ✅ 오버플로우가 잦던 “Row+shadow 컨테이너”를 제거하고
// // // // // // // // //                           // ✅ 검증된 ProLockCard UI로 통일
// // // // // // // // //                           child: _buildProLockCard(
// // // // // // // // //                             context,
// // // // // // // // //                             ref,
// // // // // // // // //                             subtitleKey: (subtitle ?? "").isNotEmpty
// // // // // // // // //                                 ? subtitle!
// // // // // // // // //                                 : "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE",
// // // // // // // // //                             onTap: () => _openPaywall(context),
// // // // // // // // //                             compact: true, // ✅ 오버레이에서는 margin 제거
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                     );
// // // // // // // // //                   },
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Paywall 이동(공용 화면)
// // // // // // // // //   void _openPaywall(BuildContext context) {
// // // // // // // // //     Navigator.of(context).push(
// // // // // // // // //       MaterialPageRoute(builder: (_) => const PaywallScreen()),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
// // // // // // // // //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // // //       children: [
// // // // // // // // //         Expanded(
// // // // // // // // //           child: Text(
// // // // // // // // //             label,
// // // // // // // // //             maxLines: 1,
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             style: TextStyle(
// // // // // // // // //               fontSize: 14,
// // // // // // // // //               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
// // // // // // // // //               color: Colors.black87,
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //         const SizedBox(width: 10),
// // // // // // // // //         Text(
// // // // // // // // //           // 📍 국가별 통화 포맷 적용
// // // // // // // // //           fmt.format(amount),
// // // // // // // // //           maxLines: 1,
// // // // // // // // //           overflow: TextOverflow.ellipsis,
// // // // // // // // //           style: TextStyle(
// // // // // // // // //             fontSize: 16,
// // // // // // // // //             fontWeight: FontWeight.bold,
// // // // // // // // //             color: color,
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _buildSectionTitle(IconData icon, String title) {
// // // // // // // // //     return Row(
// // // // // // // // //       children: [
// // // // // // // // //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// // // // // // // // //         const SizedBox(width: 8),
// // // // // // // // //         Expanded(
// // // // // // // // //           child: Text(
// // // // // // // // //             title,
// // // // // // // // //             maxLines: 1,
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisSize: MainAxisSize.min,
// // // // // // // // //       mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // // //       crossAxisAlignment: CrossAxisAlignment.center,
// // // // // // // // //       children: [
// // // // // // // // //         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
// // // // // // // // //         const SizedBox(width: 6),
// // // // // // // // //         Flexible(
// // // // // // // // //           child: Text(
// // // // // // // // //             label,
// // // // // // // // //             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             textAlign: TextAlign.left,
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// // // // // // // // //     try {
// // // // // // // // //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // // // // // // //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // // // // // // //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // // // // // // //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // // // // // // //       final tempDir = await getTemporaryDirectory();
// // // // // // // // //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// // // // // // // // //       await file.writeAsBytes(pngBytes);
// // // // // // // // //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// // // // // // // // //     } catch (e) {
// // // // // // // // //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // //
// // // // // // // // //
// // // // // // // // // import 'dart:io';
// // // // // // // // // import 'dart:typed_data';
// // // // // // // // // import 'dart:ui' as ui;
// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:flutter/rendering.dart';
// // // // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // // // // import 'package:fl_chart/fl_chart.dart';
// // // // // // // // // import 'package:intl/intl.dart';
// // // // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // // // import '../../core/purchase/models/purchase_status.dart';
// // // // // // // // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
// // // // // // // // //
// // // // // // // // // // ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
// // // // // // // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // // // // // //
// // // // // // // // // import '../ledger/ledger_provider.dart';
// // // // // // // // // import '../ledger/unpaid_provider.dart';
// // // // // // // // // import 'excel_export_service.dart';
// // // // // // // // //
// // // // // // // // // // ✅ [추가] Pro 인사이트 서비스
// // // // // // // // // import 'financial_insight_service.dart';
// // // // // // // // //
// // // // // // // // // class ReportsScreen extends ConsumerWidget {
// // // // // // // // //   const ReportsScreen({super.key});
// // // // // // // // //
// // // // // // // // //   // 📍 이미지 캡처를 위한 GlobalKey
// // // // // // // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // // // // // // //
// // // // // // // // //   // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
// // // // // // // // //   // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
// // // // // // // // //   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
// // // // // // // // //
// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // // // // // //     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
// // // // // // // // //     final isPro = ref.watch(isProProvider);
// // // // // // // // //
// // // // // // // // //     // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
// // // // // // // // //     // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
// // // // // // // // //     // ignore: unused_local_variable
// // // // // // // // //     final purchaseState = ref.watch(purchaseControllerProvider);
// // // // // // // // //
// // // // // // // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // // // // // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // // // // // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // // // // // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // // // // // // //
// // // // // // // // //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// // // // // // // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // // // // // // //
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
// // // // // // // // //     // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
// // // // // // // // //     // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
// // // // // // // // //     //
// // // // // // // // //     // ✅ [중요]
// // // // // // // // //     // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
// // // // // // // // //     // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     ref.listen<bool>(isProProvider, (prev, next) {
// // // // // // // // //       // ✅ Pro → Free로 바뀌는 순간만 감지
// // // // // // // // //       if (prev == true && next == false) {
// // // // // // // // //         final alreadyShown = ref.read(_proDisabledToastShownProvider);
// // // // // // // // //         if (alreadyShown) return;
// // // // // // // // //
// // // // // // // // //         // ✅ 플래그 ON (연속 표시 방지)
// // // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = true;
// // // // // // // // //
// // // // // // // // //         // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
// // // // // // // // //         if (context.mounted) {
// // // // // // // // //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // //             SnackBar(
// // // // // // // // //               content: Text("REPORT_PRO_DISABLED_BY_REFUND".tr(ref)),
// // // // // // // // //               behavior: SnackBarBehavior.floating,
// // // // // // // // //             ),
// // // // // // // // //           );
// // // // // // // // //         }
// // // // // // // // //       }
// // // // // // // // //
// // // // // // // // //       // ✅ Free → Pro로 복구되면(재구매/복원 등)
// // // // // // // // //       // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
// // // // // // // // //       if (prev == false && next == true) {
// // // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = false;
// // // // // // // // //       }
// // // // // // // // //     });
// // // // // // // // //
// // // // // // // // //     // ✅ [변경] Reports 전체를 Paywall로 막지 않습니다.
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //     // 기존 방식:
// // // // // // // // //     // if (!isPro) return const PaywallScreen();
// // // // // // // // //     //
// // // // // // // // //     // 현재 방식(요청 반영):
// // // // // // // // //     // - 보고서 전체 : 타이틀 + 기본 그래프 → Free
// // // // // // // // //     // - 해석/비교/경고 : 블러 + Pro 카드 (① + ③)
// // // // // // // // //     // - 엑셀/공유 : 클릭 시 Paywall (②)
// // // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // // //
// // // // // // // // //     return Scaffold(
// // // // // // // // //       backgroundColor: Colors.grey[100],
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // // // // // //         foregroundColor: Colors.white,
// // // // // // // // //         elevation: 0,
// // // // // // // // //         scrolledUnderElevation: 0,
// // // // // // // // //         automaticallyImplyLeading: false,
// // // // // // // // //         centerTitle: false,
// // // // // // // // //         title: Text(
// // // // // // // // //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // // // // // // // //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // //         child: Column(
// // // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //           children: [
// // // // // // // // //             // ✅ [고도화 1단계] 요약 및 경고(데이터 → 해석 → 경고) : Pro 구매 가치 제공
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             // ✅ 요청 반영:
// // // // // // // // //             // - Free: 섹션은 보여주되(타이틀 노출), 내용은 잠금 카드로 대체
// // // // // // // // //             // - Pro: 실제 인사이트 + 리스크 점수(0~100) + 원인 Top3 표시
// // // // // // // // //             //
// // // // // // // // //             // ✅ [중요] 오버플로우 방지:
// // // // // // // // //             // - 긴 다국어/작은 기기에서 버튼/텍스트가 줄바꿈/넘침 방지
// // // // // // // // //             // - FittedBox(scaleDown)로 "..." 없이 자동 축소가 필요한 곳에 적용
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             monthlyTrendAsync.when(
// // // // // // // // //               loading: () => const SizedBox.shrink(),
// // // // // // // // //               error: (_, __) => const SizedBox.shrink(),
// // // // // // // // //               data: (trendData) {
// // // // // // // // //                 return unpaidAsync.when(
// // // // // // // // //                   loading: () => const SizedBox.shrink(),
// // // // // // // // //                   error: (_, __) => const SizedBox.shrink(),
// // // // // // // // //                   data: (unpaidList) {
// // // // // // // // //                     int thisMonthIncome = 0;
// // // // // // // // //                     int thisMonthExpense = 0;
// // // // // // // // //                     int lastMonthExpense = 0;
// // // // // // // // //
// // // // // // // // //                     final now = DateTime.now();
// // // // // // // // //
// // // // // // // // //                     // ✅ 이번 달 데이터
// // // // // // // // //                     final thisMonthItem = trendData
// // // // // // // // //                         .where((e) => e.month.year == now.year && e.month.month == now.month)
// // // // // // // // //                         .toList();
// // // // // // // // //                     if (thisMonthItem.isNotEmpty) {
// // // // // // // // //                       thisMonthIncome = thisMonthItem.first.income;
// // // // // // // // //                       thisMonthExpense = thisMonthItem.first.expense;
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ 지난 달 데이터
// // // // // // // // //                     final last = DateTime(now.year, now.month - 1, 1);
// // // // // // // // //                     final lastMonthItem = trendData
// // // // // // // // //                         .where((e) => e.month.year == last.year && e.month.month == last.month)
// // // // // // // // //                         .toList();
// // // // // // // // //                     if (lastMonthItem.isNotEmpty) {
// // // // // // // // //                       lastMonthExpense = lastMonthItem.first.expense;
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ 미납 여부
// // // // // // // // //                     final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                     final hasUnpaid = overdue.isNotEmpty;
// // // // // // // // //                     final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // // // // //
// // // // // // // // //                     final insights = FinancialInsightService.generate(
// // // // // // // // //                       thisMonthIncome: thisMonthIncome,
// // // // // // // // //                       thisMonthExpense: thisMonthExpense,
// // // // // // // // //                       lastMonthExpense: lastMonthExpense,
// // // // // // // // //                       hasUnpaid: hasUnpaid,
// // // // // // // // //                     );
// // // // // // // // //
// // // // // // // // //                     // ✅ 인사이트가 없으면 섹션 자체를 숨겨도 되고,
// // // // // // // // //                     // 안정 메시지를 서비스에서 항상 1개라도 반환하게 해도 됨.
// // // // // // // // //                     if (insights.isEmpty) return const SizedBox.shrink();
// // // // // // // // //
// // // // // // // // //                     // ✅ [고도화] 리스크 점수 + 원인 Top3 계산 (Pro에서만 노출)
// // // // // // // // //                     final risk = _computeRiskSummary(
// // // // // // // // //                       thisMonthIncome: thisMonthIncome,
// // // // // // // // //                       thisMonthExpense: thisMonthExpense,
// // // // // // // // //                       lastMonthExpense: lastMonthExpense,
// // // // // // // // //                       overdueCount: overdue.length,
// // // // // // // // //                       totalOverdueAmount: totalOverdueAmount,
// // // // // // // // //                     );
// // // // // // // // //
// // // // // // // // //                     final insightList = Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //
// // // // // // // // //                         // ✅ [고도화] Pro에서만 "리스크 점수 카드" 노출
// // // // // // // // //                         if (isPro) ...[
// // // // // // // // //                           _buildRiskSummaryCard(ref, currencyFmt, risk),
// // // // // // // // //                           const SizedBox(height: 10),
// // // // // // // // //                         ],
// // // // // // // // //
// // // // // // // // //                         ...insights.map((i) => _buildInsightCard(ref, i)).toList(),
// // // // // // // // //                         const SizedBox(height: 20),
// // // // // // // // //                       ],
// // // // // // // // //                     );
// // // // // // // // //
// // // // // // // // //                     if (!isPro) {
// // // // // // // // //                       return Column(
// // // // // // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                         children: [
// // // // // // // // //                           _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // // //                           const SizedBox(height: 10),
// // // // // // // // //                           _buildProLockCard(
// // // // // // // // //                             context,
// // // // // // // // //                             ref,
// // // // // // // // //                             subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE",
// // // // // // // // //                             onTap: () => _openPaywall(context),
// // // // // // // // //                           ),
// // // // // // // // //                           const SizedBox(height: 20),
// // // // // // // // //                         ],
// // // // // // // // //                       );
// // // // // // // // //                     }
// // // // // // // // //
// // // // // // // // //                     // ✅ Pro면 정상 표시
// // // // // // // // //                     return insightList;
// // // // // // // // //                   },
// // // // // // // // //                 );
// // // // // // // // //               },
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             // 📍 1. Financial Analytics 섹션
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             // ✅ 요청 반영:
// // // // // // // // //             // - "기본 그래프"는 Free로 그대로 노출
// // // // // // // // //             // - (추가 고도화) 그래프 해석/비교 문구를 만들면 그 부분만 블러 처리 권장
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               height: 320,
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Row(
// // // // // // // // //                 children: [
// // // // // // // // //                   Expanded(
// // // // // // // // //                     flex: 3,
// // // // // // // // //                     child: Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
// // // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // // //                         const SizedBox(height: 25),
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: monthlyTrendAsync.when(
// // // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // // //                             data: (data) => BarChart(
// // // // // // // // //                               BarChartData(
// // // // // // // // //                                 barTouchData: BarTouchData(
// // // // // // // // //                                   enabled: false,
// // // // // // // // //                                   touchTooltipData: BarTouchTooltipData(
// // // // // // // // //                                     tooltipBgColor: Colors.transparent,
// // // // // // // // //                                     tooltipPadding: EdgeInsets.zero,
// // // // // // // // //                                     tooltipMargin: 4,
// // // // // // // // //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// // // // // // // // //                                       if (rod.toY == 0) return null;
// // // // // // // // //                                       return BarTooltipItem(
// // // // // // // // //                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
// // // // // // // // //                                         currencyFmt.format(rod.toY),
// // // // // // // // //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// // // // // // // // //                                       );
// // // // // // // // //                                     },
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                                 barGroups: data.asMap().entries.map((e) {
// // // // // // // // //                                   final List<int> indicators = [];
// // // // // // // // //                                   if (e.value.income > 0) indicators.add(0);
// // // // // // // // //                                   if (e.value.expense > 0) indicators.add(1);
// // // // // // // // //
// // // // // // // // //                                   return BarChartGroupData(
// // // // // // // // //                                     x: e.key,
// // // // // // // // //                                     barsSpace: 4,
// // // // // // // // //                                     showingTooltipIndicators: indicators,
// // // // // // // // //                                     barRods: [
// // // // // // // // //                                       BarChartRodData(
// // // // // // // // //                                         toY: e.value.income.toDouble(),
// // // // // // // // //                                         color: Colors.blue,
// // // // // // // // //                                         width: 8,
// // // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // // //                                       ),
// // // // // // // // //                                       BarChartRodData(
// // // // // // // // //                                         toY: e.value.expense.toDouble(),
// // // // // // // // //                                         color: Colors.redAccent,
// // // // // // // // //                                         width: 8,
// // // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ],
// // // // // // // // //                                   );
// // // // // // // // //                                 }).toList(),
// // // // // // // // //                                 titlesData: FlTitlesData(
// // // // // // // // //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // // //                                   bottomTitles: AxisTitles(
// // // // // // // // //                                     sideTitles: SideTitles(
// // // // // // // // //                                       showTitles: true,
// // // // // // // // //                                       getTitlesWidget: (value, meta) {
// // // // // // // // //                                         int index = value.toInt();
// // // // // // // // //                                         if (index >= 0 && index < data.length) {
// // // // // // // // //                                           return Padding(
// // // // // // // // //                                             padding: const EdgeInsets.only(top: 8.0),
// // // // // // // // //                                             child: Text(
// // // // // // // // //                                               DateFormat.MMM(lang).format(data[index].month),
// // // // // // // // //                                               style: const TextStyle(fontSize: 9),
// // // // // // // // //                                             ),
// // // // // // // // //                                           );
// // // // // // // // //                                         }
// // // // // // // // //                                         return const Text('');
// // // // // // // // //                                       },
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                                 gridData: const FlGridData(show: false),
// // // // // // // // //                                 borderData: FlBorderData(show: false),
// // // // // // // // //                               ),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(height: 12),
// // // // // // // // //                         Row(
// // // // // // // // //                           mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // // //                           children: [
// // // // // // // // //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // // // // // // // //                             const SizedBox(width: 12),
// // // // // // // // //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// // // // // // // // //                           ],
// // // // // // // // //                         )
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(width: 12),
// // // // // // // // //                   // 📍 연간 지출 차트 섹션
// // // // // // // // //                   Expanded(
// // // // // // // // //                     flex: 2,
// // // // // // // // //                     child: Column(
// // // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                       children: [
// // // // // // // // //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
// // // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: categoryStatsAsync.when(
// // // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // // //                             data: (data) {
// // // // // // // // //                               if (data.isEmpty) {
// // // // // // // // //                                 return Center(
// // // // // // // // //                                     child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// // // // // // // // //                               }
// // // // // // // // //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // // // // // // //
// // // // // // // // //                               return Column(
// // // // // // // // //                                 children: [
// // // // // // // // //                                   Expanded(
// // // // // // // // //                                     flex: 3,
// // // // // // // // //                                     child: PieChart(
// // // // // // // // //                                       PieChartData(
// // // // // // // // //                                         sectionsSpace: 2,
// // // // // // // // //                                         centerSpaceRadius: 10,
// // // // // // // // //                                         sections: data.asMap().entries.map((entry) {
// // // // // // // // //                                           final double pctValue = entry.value.percentage * 100;
// // // // // // // // //                                           final String percentageStr = pctValue.toStringAsFixed(0);
// // // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // // //                                               : entry.value.category;
// // // // // // // // //
// // // // // // // // //                                           final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';
// // // // // // // // //
// // // // // // // // //                                           return PieChartSectionData(
// // // // // // // // //                                             value: entry.value.amount.toDouble(),
// // // // // // // // //                                             title: sectionTitle,
// // // // // // // // //                                             titleStyle: const TextStyle(
// // // // // // // // //                                               fontSize: 7,
// // // // // // // // //                                               fontWeight: FontWeight.bold,
// // // // // // // // //                                               color: Colors.white,
// // // // // // // // //                                               height: 1.2,
// // // // // // // // //                                             ),
// // // // // // // // //                                             color: colors[entry.key % colors.length],
// // // // // // // // //                                             radius: 40,
// // // // // // // // //                                           );
// // // // // // // // //                                         }).toList(),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                   const SizedBox(height: 12),
// // // // // // // // //                                   Expanded(
// // // // // // // // //                                     flex: 3,
// // // // // // // // //                                     child: SingleChildScrollView(
// // // // // // // // //                                       child: Column(
// // // // // // // // //                                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                                         children: data.asMap().entries.map((entry) {
// // // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // // //                                               : entry.value.category;
// // // // // // // // //                                           return Padding(
// // // // // // // // //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// // // // // // // // //                                             child: _buildLegend(
// // // // // // // // //                                               colors[entry.key % colors.length],
// // // // // // // // //                                               // 📍 [수정] 범례 금액 다국어 포맷 적용
// // // // // // // // //                                               "$categoryName (${currencyFmt.format(entry.value.amount)})",
// // // // // // // // //                                               fontSize: 9,
// // // // // // // // //                                             ),
// // // // // // // // //                                           );
// // // // // // // // //                                         }).toList(),
// // // // // // // // //                                       ),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ],
// // // // // // // // //                               );
// // // // // // // // //                             },
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 2. Tax Data Management 섹션
// // // // // // // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Column(
// // // // // // // // //                 children: [
// // // // // // // // //                   Container(
// // // // // // // // //                     padding: const EdgeInsets.all(12),
// // // // // // // // //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                     child: Row(
// // // // // // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // // //                       children: [
// // // // // // // // //                         // ✅ [수정] "..." 없이 자동 축소되도록 FittedBox 적용 (긴 다국어 대응)
// // // // // // // // //                         Expanded(
// // // // // // // // //                           child: FittedBox(
// // // // // // // // //                             fit: BoxFit.scaleDown,
// // // // // // // // //                             alignment: Alignment.centerLeft,
// // // // // // // // //                             child: Text(
// // // // // // // // //                               "${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}",
// // // // // // // // //                               maxLines: 1,
// // // // // // // // //                               softWrap: false,
// // // // // // // // //                               overflow: TextOverflow.visible,
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(width: 10),
// // // // // // // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// // // // // // // // //                       ],
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(height: 20),
// // // // // // // // //                   SizedBox(
// // // // // // // // //                     width: double.infinity,
// // // // // // // // //                     child: ElevatedButton.icon(
// // // // // // // // //                       style: ElevatedButton.styleFrom(
// // // // // // // // //                         backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                         foregroundColor: Colors.white,
// // // // // // // // //                         // ✅ [수정] 버튼 텍스트가 길어도 한 줄 유지 + 자동 축소되도록
// // // // // // // // //                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
// // // // // // // // //                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                         visualDensity: VisualDensity.compact,
// // // // // // // // //                         minimumSize: const Size(0, 46),
// // // // // // // // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                       ),
// // // // // // // // //                       onPressed: () async {
// // // // // // // // //                         // -------------------------------------------------------------------------
// // // // // // // // //                         // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                         // -------------------------------------------------------------------------
// // // // // // // // //                         if (!isPro) {
// // // // // // // // //                           _openPaywall(context);
// // // // // // // // //                           return;
// // // // // // // // //                         }
// // // // // // // // //
// // // // // // // // //                         final transactions = await ref.read(ledgerListProvider.future);
// // // // // // // // //                         if (transactions.isEmpty) return;
// // // // // // // // //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// // // // // // // // //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// // // // // // // // //                       },
// // // // // // // // //                       icon: const Icon(Icons.file_download, size: 18),
// // // // // // // // //                       label: FittedBox(
// // // // // // // // //                         fit: BoxFit.scaleDown,
// // // // // // // // //                         child: Text("REPORT_BTN_TAX_EXCEL".tr(ref), maxLines: 1, softWrap: false,
// // // // // // // // //                             style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                       ),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 3. Unpaid Management 섹션
// // // // // // // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             Container(
// // // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Column(
// // // // // // // // //                 children: [
// // // // // // // // //                   RepaintBoundary(
// // // // // // // // //                     key: _unpaidCaptureKey,
// // // // // // // // //                     child: Container(
// // // // // // // // //                       width: double.infinity,
// // // // // // // // //                       padding: const EdgeInsets.all(12),
// // // // // // // // //                       decoration: BoxDecoration(
// // // // // // // // //                         color: Colors.white,
// // // // // // // // //                         border: Border.all(color: Colors.grey.shade300),
// // // // // // // // //                         borderRadius: BorderRadius.circular(8),
// // // // // // // // //                       ),
// // // // // // // // //                       child: unpaidAsync.when(
// // // // // // // // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// // // // // // // // //                         data: (list) {
// // // // // // // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // // // // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // // // // // // //                           return Column(
// // // // // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                             children: [
// // // // // // // // //                               // ✅ [수정] 긴 문장 다국어에서도 "..." 최소화 (필요 시 자동 축소)
// // // // // // // // //                               FittedBox(
// // // // // // // // //                                 fit: BoxFit.scaleDown,
// // // // // // // // //                                 alignment: Alignment.centerLeft,
// // // // // // // // //                                 child: Text(
// // // // // // // // //                                   // 📍 [수정] 미납 총액 다국어 포맷 적용
// // // // // // // // //                                   "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// // // // // // // // //                                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// // // // // // // // //                                   maxLines: 1,
// // // // // // // // //                                   softWrap: false,
// // // // // // // // //                                   overflow: TextOverflow.visible,
// // // // // // // // //                                 ),
// // // // // // // // //                               ),
// // // // // // // // //                               const SizedBox(height: 8),
// // // // // // // // //                               ...overdue.take(5).map(
// // // // // // // // //                                     (u) => Padding(
// // // // // // // // //                                   padding: const EdgeInsets.symmetric(vertical: 2),
// // // // // // // // //                                   // 📍 [수정] 개별 미납액 다국어 포맷 적용
// // // // // // // // //                                   child: Text(
// // // // // // // // //                                     "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? 'COMMON_ANONYMOUS'.tr(ref)}): ${currencyFmt.format(u.unit.monthlyRent)}",
// // // // // // // // //                                     style: const TextStyle(fontSize: 12, color: Colors.black87),
// // // // // // // // //                                   ),
// // // // // // // // //                                 ),
// // // // // // // // //                               ),
// // // // // // // // //                             ],
// // // // // // // // //                           );
// // // // // // // // //                         },
// // // // // // // // //                       ),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                   const SizedBox(height: 20),
// // // // // // // // //
// // // // // // // // //                   // ✅ [수정] 두 버튼이 한 줄에 안정적으로 표시되도록:
// // // // // // // // //                   // - 내부 padding/아이콘 축소
// // // // // // // // //                   // - visualDensity/tapTargetSize 조정
// // // // // // // // //                   // - label에 FittedBox(scaleDown) 적용(“...” 없이 자동 축소)
// // // // // // // // //                   Row(
// // // // // // // // //                     children: [
// // // // // // // // //                       Expanded(
// // // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // // //                             backgroundColor: const Color(0xFF4CAF50),
// // // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // // //
// // // // // // // // //                             // ✅ [수정] 세로 패딩을 약간 줄이고, 가로 패딩을 명시해 공간 확보
// // // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
// // // // // // // // //
// // // // // // // // //                             // ✅ [수정] 터치 영역/밀도 조정(작은 기기에서도 줄바꿈 완화)
// // // // // // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                             visualDensity: VisualDensity.compact,
// // // // // // // // //                             minimumSize: const Size(0, 44),
// // // // // // // // //
// // // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                           ),
// // // // // // // // //                           onPressed: () async {
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             if (!isPro) {
// // // // // // // // //                               _openPaywall(context);
// // // // // // // // //                               return;
// // // // // // // // //                             }
// // // // // // // // //
// // // // // // // // //                             final list = await ref.read(unpaidListProvider.future);
// // // // // // // // //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // // //                             if (overdue.isEmpty) return;
// // // // // // // // //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // // // // // // // //                           },
// // // // // // // // //
// // // // // // // // //                           // ✅ [수정] 아이콘 조금 축소 + 간격 축소(가로 공간 확보)
// // // // // // // // //                           icon: const Icon(Icons.file_download, size: 18),
// // // // // // // // //                           label: FittedBox(
// // // // // // // // //                             fit: BoxFit.scaleDown, // ✅ 핵심: 한 줄 유지 + 자동 축소
// // // // // // // // //                             child: Text(
// // // // // // // // //                               "REPORT_BTN_UNPAID_EXCEL".tr(ref),
// // // // // // // // //                               maxLines: 1,
// // // // // // // // //                               softWrap: false,
// // // // // // // // //                               overflow: TextOverflow.visible,
// // // // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                       const SizedBox(width: 10),
// // // // // // // // //                       Expanded(
// // // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // // //                             backgroundColor: Colors.orangeAccent,
// // // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // // //
// // // // // // // // //                             // ✅ [수정] 동일하게 적용
// // // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
// // // // // // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                             visualDensity: VisualDensity.compact,
// // // // // // // // //                             minimumSize: const Size(0, 44),
// // // // // // // // //
// // // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // // //                           ),
// // // // // // // // //                           onPressed: () {
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             // ✅ 요청 반영 (②) : 엑셀/공유는 클릭 시 Paywall
// // // // // // // // //                             // -------------------------------------------------------------------------
// // // // // // // // //                             if (!isPro) {
// // // // // // // // //                               _openPaywall(context);
// // // // // // // // //                               return;
// // // // // // // // //                             }
// // // // // // // // //                             _captureAndShareImage(context, ref);
// // // // // // // // //                           },
// // // // // // // // //
// // // // // // // // //                           // ✅ [수정] 아이콘 조금 축소 + 간격 축소
// // // // // // // // //                           icon: const Icon(Icons.share_outlined, size: 18),
// // // // // // // // //                           label: FittedBox(
// // // // // // // // //                             fit: BoxFit.scaleDown, // ✅ 핵심: 한 줄 유지 + 자동 축소
// // // // // // // // //                             child: Text(
// // // // // // // // //                               "REPORT_BTN_UNPAID_IMAGE".tr(ref),
// // // // // // // // //                               maxLines: 1,
// // // // // // // // //                               softWrap: false,
// // // // // // // // //                               overflow: TextOverflow.visible,
// // // // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // // // // //                             ),
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                     ],
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 30),
// // // // // // // // //
// // // // // // // // //             // 📍 4. Annual Summary
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             // ✅ 요청 반영:
// // // // // // // // //             // - 숫자 요약은 "해석/판단" 성격이 강하므로 Pro로 두는 편이 가격 설득에 유리
// // // // // // // // //             // - Free에선 섹션 타이틀 노출 + 내용 블러(클릭 시 Paywall)
// // // // // // // // //             //
// // // // // // // // //             // ✅ [중요] 오버플로우 방지:
// // // // // // // // //             // - 잠금 오버레이 카드가 "센터 고정(Row)"이면 작은 기기에서 overflow 발생
// // // // // // // // //             // - 오버레이는 "세로(Column) + 버튼 아래" 형태로 구성하여 안정화
// // // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // // // // // // //             const SizedBox(height: 10),
// // // // // // // // //             monthlyTrendAsync.when(
// // // // // // // // //               loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // // //               error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// // // // // // // // //               data: (trend) {
// // // // // // // // //                 final annualCard = Container(
// // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // //                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // // //                   child: () {
// // // // // // // // //                     final int currentYear = DateTime.now().year;
// // // // // // // // //                     final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// // // // // // // // //
// // // // // // // // //                     int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// // // // // // // // //                     int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// // // // // // // // //                     int yearlyProfit = yearlyIncome - yearlyExpense;
// // // // // // // // //
// // // // // // // // //                     return Column(
// // // // // // // // //                       children: [
// // // // // // // // //                         Row(
// // // // // // // // //                           mainAxisAlignment: MainAxisAlignment.end,
// // // // // // // // //                           children: [
// // // // // // // // //                             Text(
// // // // // // // // //                               "${'COMMON_YEAR'.tr(ref)}: $currentYear",
// // // // // // // // //                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
// // // // // // // // //                             ),
// // // // // // // // //                           ],
// // // // // // // // //                         ),
// // // // // // // // //                         const SizedBox(height: 10),
// // // // // // // // //                         // 📍 [수정] 요약 금액들 다국어 포맷 적용
// // // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// // // // // // // // //                         const Divider(height: 20),
// // // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// // // // // // // // //                         const Divider(height: 20),
// // // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// // // // // // // // //                         const SizedBox(height: 15),
// // // // // // // // //                         Text(
// // // // // // // // //                           "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// // // // // // // // //                           style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// // // // // // // // //                         )
// // // // // // // // //                       ],
// // // // // // // // //                     );
// // // // // // // // //                   }(),
// // // // // // // // //                 );
// // // // // // // // //
// // // // // // // // //                 // ✅ Free 사용자: 블러+오버레이 대신 "잠금 카드로 대체"
// // // // // // // // //                 if (!isPro) {
// // // // // // // // //                   return _buildProLockCard(
// // // // // // // // //                     context,
// // // // // // // // //                     ref,
// // // // // // // // //                     subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE",
// // // // // // // // //                     onTap: () => _openPaywall(context),
// // // // // // // // //                   );
// // // // // // // // //                 }
// // // // // // // // //
// // // // // // // // //                 // ✅ Pro 사용자: 실제 annualCard
// // // // // // // // //                 return annualCard;
// // // // // // // // //               },
// // // // // // // // //             ),
// // // // // // // // //
// // // // // // // // //             const SizedBox(height: 50),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [고도화 1단계] 리스크 점수 + 원인 Top3 계산
// // // // // // // // //   // - 화면이 “숫자 나열”이 아니라 “진단/경고”로 보이게 만드는 핵심 로직
// // // // // // // // //   // - 이 로직은 ReportsScreen 안에서 완결되게 두었고(추가 파일 없이),
// // // // // // // // //   //   원하시면 다음 단계에서 서비스로 분리할 수 있습니다.
// // // // // // // // //   _RiskSummary _computeRiskSummary({
// // // // // // // // //     required int thisMonthIncome,
// // // // // // // // //     required int thisMonthExpense,
// // // // // // // // //     required int lastMonthExpense,
// // // // // // // // //     required int overdueCount,
// // // // // // // // //     required int totalOverdueAmount,
// // // // // // // // //   }) {
// // // // // // // // //     final List<String> reasons = [];
// // // // // // // // //
// // // // // // // // //     // 1) 적자 여부
// // // // // // // // //     final int balance = thisMonthIncome - thisMonthExpense;
// // // // // // // // //     if (balance < 0) {
// // // // // // // // //       reasons.add("REPORT_RISK_REASON_DEFICIT"); // "이번 달 적자 상태입니다"
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 2) 수입 0
// // // // // // // // //     if (thisMonthIncome <= 0 && thisMonthExpense > 0) {
// // // // // // // // //       reasons.add("REPORT_RISK_REASON_NO_INCOME"); // "수입이 없는데 지출이 발생했습니다"
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 3) 지출 급증(지난달 대비)
// // // // // // // // //     double growthRate = 0;
// // // // // // // // //     if (lastMonthExpense > 0) {
// // // // // // // // //       growthRate = (thisMonthExpense - lastMonthExpense) / lastMonthExpense;
// // // // // // // // //       if (growthRate >= 0.30) {
// // // // // // // // //         reasons.add("REPORT_RISK_REASON_SPEND_SPIKE"); // "지출이 지난달 대비 크게 증가했습니다"
// // // // // // // // //       } else if (growthRate >= 0.15) {
// // // // // // // // //         reasons.add("REPORT_RISK_REASON_SPEND_UP"); // "지출이 지난달 대비 증가했습니다"
// // // // // // // // //       }
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 4) 미납
// // // // // // // // //     if (overdueCount > 0) {
// // // // // // // // //       reasons.add("REPORT_RISK_REASON_OVERDUE"); // "미납이 존재합니다"
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 점수화(0~100)
// // // // // // // // //     int score = 0;
// // // // // // // // //
// // // // // // // // //     // 적자: 35
// // // // // // // // //     if (balance < 0) score += 35;
// // // // // // // // //
// // // // // // // // //     // 수입 0 + 지출: 25
// // // // // // // // //     if (thisMonthIncome <= 0 && thisMonthExpense > 0) score += 25;
// // // // // // // // //
// // // // // // // // //     // 지출 증가: 10~20
// // // // // // // // //     if (growthRate >= 0.30) {
// // // // // // // // //       score += 20;
// // // // // // // // //     } else if (growthRate >= 0.15) {
// // // // // // // // //       score += 10;
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 미납: 건수/총액에 따라 10~35
// // // // // // // // //     if (overdueCount > 0) {
// // // // // // // // //       score += 10;
// // // // // // // // //       if (overdueCount >= 3) score += 10;
// // // // // // // // //       if (totalOverdueAmount > 0) score += 15;
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     if (score > 100) score = 100;
// // // // // // // // //
// // // // // // // // //     // 등급
// // // // // // // // //     final _RiskLevel level = score >= 70
// // // // // // // // //         ? _RiskLevel.high
// // // // // // // // //         : score >= 40
// // // // // // // // //         ? _RiskLevel.mid
// // // // // // // // //         : _RiskLevel.low;
// // // // // // // // //
// // // // // // // // //     // Top3만
// // // // // // // // //     final top3 = reasons.take(3).toList();
// // // // // // // // //
// // // // // // // // //     return _RiskSummary(
// // // // // // // // //       score: score,
// // // // // // // // //       level: level,
// // // // // // // // //       reasons: top3,
// // // // // // // // //       balance: balance,
// // // // // // // // //       growthRate: growthRate,
// // // // // // // // //       overdueCount: overdueCount,
// // // // // // // // //       totalOverdueAmount: totalOverdueAmount,
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [고도화 1단계] 리스크 요약 카드 UI (Pro에서만 노출)
// // // // // // // // //   // - 긴 문장/다국어에서도 “...” 없이 자동 축소되는 영역은 FittedBox 적용
// // // // // // // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk) {
// // // // // // // // //     final Color color = switch (risk.level) {
// // // // // // // // //       _RiskLevel.low => Colors.blueGrey,
// // // // // // // // //       _RiskLevel.mid => Colors.orange,
// // // // // // // // //       _RiskLevel.high => Colors.redAccent,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     final IconData icon = switch (risk.level) {
// // // // // // // // //       _RiskLevel.low => Icons.shield_outlined,
// // // // // // // // //       _RiskLevel.mid => Icons.warning_amber_rounded,
// // // // // // // // //       _RiskLevel.high => Icons.report_gmailerrorred_outlined,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     return Container(
// // // // // // // // //       width: double.infinity,
// // // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: color.withOpacity(0.06),
// // // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // // //         border: Border.all(color: color.withOpacity(0.22)),
// // // // // // // // //       ),
// // // // // // // // //       child: Column(
// // // // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //         children: [
// // // // // // // // //           // 상단: 아이콘 + "리스크 점수"
// // // // // // // // //           Row(
// // // // // // // // //             children: [
// // // // // // // // //               Icon(icon, color: color, size: 18),
// // // // // // // // //               const SizedBox(width: 8),
// // // // // // // // //               Expanded(
// // // // // // // // //                 child: FittedBox(
// // // // // // // // //                   fit: BoxFit.scaleDown,
// // // // // // // // //                   alignment: Alignment.centerLeft,
// // // // // // // // //                   child: Text(
// // // // // // // // //                     "${'REPORT_RISK_TITLE'.tr(ref)}  ${risk.score}/100",
// // // // // // // // //                     maxLines: 1,
// // // // // // // // //                     softWrap: false,
// // // // // // // // //                     overflow: TextOverflow.visible,
// // // // // // // // //                     style: TextStyle(
// // // // // // // // //                       fontSize: 14,
// // // // // // // // //                       fontWeight: FontWeight.bold,
// // // // // // // // //                       color: color,
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ],
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 8),
// // // // // // // // //
// // // // // // // // //           // 핵심 요약: 잔액/미납/증감
// // // // // // // // //           Wrap(
// // // // // // // // //             spacing: 10,
// // // // // // // // //             runSpacing: 6,
// // // // // // // // //             children: [
// // // // // // // // //               _chipText(
// // // // // // // // //                 ref,
// // // // // // // // //                 color,
// // // // // // // // //                 "${'COMMON_BALANCE'.tr(ref)}: ${currencyFmt.format(risk.balance)}",
// // // // // // // // //               ),
// // // // // // // // //               _chipText(
// // // // // // // // //                 ref,
// // // // // // // // //                 color,
// // // // // // // // //                 "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${risk.overdueCount}",
// // // // // // // // //               ),
// // // // // // // // //               if (risk.growthRate != 0)
// // // // // // // // //                 _chipText(
// // // // // // // // //                   ref,
// // // // // // // // //                   color,
// // // // // // // // //                   "${'REPORT_SPEND_CHANGE'.tr(ref)}: ${(risk.growthRate * 100).toStringAsFixed(0)}%",
// // // // // // // // //                 ),
// // // // // // // // //             ],
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 8),
// // // // // // // // //
// // // // // // // // //           // 원인 Top3
// // // // // // // // //           ...risk.reasons.map((k) {
// // // // // // // // //             return Padding(
// // // // // // // // //               padding: const EdgeInsets.only(top: 4),
// // // // // // // // //               child: Row(
// // // // // // // // //                 children: [
// // // // // // // // //                   Icon(Icons.circle, size: 6, color: color.withOpacity(0.9)),
// // // // // // // // //                   const SizedBox(width: 8),
// // // // // // // // //                   Expanded(
// // // // // // // // //                     child: Text(
// // // // // // // // //                       k.tr(ref),
// // // // // // // // //                       style: const TextStyle(fontSize: 12, height: 1.25, color: Colors.black87),
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ],
// // // // // // // // //               ),
// // // // // // // // //             );
// // // // // // // // //           }).toList(),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _chipText(WidgetRef ref, Color color, String text) {
// // // // // // // // //     return Container(
// // // // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: Colors.white,
// // // // // // // // //         borderRadius: BorderRadius.circular(999),
// // // // // // // // //         border: Border.all(color: color.withOpacity(0.18)),
// // // // // // // // //       ),
// // // // // // // // //       child: FittedBox(
// // // // // // // // //         fit: BoxFit.scaleDown,
// // // // // // // // //         child: Text(
// // // // // // // // //           text,
// // // // // // // // //           maxLines: 1,
// // // // // // // // //           softWrap: false,
// // // // // // // // //           overflow: TextOverflow.visible,
// // // // // // // // //           style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w600),
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 인사이트 카드 UI
// // // // // // // // //   // - 다국어는 messageKey.tr(ref)로 처리
// // // // // // // // //   // - 레벨별 색상/아이콘을 다르게 표시
// // // // // // // // //   Widget _buildInsightCard(WidgetRef ref, FinancialInsight insight) {
// // // // // // // // //     final Color color = switch (insight.level) {
// // // // // // // // //       InsightLevel.info => Colors.blueGrey,
// // // // // // // // //       InsightLevel.warning => Colors.orange,
// // // // // // // // //       InsightLevel.alert => Colors.redAccent,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     final IconData icon = switch (insight.level) {
// // // // // // // // //       InsightLevel.info => Icons.info_outline,
// // // // // // // // //       InsightLevel.warning => Icons.warning_amber_rounded,
// // // // // // // // //       InsightLevel.alert => Icons.report_gmailerrorred_outlined,
// // // // // // // // //     };
// // // // // // // // //
// // // // // // // // //     return Container(
// // // // // // // // //       width: double.infinity,
// // // // // // // // //       margin: const EdgeInsets.only(bottom: 8),
// // // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: color.withOpacity(0.08),
// // // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // // //         border: Border.all(color: color.withOpacity(0.25)),
// // // // // // // // //       ),
// // // // // // // // //       child: Row(
// // // // // // // // //         children: [
// // // // // // // // //           Icon(icon, color: color, size: 18),
// // // // // // // // //           const SizedBox(width: 8),
// // // // // // // // //           Expanded(
// // // // // // // // //             child: Text(
// // // // // // // // //               insight.messageKey.tr(ref),
// // // // // // // // //               style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black87),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 잠금 카드(오버플로우 방지 버전)
// // // // // // // // //   // - compact=true 이면 오버레이에서 쓸 때 margin 제거
// // // // // // // // //   Widget _buildProLockCard(
// // // // // // // // //       BuildContext context,
// // // // // // // // //       WidgetRef ref, {
// // // // // // // // //         required String subtitleKey,
// // // // // // // // //         required VoidCallback onTap,
// // // // // // // // //         bool compact = false, // ✅ 추가
// // // // // // // // //       }) {
// // // // // // // // //     return Container(
// // // // // // // // //       width: double.infinity,
// // // // // // // // //       margin: compact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12), // ✅ 변경
// // // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // // //       decoration: BoxDecoration(
// // // // // // // // //         color: Colors.white,
// // // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // // //         border: Border.all(color: Colors.grey.shade300),
// // // // // // // // //       ),
// // // // // // // // //       child: Column(
// // // // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //         children: [
// // // // // // // // //           // ✅ 1) 상단: 아이콘 + 타이틀(한 줄)
// // // // // // // // //           Row(
// // // // // // // // //             children: [
// // // // // // // // //               const Icon(Icons.lock_outline, color: Color(0xFF1A237E), size: 18),
// // // // // // // // //               const SizedBox(width: 10),
// // // // // // // // //               Expanded(
// // // // // // // // //                 child: Text(
// // // // // // // // //                   "REPORTS_PRO_LOCK_TITLE".tr(ref), // ✅ SiRE Pro 타이틀
// // // // // // // // //                   maxLines: 1,
// // // // // // // // //                   overflow: TextOverflow.ellipsis,
// // // // // // // // //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ],
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 6),
// // // // // // // // //
// // // // // // // // //           // ✅ 2) 중단: 설명(최대 2줄)
// // // // // // // // //           Text(
// // // // // // // // //             subtitleKey.tr(ref),
// // // // // // // // //             maxLines: 2,
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.2),
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           const SizedBox(height: 10),
// // // // // // // // //
// // // // // // // // //           // ✅ 3) 하단: 버튼(오른쪽 정렬, 한 줄)
// // // // // // // // //           Align(
// // // // // // // // //             alignment: Alignment.centerRight,
// // // // // // // // //             child: ConstrainedBox(
// // // // // // // // //               constraints: const BoxConstraints(maxWidth: 170), // ✅ 버튼 최대폭 제한(언어 길이 대비)
// // // // // // // // //               child: SizedBox(
// // // // // // // // //                 height: 36,
// // // // // // // // //                 child: ElevatedButton(
// // // // // // // // //                   style: ElevatedButton.styleFrom(
// // // // // // // // //                     backgroundColor: const Color(0xFF1A237E),
// // // // // // // // //                     foregroundColor: Colors.white,
// // // // // // // // //                     padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // // // //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// // // // // // // // //                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // // //                     minimumSize: const Size(0, 36),
// // // // // // // // //                   ),
// // // // // // // // //                   onPressed: onTap,
// // // // // // // // //                   child: FittedBox(
// // // // // // // // //                     fit: BoxFit.scaleDown,
// // // // // // // // //                     child: Text(
// // // // // // // // //                       "REPORTS_PRO_LOCK_BUTTON".tr(ref),
// // // // // // // // //                       maxLines: 1,
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Pro 잠금 블러 오버레이 (① + ③)
// // // // // // // // //   // - 섹션은 보여주되, 내용은 블러 처리하고
// // // // // // // // //   // - 탭하면 Paywall로 이동
// // // // // // // // //   // - 별도의 Paywall 위젯을 Reports 내부에 직접 심지 않음(공용 PaywallScreen 사용)
// // // // // // // // //   Widget _buildProBlurLock({
// // // // // // // // //     required BuildContext context,
// // // // // // // // //     required WidgetRef ref,
// // // // // // // // //     required Widget child,
// // // // // // // // //     String? subtitle,
// // // // // // // // //   }) {
// // // // // // // // //     return ClipRRect( // ✅ 핵심: 블러/오버레이가 부모 밖으로 “그려지지 않게” 클립
// // // // // // // // //       borderRadius: BorderRadius.circular(12),
// // // // // // // // //       child: Stack(
// // // // // // // // //         clipBehavior: Clip.hardEdge, // ✅ 핵심
// // // // // // // // //         children: [
// // // // // // // // //           // ✅ 내용 블러 + 비활성화 느낌
// // // // // // // // //           Opacity(
// // // // // // // // //             opacity: 0.92,
// // // // // // // // //             child: ImageFiltered(
// // // // // // // // //               imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
// // // // // // // // //               child: IgnorePointer(child: child),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //
// // // // // // // // //           // ✅ 잠금 오버레이
// // // // // // // // //           Positioned.fill(
// // // // // // // // //             child: Material(
// // // // // // // // //               color: Colors.transparent,
// // // // // // // // //               child: InkWell(
// // // // // // // // //                 onTap: () => _openPaywall(context),
// // // // // // // // //                 child: LayoutBuilder(
// // // // // // // // //                   builder: (context, constraints) {
// // // // // // // // //                     return Center(
// // // // // // // // //                       child: Padding(
// // // // // // // // //                         padding: const EdgeInsets.all(12),
// // // // // // // // //                         child: ConstrainedBox(
// // // // // // // // //                           // ✅ 오버레이 카드 폭 제한(작은 폰/긴 언어 대응)
// // // // // // // // //                           constraints: BoxConstraints(
// // // // // // // // //                             maxWidth: constraints.maxWidth,
// // // // // // // // //                           ),
// // // // // // // // //                           // ✅ 오버플로우가 잦던 “Row+shadow 컨테이너”를 제거하고
// // // // // // // // //                           // ✅ 검증된 ProLockCard UI로 통일
// // // // // // // // //                           child: _buildProLockCard(
// // // // // // // // //                             context,
// // // // // // // // //                             ref,
// // // // // // // // //                             subtitleKey: (subtitle ?? "").isNotEmpty
// // // // // // // // //                                 ? subtitle!
// // // // // // // // //                                 : "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE",
// // // // // // // // //                             onTap: () => _openPaywall(context),
// // // // // // // // //                             compact: true, // ✅ 오버레이에서는 margin 제거
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                     );
// // // // // // // // //                   },
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // ✅ [추가] Paywall 이동(공용 화면)
// // // // // // // // //   void _openPaywall(BuildContext context) {
// // // // // // // // //     Navigator.of(context).push(
// // // // // // // // //       MaterialPageRoute(builder: (_) => const PaywallScreen()),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
// // // // // // // // //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // // //       children: [
// // // // // // // // //         Expanded(
// // // // // // // // //           // ✅ [수정] 레이블도 긴 다국어에서 너무 쉽게 "..." 되지 않도록 scaleDown 적용
// // // // // // // // //           child: FittedBox(
// // // // // // // // //             fit: BoxFit.scaleDown,
// // // // // // // // //             alignment: Alignment.centerLeft,
// // // // // // // // //             child: Text(
// // // // // // // // //               label,
// // // // // // // // //               maxLines: 1,
// // // // // // // // //               softWrap: false,
// // // // // // // // //               overflow: TextOverflow.visible,
// // // // // // // // //               style: TextStyle(
// // // // // // // // //                 fontSize: 14,
// // // // // // // // //                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
// // // // // // // // //                 color: Colors.black87,
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //         const SizedBox(width: 10),
// // // // // // // // //         FittedBox(
// // // // // // // // //           fit: BoxFit.scaleDown,
// // // // // // // // //           child: Text(
// // // // // // // // //             // 📍 국가별 통화 포맷 적용
// // // // // // // // //             fmt.format(amount),
// // // // // // // // //             maxLines: 1,
// // // // // // // // //             softWrap: false,
// // // // // // // // //             overflow: TextOverflow.visible,
// // // // // // // // //             style: TextStyle(
// // // // // // // // //               fontSize: 16,
// // // // // // // // //               fontWeight: FontWeight.bold,
// // // // // // // // //               color: color,
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _buildSectionTitle(IconData icon, String title) {
// // // // // // // // //     return Row(
// // // // // // // // //       children: [
// // // // // // // // //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// // // // // // // // //         const SizedBox(width: 8),
// // // // // // // // //         Expanded(
// // // // // // // // //           // ✅ [수정] 섹션 타이틀도 작은 기기에서 자동 축소(가능한 한 "..." 최소화)
// // // // // // // // //           child: FittedBox(
// // // // // // // // //             fit: BoxFit.scaleDown,
// // // // // // // // //             alignment: Alignment.centerLeft,
// // // // // // // // //             child: Text(
// // // // // // // // //               title,
// // // // // // // // //               maxLines: 1,
// // // // // // // // //               softWrap: false,
// // // // // // // // //               overflow: TextOverflow.visible,
// // // // // // // // //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // // // // // // //             ),
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// // // // // // // // //     return Row(
// // // // // // // // //       mainAxisSize: MainAxisSize.min,
// // // // // // // // //       mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // // //       crossAxisAlignment: CrossAxisAlignment.center,
// // // // // // // // //       children: [
// // // // // // // // //         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
// // // // // // // // //         const SizedBox(width: 6),
// // // // // // // // //         Flexible(
// // // // // // // // //           child: Text(
// // // // // // // // //             label,
// // // // // // // // //             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
// // // // // // // // //             overflow: TextOverflow.ellipsis,
// // // // // // // // //             textAlign: TextAlign.left,
// // // // // // // // //           ),
// // // // // // // // //         ),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// // // // // // // // //     try {
// // // // // // // // //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // // // // // // //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // // // // // // //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // // // // // // //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // // // // // // //       final tempDir = await getTemporaryDirectory();
// // // // // // // // //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// // // // // // // // //       await file.writeAsBytes(pngBytes);
// // // // // // // // //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// // // // // // // // //     } catch (e) {
// // // // // // // // //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // // //
// // // // // // // // // // ✅ [고도화 1단계] 리스크 요약 모델(ReportsScreen 내부 전용)
// // // // // // // // // enum _RiskLevel { low, mid, high }
// // // // // // // // //
// // // // // // // // // class _RiskSummary {
// // // // // // // // //   final int score; // 0~100
// // // // // // // // //   final _RiskLevel level;
// // // // // // // // //   final List<String> reasons; // localization key list (Top3)
// // // // // // // // //   final int balance;
// // // // // // // // //   final double growthRate;
// // // // // // // // //   final int overdueCount;
// // // // // // // // //   final int totalOverdueAmount;
// // // // // // // // //
// // // // // // // // //   _RiskSummary({
// // // // // // // // //     required this.score,
// // // // // // // // //     required this.level,
// // // // // // // // //     required this.reasons,
// // // // // // // // //     required this.balance,
// // // // // // // // //     required this.growthRate,
// // // // // // // // //     required this.overdueCount,
// // // // // // // // //     required this.totalOverdueAmount,
// // // // // // // // //   });
// // // // // // // // // }
// // // // // // // //
// // // // // // // //
// // // // // // // // import 'dart:io';
// // // // // // // // import 'dart:typed_data';
// // // // // // // // import 'dart:ui' as ui;
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:flutter/rendering.dart';
// // // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // // // import 'package:fl_chart/fl_chart.dart';
// // // // // // // // import 'package:intl/intl.dart';
// // // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // // import '../../core/purchase/models/purchase_status.dart';
// // // // // // // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
// // // // // // // //
// // // // // // // // // ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
// // // // // // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // // // // //
// // // // // // // // import '../ledger/ledger_provider.dart';
// // // // // // // // import '../ledger/unpaid_provider.dart';
// // // // // // // // import 'excel_export_service.dart';
// // // // // // // //
// // // // // // // // // ✅ [추가] Pro 인사이트 서비스
// // // // // // // // import 'financial_insight_service.dart';
// // // // // // // //
// // // // // // // // class ReportsScreen extends ConsumerWidget {
// // // // // // // //   const ReportsScreen({super.key});
// // // // // // // //
// // // // // // // //   // 📍 이미지 캡처를 위한 GlobalKey
// // // // // // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // // // // // //
// // // // // // // //   // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
// // // // // // // //   // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
// // // // // // // //   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
// // // // // // // //
// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // // // // //     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
// // // // // // // //     final isPro = ref.watch(isProProvider);
// // // // // // // //
// // // // // // // //     // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
// // // // // // // //     // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
// // // // // // // //     // ignore: unused_local_variable
// // // // // // // //     final purchaseState = ref.watch(purchaseControllerProvider);
// // // // // // // //
// // // // // // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // // // // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // // // // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // // // // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // // // // // //
// // // // // // // //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// // // // // // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // // // // // //
// // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // //     // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
// // // // // // // //     // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
// // // // // // // //     // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
// // // // // // // //     //
// // // // // // // //     // ✅ [중요]
// // // // // // // //     // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
// // // // // // // //     // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
// // // // // // // //     // -------------------------------------------------------------------------
// // // // // // // //     ref.listen<bool>(isProProvider, (prev, next) {
// // // // // // // //       // ✅ Pro → Free로 바뀌는 순간만 감지
// // // // // // // //       if (prev == true && next == false) {
// // // // // // // //         final alreadyShown = ref.read(_proDisabledToastShownProvider);
// // // // // // // //         if (alreadyShown) return;
// // // // // // // //
// // // // // // // //         // ✅ 플래그 ON (연속 표시 방지)
// // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = true;
// // // // // // // //
// // // // // // // //         // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
// // // // // // // //         if (context.mounted) {
// // // // // // // //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //             SnackBar(
// // // // // // // //               content: Text("REPORT_PRO_DISABLED_BY_REFUND".tr(ref)),
// // // // // // // //               behavior: SnackBarBehavior.floating,
// // // // // // // //             ),
// // // // // // // //           );
// // // // // // // //         }
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       // ✅ Free → Pro로 복구되면(재구매/복원 등)
// // // // // // // //       // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
// // // // // // // //       if (prev == false && next == true) {
// // // // // // // //         ref.read(_proDisabledToastShownProvider.notifier).state = false;
// // // // // // // //       }
// // // // // // // //     });
// // // // // // // //
// // // // // // // //     return Scaffold(
// // // // // // // //       backgroundColor: Colors.grey[100],
// // // // // // // //       appBar: AppBar(
// // // // // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // // // // //         foregroundColor: Colors.white,
// // // // // // // //         elevation: 0,
// // // // // // // //         scrolledUnderElevation: 0,
// // // // // // // //         automaticallyImplyLeading: false,
// // // // // // // //         centerTitle: false,
// // // // // // // //         title: Text(
// // // // // // // //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // // // // // // //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //       body: SingleChildScrollView(
// // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // //         child: Column(
// // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //           children: [
// // // // // // // //             // ✅ [고도화 1단계] 요약 및 경고(데이터 → 해석 → 경고) : Pro 구매 가치 제공
// // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // //             // ✅ 요청 반영:
// // // // // // // //             // - Free: 섹션은 보여주되(타이틀 노출), 내용은 잠금 카드로 대체
// // // // // // // //             // - Pro: 실제 인사이트 + 리스크 점수(0~100) + 원인 Top3 표시
// // // // // // // //             // -------------------------------------------------------------------------
// // // // // // // //             monthlyTrendAsync.when(
// // // // // // // //               loading: () => const SizedBox.shrink(),
// // // // // // // //               error: (_, __) => const SizedBox.shrink(),
// // // // // // // //               data: (trendData) {
// // // // // // // //                 return unpaidAsync.when(
// // // // // // // //                   loading: () => const SizedBox.shrink(),
// // // // // // // //                   error: (_, __) => const SizedBox.shrink(),
// // // // // // // //                   data: (unpaidList) {
// // // // // // // //                     int thisMonthIncome = 0;
// // // // // // // //                     int thisMonthExpense = 0;
// // // // // // // //                     int lastMonthExpense = 0;
// // // // // // // //
// // // // // // // //                     final now = DateTime.now();
// // // // // // // //
// // // // // // // //                     // ✅ 이번 달 데이터
// // // // // // // //                     final thisMonthItem = trendData
// // // // // // // //                         .where((e) => e.month.year == now.year && e.month.month == now.month)
// // // // // // // //                         .toList();
// // // // // // // //                     if (thisMonthItem.isNotEmpty) {
// // // // // // // //                       thisMonthIncome = thisMonthItem.first.income;
// // // // // // // //                       thisMonthExpense = thisMonthItem.first.expense;
// // // // // // // //                     }
// // // // // // // //
// // // // // // // //                     // ✅ 지난 달 데이터
// // // // // // // //                     final last = DateTime(now.year, now.month - 1, 1);
// // // // // // // //                     final lastMonthItem = trendData
// // // // // // // //                         .where((e) => e.month.year == last.year && e.month.month == last.month)
// // // // // // // //                         .toList();
// // // // // // // //                     if (lastMonthItem.isNotEmpty) {
// // // // // // // //                       lastMonthExpense = lastMonthItem.first.expense;
// // // // // // // //                     }
// // // // // // // //
// // // // // // // //                     // ✅ 미납 여부
// // // // // // // //                     final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // //                     final hasUnpaid = overdue.isNotEmpty;
// // // // // // // //                     final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // // // //
// // // // // // // //                     // ✅ [고도화] 리스크 점수 + 원인 Top3 계산
// // // // // // // //                     final risk = _computeRiskSummary(
// // // // // // // //                       thisMonthIncome: thisMonthIncome,
// // // // // // // //                       thisMonthExpense: thisMonthExpense,
// // // // // // // //                       lastMonthExpense: lastMonthExpense,
// // // // // // // //                       overdueCount: overdue.length,
// // // // // // // //                       totalOverdueAmount: totalOverdueAmount,
// // // // // // // //                     );
// // // // // // // //
// // // // // // // //                     // ✅ [고도화] 인사이트 리스트 생성
// // // // // // // //                     final insights = FinancialInsightService.generate(
// // // // // // // //                       thisMonthIncome: thisMonthIncome,
// // // // // // // //                       thisMonthExpense: thisMonthExpense,
// // // // // // // //                       lastMonthExpense: lastMonthExpense,
// // // // // // // //                       hasUnpaid: hasUnpaid,
// // // // // // // //                     );
// // // // // // // //
// // // // // // // //                     if (!isPro) {
// // // // // // // //                       return Column(
// // // // // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                         children: [
// // // // // // // //                           _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // //                           const SizedBox(height: 10),
// // // // // // // //                           _buildProLockCard(
// // // // // // // //                             context,
// // // // // // // //                             ref,
// // // // // // // //                             subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE",
// // // // // // // //                             onTap: () => _openPaywall(context),
// // // // // // // //                           ),
// // // // // // // //                           const SizedBox(height: 20),
// // // // // // // //                         ],
// // // // // // // //                       );
// // // // // // // //                     }
// // // // // // // //
// // // // // // // //                     // ✅ Pro 전용: 리스크 요약 카드 + 상세 인사이트
// // // // // // // //                     return Column(
// // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                       children: [
// // // // // // // //                         _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // // //                         const SizedBox(height: 10),
// // // // // // // //                         _buildRiskSummaryCard(ref, currencyFmt, risk),
// // // // // // // //                         const SizedBox(height: 10),
// // // // // // // //                         ...insights.map((i) => _buildInsightCard(ref, i)).toList(),
// // // // // // // //                         const SizedBox(height: 20),
// // // // // // // //                       ],
// // // // // // // //                     );
// // // // // // // //                   },
// // // // // // // //                 );
// // // // // // // //               },
// // // // // // // //             ),
// // // // // // // //
// // // // // // // //             // 📍 1. Financial Analytics 섹션 (Free)
// // // // // // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // // // // // //             const SizedBox(height: 10),
// // // // // // // //             Container(
// // // // // // // //               height: 320,
// // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // //               child: Row(
// // // // // // // //                 children: [
// // // // // // // //                   Expanded(
// // // // // // // //                     flex: 3,
// // // // // // // //                     child: Column(
// // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                       children: [
// // // // // // // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
// // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // //                         const SizedBox(height: 25),
// // // // // // // //                         Expanded(
// // // // // // // //                           child: monthlyTrendAsync.when(
// // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // //                             data: (data) => BarChart(
// // // // // // // //                               BarChartData(
// // // // // // // //                                 barTouchData: BarTouchData(
// // // // // // // //                                   enabled: false,
// // // // // // // //                                   touchTooltipData: BarTouchTooltipData(
// // // // // // // //                                     tooltipBgColor: Colors.transparent,
// // // // // // // //                                     tooltipPadding: EdgeInsets.zero,
// // // // // // // //                                     tooltipMargin: 4,
// // // // // // // //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// // // // // // // //                                       if (rod.toY == 0) return null;
// // // // // // // //                                       return BarTooltipItem(
// // // // // // // //                                         currencyFmt.format(rod.toY),
// // // // // // // //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// // // // // // // //                                       );
// // // // // // // //                                     },
// // // // // // // //                                   ),
// // // // // // // //                                 ),
// // // // // // // //                                 barGroups: data.asMap().entries.map((e) {
// // // // // // // //                                   final List<int> indicators = [];
// // // // // // // //                                   if (e.value.income > 0) indicators.add(0);
// // // // // // // //                                   if (e.value.expense > 0) indicators.add(1);
// // // // // // // //
// // // // // // // //                                   return BarChartGroupData(
// // // // // // // //                                     x: e.key,
// // // // // // // //                                     barsSpace: 4,
// // // // // // // //                                     showingTooltipIndicators: indicators,
// // // // // // // //                                     barRods: [
// // // // // // // //                                       BarChartRodData(
// // // // // // // //                                         toY: e.value.income.toDouble(),
// // // // // // // //                                         color: Colors.blue,
// // // // // // // //                                         width: 8,
// // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // //                                       ),
// // // // // // // //                                       BarChartRodData(
// // // // // // // //                                         toY: e.value.expense.toDouble(),
// // // // // // // //                                         color: Colors.redAccent,
// // // // // // // //                                         width: 8,
// // // // // // // //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// // // // // // // //                                       ),
// // // // // // // //                                     ],
// // // // // // // //                                   );
// // // // // // // //                                 }).toList(),
// // // // // // // //                                 titlesData: FlTitlesData(
// // // // // // // //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // // //                                   bottomTitles: AxisTitles(
// // // // // // // //                                     sideTitles: SideTitles(
// // // // // // // //                                       showTitles: true,
// // // // // // // //                                       getTitlesWidget: (value, meta) {
// // // // // // // //                                         int index = value.toInt();
// // // // // // // //                                         if (index >= 0 && index < data.length) {
// // // // // // // //                                           return Padding(
// // // // // // // //                                             padding: const EdgeInsets.only(top: 8.0),
// // // // // // // //                                             child: Text(
// // // // // // // //                                               DateFormat.MMM(lang).format(data[index].month),
// // // // // // // //                                               style: const TextStyle(fontSize: 9),
// // // // // // // //                                             ),
// // // // // // // //                                           );
// // // // // // // //                                         }
// // // // // // // //                                         return const Text('');
// // // // // // // //                                       },
// // // // // // // //                                     ),
// // // // // // // //                                   ),
// // // // // // // //                                 ),
// // // // // // // //                                 gridData: const FlGridData(show: false),
// // // // // // // //                                 borderData: FlBorderData(show: false),
// // // // // // // //                               ),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                         ),
// // // // // // // //                         const SizedBox(height: 12),
// // // // // // // //                         Row(
// // // // // // // //                           mainAxisAlignment: MainAxisAlignment.start,
// // // // // // // //                           children: [
// // // // // // // //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // // // // // // //                             const SizedBox(width: 12),
// // // // // // // //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// // // // // // // //                           ],
// // // // // // // //                         )
// // // // // // // //                       ],
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   const SizedBox(width: 12),
// // // // // // // //                   Expanded(
// // // // // // // //                     flex: 2,
// // // // // // // //                     child: Column(
// // // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                       children: [
// // // // // // // //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
// // // // // // // //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // // //                         const SizedBox(height: 10),
// // // // // // // //                         Expanded(
// // // // // // // //                           child: categoryStatsAsync.when(
// // // // // // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // //                             error: (_, __) => const SizedBox(),
// // // // // // // //                             data: (data) {
// // // // // // // //                               if (data.isEmpty) {
// // // // // // // //                                 return Center(
// // // // // // // //                                     child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// // // // // // // //                               }
// // // // // // // //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // // // // // //
// // // // // // // //                               return Column(
// // // // // // // //                                 children: [
// // // // // // // //                                   Expanded(
// // // // // // // //                                     flex: 3,
// // // // // // // //                                     child: PieChart(
// // // // // // // //                                       PieChartData(
// // // // // // // //                                         sectionsSpace: 2,
// // // // // // // //                                         centerSpaceRadius: 10,
// // // // // // // //                                         sections: data.asMap().entries.map((entry) {
// // // // // // // //                                           final double pctValue = entry.value.percentage * 100;
// // // // // // // //                                           final String percentageStr = pctValue.toStringAsFixed(0);
// // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // //                                               : entry.value.category;
// // // // // // // //
// // // // // // // //                                           final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';
// // // // // // // //
// // // // // // // //                                           return PieChartSectionData(
// // // // // // // //                                             value: entry.value.amount.toDouble(),
// // // // // // // //                                             title: sectionTitle,
// // // // // // // //                                             titleStyle: const TextStyle(
// // // // // // // //                                               fontSize: 7,
// // // // // // // //                                               fontWeight: FontWeight.bold,
// // // // // // // //                                               color: Colors.white,
// // // // // // // //                                               height: 1.2,
// // // // // // // //                                             ),
// // // // // // // //                                             color: colors[entry.key % colors.length],
// // // // // // // //                                             radius: 40,
// // // // // // // //                                           );
// // // // // // // //                                         }).toList(),
// // // // // // // //                                       ),
// // // // // // // //                                     ),
// // // // // // // //                                   ),
// // // // // // // //                                   const SizedBox(height: 12),
// // // // // // // //                                   Expanded(
// // // // // // // //                                     flex: 3,
// // // // // // // //                                     child: SingleChildScrollView(
// // // // // // // //                                       child: Column(
// // // // // // // //                                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                                         children: data.asMap().entries.map((entry) {
// // // // // // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // // // // // //                                               ? entry.value.category.tr(ref)
// // // // // // // //                                               : entry.value.category;
// // // // // // // //                                           return Padding(
// // // // // // // //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// // // // // // // //                                             child: _buildLegend(
// // // // // // // //                                               colors[entry.key % colors.length],
// // // // // // // //                                               "$categoryName (${currencyFmt.format(entry.value.amount)})",
// // // // // // // //                                               fontSize: 9,
// // // // // // // //                                             ),
// // // // // // // //                                           );
// // // // // // // //                                         }).toList(),
// // // // // // // //                                       ),
// // // // // // // //                                     ),
// // // // // // // //                                   ),
// // // // // // // //                                 ],
// // // // // // // //                               );
// // // // // // // //                             },
// // // // // // // //                           ),
// // // // // // // //                         ),
// // // // // // // //                       ],
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //
// // // // // // // //             const SizedBox(height: 30),
// // // // // // // //
// // // // // // // //             // 📍 2. Tax Data Management 섹션 (Pro 구매)
// // // // // // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // // // // // //             const SizedBox(height: 10),
// // // // // // // //             Container(
// // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // //               child: Column(
// // // // // // // //                 children: [
// // // // // // // //                   Container(
// // // // // // // //                     padding: const EdgeInsets.all(12),
// // // // // // // //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // // // // // // //                     child: Row(
// // // // // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // //                       children: [
// // // // // // // //                         Expanded(
// // // // // // // //                           child: FittedBox(
// // // // // // // //                             fit: BoxFit.scaleDown,
// // // // // // // //                             alignment: Alignment.centerLeft,
// // // // // // // //                             child: Text(
// // // // // // // //                               "${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}",
// // // // // // // //                               maxLines: 1,
// // // // // // // //                               softWrap: false,
// // // // // // // //                               overflow: TextOverflow.visible,
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                         ),
// // // // // // // //                         const SizedBox(width: 10),
// // // // // // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// // // // // // // //                       ],
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   const SizedBox(height: 20),
// // // // // // // //                   SizedBox(
// // // // // // // //                     width: double.infinity,
// // // // // // // //                     child: ElevatedButton.icon(
// // // // // // // //                       style: ElevatedButton.styleFrom(
// // // // // // // //                         backgroundColor: const Color(0xFF4CAF50),
// // // // // // // //                         foregroundColor: Colors.white,
// // // // // // // //                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
// // // // // // // //                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // //                         visualDensity: VisualDensity.compact,
// // // // // // // //                         minimumSize: const Size(0, 46),
// // // // // // // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // //                       ),
// // // // // // // //                       onPressed: () async {
// // // // // // // //                         if (!isPro) {
// // // // // // // //                           _openPaywall(context);
// // // // // // // //                           return;
// // // // // // // //                         }
// // // // // // // //
// // // // // // // //                         final transactions = await ref.read(ledgerListProvider.future);
// // // // // // // //                         if (transactions.isEmpty) return;
// // // // // // // //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// // // // // // // //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// // // // // // // //                       },
// // // // // // // //                       icon: const Icon(Icons.file_download, size: 18),
// // // // // // // //                       label: FittedBox(
// // // // // // // //                         fit: BoxFit.scaleDown,
// // // // // // // //                         child: Text("REPORT_BTN_TAX_EXCEL".tr(ref), maxLines: 1, softWrap: false,
// // // // // // // //                             style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // //                       ),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //
// // // // // // // //             const SizedBox(height: 30),
// // // // // // // //
// // // // // // // //             // 📍 3. Unpaid Management 섹션 (Pro 구매)
// // // // // // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // // // // // //             const SizedBox(height: 10),
// // // // // // // //             Container(
// // // // // // // //               padding: const EdgeInsets.all(16),
// // // // // // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // //               child: Column(
// // // // // // // //                 children: [
// // // // // // // //                   RepaintBoundary(
// // // // // // // //                     key: _unpaidCaptureKey,
// // // // // // // //                     child: Container(
// // // // // // // //                       width: double.infinity,
// // // // // // // //                       padding: const EdgeInsets.all(12),
// // // // // // // //                       decoration: BoxDecoration(
// // // // // // // //                         color: Colors.white,
// // // // // // // //                         border: Border.all(color: Colors.grey.shade300),
// // // // // // // //                         borderRadius: BorderRadius.circular(8),
// // // // // // // //                       ),
// // // // // // // //                       child: unpaidAsync.when(
// // // // // // // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// // // // // // // //                         data: (list) {
// // // // // // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // // // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // // // // // //                           return Column(
// // // // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                             children: [
// // // // // // // //                               FittedBox(
// // // // // // // //                                 fit: BoxFit.scaleDown,
// // // // // // // //                                 alignment: Alignment.centerLeft,
// // // // // // // //                                 child: Text(
// // // // // // // //                                   "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// // // // // // // //                                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// // // // // // // //                                   maxLines: 1,
// // // // // // // //                                   softWrap: false,
// // // // // // // //                                   overflow: TextOverflow.visible,
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               const SizedBox(height: 8),
// // // // // // // //                               ...overdue.take(5).map(
// // // // // // // //                                     (u) => Padding(
// // // // // // // //                                   padding: const EdgeInsets.symmetric(vertical: 2),
// // // // // // // //                                   child: Text(
// // // // // // // //                                     "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? 'COMMON_ANONYMOUS'.tr(ref)}): ${currencyFmt.format(u.unit.monthlyRent)}",
// // // // // // // //                                     style: const TextStyle(fontSize: 12, color: Colors.black87),
// // // // // // // //                                   ),
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                             ],
// // // // // // // //                           );
// // // // // // // //                         },
// // // // // // // //                       ),
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                   const SizedBox(height: 20),
// // // // // // // //                   Row(
// // // // // // // //                     children: [
// // // // // // // //                       Expanded(
// // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // //                             backgroundColor: const Color(0xFF4CAF50),
// // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
// // // // // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // //                             visualDensity: VisualDensity.compact,
// // // // // // // //                             minimumSize: const Size(0, 44),
// // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // //                           ),
// // // // // // // //                           onPressed: () async {
// // // // // // // //                             if (!isPro) {
// // // // // // // //                               _openPaywall(context);
// // // // // // // //                               return;
// // // // // // // //                             }
// // // // // // // //
// // // // // // // //                             final list = await ref.read(unpaidListProvider.future);
// // // // // // // //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // // // // // //                             if (overdue.isEmpty) return;
// // // // // // // //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // // // // // // //                           },
// // // // // // // //                           icon: const Icon(Icons.file_download, size: 18),
// // // // // // // //                           label: FittedBox(
// // // // // // // //                             fit: BoxFit.scaleDown,
// // // // // // // //                             child: Text(
// // // // // // // //                               "REPORT_BTN_UNPAID_EXCEL".tr(ref),
// // // // // // // //                               maxLines: 1,
// // // // // // // //                               softWrap: false,
// // // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                         ),
// // // // // // // //                       ),
// // // // // // // //                       const SizedBox(width: 10),
// // // // // // // //                       Expanded(
// // // // // // // //                         child: ElevatedButton.icon(
// // // // // // // //                           style: ElevatedButton.styleFrom(
// // // // // // // //                             backgroundColor: Colors.orangeAccent,
// // // // // // // //                             foregroundColor: Colors.white,
// // // // // // // //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
// // // // // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // // // // //                             visualDensity: VisualDensity.compact,
// // // // // // // //                             minimumSize: const Size(0, 44),
// // // // // // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // // // // //                           ),
// // // // // // // //                           onPressed: () {
// // // // // // // //                             if (!isPro) {
// // // // // // // //                               _openPaywall(context);
// // // // // // // //                               return;
// // // // // // // //                             }
// // // // // // // //                             _captureAndShareImage(context, ref);
// // // // // // // //                           },
// // // // // // // //                           icon: const Icon(Icons.share_outlined, size: 18),
// // // // // // // //                           label: FittedBox(
// // // // // // // //                             fit: BoxFit.scaleDown,
// // // // // // // //                             child: Text(
// // // // // // // //                               "REPORT_BTN_UNPAID_IMAGE".tr(ref),
// // // // // // // //                               maxLines: 1,
// // // // // // // //                               softWrap: false,
// // // // // // // //                               style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // // // //                             ),
// // // // // // // //                           ),
// // // // // // // //                         ),
// // // // // // // //                       ),
// // // // // // // //                     ],
// // // // // // // //                   ),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //
// // // // // // // //             const SizedBox(height: 30),
// // // // // // // //
// // // // // // // //             // 📍 4. Annual Summary (Pro 구매)
// // // // // // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // // // // // //             const SizedBox(height: 10),
// // // // // // // //             monthlyTrendAsync.when(
// // // // // // // //               loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // // //               error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// // // // // // // //               data: (trend) {
// // // // // // // //                 final annualCard = Container(
// // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // //                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // // // // // //                   child: () {
// // // // // // // //                     final int currentYear = DateTime.now().year;
// // // // // // // //                     final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// // // // // // // //
// // // // // // // //                     int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// // // // // // // //                     int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// // // // // // // //                     int yearlyProfit = yearlyIncome - yearlyExpense;
// // // // // // // //
// // // // // // // //                     return Column(
// // // // // // // //                       children: [
// // // // // // // //                         Row(
// // // // // // // //                           mainAxisAlignment: MainAxisAlignment.end,
// // // // // // // //                           children: [
// // // // // // // //                             Text(
// // // // // // // //                               "${'COMMON_YEAR'.tr(ref)}: $currentYear",
// // // // // // // //                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
// // // // // // // //                             ),
// // // // // // // //                           ],
// // // // // // // //                         ),
// // // // // // // //                         const SizedBox(height: 10),
// // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// // // // // // // //                         const Divider(height: 20),
// // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// // // // // // // //                         const Divider(height: 20),
// // // // // // // //                         _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// // // // // // // //                         const SizedBox(height: 15),
// // // // // // // //                         Text(
// // // // // // // //                           "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// // // // // // // //                           style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// // // // // // // //                         )
// // // // // // // //                       ],
// // // // // // // //                     );
// // // // // // // //                   }(),
// // // // // // // //                 );
// // // // // // // //
// // // // // // // //                 if (!isPro) {
// // // // // // // //                   return _buildProLockCard(
// // // // // // // //                     context,
// // // // // // // //                     ref,
// // // // // // // //                     subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE",
// // // // // // // //                     onTap: () => _openPaywall(context),
// // // // // // // //                   );
// // // // // // // //                 }
// // // // // // // //
// // // // // // // //                 return annualCard;
// // // // // // // //               },
// // // // // // // //             ),
// // // // // // // //
// // // // // // // //             const SizedBox(height: 50),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // ✅ [고도화 1단계] 리스크 점수 + 원인 Top3 계산 (로직 고도화)
// // // // // // // //   _RiskSummary _computeRiskSummary({
// // // // // // // //     required int thisMonthIncome,
// // // // // // // //     required int thisMonthExpense,
// // // // // // // //     required int lastMonthExpense,
// // // // // // // //     required int overdueCount,
// // // // // // // //     required int totalOverdueAmount,
// // // // // // // //   }) {
// // // // // // // //     final List<String> reasons = [];
// // // // // // // //     int score = 0;
// // // // // // // //
// // // // // // // //     // 1) 수지 분석 (적자 여부)
// // // // // // // //     final int balance = thisMonthIncome - thisMonthExpense;
// // // // // // // //     if (thisMonthIncome > 0 && balance < 0) {
// // // // // // // //       score += 40;
// // // // // // // //       reasons.add("REPORT_RISK_REASON_DEFICIT"); // "수익보다 지출이 많습니다"
// // // // // // // //     } else if (thisMonthIncome <= 0 && thisMonthExpense > 0) {
// // // // // // // //       score += 50;
// // // // // // // //       reasons.add("REPORT_RISK_REASON_NO_INCOME"); // "임대 수익 없이 지출만 발생했습니다"
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // 2) 지출 변동성 (전월 대비 급증)
// // // // // // // //     double growthRate = 0;
// // // // // // // //     if (lastMonthExpense > 0) {
// // // // // // // //       growthRate = (thisMonthExpense - lastMonthExpense) / lastMonthExpense;
// // // // // // // //       if (growthRate >= 0.30) {
// // // // // // // //         score += 25;
// // // // // // // //         reasons.add("REPORT_RISK_REASON_SPEND_SPIKE");
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // 3) 수금 리스크 (미납)
// // // // // // // //     if (overdueCount > 0) {
// // // // // // // //       score += 20;
// // // // // // // //       reasons.add("REPORT_RISK_REASON_OVERDUE");
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     if (score > 100) score = 100;
// // // // // // // //
// // // // // // // //     return _RiskSummary(
// // // // // // // //       score: score,
// // // // // // // //       level: score >= 75 ? _RiskLevel.high : score >= 40 ? _RiskLevel.mid : _RiskLevel.low,
// // // // // // // //       reasons: reasons.take(3).toList(),
// // // // // // // //       balance: balance,
// // // // // // // //       growthRate: growthRate,
// // // // // // // //       overdueCount: overdueCount,
// // // // // // // //       totalOverdueAmount: totalOverdueAmount,
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // ✅ [고도화 1단계] 리스크 요약 카드 UI (Pro 전용)
// // // // // // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk) {
// // // // // // // //     final Color color = switch (risk.level) {
// // // // // // // //       _RiskLevel.low => Colors.green,
// // // // // // // //       _RiskLevel.mid => Colors.orange,
// // // // // // // //       _RiskLevel.high => Colors.redAccent,
// // // // // // // //     };
// // // // // // // //
// // // // // // // //     return Container(
// // // // // // // //       width: double.infinity,
// // // // // // // //       padding: const EdgeInsets.all(16),
// // // // // // // //       decoration: BoxDecoration(
// // // // // // // //         color: color.withOpacity(0.08),
// // // // // // // //         borderRadius: BorderRadius.circular(16),
// // // // // // // //         border: Border.all(color: color.withOpacity(0.3), width: 1.5),
// // // // // // // //       ),
// // // // // // // //       child: Column(
// // // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //         children: [
// // // // // // // //           Row(
// // // // // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // //             children: [
// // // // // // // //               Row(
// // // // // // // //                 children: [
// // // // // // // //                   Icon(Icons.analytics_outlined, color: color, size: 22),
// // // // // // // //                   const SizedBox(width: 10),
// // // // // // // //                   Text(
// // // // // // // //                     'REPORT_RISK_TITLE'.tr(ref),
// // // // // // // //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
// // // // // // // //                   ),
// // // // // // // //                 ],
// // // // // // // //               ),
// // // // // // // //               Container(
// // // // // // // //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // // // // // // //                 decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
// // // // // // // //                 child: Text(
// // // // // // // //                   "${risk.score}/100",
// // // // // // // //                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             ],
// // // // // // // //           ),
// // // // // // // //           const SizedBox(height: 12),
// // // // // // // //           const Divider(),
// // // // // // // //           ...risk.reasons.map((k) => Padding(
// // // // // // // //             padding: const EdgeInsets.only(top: 6),
// // // // // // // //             child: Row(
// // // // // // // //               children: [
// // // // // // // //                 Icon(Icons.arrow_right, color: color, size: 20),
// // // // // // // //                 Expanded(
// // // // // // // //                   child: Text(k.tr(ref), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
// // // // // // // //                 ),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //           )),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // ✅ [수정 완료] 에러 수정된 인사이트 카드 (Border 문법 수정)
// // // // // // // //   Widget _buildInsightCard(WidgetRef ref, FinancialInsight insight) {
// // // // // // // //     final Color color = switch (insight.level) {
// // // // // // // //       InsightLevel.info => const Color(0xFF1E88E5),
// // // // // // // //       InsightLevel.warning => Colors.orange,
// // // // // // // //       InsightLevel.alert => Colors.redAccent,
// // // // // // // //     };
// // // // // // // //
// // // // // // // //     return Container(
// // // // // // // //       width: double.infinity,
// // // // // // // //       margin: const EdgeInsets.only(bottom: 8),
// // // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // // //       decoration: BoxDecoration(
// // // // // // // //         color: Colors.white,
// // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // //         // 📍 에러 수정: Border.left(...) 대신 정석적인 Border(left: ...) 사용
// // // // // // // //         border: Border(left: BorderSide(color: color, width: 4)),
// // // // // // // //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
// // // // // // // //       ),
// // // // // // // //       child: Row(
// // // // // // // //         children: [
// // // // // // // //           Icon(insight.level == InsightLevel.info ? Icons.info_outline : Icons.error_outline, color: color, size: 20),
// // // // // // // //           const SizedBox(width: 12),
// // // // // // // //           Expanded(
// // // // // // // //             child: Text(
// // // // // // // //               insight.messageKey.tr(ref),
// // // // // // // //               style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Widget _buildProLockCard(
// // // // // // // //       BuildContext context,
// // // // // // // //       WidgetRef ref, {
// // // // // // // //         required String subtitleKey,
// // // // // // // //         required VoidCallback onTap,
// // // // // // // //       }) {
// // // // // // // //     return Container(
// // // // // // // //       width: double.infinity,
// // // // // // // //       padding: const EdgeInsets.all(16),
// // // // // // // //       decoration: BoxDecoration(
// // // // // // // //         color: Colors.white,
// // // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // // //         border: Border.all(color: Colors.grey.shade300),
// // // // // // // //       ),
// // // // // // // //       child: Column(
// // // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //         children: [
// // // // // // // //           Row(
// // // // // // // //             children: [
// // // // // // // //               const Icon(Icons.lock_outline, color: Color(0xFF1A237E), size: 20),
// // // // // // // //               const SizedBox(width: 10),
// // // // // // // //               Expanded(
// // // // // // // //                 child: Text(
// // // // // // // //                   "REPORTS_PRO_LOCK_TITLE".tr(ref),
// // // // // // // //                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             ],
// // // // // // // //           ),
// // // // // // // //           const SizedBox(height: 8),
// // // // // // // //           Text(
// // // // // // // //             subtitleKey.tr(ref),
// // // // // // // //             style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
// // // // // // // //           ),
// // // // // // // //           const SizedBox(height: 12),
// // // // // // // //           Align(
// // // // // // // //             alignment: Alignment.centerRight,
// // // // // // // //             child: ElevatedButton(
// // // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // // //                 backgroundColor: const Color(0xFF1A237E),
// // // // // // // //                 foregroundColor: Colors.white,
// // // // // // // //               ),
// // // // // // // //               onPressed: onTap,
// // // // // // // //               child: Text("REPORTS_PRO_LOCK_BUTTON".tr(ref)),
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   void _openPaywall(BuildContext context) {
// // // // // // // //     Navigator.of(context).push(
// // // // // // // //       MaterialPageRoute(builder: (_) => const PaywallScreen()),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// // // // // // // //     return Row(
// // // // // // // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // // //       children: [
// // // // // // // //         Expanded(
// // // // // // // //           child: FittedBox(
// // // // // // // //             fit: BoxFit.scaleDown,
// // // // // // // //             alignment: Alignment.centerLeft,
// // // // // // // //             child: Text(
// // // // // // // //               label,
// // // // // // // //               style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
// // // // // // // //             ),
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //         const SizedBox(width: 10),
// // // // // // // //         Text(fmt.format(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
// // // // // // // //       ],
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Widget _buildSectionTitle(IconData icon, String title) {
// // // // // // // //     return Row(
// // // // // // // //       children: [
// // // // // // // //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// // // // // // // //         const SizedBox(width: 8),
// // // // // // // //         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // // //       ],
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// // // // // // // //     return Row(
// // // // // // // //       mainAxisSize: MainAxisSize.min,
// // // // // // // //       children: [
// // // // // // // //         Container(
// // // // // // // //           width: 8,
// // // // // // // //           height: 8,
// // // // // // // //           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
// // // // // // // //         ),
// // // // // // // //         const SizedBox(width: 6),
// // // // // // // //         Text(
// // // // // // // //           label,
// // // // // // // //           style: TextStyle(
// // // // // // // //             fontSize: fontSize, // 📍 전달받은 fontSize를 적용합니다.
// // // // // // // //             fontWeight: FontWeight.w500,
// // // // // // // //           ),
// // // // // // // //         ),
// // // // // // // //       ],
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Widget _chipText(WidgetRef ref, Color color, String text) {
// // // // // // // //     return Container(
// // // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// // // // // // // //       decoration: BoxDecoration(
// // // // // // // //         color: Colors.white,
// // // // // // // //         borderRadius: BorderRadius.circular(8),
// // // // // // // //         border: Border.all(color: color.withOpacity(0.2)),
// // // // // // // //       ),
// // // // // // // //       child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// // // // // // // //     try {
// // // // // // // //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // // // // // //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // // // // // //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // // // // // //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // // // // // //       final tempDir = await getTemporaryDirectory();
// // // // // // // //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// // // // // // // //       await file.writeAsBytes(pngBytes);
// // // // // // // //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// // // // // // // //     } catch (e) {
// // // // // // // //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // // }
// // // // // // // //
// // // // // // // // enum _RiskLevel { low, mid, high }
// // // // // // // //
// // // // // // // // class _RiskSummary {
// // // // // // // //   final int score;
// // // // // // // //   final _RiskLevel level;
// // // // // // // //   final List<String> reasons;
// // // // // // // //   final int balance;
// // // // // // // //   final double growthRate;
// // // // // // // //   final int overdueCount;
// // // // // // // //   final int totalOverdueAmount;
// // // // // // // //
// // // // // // // //   _RiskSummary({
// // // // // // // //     required this.score,
// // // // // // // //     required this.level,
// // // // // // // //     required this.reasons,
// // // // // // // //     required this.balance,
// // // // // // // //     required this.growthRate,
// // // // // // // //     required this.overdueCount,
// // // // // // // //     required this.totalOverdueAmount,
// // // // // // // //   });
// // // // // // // // }
// // // // // // //
// // // // // // //
// // // // // // // import 'dart:io';
// // // // // // // import 'dart:typed_data';
// // // // // // // import 'dart:ui' as ui;
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:flutter/rendering.dart';
// // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // // import 'package:fl_chart/fl_chart.dart';
// // // // // // // import 'package:intl/intl.dart';
// // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // import '../../core/localization/localization_provider.dart';
// // // // // // // import '../../core/purchase/models/purchase_status.dart';
// // // // // // // import '../../core/purchase/state/purchase_provider.dart';
// // // // // // //
// // // // // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // // // // import '../ledger/ledger_provider.dart';
// // // // // // // import '../ledger/unpaid_provider.dart';
// // // // // // // import 'excel_export_service.dart';
// // // // // // // import 'financial_insight_service.dart';
// // // // // // //
// // // // // // // class ReportsScreen extends ConsumerWidget {
// // // // // // //   const ReportsScreen({super.key});
// // // // // // //
// // // // // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // // // // //   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
// // // // // // //
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // // // //     final isPro = ref.watch(isProProvider);
// // // // // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // // // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // // // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // // // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // // // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // // // // //
// // // // // // //     return Scaffold(
// // // // // // //       backgroundColor: Colors.grey[100],
// // // // // // //       appBar: AppBar(
// // // // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // // // //         foregroundColor: Colors.white,
// // // // // // //         elevation: 0,
// // // // // // //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // // // // //       ),
// // // // // // //       body: SingleChildScrollView(
// // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // //         child: Column(
// // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //           children: [
// // // // // // //             // ✅ [수정] 요약 및 경고 섹션 - 룩앤필 통일 (인디고/그레이 테마)
// // // // // // //             monthlyTrendAsync.when(
// // // // // // //               loading: () => const SizedBox.shrink(),
// // // // // // //               error: (_, __) => const SizedBox.shrink(),
// // // // // // //               data: (trendData) => unpaidAsync.when(
// // // // // // //                 loading: () => const SizedBox.shrink(),
// // // // // // //                 error: (_, __) => const SizedBox.shrink(),
// // // // // // //                 data: (unpaidList) {
// // // // // // //                   int thisMonthIncome = 0, thisMonthExpense = 0, lastMonthExpense = 0;
// // // // // // //                   final now = DateTime.now();
// // // // // // //                   final thisMonthItem = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// // // // // // //                   if (thisMonthItem.isNotEmpty) {
// // // // // // //                     thisMonthIncome = thisMonthItem.first.income;
// // // // // // //                     thisMonthExpense = thisMonthItem.first.expense;
// // // // // // //                   }
// // // // // // //                   final last = DateTime(now.year, now.month - 1, 1);
// // // // // // //                   final lastMonthItem = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// // // // // // //                   if (lastMonthItem.isNotEmpty) lastMonthExpense = lastMonthItem.first.expense;
// // // // // // //                   final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // // // // //
// // // // // // //                   final risk = _computeRiskSummary(
// // // // // // //                     thisMonthIncome: thisMonthIncome,
// // // // // // //                     thisMonthExpense: thisMonthExpense,
// // // // // // //                     lastMonthExpense: lastMonthExpense,
// // // // // // //                     overdueCount: overdue.length,
// // // // // // //                     totalOverdueAmount: overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent),
// // // // // // //                   );
// // // // // // //
// // // // // // //                   return Column(
// // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                     children: [
// // // // // // //                       _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // // //                       const SizedBox(height: 10),
// // // // // // //                       if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// // // // // // //                       else _buildRiskSummaryCard(ref, currencyFmt, risk), // 📍 룩앤필 수정된 카드 호출
// // // // // // //                       const SizedBox(height: 20),
// // // // // // //                     ],
// // // // // // //                   );
// // // // // // //                 },
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //
// // // // // // //             // 1. Financial Analytics (Free) - 차트 정보 완벽 복구
// // // // // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // // // // //             const SizedBox(height: 10),
// // // // // // //             _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// // // // // // //
// // // // // // //             const SizedBox(height: 30),
// // // // // // //
// // // // // // //             // 2. Tax Data Management (Pro) - 버튼 디자인 복구
// // // // // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // // // // //             const SizedBox(height: 10),
// // // // // // //             _buildTaxSection(context, ref, isPro),
// // // // // // //
// // // // // // //             const SizedBox(height: 30),
// // // // // // //
// // // // // // //             // 3. Unpaid Management (Pro) - 레이아웃 복구
// // // // // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // // // // //             const SizedBox(height: 10),
// // // // // // //             _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// // // // // // //
// // // // // // //             const SizedBox(height: 30),
// // // // // // //
// // // // // // //             // 4. Annual Summary (Pro) - 요약 표 디자인 복구
// // // // // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // // // // //             const SizedBox(height: 10),
// // // // // // //             _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // // // // // //
// // // // // // //             const SizedBox(height: 50),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // ✅ [수정] 룩앤필이 통일된 리스크 요약 카드 (초록색 제거, 다른 섹션과 유사한 톤)
// // // // // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk) {
// // // // // // //     // 테마 컬러 설정 (앱 메인 컬러인 인디고 사용)
// // // // // // //     const Color mainIndigo = Color(0xFF1A237E);
// // // // // // //     final Color stateColor = risk.level == _RiskLevel.high ? Colors.redAccent : (risk.level == _RiskLevel.mid ? Colors.orange : mainIndigo);
// // // // // // //
// // // // // // //     return Container(
// // // // // // //       width: double.infinity,
// // // // // // //       padding: const EdgeInsets.all(16),
// // // // // // //       decoration: BoxDecoration(
// // // // // // //           color: Colors.white,
// // // // // // //           borderRadius: BorderRadius.circular(16),
// // // // // // //           border: Border.all(color: Colors.grey.shade300), // 초록색 테두리 대신 회색으로 변경
// // // // // // //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // // // // //       ),
// // // // // // //       child: Column(
// // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //         children: [
// // // // // // //           Row(
// // // // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // // //             children: [
// // // // // // //               Row(children: [
// // // // // // //                 Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), // 인디고 색상 통일
// // // // // // //                 const SizedBox(width: 10),
// // // // // // //                 Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))
// // // // // // //               ]),
// // // // // // //               Container(
// // // // // // //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // // // // // //                   decoration: BoxDecoration(color: stateColor, borderRadius: BorderRadius.circular(20)),
// // // // // // //                   child: Text("${risk.score}/100", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //           const SizedBox(height: 16),
// // // // // // //           Row(
// // // // // // //             children: [
// // // // // // //               _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance), mainIndigo),
// // // // // // //               const SizedBox(width: 10),
// // // // // // //               _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건", mainIndigo),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //           if (risk.reasons.isNotEmpty) ...[
// // // // // // //             const SizedBox(height: 12),
// // // // // // //             const Divider(),
// // // // // // //             ...risk.reasons.map((k) => Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [Icon(Icons.arrow_right, color: stateColor), Expanded(child: Text(k.tr(ref), style: const TextStyle(fontSize: 13, color: Colors.black87)))]))),
// // // // // // //           ],
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   Widget _infoTile(WidgetRef ref, String label, String value, Color color) {
// // // // // // //     return Expanded(
// // // // // // //       child: Container(
// // // // // // //         padding: const EdgeInsets.all(10),
// // // // // // //         decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
// // // // // // //         child: Column(
// // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //           children: [
// // // // // // //             Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
// // // // // // //             Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // ✅ [복구] 차트 수치 및 범례 정보 표시 완벽 복구
// // // // // // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
// // // // // // //     return Container(
// // // // // // //       height: 320, padding: const EdgeInsets.all(16),
// // // // // // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // // // // //       child: monthlyTrend.when(
// // // // // // //           loading: () => const Center(child: CircularProgressIndicator()),
// // // // // // //           error: (_, __) => const SizedBox.shrink(),
// // // // // // //           data: (trendData) {
// // // // // // //             final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // // // // // //               final List<int> indicators = [];
// // // // // // //               if (e.value.income > 0) indicators.add(0);
// // // // // // //               if (e.value.expense > 0) indicators.add(1);
// // // // // // //               return BarChartGroupData(x: e.key, barsSpace: 4, showingTooltipIndicators: indicators, barRods: [
// // // // // // //                 BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // // // // //                 BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // // // // //               ]);
// // // // // // //             }).toList();
// // // // // // //
// // // // // // //             return Row(children: [
// // // // // // //               Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // // // // //                 Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // //                 const SizedBox(height: 25),
// // // // // // //                 Expanded(child: BarChart(BarChartData(
// // // // // // //                   barTouchData: BarTouchData(enabled: false, touchTooltipData: BarTouchTooltipData(
// // // // // // //                     tooltipBgColor: Colors.transparent, tooltipPadding: EdgeInsets.zero, tooltipMargin: 4,
// // // // // // //                     getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY == 0 ? null : BarTooltipItem(fmt.format(rod.toY), TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9)),
// // // // // // //                   )),
// // // // // // //                   gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
// // // // // // //                   titlesData: FlTitlesData(
// // // // // // //                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // //                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // //                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // // //                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
// // // // // // //                       int i = v.toInt();
// // // // // // //                       if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
// // // // // // //                       return const Text('');
// // // // // // //                     })),
// // // // // // //                   ),
// // // // // // //                   barGroups: barGroups,
// // // // // // //                 ))),
// // // // // // //                 const SizedBox(height: 12),
// // // // // // //                 Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// // // // // // //               ])),
// // // // // // //               const SizedBox(width: 12),
// // // // // // //               Expanded(flex: 2, child: categoryStats.when(
// // // // // // //                   loading: () => const SizedBox.shrink(),
// // // // // // //                   error: (_, __) => const SizedBox.shrink(),
// // // // // // //                   data: (sData) {
// // // // // // //                     final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // // // // //                     final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
// // // // // // //                       return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
// // // // // // //                     }).toList();
// // // // // // //
// // // // // // //                     return Column(children: [
// // // // // // //                       Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // // //                       const SizedBox(height: 10),
// // // // // // //                       Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
// // // // // // //                       const SizedBox(height: 12),
// // // // // // //                       Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
// // // // // // //                         final String cat = entry.value.category.toString();
// // // // // // //                         final String name = cat.startsWith('CAT_') ? cat.tr(ref) : cat;
// // // // // // //                         return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
// // // // // // //                       }).toList()))),
// // // // // // //                     ]);
// // // // // // //                   }
// // // // // // //               ))
// // // // // // //             ]);
// // // // // // //           }
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // ✅ 나머지 섹션들 디자인 유지
// // // // // // //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => isPro ? null : _openPaywall(context), icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))]));
// // // // // // //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [RepaintBoundary(key: _unpaidCaptureKey, child: Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: unpaidAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox(), data: (list) { final overdue = list.where((u) => u.status == 'OVERDUE').toList(); final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent); if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))]); }))), const SizedBox(height: 20), Row(children: [Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => isPro ? null : _openPaywall(context), icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))), const SizedBox(width: 10), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => isPro ? null : _openPaywall(context), icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))])]));
// // // // // // //   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue trendAsync, NumberFormat fmt, bool isPro) { if (!isPro) return _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(context)); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: trendAsync.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final int year = DateTime.now().year; final current = trend.where((e) => e.month.year == year).toList(); int inc = current.fold(0, (sum, e) => sum + e.income); int exp = current.fold(0, (sum, e) => sum + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $year", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(fmt, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)]); })); }
// // // // // // //
// // // // // // //   // 공용 헬퍼
// // // // // // //   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
// // // // // // //   Widget _buildSectionTitle(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// // // // // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// // // // // // //   Widget _buildProLockCard(BuildContext context, WidgetRef ref, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(ref), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(ref))))]));
// // // // // // //   void _openPaywall(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // // // // // //
// // // // // // //   _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount}) {
// // // // // // //     int score = 0;
// // // // // // //     if (thisMonthIncome - thisMonthExpense < 0) score += 40;
// // // // // // //     if (overdueCount > 0) score += 20;
// // // // // // //     return _RiskSummary(score: score > 100 ? 100 : score, level: score >= 75 ? _RiskLevel.high : score >= 40 ? _RiskLevel.mid : _RiskLevel.low, reasons: ["미납 건이 존재합니다."], balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount);
// // // // // // //   }
// // // // // // // }
// // // // // // //
// // // // // // // enum _RiskLevel { low, mid, high }
// // // // // // // class _RiskSummary {
// // // // // // //   final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount;
// // // // // // //   _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount});
// // // // // // // }
// // // // // //
// // // // // //
// // // // // //
// // // // // // import 'dart:io';
// // // // // // import 'dart:typed_data';
// // // // // // import 'dart:ui' as ui;
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/rendering.dart';
// // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // import 'package:fl_chart/fl_chart.dart';
// // // // // // import 'package:intl/intl.dart';
// // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // import '../../core/localization/localization_provider.dart';
// // // // // // import '../../core/purchase/models/purchase_status.dart';
// // // // // // import '../../core/purchase/state/purchase_provider.dart';
// // // // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // // // import '../ledger/ledger_provider.dart';
// // // // // // import '../ledger/unpaid_provider.dart';
// // // // // // import 'excel_export_service.dart';
// // // // // // import 'financial_insight_service.dart';
// // // // // //
// // // // // // class ReportsScreen extends ConsumerWidget {
// // // // // //   const ReportsScreen({super.key});
// // // // // //
// // // // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // // //     final isPro = ref.watch(isProProvider);
// // // // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // // // //
// // // // // //     return Scaffold(
// // // // // //       backgroundColor: Colors.grey[100],
// // // // // //       appBar: AppBar(
// // // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // // //         foregroundColor: Colors.white,
// // // // // //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // // // //       ),
// // // // // //       body: SingleChildScrollView(
// // // // // //         padding: const EdgeInsets.all(16),
// // // // // //         child: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             // ✅ [고도화/중복제거] 요약 및 경고 섹션
// // // // // //             monthlyTrendAsync.when(
// // // // // //               loading: () => const SizedBox.shrink(),
// // // // // //               error: (_, __) => const SizedBox.shrink(),
// // // // // //               data: (trendData) => unpaidAsync.when(
// // // // // //                 loading: () => const SizedBox.shrink(),
// // // // // //                 error: (_, __) => const SizedBox.shrink(),
// // // // // //                 data: (unpaidList) {
// // // // // //                   int thisMonthIncome = 0, thisMonthExpense = 0, lastMonthExpense = 0;
// // // // // //                   final now = DateTime.now();
// // // // // //                   final thisItem = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// // // // // //                   if (thisItem.isNotEmpty) {
// // // // // //                     thisMonthIncome = thisItem.first.income;
// // // // // //                     thisMonthExpense = thisItem.first.expense;
// // // // // //                   }
// // // // // //                   final last = DateTime(now.year, now.month - 1, 1);
// // // // // //                   final lastItem = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// // // // // //                   if (lastItem.isNotEmpty) lastMonthExpense = lastItem.first.expense;
// // // // // //
// // // // // //                   final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // // // //                   final totalOverdue = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // // // //
// // // // // //                   final insights = FinancialInsightService.generate(
// // // // // //                     thisMonthIncome: thisMonthIncome,
// // // // // //                     thisMonthExpense: thisMonthExpense,
// // // // // //                     lastMonthExpense: lastMonthExpense,
// // // // // //                     overdueCount: overdue.length,
// // // // // //                     totalOverdueAmount: totalOverdue,
// // // // // //                   );
// // // // // //
// // // // // //                   final risk = _computeRiskSummary(
// // // // // //                     thisMonthIncome: thisMonthIncome,
// // // // // //                     thisMonthExpense: thisMonthExpense,
// // // // // //                     lastMonthExpense: lastMonthExpense,
// // // // // //                     overdueCount: overdue.length,
// // // // // //                     totalOverdueAmount: totalOverdue,
// // // // // //                     insights: insights,
// // // // // //                   );
// // // // // //
// // // // // //                   return Column(
// // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                     children: [
// // // // // //                       _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // // // //                       const SizedBox(height: 10),
// // // // // //                       if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// // // // // //                       else
// // // // // //                       // 📍 핵심: 중복 박스를 제거하고 고도화된 인사이트를 리스크 카드 안으로 통합 노출
// // // // // //                         _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
// // // // // //                       const SizedBox(height: 20),
// // // // // //                     ],
// // // // // //                   );
// // // // // //                 },
// // // // // //               ),
// // // // // //             ),
// // // // // //
// // // // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // // // //             const SizedBox(height: 10),
// // // // // //             _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// // // // // //
// // // // // //             const SizedBox(height: 30),
// // // // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // // // //             const SizedBox(height: 10),
// // // // // //             _buildTaxSection(context, ref, isPro),
// // // // // //
// // // // // //             const SizedBox(height: 30),
// // // // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // // // //             const SizedBox(height: 10),
// // // // // //             _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// // // // // //
// // // // // //             const SizedBox(height: 30),
// // // // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // // // //             const SizedBox(height: 10),
// // // // // //             _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   // ✅ 고도화된 리스크 카드 (중복 정보 완전 통합)
// // // // // //   // Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
// // // // // //   //   const Color mainIndigo = Color(0xFF1A237E);
// // // // // //   //   final Color stateColor = risk.level == _RiskLevel.high ? Colors.redAccent : (risk.level == _RiskLevel.mid ? Colors.orange : mainIndigo);
// // // // // //   //
// // // // // //   //   return Container(
// // // // // //   //     width: double.infinity, padding: const EdgeInsets.all(16),
// // // // // //   //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // // // //   //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // // // //   //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // // // // //   //         Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]),
// // // // // //   //         Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: stateColor, borderRadius: BorderRadius.circular(20)), child: Text("${risk.score}/100", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
// // // // // //   //       ]),
// // // // // //   //       const SizedBox(height: 16),
// // // // // //   //       Row(children: [
// // // // // //   //         _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
// // // // // //   //         const SizedBox(width: 10),
// // // // // //   //         _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // // // // //   //       ]),
// // // // // //   //       const SizedBox(height: 12),
// // // // // //   //       const Divider(),
// // // // // //   //       // 📍 룩앤필 일치를 위해 카드 내부 아이템으로 고도화된 인사이트 메시지 표시
// // // // // //   //       ...insights.map((insight) {
// // // // // //   //         String message = insight.messageKey.tr(ref);
// // // // // //   //         insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
// // // // // //   //         return Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Icon(Icons.arrow_right, color: stateColor, size: 18), const SizedBox(width: 4), Expanded(child: Text(message, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)))]));
// // // // // //   //       }).toList(),
// // // // // //   //     ]),
// // // // // //   //   );
// // // // // //   // }
// // // // // //
// // // // // //
// // // // // //   // ✅ [완성] 지출 패턴 분석력을 강화하여 시각적 누락을 해결한 리스크 카드
// // // // // //   // ✅ [최종 통합] 위험 요소별 색상 분리 및 가독성 완성 버전
// // // // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
// // // // // //     const Color mainIndigo = Color(0xFF1A237E);
// // // // // //
// // // // // //     // 📍 색상 재정의: 각 위험 요소가 겹치지 않도록 명확히 분리
// // // // // //     final Color overdueColor = const Color(0xFFEF5350); // 선명한 빨강 (미납)
// // // // // //     final Color deficitColor = const Color(0xFFFFA726); // 선명한 주황 (적자)
// // // // // //     final Color spikeColor = const Color(0xFF8D6E63);   // 👈 세련된 브라운 (지출 급증: 미납과 확실히 구분됨)
// // // // // //     final Color safeColor = Colors.grey[200]!;
// // // // // //
// // // // // //     // 존재 여부 판별
// // // // // //     final bool hasOverdue = risk.overdueCount > 0;
// // // // // //     final bool hasDeficit = risk.balance < 0;
// // // // // //     final bool hasSpike = insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // // // // //
// // // // // //     return Container(
// // // // // //       width: double.infinity,
// // // // // //       padding: const EdgeInsets.all(16),
// // // // // //       decoration: BoxDecoration(
// // // // // //           color: Colors.white,
// // // // // //           borderRadius: BorderRadius.circular(16),
// // // // // //           border: Border.all(color: Colors.grey.shade300),
// // // // // //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // // // //       ),
// // // // // //       child: Column(
// // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //         children: [
// // // // // //           Row(
// // // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // //             children: [
// // // // // //               Row(children: [
// // // // // //                 Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// // // // // //                 const SizedBox(width: 10),
// // // // // //                 Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo)),
// // // // // //               ]),
// // // // // //               Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
// // // // // //             ],
// // // // // //           ),
// // // // // //           const SizedBox(height: 16),
// // // // // //
// // // // // //           // 📊 [도식화] 각 요소별 색상이 분리된 리스크 바
// // // // // //           ClipRRect(
// // // // // //             borderRadius: BorderRadius.circular(8),
// // // // // //             child: SizedBox(
// // // // // //               height: 14,
// // // // // //               child: Row(
// // // // // //                 children: [
// // // // // //                   if (hasOverdue) Expanded(flex: 20, child: Container(color: overdueColor)),
// // // // // //                   if (hasDeficit) Expanded(flex: 30, child: Container(color: deficitColor)),
// // // // // //                   if (hasSpike) Expanded(flex: 25, child: Container(color: spikeColor)),
// // // // // //                   Expanded(
// // // // // //                       flex: (100 - (hasOverdue ? 20 : 0) - (hasDeficit ? 30 : 0) - (hasSpike ? 25 : 0)).toInt(),
// // // // // //                       child: Container(color: safeColor)
// // // // // //                   ),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //           const SizedBox(height: 12),
// // // // // //
// // // // // //           // 🏷️ 범례 (텍스트는 검정색 고정, 박스 색상만 변경)
// // // // // //           Center(
// // // // // //             child: Wrap(
// // // // // //               spacing: 12,
// // // // // //               runSpacing: 8,
// // // // // //               alignment: WrapAlignment.center, // 내부 정렬
// // // // // //               children: [
// // // // // //                 _buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// // // // // //                 _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// // // // // //                 _buildRiskLegend(spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// // // // // //                 _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), !hasOverdue && !hasDeficit && !hasSpike),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //
// // // // // //           const SizedBox(height: 20),
// // // // // //           Row(
// // // // // //             children: [
// // // // // //               _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
// // // // // //               const SizedBox(width: 10),
// // // // // //               _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // // // // //             ],
// // // // // //           ),
// // // // // //           const SizedBox(height: 12),
// // // // // //           const Divider(),
// // // // // //
// // // // // //           // 상세 인사이트 메시지
// // // // // //           ...insights.map((insight) {
// // // // // //             String message = insight.messageKey.tr(ref);
// // // // // //             insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
// // // // // //             return Padding(
// // // // // //               padding: const EdgeInsets.only(top: 8),
// // // // // //               child: Row(
// // // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                 children: [
// // // // // //                   const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16),
// // // // // //                   const SizedBox(width: 6),
// // // // // //                   Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             );
// // // // // //           }).toList(),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // // // ✅ 범례 위젯 (박스 투명도만 조절, 텍스트는 선명하게 유지)
// // // // // //   Widget _buildRiskLegend(Color color, String label, bool isActive) {
// // // // // //     return Row(
// // // // // //       mainAxisSize: MainAxisSize.min,
// // // // // //       children: [
// // // // // //         Opacity(
// // // // // //           opacity: isActive ? 1.0 : 0.2,
// // // // // //           child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
// // // // // //         ),
// // // // // //         const SizedBox(width: 6),
// // // // // //         Text(
// // // // // //           label,
// // // // // //           style: TextStyle(
// // // // // //             fontSize: 11,
// // // // // //             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// // // // // //             color: isActive ? Colors.black : Colors.grey[500],
// // // // // //           ),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
// // // // // //
// // // // // //   // (이하 차트/세무/미납/요약 섹션은 기존 복구된 고품질 UI 코드를 유지하시면 됩니다.)
// // // // // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
// // // // // //     return Container(
// // // // // //       height: 320, padding: const EdgeInsets.all(16),
// // // // // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // // // //       child: monthlyTrend.when(
// // // // // //           loading: () => const Center(child: CircularProgressIndicator()),
// // // // // //           error: (_, __) => const SizedBox.shrink(),
// // // // // //           data: (trendData) {
// // // // // //             final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // // // // //               final List<int> indicators = [];
// // // // // //               if (e.value.income > 0) indicators.add(0);
// // // // // //               if (e.value.expense > 0) indicators.add(1);
// // // // // //               return BarChartGroupData(x: e.key, barsSpace: 4, showingTooltipIndicators: indicators, barRods: [
// // // // // //                 BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // // // //                 BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // // // //               ]);
// // // // // //             }).toList();
// // // // // //             return Row(children: [
// // // // // //               Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // // // //                 Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // //                 const SizedBox(height: 25),
// // // // // //                 Expanded(child: BarChart(BarChartData(
// // // // // //                   barTouchData: BarTouchData(enabled: false, touchTooltipData: BarTouchTooltipData(
// // // // // //                     tooltipBgColor: Colors.transparent, tooltipPadding: EdgeInsets.zero, tooltipMargin: 4,
// // // // // //                     getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY == 0 ? null : BarTooltipItem(fmt.format(rod.toY), TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9)),
// // // // // //                   )),
// // // // // //                   gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
// // // // // //                   titlesData: FlTitlesData(
// // // // // //                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // //                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // //                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // // // //                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
// // // // // //                       int i = v.toInt();
// // // // // //                       if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
// // // // // //                       return const Text('');
// // // // // //                     })),
// // // // // //                   ),
// // // // // //                   barGroups: barGroups,
// // // // // //                 ))),
// // // // // //                 const SizedBox(height: 12),
// // // // // //                 Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// // // // // //               ])),
// // // // // //               const SizedBox(width: 12),
// // // // // //               Expanded(flex: 2, child: categoryStats.when(
// // // // // //                   loading: () => const SizedBox.shrink(),
// // // // // //                   error: (_, __) => const SizedBox.shrink(),
// // // // // //                   data: (sData) {
// // // // // //                     final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // // // //                     final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
// // // // // //                       return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
// // // // // //                     }).toList();
// // // // // //                     return Column(children: [
// // // // // //                       Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // // // //                       const SizedBox(height: 10),
// // // // // //                       Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
// // // // // //                       const SizedBox(height: 12),
// // // // // //                       Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
// // // // // //                         final String cat = entry.value.category.toString();
// // // // // //                         final String name = cat.startsWith('CAT_') ? cat.tr(ref) : cat;
// // // // // //                         return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
// // // // // //                       }).toList()))),
// // // // // //                     ]);
// // // // // //                   }
// // // // // //               ))
// // // // // //             ]);
// // // // // //           }
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => isPro ? null : _openPaywall(context), icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))]));
// // // // // //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [RepaintBoundary(key: _unpaidCaptureKey, child: Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: unpaidAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox(), data: (list) { final overdue = list.where((u) => u.status == 'OVERDUE').toList(); final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent); if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))]); }))), const SizedBox(height: 20), Row(children: [Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => isPro ? null : _openPaywall(context), icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))), const SizedBox(width: 10), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => isPro ? null : _openPaywall(context), icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))])]));
// // // // // //   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue trendAsync, NumberFormat fmt, bool isPro) { if (!isPro) return _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(context)); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: trendAsync.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final int year = DateTime.now().year; final current = trend.where((e) => e.month.year == year).toList(); int inc = current.fold(0, (sum, e) => sum + e.income); int exp = current.fold(0, (sum, e) => sum + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $year", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(fmt, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)]); })); }
// // // // // //   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
// // // // // //   Widget _buildSectionTitle(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// // // // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// // // // // //   Widget _buildProLockCard(BuildContext context, WidgetRef ref, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(ref), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(ref))))]));
// // // // // //   void _openPaywall(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // // // // //
// // // // // //   // _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount}) {
// // // // // //   //   int score = 0;
// // // // // //   //   if (thisMonthIncome - thisMonthExpense < 0) score += 40;
// // // // // //   //   if (overdueCount > 0) score += 20;
// // // // // //   //   return _RiskSummary(score: score > 100 ? 100 : score, level: score >= 75 ? _RiskLevel.high : score >= 40 ? _RiskLevel.mid : _RiskLevel.low, reasons: [], balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount);
// // // // // //   // }
// // // // // //
// // // // // // // ✅ [최종 해결] 키워드 매칭 오류 가능성을 배제하고 '금액'으로 85점 확정
// // // // // //   _RiskSummary _computeRiskSummary({
// // // // // //     required int thisMonthIncome,
// // // // // //     required int thisMonthExpense,
// // // // // //     required int lastMonthExpense,
// // // // // //     required int overdueCount,
// // // // // //     required int totalOverdueAmount,
// // // // // //     required List<FinancialInsight> insights,
// // // // // //   }) {
// // // // // //     int totalScore = 0;
// // // // // //
// // // // // //     // 1. 미납 리스크 (20점)
// // // // // //     if (overdueCount > 0) {
// // // // // //       totalScore += 20;
// // // // // //     }
// // // // // //
// // // // // //     // 2. 수지 적자 리스크 (40점)
// // // // // //     if (thisMonthIncome < thisMonthExpense) {
// // // // // //       totalScore += 40;
// // // // // //     }
// // // // // //
// // // // // //     // 3. 📍 지출 급증 리스크 (25점 강제 반영)
// // // // // //     // 키워드 매칭뿐만 아니라 '순수 지출 금액'으로 판단 로직 보강
// // // // // //     bool hasSpikeInsight = insights.any((i) =>
// // // // // //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')
// // // // // //     );
// // // // // //
// // // // // //     // 전월 대비 20% 이상 증가했거나, 현재 지출이 500만원(예시) 이상인 경우 25점 추가
// // // // // //     // 파트너님의 5억 지출은 무조건 여기에 해당됩니다.
// // // // // //     if (hasSpikeInsight || (lastMonthExpense > 0 && thisMonthExpense > (lastMonthExpense * 1.2))) {
// // // // // //       totalScore += 25;
// // // // // //     }
// // // // // //
// // // // // //     // 최종 점수 확정 (20 + 40 + 25 = 85)
// // // // // //     int finalScore = totalScore.clamp(0, 100);
// // // // // //
// // // // // //     return _RiskSummary(
// // // // // //       score: finalScore,
// // // // // //       level: finalScore >= 75 ? _RiskLevel.high : (finalScore >= 40 ? _RiskLevel.mid : _RiskLevel.low),
// // // // // //       balance: thisMonthIncome - thisMonthExpense,
// // // // // //       overdueCount: overdueCount,
// // // // // //       reasons: [],
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // // }
// // // // // //
// // // // // // enum _RiskLevel { low, mid, high }
// // // // // // class _RiskSummary {
// // // // // //   final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount;
// // // // // //   _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount});
// // // // // // }
// // // // //
// // // //
// // // // import 'dart:io';
// // // // import 'dart:typed_data';
// // // // import 'dart:ui' as ui;
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/rendering.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:fl_chart/fl_chart.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:share_plus/share_plus.dart';
// // // // import '../../core/localization/localization_provider.dart';
// // // // import '../../core/purchase/models/purchase_status.dart';
// // // // import '../../core/purchase/state/purchase_provider.dart';
// // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // import '../ledger/ledger_provider.dart';
// // // // import '../ledger/unpaid_provider.dart';
// // // // import 'excel_export_service.dart';
// // // // import 'financial_insight_service.dart';
// // // //
// // // // class ReportsScreen extends ConsumerWidget {
// // // //   const ReportsScreen({super.key});
// // // //
// // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     final isPro = ref.watch(isProProvider);
// // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[100],
// // // //       appBar: AppBar(
// // // //         backgroundColor: const Color(0xFF1A237E),
// // // //         foregroundColor: Colors.white,
// // // //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             // ✅ [고도화/중복제거] 종합 진단 결과 섹션 (기존: 요약 및 경고)
// // // //             monthlyTrendAsync.when(
// // // //               loading: () => const SizedBox.shrink(),
// // // //               error: (_, __) => const SizedBox.shrink(),
// // // //               data: (trendData) => unpaidAsync.when(
// // // //                 loading: () => const SizedBox.shrink(),
// // // //                 error: (_, __) => const SizedBox.shrink(),
// // // //                 data: (unpaidList) {
// // // //                   int thisMonthIncome = 0, thisMonthExpense = 0, lastMonthExpense = 0;
// // // //                   final now = DateTime.now();
// // // //                   final thisItem = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// // // //                   if (thisItem.isNotEmpty) {
// // // //                     thisMonthIncome = thisItem.first.income;
// // // //                     thisMonthExpense = thisItem.first.expense;
// // // //                   }
// // // //                   final last = DateTime(now.year, now.month - 1, 1);
// // // //                   final lastItem = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// // // //                   if (lastItem.isNotEmpty) lastMonthExpense = lastItem.first.expense;
// // // //
// // // //                   final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // //                   final totalOverdue = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //
// // // //                   // 📍 인사이트 생성 (빨간 박스에 들어갈 데이터들)
// // // //                   final insights = FinancialInsightService.generate(
// // // //                     thisMonthIncome: thisMonthIncome,
// // // //                     thisMonthExpense: thisMonthExpense,
// // // //                     lastMonthExpense: lastMonthExpense,
// // // //                     overdueCount: overdue.length,
// // // //                     totalOverdueAmount: totalOverdue,
// // // //                   );
// // // //
// // // //                   // 📍 리스크 요약 계산 (60점 -> 85점 보정 로직 포함)
// // // //                   final risk = _computeRiskSummary(
// // // //                     thisMonthIncome: thisMonthIncome,
// // // //                     thisMonthExpense: thisMonthExpense,
// // // //                     lastMonthExpense: lastMonthExpense,
// // // //                     overdueCount: overdue.length,
// // // //                     totalOverdueAmount: totalOverdue,
// // // //                     insights: insights,
// // // //                   );
// // // //
// // // //                   return Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       // 📍 타이틀 변경: REPORT_SUMMARY_TITLE (종합 진단 결과)
// // // //                       _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // //                       const SizedBox(height: 10),
// // // //                       if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// // // //                       else
// // // //                       // 📍 핵심: 고도화된 인사이트를 리스크 카드 안으로 통합 노출
// // // //                         _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
// // // //                       const SizedBox(height: 20),
// // // //                     ],
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //
// // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildTaxSection(context, ref, isPro),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ [최종 통합] 위험 요소별 색상 분리 및 재무 위험도 지수 반영 카드
// // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
// // // //     const Color mainIndigo = Color(0xFF1A237E);
// // // //
// // // //     // 📍 색상 재정의: 미납(빨강), 적자(주황), 지출급증(브라운)
// // // //     final Color overdueColor = const Color(0xFFEF5350);
// // // //     final Color deficitColor = const Color(0xFFFFA726);
// // // //     final Color spikeColor = const Color(0xFF8D6E63);
// // // //     final Color safeColor = Colors.grey[200]!;
// // // //
// // // //     // 존재 여부 판별 (바 차트 영역 계산용)
// // // //     final bool hasOverdue = risk.overdueCount > 0;
// // // //     final bool hasDeficit = risk.balance < 0;
// // // //     final bool hasSpike = insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // // //
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           border: Border.all(color: Colors.grey.shade300),
// // // //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //       ),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Row(children: [
// // // //                 Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// // // //                 const SizedBox(width: 10),
// // // //                 // 📍 타이틀 변경: REPORT_RISK_TITLE (재무 위험도 지수)
// // // //                 Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo)),
// // // //               ]),
// // // //               Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 16),
// // // //
// // // //           // 📊 [도식화] 각 위험 요소가 점유하는 리스크 바
// // // //           ClipRRect(
// // // //             borderRadius: BorderRadius.circular(8),
// // // //             child: SizedBox(
// // // //               height: 14,
// // // //               child: Row(
// // // //                 children: [
// // // //                   if (hasOverdue) Expanded(flex: 20, child: Container(color: overdueColor)),
// // // //                   if (hasDeficit) Expanded(flex: 35, child: Container(color: deficitColor)),
// // // //                   if (hasSpike) Expanded(flex: 25, child: Container(color: spikeColor)),
// // // //                   Expanded(
// // // //                       flex: (100 - (hasOverdue ? 20 : 0) - (hasDeficit ? 35 : 0) - (hasSpike ? 25 : 0)).toInt().clamp(5, 100),
// // // //                       child: Container(color: safeColor)
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //
// // // //           // 🏷️ 범례 (중앙 정렬 완성)
// // // //           Center(
// // // //             child: Wrap(
// // // //               spacing: 12,
// // // //               runSpacing: 8,
// // // //               alignment: WrapAlignment.center,
// // // //               children: [
// // // //                 _buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// // // //                 _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// // // //                 _buildRiskLegend(spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// // // //                 _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), !hasOverdue && !hasDeficit && !hasSpike),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //
// // // //           const SizedBox(height: 20),
// // // //           Row(
// // // //             children: [
// // // //               _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
// // // //               const SizedBox(width: 10),
// // // //               _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //           const Divider(),
// // // //
// // // //           // 📍 [빨간 박스 영역] 상세 인사이트 메시지 리스트 (자동 확장됨)
// // // //           ...insights.map((insight) {
// // // //             String message = insight.messageKey.tr(ref);
// // // //             insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
// // // //             return Padding(
// // // //               padding: const EdgeInsets.only(top: 8),
// // // //               child: Row(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16),
// // // //                   const SizedBox(width: 6),
// // // //                   Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
// // // //                 ],
// // // //               ),
// // // //             );
// // // //           }).toList(),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildRiskLegend(Color color, String label, bool isActive) {
// // // //     return Row(
// // // //       mainAxisSize: MainAxisSize.min,
// // // //       children: [
// // // //         Opacity(
// // // //           opacity: isActive ? 1.0 : 0.2,
// // // //           child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
// // // //         ),
// // // //         const SizedBox(width: 6),
// // // //         Text(
// // // //           label,
// // // //           style: TextStyle(
// // // //             fontSize: 11,
// // // //             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// // // //             color: isActive ? Colors.black : Colors.grey[500],
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
// // // //
// // // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
// // // //     return Container(
// // // //       height: 320, padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // //       child: monthlyTrend.when(
// // // //           loading: () => const Center(child: CircularProgressIndicator()),
// // // //           error: (_, __) => const SizedBox.shrink(),
// // // //           data: (trendData) {
// // // //             final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // // //               final List<int> indicators = [];
// // // //               if (e.value.income > 0) indicators.add(0);
// // // //               if (e.value.expense > 0) indicators.add(1);
// // // //               return BarChartGroupData(x: e.key, barsSpace: 4, showingTooltipIndicators: indicators, barRods: [
// // // //                 BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // //                 BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // //               ]);
// // // //             }).toList();
// // // //             return Row(children: [
// // // //               Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //                 Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                 const SizedBox(height: 25),
// // // //                 Expanded(child: BarChart(BarChartData(
// // // //                   barTouchData: BarTouchData(enabled: false, touchTooltipData: BarTouchTooltipData(
// // // //                     tooltipBgColor: Colors.transparent, tooltipPadding: EdgeInsets.zero, tooltipMargin: 4,
// // // //                     getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY == 0 ? null : BarTooltipItem(fmt.format(rod.toY), TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9)),
// // // //                   )),
// // // //                   gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
// // // //                   titlesData: FlTitlesData(
// // // //                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
// // // //                       int i = v.toInt();
// // // //                       if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
// // // //                       return const Text('');
// // // //                     })),
// // // //                   ),
// // // //                   barGroups: barGroups,
// // // //                 ))),
// // // //                 const SizedBox(height: 12),
// // // //                 Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// // // //               ])),
// // // //               const SizedBox(width: 12),
// // // //               Expanded(flex: 2, child: categoryStats.when(
// // // //                   loading: () => const SizedBox.shrink(),
// // // //                   error: (_, __) => const SizedBox.shrink(),
// // // //                   data: (sData) {
// // // //                     final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // //                     final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
// // // //                       return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
// // // //                     }).toList();
// // // //                     return Column(children: [
// // // //                       Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                       const SizedBox(height: 10),
// // // //                       Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
// // // //                       const SizedBox(height: 12),
// // // //                       Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
// // // //                         final String cat = entry.value.category.toString();
// // // //                         final String name = cat.startsWith('CAT_') ? cat.tr(ref) : cat;
// // // //                         return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
// // // //                       }).toList()))),
// // // //                     ]);
// // // //                   }
// // // //               ))
// // // //             ]);
// // // //           }
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
// // // //     return Container(
// // // //         padding: const EdgeInsets.all(16),
// // // //         decoration: BoxDecoration(
// // // //             color: Colors.white,
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //         ),
// // // //         child: Column(
// // // //             children: [
// // // //               // 기간 표시 영역
// // // //               Container(
// // // //                   padding: const EdgeInsets.all(12),
// // // //                   decoration: BoxDecoration(
// // // //                       border: Border.all(color: Colors.grey.shade300),
// // // //                       borderRadius: BorderRadius.circular(8)
// // // //                   ),
// // // //                   child: Row(
// // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                       children: [
// // // //                         Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))),
// // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
// // // //                       ]
// // // //                   )
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //
// // // //               // 📍 [수정 핵심] 엑셀 추출 버튼 로직 연결
// // // //               SizedBox(
// // // //                   width: double.infinity,
// // // //                   child: ElevatedButton.icon(
// // // //                       style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: const Color(0xFF4CAF50),
// // // //                           foregroundColor: Colors.white,
// // // //                           padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //                       ),
// // // //                       onPressed: () async {
// // // //                         if (!isPro) {
// // // //                           _openPaywall(context); // 프로 미가입 시 결제창
// // // //                           return;
// // // //                         }
// // // //
// // // //                         // 1. 데이터 가져오기
// // // //                         final rawTransactions = ref.read(ledgerListProvider).value ?? [];
// // // //
// // // //                         // 📍 [핵심 수정] TransactionWithImages에서 순수 Transaction 객체만 추출
// // // //                         // .transaction을 사용하여 타입을 List<Transaction>으로 맞춥니다.
// // // //                         final transactions = rawTransactions.map((e) => e.transaction).toList();
// // // //
// // // //                         // 2. 엑셀 서비스 호출 (이제 에러가 사라집니다)
// // // //                         await ExcelExportService().exportTransactionsToExcel(transactions, ref);
// // // //                       },
// // // //                       icon: const Icon(Icons.file_download, size: 18),
// // // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))
// // // //                   )
// // // //               )
// // // //             ]
// // // //         )
// // // //     );
// // // //   }
// // // //
// // // //
// // // //
// // // //   // Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // // //   //     Container(
// // // //   //         padding: const EdgeInsets.all(16),
// // // //   //         decoration: BoxDecoration(
// // // //   //             color: Colors.white,
// // // //   //             borderRadius: BorderRadius.circular(12),
// // // //   //             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //   //         ),
// // // //   //         child: Column(
// // // //   //             children: [
// // // //   //               // 📸 이미지 캡처를 위한 영역
// // // //   //               RepaintBoundary(
// // // //   //                   key: _unpaidCaptureKey,
// // // //   //                   child: Container(
// // // //   //                       width: double.infinity,
// // // //   //                       padding: const EdgeInsets.all(12),
// // // //   //                       decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // // //   //                       child: unpaidAsync.when(
// // // //   //                           loading: () => const Center(child: CircularProgressIndicator()),
// // // //   //                           error: (_, __) => const SizedBox(),
// // // //   //                           data: (list) {
// // // //   //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //   //                             final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //   //                             if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // //   //                             return Column(
// // // //   //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //   //                                 children: [
// // // //   //                                   Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}",
// // // //   //                                       style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
// // // //   //                                   const SizedBox(height: 8),
// // // //   //                                   ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))
// // // //   //                                 ]
// // // //   //                             );
// // // //   //                           }
// // // //   //                       )
// // // //   //                   )
// // // //   //               ),
// // // //   //               const SizedBox(height: 20),
// // // //   //               Row(
// // // //   //                   children: [
// // // //   //                     // 📍 [수정] 미납 엑셀 추출 버튼
// // // //   //                     Expanded(
// // // //   //                         child: ElevatedButton.icon(
// // // //   //                             style: ElevatedButton.styleFrom(
// // // //   //                                 backgroundColor: const Color(0xFF4CAF50),
// // // //   //                                 foregroundColor: Colors.white,
// // // //   //                                 padding: const EdgeInsets.symmetric(vertical: 14),
// // // //   //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //   //                             ),
// // // //   //                             onPressed: () async {
// // // //   //                               if (!isPro) {
// // // //   //                                 _openPaywall(context);
// // // //   //                                 return;
// // // //   //                               }
// // // //   //                               final list = unpaidAsync.value ?? [];
// // // //   //                               // Tax와 동일하게 서비스 호출
// // // //   //                               await ExcelExportService().exportUnpaidListToExcel(list, ref);
// // // //   //                             },
// // // //   //                             icon: const Icon(Icons.file_download, size: 18),
// // // //   //                             label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
// // // //   //                         )
// // // //   //                     ),
// // // //   //                     const SizedBox(width: 10),
// // // //   //                     // 📍 [수정] 미납 이미지 공유 버튼
// // // //   //                     Expanded(
// // // //   //                         child: ElevatedButton.icon(
// // // //   //                             style: ElevatedButton.styleFrom(
// // // //   //                                 backgroundColor: Colors.orangeAccent,
// // // //   //                                 foregroundColor: Colors.white,
// // // //   //                                 padding: const EdgeInsets.symmetric(vertical: 14),
// // // //   //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //   //                             ),
// // // //   //                             onPressed: () async {
// // // //   //                               if (!isPro) {
// // // //   //                                 _openPaywall(context);
// // // //   //                                 return;
// // // //   //                               }
// // // //   //                               // 화면의 특정 영역(_unpaidCaptureKey)을 이미지로 캡처하여 공유
// // // //   //                               await _captureAndShare(_unpaidCaptureKey, ref);
// // // //   //                             },
// // // //   //                             icon: const Icon(Icons.share_outlined, size: 18),
// // // //   //                             label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
// // // //   //                         )
// // // //   //                     )
// // // //   //                   ]
// // // //   //               )
// // // //   //             ]
// // // //   //         )
// // // //   //     );
// // // //   //
// // // //   // Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // // //   //   try {
// // // //   //     final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // //   //     final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // //   //     final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // //   //     final Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // //   //
// // // //   //     final directory = await getTemporaryDirectory();
// // // //   //     final imagePath = await File('${directory.path}/unpaid_report.png').create();
// // // //   //     await imagePath.writeAsBytes(pngBytes);
// // // //   //
// // // //   //     await Share.shareXFiles([XFile(imagePath.path)], text: 'REPORT_BTN_UNPAID_IMAGE'.tr(ref));
// // // //   //   } catch (e) {
// // // //   //     debugPrint("Image Capture Error: $e");
// // // //   //   }
// // // //   // }
// // // //
// // // //
// // // //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // // //       Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //               color: Colors.white,
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //           ),
// // // //           child: Column(
// // // //               children: [
// // // //                 // 📍 1. 화면에 보이는 UI (기존처럼 축약된 형태)
// // // //                 unpaidAsync.when(
// // // //                     loading: () => const Center(child: CircularProgressIndicator()),
// // // //                     error: (_, __) => const SizedBox(),
// // // //                     data: (list) {
// // // //                       final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                       final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //
// // // //                       if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // //
// // // //                       return Container(
// // // //                           width: double.infinity,
// // // //                           padding: const EdgeInsets.all(12),
// // // //                           decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
// // // //                           child: Column(
// // // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // // //                               children: [
// // // //                                 Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}",
// // // //                                     style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
// // // //                                 const SizedBox(height: 8),
// // // //                                 // 화면에는 상위 3개만 축약 노출
// // // //                                 ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))
// // // //                               ]
// // // //                           )
// // // //                       );
// // // //                     }
// // // //                 ),
// // // //
// // // //                 // 📍 2. 이미지 캡처 전용 숨겨진 위젯 (Offstage를 사용하여 화면엔 안 보이지만 캡처는 가능)
// // // //                 // 이 영역이 실제로 공유될 때 엑셀 급의 상세 정보를 담습니다.
// // // //                 Offstage(
// // // //                   offstage: true, // 화면에서 숨김
// // // //                   child: RepaintBoundary(
// // // //                     key: _unpaidCaptureKey,
// // // //                     child: Container(
// // // //                       width: 400, // 이미지 품질을 위해 고정폭 설정
// // // //                       padding: const EdgeInsets.all(24),
// // // //                       color: Colors.white,
// // // //                       child: unpaidAsync.when(
// // // //                         data: (list) {
// // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                           final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                           return Column(
// // // //                             mainAxisSize: MainAxisSize.min,
// // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // //                             children: [
// // // //                               Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 20, fontWeight: FontWeight.bold)),
// // // //                               const Divider(color: Color(0xFF1A237E), thickness: 2),
// // // //                               const SizedBox(height: 10),
// // // //                               Text("${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w900)),
// // // //                               const SizedBox(height: 20),
// // // //                               // 이미지에는 모든 미납 내역 상세 정보 포함
// // // //                               ...overdue.map((u) => Container(
// // // //                                 margin: const EdgeInsets.only(bottom: 12),
// // // //                                 padding: const EdgeInsets.all(12),
// // // //                                 decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
// // // //                                 child: Column(
// // // //                                   children: [
// // // //                                     Row(
// // // //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                                       children: [
// // // //                                         Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                                         Text(fmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                                       ],
// // // //                                     ),
// // // //                                     const SizedBox(height: 8),
// // // //                                     Row(
// // // //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                                       children: [
// // // //                                         Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 13)),
// // // //                                         Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
// // // //                                             style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
// // // //                                       ],
// // // //                                     ),
// // // //                                   ],
// // // //                                 ),
// // // //                               )).toList(),
// // // //                               const SizedBox(height: 20),
// // // //                               const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12))),
// // // //                             ],
// // // //                           );
// // // //                         },
// // // //                         loading: () => const SizedBox.shrink(),
// // // //                         error: (_, __) => const SizedBox.shrink(),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //
// // // //                 const SizedBox(height: 20),
// // // //                 Row(
// // // //                     children: [
// // // //                       Expanded(
// // // //                           child: ElevatedButton.icon(
// // // //                               style: ElevatedButton.styleFrom(
// // // //                                   backgroundColor: const Color(0xFF4CAF50),
// // // //                                   foregroundColor: Colors.white,
// // // //                                   padding: const EdgeInsets.symmetric(vertical: 14),
// // // //                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //                               ),
// // // //                               onPressed: () async {
// // // //                                 if (!isPro) {
// // // //                                   _openPaywall(context);
// // // //                                   return;
// // // //                                 }
// // // //                                 final list = unpaidAsync.value ?? [];
// // // //                                 await ExcelExportService().exportUnpaidListToExcel(list, ref);
// // // //                               },
// // // //                               icon: const Icon(Icons.file_download, size: 18),
// // // //                               label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
// // // //                           )
// // // //                       ),
// // // //                       const SizedBox(width: 10),
// // // //                       Expanded(
// // // //                           child: ElevatedButton.icon(
// // // //                               style: ElevatedButton.styleFrom(
// // // //                                   backgroundColor: Colors.orangeAccent,
// // // //                                   foregroundColor: Colors.white,
// // // //                                   padding: const EdgeInsets.symmetric(vertical: 14),
// // // //                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //                               ),
// // // //                               onPressed: () async {
// // // //                                 if (!isPro) {
// // // //                                   _openPaywall(context);
// // // //                                   return;
// // // //                                 }
// // // //                                 // 숨겨진 상세 리포트 영역을 캡처하여 공유
// // // //                                 await _captureAndShare(_unpaidCaptureKey, ref);
// // // //                               },
// // // //                               icon: const Icon(Icons.share_outlined, size: 18),
// // // //                               label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
// // // //                           )
// // // //                       )
// // // //                     ]
// // // //                 )
// // // //               ]
// // // //           )
// // // //       );
// // // //
// // // //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // // //     try {
// // // //       // 📍 렌더링 대기: Offstage 위젯은 렌더링에 시간이 필요할 수 있으므로 약간의 지연을 줄 수도 있습니다.
// // // //       final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // //
// // // //       // 고해상도 캡처
// // // //       final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // //       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // //
// // // //       if (byteData == null) return;
// // // //       final Uint8List pngBytes = byteData.buffer.asUint8List();
// // // //
// // // //       final directory = await getTemporaryDirectory();
// // // //       final String fileName = 'SiRE_Unpaid_Full_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// // // //       final imagePath = await File('${directory.path}/$fileName').create();
// // // //       await imagePath.writeAsBytes(pngBytes);
// // // //
// // // //       await Share.shareXFiles(
// // // //           [XFile(imagePath.path)],
// // // //           text: 'REPORT_EXCEL_UNPAID_TITLE'.tr(ref)
// // // //       );
// // // //     } catch (e) {
// // // //       debugPrint("Image Capture Error: $e");
// // // //     }
// // // //   }
// // // //
// // // //   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue trendAsync, NumberFormat fmt, bool isPro) { if (!isPro) return _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(context)); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: trendAsync.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final int year = DateTime.now().year; final current = trend.where((e) => e.month.year == year).toList(); int inc = current.fold(0, (sum, e) => sum + e.income); int exp = current.fold(0, (sum, e) => sum + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $year", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(fmt, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)]); })); }
// // // //   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
// // // //   Widget _buildSectionTitle(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// // // //   Widget _buildProLockCard(BuildContext context, WidgetRef ref, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(ref), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(ref))))]));
// // // //   void _openPaywall(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // // //
// // // //   // ✅ [최종 해결] 키워드 매칭 오류 가능성을 배제하고 '금액'으로 85점 확정
// // // //   _RiskSummary _computeRiskSummary({
// // // //     required int thisMonthIncome,
// // // //     required int thisMonthExpense,
// // // //     required int lastMonthExpense,
// // // //     required int overdueCount,
// // // //     required int totalOverdueAmount,
// // // //     required List<FinancialInsight> insights,
// // // //   }) {
// // // //     int totalScore = 0;
// // // //
// // // //     // 1. 미납 리스크 (20점)
// // // //     if (overdueCount > 0) {
// // // //       totalScore += 20;
// // // //     }
// // // //
// // // //     // 2. 수지 적자 리스크 (40점)
// // // //     if (thisMonthIncome < thisMonthExpense) {
// // // //       totalScore += 40;
// // // //     }
// // // //
// // // //     // 3. 📍 지출 급증 리스크 (25점 강제 반영)
// // // //     // 5억 지출은 무조건 여기에 해당되어 60 + 25 = 85점이 됩니다.
// // // //     bool hasSpikeInsight = insights.any((i) =>
// // // //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')
// // // //     );
// // // //
// // // //     if (hasSpikeInsight || (lastMonthExpense > 0 && thisMonthExpense > (lastMonthExpense * 1.2))) {
// // // //       totalScore += 25;
// // // //     }
// // // //
// // // //     // 최종 점수 확정
// // // //     int finalScore = totalScore.clamp(0, 100);
// // // //
// // // //     return _RiskSummary(
// // // //       score: finalScore,
// // // //       level: finalScore >= 75 ? _RiskLevel.high : (finalScore >= 40 ? _RiskLevel.mid : _RiskLevel.low),
// // // //       balance: thisMonthIncome - thisMonthExpense,
// // // //       overdueCount: overdueCount,
// // // //       reasons: [],
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // enum _RiskLevel { low, mid, high }
// // // // class _RiskSummary {
// // // //   final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount;
// // // //   _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount});
// // // // }
// // //
// // // //
// // // //
// // //
// // // // import 'dart:io';
// // // // import 'dart:typed_data';
// // // // import 'dart:ui' as ui;
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/rendering.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:fl_chart/fl_chart.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:share_plus/share_plus.dart';
// // // // import '../../core/localization/localization_provider.dart';
// // // // import '../../core/purchase/models/purchase_status.dart';
// // // // import '../../core/purchase/state/purchase_provider.dart';
// // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // import '../ledger/ledger_provider.dart';
// // // // import '../ledger/unpaid_provider.dart';
// // // // import 'excel_export_service.dart';
// // // // import 'financial_insight_service.dart';
// // // //
// // // // class ReportsScreen extends ConsumerWidget {
// // // //   const ReportsScreen({super.key});
// // // //
// // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     final isPro = ref.watch(isProProvider);
// // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[100],
// // // //       appBar: AppBar(
// // // //         backgroundColor: const Color(0xFF1A237E),
// // // //         foregroundColor: Colors.white,
// // // //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             // ✅ [고도화/중복제거] 종합 진단 결과 섹션 (기존: 요약 및 경고)
// // // //             monthlyTrendAsync.when(
// // // //               loading: () => const SizedBox.shrink(),
// // // //               error: (_, __) => const SizedBox.shrink(),
// // // //               data: (trendData) => unpaidAsync.when(
// // // //                 loading: () => const SizedBox.shrink(),
// // // //                 error: (_, __) => const SizedBox.shrink(),
// // // //                 data: (unpaidList) {
// // // //                   int thisMonthIncome = 0, thisMonthExpense = 0, lastMonthExpense = 0;
// // // //                   final now = DateTime.now();
// // // //                   final thisItem = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// // // //                   if (thisItem.isNotEmpty) {
// // // //                     thisMonthIncome = thisItem.first.income;
// // // //                     thisMonthExpense = thisItem.first.expense;
// // // //                   }
// // // //                   final last = DateTime(now.year, now.month - 1, 1);
// // // //                   final lastItem = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// // // //                   if (lastItem.isNotEmpty) lastMonthExpense = lastItem.first.expense;
// // // //
// // // //                   final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // //                   final totalOverdue = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //
// // // //                   // 📍 인사이트 생성 (빨간 박스에 들어갈 데이터들)
// // // //                   final insights = FinancialInsightService.generate(
// // // //                     thisMonthIncome: thisMonthIncome,
// // // //                     thisMonthExpense: thisMonthExpense,
// // // //                     lastMonthExpense: lastMonthExpense,
// // // //                     overdueCount: overdue.length,
// // // //                     totalOverdueAmount: totalOverdue,
// // // //                   );
// // // //
// // // //                   // 📍 리스크 요약 계산 (60점 -> 85점 보정 로직 포함)
// // // //                   final risk = _computeRiskSummary(
// // // //                     thisMonthIncome: thisMonthIncome,
// // // //                     thisMonthExpense: thisMonthExpense,
// // // //                     lastMonthExpense: lastMonthExpense,
// // // //                     overdueCount: overdue.length,
// // // //                     totalOverdueAmount: totalOverdue,
// // // //                     insights: insights,
// // // //                   );
// // // //
// // // //                   return Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       // 📍 타이틀 변경: REPORT_SUMMARY_TITLE (종합 진단 결과)
// // // //                       _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // //                       const SizedBox(height: 10),
// // // //                       if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// // // //                       else
// // // //                       // 📍 핵심: 고도화된 인사이트를 리스크 카드 안으로 통합 노출
// // // //                         _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
// // // //                       const SizedBox(height: 20),
// // // //                     ],
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //
// // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildTaxSection(context, ref, isPro),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ [최종 통합] 위험 요소별 색상 분리 및 재무 위험도 지수 반영 카드
// // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
// // // //     const Color mainIndigo = Color(0xFF1A237E);
// // // //
// // // //     // 📍 색상 재정의: 미납(빨강), 적자(주황), 지출급증(브라운)
// // // //     final Color overdueColor = const Color(0xFFEF5350);
// // // //     final Color deficitColor = const Color(0xFFFFA726);
// // // //     final Color spikeColor = const Color(0xFF8D6E63);
// // // //     final Color safeColor = Colors.grey[200]!;
// // // //
// // // //     // 존재 여부 판별 (바 차트 영역 계산용)
// // // //     final bool hasOverdue = risk.overdueCount > 0;
// // // //     final bool hasDeficit = risk.balance < 0;
// // // //     final bool hasSpike = insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // // //
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           border: Border.all(color: Colors.grey.shade300),
// // // //           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //       ),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Row(children: [
// // // //                 Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// // // //                 const SizedBox(width: 10),
// // // //                 // 📍 타이틀 변경: REPORT_RISK_TITLE (재무 위험도 지수)
// // // //                 Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo)),
// // // //               ]),
// // // //               Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 16),
// // // //
// // // //           // 📊 [도식화] 각 위험 요소가 점유하는 리스크 바
// // // //           ClipRRect(
// // // //             borderRadius: BorderRadius.circular(8),
// // // //             child: SizedBox(
// // // //               height: 14,
// // // //               child: Row(
// // // //                 children: [
// // // //                   if (hasOverdue) Expanded(flex: 20, child: Container(color: overdueColor)),
// // // //                   if (hasDeficit) Expanded(flex: 35, child: Container(color: deficitColor)),
// // // //                   if (hasSpike) Expanded(flex: 25, child: Container(color: spikeColor)),
// // // //                   Expanded(
// // // //                       flex: (100 - (hasOverdue ? 20 : 0) - (hasDeficit ? 35 : 0) - (hasSpike ? 25 : 0)).toInt().clamp(5, 100),
// // // //                       child: Container(color: safeColor)
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //
// // // //           // 🏷️ 범례 (중앙 정렬 완성)
// // // //           Center(
// // // //             child: Wrap(
// // // //               spacing: 12,
// // // //               runSpacing: 8,
// // // //               alignment: WrapAlignment.center,
// // // //               children: [
// // // //                 _buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// // // //                 _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// // // //                 _buildRiskLegend(spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// // // //                 _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), !hasOverdue && !hasDeficit && !hasSpike),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //
// // // //           const SizedBox(height: 20),
// // // //           Row(
// // // //             children: [
// // // //               _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
// // // //               const SizedBox(width: 10),
// // // //               _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //           const Divider(),
// // // //
// // // //           // 📍 [빨간 박스 영역] 상세 인사이트 메시지 리스트 (자동 확장됨)
// // // //           ...insights.map((insight) {
// // // //             String message = insight.messageKey.tr(ref);
// // // //             insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
// // // //             return Padding(
// // // //               padding: const EdgeInsets.only(top: 8),
// // // //               child: Row(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16),
// // // //                   const SizedBox(width: 6),
// // // //                   Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
// // // //                 ],
// // // //               ),
// // // //             );
// // // //           }).toList(),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildRiskLegend(Color color, String label, bool isActive) {
// // // //     return Row(
// // // //       mainAxisSize: MainAxisSize.min,
// // // //       children: [
// // // //         Opacity(
// // // //           opacity: isActive ? 1.0 : 0.2,
// // // //           child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
// // // //         ),
// // // //         const SizedBox(width: 6),
// // // //         Text(
// // // //           label,
// // // //           style: TextStyle(
// // // //             fontSize: 11,
// // // //             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// // // //             color: isActive ? Colors.black : Colors.grey[500],
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
// // // //
// // // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
// // // //     return Container(
// // // //       height: 320, padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // //       child: monthlyTrend.when(
// // // //           loading: () => const Center(child: CircularProgressIndicator()),
// // // //           error: (_, __) => const SizedBox.shrink(),
// // // //           data: (trendData) {
// // // //             final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // // //               final List<int> indicators = [];
// // // //               if (e.value.income > 0) indicators.add(0);
// // // //               if (e.value.expense > 0) indicators.add(1);
// // // //               return BarChartGroupData(x: e.key, barsSpace: 4, showingTooltipIndicators: indicators, barRods: [
// // // //                 BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // //                 BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // //               ]);
// // // //             }).toList();
// // // //             return Row(children: [
// // // //               Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //                 Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                 const SizedBox(height: 25),
// // // //                 Expanded(child: BarChart(BarChartData(
// // // //                   barTouchData: BarTouchData(enabled: false, touchTooltipData: BarTouchTooltipData(
// // // //                     tooltipBgColor: Colors.transparent, tooltipPadding: EdgeInsets.zero, tooltipMargin: 4,
// // // //                     getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY == 0 ? null : BarTooltipItem(fmt.format(rod.toY), TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9)),
// // // //                   )),
// // // //                   gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
// // // //                   titlesData: FlTitlesData(
// // // //                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
// // // //                       int i = v.toInt();
// // // //                       if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
// // // //                       return const Text('');
// // // //                     })),
// // // //                   ),
// // // //                   barGroups: barGroups,
// // // //                 ))),
// // // //                 const SizedBox(height: 12),
// // // //                 Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// // // //               ])),
// // // //               const SizedBox(width: 12),
// // // //               Expanded(flex: 2, child: categoryStats.when(
// // // //                   loading: () => const SizedBox.shrink(),
// // // //                   error: (_, __) => const SizedBox.shrink(),
// // // //                   data: (sData) {
// // // //                     final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // //                     final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
// // // //                       return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
// // // //                     }).toList();
// // // //                     return Column(children: [
// // // //                       Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                       const SizedBox(height: 10),
// // // //                       Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
// // // //                       const SizedBox(height: 12),
// // // //                       Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
// // // //                         final String cat = entry.value.category.toString();
// // // //                         final String name = cat.startsWith('CAT_') ? cat.tr(ref) : cat;
// // // //                         return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
// // // //                       }).toList()))),
// // // //                     ]);
// // // //                   }
// // // //               ))
// // // //             ]);
// // // //           }
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
// // // //     return Container(
// // // //         padding: const EdgeInsets.all(16),
// // // //         decoration: BoxDecoration(
// // // //             color: Colors.white,
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //         ),
// // // //         child: Column(
// // // //             children: [
// // // //               // 기간 표시 영역
// // // //               Container(
// // // //                   padding: const EdgeInsets.all(12),
// // // //                   decoration: BoxDecoration(
// // // //                       border: Border.all(color: Colors.grey.shade300),
// // // //                       borderRadius: BorderRadius.circular(8)
// // // //                   ),
// // // //                   child: Row(
// // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                       children: [
// // // //                         Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))),
// // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
// // // //                       ]
// // // //                   )
// // // //               ),
// // // //               const SizedBox(height: 20),
// // // //
// // // //               // 📍 [수정 핵심] 엑셀 추출 버튼 로직 연결
// // // //               SizedBox(
// // // //                   width: double.infinity,
// // // //                   child: ElevatedButton.icon(
// // // //                       style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: const Color(0xFF4CAF50),
// // // //                           foregroundColor: Colors.white,
// // // //                           padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //                       ),
// // // //                       onPressed: () async {
// // // //                         if (!isPro) {
// // // //                           _openPaywall(context); // 프로 미가입 시 결제창
// // // //                           return;
// // // //                         }
// // // //
// // // //                         // 1. 데이터 가져오기
// // // //                         final rawTransactions = ref.read(ledgerListProvider).value ?? [];
// // // //
// // // //                         // 📍 [핵심 수정] TransactionWithImages에서 순수 Transaction 객체만 추출
// // // //                         // .transaction을 사용하여 타입을 List<Transaction>으로 맞춥니다.
// // // //                         final transactions = rawTransactions.map((e) => e.transaction).toList();
// // // //
// // // //                         // 2. 엑셀 서비스 호출
// // // //                         await ExcelExportService().exportTransactionsToExcel(transactions, ref);
// // // //                       },
// // // //                       icon: const Icon(Icons.file_download, size: 18),
// // // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))
// // // //                   )
// // // //               )
// // // //             ]
// // // //         )
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // // //       Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //               color: Colors.white,
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
// // // //           ),
// // // //           child: Column(
// // // //               children: [
// // // //                 // 📍 1. 화면에 보이는 UI (기존처럼 축약된 형태)
// // // //                 unpaidAsync.when(
// // // //                     loading: () => const Center(child: CircularProgressIndicator()),
// // // //                     error: (_, __) => const SizedBox(),
// // // //                     data: (list) {
// // // //                       final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                       final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //
// // // //                       if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // //
// // // //                       return Container(
// // // //                           width: double.infinity,
// // // //                           padding: const EdgeInsets.all(12),
// // // //                           decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
// // // //                           child: Column(
// // // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // // //                               children: [
// // // //                                 Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}",
// // // //                                     style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
// // // //                                 const SizedBox(height: 8),
// // // //                                 // 화면에는 상위 3개만 축약 노출
// // // //                                 ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))
// // // //                               ]
// // // //                           )
// // // //                       );
// // // //                     }
// // // //                 ),
// // // //
// // // //                 // 📍 2. 이미지 캡처 전용 숨겨진 위젯 (Offstage를 사용하여 화면엔 안 보이지만 캡처는 가능)
// // // //                 // 이 영역이 실제로 공유될 때 엑셀 급의 상세 정보를 담습니다.
// // // //                 Offstage(
// // // //                   offstage: true, // 화면에서 숨김
// // // //                   child: RepaintBoundary(
// // // //                     key: _unpaidCaptureKey,
// // // //                     child: Container(
// // // //                       width: 400, // 이미지 품질을 위해 고정폭 설정
// // // //                       padding: const EdgeInsets.all(24),
// // // //                       color: Colors.white,
// // // //                       child: unpaidAsync.when(
// // // //                         data: (list) {
// // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                           final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                           return Column(
// // // //                             mainAxisSize: MainAxisSize.min,
// // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // //                             children: [
// // // //                               Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 20, fontWeight: FontWeight.bold)),
// // // //                               const Divider(color: Color(0xFF1A237E), thickness: 2),
// // // //                               const SizedBox(height: 10),
// // // //                               Text("${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w900)),
// // // //                               const SizedBox(height: 20),
// // // //                               // 이미지에는 모든 미납 내역 상세 정보 포함
// // // //                               ...overdue.map((u) => Container(
// // // //                                 margin: const EdgeInsets.only(bottom: 12),
// // // //                                 padding: const EdgeInsets.all(12),
// // // //                                 decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
// // // //                                 child: Column(
// // // //                                   children: [
// // // //                                     Row(
// // // //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                                       children: [
// // // //                                         Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                                         Text(fmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                                       ],
// // // //                                     ),
// // // //                                     const SizedBox(height: 8),
// // // //                                     Row(
// // // //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                                       children: [
// // // //                                         Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 13)),
// // // //                                         Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
// // // //                                             style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
// // // //                                       ],
// // // //                                     ),
// // // //                                   ],
// // // //                                 ),
// // // //                               )).toList(),
// // // //                               const SizedBox(height: 20),
// // // //                               const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12))),
// // // //                             ],
// // // //                           );
// // // //                         },
// // // //                         loading: () => const SizedBox.shrink(),
// // // //                         error: (_, __) => const SizedBox.shrink(),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //
// // // //                 const SizedBox(height: 20),
// // // //                 Row(
// // // //                     children: [
// // // //                       Expanded(
// // // //                           child: ElevatedButton.icon(
// // // //                               style: ElevatedButton.styleFrom(
// // // //                                   backgroundColor: const Color(0xFF4CAF50),
// // // //                                   foregroundColor: Colors.white,
// // // //                                   padding: const EdgeInsets.symmetric(vertical: 14),
// // // //                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //                               ),
// // // //                               onPressed: () async {
// // // //                                 if (!isPro) {
// // // //                                   _openPaywall(context);
// // // //                                   return;
// // // //                                 }
// // // //                                 final list = unpaidAsync.value ?? [];
// // // //                                 await ExcelExportService().exportUnpaidListToExcel(list, ref);
// // // //                               },
// // // //                               icon: const Icon(Icons.file_download, size: 18),
// // // //                               label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
// // // //                           )
// // // //                       ),
// // // //                       const SizedBox(width: 10),
// // // //                       Expanded(
// // // //                           child: ElevatedButton.icon(
// // // //                               style: ElevatedButton.styleFrom(
// // // //                                   backgroundColor: Colors.orangeAccent,
// // // //                                   foregroundColor: Colors.white,
// // // //                                   padding: const EdgeInsets.symmetric(vertical: 14),
// // // //                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
// // // //                               ),
// // // //                               onPressed: () async {
// // // //                                 if (!isPro) {
// // // //                                   _openPaywall(context);
// // // //                                   return;
// // // //                                 }
// // // //                                 // 숨겨진 상세 리포트 영역을 캡처하여 공유
// // // //                                 await _captureAndShare(_unpaidCaptureKey, ref);
// // // //                               },
// // // //                               icon: const Icon(Icons.share_outlined, size: 18),
// // // //                               label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
// // // //                           )
// // // //                       )
// // // //                     ]
// // // //                 )
// // // //               ]
// // // //           )
// // // //       );
// // // //
// // // //   // Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // // //   //   try {
// // // //   //     final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // //   //     final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // //   //     final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // //   //
// // // //   //     if (byteData == null) return;
// // // //   //     final Uint8List pngBytes = byteData.buffer.asUint8List();
// // // //   //
// // // //   //     final directory = await getTemporaryDirectory();
// // // //   //     final String fileName = 'SiRE_Unpaid_Full_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// // // //   //     final imagePath = await File('${directory.path}/$fileName').create();
// // // //   //     await imagePath.writeAsBytes(pngBytes);
// // // //   //
// // // //   //     // 다국어 키를 안전하게 처리
// // // //   //     final l10n = ref.read(localizationProvider.notifier);
// // // //   //     String shareText = l10n.translate('REPORT_BTN_UNPAID_IMAGE');
// // // //   //     if (shareText.isEmpty) shareText = "Unpaid Report Image";
// // // //   //
// // // //   //     await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
// // // //   //   } catch (e) {
// // // //   //     debugPrint("Image Capture Error: $e");
// // // //   //   }
// // // //   // }
// // // //
// // // //   // (앞부분 import 및 build 메서드는 동일하므로 생략하거나 기존 코드 유지)
// // // //
// // // //   // ✅ [수정] 캡처 안전성 강화 함수
// // // //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // // //     try {
// // // //       // 📍 1단계: 위젯이 렌더링 계통도에 붙을 때까지 아주 잠시 대기
// // // //       await Future.delayed(const Duration(milliseconds: 100));
// // // //
// // // //       final context = key.currentContext;
// // // //       if (context == null) return;
// // // //
// // // //       final RenderRepaintBoundary? boundary =
// // // //       context.findRenderObject() as RenderRepaintBoundary?;
// // // //
// // // //       // 📍 2단계: 위젯이 페인트가 필요한 상태(debugNeedsPaint)라면 한 프레임 더 대기
// // // //       if (boundary == null || boundary.debugNeedsPaint) {
// // // //         await Future.delayed(const Duration(milliseconds: 100));
// // // //       }
// // // //
// // // //       // 고해상도 캡처
// // // //       final ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
// // // //       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // //
// // // //       if (byteData == null) return;
// // // //       final Uint8List pngBytes = byteData.buffer.asUint8List();
// // // //
// // // //       final directory = await getTemporaryDirectory();
// // // //       final String fileName = 'SiRE_Unpaid_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// // // //       final imagePath = await File('${directory.path}/$fileName').create();
// // // //       await imagePath.writeAsBytes(pngBytes);
// // // //
// // // //       // 다국어 키 안전 처리
// // // //       final l10n = ref.read(localizationProvider.notifier);
// // // //       String shareText = l10n.translate('REPORT_BTN_UNPAID_IMAGE');
// // // //       if (shareText.isEmpty) shareText = "Unpaid List Image";
// // // //
// // // //       await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
// // // //     } catch (e) {
// // // //       debugPrint("Image Capture Error: $e");
// // // //       // 사용자에게 에러 상황을 알리려면 여기에 ScaffoldMessenger를 추가하세요.
// // // //     }
// // // //   }
// // // //
// // // //   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue trendAsync, NumberFormat fmt, bool isPro) { if (!isPro) return _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(context)); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: trendAsync.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final int year = DateTime.now().year; final current = trend.where((e) => e.month.year == year).toList(); int inc = current.fold(0, (sum, e) => sum + e.income); int exp = current.fold(0, (sum, e) => sum + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $year", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(fmt, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)]); })); }
// // // //   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
// // // //   Widget _buildSectionTitle(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// // // //   Widget _buildProLockCard(BuildContext context, WidgetRef ref, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(ref), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(ref))))]));
// // // //   void _openPaywall(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // // //
// // // //   _RiskSummary _computeRiskSummary({
// // // //     required int thisMonthIncome,
// // // //     required int thisMonthExpense,
// // // //     required int lastMonthExpense,
// // // //     required int overdueCount,
// // // //     required int totalOverdueAmount,
// // // //     required List<FinancialInsight> insights,
// // // //   }) {
// // // //     int totalScore = 0;
// // // //     if (overdueCount > 0) totalScore += 20;
// // // //     if (thisMonthIncome < thisMonthExpense) totalScore += 40;
// // // //     bool hasSpikeInsight = insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // // //     if (hasSpikeInsight || (lastMonthExpense > 0 && thisMonthExpense > (lastMonthExpense * 1.2))) {
// // // //       totalScore += 25;
// // // //     }
// // // //     int finalScore = totalScore.clamp(0, 100);
// // // //     return _RiskSummary(
// // // //       score: finalScore,
// // // //       level: finalScore >= 75 ? _RiskLevel.high : (finalScore >= 40 ? _RiskLevel.mid : _RiskLevel.low),
// // // //       balance: thisMonthIncome - thisMonthExpense,
// // // //       overdueCount: overdueCount,
// // // //       reasons: [],
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // enum _RiskLevel { low, mid, high }
// // // // class _RiskSummary {
// // // //   final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount;
// // // //   _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount});
// // // // }
// // //
// // //
// // //
// // //
// // // // import 'dart:io';
// // // // import 'dart:typed_data';
// // // // import 'dart:ui' as ui;
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/rendering.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:fl_chart/fl_chart.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:share_plus/share_plus.dart';
// // // // import '../../core/localization/localization_provider.dart';
// // // // import '../../core/purchase/models/purchase_status.dart';
// // // // import '../../core/purchase/state/purchase_provider.dart';
// // // // import '../../core/purchase/ui/paywall_screen.dart';
// // // // import '../ledger/ledger_provider.dart';
// // // // import '../ledger/unpaid_provider.dart';
// // // // import 'excel_export_service.dart';
// // // // import 'financial_insight_service.dart';
// // // //
// // // // class ReportsScreen extends ConsumerWidget {
// // // //   const ReportsScreen({super.key});
// // // //
// // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     final isPro = ref.watch(isProProvider);
// // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[100],
// // // //       appBar: AppBar(
// // // //         backgroundColor: const Color(0xFF1A237E),
// // // //         foregroundColor: Colors.white,
// // // //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             // ✅ 종합 진단 결과 섹션
// // // //             monthlyTrendAsync.when(
// // // //               loading: () => const SizedBox.shrink(),
// // // //               error: (_, __) => const SizedBox.shrink(),
// // // //               data: (trendData) => unpaidAsync.when(
// // // //                 loading: () => const SizedBox.shrink(),
// // // //                 error: (_, __) => const SizedBox.shrink(),
// // // //                 data: (unpaidList) {
// // // //                   int thisMonthIncome = 0, thisMonthExpense = 0, lastMonthExpense = 0;
// // // //                   final now = DateTime.now();
// // // //                   final thisItem = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// // // //                   if (thisItem.isNotEmpty) {
// // // //                     thisMonthIncome = thisItem.first.income;
// // // //                     thisMonthExpense = thisItem.first.expense;
// // // //                   }
// // // //                   final last = DateTime(now.year, now.month - 1, 1);
// // // //                   final lastItem = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// // // //                   if (lastItem.isNotEmpty) lastMonthExpense = lastItem.first.expense;
// // // //
// // // //                   final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // // //                   final totalOverdue = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //
// // // //                   final insights = FinancialInsightService.generate(
// // // //                     thisMonthIncome: thisMonthIncome,
// // // //                     thisMonthExpense: thisMonthExpense,
// // // //                     lastMonthExpense: lastMonthExpense,
// // // //                     overdueCount: overdue.length,
// // // //                     totalOverdueAmount: totalOverdue,
// // // //                   );
// // // //
// // // //                   final risk = _computeRiskSummary(
// // // //                     thisMonthIncome: thisMonthIncome,
// // // //                     thisMonthExpense: thisMonthExpense,
// // // //                     lastMonthExpense: lastMonthExpense,
// // // //                     overdueCount: overdue.length,
// // // //                     totalOverdueAmount: totalOverdue,
// // // //                     insights: insights,
// // // //                   );
// // // //
// // // //                   return Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // // //                       const SizedBox(height: 10),
// // // //                       if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// // // //                       else _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
// // // //                       const SizedBox(height: 20),
// // // //                     ],
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //
// // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildTaxSection(context, ref, isPro),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// // // //
// // // //             const SizedBox(height: 30),
// // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ 재무 위험도 지수 카드
// // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
// // // //     const Color mainIndigo = Color(0xFF1A237E);
// // // //     final Color overdueColor = const Color(0xFFEF5350);
// // // //     final Color deficitColor = const Color(0xFFFFA726);
// // // //     final Color spikeColor = const Color(0xFF8D6E63);
// // // //     final Color safeColor = Colors.grey[200]!;
// // // //
// // // //     final bool hasOverdue = risk.overdueCount > 0;
// // // //     final bool hasDeficit = risk.balance < 0;
// // // //     final bool hasSpike = insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // // //
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               Row(children: [
// // // //                 Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// // // //                 const SizedBox(width: 10),
// // // //                 Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo)),
// // // //               ]),
// // // //               Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 16),
// // // //           ClipRRect(
// // // //             borderRadius: BorderRadius.circular(8),
// // // //             child: SizedBox(
// // // //               height: 14,
// // // //               child: Row(
// // // //                 children: [
// // // //                   if (hasOverdue) Expanded(flex: 20, child: Container(color: overdueColor)),
// // // //                   if (hasDeficit) Expanded(flex: 35, child: Container(color: deficitColor)),
// // // //                   if (hasSpike) Expanded(flex: 25, child: Container(color: spikeColor)),
// // // //                   Expanded(flex: (100 - (hasOverdue ? 20 : 0) - (hasDeficit ? 35 : 0) - (hasSpike ? 25 : 0)).toInt().clamp(5, 100), child: Container(color: safeColor)),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //           Center(
// // // //             child: Wrap(
// // // //               spacing: 12, runSpacing: 8, alignment: WrapAlignment.center,
// // // //               children: [
// // // //                 _buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// // // //                 _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// // // //                 _buildRiskLegend(spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// // // //                 _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), !hasOverdue && !hasDeficit && !hasSpike),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 20),
// // // //           Row(
// // // //             children: [
// // // //               _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
// // // //               const SizedBox(width: 10),
// // // //               _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //           const Divider(),
// // // //           ...insights.map((insight) {
// // // //             String message = insight.messageKey.tr(ref);
// // // //             insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
// // // //             return Padding(
// // // //               padding: const EdgeInsets.only(top: 8),
// // // //               child: Row(
// // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                 children: [
// // // //                   const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16),
// // // //                   const SizedBox(width: 6),
// // // //                   Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
// // // //                 ],
// // // //               ),
// // // //             );
// // // //           }).toList(),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildRiskLegend(Color color, String label, bool isActive) => Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]);
// // // //
// // // //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
// // // //
// // // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
// // // //     return Container(
// // // //       height: 320, padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // //       child: monthlyTrend.when(
// // // //           loading: () => const Center(child: CircularProgressIndicator()),
// // // //           error: (_, __) => const SizedBox.shrink(),
// // // //           data: (trendData) {
// // // //             final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // // //               final List<int> indicators = [];
// // // //               if (e.value.income > 0) indicators.add(0);
// // // //               if (e.value.expense > 0) indicators.add(1);
// // // //               return BarChartGroupData(x: e.key, barsSpace: 4, showingTooltipIndicators: indicators, barRods: [
// // // //                 BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // //                 BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
// // // //               ]);
// // // //             }).toList();
// // // //             return Row(children: [
// // // //               Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //                 Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                 const SizedBox(height: 25),
// // // //                 Expanded(child: BarChart(BarChartData(
// // // //                   barTouchData: BarTouchData(enabled: false, touchTooltipData: BarTouchTooltipData(
// // // //                     tooltipBgColor: Colors.transparent, tooltipPadding: EdgeInsets.zero, tooltipMargin: 4,
// // // //                     getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY == 0 ? null : BarTooltipItem(fmt.format(rod.toY), TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9)),
// // // //                   )),
// // // //                   gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
// // // //                   titlesData: FlTitlesData(
// // // //                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
// // // //                       int i = v.toInt();
// // // //                       if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
// // // //                       return const Text('');
// // // //                     })),
// // // //                   ),
// // // //                   barGroups: barGroups,
// // // //                 ))),
// // // //                 const SizedBox(height: 12),
// // // //                 Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// // // //               ])),
// // // //               const SizedBox(width: 12),
// // // //               Expanded(flex: 2, child: categoryStats.when(
// // // //                   loading: () => const SizedBox.shrink(),
// // // //                   error: (_, __) => const SizedBox.shrink(),
// // // //                   data: (sData) {
// // // //                     final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // //                     final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
// // // //                       return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
// // // //                     }).toList();
// // // //                     return Column(children: [
// // // //                       Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                       const SizedBox(height: 10),
// // // //                       Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
// // // //                       const SizedBox(height: 12),
// // // //                       Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
// // // //                         final String cat = entry.value.category.toString();
// // // //                         final String name = cat.startsWith('CAT_') ? cat.tr(ref) : cat;
// // // //                         return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
// // // //                       }).toList()))),
// // // //                     ]);
// // // //                   }
// // // //               ))
// // // //             ]);
// // // //           }
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
// // // //     return Container(
// // // //         padding: const EdgeInsets.all(16),
// // // //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // //         child: Column(
// // // //             children: [
// // // //               Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
// // // //               const SizedBox(height: 20),
// // // //               SizedBox(
// // // //                   width: double.infinity,
// // // //                   child: ElevatedButton.icon(
// // // //                       style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
// // // //                       onPressed: () async {
// // // //                         if (!isPro) { _openPaywall(context); return; }
// // // //                         final rawTransactions = ref.read(ledgerListProvider).value ?? [];
// // // //                         final transactions = rawTransactions.map((e) => e.transaction).toList();
// // // //                         await ExcelExportService().exportTransactionsToExcel(transactions, ref);
// // // //                       },
// // // //                       icon: const Icon(Icons.file_download, size: 18),
// // // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))
// // // //                   )
// // // //               )
// // // //             ]
// // // //         )
// // // //     );
// // // //   }
// // // //
// // // // // 📍 미납 관리 섹션 (공유창이 정상적으로 뜨도록 레이아웃 수정)
// // // //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // // //       Stack(
// // // //         children: [
// // // //           // 1️⃣ [이미지 생성용 위젯] 화면 안 트리에 존재해야 캡처가 가능함 (투명도 0으로 숨김)
// // // //           IgnorePointer(
// // // //             child: Opacity(
// // // //               opacity: 0.0,
// // // //               child: RepaintBoundary(
// // // //                 key: _unpaidCaptureKey,
// // // //                 child: Container(
// // // //                   width: 400, // 고정폭으로 리포트 형태 유지
// // // //                   padding: const EdgeInsets.all(24),
// // // //                   color: Colors.white,
// // // //                   child: unpaidAsync.when(
// // // //                     data: (list) {
// // // //                       final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                       final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                       return Column(
// // // //                         mainAxisSize: MainAxisSize.min,
// // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // //                         children: [
// // // //                           Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 20, fontWeight: FontWeight.bold)),
// // // //                           const Divider(color: Color(0xFF1A237E), thickness: 2),
// // // //                           const SizedBox(height: 10),
// // // //                           Text("${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w900)),
// // // //                           const SizedBox(height: 20),
// // // //                           ...overdue.map((u) => Container(
// // // //                             margin: const EdgeInsets.only(bottom: 12),
// // // //                             padding: const EdgeInsets.all(12),
// // // //                             decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
// // // //                             child: Column(
// // // //                               children: [
// // // //                                 Row(
// // // //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                                   children: [
// // // //                                     Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                                     Text(fmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 16)),
// // // //                                   ],
// // // //                                 ),
// // // //                                 const SizedBox(height: 8),
// // // //                                 Row(
// // // //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                                   children: [
// // // //                                     Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 13)),
// // // //                                     Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
// // // //                                         style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
// // // //                                   ],
// // // //                                 ),
// // // //                               ],
// // // //                             ),
// // // //                           )).toList(),
// // // //                           const SizedBox(height: 20),
// // // //                           const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12))),
// // // //                         ],
// // // //                       );
// // // //                     },
// // // //                     loading: () => const SizedBox.shrink(),
// // // //                     error: (_, __) => const SizedBox.shrink(),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //
// // // //           // 2️⃣ 실제 사용자가 보는 화면 UI
// // // //           Container(
// // // //               padding: const EdgeInsets.all(16),
// // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // // //               child: Column(
// // // //                   children: [
// // // //                     unpaidAsync.when(
// // // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // // //                         error: (_, __) => const SizedBox(),
// // // //                         data: (list) {
// // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                           final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // //                           return Container(
// // // //                               width: double.infinity,
// // // //                               padding: const EdgeInsets.all(12),
// // // //                               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
// // // //                               child: Column(
// // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                                   children: [
// // // //                                     Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
// // // //                                     const SizedBox(height: 8),
// // // //                                     ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))
// // // //                                   ]
// // // //                               )
// // // //                           );
// // // //                         }
// // // //                     ),
// // // //                     const SizedBox(height: 20),
// // // //                     Row(
// // // //                         children: [
// // // //                           Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
// // // //                           const SizedBox(width: 10),
// // // //                           Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
// // // //                         ]
// // // //                     )
// // // //                   ]
// // // //               )
// // // //           ),
// // // //         ],
// // // //       );
// // // //
// // // //   // 📍 엑셀 공유와 동일하게 SNS 공유창을 띄우는 함수
// // // //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // // //     try {
// // // //       // 📍 중요: 엔진이 그림을 다 그릴 때까지 확실히 기다림
// // // //       await WidgetsBinding.instance.endOfFrame;
// // // //       await Future.delayed(const Duration(milliseconds: 100));
// // // //
// // // //       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// // // //
// // // //       if (boundary == null || boundary.debugNeedsPaint) {
// // // //         // 아직 준비 안됐다면 한 번 더 대기
// // // //         await Future.delayed(const Duration(milliseconds: 200));
// // // //       }
// // // //
// // // //       final ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
// // // //       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // //       final Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // //
// // // //       final directory = await getTemporaryDirectory();
// // // //       final String fileName = 'SiRE_Unpaid_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// // // //       final imagePath = await File('${directory.path}/$fileName').create();
// // // //       await imagePath.writeAsBytes(pngBytes);
// // // //
// // // //       // 📍 엑셀과 동일한 Share 로직 호출 (공유창 활성화)
// // // //       await Share.shareXFiles(
// // // //           [XFile(imagePath.path)],
// // // //           text: 'REPORT_EXCEL_UNPAID_TITLE'.tr(ref)
// // // //       );
// // // //     } catch (e) {
// // // //       debugPrint("Image Capture Error: $e");
// // // //     }
// // // //   }
// // // //
// // // //
// // // //   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue trendAsync, NumberFormat fmt, bool isPro) { if (!isPro) return _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(context)); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: trendAsync.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final int year = DateTime.now().year; final current = trend.where((e) => e.month.year == year).toList(); int inc = current.fold(0, (sum, e) => sum + e.income); int exp = current.fold(0, (sum, e) => sum + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $year", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(fmt, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)]); })); }
// // // //   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
// // // //   Widget _buildSectionTitle(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// // // //   Widget _buildProLockCard(BuildContext context, WidgetRef ref, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(ref), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(ref))))]));
// // // //   void _openPaywall(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // // //
// // // //   _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount, required List<FinancialInsight> insights}) { int totalScore = 0; if (overdueCount > 0) totalScore += 20; if (thisMonthIncome < thisMonthExpense) totalScore += 40; if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')) || (lastMonthExpense > 0 && thisMonthExpense > (lastMonthExpense * 1.2))) totalScore += 25; int finalScore = totalScore.clamp(0, 100); return _RiskSummary(score: finalScore, level: finalScore >= 75 ? _RiskLevel.high : (finalScore >= 40 ? _RiskLevel.mid : _RiskLevel.low), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount, reasons: []); }
// // // // }
// // // //
// // // // enum _RiskLevel { low, mid, high }
// // // // class _RiskSummary { final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount}); }
// // //
// // // import 'dart:io';
// // // import 'dart:typed_data';
// // // import 'dart:ui' as ui;
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/rendering.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:share_plus/share_plus.dart';
// // // import '../../core/localization/localization_provider.dart';
// // // import '../../core/purchase/state/purchase_provider.dart';
// // // import '../../core/purchase/ui/paywall_screen.dart';
// // // import '../ledger/ledger_provider.dart';
// // // import '../ledger/unpaid_provider.dart';
// // // import 'excel_export_service.dart';
// // // // 📍 에러 해결: 아래 파일 안에 FinancialInsight 모델이 정의되어 있어야 합니다.
// // // import 'financial_insight_service.dart';
// // //
// // // class ReportsScreen extends ConsumerWidget {
// // //   const ReportsScreen({super.key});
// // //
// // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // //
// // //   @override
// // //   Widget build(BuildContext context, WidgetRef ref) {
// // //     final isPro = ref.watch(isProProvider);
// // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // //
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[100],
// // //       appBar: AppBar(
// // //         backgroundColor: const Color(0xFF1A237E),
// // //         foregroundColor: Colors.white,
// // //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // //       ),
// // //       body: Stack(
// // //         children: [
// // //           SingleChildScrollView(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // ✅ 종합 진단 결과 섹션
// // //                 monthlyTrendAsync.when(
// // //                     loading: () => const SizedBox.shrink(),
// // //                     error: (_, __) => const SizedBox.shrink(),
// // //                     data: (trendData) => unpaidAsync.when(
// // //                         loading: () => const SizedBox.shrink(),
// // //                         error: (_, __) => const SizedBox.shrink(),
// // //                         data: (unpaidList) {
// // //                           int inC = 0, exC = 0, lastEx = 0;
// // //                           final now = DateTime.now();
// // //                           final thisMonth = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// // //                           if (thisMonth.isNotEmpty) { inC = thisMonth.first.income; exC = thisMonth.first.expense; }
// // //                           final last = DateTime(now.year, now.month - 1, 1);
// // //                           final lastMonth = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// // //                           if (lastMonth.isNotEmpty) lastEx = lastMonth.first.expense;
// // //
// // //                           final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// // //                           final totalO = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // //
// // //                           final insights = FinancialInsightService.generate(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO);
// // //                           final risk = _computeRiskSummary(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO, insights: insights);
// // //
// // //                           return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                             _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// // //                             const SizedBox(height: 10),
// // //                             if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// // //                             else _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
// // //                             const SizedBox(height: 20),
// // //                           ]);
// // //                         }
// // //                     )
// // //                 ),
// // //
// // //                 _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// // //
// // //                 const SizedBox(height: 30),
// // //                 _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 _buildTaxSection(context, ref, isPro),
// // //
// // //                 const SizedBox(height: 30),
// // //                 _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// // //
// // //                 const SizedBox(height: 30),
// // //                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           // 📍 캡처용 오버레이 위젯 (공백 문제 해결)
// // //           Transform.translate(
// // //             offset: const Offset(-5000, -5000),
// // //             child: RepaintBoundary(
// // //               key: _unpaidCaptureKey,
// // //               child: Container(
// // //                 width: 450, padding: const EdgeInsets.all(30), color: Colors.white,
// // //                 child: unpaidAsync.when(
// // //                   data: (list) {
// // //                     final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // //                     final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // //                     return Column(
// // //                       mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 24, fontWeight: FontWeight.bold)),
// // //                         const Divider(color: Color(0xFF1A237E), thickness: 3),
// // //                         const SizedBox(height: 20),
// // //                         Text("${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.w900)),
// // //                         const SizedBox(height: 30),
// // //                         ...overdue.map((u) => Container(
// // //                           margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15),
// // //                           decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[300]), borderRadius: BorderRadius.circular(10)),
// // //                           child: Column(children: [
// // //                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // //                               Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
// // //                               Text(currencyFmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 18)),
// // //                             ]),
// // //                             const SizedBox(height: 10),
// // //                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // //                               Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 14)),
// // //                               Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}", style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
// // //                             ]),
// // //                           ]),
// // //                         )).toList(),
// // //                         const SizedBox(height: 30),
// // //                         const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5))),
// // //                       ],
// // //                     );
// // //                   },
// // //                   loading: () => const SizedBox.shrink(),
// // //                   error: (_, __) => const SizedBox.shrink(),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [복구] 재무 분석 위젯
// // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
// // //     return Container(
// // //       height: 320, padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // //       child: monthlyTrend.when(
// // //           loading: () => const Center(child: CircularProgressIndicator()),
// // //           error: (_, __) => const SizedBox.shrink(),
// // //           data: (trendData) {
// // //             final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // //               return BarChartGroupData(x: e.key, barRods: [
// // //                 BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8),
// // //                 BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8),
// // //               ]);
// // //             }).toList();
// // //             return Row(children: [
// // //               Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                 Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // //                 const SizedBox(height: 25),
// // //                 Expanded(child: BarChart(BarChartData(
// // //                   gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
// // //                   titlesData: FlTitlesData(
// // //                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // //                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // //                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
// // //                       int i = v.toInt();
// // //                       if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
// // //                       return const Text('');
// // //                     })),
// // //                   ),
// // //                   barGroups: barGroups,
// // //                 ))),
// // //                 const SizedBox(height: 12),
// // //                 Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// // //               ])),
// // //               const SizedBox(width: 12),
// // //               Expanded(flex: 2, child: categoryStats.when(
// // //                   loading: () => const SizedBox.shrink(),
// // //                   error: (_, __) => const SizedBox.shrink(),
// // //                   data: (sData) {
// // //                     final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // //                     final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
// // //                       return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
// // //                     }).toList();
// // //                     return Column(children: [
// // //                       Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // //                       const SizedBox(height: 10),
// // //                       Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
// // //                       const SizedBox(height: 12),
// // //                       Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
// // //                         final String name = entry.value.category.toString().startsWith('CAT_') ? entry.value.category.toString().tr(ref) : entry.value.category.toString();
// // //                         return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
// // //                       }).toList()))),
// // //                     ]);
// // //                   }
// // //               ))
// // //             ]);
// // //           }
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [복구] 세무 섹션 위젯
// // //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
// // //     return Container(
// // //         padding: const EdgeInsets.all(16),
// // //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // //         child: Column(children: [
// // //           Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
// // //           const SizedBox(height: 20),
// // //           SizedBox(width: double.infinity, child: ElevatedButton.icon(
// // //             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
// // //             onPressed: () async {
// // //               if (!isPro) { _openPaywall(context); return; }
// // //               final raw = ref.read(ledgerListProvider).value ?? [];
// // //               final transactions = raw.map((e) => e.transaction).toList();
// // //               await ExcelExportService().exportTransactionsToExcel(transactions, ref);
// // //             },
// // //             icon: const Icon(Icons.file_download, size: 18),
// // //             label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //           ))
// // //         ])
// // //     );
// // //   }
// // //
// // //   // ✅ [복구] 미납 섹션 위젯
// // //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // //       Container(
// // //           padding: const EdgeInsets.all(16),
// // //           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // //           child: Column(children: [
// // //             unpaidAsync.when(
// // //                 loading: () => const Center(child: CircularProgressIndicator()),
// // //                 error: (_, __) => const SizedBox(),
// // //                 data: (list) {
// // //                   final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // //                   final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // //                   if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // //                   return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                     Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
// // //                     const SizedBox(height: 8),
// // //                     ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))
// // //                   ]));
// // //                 }
// // //             ),
// // //             const SizedBox(height: 20),
// // //             Row(children: [
// // //               Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } final list = unpaidAsync.value ?? []; await ExcelExportService().exportUnpaidListToExcel(list, ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
// // //               const SizedBox(width: 10),
// // //               Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
// // //             ])
// // //           ]));
// // //
// // //   // ✅ [에러 수정] 리스크 요약 카드 (FinancialInsight 타입 명시)
// // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
// // //     const Color mainIndigo = Color(0xFF1A237E);
// // //     final Color overdueColor = const Color(0xFFEF5350);
// // //     final Color deficitColor = const Color(0xFFFFA726);
// // //     final Color spikeColor = const Color(0xFF8D6E63);
// // //     final Color safeColor = Colors.grey[200]!;
// // //
// // //     return Container(
// // //       width: double.infinity, padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // //             Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]),
// // //             Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
// // //           ]),
// // //           const SizedBox(height: 16),
// // //           ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [
// // //             if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: overdueColor)),
// // //             if (risk.balance < 0) Expanded(flex: 35, child: Container(color: deficitColor)),
// // //             Expanded(flex: 45, child: Container(color: safeColor)),
// // //           ]))),
// // //           const SizedBox(height: 12),
// // //           const Divider(),
// // //           ...insights.map((insight) {
// // //             String message = insight.messageKey.tr(ref);
// // //             insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
// // //             return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))]));
// // //           }).toList(),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [복구] 연간 요약 위젯 (isBold 에러 해결)
// // //   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue trendAsync, NumberFormat fmt, bool isPro) {
// // //     if (!isPro) return _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(context));
// // //     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: trendAsync.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final y = DateTime.now().year; final cur = trend.where((e) => e.month.year == y).toList(); int inc = cur.fold(0, (s, e) => s + e.income); int exp = cur.fold(0, (s, e) => s + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $y", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(fmt, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false), const Divider(height: 20), _buildSummaryRow(fmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)]); }));
// // //   }
// // //
// // //   // ✅ [중요] 누락되었던 헬퍼 메서드들
// // //   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {required bool isBold}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
// // //   Widget _buildSectionTitle(IconData i, String t) => Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// // //   Widget _buildLegend(Color c, String l, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(l, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// // //   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r))))]));
// // //   void _openPaywall(BuildContext c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // //
// // //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // //     try {
// // //       await WidgetsBinding.instance.endOfFrame;
// // //       await Future.delayed(const Duration(milliseconds: 200));
// // //       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// // //       if (boundary == null || boundary.debugNeedsPaint) { await Future.delayed(const Duration(milliseconds: 300)); }
// // //       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
// // //       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // //       final Uint8List pngBytes = byteData!.buffer.asUint8List();
// // //       final directory = await getTemporaryDirectory();
// // //       final path = '${directory.path}/SiRE_Unpaid_${DateTime.now().millisecondsSinceEpoch}.png';
// // //       await File(path).writeAsBytes(pngBytes);
// // //       await Share.shareXFiles([XFile(path)], text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
// // //     } catch (e) { debugPrint("Capture Error: $e"); }
// // //   }
// // //
// // //   _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount, required List<FinancialInsight> insights}) {
// // //     int s = 0; if (overdueCount > 0) s += 20; if (thisMonthIncome < thisMonthExpense) s += 40;
// // //     if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
// // //     int fs = s.clamp(0, 100);
// // //     return _RiskSummary(score: fs, level: fs >= 75 ? _RiskLevel.high : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount, reasons: []);
// // //   }
// // // }
// // //
// // // enum _RiskLevel { low, mid, high }
// // // class _RiskSummary { final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount}); }
// // //
// // //
// // //
// // //
// //
// //
// // import 'dart:io';
// // import 'dart:typed_data';
// // import 'dart:ui' as ui;
// // import 'package:flutter/material.dart';
// // import 'package:flutter/rendering.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:intl/intl.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
// // import '../../core/localization/localization_provider.dart';
// // import '../../core/purchase/state/purchase_provider.dart';
// // import '../../core/purchase/ui/paywall_screen.dart';
// // import '../ledger/ledger_provider.dart';
// // import '../ledger/unpaid_provider.dart';
// // import 'excel_export_service.dart';
// // import 'financial_insight_service.dart';
// //
// // class ReportsScreen extends ConsumerWidget {
// //   const ReportsScreen({super.key});
// //
// //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// //
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final isPro = ref.watch(isProProvider);
// //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// //     final unpaidAsync = ref.watch(unpaidListProvider);
// //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF1A237E),
// //         foregroundColor: Colors.white,
// //         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// //       ),
// //       body: Stack(
// //         children: [
// //           SingleChildScrollView(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // 종합 진단 섹션
// //                 monthlyTrendAsync.when(
// //                     loading: () => const SizedBox.shrink(),
// //                     error: (_, __) => const SizedBox.shrink(),
// //                     data: (trendData) => unpaidAsync.when(
// //                         loading: () => const SizedBox.shrink(),
// //                         error: (_, __) => const SizedBox.shrink(),
// //                         data: (unpaidList) {
// //                           int inC = 0, exC = 0, lastEx = 0;
// //                           final now = DateTime.now();
// //                           final thisMonth = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
// //                           if (thisMonth.isNotEmpty) { inC = thisMonth.first.income; exC = thisMonth.first.expense; }
// //                           final last = DateTime(now.year, now.month - 1, 1);
// //                           final lastMonth = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
// //                           if (lastMonth.isNotEmpty) lastEx = lastMonth.first.expense;
// //
// //                           final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
// //                           final totalO = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// //
// //                           final insights = FinancialInsightService.generate(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO);
// //                           final risk = _computeRiskSummary(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO, insights: insights);
// //
// //                           return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                             _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
// //                             const SizedBox(height: 10),
// //                             if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
// //                             else _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
// //                             const SizedBox(height: 20),
// //                           ]);
// //                         }
// //                     )
// //                 ),
// //
// //                 _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
// //
// //                 const SizedBox(height: 30),
// //                 _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 _buildTaxSection(context, ref, isPro),
// //
// //                 const SizedBox(height: 30),
// //                 _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
// //
// //                 const SizedBox(height: 30),
// //                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
// //               ],
// //             ),
// //           ),
// //
// //           // 캡처용 오버레이 위젯 (Transform으로 멀리 보냄)
// //           Transform.translate(
// //             offset: const Offset(-5000, -5000),
// //             child: RepaintBoundary(
// //               key: _unpaidCaptureKey,
// //               child: Container(
// //                 width: 450, padding: const EdgeInsets.all(30), color: Colors.white,
// //                 child: unpaidAsync.when(
// //                   data: (list) {
// //                     final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// //                     final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// //                     return Column(
// //                       mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 24, fontWeight: FontWeight.bold)),
// //                         const Divider(color: Color(0xFF1A237E), thickness: 3),
// //                         const SizedBox(height: 20),
// //                         Text("${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.w900)),
// //                         const SizedBox(height: 30),
// //                         ...overdue.map((u) => Container(
// //                           margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15),
// //                           decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
// //                           child: Column(children: [
// //                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// //                               Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
// //                               Text(currencyFmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 18)),
// //                             ]),
// //                             const SizedBox(height: 10),
// //                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// //                               Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 14)),
// //                               Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}", style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
// //                             ]),
// //                           ]),
// //                         )).toList(),
// //                         const SizedBox(height: 30),
// //                         const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5))),
// //                       ],
// //                     );
// //                   },
// //                   loading: () => const SizedBox.shrink(),
// //                   error: (_, __) => const SizedBox.shrink(),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // UI 헬퍼 메서드들
// //   Widget _buildSectionTitle(IconData i, String t) => Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
// //
// //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) => Container(
// //       height: 320, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// //       child: monthlyTrend.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox.shrink(), data: (trendData) => Row(children: [
// //         Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //           Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 25),
// //           Expanded(child: BarChart(BarChartData(gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { int i = v.toInt(); if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9))); return const Text(''); }))), barGroups: (trendData as List).asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8), BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8)])).toList()))),
// //           const SizedBox(height: 12),
// //           Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
// //         ])),
// //         const SizedBox(width: 12),
// //         Expanded(flex: 2, child: categoryStats.when(loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink(), data: (sData) => Column(children: [
// //           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 10),
// //           Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: (sData as List).asMap().entries.map((entry) => PieChartSectionData(value: entry.value.amount.toDouble(), color: [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple][entry.key % 5], radius: 40, title: '')).toList()))),
// //           const SizedBox(height: 12),
// //           Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) { final String name = entry.value.category.toString().startsWith('CAT_') ? entry.value.category.toString().tr(ref) : entry.value.category.toString(); return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend([Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple][entry.key % 5], "$name (${fmt.format(entry.value.amount)})", fontSize: 9)); }).toList()))),
// //         ])))
// //       ]))
// //   );
// //
// //   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) => Container(
// //       padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// //       child: Column(children: [
// //         Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
// //         const SizedBox(height: 20),
// //         SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } final raw = ref.read(ledgerListProvider).value ?? []; final transactions = raw.map((e) => e.transaction).toList(); await ExcelExportService().exportTransactionsToExcel(transactions, ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))
// //       ])
// //   );
// //
// //   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) => Container(
// //       padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// //       child: Column(children: [
// //         unpaidAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox(), data: (list) {
// //           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// //           final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// //           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// //           return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))]));
// //         }),
// //         const SizedBox(height: 20),
// //         Row(children: [
// //           Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
// //           const SizedBox(width: 10),
// //           Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
// //         ])
// //       ])
// //   );
// //
// //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) => Container(
// //       width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
// //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Icon(Icons.analytics_outlined, color: Color(0xFF1A237E), size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))]), Text("${risk.score}/100", style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900, fontSize: 18))]),
// //         const SizedBox(height: 16),
// //         ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: Colors.redAccent)), if (risk.balance < 0) Expanded(flex: 35, child: Container(color: Colors.orangeAccent)), Expanded(flex: 45, child: Container(color: Colors.grey[200]!))]))),
// //         const SizedBox(height: 12),
// //         const Divider(),
// //         ...insights.map((insight) { String msg = insight.messageKey.tr(ref); insight.arguments?.forEach((k, v) => msg = msg.replaceAll('{$k}', v)); return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: Color(0xFF1A237E), size: 16), const SizedBox(width: 6), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))])); }).toList()
// //       ])
// //   );
// //
// //   Widget _buildAnnualSummary(BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
// //     if (!p) return _buildProLockCard(c, r, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(c));
// //     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final y = DateTime.now().year; final cur = trend.where((e) => e.month.year == y).toList(); int inc = cur.fold(0, (s, e) => s + e.income); int exp = cur.fold(0, (s, e) => s + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(r)}: $y", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue, isBold: false), const Divider(height: 20), _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent, isBold: false), const Divider(height: 20), _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp, Colors.indigo, isBold: true)]); }));
// //   }
// //
// //   // 📍 컴파일 에러 해결 포인트: Border.all() 괄호 닫기 수정됨
// //   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) => Container(
// //       padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300!)), // 👈 괄호 위치 수정 완료
// //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]),
// //         const SizedBox(height: 8),
// //         Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
// //         const SizedBox(height: 12),
// //         Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r))))
// //       ])
// //   );
// //
// //   Widget _buildSummaryRow(NumberFormat f, String l, int a, Color c, {required bool isBold}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(f.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))]);
// //   Widget _buildLegend(Color c, String l, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(l, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
// //   void _openPaywall(BuildContext c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// //
// //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// //     try {
// //       await WidgetsBinding.instance.endOfFrame;
// //       await Future.delayed(const Duration(milliseconds: 200));
// //       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// //       if (boundary == null || boundary.debugNeedsPaint) { await Future.delayed(const Duration(milliseconds: 300)); }
// //       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
// //       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //       final Uint8List pngBytes = byteData!.buffer.asUint8List();
// //       final directory = await getTemporaryDirectory();
// //       final path = '${directory.path}/SiRE_Unpaid_${DateTime.now().millisecondsSinceEpoch}.png';
// //       await File(path).writeAsBytes(pngBytes);
// //       await Share.shareXFiles([XFile(path)], text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
// //     } catch (e) { debugPrint("Capture Error: $e"); }
// //   }
// //
// //   _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount, required List<FinancialInsight> insights}) {
// //     int s = 0; if (overdueCount > 0) s += 20; if (thisMonthIncome < thisMonthExpense) s += 40; if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
// //     int fs = s.clamp(0, 100);
// //     return _RiskSummary(score: fs, level: fs >= 75 ? _RiskLevel.high : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount, reasons: []);
// //   }
// // }
// //
// // enum _RiskLevel { low, mid, high }
// // class _RiskSummary { final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount}); }
//
//
//
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/state/purchase_provider.dart';
// import '../../core/purchase/ui/paywall_screen.dart';
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
// import 'financial_insight_service.dart';
//
// class ReportsScreen extends ConsumerWidget {
//   const ReportsScreen({super.key});
//
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isPro = ref.watch(isProProvider);
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//       ),
//       body: Stack( // 📍 공백 제거를 위해 Stack을 최상위로 배치
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ✅ 종합 진단 결과 섹션 (원본 디자인 복구)
//                 monthlyTrendAsync.when(
//                     loading: () => const SizedBox.shrink(),
//                     error: (_, __) => const SizedBox.shrink(),
//                     data: (trendData) => unpaidAsync.when(
//                         loading: () => const SizedBox.shrink(),
//                         error: (_, __) => const SizedBox.shrink(),
//                         data: (unpaidList) {
//                           int inC = 0, exC = 0, lastEx = 0;
//                           final now = DateTime.now();
//                           final thisMonth = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
//                           if (thisMonth.isNotEmpty) { inC = thisMonth.first.income; exC = thisMonth.first.expense; }
//                           final last = DateTime(now.year, now.month - 1, 1);
//                           final lastMonth = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
//                           if (lastMonth.isNotEmpty) lastEx = lastMonth.first.expense;
//
//                           final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
//                           final totalO = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
//
//                           final insights = FinancialInsightService.generate(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO);
//                           final risk = _computeRiskSummary(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO, insights: insights);
//
//                           return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                             _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
//                             const SizedBox(height: 10),
//                             if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
//                             else _buildRiskSummaryCard(ref, currencyFmt, risk, insights), // 📍 원본 디자인 함수 호출
//                             const SizedBox(height: 20),
//                           ]);
//                         }
//                     )
//                 ),
//
//                 _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
//               ],
//             ),
//           ),
//
//           // 📍 이미지 생성용 위젯 (화면 밖 배치로 공백 해결)
//           Transform.translate(
//             offset: const Offset(-5000, -5000),
//             child: RepaintBoundary(
//               key: _unpaidCaptureKey,
//               child: Container(
//                 width: 450, padding: const EdgeInsets.all(30), color: Colors.white,
//                 child: unpaidAsync.when(
//                   data: (list) {
//                     final overdue = list.where((u) => u.status == 'OVERDUE').toList();
//                     final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
//                     return Column(
//                       mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 24, fontWeight: FontWeight.bold)),
//                         const Divider(color: Color(0xFF1A237E), thickness: 3),
//                         const SizedBox(height: 20),
//                         Text("${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.w900)),
//                         const SizedBox(height: 30),
//                         ...overdue.map((u) => Container(
//                           margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
//                           child: Column(children: [
//                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                               Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                               Text(currencyFmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 18)),
//                             ]),
//                             const SizedBox(height: 10),
//                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                               Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 14)),
//                               Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}", style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
//                             ]),
//                           ]),
//                         )).toList(),
//                         const SizedBox(height: 30),
//                         const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5))),
//                       ],
//                     );
//                   },
//                   loading: () => const SizedBox.shrink(),
//                   error: (_, __) => const SizedBox.shrink(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ 재무 위험도 지수 원본 복구 (범례/인덱스 포함)
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     final Color overdueColor = const Color(0xFFEF5350);
//     final Color deficitColor = const Color(0xFFFFA726);
//     final Color spikeColor = const Color(0xFF8D6E63);
//     final Color safeColor = Colors.grey[200]!;
//
//     return Container(
//       width: double.infinity, padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]),
//             Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
//           ]),
//           const SizedBox(height: 16),
//           ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [
//             if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: overdueColor)),
//             if (risk.balance < 0) Expanded(flex: 35, child: Container(color: deficitColor)),
//             Expanded(flex: (100 - (risk.overdueCount > 0 ? 20 : 0) - (risk.balance < 0 ? 35 : 0)).toInt().clamp(5, 100), child: Container(color: safeColor)),
//           ]))),
//           const SizedBox(height: 12),
//           // 🏷️ 원본 범례(Index) 복구
//           Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
//             _buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), risk.overdueCount > 0),
//             _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), risk.balance < 0),
//             _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), risk.overdueCount == 0 && risk.balance >= 0),
//           ])),
//           const SizedBox(height: 20),
//           // 원본 수치 정보 복구
//           Row(children: [
//             _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
//             const SizedBox(width: 10),
//             _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
//           ]),
//           const SizedBox(height: 12),
//           const Divider(),
//           ...insights.map((insight) {
//             String message = insight.messageKey.tr(ref);
//             insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
//             return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))]));
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   // 나머지 헬퍼 메서드들 (생략 없이 작성)
//   Widget _buildRiskLegend(Color color, String label, bool isActive) => Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]);
//   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
//   Widget _buildSectionTitle(IconData i, String t) => Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
//
//   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) => Container(
//       height: 320, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: monthlyTrend.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox.shrink(), data: (trendData) => Row(children: [
//         Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 25),
//           Expanded(child: BarChart(BarChartData(gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), titlesData: FlTitlesData(topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { int i = v.toInt(); if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9))); return const Text(''); }))), barGroups: (trendData as List).asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8), BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8)])).toList()))),
//           const SizedBox(height: 12),
//           Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
//         ])),
//         const SizedBox(width: 12),
//         Expanded(flex: 2, child: categoryStats.when(loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink(), data: (sData) => Column(children: [
//           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: (sData as List).asMap().entries.map((entry) => PieChartSectionData(value: entry.value.amount.toDouble(), color: [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple][entry.key % 5], radius: 40, title: '')).toList()))),
//           const SizedBox(height: 12),
//           Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) { final String name = entry.value.category.toString().startsWith('CAT_') ? entry.value.category.toString().tr(ref) : entry.value.category.toString(); return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend([Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple][entry.key % 5], "$name (${fmt.format(entry.value.amount)})", fontSize: 9)); }).toList()))),
//         ])))
//       ]))
//   );
//
//   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) => Container(
//       padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(children: [
//         Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
//         const SizedBox(height: 20),
//         SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } final raw = ref.read(ledgerListProvider).value ?? []; final transactions = raw.map((e) => e.transaction).toList(); await ExcelExportService().exportTransactionsToExcel(transactions, ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))
//       ])
//   );
//
//   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) => Container(
//       padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(children: [
//         unpaidAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox(), data: (list) {
//           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
//           final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
//           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
//           return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))]));
//         }),
//         const SizedBox(height: 20),
//         Row(children: [
//           Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
//           const SizedBox(width: 10),
//           Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(context); return; } await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
//         ])
//       ])
//   );
//
//   Widget _buildAnnualSummary(BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
//     if (!p) return _buildProLockCard(c, r, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(c));
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final y = DateTime.now().year; final cur = trend.where((e) => e.month.year == y).toList(); int inc = cur.fold(0, (s, e) => s + e.income); int exp = cur.fold(0, (s, e) => s + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(r)}: $y", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue, isBold: false), const Divider(height: 20), _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent, isBold: false), const Divider(height: 20), _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp, Colors.indigo, isBold: true)]); }));
//   }
//
//   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300!)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r))))]));
//   Widget _buildSummaryRow(NumberFormat f, String l, int a, Color c, {required bool isBold}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(f.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))]);
//   Widget _buildLegend(Color c, String l, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(l, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
//   void _openPaywall(BuildContext c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
//
//   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
//     try {
//       await WidgetsBinding.instance.endOfFrame;
//       await Future.delayed(const Duration(milliseconds: 200));
//       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null || boundary.debugNeedsPaint) { await Future.delayed(const Duration(milliseconds: 300)); }
//       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
//       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       final Uint8List pngBytes = byteData!.buffer.asUint8List();
//       final directory = await getTemporaryDirectory();
//       final path = '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
//       await File(path).writeAsBytes(pngBytes);
//       await Share.shareXFiles([XFile(path)], text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
//     } catch (e) { debugPrint("Capture Error: $e"); }
//   }
//
//   _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount, required List<FinancialInsight> insights}) {
//     int s = 0; if (overdueCount > 0) s += 20; if (thisMonthIncome < thisMonthExpense) s += 40;
//     if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
//     int fs = s.clamp(0, 100);
//     return _RiskSummary(score: fs, level: fs >= 75 ? _RiskLevel.high : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount, reasons: []);
//   }
// }
//
// enum _RiskLevel { low, mid, high }
// class _RiskSummary { final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount}); }



import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/purchase/state/purchase_provider.dart';
import '../../core/purchase/ui/paywall_screen.dart';
import '../ledger/ledger_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'excel_export_service.dart';
import 'financial_insight_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static final GlobalKey _unpaidCaptureKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
    final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final lang = ref.watch(localizationProvider.notifier).currentLang;
    final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text("NAV_REPORTS".tr(ref), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
                monthlyTrendAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (trendData) => unpaidAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (unpaidList) {
                          int inC = 0, exC = 0, lastEx = 0;
                          final now = DateTime.now();
                          final thisMonth = trendData.where((e) => e.month.year == now.year && e.month.month == now.month).toList();
                          if (thisMonth.isNotEmpty) { inC = thisMonth.first.income; exC = thisMonth.first.expense; }
                          final last = DateTime(now.year, now.month - 1, 1);
                          final lastMonth = trendData.where((e) => e.month.year == last.year && e.month.month == last.month).toList();
                          if (lastMonth.isNotEmpty) lastEx = lastMonth.first.expense;

                          final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
                          final totalO = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);

                          final insights = FinancialInsightService.generate(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO);
                          final risk = _computeRiskSummary(thisMonthIncome: inC, thisMonthExpense: exC, lastMonthExpense: lastEx, overdueCount: overdue.length, totalOverdueAmount: totalO, insights: insights);

                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
                            const SizedBox(height: 10),
                            if (!isPro) _buildProLockCard(context, ref, subtitleKey: "REPORTS_PRO_LOCK_INSIGHTS_SUBTITLE", onTap: () => _openPaywall(context))
                            else _buildRiskSummaryCard(ref, currencyFmt, risk, insights),
                            const SizedBox(height: 20),
                          ]);
                        }
                    )
                ),

                // ✅ [복구] 재무 분석 (그래프 수치 표시 복구)
                _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
                const SizedBox(height: 10),
                _buildFinancialAnalytics(ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang),

                const SizedBox(height: 30),
                _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
                const SizedBox(height: 10),
                _buildTaxSection(context, ref, isPro),

                const SizedBox(height: 30),
                _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
                const SizedBox(height: 10),
                _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),

                const SizedBox(height: 30),
                // ✅ [복구] 연간 요약 타이틀 복구
                _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
                const SizedBox(height: 10),
                _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
              ],
            ),
          ),

          // 📍 캡처 전용 위젯 (공백 문제 해결을 위해 화면 밖 배치)
          Transform.translate(
            offset: const Offset(-5000, -5000),
            child: RepaintBoundary(
              key: _unpaidCaptureKey,
              child: Container(
                width: 450, padding: const EdgeInsets.all(30), color: Colors.white,
                child: unpaidAsync.when(
                  data: (list) {
                    final overdue = list.where((u) => u.status == 'OVERDUE').toList();
                    final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
                    return Column(
                      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref), style: const TextStyle(color: Color(0xFF1A237E), fontSize: 24, fontWeight: FontWeight.bold)),
                        const Divider(color: Color(0xFF1A237E), thickness: 3),
                        const SizedBox(height: 20),
                        Text("${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}", style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 30),
                        ...overdue.map((u) => Container(
                          margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text("${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(currencyFmt.format(u.unit.monthlyRent), style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 18)),
                            ]),
                            const SizedBox(height: 10),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(u.unit.tenantPhone ?? '-', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                              Text("${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}", style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                            ]),
                          ]),
                        )).toList(),
                        const SizedBox(height: 30),
                        const Center(child: Text("Generated by SiRE Asset Management", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5))),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ [복구] 재무 분석 카드 (그래프 위 수치 표시)
  Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang) {
    return Container(
      height: 320, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: monthlyTrend.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (trendData) {
            final List<BarChartGroupData> barGroups = (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
              final List<int> indicators = [];
              if (e.value.income > 0) indicators.add(0);
              if (e.value.expense > 0) indicators.add(1);
              return BarChartGroupData(x: e.key, barsSpace: 4, showingTooltipIndicators: indicators, barRods: [
                BarChartRodData(toY: e.value.income.toDouble(), color: Colors.blue, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                BarChartRodData(toY: e.value.expense.toDouble(), color: Colors.redAccent, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
              ]);
            }).toList();
            return Row(children: [
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                Expanded(child: BarChart(BarChartData(
                  barTouchData: BarTouchData(enabled: false, touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent, tooltipPadding: EdgeInsets.zero, tooltipMargin: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY == 0 ? null : BarTooltipItem(fmt.format(rod.toY), TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9)),
                  )),
                  gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      int i = v.toInt();
                      if (i >= 0 && i < trendData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(trendData[i].month), style: const TextStyle(fontSize: 9)));
                      return const Text('');
                    })),
                  ),
                  barGroups: barGroups,
                ))),
                const SizedBox(height: 12),
                Row(children: [_buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)), const SizedBox(width: 12), _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref))])
              ])),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: categoryStats.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (sData) {
                    final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
                    final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map<PieChartSectionData>((entry) {
                      return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
                    }).toList();
                    return Column(children: [
                      Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 10, sections: pieSections))),
                      const SizedBox(height: 12),
                      Expanded(flex: 3, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
                        final String name = entry.value.category.toString().startsWith('CAT_') ? entry.value.category.toString().tr(ref) : entry.value.category.toString();
                        return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: _buildLegend(colors[entry.key % colors.length], "$name (${fmt.format(entry.value.amount)})", fontSize: 9));
                      }).toList()))),
                    ]);
                  }
              ))
            ]);
          }
      ),
    );
  }

  // ✅ [복구] 종합 진단 결과 카드 (범례 및 상세 타일 100% 복원)
  Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
    const Color mainIndigo = Color(0xFF1A237E);
    final Color overdueColor = const Color(0xFFEF5350);
    final Color deficitColor = const Color(0xFFFFA726);
    final Color spikeColor = const Color(0xFF8D6E63);
    final Color safeColor = Colors.grey[200]!;

    final bool hasOverdue = risk.overdueCount > 0;
    final bool hasDeficit = risk.balance < 0;
    final bool hasSpike = insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]),
            Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
          ]),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [
            if (hasOverdue) Expanded(flex: 20, child: Container(color: overdueColor)),
            if (hasDeficit) Expanded(flex: 35, child: Container(color: deficitColor)),
            if (hasSpike) Expanded(flex: 25, child: Container(color: spikeColor)),
            Expanded(flex: (100 - (hasOverdue ? 20 : 0) - (hasDeficit ? 35 : 0) - (hasSpike ? 25 : 0)).toInt().clamp(5, 100), child: Container(color: safeColor)),
          ]))),
          const SizedBox(height: 12),
          // 🏷️ 원본 인덱스 범례 복구
          Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
            _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
            _buildRiskLegend(spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
            _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), !hasOverdue && !hasDeficit && !hasSpike),
          ])),
          const SizedBox(height: 20),
          // 🏷️ 원본 상세 타일(잔액, 미납건수) 복구
          Row(children: [
            _infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)),
            const SizedBox(width: 10),
            _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
          ]),
          const SizedBox(height: 12),
          const Divider(),
          ...insights.map((insight) {
            String message = insight.messageKey.tr(ref);
            insight.arguments?.forEach((key, value) => message = message.replaceAll('{$key}', value));
            return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))]));
          }).toList(),
        ],
      ),
    );
  }

  // 나머지 원본 헬퍼 메서드들 (isBold 파라미터 보정 완료)
  Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {required bool isBold}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
  Widget _buildRiskLegend(Color color, String label, bool isActive) => Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]);
  Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
  Widget _buildSectionTitle(IconData i, String t) => Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
  Widget _buildLegend(Color c, String l, {double fontSize = 10}) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(l, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
  Widget _buildTaxSection(BuildContext c, WidgetRef r, bool isPro) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(r)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(r)}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(c); return; } final raw = r.read(ledgerListProvider).value ?? []; final transactions = raw.map((e) => e.transaction).toList(); await ExcelExportService().exportTransactionsToExcel(transactions, r); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))))]));
  Widget _buildUnpaidSection(BuildContext c, WidgetRef r, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [unpaidAsync.when(loading: () => const Center(child: CircularProgressIndicator()), error: (_, __) => const SizedBox(), data: (list) { final overdue = list.where((u) => u.status == 'OVERDUE').toList(); final total = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent); if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r), textAlign: TextAlign.center); return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) => Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)))])); }), const SizedBox(height: 20), Row(children: [Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(c); return; } await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], r); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))), const SizedBox(width: 10), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { if (!isPro) { _openPaywall(c); return; } await _captureAndShare(_unpaidCaptureKey, r); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))])]));
  Widget _buildAnnualSummary(BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) { if (!p) return _buildProLockCard(c, r, subtitleKey: "REPORTS_PRO_LOCK_SUMMARY_SUBTITLE", onTap: () => _openPaywall(c)); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () => const SizedBox(), error: (_, __) => const SizedBox(), data: (trend) { final y = DateTime.now().year; final cur = trend.where((e) => e.month.year == y).toList(); int inc = cur.fold(0, (s, e) => s + e.income); int exp = cur.fold(0, (s, e) => s + e.expense); return Column(children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(r)}: $y", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), const SizedBox(height: 10), _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue, isBold: false), const Divider(height: 20), _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent, isBold: false), const Divider(height: 20), _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp, Colors.indigo, isBold: true)]); })); }
  Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300!)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onTap, child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r))))]));
  void _openPaywall(BuildContext c) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));

  Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 200));
      final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || boundary.debugNeedsPaint) { await Future.delayed(const Duration(milliseconds: 300)); }
      final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(path)], text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
    } catch (e) { debugPrint("Capture Error: $e"); }
  }

  _RiskSummary _computeRiskSummary({required int thisMonthIncome, required int thisMonthExpense, required int lastMonthExpense, required int overdueCount, required int totalOverdueAmount, required List<FinancialInsight> insights}) {
    int s = 0; if (overdueCount > 0) s += 20; if (thisMonthIncome < thisMonthExpense) s += 40;
    if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
    int fs = s.clamp(0, 100);
    return _RiskSummary(score: fs, level: fs >= 75 ? _RiskLevel.high : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount, reasons: []);
  }
}

enum _RiskLevel { low, mid, high }
class _RiskSummary { final int score; final _RiskLevel level; final List<String> reasons; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount}); }