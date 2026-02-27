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
// // // //     final currencyFmt =
// // // //     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[100],
// // // //       appBar: AppBar(
// // // //         backgroundColor: const Color(0xFF1A237E),
// // // //         foregroundColor: Colors.white,
// // // //         title: Text("NAV_REPORTS".tr(ref),
// // // //             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // //       ),
// // // //       body: Stack(
// // // //         children: [
// // // //           SingleChildScrollView(
// // // //             padding: const EdgeInsets.all(16),
// // // //             child: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
// // // //                 // 요청사항: 문구 한 줄, 버튼 다음 줄, 버튼 네이비, 카드 배경색 차별화 적용
// // // //                 if (!isPro) _buildMainProAnchor(context, ref),
// // // //
// // // //                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
// // // //                 monthlyTrendAsync.when(
// // // //                     loading: () => const SizedBox.shrink(),
// // // //                     error: (_, __) => const SizedBox.shrink(),
// // // //                     data: (trendData) => unpaidAsync.when(
// // // //                         loading: () => const SizedBox.shrink(),
// // // //                         error: (_, __) => const SizedBox.shrink(),
// // // //                         data: (unpaidList) {
// // // //                           int inC = 0, exC = 0, lastEx = 0;
// // // //                           final now = DateTime.now();
// // // //                           final thisMonth = trendData
// // // //                               .where((e) =>
// // // //                           e.month.year == now.year &&
// // // //                               e.month.month == now.month)
// // // //                               .toList();
// // // //                           if (thisMonth.isNotEmpty) {
// // // //                             inC = thisMonth.first.income;
// // // //                             exC = thisMonth.first.expense;
// // // //                           }
// // // //                           final last = DateTime(now.year, now.month - 1, 1);
// // // //                           final lastMonth = trendData
// // // //                               .where((e) =>
// // // //                           e.month.year == last.year &&
// // // //                               e.month.month == last.month)
// // // //                               .toList();
// // // //                           if (lastMonth.isNotEmpty)
// // // //                             lastEx = lastMonth.first.expense;
// // // //
// // // //                           final overdue = unpaidList
// // // //                               .where((u) => u.status == 'OVERDUE')
// // // //                               .toList();
// // // //                           final totalO = overdue.fold(
// // // //                               0, (sum, item) => sum + item.unit.monthlyRent);
// // // //
// // // //                           final insights = FinancialInsightService.generate(
// // // //                               thisMonthIncome: inC,
// // // //                               thisMonthExpense: exC,
// // // //                               lastMonthExpense: lastEx,
// // // //                               overdueCount: overdue.length,
// // // //                               totalOverdueAmount: totalO);
// // // //                           final risk = _computeRiskSummary(
// // // //                               thisMonthIncome: inC,
// // // //                               thisMonthExpense: exC,
// // // //                               lastMonthExpense: lastEx,
// // // //                               overdueCount: overdue.length,
// // // //                               totalOverdueAmount: totalO,
// // // //                               insights: insights);
// // // //
// // // //                           return Column(
// // // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // // //                               children: [
// // // //                                 _buildSectionTitle(Icons.lightbulb_outline,
// // // //                                     "REPORT_SEC_INSIGHTS".tr(ref)),
// // // //                                 const SizedBox(height: 10),
// // // //                                 if (!isPro)
// // // //                                 // 📍 [수정] 결제 유도 버튼 삭제 및 안내 문구 노출 (다국어 적용)
// // // //                                   _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
// // // //                                 else
// // // //                                   _buildRiskSummaryCard(
// // // //                                       ref, currencyFmt, risk, insights),
// // // //                                 const SizedBox(height: 20),
// // // //                               ]);
// // // //                         })),
// // // //
// // // //                 // ✅ [복구] 재무 분석 (그래프 수치 표시 복구)
// // // //                 _buildSectionTitle(
// // // //                     Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // //                 const SizedBox(height: 10),
// // // //                 // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
// // // //                 _buildFinancialAnalytics(ref, monthlyTrendAsync,
// // // //                     categoryStatsAsync, currencyFmt, lang, isPro),
// // // //
// // // //                 const SizedBox(height: 30),
// // // //                 _buildSectionTitle(
// // // //                     Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // //                 const SizedBox(height: 10),
// // // //                 _buildTaxSection(context, ref, isPro),
// // // //
// // // //                 const SizedBox(height: 30),
// // // //                 _buildSectionTitle(Icons.notification_important_outlined,
// // // //                     "REPORT_SEC_UNPAID".tr(ref)),
// // // //                 const SizedBox(height: 10),
// // // //                 _buildUnpaidSection(
// // // //                     context, ref, unpaidAsync, currencyFmt, isPro),
// // // //
// // // //                 const SizedBox(height: 30),
// // // //                 // ✅ [복구] 연간 요약 타이틀 복구
// // // //                 _buildSectionTitle(Icons.table_chart_outlined,
// // // //                     "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // //                 const SizedBox(height: 10),
// // // //                 _buildAnnualSummary(
// // // //                     context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //
// // // //           // 📍 캡처 전용 위젯 (공백 문제 해결을 위해 화면 밖 배치)
// // // //           Transform.translate(
// // // //             offset: const Offset(-5000, -5000),
// // // //             child: RepaintBoundary(
// // // //               key: _unpaidCaptureKey,
// // // //               child: Container(
// // // //                 width: 450,
// // // //                 padding: const EdgeInsets.all(30),
// // // //                 color: Colors.white,
// // // //                 child: unpaidAsync.when(
// // // //                   data: (list) {
// // // //                     final overdue =
// // // //                     list.where((u) => u.status == 'OVERDUE').toList();
// // // //                     final total = overdue.fold(
// // // //                         0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                     return Column(
// // // //                       mainAxisSize: MainAxisSize.min,
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: [
// // // //                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
// // // //                             style: const TextStyle(
// // // //                                 color: Color(0xFF1A237E),
// // // //                                 fontSize: 24,
// // // //                                 fontWeight: FontWeight.bold)),
// // // //                         const Divider(color: Color(0xFF1A237E), thickness: 3),
// // // //                         const SizedBox(height: 20),
// // // //                         Text(
// // // //                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
// // // //                             style: const TextStyle(
// // // //                                 color: Colors.red,
// // // //                                 fontSize: 28,
// // // //                                 fontWeight: FontWeight.w900)),
// // // //                         const SizedBox(height: 30),
// // // //                         ...overdue
// // // //                             .map((u) => Container(
// // // //                           margin: const EdgeInsets.only(bottom: 15),
// // // //                           padding: const EdgeInsets.all(15),
// // // //                           decoration: BoxDecoration(
// // // //                               color: Colors.grey[50],
// // // //                               border:
// // // //                               Border.all(color: Colors.grey[300]!),
// // // //                               borderRadius: BorderRadius.circular(10)),
// // // //                           child: Column(children: [
// // // //                             Row(
// // // //                                 mainAxisAlignment:
// // // //                                 MainAxisAlignment.spaceBetween,
// // // //                                 children: [
// // // //                                   Text(
// // // //                                       "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
// // // //                                       style: const TextStyle(
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           fontSize: 18)),
// // // //                                   Text(
// // // //                                       currencyFmt
// // // //                                           .format(u.unit.monthlyRent),
// // // //                                       style: const TextStyle(
// // // //                                           color: Color(0xFF1A237E),
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           fontSize: 18)),
// // // //                                 ]),
// // // //                             const SizedBox(height: 10),
// // // //                             Row(
// // // //                                 mainAxisAlignment:
// // // //                                 MainAxisAlignment.spaceBetween,
// // // //                                 children: [
// // // //                                   Text(u.unit.tenantPhone ?? '-',
// // // //                                       style: const TextStyle(
// // // //                                           color: Colors.black54,
// // // //                                           fontSize: 14)),
// // // //                                   Text(
// // // //                                       "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
// // // //                                       style: const TextStyle(
// // // //                                           color: Colors.redAccent,
// // // //                                           fontSize: 14,
// // // //                                           fontWeight: FontWeight.bold)),
// // // //                                 ]),
// // // //                           ]),
// // // //                         ))
// // // //                             .toList(),
// // // //                         const SizedBox(height: 30),
// // // //                         const Center(
// // // //                             child: Text("Generated by SiRE Asset Management",
// // // //                                 style: TextStyle(
// // // //                                     color: Colors.grey,
// // // //                                     fontSize: 12,
// // // //                                     letterSpacing: 1.5))),
// // // //                       ],
// // // //                     );
// // // //                   },
// // // //                   loading: () => const SizedBox.shrink(),
// // // //                   error: (_, __) => const SizedBox.shrink(),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ [신규/수정] 상단 메인 Pro 안내 카드 (디자인 요청사항 반영)
// // // //   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
// // // //     return Container(
// // // //       margin: const EdgeInsets.only(bottom: 25),
// // // //       padding: const EdgeInsets.all(20),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.blueGrey[50], // 카드 색상 다르게 설정 (밝은 회청색)
// // // //         borderRadius: BorderRadius.circular(16),
// // // //         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
// // // //       ),
// // // //       child: Column( // 버튼을 다음 줄로 보내기 위해 Column 사용
// // // //         children: [
// // // //           Row(
// // // //             children: [
// // // //               // 📍 아이콘 변경: Icons.workspace_premium_outlined
// // // //               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                 child: Text(
// // // //                   "REPORT_MAIN_PRO_TEXT".tr(ref), // 다국어 키 (보고서는 SiRE Pro 기능입니다.)
// // // //                   style: const TextStyle(
// // // //                       color: Color(0xFF1A237E),
// // // //                       fontWeight: FontWeight.bold,
// // // //                       fontSize: 15),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //           const SizedBox(height: 16),
// // // //           SizedBox(
// // // //             width: double.infinity,
// // // //             child: ElevatedButton(
// // // //               onPressed: () => _openPaywall(context),
// // // //               style: ElevatedButton.styleFrom(
// // // //                 backgroundColor: const Color(0xFF1A237E), // 버튼 네이비 색상 유지
// // // //                 foregroundColor: Colors.white,
// // // //                 padding: const EdgeInsets.symmetric(vertical: 12),
// // // //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //               ),
// // // //               // 📍 키 변경: SETTINGS_PRO_BUY_LIFETIME_TITLE (Pro 구매(평생))
// // // //               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // 📍 [신규] 일관성 있는 단순 안내 텍스트 카드
// // // //   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.all(20),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         border: Border.all(color: Colors.grey.shade300),
// // // //       ),
// // // //       child: Text(
// // // //         text,
// // // //         textAlign: TextAlign.center,
// // // //         style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ [복구/수정] 재무 분석 카드 (그래프 위 수치 표시 및 Pro 구매 여부 체크 포함)
// // // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend,
// // // //       AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
// // // //
// // // //     // 📍 [수정] Pro 미구매 시 다른 영역과 동일한 사이즈의 안내 카드를 보여줌
// // // //     if (!isPro) {
// // // //       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
// // // //     }
// // // //
// // // //     return Container(
// // // //       height: 320,
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           boxShadow: [
// // // //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // // //           ]),
// // // //       child: monthlyTrend.when(
// // // //           loading: () => const Center(child: CircularProgressIndicator()),
// // // //           error: (_, __) => const SizedBox.shrink(),
// // // //           data: (trendData) {
// // // //             final List<BarChartGroupData> barGroups =
// // // //             (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // // //               final List<int> indicators = [];
// // // //               if (e.value.income > 0) indicators.add(0);
// // // //               if (e.value.expense > 0) indicators.add(1);
// // // //               return BarChartGroupData(
// // // //                   x: e.key,
// // // //                   barsSpace: 4,
// // // //                   showingTooltipIndicators: indicators,
// // // //                   barRods: [
// // // //                     BarChartRodData(
// // // //                         toY: e.value.income.toDouble(),
// // // //                         color: Colors.blue,
// // // //                         width: 8,
// // // //                         borderRadius: const BorderRadius.vertical(
// // // //                             top: Radius.circular(2))),
// // // //                     BarChartRodData(
// // // //                         toY: e.value.expense.toDouble(),
// // // //                         color: Colors.redAccent,
// // // //                         width: 8,
// // // //                         borderRadius: const BorderRadius.vertical(
// // // //                             top: Radius.circular(2))),
// // // //                   ]);
// // // //             }).toList();
// // // //             return Row(children: [
// // // //               Expanded(
// // // //                   flex: 3,
// // // //                   child: Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: [
// // // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
// // // //                             style: const TextStyle(
// // // //                                 fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                         const SizedBox(height: 25),
// // // //                         Expanded(
// // // //                             child: BarChart(BarChartData(
// // // //                               barTouchData: BarTouchData(
// // // //                                   enabled: false,
// // // //                                   touchTooltipData: BarTouchTooltipData(
// // // //                                     tooltipBgColor: Colors.transparent,
// // // //                                     tooltipPadding: EdgeInsets.zero,
// // // //                                     tooltipMargin: 4,
// // // //                                     getTooltipItem:
// // // //                                         (group, groupIndex, rod, rodIndex) =>
// // // //                                     rod.toY == 0
// // // //                                         ? null
// // // //                                         : BarTooltipItem(
// // // //                                         fmt.format(rod.toY),
// // // //                                         TextStyle(
// // // //                                             color: rod.color,
// // // //                                             fontWeight: FontWeight.bold,
// // // //                                             fontSize: 9)),
// // // //                                   )),
// // // //                               gridData: const FlGridData(show: false),
// // // //                               borderData: FlBorderData(show: false),
// // // //                               titlesData: FlTitlesData(
// // // //                                 topTitles: const AxisTitles(
// // // //                                     sideTitles: SideTitles(showTitles: false)),
// // // //                                 rightTitles: const AxisTitles(
// // // //                                     sideTitles: SideTitles(showTitles: false)),
// // // //                                 leftTitles: const AxisTitles(
// // // //                                     sideTitles: SideTitles(showTitles: false)),
// // // //                                 bottomTitles: AxisTitles(
// // // //                                     sideTitles: SideTitles(
// // // //                                         showTitles: true,
// // // //                                         getTitlesWidget: (v, m) {
// // // //                                           int i = v.toInt();
// // // //                                           if (i >= 0 && i < trendData.length)
// // // //                                             return Padding(
// // // //                                                 padding:
// // // //                                                 const EdgeInsets.only(top: 8),
// // // //                                                 child: Text(
// // // //                                                     DateFormat.MMM(lang)
// // // //                                                         .format(trendData[i].month),
// // // //                                                     style: const TextStyle(
// // // //                                                         fontSize: 9)));
// // // //                                           return const Text('');
// // // //                                         })),
// // // //                               ),
// // // //                               barGroups: barGroups,
// // // //                             ))),
// // // //                         const SizedBox(height: 12),
// // // //                         Row(children: [
// // // //                           _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // // //                           const SizedBox(width: 12),
// // // //                           _buildLegend(
// // // //                               Colors.redAccent, "COMMON_EXPENSE".tr(ref))
// // // //                         ])
// // // //                       ])),
// // // //               const SizedBox(width: 12),
// // // //               Expanded(
// // // //                   flex: 2,
// // // //                   child: categoryStats.when(
// // // //                       loading: () => const SizedBox.shrink(),
// // // //                       error: (_, __) => const SizedBox.shrink(),
// // // //                       data: (sData) {
// // // //                         final colors = [
// // // //                           Colors.indigo,
// // // //                           Colors.teal,
// // // //                           Colors.orange,
// // // //                           Colors.brown,
// // // //                           Colors.purple
// // // //                         ];
// // // //                         final List<PieChartSectionData> pieSections =
// // // //                         (sData as List)
// // // //                             .asMap()
// // // //                             .entries
// // // //                             .map<PieChartSectionData>((entry) {
// // // //                           return PieChartSectionData(
// // // //                               value: entry.value.amount.toDouble(),
// // // //                               color: colors[entry.key % colors.length],
// // // //                               radius: 40,
// // // //                               title: '');
// // // //                         }).toList();
// // // //                         return Column(children: [
// // // //                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
// // // //                               style: const TextStyle(
// // // //                                   fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                           const SizedBox(height: 10),
// // // //                           Expanded(
// // // //                               flex: 3,
// // // //                               child: PieChart(PieChartData(
// // // //                                   sectionsSpace: 2,
// // // //                                   centerSpaceRadius: 10,
// // // //                                   sections: pieSections))),
// // // //                           const SizedBox(height: 12),
// // // //                           Expanded(
// // // //                               flex: 3,
// // // //                               child: SingleChildScrollView(
// // // //                                   child: Column(
// // // //                                       crossAxisAlignment:
// // // //                                       CrossAxisAlignment.start,
// // // //                                       children:
// // // //                                       sData.asMap().entries.map((entry) {
// // // //                                         final String name = entry.value.category
// // // //                                             .toString()
// // // //                                             .startsWith('CAT_')
// // // //                                             ? entry.value.category
// // // //                                             .toString()
// // // //                                             .tr(ref)
// // // //                                             : entry.value.category.toString();
// // // //                                         return Padding(
// // // //                                             padding: const EdgeInsets.symmetric(
// // // //                                                 vertical: 3),
// // // //                                             child: _buildLegend(
// // // //                                                 colors[
// // // //                                                 entry.key % colors.length],
// // // //                                                 "$name (${fmt.format(entry.value.amount)})",
// // // //                                                 fontSize: 9));
// // // //                                       }).toList()))),
// // // //                         ]);
// // // //                       }))
// // // //             ]);
// // // //           }),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ [복구] 종합 진단 결과 카드 (범례 및 상세 타일 100% 복원)
// // // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt,
// // // //       _RiskSummary risk, List<FinancialInsight> insights) {
// // // //     const Color mainIndigo = Color(0xFF1A237E);
// // // //     final Color overdueColor = const Color(0xFFEF5350);
// // // //     final Color deficitColor = const Color(0xFFFFA726);
// // // //     final Color spikeColor = const Color(0xFF8D6E63);
// // // //     final Color safeColor = Colors.grey[200]!;
// // // //
// // // //     final bool hasOverdue = risk.overdueCount > 0;
// // // //     final bool hasDeficit = risk.balance < 0;
// // // //     final bool hasSpike = insights.any((i) =>
// // // //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // // //
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           border: Border.all(color: Colors.grey.shade300!),
// // // //           boxShadow: [
// // // //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // // //           ]),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // // //             Row(children: [
// // // //               Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// // // //               const SizedBox(width: 10),
// // // //               Text('REPORT_RISK_TITLE'.tr(ref),
// // // //                   style: const TextStyle(
// // // //                       fontSize: 16,
// // // //                       fontWeight: FontWeight.bold,
// // // //                       color: mainIndigo))
// // // //             ]),
// // // //             Text("${risk.score}/100",
// // // //                 style: const TextStyle(
// // // //                     color: mainIndigo,
// // // //                     fontWeight: FontWeight.w900,
// // // //                     fontSize: 18)),
// // // //           ]),
// // // //           const SizedBox(height: 16),
// // // //           ClipRRect(
// // // //               borderRadius: BorderRadius.circular(8),
// // // //               child: SizedBox(
// // // //                   height: 14,
// // // //                   child: Row(children: [
// // // //                     if (hasOverdue)
// // // //                       Expanded(flex: 20, child: Container(color: overdueColor)),
// // // //                     if (hasDeficit)
// // // //                       Expanded(flex: 35, child: Container(color: deficitColor)),
// // // //                     if (hasSpike)
// // // //                       Expanded(flex: 25, child: Container(color: spikeColor)),
// // // //                     Expanded(
// // // //                         flex: (100 -
// // // //                             (hasOverdue ? 20 : 0) -
// // // //                             (hasDeficit ? 35 : 0) -
// // // //                             (hasSpike ? 25 : 0))
// // // //                             .toInt()
// // // //                             .clamp(5, 100),
// // // //                         child: Container(color: safeColor)),
// // // //                   ]))),
// // // //           const SizedBox(height: 12),
// // // //           // 🏷️ 원본 인덱스 범례 복구
// // // //           Center(
// // // //               child: Wrap(
// // // //                   spacing: 12,
// // // //                   runSpacing: 8,
// // // //                   alignment: WrapAlignment.center,
// // // //                   children: [
// // // //                     _buildRiskLegend(
// // // //                         overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// // // //                     _buildRiskLegend(
// // // //                         deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// // // //                     _buildRiskLegend(
// // // //                         spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// // // //                     _buildRiskLegend(
// // // //                         Colors.grey[400]!,
// // // //                         "INSIGHT_LABEL_SAFE".tr(ref),
// // // //                         !hasOverdue && !hasDeficit && !hasSpike),
// // // //                   ])),
// // // //           const SizedBox(height: 20),
// // // //           // 🏷️ 원본 상세 타일(잔액, 미납건수) 복구
// // // //           Row(children: [
// // // //             _infoTile(ref, "COMMON_BALANCE".tr(ref),
// // // //                 currencyFmt.format(risk.balance)),
// // // //             const SizedBox(width: 10),
// // // //             _infoTile(
// // // //                 ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // // //           ]),
// // // //           const SizedBox(height: 12),
// // // //           const Divider(),
// // // //           ...insights.map((insight) {
// // // //             String message = insight.messageKey.tr(ref);
// // // //             insight.arguments?.forEach(
// // // //                     (key, value) => message = message.replaceAll('{$key}', value));
// // // //             return Padding(
// // // //                 padding: const EdgeInsets.only(top: 8),
// // // //                 child: Row(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       const Icon(Icons.check_circle_outline,
// // // //                           color: mainIndigo, size: 16),
// // // //                       const SizedBox(width: 6),
// // // //                       Expanded(
// // // //                           child: Text(message,
// // // //                               style: const TextStyle(
// // // //                                   fontSize: 13,
// // // //                                   color: Colors.black87,
// // // //                                   fontWeight: FontWeight.w500)))
// // // //                     ]));
// // // //           }).toList(),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // 나머지 원본 헬퍼 메서드들 (isBold 파라미터 보정 완료)
// // // //   Widget _buildSummaryRow(
// // // //       NumberFormat fmt, String label, int amount, Color color,
// // // //       {required bool isBold}) =>
// // // //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // // //         Text(label,
// // // //             style: TextStyle(
// // // //                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
// // // //         Text(fmt.format(amount),
// // // //             style: TextStyle(fontWeight: FontWeight.bold, color: color))
// // // //       ]);
// // // //
// // // //   Widget _buildRiskLegend(Color color, String label, bool isActive) =>
// // // //       Row(mainAxisSize: MainAxisSize.min, children: [
// // // //         Opacity(
// // // //             opacity: isActive ? 1.0 : 0.2,
// // // //             child: Container(
// // // //                 width: 10,
// // // //                 height: 10,
// // // //                 decoration: BoxDecoration(
// // // //                     color: color, borderRadius: BorderRadius.circular(2)))),
// // // //         const SizedBox(width: 6),
// // // //         Text(label,
// // // //             style: TextStyle(
// // // //                 fontSize: 11,
// // // //                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// // // //                 color: isActive ? Colors.black : Colors.grey[500]))
// // // //       ]);
// // // //
// // // //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(
// // // //       child: Container(
// // // //           padding: const EdgeInsets.all(10),
// // // //           decoration: BoxDecoration(
// // // //               color: Colors.grey[50],
// // // //               borderRadius: BorderRadius.circular(8),
// // // //               border: Border.all(color: Colors.grey.shade200)),
// // // //           child:
// // // //           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //             Text(label,
// // // //                 style: TextStyle(fontSize: 10, color: Colors.grey[600])),
// // // //             Text(value,
// // // //                 style: const TextStyle(
// // // //                     fontSize: 14,
// // // //                     fontWeight: FontWeight.bold,
// // // //                     color: Color(0xFF1A237E)))
// // // //           ])));
// // // //
// // // //   Widget _buildSectionTitle(IconData i, String t) => Row(children: [
// // // //     Icon(i, color: const Color(0xFF1A237E)),
// // // //     const SizedBox(width: 8),
// // // //     Text(t,
// // // //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
// // // //   ]);
// // // //
// // // //   Widget _buildLegend(Color c, String l, {double fontSize = 10}) =>
// // // //       Row(mainAxisSize: MainAxisSize.min, children: [
// // // //         Container(
// // // //             width: 8,
// // // //             height: 8,
// // // //             decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
// // // //         const SizedBox(width: 6),
// // // //         Flexible(
// // // //             child: Text(l,
// // // //                 style:
// // // //                 TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
// // // //                 overflow: TextOverflow.ellipsis))
// // // //       ]);
// // // //
// // // //   Widget _buildTaxSection(BuildContext c, WidgetRef r, bool isPro) => Container(
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           boxShadow: [
// // // //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // // //           ]),
// // // //       child: Column(children: [
// // // //         Container(
// // // //             padding: const EdgeInsets.all(12),
// // // //             decoration: BoxDecoration(
// // // //                 border: Border.all(color: Colors.grey.shade300),
// // // //                 borderRadius: BorderRadius.circular(8)),
// // // //             child: Row(
// // // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                 children: [
// // // //                   Expanded(
// // // //                       child: Text(
// // // //                           "${'REPORT_TAX_PERIOD'.tr(r)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(r)}",
// // // //                           style: const TextStyle(fontSize: 13))),
// // // //                   const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
// // // //                 ])),
// // // //         const SizedBox(height: 20),
// // // //         SizedBox(
// // // //             width: double.infinity,
// // // //             child: ElevatedButton.icon(
// // // //                 style: ElevatedButton.styleFrom(
// // // //                     backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
// // // //                     foregroundColor: isPro ? Colors.white : Colors.grey[600],
// // // //                     padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                     shape: RoundedRectangleBorder(
// // // //                         borderRadius: BorderRadius.circular(8))),
// // // //                 onPressed: isPro ? () async {
// // // //                   final raw = r.read(ledgerListProvider).value ?? [];
// // // //                   final transactions = raw.map((e) => e.transaction).toList();
// // // //                   await ExcelExportService()
// // // //                       .exportTransactionsToExcel(transactions, r);
// // // //                 } : null, // 📍 null을 통해 버튼 물리적 비활성화
// // // //                 icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
// // // //                 label: Text("REPORT_BTN_TAX_EXCEL".tr(r),
// // // //                     style: const TextStyle(fontWeight: FontWeight.bold))))
// // // //       ]));
// // // //
// // // //   // ✅ [수정] 미납 관리 섹션 (무료 사용자 시 정보 숨김 로직 추가)
// // // //   Widget _buildUnpaidSection(BuildContext c, WidgetRef r,
// // // //       AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // // //       Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //               color: Colors.white,
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               boxShadow: [
// // // //                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // // //               ]),
// // // //           child: Column(children: [
// // // //             unpaidAsync.when(
// // // //                 loading: () => const Center(child: CircularProgressIndicator()),
// // // //                 error: (_, __) => const SizedBox(),
// // // //                 data: (list) {
// // // //                   final overdue =
// // // //                   list.where((u) => u.status == 'OVERDUE').toList();
// // // //                   final total = overdue.fold(
// // // //                       0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                   if (overdue.isEmpty)
// // // //                     return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r),
// // // //                         textAlign: TextAlign.center);
// // // //
// // // //                   // 📍 [로직 추가] Pro 사용자에게만 미납 상세 정보를 보여줌 (다국어 키 적용)
// // // //                   if (!isPro) {
// // // //                     return Container(
// // // //                       width: double.infinity,
// // // //                       padding: const EdgeInsets.all(16),
// // // //                       decoration: BoxDecoration(
// // // //                           color: Colors.grey[50],
// // // //                           borderRadius: BorderRadius.circular(8)),
// // // //                       child: Center(
// // // //                         child: Text(
// // // //                           "REPORT_LOCK_UNPAID".tr(r),
// // // //                           style: TextStyle(color: Colors.grey[600], fontSize: 13),
// // // //                         ),
// // // //                       ),
// // // //                     );
// // // //                   }
// // // //
// // // //                   return Container(
// // // //                       width: double.infinity,
// // // //                       padding: const EdgeInsets.all(12),
// // // //                       decoration: BoxDecoration(
// // // //                           color: Colors.grey[50],
// // // //                           borderRadius: BorderRadius.circular(8)),
// // // //                       child: Column(
// // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // //                           children: [
// // // //                             Text(
// // // //                                 "${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}",
// // // //                                 style: const TextStyle(
// // // //                                     color: Colors.red,
// // // //                                     fontWeight: FontWeight.bold)),
// // // //                             const SizedBox(height: 8),
// // // //                             ...overdue.take(3).map((u) => Text(
// // // //                                 "• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}",
// // // //                                 style: const TextStyle(fontSize: 12)))
// // // //                           ]));
// // // //                 }),
// // // //             const SizedBox(height: 20),
// // // //             Row(children: [
// // // //               Expanded(
// // // //                   child: ElevatedButton.icon(
// // // //                       style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
// // // //                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
// // // //                           padding: const EdgeInsets.symmetric(vertical: 14),
// // // //                           shape: RoundedRectangleBorder(
// // // //                               borderRadius: BorderRadius.circular(8))),
// // // //                       onPressed: isPro ? () async {
// // // //                         await ExcelExportService().exportUnpaidListToExcel(
// // // //                             unpaidAsync.value ?? [], r);
// // // //                       } : null,
// // // //                       icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
// // // //                       label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r),
// // // //                           style: const TextStyle(
// // // //                               fontSize: 12, fontWeight: FontWeight.bold)))),
// // // //               const SizedBox(width: 10),
// // // //               Expanded(
// // // //                   child: ElevatedButton.icon(
// // // //                       style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300], // 📍 비활성화 색상 적용
// // // //                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
// // // //                           padding: const EdgeInsets.symmetric(vertical: 14),
// // // //                           shape: RoundedRectangleBorder(
// // // //                               borderRadius: BorderRadius.circular(8))),
// // // //                       onPressed: isPro ? () async {
// // // //                         await _captureAndShare(_unpaidCaptureKey, r);
// // // //                       } : null,
// // // //                       icon: Icon(isPro ? Icons.share_outlined : Icons.lock_outline, size: 18),
// // // //                       label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r),
// // // //                           style: const TextStyle(
// // // //                               fontSize: 12, fontWeight: FontWeight.bold))))
// // // //             ])
// // // //           ]));
// // // //
// // // //   Widget _buildAnnualSummary(
// // // //       BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
// // // //     // 📍 p (isPro) 여부에 따라 전체 콘텐츠 노출 여부 결정 (다국어 적용)
// // // //     if (!p)
// // // //       return _buildSimpleLockCard(r, "REPORT_LOCK_ANNUAL".tr(r));
// // // //
// // // //     return Container(
// // // //         padding: const EdgeInsets.all(16),
// // // //         decoration: BoxDecoration(
// // // //             color: Colors.white,
// // // //             borderRadius: BorderRadius.circular(12),
// // // //             boxShadow: [
// // // //               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // // //             ]),
// // // //         child: t.when(
// // // //             loading: () => const SizedBox(),
// // // //             error: (_, __) => const SizedBox(),
// // // //             data: (trend) {
// // // //               final y = DateTime.now().year;
// // // //               final cur = trend.where((e) => e.month.year == y).toList();
// // // //               int inc = cur.fold(0, (s, e) => s + e.income);
// // // //               int exp = cur.fold(0, (s, e) => s + e.expense);
// // // //               return Column(children: [
// // // //                 Row(mainAxisAlignment: MainAxisAlignment.end, children: [
// // // //                   Text("${'COMMON_YEAR'.tr(r)}: $y",
// // // //                       style: const TextStyle(
// // // //                           fontSize: 12, fontWeight: FontWeight.bold))
// // // //                 ]),
// // // //                 const SizedBox(height: 10),
// // // //                 _buildSummaryRow(
// // // //                     f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue,
// // // //                     isBold: false),
// // // //                 const Divider(height: 20),
// // // //                 _buildSummaryRow(
// // // //                     f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent,
// // // //                     isBold: false),
// // // //                 const Divider(height: 20),
// // // //                 _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp,
// // // //                     Colors.indigo,
// // // //                     isBold: true)
// // // //               ]);
// // // //             }));
// // // //   }
// // // //
// // // //   // 📍 [원본 유지] Pro 전용 잠금 카드 스타일 (네이비 브랜드 컬러 적용)
// // // //   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) =>
// // // //       Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
// // // //           child: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]),
// // // //                 const SizedBox(height: 8),
// // // //                 Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
// // // //                 const SizedBox(height: 12),
// // // //                 Align(
// // // //                   alignment: Alignment.centerRight,
// // // //                   child: ElevatedButton(
// // // //                     onPressed: onTap,
// // // //                     style: ElevatedButton.styleFrom(
// // // //                       backgroundColor: const Color(0xFF1A237E), // SiRE 메인 네이비 색상
// // // //                       foregroundColor: Colors.white,            // 글자색 흰색
// // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //                     ),
// // // //                     child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r)),
// // // //                   ),
// // // //                 )
// // // //               ]
// // // //           )
// // // //       );
// // // //
// // // //   void _openPaywall(BuildContext c) => Navigator.of(c)
// // // //       .push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // // //
// // // //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // // //     try {
// // // //       await WidgetsBinding.instance.endOfFrame;
// // // //       await Future.delayed(const Duration(milliseconds: 200));
// // // //       final RenderRepaintBoundary? boundary =
// // // //       key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// // // //       if (boundary == null || boundary.debugNeedsPaint) {
// // // //         await Future.delayed(const Duration(milliseconds: 300));
// // // //       }
// // // //       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
// // // //       final ByteData? byteData =
// // // //       await image.toByteData(format: ui.ImageByteFormat.png);
// // // //       final Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // //       final directory = await getTemporaryDirectory();
// // // //       final path =
// // // //           '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// // // //       await File(path).writeAsBytes(pngBytes);
// // // //       await Share.shareXFiles([XFile(path)],
// // // //           text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
// // // //     } catch (e) {
// // // //       debugPrint("Capture Error: $e");
// // // //     }
// // // //   }
// // // //
// // // //   _RiskSummary _computeRiskSummary(
// // // //       {required int thisMonthIncome,
// // // //         required int thisMonthExpense,
// // // //         required int lastMonthExpense,
// // // //         required int overdueCount,
// // // //         required int totalOverdueAmount,
// // // //         required List<FinancialInsight> insights}) {
// // // //     int s = 0;
// // // //     if (overdueCount > 0) s += 20;
// // // //     if (thisMonthIncome < thisMonthExpense) s += 40;
// // // //     if (insights.any((i) =>
// // // //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')))
// // // //       s += 25;
// // // //     int fs = s.clamp(0, 100);
// // // //     return _RiskSummary(
// // // //         score: fs,
// // // //         level: fs >= 75
// // // //             ? _RiskLevel.high
// // // //             : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low),
// // // //         balance: thisMonthIncome - thisMonthExpense,
// // // //         overdueCount: overdueCount,
// // // //         reasons: []);
// // // //   }
// // // // }
// // // //
// // // // enum _RiskLevel { low, mid, high }
// // // //
// // // // class _RiskSummary {
// // // //   final int score;
// // // //   final _RiskLevel level;
// // // //   final List<String> reasons;
// // // //   final int balance;
// // // //   final int overdueCount;
// // // //
// // // //   _RiskSummary(
// // // //       {required this.score,
// // // //         required this.level,
// // // //         required this.reasons,
// // // //         required this.balance,
// // // //         required this.overdueCount});
// // // // }
// // //
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
// // // import 'financial_insight_service.dart';
// // //
// // // class ReportsScreen extends ConsumerWidget {
// // //   const ReportsScreen({super.key});
// // //
// // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // //
// // //   @override
// // //   Widget build(BuildContext context, WidgetRef ref) {
// // //     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
// // //     final isPro = ref.watch(isProProvider);
// // //
// // //     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
// // //     // 이 화면이 빌드될 때 Pro 상태로 변경되면, 스택에 쌓인 PaywallScreen을 닫습니다.
// // //     ref.listen<bool>(isProProvider, (previous, next) {
// // //       if (previous == false && next == true) {
// // //         // 이전에 유료가 아니었다가 지금 유료가 된 경우 (결제 성공)
// // //         // 현재 화면 위에 열려있는 다이얼로그나 페이지(Paywall)가 있다면 닫습니다.
// // //         if (Navigator.of(context).canPop()) {
// // //           Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/main_screen');
// // //         }
// // //       }
// // //     });
// // //
// // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // //     final currencyFmt =
// // //     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // //
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[100],
// // //       appBar: AppBar(
// // //         backgroundColor: const Color(0xFF1A237E),
// // //         foregroundColor: Colors.white,
// // //         title: Text("NAV_REPORTS".tr(ref),
// // //             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // //       ),
// // //       body: Stack(
// // //         children: [
// // //           SingleChildScrollView(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
// // //                 // 요청사항: 문구 한 줄, 버튼 다음 줄, 버튼 네이비, 카드 배경색 차별화 적용
// // //                 if (!isPro) _buildMainProAnchor(context, ref),
// // //
// // //                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
// // //                 monthlyTrendAsync.when(
// // //                     loading: () => const SizedBox.shrink(),
// // //                     error: (_, __) => const SizedBox.shrink(),
// // //                     data: (trendData) => unpaidAsync.when(
// // //                         loading: () => const SizedBox.shrink(),
// // //                         error: (_, __) => const SizedBox.shrink(),
// // //                         data: (unpaidList) {
// // //                           int inC = 0, exC = 0, lastEx = 0;
// // //                           final now = DateTime.now();
// // //                           final thisMonth = trendData
// // //                               .where((e) =>
// // //                           e.month.year == now.year &&
// // //                               e.month.month == now.month)
// // //                               .toList();
// // //                           if (thisMonth.isNotEmpty) {
// // //                             inC = thisMonth.first.income;
// // //                             exC = thisMonth.first.expense;
// // //                           }
// // //                           final last = DateTime(now.year, now.month - 1, 1);
// // //                           final lastMonth = trendData
// // //                               .where((e) =>
// // //                           e.month.year == last.year &&
// // //                               e.month.month == last.month)
// // //                               .toList();
// // //                           if (lastMonth.isNotEmpty)
// // //                             lastEx = lastMonth.first.expense;
// // //
// // //                           final overdue = unpaidList
// // //                               .where((u) => u.status == 'OVERDUE')
// // //                               .toList();
// // //                           final totalO = overdue.fold(
// // //                               0, (sum, item) => sum + item.unit.monthlyRent);
// // //
// // //                           final insights = FinancialInsightService.generate(
// // //                               thisMonthIncome: inC,
// // //                               thisMonthExpense: exC,
// // //                               lastMonthExpense: lastEx,
// // //                               overdueCount: overdue.length,
// // //                               totalOverdueAmount: totalO);
// // //                           final risk = _computeRiskSummary(
// // //                               thisMonthIncome: inC,
// // //                               thisMonthExpense: exC,
// // //                               lastMonthExpense: lastEx,
// // //                               overdueCount: overdue.length,
// // //                               totalOverdueAmount: totalO,
// // //                               insights: insights);
// // //
// // //                           return Column(
// // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // //                               children: [
// // //                                 _buildSectionTitle(Icons.lightbulb_outline,
// // //                                     "REPORT_SEC_INSIGHTS".tr(ref)),
// // //                                 const SizedBox(height: 10),
// // //                                 if (!isPro)
// // //                                 // 📍 [수정] 결제 유도 버튼 삭제 및 안내 문구 노출 (다국어 적용)
// // //                                   _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
// // //                                 else
// // //                                   _buildRiskSummaryCard(
// // //                                       ref, currencyFmt, risk, insights),
// // //                                 const SizedBox(height: 20),
// // //                               ]);
// // //                         })),
// // //
// // //                 // ✅ [복구] 재무 분석 (그래프 수치 표시 복구)
// // //                 _buildSectionTitle(
// // //                     Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
// // //                 _buildFinancialAnalytics(ref, monthlyTrendAsync,
// // //                     categoryStatsAsync, currencyFmt, lang, isPro),
// // //
// // //                 const SizedBox(height: 30),
// // //                 _buildSectionTitle(
// // //                     Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 _buildTaxSection(context, ref, isPro),
// // //
// // //                 const SizedBox(height: 30),
// // //                 _buildSectionTitle(Icons.notification_important_outlined,
// // //                     "REPORT_SEC_UNPAID".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 _buildUnpaidSection(
// // //                     context, ref, unpaidAsync, currencyFmt, isPro),
// // //
// // //                 const SizedBox(height: 30),
// // //                 // ✅ [복구] 연간 요약 타이틀 복구
// // //                 _buildSectionTitle(Icons.table_chart_outlined,
// // //                     "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // //                 const SizedBox(height: 10),
// // //                 _buildAnnualSummary(
// // //                     context, ref, monthlyTrendAsync, currencyFmt, isPro),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           // 📍 캡처 전용 위젯 (공백 문제 해결을 위해 화면 밖 배치)
// // //           Transform.translate(
// // //             offset: const Offset(-5000, -5000),
// // //             child: RepaintBoundary(
// // //               key: _unpaidCaptureKey,
// // //               child: Container(
// // //                 width: 450,
// // //                 padding: const EdgeInsets.all(30),
// // //                 color: Colors.white,
// // //                 child: unpaidAsync.when(
// // //                   data: (list) {
// // //                     final overdue =
// // //                     list.where((u) => u.status == 'OVERDUE').toList();
// // //                     final total = overdue.fold(
// // //                         0, (sum, item) => sum + item.unit.monthlyRent);
// // //                     return Column(
// // //                       mainAxisSize: MainAxisSize.min,
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
// // //                             style: const TextStyle(
// // //                                 color: Color(0xFF1A237E),
// // //                                 fontSize: 24,
// // //                                 fontWeight: FontWeight.bold)),
// // //                         const Divider(color: Color(0xFF1A237E), thickness: 3),
// // //                         const SizedBox(height: 20),
// // //                         Text(
// // //                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
// // //                             style: const TextStyle(
// // //                                 color: Colors.red,
// // //                                 fontSize: 28,
// // //                                 fontWeight: FontWeight.w900)),
// // //                         const SizedBox(height: 30),
// // //                         ...overdue
// // //                             .map((u) => Container(
// // //                           margin: const EdgeInsets.only(bottom: 15),
// // //                           padding: const EdgeInsets.all(15),
// // //                           decoration: BoxDecoration(
// // //                               color: Colors.grey[50],
// // //                               border:
// // //                               Border.all(color: Colors.grey[300]!),
// // //                               borderRadius: BorderRadius.circular(10)),
// // //                           child: Column(children: [
// // //                             Row(
// // //                                 mainAxisAlignment:
// // //                                 MainAxisAlignment.spaceBetween,
// // //                                 children: [
// // //                                   Text(
// // //                                       "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
// // //                                       style: const TextStyle(
// // //                                           fontWeight: FontWeight.bold,
// // //                                           fontSize: 18)),
// // //                                   Text(
// // //                                       currencyFmt
// // //                                           .format(u.unit.monthlyRent),
// // //                                       style: const TextStyle(
// // //                                           color: Color(0xFF1A237E),
// // //                                           fontWeight: FontWeight.bold,
// // //                                           fontSize: 18)),
// // //                                 ]),
// // //                             const SizedBox(height: 10),
// // //                             Row(
// // //                                 mainAxisAlignment:
// // //                                 MainAxisAlignment.spaceBetween,
// // //                                 children: [
// // //                                   Text(u.unit.tenantPhone ?? '-',
// // //                                       style: const TextStyle(
// // //                                           color: Colors.black54,
// // //                                           fontSize: 14)),
// // //                                   Text(
// // //                                       "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
// // //                                       style: const TextStyle(
// // //                                           color: Colors.redAccent,
// // //                                           fontSize: 14,
// // //                                           fontWeight: FontWeight.bold)),
// // //                                 ]),
// // //                           ]),
// // //                         ))
// // //                             .toList(),
// // //                         const SizedBox(height: 30),
// // //                         const Center(
// // //                             child: Text("Generated by SiRE Asset Management",
// // //                                 style: TextStyle(
// // //                                     color: Colors.grey,
// // //                                     fontSize: 12,
// // //                                     letterSpacing: 1.5))),
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
// // //   // ✅ [신규/수정] 상단 메인 Pro 안내 카드 (디자인 요청사항 반영)
// // //   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 25),
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: Colors.blueGrey[50], // 카드 색상 다르게 설정 (밝은 회청색)
// // //         borderRadius: BorderRadius.circular(16),
// // //         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
// // //       ),
// // //       child: Column( // 버튼을 다음 줄로 보내기 위해 Column 사용
// // //         children: [
// // //           Row(
// // //             children: [
// // //               // 📍 아이콘 변경: Icons.workspace_premium_outlined
// // //               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
// // //               const SizedBox(width: 10),
// // //               Expanded(
// // //                 child: Text(
// // //                   "REPORT_MAIN_PRO_TEXT".tr(ref), // 다국어 키 (보고서는 SiRE Pro 기능입니다.)
// // //                   style: const TextStyle(
// // //                       color: Color(0xFF1A237E),
// // //                       fontWeight: FontWeight.bold,
// // //                       fontSize: 15),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 16),
// // //           SizedBox(
// // //             width: double.infinity,
// // //             child: ElevatedButton(
// // //               onPressed: () => _openPaywall(context),
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: const Color(0xFF1A237E), // 버튼 네이비 색상 유지
// // //                 foregroundColor: Colors.white,
// // //                 padding: const EdgeInsets.symmetric(vertical: 12),
// // //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //               ),
// // //               // 📍 키 변경: SETTINGS_PRO_BUY_LIFETIME_TITLE (Pro 구매(평생))
// // //               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // 📍 [신규] 일관성 있는 단순 안내 텍스트 카드
// // //   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: Border.all(color: Colors.grey.shade300),
// // //       ),
// // //       child: Text(
// // //         text,
// // //         textAlign: TextAlign.center,
// // //         style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [복구/수정] 재무 분석 카드 (그래프 위 수치 표시 및 Pro 구매 여부 체크 포함)
// // //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend,
// // //       AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
// // //
// // //     // 📍 [수정사항 반영] Pro 미구매 시 다른 영역과 동일한 카드 사이즈로 안내 메시지 출력
// // //     if (!isPro) {
// // //       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
// // //     }
// // //
// // //     return Container(
// // //       height: 320,
// // //       padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(
// // //           color: Colors.white,
// // //           borderRadius: BorderRadius.circular(12),
// // //           boxShadow: [
// // //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // //           ]),
// // //       child: monthlyTrend.when(
// // //           loading: () => const Center(child: CircularProgressIndicator()),
// // //           error: (_, __) => const SizedBox.shrink(),
// // //           data: (trendData) {
// // //             final List<BarChartGroupData> barGroups =
// // //             (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// // //               final List<int> indicators = [];
// // //               if (e.value.income > 0) indicators.add(0);
// // //               if (e.value.expense > 0) indicators.add(1);
// // //               return BarChartGroupData(
// // //                   x: e.key,
// // //                   barsSpace: 4,
// // //                   showingTooltipIndicators: indicators,
// // //                   barRods: [
// // //                     BarChartRodData(
// // //                         toY: e.value.income.toDouble(),
// // //                         color: Colors.blue,
// // //                         width: 8,
// // //                         borderRadius: const BorderRadius.vertical(
// // //                             top: Radius.circular(2))),
// // //                     BarChartRodData(
// // //                         toY: e.value.expense.toDouble(),
// // //                         color: Colors.redAccent,
// // //                         width: 8,
// // //                         borderRadius: const BorderRadius.vertical(
// // //                             top: Radius.circular(2))),
// // //                   ]);
// // //             }).toList();
// // //             return Row(children: [
// // //               Expanded(
// // //                   flex: 3,
// // //                   child: Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
// // //                             style: const TextStyle(
// // //                                 fontSize: 12, fontWeight: FontWeight.bold)),
// // //                         const SizedBox(height: 25),
// // //                         Expanded(
// // //                             child: BarChart(BarChartData(
// // //                               barTouchData: BarTouchData(
// // //                                   enabled: false,
// // //                                   touchTooltipData: BarTouchTooltipData(
// // //                                     tooltipBgColor: Colors.transparent,
// // //                                     tooltipPadding: EdgeInsets.zero,
// // //                                     tooltipMargin: 4,
// // //                                     getTooltipItem:
// // //                                         (group, groupIndex, rod, rodIndex) =>
// // //                                     rod.toY == 0
// // //                                         ? null
// // //                                         : BarTooltipItem(
// // //                                         fmt.format(rod.toY),
// // //                                         TextStyle(
// // //                                             color: rod.color,
// // //                                             fontWeight: FontWeight.bold,
// // //                                             fontSize: 9)),
// // //                                   )),
// // //                               gridData: const FlGridData(show: false),
// // //                               borderData: FlBorderData(show: false),
// // //                               titlesData: FlTitlesData(
// // //                                 topTitles: const AxisTitles(
// // //                                     sideTitles: SideTitles(showTitles: false)),
// // //                                 rightTitles: const AxisTitles(
// // //                                     sideTitles: SideTitles(showTitles: false)),
// // //                                 leftTitles: const AxisTitles(
// // //                                     sideTitles: SideTitles(showTitles: false)),
// // //                                 bottomTitles: AxisTitles(
// // //                                     sideTitles: SideTitles(
// // //                                         showTitles: true,
// // //                                         getTitlesWidget: (v, m) {
// // //                                           int i = v.toInt();
// // //                                           if (i >= 0 && i < trendData.length)
// // //                                             return Padding(
// // //                                                 padding:
// // //                                                 const EdgeInsets.only(top: 8),
// // //                                                 child: Text(
// // //                                                     DateFormat.MMM(lang)
// // //                                                         .format(trendData[i].month),
// // //                                                     style: const TextStyle(
// // //                                                         fontSize: 9)));
// // //                                           return const Text('');
// // //                                         })),
// // //                               ),
// // //                               barGroups: barGroups,
// // //                             ))),
// // //                         const SizedBox(height: 12),
// // //                         Row(children: [
// // //                           _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // //                           const SizedBox(width: 12),
// // //                           _buildLegend(
// // //                               Colors.redAccent, "COMMON_EXPENSE".tr(ref))
// // //                         ])
// // //                       ])),
// // //               const SizedBox(width: 12),
// // //               Expanded(
// // //                   flex: 2,
// // //                   child: categoryStats.when(
// // //                       loading: () => const SizedBox.shrink(),
// // //                       error: (_, __) => const SizedBox.shrink(),
// // //                       data: (sData) {
// // //                         final colors = [
// // //                           Colors.indigo,
// // //                           Colors.teal,
// // //                           Colors.orange,
// // //                           Colors.brown,
// // //                           Colors.purple
// // //                         ];
// // //                         final List<PieChartSectionData> pieSections =
// // //                         (sData as List)
// // //                             .asMap()
// // //                             .entries
// // //                             .map<PieChartSectionData>((entry) {
// // //                           return PieChartSectionData(
// // //                               value: entry.value.amount.toDouble(),
// // //                               color: colors[entry.key % colors.length],
// // //                               radius: 40,
// // //                               title: '');
// // //                         }).toList();
// // //                         return Column(children: [
// // //                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
// // //                               style: const TextStyle(
// // //                                   fontSize: 12, fontWeight: FontWeight.bold)),
// // //                           const SizedBox(height: 10),
// // //                           Expanded(
// // //                               flex: 3,
// // //                               child: PieChart(PieChartData(
// // //                                   sectionsSpace: 2,
// // //                                   centerSpaceRadius: 10,
// // //                                   sections: pieSections))),
// // //                           const SizedBox(height: 12),
// // //                           Expanded(
// // //                               flex: 3,
// // //                               child: SingleChildScrollView(
// // //                                   child: Column(
// // //                                       crossAxisAlignment:
// // //                                       CrossAxisAlignment.start,
// // //                                       children:
// // //                                       sData.asMap().entries.map((entry) {
// // //                                         final String name = entry.value.category
// // //                                             .toString()
// // //                                             .startsWith('CAT_')
// // //                                             ? entry.value.category
// // //                                             .toString()
// // //                                             .tr(ref)
// // //                                             : entry.value.category.toString();
// // //                                         return Padding(
// // //                                             padding: const EdgeInsets.symmetric(
// // //                                                 vertical: 3),
// // //                                             child: _buildLegend(
// // //                                                 colors[
// // //                                                 entry.key % colors.length],
// // //                                                 "$name (${fmt.format(entry.value.amount)})",
// // //                                                 fontSize: 9));
// // //                                       }).toList()))),
// // //                         ]);
// // //                       }))
// // //             ]);
// // //           }),
// // //     );
// // //   }
// // //
// // //   // ✅ [복구] 종합 진단 결과 카드 (범례 및 상세 타일 100% 복원)
// // //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt,
// // //       _RiskSummary risk, List<FinancialInsight> insights) {
// // //     const Color mainIndigo = Color(0xFF1A237E);
// // //     final Color overdueColor = const Color(0xFFEF5350);
// // //     final Color deficitColor = const Color(0xFFFFA726);
// // //     final Color spikeColor = const Color(0xFF8D6E63);
// // //     final Color safeColor = Colors.grey[200]!;
// // //
// // //     final bool hasOverdue = risk.overdueCount > 0;
// // //     final bool hasDeficit = risk.balance < 0;
// // //     final bool hasSpike = insights.any((i) =>
// // //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// // //
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(
// // //           color: Colors.white,
// // //           borderRadius: BorderRadius.circular(16),
// // //           border: Border.all(color: Colors.grey.shade300!),
// // //           boxShadow: [
// // //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // //           ]),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // //             Row(children: [
// // //               Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// // //               const SizedBox(width: 10),
// // //               Text('REPORT_RISK_TITLE'.tr(ref),
// // //                   style: const TextStyle(
// // //                       fontSize: 16,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: mainIndigo))
// // //             ]),
// // //             Text("${risk.score}/100",
// // //                 style: const TextStyle(
// // //                     color: mainIndigo,
// // //                     fontWeight: FontWeight.w900,
// // //                     fontSize: 18)),
// // //           ]),
// // //           const SizedBox(height: 16),
// // //           ClipRRect(
// // //               borderRadius: BorderRadius.circular(8),
// // //               child: SizedBox(
// // //                   height: 14,
// // //                   child: Row(children: [
// // //                     if (hasOverdue)
// // //                       Expanded(flex: 20, child: Container(color: overdueColor)),
// // //                     if (hasDeficit)
// // //                       Expanded(flex: 35, child: Container(color: deficitColor)),
// // //                     if (hasSpike)
// // //                       Expanded(flex: 25, child: Container(color: spikeColor)),
// // //                     Expanded(
// // //                         flex: (100 -
// // //                             (hasOverdue ? 20 : 0) -
// // //                             (hasDeficit ? 35 : 0) -
// // //                             (hasSpike ? 25 : 0))
// // //                             .toInt()
// // //                             .clamp(5, 100),
// // //                         child: Container(color: safeColor)),
// // //                   ]))),
// // //           const SizedBox(height: 12),
// // //           // 🏷️ 원본 인덱스 범례 복구
// // //           Center(
// // //               child: Wrap(
// // //                   spacing: 12,
// // //                   runSpacing: 8,
// // //                   alignment: WrapAlignment.center,
// // //                   children: [
// // //                     _buildRiskLegend(
// // //                         overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// // //                     _buildRiskLegend(
// // //                         deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// // //                     _buildRiskLegend(
// // //                         spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// // //                     _buildRiskLegend(
// // //                         Colors.grey[400]!,
// // //                         "INSIGHT_LABEL_SAFE".tr(ref),
// // //                         !hasOverdue && !hasDeficit && !hasSpike),
// // //                   ])),
// // //           const SizedBox(height: 20),
// // //           // 🏷️ 원본 상세 타일(잔액, 미납건수) 복구
// // //           Row(children: [
// // //             _infoTile(ref, "COMMON_BALANCE".tr(ref),
// // //                 currencyFmt.format(risk.balance)),
// // //             const SizedBox(width: 10),
// // //             _infoTile(
// // //                 ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// // //           ]),
// // //           const SizedBox(height: 12),
// // //           const Divider(),
// // //           ...insights.map((insight) {
// // //             String message = insight.messageKey.tr(ref);
// // //             insight.arguments?.forEach(
// // //                     (key, value) => message = message.replaceAll('{$key}', value));
// // //             return Padding(
// // //                 padding: const EdgeInsets.only(top: 8),
// // //                 child: Row(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       const Icon(Icons.check_circle_outline,
// // //                           color: mainIndigo, size: 16),
// // //                       const SizedBox(width: 6),
// // //                       Expanded(
// // //                           child: Text(message,
// // //                               style: const TextStyle(
// // //                                   fontSize: 13,
// // //                                   color: Colors.black87,
// // //                                   fontWeight: FontWeight.w500)))
// // //                     ]));
// // //           }).toList(),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // 나머지 원본 헬퍼 메서드들 (isBold 파라미터 보정 완료)
// // //   Widget _buildSummaryRow(
// // //       NumberFormat fmt, String label, int amount, Color color,
// // //       {required bool isBold}) =>
// // //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// // //         Text(label,
// // //             style: TextStyle(
// // //                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
// // //         Text(fmt.format(amount),
// // //             style: TextStyle(fontWeight: FontWeight.bold, color: color))
// // //       ]);
// // //
// // //   Widget _buildRiskLegend(Color color, String label, bool isActive) =>
// // //       Row(mainAxisSize: MainAxisSize.min, children: [
// // //         Opacity(
// // //             opacity: isActive ? 1.0 : 0.2,
// // //             child: Container(
// // //                 width: 10,
// // //                 height: 10,
// // //                 decoration: BoxDecoration(
// // //                     color: color, borderRadius: BorderRadius.circular(2)))),
// // //         const SizedBox(width: 6),
// // //         Text(label,
// // //             style: TextStyle(
// // //                 fontSize: 11,
// // //                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// // //                 color: isActive ? Colors.black : Colors.grey[500]))
// // //       ]);
// // //
// // //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(
// // //       child: Container(
// // //           padding: const EdgeInsets.all(10),
// // //           decoration: BoxDecoration(
// // //               color: Colors.grey[50],
// // //               borderRadius: BorderRadius.circular(8),
// // //               border: Border.all(color: Colors.grey.shade200)),
// // //           child:
// // //           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //             Text(label,
// // //                 style: TextStyle(fontSize: 10, color: Colors.grey[600])),
// // //             Text(value,
// // //                 style: const TextStyle(
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Color(0xFF1A237E)))
// // //           ])));
// // //
// // //   Widget _buildSectionTitle(IconData i, String t) => Row(children: [
// // //     Icon(i, color: const Color(0xFF1A237E)),
// // //     const SizedBox(width: 8),
// // //     Text(t,
// // //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
// // //   ]);
// // //
// // //   Widget _buildLegend(Color c, String l, {double fontSize = 10}) =>
// // //       Row(mainAxisSize: MainAxisSize.min, children: [
// // //         Container(
// // //             width: 8,
// // //             height: 8,
// // //             decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
// // //         const SizedBox(width: 6),
// // //         Flexible(
// // //             child: Text(l,
// // //                 style:
// // //                 TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
// // //                 overflow: TextOverflow.ellipsis))
// // //       ]);
// // //
// // //   Widget _buildTaxSection(BuildContext c, WidgetRef r, bool isPro) => Container(
// // //       padding: const EdgeInsets.all(16),
// // //       decoration: BoxDecoration(
// // //           color: Colors.white,
// // //           borderRadius: BorderRadius.circular(12),
// // //           boxShadow: [
// // //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // //           ]),
// // //       child: Column(children: [
// // //         Container(
// // //             padding: const EdgeInsets.all(12),
// // //             decoration: BoxDecoration(
// // //                 border: Border.all(color: Colors.grey.shade300),
// // //                 borderRadius: BorderRadius.circular(8)),
// // //             child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Expanded(
// // //                       child: Text(
// // //                           "${'REPORT_TAX_PERIOD'.tr(r)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(r)}",
// // //                           style: const TextStyle(fontSize: 13))),
// // //                   const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
// // //                 ])),
// // //         const SizedBox(height: 20),
// // //         SizedBox(
// // //             width: double.infinity,
// // //             child: ElevatedButton.icon(
// // //                 style: ElevatedButton.styleFrom(
// // //                     backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
// // //                     foregroundColor: isPro ? Colors.white : Colors.grey[600],
// // //                     padding: const EdgeInsets.symmetric(vertical: 16),
// // //                     shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8))),
// // //                 onPressed: isPro ? () async {
// // //                   final raw = r.read(ledgerListProvider).value ?? [];
// // //                   final transactions = raw.map((e) => e.transaction).toList();
// // //                   await ExcelExportService()
// // //                       .exportTransactionsToExcel(transactions, r);
// // //                 } : null, // 📍 null을 통해 버튼 물리적 비활성화
// // //                 icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
// // //                 label: Text("REPORT_BTN_TAX_EXCEL".tr(r),
// // //                     style: const TextStyle(fontWeight: FontWeight.bold))))
// // //       ]));
// // //
// // //   // ✅ [수정] 미납 관리 섹션 (무료 사용자 시 정보 숨김 로직 추가)
// // //   Widget _buildUnpaidSection(BuildContext c, WidgetRef r,
// // //       AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// // //       Container(
// // //           padding: const EdgeInsets.all(16),
// // //           decoration: BoxDecoration(
// // //               color: Colors.white,
// // //               borderRadius: BorderRadius.circular(12),
// // //               boxShadow: [
// // //                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // //               ]),
// // //           child: Column(children: [
// // //             unpaidAsync.when(
// // //                 loading: () => const Center(child: CircularProgressIndicator()),
// // //                 error: (_, __) => const SizedBox(),
// // //                 data: (list) {
// // //                   final overdue =
// // //                   list.where((u) => u.status == 'OVERDUE').toList();
// // //                   final total = overdue.fold(
// // //                       0, (sum, item) => sum + item.unit.monthlyRent);
// // //                   if (overdue.isEmpty)
// // //                     return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r),
// // //                         textAlign: TextAlign.center);
// // //
// // //                   // 📍 [로직 추가] Pro 사용자에게만 미납 상세 정보를 보여줌 (다국어 키 적용)
// // //                   if (!isPro) {
// // //                     return Container(
// // //                       width: double.infinity,
// // //                       padding: const EdgeInsets.all(16),
// // //                       decoration: BoxDecoration(
// // //                           color: Colors.grey[50],
// // //                           borderRadius: BorderRadius.circular(8)),
// // //                       child: Center(
// // //                         child: Text(
// // //                           "REPORT_LOCK_UNPAID".tr(r),
// // //                           style: TextStyle(color: Colors.grey[600], fontSize: 13),
// // //                         ),
// // //                       ),
// // //                     );
// // //                   }
// // //
// // //                   return Container(
// // //                       width: double.infinity,
// // //                       padding: const EdgeInsets.all(12),
// // //                       decoration: BoxDecoration(
// // //                           color: Colors.grey[50],
// // //                           borderRadius: BorderRadius.circular(8)),
// // //                       child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                                 "${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}",
// // //                                 style: const TextStyle(
// // //                                     color: Colors.red,
// // //                                     fontWeight: FontWeight.bold)),
// // //                             const SizedBox(height: 8),
// // //                             ...overdue.take(3).map((u) => Text(
// // //                                 "• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}",
// // //                                 style: const TextStyle(fontSize: 12)))
// // //                           ]));
// // //                 }),
// // //             const SizedBox(height: 20),
// // //             Row(children: [
// // //               Expanded(
// // //                   child: ElevatedButton.icon(
// // //                       style: ElevatedButton.styleFrom(
// // //                           backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
// // //                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
// // //                           padding: const EdgeInsets.symmetric(vertical: 14),
// // //                           shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(8))),
// // //                       onPressed: isPro ? () async {
// // //                         await ExcelExportService().exportUnpaidListToExcel(
// // //                             unpaidAsync.value ?? [], r);
// // //                       } : null,
// // //                       icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
// // //                       label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r),
// // //                           style: const TextStyle(
// // //                               fontSize: 12, fontWeight: FontWeight.bold)))),
// // //               const SizedBox(width: 10),
// // //               Expanded(
// // //                   child: ElevatedButton.icon(
// // //                       style: ElevatedButton.styleFrom(
// // //                           backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300], // 📍 비활성화 색상 적용
// // //                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
// // //                           padding: const EdgeInsets.symmetric(vertical: 14),
// // //                           shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(8))),
// // //                       onPressed: isPro ? () async {
// // //                         await _captureAndShare(_unpaidCaptureKey, r);
// // //                       } : null,
// // //                       icon: Icon(isPro ? Icons.share_outlined : Icons.lock_outline, size: 18),
// // //                       label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r),
// // //                           style: const TextStyle(
// // //                               fontSize: 12, fontWeight: FontWeight.bold))))
// // //             ])
// // //           ]));
// // //
// // //   Widget _buildAnnualSummary(
// // //       BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
// // //     // 📍 p (isPro) 여부에 따라 전체 콘텐츠 노출 여부 결정 (다국어 적용)
// // //     if (!p)
// // //       return _buildSimpleLockCard(r, "REPORT_LOCK_ANNUAL".tr(r));
// // //
// // //     return Container(
// // //         padding: const EdgeInsets.all(16),
// // //         decoration: BoxDecoration(
// // //             color: Colors.white,
// // //             borderRadius: BorderRadius.circular(12),
// // //             boxShadow: [
// // //               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// // //             ]),
// // //         child: t.when(
// // //             loading: () => const SizedBox(),
// // //             error: (_, __) => const SizedBox(),
// // //             data: (trend) {
// // //               final y = DateTime.now().year;
// // //               final cur = trend.where((e) => e.month.year == y).toList();
// // //               int inc = cur.fold(0, (s, e) => s + e.income);
// // //               int exp = cur.fold(0, (s, e) => s + e.expense);
// // //               return Column(children: [
// // //                 Row(mainAxisAlignment: MainAxisAlignment.end, children: [
// // //                   Text("${'COMMON_YEAR'.tr(r)}: $y",
// // //                       style: const TextStyle(
// // //                           fontSize: 12, fontWeight: FontWeight.bold))
// // //                 ]),
// // //                 const SizedBox(height: 10),
// // //                 _buildSummaryRow(
// // //                     f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue,
// // //                     isBold: false),
// // //                 const Divider(height: 20),
// // //                 _buildSummaryRow(
// // //                     f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent,
// // //                     isBold: false),
// // //                 const Divider(height: 20),
// // //                 _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp,
// // //                     Colors.indigo,
// // //                     isBold: true)
// // //               ]);
// // //             }));
// // //   }
// // //
// // //   // 📍 [원본 유지] Pro 전용 잠금 카드 스타일 (네이비 브랜드 컬러 적용)
// // //   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) =>
// // //       Container(
// // //           padding: const EdgeInsets.all(16),
// // //           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
// // //           child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]),
// // //                 const SizedBox(height: 8),
// // //                 Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
// // //                 const SizedBox(height: 12),
// // //                 Align(
// // //                   alignment: Alignment.centerRight,
// // //                   child: ElevatedButton(
// // //                     onPressed: onTap,
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFF1A237E), // SiRE 메인 네이비 색상
// // //                       foregroundColor: Colors.white,            // 글자색 흰색
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //                     ),
// // //                     child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r)),
// // //                   ),
// // //                 )
// // //               ]
// // //           )
// // //       );
// // //
// // //   void _openPaywall(BuildContext c) => Navigator.of(c)
// // //       .push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// // //
// // //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// // //     try {
// // //       await WidgetsBinding.instance.endOfFrame;
// // //       await Future.delayed(const Duration(milliseconds: 200));
// // //       final RenderRepaintBoundary? boundary =
// // //       key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// // //       if (boundary == null || boundary.debugNeedsPaint) {
// // //         await Future.delayed(const Duration(milliseconds: 300));
// // //       }
// // //       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
// // //       final ByteData? byteData =
// // //       await image.toByteData(format: ui.ImageByteFormat.png);
// // //       final Uint8List pngBytes = byteData!.buffer.asUint8List();
// // //       final directory = await getTemporaryDirectory();
// // //       final path =
// // //           '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// // //       await File(path).writeAsBytes(pngBytes);
// // //       await Share.shareXFiles([XFile(path)],
// // //           text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
// // //     } catch (e) {
// // //       debugPrint("Capture Error: $e");
// // //     }
// // //   }
// // //
// // //   _RiskSummary _computeRiskSummary(
// // //       {required int thisMonthIncome,
// // //         required int thisMonthExpense,
// // //         required int lastMonthExpense,
// // //         required int overdueCount,
// // //         required int totalOverdueAmount,
// // //         required List<FinancialInsight> insights}) {
// // //     int s = 0;
// // //     if (overdueCount > 0) s += 20;
// // //     if (thisMonthIncome < thisMonthExpense) s += 40;
// // //     if (insights.any((i) =>
// // //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')))
// // //       s += 25;
// // //     int fs = s.clamp(0, 100);
// // //     return _RiskSummary(
// // //         score: fs,
// // //         level: fs >= 75
// // //             ? _RiskLevel.high
// // //             : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low),
// // //         balance: thisMonthIncome - thisMonthExpense,
// // //         overdueCount: overdueCount,
// // //         reasons: []);
// // //   }
// // // }
// // //
// // // enum _RiskLevel { low, mid, high }
// // //
// // // class _RiskSummary {
// // //   final int score;
// // //   final _RiskLevel level;
// // //   final List<String> reasons;
// // //   final int balance;
// // //   final int overdueCount;
// // //
// // //   _RiskSummary(
// // //       {required this.score,
// // //         required this.level,
// // //         required this.reasons,
// // //         required this.balance,
// // //         required this.overdueCount});
// // // }
// //
// //
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
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/main_screen');
//         }
//       }
//     });
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt =
//     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         title: Text("NAV_REPORTS".tr(ref),
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
//                 if (!isPro) _buildMainProAnchor(context, ref),
//
//                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
//                 monthlyTrendAsync.when(
//                     loading: () => const SizedBox.shrink(),
//                     error: (_, __) => const SizedBox.shrink(),
//                     data: (trendData) => unpaidAsync.when(
//                         loading: () => const SizedBox.shrink(),
//                         error: (_, __) => const SizedBox.shrink(),
//                         data: (unpaidList) {
//                           int inC = 0, exC = 0, lastEx = 0;
//                           final now = DateTime.now();
//                           final thisMonth = trendData
//                               .where((e) =>
//                           e.month.year == now.year &&
//                               e.month.month == now.month)
//                               .toList();
//                           if (thisMonth.isNotEmpty) {
//                             inC = thisMonth.first.income;
//                             exC = thisMonth.first.expense;
//                           }
//                           final last = DateTime(now.year, now.month - 1, 1);
//                           final lastMonth = trendData
//                               .where((e) =>
//                           e.month.year == last.year &&
//                               e.month.month == last.month)
//                               .toList();
//                           if (lastMonth.isNotEmpty)
//                             lastEx = lastMonth.first.expense;
//
//                           final overdue = unpaidList
//                               .where((u) => u.status == 'OVERDUE')
//                               .toList();
//                           final totalO = overdue.fold(
//                               0, (sum, item) => sum + item.unit.monthlyRent);
//
//                           final insights = FinancialInsightService.generate(
//                               thisMonthIncome: inC,
//                               thisMonthExpense: exC,
//                               lastMonthExpense: lastEx,
//                               overdueCount: overdue.length,
//                               totalOverdueAmount: totalO);
//                           final risk = _computeRiskSummary(
//                               thisMonthIncome: inC,
//                               thisMonthExpense: exC,
//                               lastMonthExpense: lastEx,
//                               overdueCount: overdue.length,
//                               totalOverdueAmount: totalO,
//                               insights: insights);
//
//                           return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildSectionTitle(Icons.lightbulb_outline,
//                                     "REPORT_SEC_INSIGHTS".tr(ref)),
//                                 const SizedBox(height: 10),
//                                 if (!isPro)
//                                 // 📍 [수정] 안내 문구 노출 (다국어 키 적용)
//                                   _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
//                                 else
//                                   _buildRiskSummaryCard(
//                                       ref, currencyFmt, risk, insights),
//                                 const SizedBox(height: 20),
//                               ]);
//                         })),
//
//                 // ✅ [복구] 재무 분석 (그래프 수치 표시 복구)
//                 _buildSectionTitle(
//                     Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
//                 _buildFinancialAnalytics(ref, monthlyTrendAsync,
//                     categoryStatsAsync, currencyFmt, lang, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(
//                     Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined,
//                     "REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 // 📍 [에러 수정] ref 파라미터를 명시적으로 전달하여 image_1aba06 에러 해결
//                 _buildUnpaidSection(
//                     context, ref, unpaidAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 30),
//                 // ✅ [복구] 연간 요약 타이틀 복구
//                 _buildSectionTitle(Icons.table_chart_outlined,
//                     "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildAnnualSummary(
//                     context, ref, monthlyTrendAsync, currencyFmt, isPro),
//               ],
//             ),
//           ),
//
//           // 📍 캡처 전용 위젯 (공백 문제 해결을 위해 화면 밖 배치)
//           Transform.translate(
//             offset: const Offset(-5000, -5000),
//             child: RepaintBoundary(
//               key: _unpaidCaptureKey,
//               child: Container(
//                 width: 450,
//                 padding: const EdgeInsets.all(30),
//                 color: Colors.white,
//                 child: unpaidAsync.when(
//                   data: (list) {
//                     final overdue =
//                     list.where((u) => u.status == 'OVERDUE').toList();
//                     final total = overdue.fold(
//                         0, (sum, item) => sum + item.unit.monthlyRent);
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
//                             style: const TextStyle(
//                                 color: Color(0xFF1A237E),
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold)),
//                         const Divider(color: Color(0xFF1A237E), thickness: 3),
//                         const SizedBox(height: 20),
//                         Text(
//                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
//                             style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w900)),
//                         const SizedBox(height: 30),
//                         ...overdue
//                             .map((u) => Container(
//                           margin: const EdgeInsets.only(bottom: 15),
//                           padding: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               border:
//                               Border.all(color: Colors.grey[300]!),
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Column(children: [
//                             Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                       "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18)),
//                                   Text(
//                                       currencyFmt
//                                           .format(u.unit.monthlyRent),
//                                       style: const TextStyle(
//                                           color: Color(0xFF1A237E),
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18)),
//                                 ]),
//                             const SizedBox(height: 10),
//                             Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(u.unit.tenantPhone ?? '-',
//                                       style: const TextStyle(
//                                           color: Colors.black54,
//                                           fontSize: 14)),
//                                   Text(
//                                       "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
//                                       style: const TextStyle(
//                                           color: Colors.redAccent,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold)),
//                                 ]),
//                           ]),
//                         ))
//                             .toList(),
//                         const SizedBox(height: 30),
//                         const Center(
//                             child: Text("Generated by SiRE Asset Management",
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 12,
//                                     letterSpacing: 1.5))),
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
//   // ✅ [신규/수정] 상단 메인 Pro 안내 카드 (체험 버튼 추가)
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     final trialCount = ref.watch(trialCountProvider);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref),
//                   style: const TextStyle(
//                       color: Color(0xFF1A237E),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => _openPaywall(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A237E),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: trialCount > 0
//                   ? () => ref.read(purchaseControllerProvider.notifier).startTrial()
//                   : null,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
//                 foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text(
//                 trialCount > 0
//                     ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})"
//                     : "PROP_TRIAL_EXPIRED".tr(ref),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 📍 [신규] 일관성 있는 단순 안내 텍스트 카드
//   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
//       ),
//     );
//   }
//
//   // ✅ [복구/수정] 재무 분석 카드
//   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend,
//       AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//     if (!isPro) {
//       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
//     }
//
//     return Container(
//       height: 320,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//           ]),
//       child: monthlyTrend.when(
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (_, __) => const SizedBox.shrink(),
//           data: (trendData) {
//             final List<BarChartGroupData> barGroups =
//             (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
//               final List<int> indicators = [];
//               if (e.value.income > 0) indicators.add(0);
//               if (e.value.expense > 0) indicators.add(1);
//               return BarChartGroupData(
//                   x: e.key,
//                   barsSpace: 4,
//                   showingTooltipIndicators: indicators,
//                   barRods: [
//                     BarChartRodData(
//                         toY: e.value.income.toDouble(),
//                         color: Colors.blue,
//                         width: 8,
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(2))),
//                     BarChartRodData(
//                         toY: e.value.expense.toDouble(),
//                         color: Colors.redAccent,
//                         width: 8,
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(2))),
//                   ]);
//             }).toList();
//             return Row(children: [
//               Expanded(
//                   flex: 3,
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
//                             style: const TextStyle(
//                                 fontSize: 12, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 25),
//                         Expanded(
//                             child: BarChart(BarChartData(
//                               barTouchData: BarTouchData(
//                                   enabled: false,
//                                   touchTooltipData: BarTouchTooltipData(
//                                     tooltipBgColor: Colors.transparent,
//                                     tooltipPadding: EdgeInsets.zero,
//                                     tooltipMargin: 4,
//                                     getTooltipItem:
//                                         (group, groupIndex, rod, rodIndex) =>
//                                     rod.toY == 0
//                                         ? null
//                                         : BarTooltipItem(
//                                         fmt.format(rod.toY),
//                                         TextStyle(
//                                             color: rod.color,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 9)),
//                                   )),
//                               gridData: const FlGridData(show: false),
//                               borderData: FlBorderData(show: false),
//                               titlesData: FlTitlesData(
//                                 topTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 rightTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 leftTitles: const AxisTitles(
//                                     sideTitles: SideTitles(showTitles: false)),
//                                 bottomTitles: AxisTitles(
//                                     sideTitles: SideTitles(
//                                         showTitles: true,
//                                         getTitlesWidget: (v, m) {
//                                           int i = v.toInt();
//                                           if (i >= 0 && i < trendData.length)
//                                             return Padding(
//                                                 padding:
//                                                 const EdgeInsets.only(top: 8),
//                                                 child: Text(
//                                                     DateFormat.MMM(lang)
//                                                         .format(trendData[i].month),
//                                                     style: const TextStyle(
//                                                         fontSize: 9)));
//                                           return const Text('');
//                                         })),
//                               ),
//                               barGroups: barGroups,
//                             ))),
//                         const SizedBox(height: 12),
//                         Row(children: [
//                           _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
//                           const SizedBox(width: 12),
//                           _buildLegend(
//                               Colors.redAccent, "COMMON_EXPENSE".tr(ref))
//                         ])
//                       ])),
//               const SizedBox(width: 12),
//               Expanded(
//                   flex: 2,
//                   child: categoryStats.when(
//                       loading: () => const SizedBox.shrink(),
//                       error: (_, __) => const SizedBox.shrink(),
//                       data: (sData) {
//                         final colors = [
//                           Colors.indigo,
//                           Colors.teal,
//                           Colors.orange,
//                           Colors.brown,
//                           Colors.purple
//                         ];
//                         final List<PieChartSectionData> pieSections =
//                         (sData as List)
//                             .asMap()
//                             .entries
//                             .map<PieChartSectionData>((entry) {
//                           return PieChartSectionData(
//                               value: entry.value.amount.toDouble(),
//                               color: colors[entry.key % colors.length],
//                               radius: 40,
//                               title: '');
//                         }).toList();
//                         return Column(children: [
//                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
//                               style: const TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 10),
//                           Expanded(
//                               flex: 3,
//                               child: PieChart(PieChartData(
//                                   sectionsSpace: 2,
//                                   centerSpaceRadius: 10,
//                                   sections: pieSections))),
//                           const SizedBox(height: 12),
//                           Expanded(
//                               flex: 3,
//                               child: SingleChildScrollView(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children:
//                                       sData.asMap().entries.map((entry) {
//                                         final String name = entry.value.category
//                                             .toString()
//                                             .startsWith('CAT_')
//                                             ? entry.value.category
//                                             .toString()
//                                             .tr(ref)
//                                             : entry.value.category.toString();
//                                         return Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 3),
//                                             child: _buildLegend(
//                                                 colors[
//                                                 entry.key % colors.length],
//                                                 "$name (${fmt.format(entry.value.amount)})",
//                                                 fontSize: 9));
//                                       }).toList()))),
//                         ]);
//                       }))
//             ]);
//           }),
//     );
//   }
//
//   // ✅ [복구] 종합 진단 결과 카드
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt,
//       _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     final Color overdueColor = const Color(0xFFEF5350);
//     final Color deficitColor = const Color(0xFFFFA726);
//     final Color spikeColor = const Color(0xFF8D6E63);
//     final Color safeColor = Colors.grey[200]!;
//
//     final bool hasOverdue = risk.overdueCount > 0;
//     final bool hasDeficit = risk.balance < 0;
//     final bool hasSpike = insights.any((i) =>
//     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade300!),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//           ]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Row(children: [
//               Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
//               const SizedBox(width: 10),
//               Text('REPORT_RISK_TITLE'.tr(ref),
//                   style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: mainIndigo))
//             ]),
//             Text("${risk.score}/100",
//                 style: const TextStyle(
//                     color: mainIndigo,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 18)),
//           ]),
//           const SizedBox(height: 16),
//           ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: SizedBox(
//                   height: 14,
//                   child: Row(children: [
//                     if (hasOverdue)
//                       Expanded(flex: 20, child: Container(color: overdueColor)),
//                     if (hasDeficit)
//                       Expanded(flex: 35, child: Container(color: deficitColor)),
//                     if (hasSpike)
//                       Expanded(flex: 25, child: Container(color: spikeColor)),
//                     Expanded(
//                         flex: (100 -
//                             (hasOverdue ? 20 : 0) -
//                             (hasDeficit ? 35 : 0) -
//                             (hasSpike ? 25 : 0))
//                             .toInt()
//                             .clamp(5, 100),
//                         child: Container(color: safeColor)),
//                   ]))),
//           const SizedBox(height: 12),
//           Center(
//               child: Wrap(
//                   spacing: 12,
//                   runSpacing: 8,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     _buildRiskLegend(
//                         overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
//                     _buildRiskLegend(
//                         deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
//                     _buildRiskLegend(
//                         spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
//                     _buildRiskLegend(
//                         Colors.grey[400]!,
//                         "INSIGHT_LABEL_SAFE".tr(ref),
//                         !hasOverdue && !hasDeficit && !hasSpike),
//                   ])),
//           const SizedBox(height: 20),
//           Row(children: [
//             _infoTile(ref, "COMMON_BALANCE".tr(ref),
//                 currencyFmt.format(risk.balance)),
//             const SizedBox(width: 10),
//             _infoTile(
//                 ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
//           ]),
//           const SizedBox(height: 12),
//           const Divider(),
//           ...insights.map((insight) {
//             String message = insight.messageKey.tr(ref);
//             insight.arguments?.forEach(
//                     (key, value) => message = message.replaceAll('{$key}', value));
//             return Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(Icons.check_circle_outline,
//                           color: mainIndigo, size: 16),
//                       const SizedBox(width: 6),
//                       Expanded(
//                           child: Text(message,
//                               style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.w500)))
//                     ]));
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   // 나머지 헬퍼 메서드들
//   Widget _buildSummaryRow(
//       NumberFormat fmt, String label, int amount, Color color,
//       {required bool isBold}) =>
//       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//         Text(label,
//             style: TextStyle(
//                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//         Text(fmt.format(amount),
//             style: TextStyle(fontWeight: FontWeight.bold, color: color))
//       ]);
//
//   Widget _buildRiskLegend(Color color, String label, bool isActive) =>
//       Row(mainAxisSize: MainAxisSize.min, children: [
//         Opacity(
//             opacity: isActive ? 1.0 : 0.2,
//             child: Container(
//                 width: 10,
//                 height: 10,
//                 decoration: BoxDecoration(
//                     color: color, borderRadius: BorderRadius.circular(2)))),
//         const SizedBox(width: 6),
//         Text(label,
//             style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                 color: isActive ? Colors.black : Colors.grey[500]))
//       ]);
//
//   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(
//       child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200)),
//           child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(label,
//                 style: TextStyle(fontSize: 10, color: Colors.grey[600])),
//             Text(value,
//                 style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A237E)))
//           ])));
//
//   Widget _buildSectionTitle(IconData i, String t) => Row(children: [
//     Icon(i, color: const Color(0xFF1A237E)),
//     const SizedBox(width: 8),
//     Text(t,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
//   ]);
//
//   Widget _buildLegend(Color c, String l, {double fontSize = 10}) =>
//       Row(mainAxisSize: MainAxisSize.min, children: [
//         Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
//         const SizedBox(width: 6),
//         Flexible(
//             child: Text(l,
//                 style:
//                 TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
//                 overflow: TextOverflow.ellipsis))
//       ]);
//
//   Widget _buildTaxSection(BuildContext c, WidgetRef r, bool isPro) => Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//           ]),
//       child: Column(children: [
//         Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                       child: Text(
//                           "${'REPORT_TAX_PERIOD'.tr(r)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(r)}",
//                           style: const TextStyle(fontSize: 13))),
//                   const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
//                 ])),
//         const SizedBox(height: 20),
//         SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300],
//                     foregroundColor: isPro ? Colors.white : Colors.grey[600],
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8))),
//                 onPressed: isPro ? () async {
//                   final raw = r.read(ledgerListProvider).value ?? [];
//                   final transactions = raw.map((e) => e.transaction).toList();
//                   await ExcelExportService()
//                       .exportTransactionsToExcel(transactions, r);
//                 } : null,
//                 icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
//                 label: Text("REPORT_BTN_TAX_EXCEL".tr(r),
//                     style: const TextStyle(fontWeight: FontWeight.bold))))
//       ]));
//
//   // 📍 [에러 해결] ref 파라미터 추가
//   Widget _buildUnpaidSection(BuildContext c, WidgetRef r,
//       AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
//       Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//               ]),
//           child: Column(children: [
//             unpaidAsync.when(
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (_, __) => const SizedBox(),
//                 data: (list) {
//                   final overdue =
//                   list.where((u) => u.status == 'OVERDUE').toList();
//                   final total = overdue.fold(
//                       0, (sum, item) => sum + item.unit.monthlyRent);
//                   if (overdue.isEmpty)
//                     return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r),
//                         textAlign: TextAlign.center);
//
//                   if (!isPro) {
//                     return Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                           color: Colors.grey[50],
//                           borderRadius: BorderRadius.circular(8)),
//                       child: Center(
//                         child: Text(
//                           "REPORT_LOCK_UNPAID".tr(r),
//                           style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                         ),
//                       ),
//                     );
//                   }
//
//                   return Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                           color: Colors.grey[50],
//                           borderRadius: BorderRadius.circular(8)),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                                 "${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}",
//                                 style: const TextStyle(
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             ...overdue.take(3).map((u) => Text(
//                                 "• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}",
//                                 style: const TextStyle(fontSize: 12)))
//                           ]));
//                 }),
//             const SizedBox(height: 20),
//             Row(children: [
//               Expanded(
//                   child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300],
//                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8))),
//                       onPressed: isPro ? () async {
//                         await ExcelExportService().exportUnpaidListToExcel(
//                             unpaidAsync.value ?? [], r);
//                       } : null,
//                       icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
//                       label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r),
//                           style: const TextStyle(
//                               fontSize: 12, fontWeight: FontWeight.bold)))),
//               const SizedBox(width: 10),
//               Expanded(
//                   child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300],
//                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8))),
//                       onPressed: isPro ? () async {
//                         await _captureAndShare(_unpaidCaptureKey, r);
//                       } : null,
//                       icon: Icon(isPro ? Icons.share_outlined : Icons.lock_outline, size: 18),
//                       label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r),
//                           style: const TextStyle(
//                               fontSize: 12, fontWeight: FontWeight.bold))))
//             ])
//           ]));
//
//   Widget _buildAnnualSummary(
//       BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
//     if (!p)
//       return _buildSimpleLockCard(r, "REPORT_LOCK_ANNUAL".tr(r));
//
//     return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//             ]),
//         child: t.when(
//             loading: () => const SizedBox(),
//             error: (_, __) => const SizedBox(),
//             data: (trend) {
//               final y = DateTime.now().year;
//               final cur = trend.where((e) => e.month.year == y).toList();
//               int inc = cur.fold(0, (s, e) => s + e.income);
//               int exp = cur.fold(0, (s, e) => s + e.expense);
//               return Column(children: [
//                 Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                   Text("${'COMMON_YEAR'.tr(r)}: $y",
//                       style: const TextStyle(
//                           fontSize: 12, fontWeight: FontWeight.bold))
//                 ]),
//                 const SizedBox(height: 10),
//                 _buildSummaryRow(
//                     f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue,
//                     isBold: false),
//                 const Divider(height: 20),
//                 _buildSummaryRow(
//                     f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent,
//                     isBold: false),
//                 const Divider(height: 20),
//                 _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp,
//                     Colors.indigo,
//                     isBold: true)
//               ]);
//             }));
//   }
//
//   void _openPaywall(BuildContext c) => Navigator.of(c)
//       .push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
//
//   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
//     try {
//       await WidgetsBinding.instance.endOfFrame;
//       await Future.delayed(const Duration(milliseconds: 200));
//       final RenderRepaintBoundary? boundary =
//       key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null || boundary.debugNeedsPaint) {
//         await Future.delayed(const Duration(milliseconds: 300));
//       }
//       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
//       final ByteData? byteData =
//       await image.toByteData(format: ui.ImageByteFormat.png);
//       final Uint8List pngBytes = byteData!.buffer.asUint8List();
//       final directory = await getTemporaryDirectory();
//       final path =
//           '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
//       await File(path).writeAsBytes(pngBytes);
//       await Share.shareXFiles([XFile(path)],
//           text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
//     } catch (e) {
//       debugPrint("Capture Error: $e");
//     }
//   }
//
//   _RiskSummary _computeRiskSummary(
//       {required int thisMonthIncome,
//         required int thisMonthExpense,
//         required int lastMonthExpense,
//         required int overdueCount,
//         required int totalOverdueAmount,
//         required List<FinancialInsight> insights}) {
//     int s = 0;
//     if (overdueCount > 0) s += 20;
//     if (thisMonthIncome < thisMonthExpense) s += 40;
//     if (insights.any((i) =>
//     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')))
//       s += 25;
//     int fs = s.clamp(0, 100);
//     return _RiskSummary(
//         score: fs,
//         level: fs >= 75
//             ? _RiskLevel.high
//             : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low),
//         balance: thisMonthIncome - thisMonthExpense,
//         overdueCount: overdueCount,
//         reasons: []);
//   }
// }
//
// enum _RiskLevel { low, mid, high }
//
// class _RiskSummary {
//   final int score;
//   final _RiskLevel level;
//   final List<String> reasons;
//   final int balance;
//   final int overdueCount;
//
//   _RiskSummary(
//       {required this.score,
//         required this.level,
//         required this.reasons,
//         required this.balance,
//         required this.overdueCount});
// }








// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:drift/drift.dart' hide Column; // 📍 핵심: drift의 Column을 숨겨서 UI용 Column과 충돌 방지
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/state/purchase_provider.dart';
// import '../../core/purchase/ui/paywall_screen.dart';
// import '../../core/database/database_provider.dart';
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
// import 'financial_insight_service.dart';
//
// // 📍 [수정] 스크롤 상태 감지 및 연도 변경을 위해 ConsumerStatefulWidget으로 전환
// class ReportsScreen extends ConsumerStatefulWidget {
//   const ReportsScreen({super.key});
//
//   @override
//   ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
// }
//
// class _ReportsScreenState extends ConsumerState<ReportsScreen> {
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   // 📍 스크롤 상태 관리를 위한 컨트롤러
//   late ScrollController _chartScrollController;
//   bool _canScrollLeft = true;
//   bool _canScrollRight = false;
//
//   // 📍 [신규] 현재 보고 있는 연도 상태 (기본값: 현재 연도)
//   int _selectedYear = DateTime.now().year;
//
//   @override
//   void initState() {
//     super.initState();
//     _chartScrollController = ScrollController();
//     _chartScrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _chartScrollController.removeListener(_scrollListener);
//     _chartScrollController.dispose();
//     super.dispose();
//   }
//
//   // 📍 스크롤 위치에 따라 화살표 가시성을 실시간 업데이트 (reverse: true 기준)
//   void _scrollListener() {
//     if (!_chartScrollController.hasClients) return;
//
//     final maxScroll = _chartScrollController.position.maxScrollExtent;
//     final currentScroll = _chartScrollController.offset;
//
//     setState(() {
//       _canScrollLeft = currentScroll < maxScroll;
//       _canScrollRight = currentScroll > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).popUntil((route) { return route.isFirst || route.settings.name == '/main_screen'; });
//         }
//       }
//     });
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     // 📍 [수정] 선택된 연도에 따라 카테고리 통계를 동적으로 가져옴
//     final categoryStatsAsync = ref.watch(annualCategoryStatisticsProvider(_selectedYear));
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt =
//     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // 📍 [수정] 앱바 타이틀 영역에 연도 선택기 위젯 배치
//         title: Row(
//           children: [
//             Text("NAV_REPORTS".tr(ref),
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const Spacer(),
//             _buildYearSelector(),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
//                 if (!isPro) _buildMainProAnchor(context, ref),
//
//                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
//                 monthlyTrendAsync.when(
//                     loading: () { return const SizedBox.shrink(); },
//                     error: (err, stack) { return const SizedBox.shrink(); },
//                     data: (trendData) {
//                       // 📍 [수정] 선택된 연도 데이터만 필터링
//                       final yearData = trendData.where((e) => e.month.year == _selectedYear).toList();
//
//                       return unpaidAsync.when(
//                           loading: () { return const SizedBox.shrink(); },
//                           error: (err, stack) { return const SizedBox.shrink(); },
//                           data: (unpaidList) {
//                             int inC = 0, exC = 0, lastEx = 0;
//                             final now = DateTime.now();
//
//                             // 선택된 연도가 현재 연도인 경우 이번 달 기준, 과거인 경우 12월 기준
//                             final bool isCurrentYear = _selectedYear == now.year;
//                             final int targetMonth = isCurrentYear ? now.month : 12;
//
//                             final thisMonth = yearData
//                                 .where((e) { return e.month.month == targetMonth; })
//                                 .toList();
//                             if (thisMonth.isNotEmpty) {
//                               inC = thisMonth.first.income;
//                               exC = thisMonth.first.expense;
//                             }
//                             final lastMonthData = yearData
//                                 .where((e) { return e.month.month == (targetMonth - 1); })
//                                 .toList();
//                             if (lastMonthData.isNotEmpty) {
//                               lastEx = lastMonthData.first.expense;
//                             }
//
//                             final overdue = unpaidList
//                                 .where((u) { return u.status == 'OVERDUE'; })
//                                 .toList();
//                             final totalO = overdue.fold(
//                                 0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//
//                             final insights = FinancialInsightService.generate(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO);
//                             final risk = _computeRiskSummary(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO,
//                                 insights: insights);
//
//                             return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _buildSectionTitle(Icons.lightbulb_outline,
//                                       "REPORT_SEC_INSIGHTS".tr(ref)),
//                                   const SizedBox(height: 10),
//                                   if (!isPro)
//                                   // 📍 [수정] 안내 문구 노출 (다국어 키 적용)
//                                     _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
//                                   else
//                                     _buildRiskSummaryCard(
//                                         ref, currencyFmt, risk, insights),
//                                   const SizedBox(height: 20),
//                                 ]);
//                           });
//                     }),
//
//                 // ✅ [복구] 재무 분석
//                 _buildSectionTitle(
//                     Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
//                 _buildFinancialAnalytics(context, ref, monthlyTrendAsync,
//                     categoryStatsAsync, currencyFmt, lang, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(
//                     Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined,
//                     "REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 // 📍 [에러 수정] ref 파라미터를 명시적으로 전달
//                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 30),
//                 // ✅ [복구] 연간 요약 타이틀 복구
//                 _buildSectionTitle(Icons.table_chart_outlined,
//                     "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 📍 연도 선택 컨트롤러 위젯 ---
//   Widget _buildYearSelector() {
//     final now = DateTime.now();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () => setState(() => _selectedYear--),
//             child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "$_selectedYear",
//               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           GestureDetector(
//             onTap: _selectedYear < now.year ? () => setState(() => _selectedYear++) : null,
//             child: Icon(
//                 Icons.chevron_right,
//                 color: _selectedYear < now.year ? Colors.white : Colors.white24,
//                 size: 24
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 헬퍼 메서드 영역 ---
//
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     final trialCount = ref.watch(trialCountProvider);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref),
//                   style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () { _openPaywall(context); },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A237E),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: trialCount > 0 ? () { ref.read(purchaseControllerProvider.notifier).startTrial(); } : null,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
//                 foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text(
//                 trialCount > 0 ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})" : "PROP_TRIAL_EXPIRED".tr(ref),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
//     );
//   }
//
//   Widget _buildFinancialAnalytics(BuildContext context, WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//     if (!isPro) {
//       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
//     }
//
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: monthlyTrend.when(
//           loading: () { return const Center(child: CircularProgressIndicator()); },
//           error: (err, stack) { return const SizedBox.shrink(); },
//           data: (trendData) {
//             // 📍 [수정] 전체 12개월 중 선택된 연도 데이터만 바인딩
//             final yearData = (trendData as List).where((e) => e.month.year == _selectedYear).toList();
//
//             if (yearData.isEmpty) {
//               return const Center(child: Text("해당 연도에 데이터가 없습니다."));
//             }
//
//             double maxY = yearData.map((e) => e.income > e.expense ? e.income.toDouble() : e.expense.toDouble()).reduce((a, b) => a > b ? a : b);
//             maxY = maxY > 0 ? maxY * 1.3 : 1000000;
//             double avgIn = yearData.fold(0, (sum, e) => (sum + e.income).toInt()) / yearData.length;
//
//             final double screenWidth = MediaQuery.of(context).size.width;
//             final double chartAvailableWidth = (screenWidth - 64) * 0.61;
//             final double barGroupWidth = chartAvailableWidth / 6;
//             final double totalScrollWidth = barGroupWidth * yearData.length;
//
//             final List<BarChartGroupData> barGroups = yearData.asMap().entries.map((e) {
//               final bool isSpike = e.value.expense > (avgIn * 0.4);
//               return BarChartGroupData(
//                   x: e.key,
//                   barsSpace: 2,
//                   barRods: [
//                     BarChartRodData(toY: e.value.income.toDouble(), color: const Color(0xFF42A5F5), width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                     BarChartRodData(toY: e.value.expense.toDouble(), color: isSpike ? Colors.redAccent.shade700 : Colors.redAccent.shade100, width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                   ]);
//             }).toList();
//
//             return Column(children: [
//               Expanded(
//                 child: Row(children: [
//                   Expanded(
//                     flex: 6,
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 25),
//                       Expanded(
//                         child: Stack(
//                           children: [
//                             SingleChildScrollView(
//                               controller: _chartScrollController,
//                               scrollDirection: Axis.horizontal,
//                               reverse: true,
//                               child: Container(
//                                 width: totalScrollWidth,
//                                 padding: const EdgeInsets.only(right: 15),
//                                 child: BarChart(BarChartData(
//                                   maxY: maxY,
//                                   barTouchData: BarTouchData(
//                                     enabled: true,
//                                     touchTooltipData: BarTouchTooltipData(
//                                       tooltipBgColor: const Color(0xFF1A237E),
//                                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                                         return BarTooltipItem("${rodIndex == 0 ? 'IN' : 'EX'}\n${fmt.format(rod.toY)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
//                                       },
//                                     ),
//                                   ),
//                                   extraLinesData: ExtraLinesData(horizontalLines: [
//                                     HorizontalLine(
//                                       y: avgIn,
//                                       color: Colors.orange.shade300,
//                                       strokeWidth: 1.5,
//                                       dashArray: [4, 4],
//                                     )
//                                   ]),
//                                   gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
//                                   borderData: FlBorderData(show: false),
//                                   titlesData: FlTitlesData(
//                                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
//                                       int i = v.toInt();
//                                       if (i >= 0 && i < yearData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(yearData[i].month), style: const TextStyle(fontSize: 8, color: Colors.grey)));
//                                       return const Text('');
//                                     })),
//                                   ),
//                                   barGroups: barGroups,
//                                 )),
//                               ),
//                             ),
//                             Positioned.fill(
//                               child: IgnorePointer(
//                                 child: LayoutBuilder(builder: (context, constraints) {
//                                   final double labelBottom = (constraints.maxHeight - 20) * (avgIn / maxY) + 12;
//                                   return Stack(
//                                     children: [
//                                       Positioned(
//                                         left: 0, right: 0,
//                                         bottom: labelBottom,
//                                         child: Center(
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.7),
//                                               borderRadius: BorderRadius.circular(6),
//                                               border: Border.all(color: Colors.orange.shade300, width: 1.2),
//                                             ),
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               child: Text(
//                                                 "REPORT_AVG_INCOME".tr(ref),
//                                                 style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade800, fontWeight: FontWeight.normal),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             ),
//                             if (_canScrollLeft)
//                               Positioned(left: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_left, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                             if (_canScrollRight)
//                               Positioned(right: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_right, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Center(child: Text("⟷ Swipe to view history ⟷", style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.5))),
//                     ]),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 4,
//                     child: categoryStats.when(
//                       loading: () { return const SizedBox.shrink(); },
//                       error: (err, stack) { return const SizedBox.shrink(); },
//                       data: (sData) {
//                         final colors = [const Color(0xFF1A237E), const Color(0xFF3F51B5), const Color(0xFF7986CB), const Color(0xFFC5CAE9), Colors.blueGrey];
//                         final List<PieChartSectionData> pieSections = (sData as List).asMap().entries.map((entry) {
//                           return PieChartSectionData(value: entry.value.amount.toDouble(), color: colors[entry.key % colors.length], radius: 40, title: '');
//                         }).toList();
//                         return Column(children: [
//                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           SizedBox(height: 100, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 15, sections: pieSections))),
//                           const SizedBox(height: 15),
//                           Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((entry) {
//                             final String name = entry.value.category.toString().startsWith('CAT_') ? entry.value.category.toString().tr(ref) : entry.value.category.toString();
//                             return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
//                               Container(width: 7, height: 7, decoration: BoxDecoration(color: colors[entry.key % colors.length], shape: BoxShape.circle)),
//                               const SizedBox(width: 5),
//                               Expanded(child: SizedBox(height: 12, child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(name, style: const TextStyle(fontSize: 9))))),
//                               const SizedBox(width: 3),
//                               FittedBox(fit: BoxFit.scaleDown, child: Text(fmt.format(entry.value.amount), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
//                             ]));
//                           }).toList()))),
//                         ]);
//                       },
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     _buildLegend(const Color(0xFF42A5F5), "COMMON_INCOME".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade100, "COMMON_EXPENSE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade700, "INSIGHT_LABEL_SPIKE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.orange.shade300, "REPORT_AVG_INCOME".tr(ref), isDash: true),
//                   ]),
//                 ),
//               )
//             ]);
//           }),
//     );
//   }
//
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     final Color overdueColor = const Color(0xFFEF5350);
//     final Color deficitColor = const Color(0xFFFFA726);
//     final Color spikeColor = const Color(0xFF8D6E63);
//     final bool hasOverdue = risk.overdueCount > 0;
//     final bool hasDeficit = risk.balance < 0;
//     final bool hasSpike = insights.any((i) { return i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'); });
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]),
//             Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18)),
//           ]),
//           const SizedBox(height: 16),
//           ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (hasOverdue) Expanded(flex: 20, child: Container(color: overdueColor)), if (hasDeficit) Expanded(flex: 35, child: Container(color: deficitColor)), if (hasSpike) Expanded(flex: 25, child: Container(color: spikeColor)), Expanded(flex: (100 - (hasOverdue ? 20 : 0) - (hasDeficit ? 35 : 0) - (hasSpike ? 25 : 0)).toInt().clamp(5, 100), child: Container(color: Colors.grey[200]!))]))),
//           const SizedBox(height: 12),
//           Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [_buildRiskLegend(overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue), _buildRiskLegend(deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit), _buildRiskLegend(spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike), _buildRiskLegend(Colors.grey[400]!, "INSIGHT_LABEL_SAFE".tr(ref), !hasOverdue && !hasDeficit && !hasSpike)])),
//           const SizedBox(height: 20),
//           Row(children: [_infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)), const SizedBox(width: 10), _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건")]),
//           const SizedBox(height: 12),
//           const Divider(),
//           ...insights.map((insight) {
//             String message = insight.messageKey.tr(ref);
//             insight.arguments?.forEach((key, value) { message = message.replaceAll('{$key}', value); });
//             return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))]));
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(NumberFormat fmt, String label, int amount, Color color, {required bool isBold}) {
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color))]);
//   }
//
//   Widget _buildRiskLegend(Color color, String label, bool isActive) {
//     return Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]);
//   }
//
//   Widget _infoTile(WidgetRef ref, String label, String value) {
//     return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))])));
//   }
//
//   Widget _buildSectionTitle(IconData i, String t) {
//     return Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]);
//   }
//
//   Widget _buildLegend(Color c, String l, {double fontSize = 10, bool isDash = false}) {
//     return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: isDash ? 2 : 8, decoration: BoxDecoration(color: c, shape: isDash ? BoxShape.rectangle : BoxShape.circle)), const SizedBox(width: 6), Flexible(child: Text(l, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]);
//   }
//
//   // 📍 [수정] 선택된 연도에 맞춰 엑셀 추출 대상 데이터를 DB에서 직접 가져오도록 수정
//   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
//     return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//         child: Column(children: [
//           Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8)),
//               child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 Expanded(
//                     child: Text(
//                         "${'REPORT_TAX_PERIOD'.tr(ref)}: $_selectedYear.01.01 - ${DateFormat('yyyy.MM.dd').format(_selectedYear == DateTime.now().year ? DateTime.now() : DateTime(_selectedYear, 12, 31))}",
//                         style: const TextStyle(fontSize: 13))),
//                 const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
//               ])),
//           const SizedBox(height: 20),
//           SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300],
//                       foregroundColor: isPro ? Colors.white : Colors.grey[600],
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//                   onPressed: isPro
//                       ? () async {
//                     // 📍 [핵심 수정] 캐싱된 Provider 대신 DB에서 해당 연도 전체 데이터를 직접 비동기로 가져옵니다.
//                     final db = ref.read(databaseProvider);
//                     final firstDay = DateTime(_selectedYear, 1, 1);
//                     final lastDay = DateTime(_selectedYear, 12, 31, 23, 59, 59);
//
//                     final transactions = await (db.select(db.transactions)
//                       ..where((t) => t.transactionDate.isBetweenValues(firstDay, lastDay))
//                       ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
//                         .get();
//
//                     if (transactions.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("NO_DATA_FOR_YEAR".tr(ref)))
//                       );
//                       return;
//                     }
//
//                     await ExcelExportService().exportTransactionsToExcel(transactions, ref);
//                   }
//                       : null,
//                   icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
//                   label: Text("REPORT_BTN_TAX_EXCEL".tr(ref),
//                       style: const TextStyle(fontWeight: FontWeight.bold))))
//         ]));
//   }
//
//   Widget _buildUnpaidSection(BuildContext c, WidgetRef r, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) {
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [unpaidAsync.when(loading: () { return const Center(child: CircularProgressIndicator()); }, error: (err, stack) { return const SizedBox(); }, data: (list) { final overdue = list.where((u) { return u.status == 'OVERDUE'; }).toList(); final total = overdue.fold(0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); }); if (overdue.isEmpty) { return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r), textAlign: TextAlign.center); } if (!isPro) { return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Center(child: Text("REPORT_LOCK_UNPAID".tr(r), style: TextStyle(color: Colors.grey[600], fontSize: 13)))); } return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) { return Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)); })])); }), const SizedBox(height: 20), Row(children: [Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], foregroundColor: isPro ? Colors.white : Colors.grey[600], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: isPro ? () async { await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], r); } : null, icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))), const SizedBox(width: 10), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300], foregroundColor: isPro ? Colors.white : Colors.grey[600], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: isPro ? () async { await _captureAndShare(_unpaidCaptureKey, r); } : null, icon: Icon(isPro ? Icons.share_outlined : Icons.lock_outline, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))])]));
//   }
//
//   Widget _buildAnnualSummary(BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
//     if (!p) { return _buildSimpleLockCard(r, "REPORT_LOCK_ANNUAL".tr(r)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//       final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
//       int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
//       int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
//       return Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(r)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//         const SizedBox(height: 10),
//         _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp, Colors.indigo, isBold: true)
//       ]);
//     }));
//   }
//
//   void _openPaywall(BuildContext c) { Navigator.of(c).push(MaterialPageRoute(builder: (context) { return const PaywallScreen(); })); }
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
//     int s = 0;
//     if (overdueCount > 0) s += 20;
//     if (thisMonthIncome < thisMonthExpense) s += 40;
//     if (insights.any((i) { return i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'); })) s += 25;
//     int fs = s.clamp(0, 100);
//     return _RiskSummary(score: fs, level: fs >= 75 ? _RiskLevel.high : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount, reasons: []);
//   }
// }
//
// enum _RiskLevel { low, mid, high }
//
// class _RiskSummary {
//   final int score;
//   final _RiskLevel level;
//   final List<String> reasons;
//   final int balance;
//   final int overdueCount;
//   _RiskSummary({required this.score, required this.level, required this.reasons, required this.balance, required this.overdueCount});
// }

//
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:drift/drift.dart' hide Column; // 📍 핵심: drift의 Column을 숨겨서 UI용 Column과 충돌 방지
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/state/purchase_provider.dart';
// import '../../core/purchase/ui/paywall_screen.dart';
// import '../../core/database/database_provider.dart';
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
// import 'financial_insight_service.dart';
//
// // 📍 [수정] 스크롤 상태 감지 및 연도 변경을 위해 ConsumerStatefulWidget으로 전환
// class ReportsScreen extends ConsumerStatefulWidget {
//   const ReportsScreen({super.key});
//
//   @override
//   ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
// }
//
// class _ReportsScreenState extends ConsumerState<ReportsScreen> {
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   // 📍 스크롤 상태 관리를 위한 컨트롤러
//   late ScrollController _chartScrollController;
//   bool _canScrollLeft = true;
//   bool _canScrollRight = false;
//
//   // 📍 [신규] 현재 보고 있는 연도 상태 (기본값: 현재 연도)
//   int _selectedYear = DateTime.now().year;
//
//   @override
//   void initState() {
//     super.initState();
//     _chartScrollController = ScrollController();
//     _chartScrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _chartScrollController.removeListener(_scrollListener);
//     _chartScrollController.dispose();
//     super.dispose();
//   }
//
//   // 📍 스크롤 위치에 따라 화살표 가시성을 실시간 업데이트 (reverse: true 기준)
//   void _scrollListener() {
//     if (!_chartScrollController.hasClients) return;
//
//     final maxScroll = _chartScrollController.position.maxScrollExtent;
//     final currentScroll = _chartScrollController.offset;
//
//     setState(() {
//       // offset 0 = 가장 오른쪽(최신), maxScroll = 가장 왼쪽(과거)
//       _canScrollLeft = currentScroll < maxScroll;
//       _canScrollRight = currentScroll > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).popUntil((route) { return route.isFirst || route.settings.name == '/main_screen'; });
//         }
//       }
//     });
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     // 📍 [수정] 선택된 연도에 따라 카테고리 통계를 동적으로 가져옴
//     final categoryStatsAsync = ref.watch(annualCategoryStatisticsProvider(_selectedYear));
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt =
//     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // 📍 [수정] 앱바 타이틀 영역에 연도 선택기 위젯 배치
//         title: Row(
//           children: [
//             Text("NAV_REPORTS".tr(ref),
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const Spacer(),
//             // 📍 Pro 권한이 있을 때만 연도 선택기 노출 (보안 강화)
//             if (isPro) _buildYearSelector(),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
//                 if (!isPro) _buildMainProAnchor(context, ref),
//
//                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
//                 monthlyTrendAsync.when(
//                     loading: () { return const SizedBox.shrink(); },
//                     error: (err, stack) { return const SizedBox.shrink(); },
//                     data: (trendData) {
//                       // 📍 [수정] 선택된 연도 데이터만 필터링
//                       final yearData = trendData.where((e) => e.month.year == _selectedYear).toList();
//
//                       return unpaidAsync.when(
//                           loading: () { return const SizedBox.shrink(); },
//                           error: (err, stack) { return const SizedBox.shrink(); },
//                           data: (unpaidList) {
//                             int inC = 0, exC = 0, lastEx = 0;
//                             final now = DateTime.now();
//
//                             // 선택된 연도가 현재 연도인 경우 이번 달 기준, 과거인 경우 12월 기준
//                             final bool isCurrentYear = _selectedYear == now.year;
//                             final int targetMonth = isCurrentYear ? now.month : 12;
//
//                             final thisMonth = yearData
//                                 .where((e) { return e.month.month == targetMonth; })
//                                 .toList();
//                             if (thisMonth.isNotEmpty) {
//                               inC = thisMonth.first.income;
//                               exC = thisMonth.first.expense;
//                             }
//                             final lastMonthData = yearData
//                                 .where((e) { return e.month.month == (targetMonth - 1); })
//                                 .toList();
//                             if (lastMonthData.isNotEmpty) {
//                               lastEx = lastMonthData.first.expense;
//                             }
//
//                             final overdue = unpaidList
//                                 .where((u) { return u.status == 'OVERDUE'; })
//                                 .toList();
//                             final totalO = overdue.fold(
//                                 0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//
//                             final insights = FinancialInsightService.generate(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO);
//                             final risk = _computeRiskSummary(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO,
//                                 insights: insights);
//
//                             return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _buildSectionTitle(Icons.lightbulb_outline,
//                                       "REPORT_SEC_INSIGHTS".tr(ref)),
//                                   const SizedBox(height: 10),
//                                   if (!isPro)
//                                   // 📍 [수정] 안내 문구 노출 (다국어 키 적용)
//                                     _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
//                                   else
//                                     _buildRiskSummaryCard(
//                                         ref, currencyFmt, risk, insights),
//                                   const SizedBox(height: 20),
//                                 ]);
//                           });
//                     }),
//
//                 // ✅ [복구] 재무 분석
//                 _buildSectionTitle(
//                     Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
//                 _buildFinancialAnalytics(context, ref, monthlyTrendAsync,
//                     categoryStatsAsync, currencyFmt, lang, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(
//                     Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined,
//                     "REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 // 📍 [에러 수정] ref 파라미터를 명시적으로 전달
//                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 30),
//                 // ✅ [복구] 연간 요약 타이틀 복구
//                 _buildSectionTitle(Icons.table_chart_outlined,
//                     "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
//               ],
//             ),
//           ),
//
//           // 📍 캡처 전용 위젯
//           Transform.translate(
//             offset: const Offset(-5000, -5000),
//             child: RepaintBoundary(
//               key: _unpaidCaptureKey,
//               child: Container(
//                 width: 450,
//                 padding: const EdgeInsets.all(30),
//                 color: Colors.white,
//                 child: unpaidAsync.when(
//                   data: (list) {
//                     final overdue =
//                     list.where((u) { return u.status == 'OVERDUE'; }).toList();
//                     final total = overdue.fold(
//                         0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
//                             style: const TextStyle(
//                                 color: Color(0xFF1A237E),
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold)),
//                         const Divider(color: Color(0xFF1A237E), thickness: 3),
//                         const SizedBox(height: 20),
//                         Text(
//                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
//                             style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w900)),
//                         const SizedBox(height: 30),
//                         ...overdue
//                             .map((u) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 15),
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                                 color: Colors.grey[50],
//                                 border:
//                                 Border.all(color: Colors.grey[300]!),
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Column(children: [
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                     Text(
//                                         currencyFmt
//                                             .format(u.unit.monthlyRent),
//                                         style: const TextStyle(
//                                             color: Color(0xFF1A237E),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                   ]),
//                               const SizedBox(height: 10),
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(u.unit.tenantPhone ?? '-',
//                                         style: const TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 14)),
//                                     Text(
//                                         "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
//                                         style: const TextStyle(
//                                             color: Colors.redAccent,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold)),
//                                   ]),
//                             ]),
//                           );
//                         })
//                             .toList(),
//                         const SizedBox(height: 30),
//                         const Center(
//                             child: Text("Generated by SiRE Asset Management",
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 12,
//                                     letterSpacing: 1.5))),
//                       ],
//                     );
//                   },
//                   loading: () { return const SizedBox.shrink(); },
//                   error: (err, stack) { return const SizedBox.shrink(); },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 📍 연도 선택 컨트롤러 위젯 ---
//   Widget _buildYearSelector() {
//     final now = DateTime.now();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () { setState(() { _selectedYear--; }); },
//             child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "$_selectedYear",
//               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           GestureDetector(
//             onTap: _selectedYear < now.year ? () { setState(() { _selectedYear++; }); } : null,
//             child: Icon(
//                 Icons.chevron_right,
//                 color: _selectedYear < now.year ? Colors.white : Colors.white24,
//                 size: 24
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 헬퍼 메서드 영역 (명시적 함수 스타일 유지) ---
//
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     final trialCount = ref.watch(trialCountProvider);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref),
//                   style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () { _openPaywall(context); },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A237E),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: trialCount > 0 ? () { ref.read(purchaseControllerProvider.notifier).startTrial(); } : null,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
//                 foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text(
//                 trialCount > 0 ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})" : "PROP_TRIAL_EXPIRED".tr(ref),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(children: [
//         const Icon(Icons.lock_outline, color: Colors.grey, size: 30),
//         const SizedBox(height: 12),
//         Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5))
//       ]),
//     );
//   }
//
//   Widget _buildFinancialAnalytics(BuildContext context, WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//     if (!isPro) {
//       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
//     }
//
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: monthlyTrend.when(
//           loading: () { return const Center(child: CircularProgressIndicator()); },
//           error: (err, stack) { return const SizedBox.shrink(); },
//           data: (trendData) {
//             // 📍 [수정] 전체 12개월 중 선택된 연도 데이터만 바인딩
//             final yearData = (trendData as List).where((e) => e.month.year == _selectedYear).toList();
//
//             if (yearData.isEmpty) {
//               return const Center(child: Text("해당 연도에 데이터가 없습니다."));
//             }
//
//             double maxY = yearData.map((e) => e.income > e.expense ? e.income.toDouble() : e.expense.toDouble()).reduce((a, b) => a > b ? a : b);
//             maxY = maxY > 0 ? maxY * 1.3 : 1000000;
//             double avgIn = yearData.fold(0, (sum, e) => (sum + e.income).toInt()) / yearData.length;
//
//             final double screenWidth = MediaQuery.of(context).size.width;
//             final double chartAvailableWidth = (screenWidth - 64) * 0.6;
//             final double barGroupWidth = chartAvailableWidth / 6;
//
//             final List<BarChartGroupData> barGroups = yearData.asMap().entries.map((e) {
//               final bool isSpike = e.value.expense > (avgIn * 0.4);
//               return BarChartGroupData(
//                   x: e.key,
//                   barsSpace: 2,
//                   barRods: [
//                     BarChartRodData(toY: e.value.income.toDouble(), color: const Color(0xFF42A5F5), width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                     BarChartRodData(toY: e.value.expense.toDouble(), color: isSpike ? Colors.redAccent.shade700 : Colors.redAccent.shade100, width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                   ]);
//             }).toList();
//
//             return Column(children: [
//               Expanded(
//                 child: Row(children: [
//                   Expanded(
//                     flex: 6,
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 25),
//                       Expanded(
//                         child: Stack(
//                           children: [
//                             SingleChildScrollView(
//                               controller: _chartScrollController,
//                               scrollDirection: Axis.horizontal,
//                               reverse: true,
//                               child: Container(
//                                 width: barGroupWidth * yearData.length,
//                                 padding: const EdgeInsets.only(right: 15),
//                                 child: BarChart(BarChartData(
//                                   maxY: maxY,
//                                   barTouchData: BarTouchData(
//                                     enabled: true,
//                                     touchTooltipData: BarTouchTooltipData(
//                                       tooltipBgColor: const Color(0xFF1A237E),
//                                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                                         return BarTooltipItem("${rodIndex == 0 ? 'IN' : 'EX'}\n${fmt.format(rod.toY)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
//                                       },
//                                     ),
//                                   ),
//                                   extraLinesData: ExtraLinesData(horizontalLines: [
//                                     HorizontalLine(
//                                       y: avgIn,
//                                       color: Colors.orange.shade300,
//                                       strokeWidth: 1.5,
//                                       dashArray: [4, 4],
//                                     )
//                                   ]),
//                                   gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
//                                   borderData: FlBorderData(show: false),
//                                   titlesData: FlTitlesData(
//                                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
//                                       int i = v.toInt();
//                                       if (i >= 0 && i < yearData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(yearData[i].month), style: const TextStyle(fontSize: 8, color: Colors.grey)));
//                                       return const Text('');
//                                     })),
//                                   ),
//                                   barGroups: barGroups,
//                                 )),
//                               ),
//                             ),
//                             Positioned.fill(
//                               child: IgnorePointer(
//                                 child: LayoutBuilder(builder: (context, constraints) {
//                                   final double labelBottom = (constraints.maxHeight - 20) * (avgIn / maxY) + 12;
//                                   return Stack(
//                                     children: [
//                                       Positioned(
//                                         left: 0, right: 0,
//                                         bottom: labelBottom,
//                                         child: Center(
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.7),
//                                               borderRadius: BorderRadius.circular(6),
//                                               border: Border.all(color: Colors.orange.shade300, width: 1.2),
//                                             ),
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               child: Text(
//                                                 "REPORT_AVG_INCOME".tr(ref),
//                                                 style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade800, fontWeight: FontWeight.normal),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             ),
//                             if (_canScrollLeft)
//                               Positioned(left: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_left, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                             if (_canScrollRight)
//                               Positioned(right: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_right, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Center(child: Text("⟷ Swipe to view history ⟷", style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.5))),
//                     ]),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 4,
//                     child: categoryStats.when(
//                       loading: () { return const SizedBox.shrink(); },
//                       error: (err, stack) { return const SizedBox.shrink(); },
//                       data: (sData) {
//                         final colors = [const Color(0xFF1A237E), const Color(0xFF3F51B5), const Color(0xFF7986CB), const Color(0xFFC5CAE9), Colors.blueGrey];
//                         return Column(children: [
//                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           SizedBox(height: 100, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 15, sections: (sData as List).asMap().entries.map<PieChartSectionData>((e) { return PieChartSectionData(value: e.value.amount.toDouble(), color: colors[e.key % colors.length], radius: 40, title: ''); }).toList()))),
//                           const SizedBox(height: 15),
//                           Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((e) { return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)), const SizedBox(width: 5), Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(e.value.category.toString().startsWith('CAT_') ? e.value.category.toString().tr(ref) : e.value.category.toString(), style: const TextStyle(fontSize: 9)))), const SizedBox(width: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(fmt.format(e.value.amount), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))])); }).toList()))),
//                         ]);
//                       },
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     _buildLegend(const Color(0xFF42A5F5), "COMMON_INCOME".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade100, "COMMON_EXPENSE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade700, "INSIGHT_LABEL_SPIKE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.orange.shade300, "REPORT_AVG_INCOME".tr(ref), isDash: true),
//                   ]),
//                 ),
//               )
//             ]);
//           }),
//     );
//   }
//
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     return Container(
//       width: double.infinity, padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]), Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18))]),
//         const SizedBox(height: 16),
//         ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: Colors.red)), if (risk.balance < 0) Expanded(flex: 35, child: Container(color: Colors.orange)), Expanded(flex: 45, child: Container(color: Colors.grey[200]!))]))),
//         const SizedBox(height: 12),
//         Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [_buildRiskLegend(Colors.red, "ALERT_OVERDUE_TITLE".tr(ref), risk.overdueCount > 0), _buildRiskLegend(Colors.orange, "INSIGHT_LABEL_DEFICIT".tr(ref), risk.balance < 0), _buildRiskLegend(Colors.grey, "INSIGHT_LABEL_SAFE".tr(ref), risk.overdueCount == 0 && risk.balance >= 0)] ) ),
//         const SizedBox(height: 20),
//         Row(children: [_infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)), const SizedBox(width: 10), _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건")]),
//         const SizedBox(height: 12),
//         const Divider(),
//         ...insights.map((insight) { String msg = insight.messageKey.tr(ref); insight.arguments?.forEach((k, v) { msg = msg.replaceAll('{$k}', v); }); return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))])); }).toList(),
//       ]),
//     );
//   }
//
//   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_TAX".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: $_selectedYear.01.01 - ${DateFormat('yyyy.MM.dd').format(_selectedYear == DateTime.now().year ? DateTime.now() : DateTime(_selectedYear, 12, 31))}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
//       const SizedBox(height: 20),
//       SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4CAF50),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//               onPressed: () async {
//                 final db = ref.read(databaseProvider);
//                 final txs = await (db.select(db.transactions)..where((t) => t.transactionDate.isBetweenValues(DateTime(_selectedYear, 1, 1), DateTime(_selectedYear, 12, 31, 23, 59, 59)))).get();
//                 if (txs.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("NO_DATA_FOR_YEAR".tr(ref)))); return; }
//                 await ExcelExportService().exportTransactionsToExcel(txs, ref);
//               },
//               icon: const Icon(Icons.file_download, size: 18),
//               label: Text("REPORT_BTN_TAX_EXCEL".tr(ref),
//                   style: const TextStyle(fontWeight: FontWeight.bold))))
//     ]));
//   }
//
//   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_UNPAID".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       unpaidAsync.when(loading: () { return const Center(child: CircularProgressIndicator()); }, error: (err, stack) { return const SizedBox(); }, data: (list) {
//         final overdue = list.where((u) => u.status == 'OVERDUE').toList();
//         final total = overdue.fold(0, (sum, item) => (sum + item.unit.monthlyRent).toInt());
//         if (overdue.isEmpty) { return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); }
//         return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) { return Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)); })]));
//       }),
//       const SizedBox(height: 20),
//       Row(children: [
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
//         const SizedBox(width: 10),
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
//       ])
//     ]));
//   }
//
//   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//       final yearData = (trend as List).where((e) => e.month.year == _selectedYear).toList();
//       int inc = yearData.fold(0, (sum, e) => (sum + e.income).toInt());
//       int exp = yearData.fold(0, (sum, e) => (sum + e.expense).toInt());
//       return Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//         const SizedBox(height: 10),
//         _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)
//       ]);
//     }));
//   }
//
//   Widget _buildSectionTitle(IconData i, String t) { return Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]); }
//   Widget _buildSummaryRow(NumberFormat fmt, String l, int a, Color c, {required bool isBold}) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))]); }
//   Widget _buildRiskLegend(Color color, String label, bool isActive) { return Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]); }
//   Widget _infoTile(WidgetRef ref, String label, String value) { return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))]))); }
//   Widget _buildLegend(Color c, String l, {bool isDash = false}) { return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: isDash ? 2 : 8, decoration: BoxDecoration(color: c, shape: isDash ? BoxShape.rectangle : BoxShape.circle)), const SizedBox(width: 6), Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))]); }
//   void _openPaywall(BuildContext c) { Navigator.of(c).push(MaterialPageRoute(builder: (context) { return const PaywallScreen(); })); }
//
//   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
//     try {
//       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
//     int s = 0;
//     if (overdueCount > 0) s += 20;
//     if (thisMonthIncome < thisMonthExpense) s += 40;
//     if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
//     return _RiskSummary(score: s.clamp(0, 100), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount);
//   }
// }
//
// class _RiskSummary { final int score; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.balance, required this.overdueCount}); }


//
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:drift/drift.dart' hide Column; // 📍 핵심: drift의 Column을 숨겨서 UI용 Column과 충돌 방지
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sire/features/reports/reports_provider.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/state/purchase_provider.dart';
// import '../../core/purchase/ui/paywall_screen.dart';
// import '../../core/database/database_provider.dart';
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
// import 'financial_insight_service.dart';
//
// // 📍 [수정] 스크롤 상태 감지 및 연도 변경을 위해 ConsumerStatefulWidget으로 전환
// class ReportsScreen extends ConsumerStatefulWidget {
//   const ReportsScreen({super.key});
//
//   @override
//   ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
// }
//
// class _ReportsScreenState extends ConsumerState<ReportsScreen> {
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   // 📍 스크롤 상태 관리를 위한 컨트롤러
//   late ScrollController _chartScrollController;
//   bool _canScrollLeft = true;
//   bool _canScrollRight = false;
//
//   // 📍 [신규] 현재 보고 있는 연도 상태 (기본값: 현재 연도)
//   int _selectedYear = DateTime.now().year;
//
//   @override
//   void initState() {
//     super.initState();
//     _chartScrollController = ScrollController();
//     _chartScrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _chartScrollController.removeListener(_scrollListener);
//     _chartScrollController.dispose();
//     super.dispose();
//   }
//
//   // 📍 스크롤 위치에 따라 화살표 가시성을 실시간 업데이트 (reverse: true 기준)
//   void _scrollListener() {
//     if (!_chartScrollController.hasClients) {
//       return;
//     }
//
//     final maxScroll = _chartScrollController.position.maxScrollExtent;
//     final currentScroll = _chartScrollController.offset;
//
//     setState(() {
//       // offset 0 = 가장 오른쪽(최신), maxScroll = 가장 왼쪽(과거)
//       _canScrollLeft = currentScroll < maxScroll;
//       _canScrollRight = currentScroll > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).popUntil((route) { return route.isFirst || route.settings.name == '/main_screen'; });
//         }
//       }
//     });
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     // 📍 [수정] 선택된 연도에 따라 카테고리 통계를 동적으로 가져옴
//     final categoryStatsAsync = ref.watch(annualCategoryStatisticsProvider(_selectedYear));
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt =
//     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // 📍 [수정] 앱바 타이틀 영역에 연도 선택기 위젯 배치
//         title: Row(
//           children: [
//             Text("NAV_REPORTS".tr(ref),
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const Spacer(),
//             // 📍 Pro 권한이 있을 때만 연도 선택기 노출 (보안 강화)
//             if (isPro) _buildYearSelector(),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
//                 if (!isPro) _buildMainProAnchor(context, ref),
//
//                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
//                 monthlyTrendAsync.when(
//                     loading: () { return const SizedBox.shrink(); },
//                     error: (err, stack) { return const SizedBox.shrink(); },
//                     data: (trendData) {
//                       // 📍 [수정] 선택된 연도 데이터만 필터링
//                       final yearData = trendData.where((e) => e.month.year == _selectedYear).toList();
//
//                       return unpaidAsync.when(
//                           loading: () { return const SizedBox.shrink(); },
//                           error: (err, stack) { return const SizedBox.shrink(); },
//                           data: (unpaidList) {
//                             int inC = 0, exC = 0, lastEx = 0;
//                             final now = DateTime.now();
//
//                             // 선택된 연도가 현재 연도인 경우 이번 달 기준, 과거인 경우 12월 기준
//                             final bool isCurrentYear = _selectedYear == now.year;
//                             final int targetMonth = isCurrentYear ? now.month : 12;
//
//                             final thisMonth = yearData
//                                 .where((e) { return e.month.month == targetMonth; })
//                                 .toList();
//                             if (thisMonth.isNotEmpty) {
//                               inC = thisMonth.first.income;
//                               exC = thisMonth.first.expense;
//                             }
//                             final lastMonthData = yearData
//                                 .where((e) { return e.month.month == (targetMonth - 1); })
//                                 .toList();
//                             if (lastMonthData.isNotEmpty) {
//                               lastEx = lastMonthData.first.expense;
//                             }
//
//                             final overdue = unpaidList
//                                 .where((u) { return u.status == 'OVERDUE'; })
//                                 .toList();
//                             final totalO = overdue.fold(
//                                 0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//
//                             final insights = FinancialInsightService.generate(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO);
//                             final risk = _computeRiskSummary(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO,
//                                 insights: insights);
//
//                             return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _buildSectionTitle(Icons.lightbulb_outline,
//                                       "REPORT_SEC_INSIGHTS".tr(ref)),
//                                   const SizedBox(height: 10),
//                                   if (!isPro)
//                                   // 📍 [수정] 안내 문구 노출 (한 줄 아이콘 + 텍스트)
//                                     _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
//                                   else
//                                     _buildRiskSummaryCard(
//                                         ref, currencyFmt, risk, insights),
//                                   const SizedBox(height: 20),
//                                 ]);
//                           });
//                     }),
//
//                 // ✅ [복구] 재무 분석
//                 _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildFinancialAnalytics(context, ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.table_chart_outlined,"REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 40),
//                 const Divider(thickness: 1.5), // 분석 영역과 도구 영역 구분을 위한 구분선
//                 const SizedBox(height: 20),
//
//                 _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined,"REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
//
//               ],
//             ),
//           ),
//
//           // 📍 캡처 전용 위젯 (원본 주석 및 구조 유지)
//           Transform.translate(
//             offset: const Offset(-5000, -5000),
//             child: RepaintBoundary(
//               key: _unpaidCaptureKey,
//               child: Container(
//                 width: 450,
//                 padding: const EdgeInsets.all(30),
//                 color: Colors.white,
//                 child: unpaidAsync.when(
//                   data: (list) {
//                     final overdue =
//                     list.where((u) { return u.status == 'OVERDUE'; }).toList();
//                     final total = overdue.fold(
//                         0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
//                             style: const TextStyle(
//                                 color: Color(0xFF1A237E),
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold)),
//                         const Divider(color: Color(0xFF1A237E), thickness: 3),
//                         const SizedBox(height: 20),
//                         Text(
//                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
//                             style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w900)),
//                         const SizedBox(height: 30),
//                         ...overdue
//                             .map((u) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 15),
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                                 color: Colors.grey[50],
//                                 border:
//                                 Border.all(color: Colors.grey[300]!),
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Column(children: [
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                     Text(
//                                         currencyFmt
//                                             .format(u.unit.monthlyRent),
//                                         style: const TextStyle(
//                                             color: Color(0xFF1A237E),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                   ]),
//                               const SizedBox(height: 10),
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(u.unit.tenantPhone ?? '-',
//                                         style: const TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 14)),
//                                     Text(
//                                         "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
//                                         style: const TextStyle(
//                                             color: Colors.redAccent,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold)),
//                                   ]),
//                             ]),
//                           );
//                         })
//                             .toList(),
//                         const SizedBox(height: 30),
//                         const Center(
//                             child: Text("Generated by SiRE Asset Management",
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 12,
//                                     letterSpacing: 1.5))),
//                       ],
//                     );
//                   },
//                   loading: () { return const SizedBox.shrink(); },
//                   error: (err, stack) { return const SizedBox.shrink(); },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 📍 연도 선택 컨트롤러 위젯 ---
//   Widget _buildYearSelector() {
//     final now = DateTime.now();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () { setState(() { _selectedYear--; }); },
//             child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "$_selectedYear",
//               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           GestureDetector(
//             onTap: _selectedYear < now.year ? () { setState(() { _selectedYear++; }); } : null,
//             child: Icon(
//                 Icons.chevron_right,
//                 color: _selectedYear < now.year ? Colors.white : Colors.white24,
//                 size: 24
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 헬퍼 메서드 영역 ---
//
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     final trialCount = ref.watch(trialCountProvider);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref),
//                   style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () { _openPaywall(context); },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A237E),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: trialCount > 0 ? () { ref.read(purchaseControllerProvider.notifier).startTrial(); } : null,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
//                 foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text(
//                 trialCount > 0 ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})" : "PROP_TRIAL_EXPIRED".tr(ref),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 📍 [수정] 아이콘과 텍스트를 한 줄(Row)에 배치하는 잠금 카드
//   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
//           const SizedBox(width: 10),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFinancialAnalytics(BuildContext context, WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//     if (!isPro) {
//       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
//     }
//
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: monthlyTrend.when(
//           loading: () { return const Center(child: CircularProgressIndicator()); },
//           error: (err, stack) { return const SizedBox.shrink(); },
//           data: (trendData) {
//             // 📍 원본 그래프 유지를 위해 yearData 필터링 및 너비 계산 로직 보존
//             final yearData = (trendData as List).where((e) => e.month.year == _selectedYear).toList();
//
//             if (yearData.isEmpty) {
//               return const Center(child: Text("해당 연도에 데이터가 없습니다."));
//             }
//
//             double maxY = yearData.map((e) => e.income > e.expense ? e.income.toDouble() : e.expense.toDouble()).reduce((a, b) => a > b ? a : b);
//             maxY = maxY > 0 ? maxY * 1.3 : 1000000;
//             double avgIn = yearData.fold(0, (sum, e) => (sum + e.income).toInt()) / yearData.length;
//
//             final double screenWidth = MediaQuery.of(context).size.width;
//             final double chartAvailableWidth = (screenWidth - 64) * 0.61;
//             final double barGroupWidth = chartAvailableWidth / 6;
//
//             final List<BarChartGroupData> barGroups = yearData.asMap().entries.map((e) {
//               final bool isSpike = e.value.expense > (avgIn * 0.4);
//               return BarChartGroupData(
//                   x: e.key,
//                   barsSpace: 2,
//                   barRods: [
//                     BarChartRodData(toY: e.value.income.toDouble(), color: const Color(0xFF42A5F5), width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                     BarChartRodData(toY: e.value.expense.toDouble(), color: isSpike ? Colors.redAccent.shade700 : Colors.redAccent.shade100, width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                   ]);
//             }).toList();
//
//             return Column(children: [
//               Expanded(
//                 child: Row(children: [
//                   Expanded(
//                     flex: 6,
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 25),
//                       Expanded(
//                         child: Stack(
//                           children: [
//                             SingleChildScrollView(
//                               controller: _chartScrollController,
//                               scrollDirection: Axis.horizontal,
//                               reverse: true,
//                               child: Container(
//                                 width: barGroupWidth * yearData.length,
//                                 padding: const EdgeInsets.only(right: 15),
//                                 child: BarChart(BarChartData(
//                                   maxY: maxY,
//                                   barTouchData: BarTouchData(
//                                     enabled: true,
//                                     touchTooltipData: BarTouchTooltipData(
//                                       tooltipBgColor: const Color(0xFF1A237E),
//                                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                                         return BarTooltipItem("${rodIndex == 0 ? 'IN' : 'EX'}\n${fmt.format(rod.toY)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
//                                       },
//                                     ),
//                                   ),
//                                   extraLinesData: ExtraLinesData(horizontalLines: [
//                                     HorizontalLine(
//                                       y: avgIn,
//                                       color: Colors.orange.shade300,
//                                       strokeWidth: 1.5,
//                                       dashArray: [4, 4],
//                                     )
//                                   ]),
//                                   gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
//                                   borderData: FlBorderData(show: false),
//                                   titlesData: FlTitlesData(
//                                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
//                                       int i = v.toInt();
//                                       if (i >= 0 && i < yearData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(yearData[i].month), style: const TextStyle(fontSize: 8, color: Colors.grey)));
//                                       return const Text('');
//                                     })),
//                                   ),
//                                   barGroups: barGroups,
//                                 )),
//                               ),
//                             ),
//                             Positioned.fill(
//                               child: IgnorePointer(
//                                 child: LayoutBuilder(builder: (context, constraints) {
//                                   final double labelBottom = (constraints.maxHeight - 20) * (avgIn / maxY) + 12;
//                                   return Stack(
//                                     children: [
//                                       Positioned(
//                                         left: 0, right: 0,
//                                         bottom: labelBottom,
//                                         child: Center(
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.7),
//                                               borderRadius: BorderRadius.circular(6),
//                                               border: Border.all(color: Colors.orange.shade300, width: 1.2),
//                                             ),
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               child: Text(
//                                                 "REPORT_AVG_INCOME".tr(ref),
//                                                 style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade800, fontWeight: FontWeight.normal),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             ),
//                             if (_canScrollLeft)
//                               Positioned(left: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_left, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                             if (_canScrollRight)
//                               Positioned(right: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_right, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Center(child: Text("⟷ Swipe to view history ⟷", style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.5))),
//                     ]),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 4,
//                     child: categoryStats.when(
//                       loading: () { return const SizedBox.shrink(); },
//                       error: (err, stack) { return const SizedBox.shrink(); },
//                       data: (sData) {
//                         final colors = [const Color(0xFF1A237E), const Color(0xFF3F51B5), const Color(0xFF7986CB), const Color(0xFFC5CAE9), Colors.blueGrey];
//                         return Column(children: [
//                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           SizedBox(height: 100, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 15, sections: (sData as List).asMap().entries.map<PieChartSectionData>((e) { return PieChartSectionData(value: e.value.amount.toDouble(), color: colors[e.key % colors.length], radius: 40, title: ''); }).toList()))),
//                           const SizedBox(height: 15),
//                           Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((e) { return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)), const SizedBox(width: 5), Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(e.value.category.toString().startsWith('CAT_') ? e.value.category.toString().tr(ref) : e.value.category.toString(), style: const TextStyle(fontSize: 9)))), const SizedBox(width: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(fmt.format(e.value.amount), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))])); }).toList()))),
//                         ]);
//                       },
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     _buildLegend(const Color(0xFF42A5F5), "COMMON_INCOME".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade100, "COMMON_EXPENSE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade700, "INSIGHT_LABEL_SPIKE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.orange.shade300, "REPORT_AVG_INCOME".tr(ref), isDash: true),
//                   ]),
//                 ),
//               )
//             ]);
//           }),
//     );
//   }
//
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     return Container(
//       width: double.infinity, padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]), Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18))]),
//         const SizedBox(height: 16),
//         ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: Colors.red)), if (risk.balance < 0) Expanded(flex: 35, child: Container(color: Colors.orange)), Expanded(flex: 45, child: Container(color: Colors.grey[200]!))]))),
//         const SizedBox(height: 12),
//         Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [_buildRiskLegend(Colors.red, "ALERT_OVERDUE_TITLE".tr(ref), risk.overdueCount > 0), _buildRiskLegend(Colors.orange, "INSIGHT_LABEL_DEFICIT".tr(ref), risk.balance < 0), _buildRiskLegend(Colors.grey, "INSIGHT_LABEL_SAFE".tr(ref), risk.overdueCount == 0 && risk.balance >= 0)] ) ),
//         const SizedBox(height: 20),
//         Row(children: [_infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)), const SizedBox(width: 10), _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건")]),
//         const SizedBox(height: 12),
//         const Divider(),
//         ...insights.map((insight) { String msg = insight.messageKey.tr(ref); insight.arguments?.forEach((k, v) { msg = msg.replaceAll('{$k}', v); }); return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))])); }).toList(),
//       ]),
//     );
//   }
//
//   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_TAX".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: $_selectedYear.01.01 - ${DateFormat('yyyy.MM.dd').format(_selectedYear == DateTime.now().year ? DateTime.now() : DateTime(_selectedYear, 12, 31))}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
//       const SizedBox(height: 20),
//       SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//           onPressed: () async {
//             final db = ref.read(databaseProvider);
//             final txs = await (db.select(db.transactions)..where((t) { return t.transactionDate.isBetweenValues(DateTime(_selectedYear, 1, 1), DateTime(_selectedYear, 12, 31, 23, 59, 59)); })).get();
//             if (txs.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("NO_DATA_FOR_YEAR".tr(ref)))); return; }
//             await ExcelExportService().exportTransactionsToExcel(txs, ref);
//           },
//           icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))
//     ]));
//   }
//
//   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_UNPAID".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       unpaidAsync.when(loading: () { return const Center(child: CircularProgressIndicator()); }, error: (err, stack) { return const SizedBox(); }, data: (list) {
//         final overdue = list.where((u) { return u.status == 'OVERDUE'; }).toList();
//         final total = overdue.fold(0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//         if (overdue.isEmpty) { return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); }
//         return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) { return Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)); })]));
//       }),
//       const SizedBox(height: 20),
//       Row(children: [
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
//         const SizedBox(width: 10),
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
//       ])
//     ]));
//   }
//
//   // Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
//   //   if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }
//   //   return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//   //     final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
//   //     int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
//   //     int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
//   //     return Column(children: [
//   //       Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//   //       const SizedBox(height: 10),
//   //       _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false),
//   //       const Divider(height: 20),
//   //       _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false),
//   //       const Divider(height: 20),
//   //       _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)
//   //     ]);
//   //   }));
//   // }
//
//   // Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
//   //   if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }
//   //
//   //   // 📍 [신규] 증빙 완료율 데이터 구독
//   //   final receiptCompletionAsync = ref.watch(annualReceiptCompletionProvider(_selectedYear));
//   //
//   //   return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//   //     final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
//   //     int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
//   //     int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
//   //
//   //     return Column(children: [
//   //       Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//   //       const SizedBox(height: 10),
//   //       _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false),
//   //       const Divider(height: 20),
//   //       _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false),
//   //
//   //       // 📍 [신규 추가] 1번 기능: 지출 증빙 완료율 표시
//   //       receiptCompletionAsync.when(
//   //         data: (completionRate) => Padding(
//   //           padding: const EdgeInsets.only(top: 8, bottom: 8),
//   //           child: Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               Text("REPORT_RECEIPT_COMPLETION".tr(ref), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//   //               Text("${completionRate.toStringAsFixed(1)}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: completionRate >= 90 ? Colors.green : Colors.orange)),
//   //             ],
//   //           ),
//   //         ),
//   //         loading: () => const SizedBox.shrink(),
//   //         error: (_, __) => const SizedBox.shrink(),
//   //       ),
//   //
//   //       const Divider(height: 20),
//   //       _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), inc - exp, Colors.indigo, isBold: true)
//   //     ]);
//   //   }));
//   // }
//
//   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }
//
//     // 📍 1번/3번 데이터 구독
//     final receiptCompletionAsync = ref.watch(annualReceiptCompletionProvider(_selectedYear));
//     final profitMarginAsync = ref.watch(annualProfitMarginProvider(_selectedYear));
//
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//       final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
//       int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
//       int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
//       int netProfit = inc - exp;
//
//       return Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//         const SizedBox(height: 10),
//         _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false),
//
//         // 📍 [1번 기능] 지출 증빙 완료율 (중간에 배치)
//         receiptCompletionAsync.when(
//           data: (rate) => _buildSubInsightRow("REPORT_RECEIPT_COMPLETION".tr(ref), "${rate.toStringAsFixed(1)}%"),
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//
//         const Divider(height: 20),
//
//         // 📍 [핵심 변경] 연간 순이익 금액을 먼저 표시
//         _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), netProfit, Colors.indigo, isBold: true),
//
//         // 📍 [3번 수정] 순이익률 표시 (증빙 완료율과 동일한 레이아웃으로 변경)
//         profitMarginAsync.when(
//           data: (margin) => _buildSubInsightRow(
//             "REPORT_PROFIT_MARGIN".tr(ref),
//             "${margin.toStringAsFixed(1)}%",
//             valueColor: margin >= 0 ? Colors.indigo : Colors.red, // 수익 상태에 따른 색상 강조
//           ),
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//       ]);
//     }));
//   }
//
//   // 📍 [범용 위젯 수정] 라벨과 수치를 양 끝으로 배치하고 색상 옵션을 추가함
//   Widget _buildSubInsightRow(String label, String value, {Color valueColor = Colors.blueGrey}) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
//         children: [
//           Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//           Text(
//               value,
//               style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: valueColor
//               )
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildSectionTitle(IconData i, String t) { return Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]); }
//   Widget _buildSummaryRow(NumberFormat fmt, String l, int a, Color c, {required bool isBold}) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))]); }
//   Widget _buildRiskLegend(Color color, String label, bool isActive) { return Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]); }
//   Widget _infoTile(WidgetRef ref, String label, String value) { return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))]))); }
//   Widget _buildLegend(Color c, String l, {bool isDash = false}) { return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: isDash ? 2 : 8, decoration: BoxDecoration(color: c, shape: isDash ? BoxShape.rectangle : BoxShape.circle)), const SizedBox(width: 6), Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))]); }
//   void _openPaywall(BuildContext c) { Navigator.of(c).push(MaterialPageRoute(builder: (context) { return const PaywallScreen(); })); }
//
//   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
//     try {
//       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
//     int s = 0;
//     if (overdueCount > 0) s += 20;
//     if (thisMonthIncome < thisMonthExpense) s += 40;
//     if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
//     return _RiskSummary(score: s.clamp(0, 100), balance: thisMonthIncome - thisMonthExpense, overdueCount: overdueCount);
//   }
// }
//
// class _RiskSummary { final int score; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.balance, required this.overdueCount}); }


//
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:drift/drift.dart' hide Column; // 📍 핵심: drift의 Column을 숨겨서 UI용 Column과 충돌 방지
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sire/features/reports/reports_provider.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/state/purchase_provider.dart';
// import '../../core/purchase/ui/paywall_screen.dart';
// import '../../core/database/database_provider.dart';
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
// import 'financial_insight_service.dart';
//
// // 📍 [수정] 스크롤 상태 감지 및 연도 변경을 위해 ConsumerStatefulWidget으로 전환
// class ReportsScreen extends ConsumerStatefulWidget {
//   const ReportsScreen({super.key});
//
//   @override
//   ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
// }
//
// class _ReportsScreenState extends ConsumerState<ReportsScreen> {
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   // 📍 스크롤 상태 관리를 위한 컨트롤러
//   late ScrollController _chartScrollController;
//   bool _canScrollLeft = true;
//   bool _canScrollRight = false;
//
//   // 📍 [신규] 현재 보고 있는 연도 상태 (기본값: 현재 연도)
//   int _selectedYear = DateTime.now().year;
//
//   @override
//   void initState() {
//     super.initState();
//     _chartScrollController = ScrollController();
//     _chartScrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _chartScrollController.removeListener(_scrollListener);
//     _chartScrollController.dispose();
//     super.dispose();
//   }
//
//   // 📍 스크롤 위치에 따라 화살표 가시성을 실시간 업데이트 (reverse: true 기준)
//   void _scrollListener() {
//     if (!_chartScrollController.hasClients) {
//       return;
//     }
//
//     final maxScroll = _chartScrollController.position.maxScrollExtent;
//     final currentScroll = _chartScrollController.offset;
//
//     setState(() {
//       // offset 0 = 가장 오른쪽(최신), maxScroll = 가장 왼쪽(과거)
//       _canScrollLeft = currentScroll < maxScroll;
//       _canScrollRight = currentScroll > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).popUntil((route) { return route.isFirst || route.settings.name == '/main_screen'; });
//         }
//       }
//     });
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     // 📍 [수정] 선택된 연도에 따라 카테고리 통계를 동적으로 가져옴
//     final categoryStatsAsync = ref.watch(annualCategoryStatisticsProvider(_selectedYear));
//     final unpaidAsync = ref.watch(unpaidListProvider);
//
//     // 📍 [신규] 재무 위험도를 위한 전체 기간 누적 잔액 구독
//     final totalBalanceAsync = ref.watch(totalCumulativeBalanceProvider);
//
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt =
//     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // 📍 [수정] 앱바 타이틀 영역에 연도 선택기 위젯 배치
//         title: Row(
//           children: [
//             Text("NAV_REPORTS".tr(ref),
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const Spacer(),
//             // 📍 Pro 권한이 있을 때만 연도 선택기 노출 (보안 강화)
//             if (isPro) _buildYearSelector(),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
//                 if (!isPro) _buildMainProAnchor(context, ref),
//
//                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
//                 monthlyTrendAsync.when(
//                     loading: () { return const SizedBox.shrink(); },
//                     error: (err, stack) { return const SizedBox.shrink(); },
//                     data: (trendData) {
//                       // 📍 [수정] '재무 분석' 및 '요약표'를 위한 연도별 데이터 필터링
//                       final yearData = trendData.where((e) => e.month.year == _selectedYear).toList();
//
//                       return unpaidAsync.when(
//                           loading: () { return const SizedBox.shrink(); },
//                           error: (err, stack) { return const SizedBox.shrink(); },
//                           data: (unpaidList) {
//                             int inC = 0, exC = 0, lastEx = 0;
//                             final now = DateTime.now();
//
//                             // 📍 이번 달 지출 급증 분석을 위해 선택된 연도의 데이터를 추출
//                             final bool isSelectedCurrentYear = _selectedYear == now.year;
//                             final int targetMonth = isSelectedCurrentYear ? now.month : 12;
//
//                             final thisMonth = yearData
//                                 .where((e) { return e.month.month == targetMonth; })
//                                 .toList();
//                             if (thisMonth.isNotEmpty) {
//                               inC = thisMonth.first.income;
//                               exC = thisMonth.first.expense;
//                             }
//                             final lastMonthData = yearData
//                                 .where((e) { return e.month.month == (targetMonth - 1); })
//                                 .toList();
//                             if (lastMonthData.isNotEmpty) {
//                               lastEx = lastMonthData.first.expense;
//                             }
//
//                             // 📍 [중요 수정] 미납은 연도와 관계없이 '전체 미납(OVERDUE)'을 집계
//                             final overdue = unpaidList
//                                 .where((u) { return u.status == 'OVERDUE'; })
//                                 .toList();
//                             final totalO = overdue.fold(
//                                 0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//
//                             final insights = FinancialInsightService.generate(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO);
//
//                             return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _buildSectionTitle(Icons.lightbulb_outline,
//                                       "REPORT_SEC_INSIGHTS".tr(ref)),
//                                   const SizedBox(height: 10),
//                                   if (!isPro)
//                                   // 📍 [수정] 안내 문구 노출 (한 줄 아이콘 + 텍스트)
//                                     _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
//                                   else
//                                   // 📍 [중요 수정] 위험도 지수 카드는 전체 누적 잔액(totalBalanceAsync)을 사용
//                                     totalBalanceAsync.when(
//                                       data: (cumulativeBalance) {
//                                         final risk = _computeRiskSummary(
//                                             thisMonthIncome: inC,
//                                             thisMonthExpense: exC,
//                                             lastMonthExpense: lastEx,
//                                             overdueCount: overdue.length,
//                                             totalOverdueAmount: totalO,
//                                             balance: cumulativeBalance.toInt(), // 📍 누적 잔액 전달
//                                             insights: insights);
//
//                                         return _buildRiskSummaryCard(
//                                             ref, currencyFmt, risk, insights);
//                                       },
//                                       loading: () => const Center(child: CircularProgressIndicator()),
//                                       error: (err, stack) => const SizedBox.shrink(),
//                                     ),
//                                   const SizedBox(height: 20),
//                                 ]);
//                           });
//                     }),
//
//                 // ✅ [복구] 재무 분석
//                 _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildFinancialAnalytics(context, ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.table_chart_outlined,"REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 40),
//                 const Divider(thickness: 1.5), // 분석 영역과 도구 영역 구분을 위한 구분선
//                 const SizedBox(height: 20),
//
//                 _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined,"REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
//
//               ],
//             ),
//           ),
//
//           // 📍 캡처 전용 위젯 (원본 주석 및 구조 유지)
//           Transform.translate(
//             offset: const Offset(-5000, -5000),
//             child: RepaintBoundary(
//               key: _unpaidCaptureKey,
//               child: Container(
//                 width: 450,
//                 padding: const EdgeInsets.all(30),
//                 color: Colors.white,
//                 child: unpaidAsync.when(
//                   data: (list) {
//                     final overdue =
//                     list.where((u) { return u.status == 'OVERDUE'; }).toList();
//                     final total = overdue.fold(
//                         0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
//                             style: const TextStyle(
//                                 color: Color(0xFF1A237E),
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold)),
//                         const Divider(color: Color(0xFF1A237E), thickness: 3),
//                         const SizedBox(height: 20),
//                         Text(
//                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
//                             style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w900)),
//                         const SizedBox(height: 30),
//                         ...overdue
//                             .map((u) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 15),
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                                 color: Colors.grey[50],
//                                 border:
//                                 Border.all(color: Colors.grey[300]!),
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Column(children: [
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                     Text(
//                                         currencyFmt
//                                             .format(u.unit.monthlyRent),
//                                         style: const TextStyle(
//                                             color: Color(0xFF1A237E),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                   ]),
//                               const SizedBox(height: 10),
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(u.unit.tenantPhone ?? '-',
//                                         style: const TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 14)),
//                                     Text(
//                                         "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
//                                         style: const TextStyle(
//                                             color: Colors.redAccent,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold)),
//                                   ]),
//                             ]),
//                           );
//                         })
//                             .toList(),
//                         const SizedBox(height: 30),
//                         const Center(
//                             child: Text("Generated by SiRE Asset Management",
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 12,
//                                     letterSpacing: 1.5))),
//                       ],
//                     );
//                   },
//                   loading: () { return const SizedBox.shrink(); },
//                   error: (err, stack) { return const SizedBox.shrink(); },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 📍 연도 선택 컨트롤러 위젯 ---
//   Widget _buildYearSelector() {
//     final now = DateTime.now();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () { setState(() { _selectedYear--; }); },
//             child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "$_selectedYear",
//               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           GestureDetector(
//             onTap: _selectedYear < now.year ? () { setState(() { _selectedYear++; }); } : null,
//             child: Icon(
//                 Icons.chevron_right,
//                 color: _selectedYear < now.year ? Colors.white : Colors.white24,
//                 size: 24
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 헬퍼 메서드 영역 ---
//
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     final trialCount = ref.watch(trialCountProvider);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref),
//                   style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () { _openPaywall(context); },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A237E),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: trialCount > 0 ? () { ref.read(purchaseControllerProvider.notifier).startTrial(); } : null,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
//                 foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text(
//                 trialCount > 0 ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})" : "PROP_TRIAL_EXPIRED".tr(ref),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 📍 [수정] 아이콘과 텍스트를 한 줄(Row)에 배치하는 잠금 카드
//   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
//           const SizedBox(width: 10),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFinancialAnalytics(BuildContext context, WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//     if (!isPro) {
//       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
//     }
//
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: monthlyTrend.when(
//           loading: () { return const Center(child: CircularProgressIndicator()); },
//           error: (err, stack) { return const SizedBox.shrink(); },
//           data: (trendData) {
//             // 📍 원본 그래프 유지를 위해 yearData 필터링 및 너비 계산 로직 보존
//             final yearData = (trendData as List).where((e) => e.month.year == _selectedYear).toList();
//
//             if (yearData.isEmpty) {
//               return const Center(child: Text("해당 연도에 데이터가 없습니다."));
//             }
//
//             double maxY = yearData.map((e) => e.income > e.expense ? e.income.toDouble() : e.expense.toDouble()).reduce((a, b) => a > b ? a : b);
//             maxY = maxY > 0 ? maxY * 1.3 : 1000000;
//             double avgIn = yearData.fold(0, (sum, e) => (sum + e.income).toInt()) / yearData.length;
//
//             final double screenWidth = MediaQuery.of(context).size.width;
//             final double chartAvailableWidth = (screenWidth - 64) * 0.61;
//             final double barGroupWidth = chartAvailableWidth / 6;
//
//             final List<BarChartGroupData> barGroups = yearData.asMap().entries.map((e) {
//               final bool isSpike = e.value.expense > (avgIn * 0.4);
//               return BarChartGroupData(
//                   x: e.key,
//                   barsSpace: 2,
//                   barRods: [
//                     BarChartRodData(toY: e.value.income.toDouble(), color: const Color(0xFF42A5F5), width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                     BarChartRodData(toY: e.value.expense.toDouble(), color: isSpike ? Colors.redAccent.shade700 : Colors.redAccent.shade100, width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                   ]);
//             }).toList();
//
//             return Column(children: [
//               Expanded(
//                 child: Row(children: [
//                   Expanded(
//                     flex: 6,
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 25),
//                       Expanded(
//                         child: Stack(
//                           children: [
//                             SingleChildScrollView(
//                               controller: _chartScrollController,
//                               scrollDirection: Axis.horizontal,
//                               reverse: true,
//                               child: Container(
//                                 width: barGroupWidth * yearData.length,
//                                 padding: const EdgeInsets.only(right: 15),
//                                 child: BarChart(BarChartData(
//                                   maxY: maxY,
//                                   barTouchData: BarTouchData(
//                                     enabled: true,
//                                     touchTooltipData: BarTouchTooltipData(
//                                       tooltipBgColor: const Color(0xFF1A237E),
//                                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                                         return BarTooltipItem("${rodIndex == 0 ? 'IN' : 'EX'}\n${fmt.format(rod.toY)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
//                                       },
//                                     ),
//                                   ),
//                                   extraLinesData: ExtraLinesData(horizontalLines: [
//                                     HorizontalLine(
//                                       y: avgIn,
//                                       color: Colors.orange.shade300,
//                                       strokeWidth: 1.5,
//                                       dashArray: [4, 4],
//                                     )
//                                   ]),
//                                   gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
//                                   borderData: FlBorderData(show: false),
//                                   titlesData: FlTitlesData(
//                                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
//                                       int i = v.toInt();
//                                       if (i >= 0 && i < yearData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(yearData[i].month), style: const TextStyle(fontSize: 8, color: Colors.grey)));
//                                       return const Text('');
//                                     })),
//                                   ),
//                                   barGroups: barGroups,
//                                 )),
//                               ),
//                             ),
//                             Positioned.fill(
//                               child: IgnorePointer(
//                                 child: LayoutBuilder(builder: (context, constraints) {
//                                   final double labelBottom = (constraints.maxHeight - 20) * (avgIn / maxY) + 12;
//                                   return Stack(
//                                     children: [
//                                       Positioned(
//                                         left: 0, right: 0,
//                                         bottom: labelBottom,
//                                         child: Center(
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.7),
//                                               borderRadius: BorderRadius.circular(6),
//                                               border: Border.all(color: Colors.orange.shade300, width: 1.2),
//                                             ),
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               child: Text(
//                                                 "REPORT_AVG_INCOME".tr(ref),
//                                                 style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade800, fontWeight: FontWeight.normal),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             ),
//                             if (_canScrollLeft)
//                               Positioned(left: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_left, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                             if (_canScrollRight)
//                               Positioned(right: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_right, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Center(child: Text("⟷ Swipe to view history ⟷", style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.5))),
//                     ]),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 4,
//                     child: categoryStats.when(
//                       loading: () { return const SizedBox.shrink(); },
//                       error: (err, stack) { return const SizedBox.shrink(); },
//                       data: (sData) {
//                         final colors = [const Color(0xFF1A237E), const Color(0xFF3F51B5), const Color(0xFF7986CB), const Color(0xFFC5CAE9), Colors.blueGrey];
//                         return Column(children: [
//                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           SizedBox(height: 100, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 15, sections: (sData as List).asMap().entries.map<PieChartSectionData>((e) { return PieChartSectionData(value: e.value.amount.toDouble(), color: colors[e.key % colors.length], radius: 40, title: ''); }).toList()))),
//                           const SizedBox(height: 15),
//                           Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((e) { return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)), const SizedBox(width: 5), Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(e.value.category.toString().startsWith('CAT_') ? e.value.category.toString().tr(ref) : e.value.category.toString(), style: const TextStyle(fontSize: 9)))), const SizedBox(width: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(fmt.format(e.value.amount), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))])); }).toList()))),
//                         ]);
//                       },
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     _buildLegend(const Color(0xFF42A5F5), "COMMON_INCOME".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade100, "COMMON_EXPENSE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade700, "INSIGHT_LABEL_SPIKE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.orange.shade300, "REPORT_AVG_INCOME".tr(ref), isDash: true),
//                   ]),
//                 ),
//               )
//             ]);
//           }),
//     );
//   }
//
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     return Container(
//       width: double.infinity, padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]), Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18))]),
//         const SizedBox(height: 16),
//         ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: Colors.red)), if (risk.balance < 0) Expanded(flex: 35, child: Container(color: Colors.orange)), Expanded(flex: 45, child: Container(color: Colors.grey[200]!))]))),
//         const SizedBox(height: 12),
//         Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [_buildRiskLegend(Colors.red, "ALERT_OVERDUE_TITLE".tr(ref), risk.overdueCount > 0), _buildRiskLegend(Colors.orange, "INSIGHT_LABEL_DEFICIT".tr(ref), risk.balance < 0), _buildRiskLegend(Colors.grey, "INSIGHT_LABEL_SAFE".tr(ref), risk.overdueCount == 0 && risk.balance >= 0)] ) ),
//         const SizedBox(height: 20),
//         Row(children: [_infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)), const SizedBox(width: 10), _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건")]),
//         const SizedBox(height: 12),
//         const Divider(),
//         ...insights.map((insight) { String msg = insight.messageKey.tr(ref); insight.arguments?.forEach((k, v) { msg = msg.replaceAll('{$k}', v); }); return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))])); }).toList(),
//       ]),
//     );
//   }
//
//   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_TAX".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: $_selectedYear.01.01 - ${DateFormat('yyyy.MM.dd').format(_selectedYear == DateTime.now().year ? DateTime.now() : DateTime(_selectedYear, 12, 31))}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
//       const SizedBox(height: 20),
//       SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//           onPressed: () async {
//             final db = ref.read(databaseProvider);
//             final txs = await (db.select(db.transactions)..where((t) { return t.transactionDate.isBetweenValues(DateTime(_selectedYear, 1, 1), DateTime(_selectedYear, 12, 31, 23, 59, 59)); })).get();
//             if (txs.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("NO_DATA_FOR_YEAR".tr(ref)))); return; }
//             await ExcelExportService().exportTransactionsToExcel(txs, ref);
//           },
//           icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))
//     ]));
//   }
//
//   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_UNPAID".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       unpaidAsync.when(loading: () { return const Center(child: CircularProgressIndicator()); }, error: (err, stack) { return const SizedBox(); }, data: (list) {
//         // 📍 [중요 수정] 미납 정보 노출 시 전체 기간의 미납을 보여줌
//         final overdue = list.where((u) { return u.status == 'OVERDUE'; }).toList();
//         final total = overdue.fold(0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//         if (overdue.isEmpty) { return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); }
//         return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) { return Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)); })]));
//       }),
//       const SizedBox(height: 20),
//       Row(children: [
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
//         const SizedBox(width: 10),
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
//       ])
//     ]));
//   }
//
//   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }
//
//     // 📍 1번/3번 데이터 구독
//     final receiptCompletionAsync = ref.watch(annualReceiptCompletionProvider(_selectedYear));
//     final profitMarginAsync = ref.watch(annualProfitMarginProvider(_selectedYear));
//
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//       final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
//       int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
//       int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
//       int netProfit = inc - exp;
//
//       return Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//         const SizedBox(height: 10),
//         _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false),
//
//         // 📍 [1번 기능] 지출 증빙 완료율 (중간에 배치)
//         receiptCompletionAsync.when(
//           data: (rate) => _buildSubInsightRow("REPORT_RECEIPT_COMPLETION".tr(ref), "${rate.toStringAsFixed(1)}%"),
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//
//         const Divider(height: 20),
//
//         // 📍 [핵심 변경] 연간 순이익 금액을 먼저 표시
//         _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), netProfit, Colors.indigo, isBold: true),
//
//         // 📍 [3번 수정] 순이익률 표시 (증빙 완료율과 동일한 레이아웃으로 변경)
//         profitMarginAsync.when(
//           data: (margin) => _buildSubInsightRow(
//             "REPORT_PROFIT_MARGIN".tr(ref),
//             "${margin.toStringAsFixed(1)}%",
//             valueColor: margin >= 0 ? Colors.indigo : Colors.red, // 수익 상태에 따른 색상 강조
//           ),
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//       ]);
//     }));
//   }
//
//   // 📍 [범용 위젯 수정] 라벨과 수치를 양 끝으로 배치하고 색상 옵션을 추가함
//   Widget _buildSubInsightRow(String label, String value, {Color valueColor = Colors.blueGrey}) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
//         children: [
//           Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//           Text(
//               value,
//               style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: valueColor
//               )
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildSectionTitle(IconData i, String t) { return Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]); }
//   Widget _buildSummaryRow(NumberFormat fmt, String l, int a, Color c, {required bool isBold}) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))]); }
//   Widget _buildRiskLegend(Color color, String label, bool isActive) { return Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]); }
//   Widget _infoTile(WidgetRef ref, String label, String value) { return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))]))); }
//   Widget _buildLegend(Color c, String l, {bool isDash = false}) { return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: isDash ? 2 : 8, decoration: BoxDecoration(color: c, shape: isDash ? BoxShape.rectangle : BoxShape.circle)), const SizedBox(width: 6), Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))]); }
//   void _openPaywall(BuildContext c) { Navigator.of(c).push(MaterialPageRoute(builder: (context) { return const PaywallScreen(); })); }
//
//   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
//     try {
//       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
//   // 📍 [핵심 로직 수정] balance를 외부에서 전달받아(누적 잔액) 처리하도록 수정
//   _RiskSummary _computeRiskSummary({
//     required int thisMonthIncome,
//     required int thisMonthExpense,
//     required int lastMonthExpense,
//     required int overdueCount,
//     required int totalOverdueAmount,
//     required int balance, // 📍 누적 잔액 인자 추가
//     required List<FinancialInsight> insights
//   }) {
//     int s = 0;
//     if (overdueCount > 0) s += 20; // 미납 존재 시 위험도 상승
//     if (balance < 0) s += 40;      // 전체 누적 자산이 적자일 때 대폭 상승
//     if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
//
//     return _RiskSummary(
//         score: s.clamp(0, 100),
//         balance: balance, // 📍 누적 잔액 저장
//         overdueCount: overdueCount
//     );
//   }
// }
//
// class _RiskSummary { final int score; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.balance, required this.overdueCount}); }

//
//
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:drift/drift.dart' hide Column; // 📍 핵심: drift의 Column을 숨겨서 UI용 Column과 충돌 방지
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sire/features/reports/reports_provider.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/state/purchase_provider.dart';
// import '../../core/purchase/ui/paywall_screen.dart';
// import '../../core/database/database_provider.dart';
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
// import 'financial_insight_service.dart';
//
// // 📍 [수정] 스크롤 상태 감지 및 연도 변경을 위해 ConsumerStatefulWidget으로 전환
// class ReportsScreen extends ConsumerStatefulWidget {
//   const ReportsScreen({super.key});
//
//   @override
//   ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
// }
//
// class _ReportsScreenState extends ConsumerState<ReportsScreen> {
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   // 📍 스크롤 상태 관리를 위한 컨트롤러
//   late ScrollController _chartScrollController;
//   bool _canScrollLeft = true;
//   bool _canScrollRight = false;
//
//   // 📍 [신규] 현재 보고 있는 연도 상태 (기본값: 현재 연도)
//   int _selectedYear = DateTime.now().year;
//
//   @override
//   void initState() {
//     super.initState();
//     _chartScrollController = ScrollController();
//     _chartScrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _chartScrollController.removeListener(_scrollListener);
//     _chartScrollController.dispose();
//     super.dispose();
//   }
//
//   // 📍 스크롤 위치에 따라 화살표 가시성을 실시간 업데이트 (reverse: true 기준)
//   void _scrollListener() {
//     if (!_chartScrollController.hasClients) {
//       return;
//     }
//
//     final maxScroll = _chartScrollController.position.maxScrollExtent;
//     final currentScroll = _chartScrollController.offset;
//
//     setState(() {
//       // offset 0 = 가장 오른쪽(최신), maxScroll = 가장 왼쪽(과거)
//       _canScrollLeft = currentScroll < maxScroll;
//       _canScrollRight = currentScroll > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         if (Navigator.of(context).canPop()) {
//           Navigator.of(context).popUntil((route) { return route.isFirst || route.settings.name == '/main_screen'; });
//         }
//       }
//     });
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     // 📍 [수정] 선택된 연도에 따라 카테고리 통계를 동적으로 가져옴
//     final categoryStatsAsync = ref.watch(annualCategoryStatisticsProvider(_selectedYear));
//     final unpaidAsync = ref.watch(unpaidListProvider);
//
//     // 📍 [신규] 재무 위험도를 위한 전체 기간 누적 잔액 구독
//     final totalBalanceAsync = ref.watch(totalCumulativeBalanceProvider);
//
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     final currencyFmt =
//     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         // 📍 [수정] 앱바 타이틀 영역에 연도 선택기 위젯 배치
//         title: Row(
//           children: [
//             Text("NAV_REPORTS".tr(ref),
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const Spacer(),
//             // 📍 Pro 권한이 있을 때만 연도 선택기 노출 (보안 강화)
//             if (isPro) _buildYearSelector(),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
//                 if (!isPro) _buildMainProAnchor(context, ref),
//
//                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
//                 monthlyTrendAsync.when(
//                     loading: () { return const SizedBox.shrink(); },
//                     error: (err, stack) { return const SizedBox.shrink(); },
//                     data: (trendData) {
//                       // 📍 [수정] '재무 분석' 및 '요약표'를 위한 연도별 데이터 필터링
//                       final yearData = trendData.where((e) => e.month.year == _selectedYear).toList();
//
//                       return unpaidAsync.when(
//                           loading: () { return const SizedBox.shrink(); },
//                           error: (err, stack) { return const SizedBox.shrink(); },
//                           data: (unpaidList) {
//                             int inC = 0, exC = 0, lastEx = 0;
//                             final now = DateTime.now();
//
//                             // 📍 이번 달 지출 급증 분석을 위해 선택된 연도의 데이터를 추출
//                             final bool isSelectedCurrentYear = _selectedYear == now.year;
//                             final int targetMonth = isSelectedCurrentYear ? now.month : 12;
//
//                             final thisMonth = yearData
//                                 .where((e) { return e.month.month == targetMonth; })
//                                 .toList();
//                             if (thisMonth.isNotEmpty) {
//                               inC = thisMonth.first.income;
//                               exC = thisMonth.first.expense;
//                             }
//                             final lastMonthData = yearData
//                                 .where((e) { return e.month.month == (targetMonth - 1); })
//                                 .toList();
//                             if (lastMonthData.isNotEmpty) {
//                               lastEx = lastMonthData.first.expense;
//                             }
//
//                             // 📍 [중요 수정] 미납은 연도와 관계없이 '전체 미납(OVERDUE)'을 집계
//                             final overdue = unpaidList
//                                 .where((u) { return u.status == 'OVERDUE'; })
//                                 .toList();
//                             final totalO = overdue.fold(
//                                 0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//
//                             final insights = FinancialInsightService.generate(
//                                 thisMonthIncome: inC,
//                                 thisMonthExpense: exC,
//                                 lastMonthExpense: lastEx,
//                                 overdueCount: overdue.length,
//                                 totalOverdueAmount: totalO);
//
//                             return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _buildSectionTitle(Icons.lightbulb_outline,
//                                       "REPORT_SEC_INSIGHTS".tr(ref)),
//                                   const SizedBox(height: 10),
//                                   if (!isPro)
//                                   // 📍 [수정] 안내 문구 노출 (한 줄 아이콘 + 텍스트)
//                                     _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
//                                   else
//                                   // 📍 [중요 수정] 위험도 지수 카드는 전체 누적 잔액(totalBalanceAsync)을 사용
//                                     totalBalanceAsync.when(
//                                       data: (cumulativeBalance) {
//                                         final risk = _computeRiskSummary(
//                                             thisMonthIncome: inC,
//                                             thisMonthExpense: exC,
//                                             lastMonthExpense: lastEx,
//                                             overdueCount: overdue.length,
//                                             totalOverdueAmount: totalO,
//                                             balance: cumulativeBalance.toInt(), // 📍 누적 잔액 전달
//                                             insights: insights);
//
//                                         return _buildRiskSummaryCard(
//                                             ref, currencyFmt, risk, insights);
//                                       },
//                                       loading: () => const Center(child: CircularProgressIndicator()),
//                                       error: (err, stack) => const SizedBox.shrink(),
//                                     ),
//                                   const SizedBox(height: 20),
//                                 ]);
//                           });
//                     }),
//
//                 // ✅ [복구] 재무 분석
//                 _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildFinancialAnalytics(context, ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.table_chart_outlined,"REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),
//
//                 const SizedBox(height: 40),
//                 const Divider(thickness: 1.5), // 분석 영역과 도구 영역 구분을 위한 구분선
//                 const SizedBox(height: 20),
//
//                 _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildTaxSection(context, ref, isPro),
//
//                 const SizedBox(height: 30),
//                 _buildSectionTitle(Icons.notification_important_outlined,"REPORT_SEC_UNPAID".tr(ref)),
//                 const SizedBox(height: 10),
//                 _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),
//
//               ],
//             ),
//           ),
//
//           // 📍 캡처 전용 위젯 (원본 주석 및 구조 유지)
//           Transform.translate(
//             offset: const Offset(-5000, -5000),
//             child: RepaintBoundary(
//               key: _unpaidCaptureKey,
//               child: Container(
//                 width: 450,
//                 padding: const EdgeInsets.all(30),
//                 color: Colors.white,
//                 child: unpaidAsync.when(
//                   data: (list) {
//                     final overdue =
//                     list.where((u) { return u.status == 'OVERDUE'; }).toList();
//                     final total = overdue.fold(
//                         0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
//                             style: const TextStyle(
//                                 color: Color(0xFF1A237E),
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold)),
//                         const Divider(color: Color(0xFF1A237E), thickness: 3),
//                         const SizedBox(height: 20),
//                         Text(
//                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
//                             style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w900)),
//                         const SizedBox(height: 30),
//                         ...overdue
//                             .map((u) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 15),
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                                 color: Colors.grey[50],
//                                 border:
//                                 Border.all(color: Colors.grey[300]!),
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Column(children: [
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                     Text(
//                                         currencyFmt
//                                             .format(u.unit.monthlyRent),
//                                         style: const TextStyle(
//                                             color: Color(0xFF1A237E),
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18)),
//                                   ]),
//                               const SizedBox(height: 10),
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(u.unit.tenantPhone ?? '-',
//                                         style: const TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 14)),
//                                     Text(
//                                         "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
//                                         style: const TextStyle(
//                                             color: Colors.redAccent,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold)),
//                                   ]),
//                             ]),
//                           );
//                         })
//                             .toList(),
//                         const SizedBox(height: 30),
//                         const Center(
//                             child: Text("Generated by SiRE Asset Management",
//                                 style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 12,
//                                     letterSpacing: 1.5))),
//                       ],
//                     );
//                   },
//                   loading: () { return const SizedBox.shrink(); },
//                   error: (err, stack) { return const SizedBox.shrink(); },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 📍 연도 선택 컨트롤러 위젯 ---
//   Widget _buildYearSelector() {
//     final now = DateTime.now();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () { setState(() { _selectedYear--; }); },
//             child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               "$_selectedYear",
//               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           GestureDetector(
//             onTap: _selectedYear < now.year ? () { setState(() { _selectedYear++; }); } : null,
//             child: Icon(
//                 Icons.chevron_right,
//                 color: _selectedYear < now.year ? Colors.white : Colors.white24,
//                 size: 24
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- 헬퍼 메서드 영역 ---
//
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     final trialCount = ref.watch(trialCountProvider);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref),
//                   style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () { _openPaywall(context); },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A237E),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: trialCount > 0 ? () { ref.read(purchaseControllerProvider.notifier).startTrial(); } : null,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
//                 foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: Text(
//                 trialCount > 0 ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})" : "PROP_TRIAL_EXPIRED".tr(ref),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 📍 [수정] 아이콘과 텍스트를 한 줄(Row)에 배치하는 잠금 카드
//   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
//           const SizedBox(width: 10),
//           Flexible(
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFinancialAnalytics(BuildContext context, WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//     if (!isPro) {
//       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
//     }
//
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: monthlyTrend.when(
//           loading: () { return const Center(child: CircularProgressIndicator()); },
//           error: (err, stack) { return const SizedBox.shrink(); },
//           data: (trendData) {
//             // 📍 원본 그래프 유지를 위해 yearData 필터링 및 너비 계산 로직 보존
//             final yearData = (trendData as List).where((e) => e.month.year == _selectedYear).toList();
//
//             if (yearData.isEmpty) {
//               return const Center(child: Text("해당 연도에 데이터가 없습니다."));
//             }
//
//             double maxY = yearData.map((e) => e.income > e.expense ? e.income.toDouble() : e.expense.toDouble()).reduce((a, b) => a > b ? a : b);
//             maxY = maxY > 0 ? maxY * 1.3 : 1000000;
//             double avgIn = yearData.fold(0, (sum, e) => (sum + e.income).toInt()) / yearData.length;
//
//             final double screenWidth = MediaQuery.of(context).size.width;
//             final double chartAvailableWidth = (screenWidth - 64) * 0.61;
//             final double barGroupWidth = chartAvailableWidth / 6;
//
//             final List<BarChartGroupData> barGroups = yearData.asMap().entries.map((e) {
//               final bool isSpike = e.value.expense > (avgIn * 0.4);
//               return BarChartGroupData(
//                   x: e.key,
//                   barsSpace: 2,
//                   barRods: [
//                     BarChartRodData(toY: e.value.income.toDouble(), color: const Color(0xFF42A5F5), width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                     BarChartRodData(toY: e.value.expense.toDouble(), color: isSpike ? Colors.redAccent.shade700 : Colors.redAccent.shade100, width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
//                   ]);
//             }).toList();
//
//             return Column(children: [
//               Expanded(
//                 child: Row(children: [
//                   Expanded(
//                     flex: 6,
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 25),
//                       Expanded(
//                         child: Stack(
//                           children: [
//                             SingleChildScrollView(
//                               controller: _chartScrollController,
//                               scrollDirection: Axis.horizontal,
//                               reverse: true,
//                               child: Container(
//                                 width: barGroupWidth * yearData.length,
//                                 padding: const EdgeInsets.only(right: 15),
//                                 child: BarChart(BarChartData(
//                                   maxY: maxY,
//                                   barTouchData: BarTouchData(
//                                     enabled: true,
//                                     touchTooltipData: BarTouchTooltipData(
//                                       tooltipBgColor: const Color(0xFF1A237E),
//                                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                                         return BarTooltipItem("${rodIndex == 0 ? 'IN' : 'EX'}\n${fmt.format(rod.toY)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
//                                       },
//                                     ),
//                                   ),
//                                   extraLinesData: ExtraLinesData(horizontalLines: [
//                                     HorizontalLine(
//                                       y: avgIn,
//                                       color: Colors.orange.shade300,
//                                       strokeWidth: 1.5,
//                                       dashArray: [4, 4],
//                                     )
//                                   ]),
//                                   gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
//                                   borderData: FlBorderData(show: false),
//                                   titlesData: FlTitlesData(
//                                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
//                                       int i = v.toInt();
//                                       if (i >= 0 && i < yearData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(yearData[i].month), style: const TextStyle(fontSize: 8, color: Colors.grey)));
//                                       return const Text('');
//                                     })),
//                                   ),
//                                   barGroups: barGroups,
//                                 )),
//                               ),
//                             ),
//                             Positioned.fill(
//                               child: IgnorePointer(
//                                 child: LayoutBuilder(builder: (context, constraints) {
//                                   final double labelBottom = (constraints.maxHeight - 20) * (avgIn / maxY) + 12;
//                                   return Stack(
//                                     children: [
//                                       Positioned(
//                                         left: 0, right: 0,
//                                         bottom: labelBottom,
//                                         child: Center(
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.7),
//                                               borderRadius: BorderRadius.circular(6),
//                                               border: Border.all(color: Colors.orange.shade300, width: 1.2),
//                                             ),
//                                             child: FittedBox(
//                                               fit: BoxFit.scaleDown,
//                                               child: Text(
//                                                 "REPORT_AVG_INCOME".tr(ref),
//                                                 style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade800, fontWeight: FontWeight.normal),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }),
//                               ),
//                             ),
//                             if (_canScrollLeft)
//                               Positioned(left: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_left, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                             if (_canScrollRight)
//                               Positioned(right: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_right, color: Colors.indigo.withOpacity(0.4), size: 24)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Center(child: Text("⟷ Swipe to view history ⟷", style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.5))),
//                     ]),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 4,
//                     child: categoryStats.when(
//                       loading: () { return const SizedBox.shrink(); },
//                       error: (err, stack) { return const SizedBox.shrink(); },
//                       data: (sData) {
//                         final colors = [const Color(0xFF1A237E), const Color(0xFF3F51B5), const Color(0xFF7986CB), const Color(0xFFC5CAE9), Colors.blueGrey];
//                         return Column(children: [
//                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 15),
//                           SizedBox(height: 100, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 15, sections: (sData as List).asMap().entries.map<PieChartSectionData>((e) { return PieChartSectionData(value: e.value.amount.toDouble(), color: colors[e.key % colors.length], radius: 40, title: ''); }).toList()))),
//                           const SizedBox(height: 15),
//                           Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((e) { return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)), const SizedBox(width: 5), Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(e.value.category.toString().startsWith('CAT_') ? e.value.category.toString().tr(ref) : e.value.category.toString(), style: const TextStyle(fontSize: 9)))), const SizedBox(width: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(fmt.format(e.value.amount), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))])); }).toList()))),
//                         ]);
//                       },
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//                     _buildLegend(const Color(0xFF42A5F5), "COMMON_INCOME".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade100, "COMMON_EXPENSE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.redAccent.shade700, "INSIGHT_LABEL_SPIKE".tr(ref)),
//                     const SizedBox(width: 15),
//                     _buildLegend(Colors.orange.shade300, "REPORT_AVG_INCOME".tr(ref), isDash: true),
//                   ]),
//                 ),
//               )
//             ]);
//           }),
//     );
//   }
//
//   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
//     const Color mainIndigo = Color(0xFF1A237E);
//     return Container(
//       width: double.infinity, padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]), Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18))]),
//         const SizedBox(height: 16),
//         ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: Colors.red)), if (risk.balance < 0) Expanded(flex: 35, child: Container(color: Colors.orange)), Expanded(flex: 45, child: Container(color: Colors.grey[200]!))]))),
//         const SizedBox(height: 12),
//         Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [_buildRiskLegend(Colors.red, "ALERT_OVERDUE_TITLE".tr(ref), risk.overdueCount > 0), _buildRiskLegend(Colors.orange, "INSIGHT_LABEL_DEFICIT".tr(ref), risk.balance < 0), _buildRiskLegend(Colors.grey, "INSIGHT_LABEL_SAFE".tr(ref), risk.overdueCount == 0 && risk.balance >= 0)] ) ),
//         const SizedBox(height: 20),
//         Row(children: [_infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)), const SizedBox(width: 10), _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건")]),
//         const SizedBox(height: 12),
//         const Divider(),
//         ...insights.map((insight) { String msg = insight.messageKey.tr(ref); insight.arguments?.forEach((k, v) { msg = msg.replaceAll('{$k}', v); }); return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))])); }).toList(),
//       ]),
//     );
//   }
//
//   Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_TAX".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: $_selectedYear.01.01 - ${DateFormat('yyyy.MM.dd').format(_selectedYear == DateTime.now().year ? DateTime.now() : DateTime(_selectedYear, 12, 31))}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
//       const SizedBox(height: 20),
//       SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//           onPressed: () async {
//             final db = ref.read(databaseProvider);
//             final txs = await (db.select(db.transactions)..where((t) { return t.transactionDate.isBetweenValues(DateTime(_selectedYear, 1, 1), DateTime(_selectedYear, 12, 31, 23, 59, 59)); })).get();
//             if (txs.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("NO_DATA_FOR_YEAR".tr(ref)))); return; }
//             await ExcelExportService().exportTransactionsToExcel(txs, ref);
//           },
//           icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))
//     ]));
//   }
//
//   Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_UNPAID".tr(ref)); }
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
//       unpaidAsync.when(loading: () { return const Center(child: CircularProgressIndicator()); }, error: (err, stack) { return const SizedBox(); }, data: (list) {
//         // 📍 [중요 수정] 미납 정보 노출 시 전체 기간의 미납을 보여줌
//         final overdue = list.where((u) { return u.status == 'OVERDUE'; }).toList();
//         final total = overdue.fold(0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
//         if (overdue.isEmpty) { return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); }
//         return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) { return Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)); })]));
//       }),
//       const SizedBox(height: 20),
//       Row(children: [
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
//         const SizedBox(width: 10),
//         Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
//       ])
//     ]));
//   }
//
//   Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
//     if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }
//
//     // 📍 1번/3번 데이터 구독
//     final receiptCompletionAsync = ref.watch(annualReceiptCompletionProvider(_selectedYear));
//     final profitMarginAsync = ref.watch(annualProfitMarginProvider(_selectedYear));
//
//     return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
//       final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
//       int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
//       int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
//       int netProfit = inc - exp;
//
//       return Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
//         const SizedBox(height: 10),
//         _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false),
//         const Divider(height: 20),
//         _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false),
//
//         // 📍 [1번 기능] 지출 증빙 완료율 (중간에 배치)
//         receiptCompletionAsync.when(
//           data: (rate) => _buildSubInsightRow("REPORT_RECEIPT_COMPLETION".tr(ref), "${rate.toStringAsFixed(1)}%"),
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//
//         const Divider(height: 20),
//
//         // 📍 [핵심 변경] 연간 순이익 금액을 먼저 표시
//         _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), netProfit, Colors.indigo, isBold: true),
//
//         // 📍 [3번 수정] 순이익률 표시 (증빙 완료율과 동일한 레이아웃으로 변경)
//         profitMarginAsync.when(
//           data: (margin) => _buildSubInsightRow(
//             "REPORT_PROFIT_MARGIN".tr(ref),
//             "${margin.toStringAsFixed(1)}%",
//             valueColor: margin >= 0 ? Colors.indigo : Colors.red, // 수익 상태에 따른 색상 강조
//           ),
//           loading: () => const SizedBox.shrink(),
//           error: (_, __) => const SizedBox.shrink(),
//         ),
//       ]);
//     }));
//   }
//
//   // 📍 [범용 위젯 수정] 라벨과 수치를 양 끝으로 배치하고 색상 옵션을 추가함
//   Widget _buildSubInsightRow(String label, String value, {Color valueColor = Colors.blueGrey}) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
//         children: [
//           Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//           Text(
//               value,
//               style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: valueColor
//               )
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildSectionTitle(IconData i, String t) { return Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]); }
//   Widget _buildSummaryRow(NumberFormat fmt, String l, int a, Color c, {required bool isBold}) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(fmt.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))]); }
//   Widget _buildRiskLegend(Color color, String label, bool isActive) { return Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]); }
//   Widget _infoTile(WidgetRef ref, String label, String value) { return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))]))); }
//   Widget _buildLegend(Color c, String l, {bool isDash = false}) { return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: isDash ? 2 : 8, decoration: BoxDecoration(color: c, shape: isDash ? BoxShape.rectangle : BoxShape.circle)), const SizedBox(width: 6), Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))]); }
//   void _openPaywall(BuildContext c) { Navigator.of(c).push(MaterialPageRoute(builder: (context) { return const PaywallScreen(); })); }
//
//   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
//     try {
//       final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
//   // 📍 [핵심 로직 수정] balance를 외부에서 전달받아(누적 잔액) 처리하도록 수정
//   _RiskSummary _computeRiskSummary({
//     required int thisMonthIncome,
//     required int thisMonthExpense,
//     required int lastMonthExpense,
//     required int overdueCount,
//     required int totalOverdueAmount,
//     required int balance, // 📍 누적 잔액 인자 추가
//     required List<FinancialInsight> insights
//   }) {
//     int s = 0;
//     if (overdueCount > 0) s += 20; // 미납 존재 시 위험도 상승
//     if (balance < 0) s += 40;      // 전체 누적 자산이 적자일 때 대폭 상승
//     if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;
//
//     return _RiskSummary(
//         score: s.clamp(0, 100),
//         balance: balance, // 📍 누적 잔액 저장
//         overdueCount: overdueCount
//     );
//   }
// }
//
// class _RiskSummary { final int score; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.balance, required this.overdueCount}); }


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:drift/drift.dart' hide Column; // 📍 핵심: drift의 Column을 숨겨서 UI용 Column과 충돌 방지
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sire/features/reports/reports_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/purchase/state/purchase_provider.dart';
import '../../core/purchase/ui/paywall_screen.dart';
import '../../core/database/database_provider.dart';
import '../ledger/ledger_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'excel_export_service.dart';
import 'financial_insight_service.dart';

// 📍 [수정] 스크롤 상태 감지 및 연도 변경을 위해 ConsumerStatefulWidget으로 전환
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  static final GlobalKey _unpaidCaptureKey = GlobalKey();

  // 📍 스크롤 상태 관리를 위한 컨트롤러
  late ScrollController _chartScrollController;
  bool _canScrollLeft = true;
  bool _canScrollRight = false;

  // 📍 [신규] 현재 보고 있는 연도 상태 (기본값: 현재 연도)
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _chartScrollController = ScrollController();
    _chartScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _chartScrollController.removeListener(_scrollListener);
    _chartScrollController.dispose();
    super.dispose();
  }

  // 📍 스크롤 위치에 따라 화살표 가시성을 실시간 업데이트 (reverse: true 기준)
  void _scrollListener() {
    if (!_chartScrollController.hasClients) {
      return;
    }

    final maxScroll = _chartScrollController.position.maxScrollExtent;
    final currentScroll = _chartScrollController.offset;

    setState(() {
      // offset 0 = 가장 오른쪽(최신), maxScroll = 가장 왼쪽(과거)
      _canScrollLeft = currentScroll < maxScroll;
      _canScrollRight = currentScroll > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
    final isPro = ref.watch(isProProvider);

    // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
    ref.listen<bool>(isProProvider, (previous, next) {
      if (previous == false && next == true) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) { return route.isFirst || route.settings.name == '/main_screen'; });
        }
      }
    });

    final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
    // 📍 [수정] 선택된 연도에 따라 카테고리 통계를 동적으로 가져옴
    final categoryStatsAsync = ref.watch(annualCategoryStatisticsProvider(_selectedYear));
    final unpaidAsync = ref.watch(unpaidListProvider);

    // 📍 [신규] 재무 위험도를 위한 전체 기간 누적 잔액 구독
    final totalBalanceAsync = ref.watch(totalCumulativeBalanceProvider);

    final lang = ref.watch(localizationProvider.notifier).currentLang;
    final currencyFmt =
    NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        // 📍 [수정] 앱바 타이틀 영역에 연도 선택기 위젯 배치
        title: Row(
          children: [
            Text("NAV_REPORTS".tr(ref),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            // 📍 Pro 권한이 있을 때만 연도 선택기 노출 (보안 강화)
            if (isPro) _buildYearSelector(),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
                if (!isPro) _buildMainProAnchor(context, ref),

                // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
                monthlyTrendAsync.when(
                    loading: () { return const SizedBox.shrink(); },
                    error: (err, stack) { return const SizedBox.shrink(); },
                    data: (trendData) {
                      // 📍 [수정] '재무 분석' 및 '요약표'를 위한 연도별 데이터 필터링
                      final yearData = trendData.where((e) => e.month.year == _selectedYear).toList();

                      return unpaidAsync.when(
                          loading: () { return const SizedBox.shrink(); },
                          error: (err, stack) { return const SizedBox.shrink(); },
                          data: (unpaidList) {
                            int inC = 0, exC = 0, lastEx = 0;
                            final now = DateTime.now();

                            // 📍 이번 달 지출 급증 분석을 위해 선택된 연도의 데이터를 추출
                            final bool isSelectedCurrentYear = _selectedYear == now.year;
                            final int targetMonth = isSelectedCurrentYear ? now.month : 12;

                            final thisMonth = yearData
                                .where((e) { return e.month.month == targetMonth; })
                                .toList();
                            if (thisMonth.isNotEmpty) {
                              inC = thisMonth.first.income;
                              exC = thisMonth.first.expense;
                            }
                            final lastMonthData = yearData
                                .where((e) { return e.month.month == (targetMonth - 1); })
                                .toList();
                            if (lastMonthData.isNotEmpty) {
                              lastEx = lastMonthData.first.expense;
                            }

                            // 📍 [중요 수정] 미납은 연도와 관계없이 '전체 미납(OVERDUE)'을 집계
                            final overdue = unpaidList
                                .where((u) { return u.status == 'OVERDUE'; })
                                .toList();
                            final totalO = overdue.fold(
                                0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });

                            final insights = FinancialInsightService.generate(
                                thisMonthIncome: inC,
                                thisMonthExpense: exC,
                                lastMonthExpense: lastEx,
                                overdueCount: overdue.length,
                                totalOverdueAmount: totalO);

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(Icons.lightbulb_outline,
                                      "REPORT_SEC_INSIGHTS".tr(ref)),
                                  const SizedBox(height: 10),
                                  if (!isPro)
                                  // 📍 [수정] 안내 문구 노출 (한 줄 아이콘 + 텍스트)
                                    _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
                                  else
                                  // 📍 [중요 수정] 위험도 지수 카드는 전체 누적 잔액(totalBalanceAsync)을 사용
                                    totalBalanceAsync.when(
                                      data: (cumulativeBalance) {
                                        final risk = _computeRiskSummary(
                                            thisMonthIncome: inC,
                                            thisMonthExpense: exC,
                                            lastMonthExpense: lastEx,
                                            overdueCount: overdue.length,
                                            totalOverdueAmount: totalO,
                                            balance: cumulativeBalance.toInt(), // 📍 누적 잔액 전달
                                            insights: insights);

                                        return _buildRiskSummaryCard(
                                            ref, currencyFmt, risk, insights);
                                      },
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                      error: (err, stack) => const SizedBox.shrink(),
                                    ),
                                  const SizedBox(height: 20),
                                ]);
                          });
                    }),

                // ✅ [복구] 재무 분석
                _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
                const SizedBox(height: 10),
                _buildFinancialAnalytics(context, ref, monthlyTrendAsync, categoryStatsAsync, currencyFmt, lang, isPro),

                const SizedBox(height: 30),
                _buildSectionTitle(Icons.table_chart_outlined,"REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
                const SizedBox(height: 10),
                _buildAnnualSummary(context, ref, monthlyTrendAsync, currencyFmt, isPro),

                const SizedBox(height: 40),
                const Divider(thickness: 1.5), // 분석 영역과 도구 영역 구분을 위한 구분선
                const SizedBox(height: 20),

                _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
                const SizedBox(height: 10),
                _buildTaxSection(context, ref, isPro),

                const SizedBox(height: 30),
                _buildSectionTitle(Icons.notification_important_outlined,"REPORT_SEC_UNPAID".tr(ref)),
                const SizedBox(height: 10),
                _buildUnpaidSection(context, ref, unpaidAsync, currencyFmt, isPro),

              ],
            ),
          ),

          // 📍 캡처 전용 위젯 (원본 주석 및 구조 유지)
          Transform.translate(
            offset: const Offset(-5000, -5000),
            child: RepaintBoundary(
              key: _unpaidCaptureKey,
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(30),
                color: Colors.white,
                child: unpaidAsync.when(
                  data: (list) {
                    final overdue =
                    list.where((u) { return u.status == 'OVERDUE'; }).toList();
                    final total = overdue.fold(
                        0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
                            style: const TextStyle(
                                color: Color(0xFF1A237E),
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const Divider(color: Color(0xFF1A237E), thickness: 3),
                        const SizedBox(height: 20),
                        Text(
                            "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 30),
                        ...overdue
                            .map((u) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border:
                                Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    Text(
                                        currencyFmt
                                            .format(u.unit.monthlyRent),
                                        style: const TextStyle(
                                            color: Color(0xFF1A237E),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ]),
                              const SizedBox(height: 10),
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(u.unit.tenantPhone ?? '-',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14)),
                                    Text(
                                        "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
                                        style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                            ]),
                          );
                        })
                            .toList(),
                        const SizedBox(height: 30),
                        const Center(
                            child: Text("Generated by SiRE Asset Management",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    letterSpacing: 1.5))),
                      ],
                    );
                  },
                  loading: () { return const SizedBox.shrink(); },
                  error: (err, stack) { return const SizedBox.shrink(); },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 📍 연도 선택 컨트롤러 위젯 ---
  Widget _buildYearSelector() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () { setState(() { _selectedYear--; }); },
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "$_selectedYear",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: _selectedYear < now.year ? () { setState(() { _selectedYear++; }); } : null,
            child: Icon(
                Icons.chevron_right,
                color: _selectedYear < now.year ? Colors.white : Colors.white24,
                size: 24
            ),
          ),
        ],
      ),
    );
  }

  // --- 헬퍼 메서드 영역 ---

  Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
    final trialCount = ref.watch(trialCountProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "REPORT_MAIN_PRO_TEXT".tr(ref),
                  style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { _openPaywall(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: trialCount > 0 ? () { ref.read(purchaseControllerProvider.notifier).startTrial(); } : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
                foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                trialCount > 0 ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})" : "PROP_TRIAL_EXPIRED".tr(ref),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📍 [수정] 아이콘과 텍스트를 한 줄(Row)에 배치하는 잠금 카드
  Widget _buildSimpleLockCard(WidgetRef ref, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialAnalytics(BuildContext context, WidgetRef ref, AsyncValue monthlyTrend, AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
    if (!isPro) {
      return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: monthlyTrend.when(
          loading: () { return const Center(child: CircularProgressIndicator()); },
          error: (err, stack) { return const SizedBox.shrink(); },
          data: (trendData) {
            // 📍 원본 그래프 유지를 위해 yearData 필터링 및 너비 계산 로직 보존
            final yearData = (trendData as List).where((e) => e.month.year == _selectedYear).toList();

            if (yearData.isEmpty) {
              return const Center(child: Text("해당 연도에 데이터가 없습니다."));
            }

            double maxY = yearData.map((e) => e.income > e.expense ? e.income.toDouble() : e.expense.toDouble()).reduce((a, b) => a > b ? a : b);
            maxY = maxY > 0 ? maxY * 1.3 : 1000000;
            double avgIn = yearData.fold(0, (sum, e) => (sum + e.income).toInt()) / yearData.length;

            final double screenWidth = MediaQuery.of(context).size.width;
            final double chartAvailableWidth = (screenWidth - 64) * 0.61;
            final double barGroupWidth = chartAvailableWidth / 6;

            final List<BarChartGroupData> barGroups = yearData.asMap().entries.map((e) {
              final bool isSpike = e.value.expense > (avgIn * 0.4);
              return BarChartGroupData(
                  x: e.key,
                  barsSpace: 2,
                  barRods: [
                    BarChartRodData(toY: e.value.income.toDouble(), color: const Color(0xFF42A5F5), width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                    BarChartRodData(toY: e.value.expense.toDouble(), color: isSpike ? Colors.redAccent.shade700 : Colors.redAccent.shade100, width: 7, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                  ]);
            }).toList();

            return Column(children: [
              Expanded(
                child: Row(children: [
                  Expanded(
                    flex: 6,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25),
                      Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              controller: _chartScrollController,
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Container(
                                width: barGroupWidth * yearData.length,
                                padding: const EdgeInsets.only(right: 15),
                                child: BarChart(BarChartData(
                                  maxY: maxY,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: const Color(0xFF1A237E),
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem("${rodIndex == 0 ? 'IN' : 'EX'}\n${fmt.format(rod.toY)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
                                      },
                                    ),
                                  ),
                                  extraLinesData: ExtraLinesData(horizontalLines: [
                                    HorizontalLine(
                                      y: avgIn,
                                      color: Colors.orange.shade300,
                                      strokeWidth: 1.5,
                                      dashArray: [4, 4],
                                    )
                                  ]),
                                  gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (v) { return FlLine(color: Colors.grey.withOpacity(0.05), strokeWidth: 1); }),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                                      int i = v.toInt();
                                      if (i >= 0 && i < yearData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat.MMM(lang).format(yearData[i].month), style: const TextStyle(fontSize: 8, color: Colors.grey)));
                                      return const Text('');
                                    })),
                                  ),
                                  barGroups: barGroups,
                                )),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: LayoutBuilder(builder: (context, constraints) {
                                  final double labelBottom = (constraints.maxHeight - 20) * (avgIn / maxY) + 12;
                                  return Stack(
                                    children: [
                                      Positioned(
                                        left: 0, right: 0,
                                        bottom: labelBottom,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.orange.shade300, width: 1.2),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                "REPORT_AVG_INCOME".tr(ref),
                                                style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade800, fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            if (_canScrollLeft)
                              Positioned(left: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_left, color: Colors.indigo.withOpacity(0.4), size: 24)),
                            if (_canScrollRight)
                              Positioned(right: -5, top: 0, bottom: 0, child: Icon(Icons.chevron_right, color: Colors.indigo.withOpacity(0.4), size: 24)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(child: Text("⟷ Swipe to view history ⟷", style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.5))),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: categoryStats.when(
                      loading: () { return const SizedBox.shrink(); },
                      error: (err, stack) { return const SizedBox.shrink(); },
                      data: (sData) {
                        final colors = [const Color(0xFF1A237E), const Color(0xFF3F51B5), const Color(0xFF7986CB), const Color(0xFFC5CAE9), Colors.blueGrey];
                        return Column(children: [
                          Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          SizedBox(height: 100, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 15, sections: (sData as List).asMap().entries.map<PieChartSectionData>((e) { return PieChartSectionData(value: e.value.amount.toDouble(), color: colors[e.key % colors.length], radius: 40, title: ''); }).toList()))),
                          const SizedBox(height: 15),
                          Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sData.asMap().entries.map((e) { return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)), const SizedBox(width: 5), Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(e.value.category.toString().startsWith('CAT_') ? e.value.category.toString().tr(ref) : e.value.category.toString(), style: const TextStyle(fontSize: 9)))), const SizedBox(width: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(fmt.format(e.value.amount), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))])); }).toList()))),
                        ]);
                      },
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _buildLegend(const Color(0xFF42A5F5), "COMMON_INCOME".tr(ref)),
                    const SizedBox(width: 15),
                    _buildLegend(Colors.redAccent.shade100, "COMMON_EXPENSE".tr(ref)),
                    const SizedBox(width: 15),
                    _buildLegend(Colors.redAccent.shade700, "INSIGHT_LABEL_SPIKE".tr(ref)),
                    const SizedBox(width: 15),
                    _buildLegend(Colors.orange.shade300, "REPORT_AVG_INCOME".tr(ref), isDash: true),
                  ]),
                ),
              )
            ]);
          }),
    );
  }

  Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt, _RiskSummary risk, List<FinancialInsight> insights) {
    const Color mainIndigo = Color(0xFF1A237E);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.analytics_outlined, color: mainIndigo, size: 22), const SizedBox(width: 10), Text('REPORT_RISK_TITLE'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainIndigo))]), Text("${risk.score}/100", style: const TextStyle(color: mainIndigo, fontWeight: FontWeight.w900, fontSize: 18))]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 14, child: Row(children: [if (risk.overdueCount > 0) Expanded(flex: 20, child: Container(color: Colors.red)), if (risk.balance < 0) Expanded(flex: 35, child: Container(color: Colors.orange)), Expanded(flex: 45, child: Container(color: Colors.grey[200]!))]))),
        const SizedBox(height: 12),
        Center(child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [_buildRiskLegend(Colors.red, "ALERT_OVERDUE_TITLE".tr(ref), risk.overdueCount > 0), _buildRiskLegend(Colors.orange, "INSIGHT_LABEL_DEFICIT".tr(ref), risk.balance < 0), _buildRiskLegend(Colors.grey, "INSIGHT_LABEL_SAFE".tr(ref), risk.overdueCount == 0 && risk.balance >= 0)] ) ),
        const SizedBox(height: 20),
        Row(children: [_infoTile(ref, "COMMON_BALANCE".tr(ref), currencyFmt.format(risk.balance)), const SizedBox(width: 10), _infoTile(ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건")]),
        const SizedBox(height: 12),
        const Divider(),
        ...insights.map((insight) { String msg = insight.messageKey.tr(ref); insight.arguments?.forEach((k, v) { msg = msg.replaceAll('{$k}', v); }); return Padding(padding: const EdgeInsets.only(top: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline, color: mainIndigo, size: 16), const SizedBox(width: 6), Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)))])); }).toList(),
      ]),
    );
  }

  Widget _buildTaxSection(BuildContext context, WidgetRef ref, bool isPro) {
    if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_TAX".tr(ref)); }
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text("${'REPORT_TAX_PERIOD'.tr(ref)}: $_selectedYear.01.01 - ${DateFormat('yyyy.MM.dd').format(_selectedYear == DateTime.now().year ? DateTime.now() : DateTime(_selectedYear, 12, 31))}", style: const TextStyle(fontSize: 13))), const Icon(Icons.calendar_today, size: 20, color: Colors.grey)])),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () async {
            final db = ref.read(databaseProvider);
            final txs = await (db.select(db.transactions)..where((t) { return t.transactionDate.isBetweenValues(DateTime(_selectedYear, 1, 1), DateTime(_selectedYear, 12, 31, 23, 59, 59)); })).get();
            if (txs.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("NO_DATA_FOR_YEAR".tr(ref)))); return; }
            await ExcelExportService().exportTransactionsToExcel(txs, ref);
          },
          icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold))))
    ]));
  }

  Widget _buildUnpaidSection(BuildContext context, WidgetRef ref, AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) {
    if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_UNPAID".tr(ref)); }
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(children: [
      unpaidAsync.when(loading: () { return const Center(child: CircularProgressIndicator()); }, error: (err, stack) { return const SizedBox(); }, data: (list) {
        // 📍 [중요 수정] 미납 정보 노출 시 전체 기간의 미납을 보여줌
        final overdue = list.where((u) { return u.status == 'OVERDUE'; }).toList();
        final total = overdue.fold(0, (sum, item) { return (sum + item.unit.monthlyRent).toInt(); });
        if (overdue.isEmpty) { return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center); }
        return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} / ${'PROP_TOTAL'.tr(ref)}: ${fmt.format(total)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...overdue.take(3).map((u) { return Text("• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12)); })]));
      }),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await ExcelExportService().exportUnpaidListToExcel(unpaidAsync.value ?? [], ref); }, icon: const Icon(Icons.file_download, size: 18), label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { await _captureAndShare(_unpaidCaptureKey, ref); }, icon: const Icon(Icons.share_outlined, size: 18), label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
      ])
    ]));
  }

  Widget _buildAnnualSummary(BuildContext context, WidgetRef ref, AsyncValue t, NumberFormat f, bool isPro) {
    if (!isPro) { return _buildSimpleLockCard(ref, "REPORT_LOCK_ANNUAL".tr(ref)); }

    // 📍 1번/3번 데이터 구독
    final receiptCompletionAsync = ref.watch(annualReceiptCompletionProvider(_selectedYear));
    final profitMarginAsync = ref.watch(annualProfitMarginProvider(_selectedYear));

    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: t.when(loading: () { return const SizedBox(); }, error: (err, stack) { return const SizedBox(); }, data: (trend) {
      final yearData = (trend as List).where((e) { return e.month.year == _selectedYear; }).toList();
      int inc = yearData.fold(0, (sum, e) { return (sum + e.income).toInt(); });
      int exp = yearData.fold(0, (sum, e) { return (sum + e.expense).toInt(); });
      int netProfit = inc - exp;

      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("${'COMMON_YEAR'.tr(ref)}: $_selectedYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 10),

        // 📍 [수정] 클릭 시 수입 상세 내역 바텀 시트 오픈
        InkWell(
          onTap: () => _showTransactionDetailSheet(context, ref, 'INC', _selectedYear, f),
          child: _buildSummaryRow(f, "REPORT_YEARLY_REVENUE".tr(ref), inc, Colors.blue, isBold: false, showArrow: true),
        ),

        const Divider(height: 20),

        // 📍 [수정] 클릭 시 지출 상세 내역 바텀 시트 오픈
        InkWell(
          onTap: () => _showTransactionDetailSheet(context, ref, 'EXP', _selectedYear, f),
          child: _buildSummaryRow(f, "REPORT_YEARLY_EXPENSES".tr(ref), exp, Colors.redAccent, isBold: false, showArrow: true),
        ),

        // 📍 [1번 기능] 지출 증빙 완료율 (중간에 배치)
        receiptCompletionAsync.when(
          data: (rate) => _buildSubInsightRow("REPORT_RECEIPT_COMPLETION".tr(ref), "${rate.toStringAsFixed(1)}%"),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const Divider(height: 20),

        // 📍 [핵심 변경] 연간 순이익 금액을 먼저 표시
        _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(ref), netProfit, Colors.indigo, isBold: true),

        // 📍 [3번 수정] 순이익률 표시 (증빙 완료율과 동일한 레이아웃으로 변경)
        profitMarginAsync.when(
          data: (margin) => _buildSubInsightRow(
            "REPORT_PROFIT_MARGIN".tr(ref),
            "${margin.toStringAsFixed(1)}%",
            valueColor: margin >= 0 ? Colors.indigo : Colors.red, // 수익 상태에 따른 색상 강조
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ]);
    }));
  }

  // 📍 [범용 위젯 수정] 라벨과 수치를 양 끝으로 배치하고 색상 옵션을 추가함
  Widget _buildSubInsightRow(String label, String value, {Color valueColor = Colors.blueGrey}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(
              value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: valueColor
              )
          ),
        ],
      ),
    );
  }


  Widget _buildSectionTitle(IconData i, String t) { return Row(children: [Icon(i, color: const Color(0xFF1A237E)), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]); }

  // 📍 [수정] 클릭 유도를 위해 화살표(showArrow) 옵션 추가
  Widget _buildSummaryRow(NumberFormat fmt, String l, int a, Color c, {required bool isBold, bool showArrow = false}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(l, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
              if (showArrow) const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
          Text(fmt.format(a), style: TextStyle(fontWeight: FontWeight.bold, color: c))
        ]
    );
  }

  Widget _buildRiskLegend(Color color, String label, bool isActive) { return Row(mainAxisSize: MainAxisSize.min, children: [Opacity(opacity: isActive ? 1.0 : 0.2, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey[500]))]); }
  Widget _infoTile(WidgetRef ref, String label, String value) { return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)))]))); }
  Widget _buildLegend(Color c, String l, {bool isDash = false}) { return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: isDash ? 2 : 8, decoration: BoxDecoration(color: c, shape: isDash ? BoxShape.rectangle : BoxShape.circle)), const SizedBox(width: 6), Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))]); }
  void _openPaywall(BuildContext c) { Navigator.of(c).push(MaterialPageRoute(builder: (context) { return const PaywallScreen(); })); }

  Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
    try {
      final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(path)], text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
    } catch (e) { debugPrint("Capture Error: $e"); }
  }

  // 📍 [핵심 로직 수정] balance를 외부에서 전달받아(누적 잔액) 처리하도록 수정
  _RiskSummary _computeRiskSummary({
    required int thisMonthIncome,
    required int thisMonthExpense,
    required int lastMonthExpense,
    required int overdueCount,
    required int totalOverdueAmount,
    required int balance, // 📍 누적 잔액 인자 추가
    required List<FinancialInsight> insights
  }) {
    int s = 0;
    if (overdueCount > 0) s += 20; // 미납 존재 시 위험도 상승
    if (balance < 0) s += 40;      // 전체 누적 자산이 적자일 때 대폭 상승
    if (insights.any((i) => i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'))) s += 25;

    return _RiskSummary(
        score: s.clamp(0, 100),
        balance: balance, // 📍 누적 잔액 저장
        overdueCount: overdueCount
    );
  }

// 📍 [최종 최적화] 연간 상세 내역 바텀 시트 (금액 영역 확장 및 증빙 완벽 판별)
//   void _showTransactionDetailSheet(BuildContext context, WidgetRef ref, String type, int year, NumberFormat fmt) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         builder: (_, scrollController) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 width: 40, height: 4,
//                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       type == 'INC' ? "REPORT_YEARLY_REVENUE".tr(ref) : "REPORT_YEARLY_EXPENSES".tr(ref),
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
//                     ),
//                     Text("$year${"COMMON_YEAR".tr(ref)}", style: const TextStyle(fontSize: 14, color: Colors.indigo)),
//                   ],
//                 ),
//               ),
//               // 📍 헤더: 금액 영역 너비를 110으로 확장하여 잘림 방지
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 color: Colors.grey[50],
//                 child: Row(
//                   children: [
//                     SizedBox(width: 45, child: Text("날짜", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold))),
//                     Expanded(child: Text("항목 | 카테고리", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold))),
//                     if (type == 'EXP') SizedBox(width: 35, child: Center(child: Text("증빙", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)))),
//                     SizedBox(width: 110, child: Text("금액", textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold))),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: FutureBuilder<List<Transaction>>(
//                   future: ref.read(databaseProvider).select(ref.read(databaseProvider).transactions).get().then(
//                           (list) => list.where((t) => t.type == type && t.transactionDate.year == year).toList()
//                         ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate))
//                   ),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//                     final data = snapshot.data!;
//                     if (data.isEmpty) return Center(child: Text("COMMON_NO_DATA".tr(ref)));
//
//                     Map<int, List<Transaction>> groupedData = {};
//                     for (var item in data) {
//                       groupedData.putIfAbsent(item.transactionDate.month, () => []).add(item);
//                     }
//                     var sortedMonths = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));
//
//                     return ListView.builder(
//                       controller: scrollController,
//                       padding: const EdgeInsets.only(bottom: 30),
//                       itemCount: sortedMonths.length,
//                       itemBuilder: (context, mIndex) {
//                         int month = sortedMonths[mIndex];
//                         List<Transaction> items = groupedData[month]!;
//
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                               color: Colors.indigo.withOpacity(0.05),
//                               child: Text("$month월", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
//                             ),
//                             ...items.map((item) {
//                               final dateStr = DateFormat('dd').format(item.transactionDate);
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                                 decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
//                                 child: Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 45,
//                                       child: Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
//                                     ),
//                                     Expanded(
//                                       child: RichText(
//                                         overflow: TextOverflow.ellipsis,
//                                         text: TextSpan(
//                                           style: const TextStyle(fontSize: 14, color: Colors.black),
//                                           children: [
//                                             TextSpan(text: type == 'INC' ? (item.unitId != null ? "${item.unitId}호" : item.memo ?? '-') : (item.memo ?? "COMMON_EXPENSE".tr(ref))),
//                                             TextSpan(text: " | ", style: TextStyle(color: Colors.grey[300])),
//                                             TextSpan(
//                                               text: item.category?.toString().startsWith('CAT_') == true ? item.category!.tr(ref) : (item.category ?? '-'),
//                                               style: const TextStyle(color: Colors.indigo, fontSize: 13),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     // 📍 증빙 아이콘: DB 조회를 통해 실시간 존재 여부 판별 (EXP 타입만)
//                                     if (type == 'EXP')
//                                       SizedBox(
//                                         width: 35,
//                                         child: Center(
//                                           child: FutureBuilder<bool>(
//                                             // 단일 경로가 있거나, 다중 이미지 테이블에 데이터가 있는지 확인
//                                             future: Future.sync(() async {
//                                               if (item.receiptImagePath != null && item.receiptImagePath!.isNotEmpty) return true;
//                                               final db = ref.read(databaseProvider);
//                                               final image = await (db.select(db.transactionImages)
//                                                 ..where((t) => t.transactionId.equals(item.id))
//                                                 ..limit(1)).getSingleOrNull();
//                                               return image != null;
//                                             }),
//                                             builder: (context, imgSnapshot) {
//                                               final hasImg = imgSnapshot.data ?? false;
//                                               return Icon(
//                                                   Icons.image_outlined,
//                                                   size: 16,
//                                                   color: hasImg ? Colors.orange : Colors.grey[200]
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     // 📍 금액: 너비를 110으로 늘려 큰 금액도 한 줄에 표시
//                                     SizedBox(
//                                       width: 110,
//                                       child: Text(
//                                         fmt.format(item.amount),
//                                         textAlign: TextAlign.right,
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w400,
//                                             color: type == 'INC' ? Colors.blue[800] : Colors.red[800]
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
// // 📍 [수정] 수입/지출 모두 증빙 항목을 포함하는 월별 탭 상세 내역
//   void _showTransactionDetailSheet(BuildContext context, WidgetRef ref, String type, int year, NumberFormat fmt) async {
//     final db = ref.read(databaseProvider);
//
//     // 1. 해당 연도의 전체 데이터를 가져옴
//     final allTransactions = await (db.select(db.transactions)
//       ..where((t) => t.type.equals(type) & t.transactionDate.isBetweenValues(DateTime(year, 1, 1), DateTime(year, 12, 31, 23, 59, 59)))
//       ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
//         .get();
//
//     if (allTransactions.isEmpty) {
//       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("COMMON_NO_DATA".tr(ref))));
//       return;
//     }
//
//     // 2. 데이터가 있는 월만 추출하여 오름차순 정렬
//     final availableMonths = allTransactions.map((t) => t.transactionDate.month).toSet().toList()..sort((a, b) => a.compareTo(b));
//     final currentMonth = DateTime.now().month;
//     final initialIndex = availableMonths.contains(currentMonth) ? availableMonths.indexOf(currentMonth) : 0;
//
//     if (!context.mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DefaultTabController(
//         length: availableMonths.length,
//         initialIndex: initialIndex,
//         child: DraggableScrollableSheet(
//           initialChildSize: 0.8,
//           maxChildSize: 0.95,
//           minChildSize: 0.5,
//           builder: (_, scrollController) => Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.symmetric(vertical: 12),
//                   width: 40, height: 4,
//                   decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         type == 'INC' ? "REPORT_YEARLY_REVENUE".tr(ref) : "REPORT_YEARLY_EXPENSES".tr(ref),
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
//                       ),
//                       Text("$year${"COMMON_YEAR".tr(ref)}", style: const TextStyle(fontSize: 14, color: Colors.indigo)),
//                     ],
//                   ),
//                 ),
//                 TabBar(
//                   isScrollable: true,
//                   labelColor: const Color(0xFF1A237E),
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: const Color(0xFF1A237E),
//                   tabs: availableMonths.map((m) => Tab(text: "$m월")).toList(),
//                 ),
//                 // 📍 헤더: 수입/지출 공통으로 '증빙' 컬럼 노출
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   color: Colors.grey[50],
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 40, child: Text("일", style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold))),
//                       const Expanded(child: Text("항목 | 카테고리", style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold))),
//                       const SizedBox(width: 40, child: Center(child: Text("증빙", style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)))),
//                       const SizedBox(width: 120, child: Text("금액", textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold))),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     children: availableMonths.map((month) {
//                       final monthItems = allTransactions.where((t) => t.transactionDate.month == month).toList();
//                       return ListView.builder(
//                         controller: scrollController,
//                         padding: const EdgeInsets.only(bottom: 30),
//                         itemCount: monthItems.length,
//                         itemBuilder: (context, index) {
//                           final item = monthItems[index];
//                           final dateStr = DateFormat('dd').format(item.transactionDate);
//                           return Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                             decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
//                             child: Row(
//                               children: [
//                                 SizedBox(width: 40, child: Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500))),
//                                 Expanded(
//                                   child: RichText(
//                                     overflow: TextOverflow.ellipsis,
//                                     text: TextSpan(
//                                       style: const TextStyle(fontSize: 14, color: Colors.black87),
//                                       children: [
//                                         TextSpan(text: type == 'INC' ? (item.unitId != null ? "${item.unitId}호" : item.memo ?? '-') : (item.memo ?? "COMMON_EXPENSE".tr(ref))),
//                                         const TextSpan(text: "  |  ", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w100)),
//                                         TextSpan(
//                                           text: item.category?.toString().startsWith('CAT_') == true ? item.category!.tr(ref) : (item.category ?? '-'),
//                                           style: const TextStyle(color: Colors.indigo, fontSize: 13),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 // 📍 증빙 아이콘: 수입(INC)에서도 실시간 DB 확인 후 주황색 아이콘 표시
//                                 SizedBox(
//                                   width: 40,
//                                   child: Center(
//                                     child: FutureBuilder<bool>(
//                                       future: () async {
//                                         if (item.receiptImagePath != null && item.receiptImagePath!.isNotEmpty) return true;
//                                         final query = db.select(db.transactionImages)..where((t) => t.transactionId.equals(item.id));
//                                         final img = await query.getSingleOrNull();
//                                         return img != null;
//                                       }(),
//                                       builder: (context, snapshot) => Icon(
//                                         Icons.image_outlined,
//                                         size: 18,
//                                         color: (snapshot.data == true) ? Colors.orange : Colors.grey[200],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 120,
//                                   child: Text(
//                                     fmt.format(item.amount),
//                                     textAlign: TextAlign.right,
//                                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: type == 'INC' ? Colors.blue[900] : Colors.red[900]),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }


// 📍 [최종 수정] 텍스트 오버플로우 방지 및 배경 박스가 적용된 다중 이미지 슬라이드 뷰어
  void _showMultiImagePager(BuildContext context, List<String> paths, String title, String category) {
    int currentIndex = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                itemCount: paths.length,
                onPageChanged: (index) => setDialogState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      File(paths[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text("REPORT_IMAGE_LOAD_ERROR".tr(ref), style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),

              // 📍 상단 헤더 영역 (텍스트 축약 로직 포함)
              Positioned(
                top: 40,
                left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // 1. 왼쪽: 페이지 인덱스 (고정 폭 확보)
                      Container(
                        constraints: const BoxConstraints(minWidth: 45),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                            "${currentIndex + 1} / ${paths.length}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 11)
                        ),
                      ),

                      // 2. 중앙: 항목 | 카테고리 (유동적 축약 영역)
                      // 📍 Flexible을 사용하여 공간이 부족하면 자동으로 줄어들게 함
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$title | $category",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            // 📍 텍스트가 영역을 넘어가면 말줄임표(...) 표시
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),

                      // 3. 오른쪽: 닫기 버튼 (고정 영역)
                      IconButton(
                        constraints: const BoxConstraints(maxWidth: 40),
                        icon: const Icon(Icons.close, color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              if (paths.length > 1) ...[
                if (currentIndex > 0)
                  const Positioned(left: 10, child: Icon(Icons.arrow_back_ios, color: Colors.white30, size: 30)),
                if (currentIndex < paths.length - 1)
                  const Positioned(right: 10, child: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 30)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // 📍 [에러 해결]: 모든 이미지를 수집하고 정보를 뷰어에 전달 (인자 5개 완전 동기화)
  void _handleImageTap(BuildContext context, WidgetRef ref, Transaction item, String title, String category) async {
    final db = ref.read(databaseProvider);
    List<String> allPaths = [];

    if (item.receiptImagePath != null && item.receiptImagePath!.isNotEmpty) {
      allPaths.add(item.receiptImagePath!);
    }

    final savedImages = await (db.select(db.transactionImages)
      ..where((t) => t.transactionId.equals(item.id)))
        .get();
    allPaths.addAll(savedImages.map((img) => img.imagePath));

    if (allPaths.isEmpty) return;

    if (context.mounted) {
      // 📍 정의된 인자 구조에 맞춰 호출
      _showMultiImagePager(context, allPaths, title, category);
    }
  }

  // 📍 상세 내역 리스트 내 증빙 아이콘 영역 (인자 전달 에러 해결)
  Widget _buildReceiptIcon(BuildContext context, WidgetRef ref, Transaction item) {
    final db = ref.read(databaseProvider);

    // 뷰어 정보 미리 생성
    final String title = item.type == 'INC'
        ? (item.unitId != null ? "${item.unitId}호" : item.memo ?? '-')
        : (item.memo ?? "COMMON_EXPENSE".tr(ref));

    final String category = item.category?.toString().startsWith('CAT_') == true
        ? item.category!.tr(ref)
        : (item.category ?? '-');

    return SizedBox(
      width: 40,
      child: Center(
        child: FutureBuilder<List<String>>(
          future: () async {
            List<String> paths = [];
            if (item.receiptImagePath != null && item.receiptImagePath!.isNotEmpty) {
              paths.add(item.receiptImagePath!);
            }
            final imgs = await (db.select(db.transactionImages)..where((t) => t.transactionId.equals(item.id))).get();
            paths.addAll(imgs.map((i) => i.imagePath));
            return paths;
          }(),
          builder: (context, snapshot) {
            final paths = snapshot.data ?? [];
            final bool hasImg = paths.isNotEmpty;

            return GestureDetector(
              // 📍 [해결]: title과 category를 추가 인자로 넘겨 호출 에러 방지
              onTap: hasImg ? () => _handleImageTap(context, ref, item, title, category) : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.image_outlined, size: 18, color: hasImg ? Colors.orange : Colors.grey[200]),
                  if (paths.length > 1)
                    Positioned(
                      right: -4, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text("${paths.length}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 📍 [완전 구현] 수입/지출 상세 내역 바텀 시트 (긴 언어 대응 및 '호' 다국어화)
  void _showTransactionDetailSheet(BuildContext context, WidgetRef ref, String type, int year, NumberFormat fmt) async {
    final db = ref.read(databaseProvider);

    // 1. 해당 연도의 전체 데이터를 가져옴 (📍 날짜 오름차순 정렬로 수정)
    final allTransactions = await (db.select(db.transactions)
      ..where((t) => t.type.equals(type) & t.transactionDate.isBetweenValues(DateTime(year, 1, 1), DateTime(year, 12, 31, 23, 59, 59)))
      ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.asc)]))
        .get();

    if (allTransactions.isEmpty) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("COMMON_NO_DATA".tr(ref))));
      return;
    }

    // 2. 데이터가 있는 월 추출 및 정렬
    final availableMonths = allTransactions.map((t) => t.transactionDate.month).toSet().toList()..sort((a, b) => a.compareTo(b));
    final currentMonth = DateTime.now().month;
    final initialIndex = availableMonths.contains(currentMonth) ? availableMonths.indexOf(currentMonth) : 0;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DefaultTabController(
        length: availableMonths.length,
        initialIndex: initialIndex,
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

                // 📍 [타이틀 영역] 긴 언어 대응 (1줄 고정 및 축약)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      // 1. 제목 부분을 Expanded로 감싸서 남은 공간을 모두 차지하게 함
                      Expanded(
                        child: Text(
                          type == 'INC' ? "REPORT_YEARLY_REVENUE".tr(ref) : "REPORT_YEARLY_EXPENSES".tr(ref),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                          // 📍 핵심: 2줄 방지 및 말줄임표 처리
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 2. 제목과 연도 사이의 최소 간격
                      const SizedBox(width: 12),

                      // 3. 연도 표시 (우측 고정)
                      Text(
                        "$year${"COMMON_YEAR".tr(ref)}",
                        style: const TextStyle(fontSize: 14, color: Colors.indigo, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                TabBar(
                  isScrollable: true,
                  labelColor: const Color(0xFF1A237E),
                  indicatorColor: const Color(0xFF1A237E),
                  tabs: availableMonths.map((m) => Tab(text: "$m${"REPORT_DETAIL_MONTH_UNIT".tr(ref)}")).toList(),
                ),

                // 📍 [리스트 헤더] 긴 언어(네덜란드어 등) 대응 가변 너비 레이아웃
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text("REPORT_DETAIL_DATE_SHORT".tr(ref), style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Text(
                            "REPORT_DETAIL_ITEM_CAT".tr(ref),
                            style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                      ),
                      // 📍 증빙 헤더: 2줄 방지를 위해 최소 너비 확보 및 한 줄 고정
                      Container(
                        constraints: const BoxConstraints(minWidth: 45),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            "REPORT_DETAIL_RECEIPT".tr(ref),
                            style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                      SizedBox(width: 120, child: Text("REPORT_DETAIL_AMOUNT".tr(ref), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    children: availableMonths.map((month) {
                      final monthItems = allTransactions.where((t) => t.transactionDate.month == month).toList();
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 30),
                        itemCount: monthItems.length,
                        itemBuilder: (context, index) {
                          final item = monthItems[index];
                          final dateStr = DateFormat('dd').format(item.transactionDate);

                          return FutureBuilder<String>(
                              future: () async {
                                if (item.unitId == null) return item.memo ?? '';
                                final room = await (db.select(db.units)..where((u) => u.id.equals(item.unitId!))).getSingleOrNull();
                                // 📍 '호' 부분을 다국어 키 'COMMON_ROOM_UNIT'으로 적용
                                final unitSuffix = "COMMON_ROOM_UNIT".tr(ref);
                                return room != null ? "${room.roomNumber}$unitSuffix" : "${item.unitId}$unitSuffix";
                              }(),
                              builder: (context, nameSnapshot) {
                                final String displayName = nameSnapshot.data ?? "";
                                final String categoryLabel = item.category?.toString().startsWith('CAT_') == true
                                    ? item.category!.tr(ref) : (item.category ?? '-');

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 40, child: Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500))),

                                      // 📍 [리스트 항목] 텍스트 축약 및 레이아웃 유지 (구분선 조건부 표시 로직 반영)
                                      Expanded(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                          text: TextSpan(
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                            children: [
                                              // 📍 항목명(호수/메모) 정의: 지출 시 메모가 없으면 "지출" 기본 명칭 표시
                                                  () {
                                                final String entryName = type == 'INC'
                                                    ? displayName
                                                    : (item.memo != null && item.memo!.isNotEmpty ? item.memo! : "COMMON_EXPENSE".tr(ref));

                                                if (entryName.isNotEmpty) {
                                                  return TextSpan(
                                                      children: [
                                                        TextSpan(text: entryName),
                                                        const TextSpan(
                                                            text: "  |  ",
                                                            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w100)
                                                        ),
                                                      ]
                                                  );
                                                }
                                                return const TextSpan(text: "");
                                              }(),
                                              // 📍 카테고리명 (항목명이 없어도 카테고리는 표시)
                                              TextSpan(
                                                  text: categoryLabel,
                                                  style: const TextStyle(color: Colors.indigo, fontSize: 13)
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // 📍 증빙 배지 시스템
                                      SizedBox(
                                        width: 40,
                                        child: Center(
                                          child: FutureBuilder<List<String>>(
                                            future: () async {
                                              List<String> paths = [];
                                              if (item.receiptImagePath != null && item.receiptImagePath!.isNotEmpty) paths.add(item.receiptImagePath!);
                                              final imgs = await (db.select(db.transactionImages)..where((t) => t.transactionId.equals(item.id))).get();
                                              paths.addAll(imgs.map((i) => i.imagePath));
                                              return paths;
                                            }(),
                                            builder: (context, imgSnapshot) {
                                              final paths = imgSnapshot.data ?? [];
                                              final bool hasImg = paths.isNotEmpty;
                                              return GestureDetector(
                                                onTap: hasImg ? () => _handleImageTap(context, ref, item, displayName, categoryLabel) : null,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Icon(Icons.image_outlined, size: 20, color: hasImg ? Colors.orange : Colors.grey[200]),
                                                    if (paths.length > 1)
                                                      Positioned(
                                                        right: -4, top: -4,
                                                        child: Container(
                                                          padding: const EdgeInsets.all(2),
                                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                          child: Text("${paths.length}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                            fmt.format(item.amount),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: type == 'INC' ? Colors.blue[900] : Colors.red[900])
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _RiskSummary { final int score; final int balance; final int overdueCount; _RiskSummary({required this.score, required this.balance, required this.overdueCount}); }
