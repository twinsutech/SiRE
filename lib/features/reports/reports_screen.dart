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
// //     final currencyFmt =
// //     NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF1A237E),
// //         foregroundColor: Colors.white,
// //         title: Text("NAV_REPORTS".tr(ref),
// //             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// //       ),
// //       body: Stack(
// //         children: [
// //           SingleChildScrollView(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // 📍 [신규] 최상단 메인 Pro 안내 카드 (유료 사용자에게는 보이지 않음)
// //                 // 요청사항: 문구 한 줄, 버튼 다음 줄, 버튼 네이비, 카드 배경색 차별화 적용
// //                 if (!isPro) _buildMainProAnchor(context, ref),
// //
// //                 // ✅ [복구] 종합 진단 결과 (지출 급증 및 리스크 범례 포함)
// //                 monthlyTrendAsync.when(
// //                     loading: () => const SizedBox.shrink(),
// //                     error: (_, __) => const SizedBox.shrink(),
// //                     data: (trendData) => unpaidAsync.when(
// //                         loading: () => const SizedBox.shrink(),
// //                         error: (_, __) => const SizedBox.shrink(),
// //                         data: (unpaidList) {
// //                           int inC = 0, exC = 0, lastEx = 0;
// //                           final now = DateTime.now();
// //                           final thisMonth = trendData
// //                               .where((e) =>
// //                           e.month.year == now.year &&
// //                               e.month.month == now.month)
// //                               .toList();
// //                           if (thisMonth.isNotEmpty) {
// //                             inC = thisMonth.first.income;
// //                             exC = thisMonth.first.expense;
// //                           }
// //                           final last = DateTime(now.year, now.month - 1, 1);
// //                           final lastMonth = trendData
// //                               .where((e) =>
// //                           e.month.year == last.year &&
// //                               e.month.month == last.month)
// //                               .toList();
// //                           if (lastMonth.isNotEmpty)
// //                             lastEx = lastMonth.first.expense;
// //
// //                           final overdue = unpaidList
// //                               .where((u) => u.status == 'OVERDUE')
// //                               .toList();
// //                           final totalO = overdue.fold(
// //                               0, (sum, item) => sum + item.unit.monthlyRent);
// //
// //                           final insights = FinancialInsightService.generate(
// //                               thisMonthIncome: inC,
// //                               thisMonthExpense: exC,
// //                               lastMonthExpense: lastEx,
// //                               overdueCount: overdue.length,
// //                               totalOverdueAmount: totalO);
// //                           final risk = _computeRiskSummary(
// //                               thisMonthIncome: inC,
// //                               thisMonthExpense: exC,
// //                               lastMonthExpense: lastEx,
// //                               overdueCount: overdue.length,
// //                               totalOverdueAmount: totalO,
// //                               insights: insights);
// //
// //                           return Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 _buildSectionTitle(Icons.lightbulb_outline,
// //                                     "REPORT_SEC_INSIGHTS".tr(ref)),
// //                                 const SizedBox(height: 10),
// //                                 if (!isPro)
// //                                 // 📍 [수정] 결제 유도 버튼 삭제 및 안내 문구 노출 (다국어 적용)
// //                                   _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
// //                                 else
// //                                   _buildRiskSummaryCard(
// //                                       ref, currencyFmt, risk, insights),
// //                                 const SizedBox(height: 20),
// //                               ]);
// //                         })),
// //
// //                 // ✅ [복구] 재무 분석 (그래프 수치 표시 복구)
// //                 _buildSectionTitle(
// //                     Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
// //                 _buildFinancialAnalytics(ref, monthlyTrendAsync,
// //                     categoryStatsAsync, currencyFmt, lang, isPro),
// //
// //                 const SizedBox(height: 30),
// //                 _buildSectionTitle(
// //                     Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 _buildTaxSection(context, ref, isPro),
// //
// //                 const SizedBox(height: 30),
// //                 _buildSectionTitle(Icons.notification_important_outlined,
// //                     "REPORT_SEC_UNPAID".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 _buildUnpaidSection(
// //                     context, ref, unpaidAsync, currencyFmt, isPro),
// //
// //                 const SizedBox(height: 30),
// //                 // ✅ [복구] 연간 요약 타이틀 복구
// //                 _buildSectionTitle(Icons.table_chart_outlined,
// //                     "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// //                 const SizedBox(height: 10),
// //                 _buildAnnualSummary(
// //                     context, ref, monthlyTrendAsync, currencyFmt, isPro),
// //               ],
// //             ),
// //           ),
// //
// //           // 📍 캡처 전용 위젯 (공백 문제 해결을 위해 화면 밖 배치)
// //           Transform.translate(
// //             offset: const Offset(-5000, -5000),
// //             child: RepaintBoundary(
// //               key: _unpaidCaptureKey,
// //               child: Container(
// //                 width: 450,
// //                 padding: const EdgeInsets.all(30),
// //                 color: Colors.white,
// //                 child: unpaidAsync.when(
// //                   data: (list) {
// //                     final overdue =
// //                     list.where((u) => u.status == 'OVERDUE').toList();
// //                     final total = overdue.fold(
// //                         0, (sum, item) => sum + item.unit.monthlyRent);
// //                     return Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("REPORT_EXCEL_UNPAID_TITLE".tr(ref),
// //                             style: const TextStyle(
// //                                 color: Color(0xFF1A237E),
// //                                 fontSize: 24,
// //                                 fontWeight: FontWeight.bold)),
// //                         const Divider(color: Color(0xFF1A237E), thickness: 3),
// //                         const SizedBox(height: 20),
// //                         Text(
// //                             "${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(total)}",
// //                             style: const TextStyle(
// //                                 color: Colors.red,
// //                                 fontSize: 28,
// //                                 fontWeight: FontWeight.w900)),
// //                         const SizedBox(height: 30),
// //                         ...overdue
// //                             .map((u) => Container(
// //                           margin: const EdgeInsets.only(bottom: 15),
// //                           padding: const EdgeInsets.all(15),
// //                           decoration: BoxDecoration(
// //                               color: Colors.grey[50],
// //                               border:
// //                               Border.all(color: Colors.grey[300]!),
// //                               borderRadius: BorderRadius.circular(10)),
// //                           child: Column(children: [
// //                             Row(
// //                                 mainAxisAlignment:
// //                                 MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                       "${u.unit.roomNumber}호 | ${u.unit.tenantName ?? '-'}",
// //                                       style: const TextStyle(
// //                                           fontWeight: FontWeight.bold,
// //                                           fontSize: 18)),
// //                                   Text(
// //                                       currencyFmt
// //                                           .format(u.unit.monthlyRent),
// //                                       style: const TextStyle(
// //                                           color: Color(0xFF1A237E),
// //                                           fontWeight: FontWeight.bold,
// //                                           fontSize: 18)),
// //                                 ]),
// //                             const SizedBox(height: 10),
// //                             Row(
// //                                 mainAxisAlignment:
// //                                 MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(u.unit.tenantPhone ?? '-',
// //                                       style: const TextStyle(
// //                                           color: Colors.black54,
// //                                           fontSize: 14)),
// //                                   Text(
// //                                       "${'FILTER_EXPIRY_DATE'.tr(ref)}: ${DateFormat('yyyy-MM-dd').format(u.dueDate)}",
// //                                       style: const TextStyle(
// //                                           color: Colors.redAccent,
// //                                           fontSize: 14,
// //                                           fontWeight: FontWeight.bold)),
// //                                 ]),
// //                           ]),
// //                         ))
// //                             .toList(),
// //                         const SizedBox(height: 30),
// //                         const Center(
// //                             child: Text("Generated by SiRE Asset Management",
// //                                 style: TextStyle(
// //                                     color: Colors.grey,
// //                                     fontSize: 12,
// //                                     letterSpacing: 1.5))),
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
// //   // ✅ [신규/수정] 상단 메인 Pro 안내 카드 (디자인 요청사항 반영)
// //   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 25),
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.blueGrey[50], // 카드 색상 다르게 설정 (밝은 회청색)
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
// //       ),
// //       child: Column( // 버튼을 다음 줄로 보내기 위해 Column 사용
// //         children: [
// //           Row(
// //             children: [
// //               // 📍 아이콘 변경: Icons.workspace_premium_outlined
// //               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 child: Text(
// //                   "REPORT_MAIN_PRO_TEXT".tr(ref), // 다국어 키 (보고서는 SiRE Pro 기능입니다.)
// //                   style: const TextStyle(
// //                       color: Color(0xFF1A237E),
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 15),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton(
// //               onPressed: () => _openPaywall(context),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF1A237E), // 버튼 네이비 색상 유지
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(vertical: 12),
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //               ),
// //               // 📍 키 변경: SETTINGS_PRO_BUY_LIFETIME_TITLE (Pro 구매(평생))
// //               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // 📍 [신규] 일관성 있는 단순 안내 텍스트 카드
// //   Widget _buildSimpleLockCard(WidgetRef ref, String text) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //       child: Text(
// //         text,
// //         textAlign: TextAlign.center,
// //         style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
// //       ),
// //     );
// //   }
// //
// //   // ✅ [복구/수정] 재무 분석 카드 (그래프 위 수치 표시 및 Pro 구매 여부 체크 포함)
// //   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend,
// //       AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
// //
// //     // 📍 [수정] Pro 미구매 시 다른 영역과 동일한 사이즈의 안내 카드를 보여줌
// //     if (!isPro) {
// //       return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
// //     }
// //
// //     return Container(
// //       height: 320,
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// //           ]),
// //       child: monthlyTrend.when(
// //           loading: () => const Center(child: CircularProgressIndicator()),
// //           error: (_, __) => const SizedBox.shrink(),
// //           data: (trendData) {
// //             final List<BarChartGroupData> barGroups =
// //             (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
// //               final List<int> indicators = [];
// //               if (e.value.income > 0) indicators.add(0);
// //               if (e.value.expense > 0) indicators.add(1);
// //               return BarChartGroupData(
// //                   x: e.key,
// //                   barsSpace: 4,
// //                   showingTooltipIndicators: indicators,
// //                   barRods: [
// //                     BarChartRodData(
// //                         toY: e.value.income.toDouble(),
// //                         color: Colors.blue,
// //                         width: 8,
// //                         borderRadius: const BorderRadius.vertical(
// //                             top: Radius.circular(2))),
// //                     BarChartRodData(
// //                         toY: e.value.expense.toDouble(),
// //                         color: Colors.redAccent,
// //                         width: 8,
// //                         borderRadius: const BorderRadius.vertical(
// //                             top: Radius.circular(2))),
// //                   ]);
// //             }).toList();
// //             return Row(children: [
// //               Expanded(
// //                   flex: 3,
// //                   child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
// //                             style: const TextStyle(
// //                                 fontSize: 12, fontWeight: FontWeight.bold)),
// //                         const SizedBox(height: 25),
// //                         Expanded(
// //                             child: BarChart(BarChartData(
// //                               barTouchData: BarTouchData(
// //                                   enabled: false,
// //                                   touchTooltipData: BarTouchTooltipData(
// //                                     tooltipBgColor: Colors.transparent,
// //                                     tooltipPadding: EdgeInsets.zero,
// //                                     tooltipMargin: 4,
// //                                     getTooltipItem:
// //                                         (group, groupIndex, rod, rodIndex) =>
// //                                     rod.toY == 0
// //                                         ? null
// //                                         : BarTooltipItem(
// //                                         fmt.format(rod.toY),
// //                                         TextStyle(
// //                                             color: rod.color,
// //                                             fontWeight: FontWeight.bold,
// //                                             fontSize: 9)),
// //                                   )),
// //                               gridData: const FlGridData(show: false),
// //                               borderData: FlBorderData(show: false),
// //                               titlesData: FlTitlesData(
// //                                 topTitles: const AxisTitles(
// //                                     sideTitles: SideTitles(showTitles: false)),
// //                                 rightTitles: const AxisTitles(
// //                                     sideTitles: SideTitles(showTitles: false)),
// //                                 leftTitles: const AxisTitles(
// //                                     sideTitles: SideTitles(showTitles: false)),
// //                                 bottomTitles: AxisTitles(
// //                                     sideTitles: SideTitles(
// //                                         showTitles: true,
// //                                         getTitlesWidget: (v, m) {
// //                                           int i = v.toInt();
// //                                           if (i >= 0 && i < trendData.length)
// //                                             return Padding(
// //                                                 padding:
// //                                                 const EdgeInsets.only(top: 8),
// //                                                 child: Text(
// //                                                     DateFormat.MMM(lang)
// //                                                         .format(trendData[i].month),
// //                                                     style: const TextStyle(
// //                                                         fontSize: 9)));
// //                                           return const Text('');
// //                                         })),
// //                               ),
// //                               barGroups: barGroups,
// //                             ))),
// //                         const SizedBox(height: 12),
// //                         Row(children: [
// //                           _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// //                           const SizedBox(width: 12),
// //                           _buildLegend(
// //                               Colors.redAccent, "COMMON_EXPENSE".tr(ref))
// //                         ])
// //                       ])),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                   flex: 2,
// //                   child: categoryStats.when(
// //                       loading: () => const SizedBox.shrink(),
// //                       error: (_, __) => const SizedBox.shrink(),
// //                       data: (sData) {
// //                         final colors = [
// //                           Colors.indigo,
// //                           Colors.teal,
// //                           Colors.orange,
// //                           Colors.brown,
// //                           Colors.purple
// //                         ];
// //                         final List<PieChartSectionData> pieSections =
// //                         (sData as List)
// //                             .asMap()
// //                             .entries
// //                             .map<PieChartSectionData>((entry) {
// //                           return PieChartSectionData(
// //                               value: entry.value.amount.toDouble(),
// //                               color: colors[entry.key % colors.length],
// //                               radius: 40,
// //                               title: '');
// //                         }).toList();
// //                         return Column(children: [
// //                           Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
// //                               style: const TextStyle(
// //                                   fontSize: 12, fontWeight: FontWeight.bold)),
// //                           const SizedBox(height: 10),
// //                           Expanded(
// //                               flex: 3,
// //                               child: PieChart(PieChartData(
// //                                   sectionsSpace: 2,
// //                                   centerSpaceRadius: 10,
// //                                   sections: pieSections))),
// //                           const SizedBox(height: 12),
// //                           Expanded(
// //                               flex: 3,
// //                               child: SingleChildScrollView(
// //                                   child: Column(
// //                                       crossAxisAlignment:
// //                                       CrossAxisAlignment.start,
// //                                       children:
// //                                       sData.asMap().entries.map((entry) {
// //                                         final String name = entry.value.category
// //                                             .toString()
// //                                             .startsWith('CAT_')
// //                                             ? entry.value.category
// //                                             .toString()
// //                                             .tr(ref)
// //                                             : entry.value.category.toString();
// //                                         return Padding(
// //                                             padding: const EdgeInsets.symmetric(
// //                                                 vertical: 3),
// //                                             child: _buildLegend(
// //                                                 colors[
// //                                                 entry.key % colors.length],
// //                                                 "$name (${fmt.format(entry.value.amount)})",
// //                                                 fontSize: 9));
// //                                       }).toList()))),
// //                         ]);
// //                       }))
// //             ]);
// //           }),
// //     );
// //   }
// //
// //   // ✅ [복구] 종합 진단 결과 카드 (범례 및 상세 타일 100% 복원)
// //   Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt,
// //       _RiskSummary risk, List<FinancialInsight> insights) {
// //     const Color mainIndigo = Color(0xFF1A237E);
// //     final Color overdueColor = const Color(0xFFEF5350);
// //     final Color deficitColor = const Color(0xFFFFA726);
// //     final Color spikeColor = const Color(0xFF8D6E63);
// //     final Color safeColor = Colors.grey[200]!;
// //
// //     final bool hasOverdue = risk.overdueCount > 0;
// //     final bool hasDeficit = risk.balance < 0;
// //     final bool hasSpike = insights.any((i) =>
// //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: Colors.grey.shade300!),
// //           boxShadow: [
// //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// //           ]),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// //             Row(children: [
// //               Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
// //               const SizedBox(width: 10),
// //               Text('REPORT_RISK_TITLE'.tr(ref),
// //                   style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: mainIndigo))
// //             ]),
// //             Text("${risk.score}/100",
// //                 style: const TextStyle(
// //                     color: mainIndigo,
// //                     fontWeight: FontWeight.w900,
// //                     fontSize: 18)),
// //           ]),
// //           const SizedBox(height: 16),
// //           ClipRRect(
// //               borderRadius: BorderRadius.circular(8),
// //               child: SizedBox(
// //                   height: 14,
// //                   child: Row(children: [
// //                     if (hasOverdue)
// //                       Expanded(flex: 20, child: Container(color: overdueColor)),
// //                     if (hasDeficit)
// //                       Expanded(flex: 35, child: Container(color: deficitColor)),
// //                     if (hasSpike)
// //                       Expanded(flex: 25, child: Container(color: spikeColor)),
// //                     Expanded(
// //                         flex: (100 -
// //                             (hasOverdue ? 20 : 0) -
// //                             (hasDeficit ? 35 : 0) -
// //                             (hasSpike ? 25 : 0))
// //                             .toInt()
// //                             .clamp(5, 100),
// //                         child: Container(color: safeColor)),
// //                   ]))),
// //           const SizedBox(height: 12),
// //           // 🏷️ 원본 인덱스 범례 복구
// //           Center(
// //               child: Wrap(
// //                   spacing: 12,
// //                   runSpacing: 8,
// //                   alignment: WrapAlignment.center,
// //                   children: [
// //                     _buildRiskLegend(
// //                         overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
// //                     _buildRiskLegend(
// //                         deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
// //                     _buildRiskLegend(
// //                         spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
// //                     _buildRiskLegend(
// //                         Colors.grey[400]!,
// //                         "INSIGHT_LABEL_SAFE".tr(ref),
// //                         !hasOverdue && !hasDeficit && !hasSpike),
// //                   ])),
// //           const SizedBox(height: 20),
// //           // 🏷️ 원본 상세 타일(잔액, 미납건수) 복구
// //           Row(children: [
// //             _infoTile(ref, "COMMON_BALANCE".tr(ref),
// //                 currencyFmt.format(risk.balance)),
// //             const SizedBox(width: 10),
// //             _infoTile(
// //                 ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
// //           ]),
// //           const SizedBox(height: 12),
// //           const Divider(),
// //           ...insights.map((insight) {
// //             String message = insight.messageKey.tr(ref);
// //             insight.arguments?.forEach(
// //                     (key, value) => message = message.replaceAll('{$key}', value));
// //             return Padding(
// //                 padding: const EdgeInsets.only(top: 8),
// //                 child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Icon(Icons.check_circle_outline,
// //                           color: mainIndigo, size: 16),
// //                       const SizedBox(width: 6),
// //                       Expanded(
// //                           child: Text(message,
// //                               style: const TextStyle(
// //                                   fontSize: 13,
// //                                   color: Colors.black87,
// //                                   fontWeight: FontWeight.w500)))
// //                     ]));
// //           }).toList(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // 나머지 원본 헬퍼 메서드들 (isBold 파라미터 보정 완료)
// //   Widget _buildSummaryRow(
// //       NumberFormat fmt, String label, int amount, Color color,
// //       {required bool isBold}) =>
// //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
// //         Text(label,
// //             style: TextStyle(
// //                 fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
// //         Text(fmt.format(amount),
// //             style: TextStyle(fontWeight: FontWeight.bold, color: color))
// //       ]);
// //
// //   Widget _buildRiskLegend(Color color, String label, bool isActive) =>
// //       Row(mainAxisSize: MainAxisSize.min, children: [
// //         Opacity(
// //             opacity: isActive ? 1.0 : 0.2,
// //             child: Container(
// //                 width: 10,
// //                 height: 10,
// //                 decoration: BoxDecoration(
// //                     color: color, borderRadius: BorderRadius.circular(2)))),
// //         const SizedBox(width: 6),
// //         Text(label,
// //             style: TextStyle(
// //                 fontSize: 11,
// //                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// //                 color: isActive ? Colors.black : Colors.grey[500]))
// //       ]);
// //
// //   Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(
// //       child: Container(
// //           padding: const EdgeInsets.all(10),
// //           decoration: BoxDecoration(
// //               color: Colors.grey[50],
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(color: Colors.grey.shade200)),
// //           child:
// //           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //             Text(label,
// //                 style: TextStyle(fontSize: 10, color: Colors.grey[600])),
// //             Text(value,
// //                 style: const TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1A237E)))
// //           ])));
// //
// //   Widget _buildSectionTitle(IconData i, String t) => Row(children: [
// //     Icon(i, color: const Color(0xFF1A237E)),
// //     const SizedBox(width: 8),
// //     Text(t,
// //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
// //   ]);
// //
// //   Widget _buildLegend(Color c, String l, {double fontSize = 10}) =>
// //       Row(mainAxisSize: MainAxisSize.min, children: [
// //         Container(
// //             width: 8,
// //             height: 8,
// //             decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
// //         const SizedBox(width: 6),
// //         Flexible(
// //             child: Text(l,
// //                 style:
// //                 TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
// //                 overflow: TextOverflow.ellipsis))
// //       ]);
// //
// //   Widget _buildTaxSection(BuildContext c, WidgetRef r, bool isPro) => Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// //           ]),
// //       child: Column(children: [
// //         Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //                 border: Border.all(color: Colors.grey.shade300),
// //                 borderRadius: BorderRadius.circular(8)),
// //             child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Expanded(
// //                       child: Text(
// //                           "${'REPORT_TAX_PERIOD'.tr(r)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(r)}",
// //                           style: const TextStyle(fontSize: 13))),
// //                   const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
// //                 ])),
// //         const SizedBox(height: 20),
// //         SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton.icon(
// //                 style: ElevatedButton.styleFrom(
// //                     backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
// //                     foregroundColor: isPro ? Colors.white : Colors.grey[600],
// //                     padding: const EdgeInsets.symmetric(vertical: 16),
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8))),
// //                 onPressed: isPro ? () async {
// //                   final raw = r.read(ledgerListProvider).value ?? [];
// //                   final transactions = raw.map((e) => e.transaction).toList();
// //                   await ExcelExportService()
// //                       .exportTransactionsToExcel(transactions, r);
// //                 } : null, // 📍 null을 통해 버튼 물리적 비활성화
// //                 icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
// //                 label: Text("REPORT_BTN_TAX_EXCEL".tr(r),
// //                     style: const TextStyle(fontWeight: FontWeight.bold))))
// //       ]));
// //
// //   // ✅ [수정] 미납 관리 섹션 (무료 사용자 시 정보 숨김 로직 추가)
// //   Widget _buildUnpaidSection(BuildContext c, WidgetRef r,
// //       AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
// //       Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(12),
// //               boxShadow: [
// //                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// //               ]),
// //           child: Column(children: [
// //             unpaidAsync.when(
// //                 loading: () => const Center(child: CircularProgressIndicator()),
// //                 error: (_, __) => const SizedBox(),
// //                 data: (list) {
// //                   final overdue =
// //                   list.where((u) => u.status == 'OVERDUE').toList();
// //                   final total = overdue.fold(
// //                       0, (sum, item) => sum + item.unit.monthlyRent);
// //                   if (overdue.isEmpty)
// //                     return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r),
// //                         textAlign: TextAlign.center);
// //
// //                   // 📍 [로직 추가] Pro 사용자에게만 미납 상세 정보를 보여줌 (다국어 키 적용)
// //                   if (!isPro) {
// //                     return Container(
// //                       width: double.infinity,
// //                       padding: const EdgeInsets.all(16),
// //                       decoration: BoxDecoration(
// //                           color: Colors.grey[50],
// //                           borderRadius: BorderRadius.circular(8)),
// //                       child: Center(
// //                         child: Text(
// //                           "REPORT_LOCK_UNPAID".tr(r),
// //                           style: TextStyle(color: Colors.grey[600], fontSize: 13),
// //                         ),
// //                       ),
// //                     );
// //                   }
// //
// //                   return Container(
// //                       width: double.infinity,
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                           color: Colors.grey[50],
// //                           borderRadius: BorderRadius.circular(8)),
// //                       child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                                 "${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}",
// //                                 style: const TextStyle(
// //                                     color: Colors.red,
// //                                     fontWeight: FontWeight.bold)),
// //                             const SizedBox(height: 8),
// //                             ...overdue.take(3).map((u) => Text(
// //                                 "• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}",
// //                                 style: const TextStyle(fontSize: 12)))
// //                           ]));
// //                 }),
// //             const SizedBox(height: 20),
// //             Row(children: [
// //               Expanded(
// //                   child: ElevatedButton.icon(
// //                       style: ElevatedButton.styleFrom(
// //                           backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
// //                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
// //                           padding: const EdgeInsets.symmetric(vertical: 14),
// //                           shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8))),
// //                       onPressed: isPro ? () async {
// //                         await ExcelExportService().exportUnpaidListToExcel(
// //                             unpaidAsync.value ?? [], r);
// //                       } : null,
// //                       icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
// //                       label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r),
// //                           style: const TextStyle(
// //                               fontSize: 12, fontWeight: FontWeight.bold)))),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                   child: ElevatedButton.icon(
// //                       style: ElevatedButton.styleFrom(
// //                           backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300], // 📍 비활성화 색상 적용
// //                           foregroundColor: isPro ? Colors.white : Colors.grey[600],
// //                           padding: const EdgeInsets.symmetric(vertical: 14),
// //                           shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8))),
// //                       onPressed: isPro ? () async {
// //                         await _captureAndShare(_unpaidCaptureKey, r);
// //                       } : null,
// //                       icon: Icon(isPro ? Icons.share_outlined : Icons.lock_outline, size: 18),
// //                       label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r),
// //                           style: const TextStyle(
// //                               fontSize: 12, fontWeight: FontWeight.bold))))
// //             ])
// //           ]));
// //
// //   Widget _buildAnnualSummary(
// //       BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
// //     // 📍 p (isPro) 여부에 따라 전체 콘텐츠 노출 여부 결정 (다국어 적용)
// //     if (!p)
// //       return _buildSimpleLockCard(r, "REPORT_LOCK_ANNUAL".tr(r));
// //
// //     return Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             boxShadow: [
// //               BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
// //             ]),
// //         child: t.when(
// //             loading: () => const SizedBox(),
// //             error: (_, __) => const SizedBox(),
// //             data: (trend) {
// //               final y = DateTime.now().year;
// //               final cur = trend.where((e) => e.month.year == y).toList();
// //               int inc = cur.fold(0, (s, e) => s + e.income);
// //               int exp = cur.fold(0, (s, e) => s + e.expense);
// //               return Column(children: [
// //                 Row(mainAxisAlignment: MainAxisAlignment.end, children: [
// //                   Text("${'COMMON_YEAR'.tr(r)}: $y",
// //                       style: const TextStyle(
// //                           fontSize: 12, fontWeight: FontWeight.bold))
// //                 ]),
// //                 const SizedBox(height: 10),
// //                 _buildSummaryRow(
// //                     f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue,
// //                     isBold: false),
// //                 const Divider(height: 20),
// //                 _buildSummaryRow(
// //                     f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent,
// //                     isBold: false),
// //                 const Divider(height: 20),
// //                 _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp,
// //                     Colors.indigo,
// //                     isBold: true)
// //               ]);
// //             }));
// //   }
// //
// //   // 📍 [원본 유지] Pro 전용 잠금 카드 스타일 (네이비 브랜드 컬러 적용)
// //   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) =>
// //       Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
// //           child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]),
// //                 const SizedBox(height: 8),
// //                 Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
// //                 const SizedBox(height: 12),
// //                 Align(
// //                   alignment: Alignment.centerRight,
// //                   child: ElevatedButton(
// //                     onPressed: onTap,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFF1A237E), // SiRE 메인 네이비 색상
// //                       foregroundColor: Colors.white,            // 글자색 흰색
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                     ),
// //                     child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r)),
// //                   ),
// //                 )
// //               ]
// //           )
// //       );
// //
// //   void _openPaywall(BuildContext c) => Navigator.of(c)
// //       .push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
// //
// //   Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
// //     try {
// //       await WidgetsBinding.instance.endOfFrame;
// //       await Future.delayed(const Duration(milliseconds: 200));
// //       final RenderRepaintBoundary? boundary =
// //       key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
// //       if (boundary == null || boundary.debugNeedsPaint) {
// //         await Future.delayed(const Duration(milliseconds: 300));
// //       }
// //       final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
// //       final ByteData? byteData =
// //       await image.toByteData(format: ui.ImageByteFormat.png);
// //       final Uint8List pngBytes = byteData!.buffer.asUint8List();
// //       final directory = await getTemporaryDirectory();
// //       final path =
// //           '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
// //       await File(path).writeAsBytes(pngBytes);
// //       await Share.shareXFiles([XFile(path)],
// //           text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
// //     } catch (e) {
// //       debugPrint("Capture Error: $e");
// //     }
// //   }
// //
// //   _RiskSummary _computeRiskSummary(
// //       {required int thisMonthIncome,
// //         required int thisMonthExpense,
// //         required int lastMonthExpense,
// //         required int overdueCount,
// //         required int totalOverdueAmount,
// //         required List<FinancialInsight> insights}) {
// //     int s = 0;
// //     if (overdueCount > 0) s += 20;
// //     if (thisMonthIncome < thisMonthExpense) s += 40;
// //     if (insights.any((i) =>
// //     i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')))
// //       s += 25;
// //     int fs = s.clamp(0, 100);
// //     return _RiskSummary(
// //         score: fs,
// //         level: fs >= 75
// //             ? _RiskLevel.high
// //             : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low),
// //         balance: thisMonthIncome - thisMonthExpense,
// //         overdueCount: overdueCount,
// //         reasons: []);
// //   }
// // }
// //
// // enum _RiskLevel { low, mid, high }
// //
// // class _RiskSummary {
// //   final int score;
// //   final _RiskLevel level;
// //   final List<String> reasons;
// //   final int balance;
// //   final int overdueCount;
// //
// //   _RiskSummary(
// //       {required this.score,
// //         required this.level,
// //         required this.reasons,
// //         required this.balance,
// //         required this.overdueCount});
// // }
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
//     // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
//     final isPro = ref.watch(isProProvider);
//
//     // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
//     // 이 화면이 빌드될 때 Pro 상태로 변경되면, 스택에 쌓인 PaywallScreen을 닫습니다.
//     ref.listen<bool>(isProProvider, (previous, next) {
//       if (previous == false && next == true) {
//         // 이전에 유료가 아니었다가 지금 유료가 된 경우 (결제 성공)
//         // 현재 화면 위에 열려있는 다이얼로그나 페이지(Paywall)가 있다면 닫습니다.
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
//                 // 요청사항: 문구 한 줄, 버튼 다음 줄, 버튼 네이비, 카드 배경색 차별화 적용
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
//                                 // 📍 [수정] 결제 유도 버튼 삭제 및 안내 문구 노출 (다국어 적용)
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
//   // ✅ [신규/수정] 상단 메인 Pro 안내 카드 (디자인 요청사항 반영)
//   Widget _buildMainProAnchor(BuildContext context, WidgetRef ref) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 25),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blueGrey[50], // 카드 색상 다르게 설정 (밝은 회청색)
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
//       ),
//       child: Column( // 버튼을 다음 줄로 보내기 위해 Column 사용
//         children: [
//           Row(
//             children: [
//               // 📍 아이콘 변경: Icons.workspace_premium_outlined
//               const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E), size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   "REPORT_MAIN_PRO_TEXT".tr(ref), // 다국어 키 (보고서는 SiRE Pro 기능입니다.)
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
//                 backgroundColor: const Color(0xFF1A237E), // 버튼 네이비 색상 유지
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               // 📍 키 변경: SETTINGS_PRO_BUY_LIFETIME_TITLE (Pro 구매(평생))
//               child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
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
//   // ✅ [복구/수정] 재무 분석 카드 (그래프 위 수치 표시 및 Pro 구매 여부 체크 포함)
//   Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend,
//       AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
//
//     // 📍 [수정사항 반영] Pro 미구매 시 다른 영역과 동일한 카드 사이즈로 안내 메시지 출력
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
//   // ✅ [복구] 종합 진단 결과 카드 (범례 및 상세 타일 100% 복원)
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
//           // 🏷️ 원본 인덱스 범례 복구
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
//           // 🏷️ 원본 상세 타일(잔액, 미납건수) 복구
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
//   // 나머지 원본 헬퍼 메서드들 (isBold 파라미터 보정 완료)
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
//                     backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
//                     foregroundColor: isPro ? Colors.white : Colors.grey[600],
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8))),
//                 onPressed: isPro ? () async {
//                   final raw = r.read(ledgerListProvider).value ?? [];
//                   final transactions = raw.map((e) => e.transaction).toList();
//                   await ExcelExportService()
//                       .exportTransactionsToExcel(transactions, r);
//                 } : null, // 📍 null을 통해 버튼 물리적 비활성화
//                 icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
//                 label: Text("REPORT_BTN_TAX_EXCEL".tr(r),
//                     style: const TextStyle(fontWeight: FontWeight.bold))))
//       ]));
//
//   // ✅ [수정] 미납 관리 섹션 (무료 사용자 시 정보 숨김 로직 추가)
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
//                   // 📍 [로직 추가] Pro 사용자에게만 미납 상세 정보를 보여줌 (다국어 키 적용)
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
//                           backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300], // 📍 비활성화 색상 적용
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
//                           backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300], // 📍 비활성화 색상 적용
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
//     // 📍 p (isPro) 여부에 따라 전체 콘텐츠 노출 여부 결정 (다국어 적용)
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
//   // 📍 [원본 유지] Pro 전용 잠금 카드 스타일 (네이비 브랜드 컬러 적용)
//   Widget _buildProLockCard(BuildContext c, WidgetRef r, {required String subtitleKey, required VoidCallback onTap}) =>
//       Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [const Icon(Icons.lock_outline, color: Color(0xFF1A237E)), const SizedBox(width: 10), Text("REPORTS_PRO_LOCK_TITLE".tr(r), style: const TextStyle(fontWeight: FontWeight.bold))]),
//                 const SizedBox(height: 8),
//                 Text(subtitleKey.tr(r), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//                 const SizedBox(height: 12),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton(
//                     onPressed: onTap,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1A237E), // SiRE 메인 네이비 색상
//                       foregroundColor: Colors.white,            // 글자색 흰색
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     child: Text("REPORTS_PRO_LOCK_BUTTON".tr(r)),
//                   ),
//                 )
//               ]
//           )
//       );
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
    // 📍 환불 및 결제 상태를 실시간으로 watch 합니다.
    final isPro = ref.watch(isProProvider);

    // 📍 [추가 로직] 결제 성공 시 자동으로 Paywall 화면을 닫아주는 리스너
    ref.listen<bool>(isProProvider, (previous, next) {
      if (previous == false && next == true) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/main_screen');
        }
      }
    });

    final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
    final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final lang = ref.watch(localizationProvider.notifier).currentLang;
    final currencyFmt =
    NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text("NAV_REPORTS".tr(ref),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (trendData) => unpaidAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (unpaidList) {
                          int inC = 0, exC = 0, lastEx = 0;
                          final now = DateTime.now();
                          final thisMonth = trendData
                              .where((e) =>
                          e.month.year == now.year &&
                              e.month.month == now.month)
                              .toList();
                          if (thisMonth.isNotEmpty) {
                            inC = thisMonth.first.income;
                            exC = thisMonth.first.expense;
                          }
                          final last = DateTime(now.year, now.month - 1, 1);
                          final lastMonth = trendData
                              .where((e) =>
                          e.month.year == last.year &&
                              e.month.month == last.month)
                              .toList();
                          if (lastMonth.isNotEmpty)
                            lastEx = lastMonth.first.expense;

                          final overdue = unpaidList
                              .where((u) => u.status == 'OVERDUE')
                              .toList();
                          final totalO = overdue.fold(
                              0, (sum, item) => sum + item.unit.monthlyRent);

                          final insights = FinancialInsightService.generate(
                              thisMonthIncome: inC,
                              thisMonthExpense: exC,
                              lastMonthExpense: lastEx,
                              overdueCount: overdue.length,
                              totalOverdueAmount: totalO);
                          final risk = _computeRiskSummary(
                              thisMonthIncome: inC,
                              thisMonthExpense: exC,
                              lastMonthExpense: lastEx,
                              overdueCount: overdue.length,
                              totalOverdueAmount: totalO,
                              insights: insights);

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(Icons.lightbulb_outline,
                                    "REPORT_SEC_INSIGHTS".tr(ref)),
                                const SizedBox(height: 10),
                                if (!isPro)
                                // 📍 [수정] 안내 문구 노출 (다국어 키 적용)
                                  _buildSimpleLockCard(ref, "REPORT_LOCK_INSIGHT".tr(ref))
                                else
                                  _buildRiskSummaryCard(
                                      ref, currencyFmt, risk, insights),
                                const SizedBox(height: 20),
                              ]);
                        })),

                // ✅ [복구] 재무 분석 (그래프 수치 표시 복구)
                _buildSectionTitle(
                    Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
                const SizedBox(height: 10),
                // 📍 [수정] isPro 상태를 전달하여 유료 사용자에게만 그래프 노출
                _buildFinancialAnalytics(ref, monthlyTrendAsync,
                    categoryStatsAsync, currencyFmt, lang, isPro),

                const SizedBox(height: 30),
                _buildSectionTitle(
                    Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
                const SizedBox(height: 10),
                _buildTaxSection(context, ref, isPro),

                const SizedBox(height: 30),
                _buildSectionTitle(Icons.notification_important_outlined,
                    "REPORT_SEC_UNPAID".tr(ref)),
                const SizedBox(height: 10),
                // 📍 [에러 수정] ref 파라미터를 명시적으로 전달하여 image_1aba06 에러 해결
                _buildUnpaidSection(
                    context, ref, unpaidAsync, currencyFmt, isPro),

                const SizedBox(height: 30),
                // ✅ [복구] 연간 요약 타이틀 복구
                _buildSectionTitle(Icons.table_chart_outlined,
                    "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
                const SizedBox(height: 10),
                _buildAnnualSummary(
                    context, ref, monthlyTrendAsync, currencyFmt, isPro),
              ],
            ),
          ),

          // 📍 캡처 전용 위젯 (공백 문제 해결을 위해 화면 밖 배치)
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
                    list.where((u) => u.status == 'OVERDUE').toList();
                    final total = overdue.fold(
                        0, (sum, item) => sum + item.unit.monthlyRent);
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
                            .map((u) => Container(
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
                        ))
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

  // ✅ [신규/수정] 상단 메인 Pro 안내 카드 (체험 버튼 추가)
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
                  style: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openPaywall(context),
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
              onPressed: trialCount > 0
                  ? () => ref.read(purchaseControllerProvider.notifier).startTrial()
                  : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey),
                foregroundColor: trialCount > 0 ? const Color(0xFF1A237E) : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                trialCount > 0
                    ? "${"PROP_FREE_TRIAL".tr(ref)} ($trialCount${"PROP_TRIAL_UNIT".tr(ref)})"
                    : "PROP_TRIAL_EXPIRED".tr(ref),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📍 [신규] 일관성 있는 단순 안내 텍스트 카드
  Widget _buildSimpleLockCard(WidgetRef ref, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
      ),
    );
  }

  // ✅ [복구/수정] 재무 분석 카드
  Widget _buildFinancialAnalytics(WidgetRef ref, AsyncValue monthlyTrend,
      AsyncValue categoryStats, NumberFormat fmt, String lang, bool isPro) {
    if (!isPro) {
      return _buildSimpleLockCard(ref, "REPORT_LOCK_FINANCIAL".tr(ref));
    }

    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: monthlyTrend.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (trendData) {
            final List<BarChartGroupData> barGroups =
            (trendData as List).asMap().entries.map<BarChartGroupData>((e) {
              final List<int> indicators = [];
              if (e.value.income > 0) indicators.add(0);
              if (e.value.expense > 0) indicators.add(1);
              return BarChartGroupData(
                  x: e.key,
                  barsSpace: 4,
                  showingTooltipIndicators: indicators,
                  barRods: [
                    BarChartRodData(
                        toY: e.value.income.toDouble(),
                        color: Colors.blue,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2))),
                    BarChartRodData(
                        toY: e.value.expense.toDouble(),
                        color: Colors.redAccent,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2))),
                  ]);
            }).toList();
            return Row(children: [
              Expanded(
                  flex: 3,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REPORT_MONTHLY_TREND_TITLE".tr(ref),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 25),
                        Expanded(
                            child: BarChart(BarChartData(
                              barTouchData: BarTouchData(
                                  enabled: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.transparent,
                                    tooltipPadding: EdgeInsets.zero,
                                    tooltipMargin: 4,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) =>
                                    rod.toY == 0
                                        ? null
                                        : BarTooltipItem(
                                        fmt.format(rod.toY),
                                        TextStyle(
                                            color: rod.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9)),
                                  )),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, m) {
                                          int i = v.toInt();
                                          if (i >= 0 && i < trendData.length)
                                            return Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8),
                                                child: Text(
                                                    DateFormat.MMM(lang)
                                                        .format(trendData[i].month),
                                                    style: const TextStyle(
                                                        fontSize: 9)));
                                          return const Text('');
                                        })),
                              ),
                              barGroups: barGroups,
                            ))),
                        const SizedBox(height: 12),
                        Row(children: [
                          _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
                          const SizedBox(width: 12),
                          _buildLegend(
                              Colors.redAccent, "COMMON_EXPENSE".tr(ref))
                        ])
                      ])),
              const SizedBox(width: 12),
              Expanded(
                  flex: 2,
                  child: categoryStats.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (sData) {
                        final colors = [
                          Colors.indigo,
                          Colors.teal,
                          Colors.orange,
                          Colors.brown,
                          Colors.purple
                        ];
                        final List<PieChartSectionData> pieSections =
                        (sData as List)
                            .asMap()
                            .entries
                            .map<PieChartSectionData>((entry) {
                          return PieChartSectionData(
                              value: entry.value.amount.toDouble(),
                              color: colors[entry.key % colors.length],
                              radius: 40,
                              title: '');
                        }).toList();
                        return Column(children: [
                          Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Expanded(
                              flex: 3,
                              child: PieChart(PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 10,
                                  sections: pieSections))),
                          const SizedBox(height: 12),
                          Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children:
                                      sData.asMap().entries.map((entry) {
                                        final String name = entry.value.category
                                            .toString()
                                            .startsWith('CAT_')
                                            ? entry.value.category
                                            .toString()
                                            .tr(ref)
                                            : entry.value.category.toString();
                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            child: _buildLegend(
                                                colors[
                                                entry.key % colors.length],
                                                "$name (${fmt.format(entry.value.amount)})",
                                                fontSize: 9));
                                      }).toList()))),
                        ]);
                      }))
            ]);
          }),
    );
  }

  // ✅ [복구] 종합 진단 결과 카드
  Widget _buildRiskSummaryCard(WidgetRef ref, NumberFormat currencyFmt,
      _RiskSummary risk, List<FinancialInsight> insights) {
    const Color mainIndigo = Color(0xFF1A237E);
    final Color overdueColor = const Color(0xFFEF5350);
    final Color deficitColor = const Color(0xFFFFA726);
    final Color spikeColor = const Color(0xFF8D6E63);
    final Color safeColor = Colors.grey[200]!;

    final bool hasOverdue = risk.overdueCount > 0;
    final bool hasDeficit = risk.balance < 0;
    final bool hasSpike = insights.any((i) =>
    i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.analytics_outlined, color: mainIndigo, size: 22),
              const SizedBox(width: 10),
              Text('REPORT_RISK_TITLE'.tr(ref),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainIndigo))
            ]),
            Text("${risk.score}/100",
                style: const TextStyle(
                    color: mainIndigo,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                  height: 14,
                  child: Row(children: [
                    if (hasOverdue)
                      Expanded(flex: 20, child: Container(color: overdueColor)),
                    if (hasDeficit)
                      Expanded(flex: 35, child: Container(color: deficitColor)),
                    if (hasSpike)
                      Expanded(flex: 25, child: Container(color: spikeColor)),
                    Expanded(
                        flex: (100 -
                            (hasOverdue ? 20 : 0) -
                            (hasDeficit ? 35 : 0) -
                            (hasSpike ? 25 : 0))
                            .toInt()
                            .clamp(5, 100),
                        child: Container(color: safeColor)),
                  ]))),
          const SizedBox(height: 12),
          Center(
              child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildRiskLegend(
                        overdueColor, "ALERT_OVERDUE_TITLE".tr(ref), hasOverdue),
                    _buildRiskLegend(
                        deficitColor, "INSIGHT_LABEL_DEFICIT".tr(ref), hasDeficit),
                    _buildRiskLegend(
                        spikeColor, "INSIGHT_LABEL_SPIKE".tr(ref), hasSpike),
                    _buildRiskLegend(
                        Colors.grey[400]!,
                        "INSIGHT_LABEL_SAFE".tr(ref),
                        !hasOverdue && !hasDeficit && !hasSpike),
                  ])),
          const SizedBox(height: 20),
          Row(children: [
            _infoTile(ref, "COMMON_BALANCE".tr(ref),
                currencyFmt.format(risk.balance)),
            const SizedBox(width: 10),
            _infoTile(
                ref, "ALERT_OVERDUE_TITLE".tr(ref), "${risk.overdueCount} 건"),
          ]),
          const SizedBox(height: 12),
          const Divider(),
          ...insights.map((insight) {
            String message = insight.messageKey.tr(ref);
            insight.arguments?.forEach(
                    (key, value) => message = message.replaceAll('{$key}', value));
            return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: mainIndigo, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(message,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500)))
                    ]));
          }).toList(),
        ],
      ),
    );
  }

  // 나머지 헬퍼 메서드들
  Widget _buildSummaryRow(
      NumberFormat fmt, String label, int amount, Color color,
      {required bool isBold}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(fmt.format(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: color))
      ]);

  Widget _buildRiskLegend(Color color, String label, bool isActive) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Opacity(
            opacity: isActive ? 1.0 : 0.2,
            child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey[500]))
      ]);

  Widget _infoTile(WidgetRef ref, String label, String value) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200)),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E)))
          ])));

  Widget _buildSectionTitle(IconData i, String t) => Row(children: [
    Icon(i, color: const Color(0xFF1A237E)),
    const SizedBox(width: 8),
    Text(t,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
  ]);

  Widget _buildLegend(Color c, String l, {double fontSize = 10}) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Flexible(
            child: Text(l,
                style:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis))
      ]);

  Widget _buildTaxSection(BuildContext c, WidgetRef r, bool isPro) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(children: [
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                          "${'REPORT_TAX_PERIOD'.tr(r)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(r)}",
                          style: const TextStyle(fontSize: 13))),
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
                ])),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300],
                    foregroundColor: isPro ? Colors.white : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: isPro ? () async {
                  final raw = r.read(ledgerListProvider).value ?? [];
                  final transactions = raw.map((e) => e.transaction).toList();
                  await ExcelExportService()
                      .exportTransactionsToExcel(transactions, r);
                } : null,
                icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
                label: Text("REPORT_BTN_TAX_EXCEL".tr(r),
                    style: const TextStyle(fontWeight: FontWeight.bold))))
      ]));

  // 📍 [에러 해결] ref 파라미터 추가
  Widget _buildUnpaidSection(BuildContext c, WidgetRef r,
      AsyncValue unpaidAsync, NumberFormat fmt, bool isPro) =>
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ]),
          child: Column(children: [
            unpaidAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
                data: (list) {
                  final overdue =
                  list.where((u) => u.status == 'OVERDUE').toList();
                  final total = overdue.fold(
                      0, (sum, item) => sum + item.unit.monthlyRent);
                  if (overdue.isEmpty)
                    return Text("REPORT_UNPAID_ALL_COLLECTED".tr(r),
                        textAlign: TextAlign.center);

                  if (!isPro) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          "REPORT_LOCK_UNPAID".tr(r),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    );
                  }

                  return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${'ALERT_OVERDUE_TITLE'.tr(r)}: ${overdue.length} / ${'PROP_TOTAL'.tr(r)}: ${fmt.format(total)}",
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...overdue.take(3).map((u) => Text(
                                "• ${u.unit.roomNumber}호: ${fmt.format(u.unit.monthlyRent)}",
                                style: const TextStyle(fontSize: 12)))
                          ]));
                }),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: isPro ? const Color(0xFF4CAF50) : Colors.grey[300],
                          foregroundColor: isPro ? Colors.white : Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: isPro ? () async {
                        await ExcelExportService().exportUnpaidListToExcel(
                            unpaidAsync.value ?? [], r);
                      } : null,
                      icon: Icon(isPro ? Icons.file_download : Icons.lock_outline, size: 18),
                      label: Text("REPORT_BTN_UNPAID_EXCEL".tr(r),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: isPro ? Colors.orangeAccent : Colors.grey[300],
                          foregroundColor: isPro ? Colors.white : Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: isPro ? () async {
                        await _captureAndShare(_unpaidCaptureKey, r);
                      } : null,
                      icon: Icon(isPro ? Icons.share_outlined : Icons.lock_outline, size: 18),
                      label: Text("REPORT_BTN_UNPAID_IMAGE".tr(r),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold))))
            ])
          ]));

  Widget _buildAnnualSummary(
      BuildContext c, WidgetRef r, AsyncValue t, NumberFormat f, bool p) {
    if (!p)
      return _buildSimpleLockCard(r, "REPORT_LOCK_ANNUAL".tr(r));

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ]),
        child: t.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (trend) {
              final y = DateTime.now().year;
              final cur = trend.where((e) => e.month.year == y).toList();
              int inc = cur.fold(0, (s, e) => s + e.income);
              int exp = cur.fold(0, (s, e) => s + e.expense);
              return Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text("${'COMMON_YEAR'.tr(r)}: $y",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold))
                ]),
                const SizedBox(height: 10),
                _buildSummaryRow(
                    f, "REPORT_YEARLY_REVENUE".tr(r), inc, Colors.blue,
                    isBold: false),
                const Divider(height: 20),
                _buildSummaryRow(
                    f, "REPORT_YEARLY_EXPENSES".tr(r), exp, Colors.redAccent,
                    isBold: false),
                const Divider(height: 20),
                _buildSummaryRow(f, "REPORT_ANNUAL_NET_PROFIT".tr(r), inc - exp,
                    Colors.indigo,
                    isBold: true)
              ]);
            }));
  }

  void _openPaywall(BuildContext c) => Navigator.of(c)
      .push(MaterialPageRoute(builder: (_) => const PaywallScreen()));

  Future<void> _captureAndShare(GlobalKey key, WidgetRef ref) async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 200));
      final RenderRepaintBoundary? boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
      final ui.Image image = await boundary!.toImage(pixelRatio: 2.5);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/SiRE_Report_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(path)],
          text: "REPORT_EXCEL_UNPAID_TITLE".tr(ref));
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  _RiskSummary _computeRiskSummary(
      {required int thisMonthIncome,
        required int thisMonthExpense,
        required int lastMonthExpense,
        required int overdueCount,
        required int totalOverdueAmount,
        required List<FinancialInsight> insights}) {
    int s = 0;
    if (overdueCount > 0) s += 20;
    if (thisMonthIncome < thisMonthExpense) s += 40;
    if (insights.any((i) =>
    i.messageKey.contains('SPIKE') || i.messageKey.contains('RATIO')))
      s += 25;
    int fs = s.clamp(0, 100);
    return _RiskSummary(
        score: fs,
        level: fs >= 75
            ? _RiskLevel.high
            : (fs >= 40 ? _RiskLevel.mid : _RiskLevel.low),
        balance: thisMonthIncome - thisMonthExpense,
        overdueCount: overdueCount,
        reasons: []);
  }
}

enum _RiskLevel { low, mid, high }

class _RiskSummary {
  final int score;
  final _RiskLevel level;
  final List<String> reasons;
  final int balance;
  final int overdueCount;

  _RiskSummary(
      {required this.score,
        required this.level,
        required this.reasons,
        required this.balance,
        required this.overdueCount});
}
