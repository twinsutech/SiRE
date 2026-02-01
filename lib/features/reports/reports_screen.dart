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
// // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // import '../ledger/ledger_provider.dart';
// // // // import '../ledger/unpaid_provider.dart';
// // // // import 'excel_export_service.dart';
// // // //
// // // // class ReportsScreen extends ConsumerWidget {
// // // //   const ReportsScreen({super.key});
// // // //
// // // //   // 📍 이미지 캡처를 위한 GlobalKey
// // // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // // //
// // // //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// // // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[100],
// // // //       appBar: AppBar(
// // // //         backgroundColor: const Color(0xFF1A237E),
// // // //         foregroundColor: Colors.white,
// // // //         elevation: 0,
// // // //         scrolledUnderElevation: 0,
// // // //         automaticallyImplyLeading: false,
// // // //         centerTitle: false,
// // // //         title: Text(
// // // //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // // //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // //         ),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             // 📍 1. Financial Analytics 섹션
// // // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             Container(
// // // //               height: 320,
// // // //               padding: const EdgeInsets.all(16),
// // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // //               child: Row(
// // // //                 children: [
// // // //                   Expanded(
// // // //                     flex: 3,
// // // //                     child: Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: [
// // // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                         const SizedBox(height: 25),
// // // //                         Expanded(
// // // //                           child: monthlyTrendAsync.when(
// // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // //                             error: (_, __) => const SizedBox(),
// // // //                             data: (data) => BarChart(
// // // //                               BarChartData(
// // // //                                 barTouchData: BarTouchData(
// // // //                                   enabled: false,
// // // //                                   touchTooltipData: BarTouchTooltipData(
// // // //                                     tooltipBgColor: Colors.transparent,
// // // //                                     tooltipPadding: EdgeInsets.zero,
// // // //                                     tooltipMargin: 4,
// // // //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// // // //                                       if (rod.toY == 0) return null;
// // // //                                       return BarTooltipItem(
// // // //                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
// // // //                                         currencyFmt.format(rod.toY),
// // // //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// // // //                                       );
// // // //                                     },
// // // //                                   ),
// // // //                                 ),
// // // //                                 barGroups: data.asMap().entries.map((e) {
// // // //                                   final List<int> indicators = [];
// // // //                                   if (e.value.income > 0) indicators.add(0);
// // // //                                   if (e.value.expense > 0) indicators.add(1);
// // // //
// // // //                                   return BarChartGroupData(
// // // //                                     x: e.key,
// // // //                                     barsSpace: 4,
// // // //                                     showingTooltipIndicators: indicators,
// // // //                                     barRods: [
// // // //                                       BarChartRodData(
// // // //                                           toY: e.value.income.toDouble(),
// // // //                                           color: Colors.blue,
// // // //                                           width: 8,
// // // //                                           borderRadius: const BorderRadius.vertical(top: Radius.circular(2))
// // // //                                       ),
// // // //                                       BarChartRodData(
// // // //                                           toY: e.value.expense.toDouble(),
// // // //                                           color: Colors.redAccent,
// // // //                                           width: 8,
// // // //                                           borderRadius: const BorderRadius.vertical(top: Radius.circular(2))
// // // //                                       ),
// // // //                                     ],
// // // //                                   );
// // // //                                 }).toList(),
// // // //                                 titlesData: FlTitlesData(
// // // //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // // //                                   bottomTitles: AxisTitles(
// // // //                                     sideTitles: SideTitles(
// // // //                                       showTitles: true,
// // // //                                       getTitlesWidget: (value, meta) {
// // // //                                         int index = value.toInt();
// // // //                                         if (index >= 0 && index < data.length) {
// // // //                                           return Padding(
// // // //                                             padding: const EdgeInsets.only(top: 8.0),
// // // //                                             child: Text(DateFormat.MMM(lang).format(data[index].month), style: const TextStyle(fontSize: 9)),
// // // //                                           );
// // // //                                         }
// // // //                                         return const Text('');
// // // //                                       },
// // // //                                     ),
// // // //                                   ),
// // // //                                 ),
// // // //                                 gridData: const FlGridData(show: false),
// // // //                                 borderData: FlBorderData(show: false),
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                         const SizedBox(height: 12),
// // // //                         Row(
// // // //                           mainAxisAlignment: MainAxisAlignment.start,
// // // //                           children: [
// // // //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // // //                             const SizedBox(width: 12),
// // // //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// // // //                           ],
// // // //                         )
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(width: 12),
// // // //                   // 📍 연간 지출 차트 섹션
// // // //                   Expanded(
// // // //                     flex: 2,
// // // //                     child: Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: [
// // // //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // // //                         const SizedBox(height: 10),
// // // //                         Expanded(
// // // //                           child: categoryStatsAsync.when(
// // // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // // //                             error: (_, __) => const SizedBox(),
// // // //                             data: (data) {
// // // //                               if (data.isEmpty) return Center(child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// // // //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // // //
// // // //                               return Column(
// // // //                                 children: [
// // // //                                   Expanded(
// // // //                                     flex: 3,
// // // //                                     child: PieChart(
// // // //                                         PieChartData(
// // // //                                             sectionsSpace: 2,
// // // //                                             centerSpaceRadius: 10,
// // // //                                             sections: data.asMap().entries.map((entry) {
// // // //                                               final double pctValue = entry.value.percentage * 100;
// // // //                                               final String percentageStr = pctValue.toStringAsFixed(0);
// // // //                                               final String categoryName = entry.value.category.startsWith('CAT_')
// // // //                                                   ? entry.value.category.tr(ref)
// // // //                                                   : entry.value.category;
// // // //
// // // //                                               final String sectionTitle = pctValue <= 1
// // // //                                                   ? ''
// // // //                                                   : '$categoryName\n($percentageStr%)';
// // // //
// // // //                                               return PieChartSectionData(
// // // //                                                 value: entry.value.amount.toDouble(),
// // // //                                                 title: sectionTitle,
// // // //                                                 titleStyle: const TextStyle(
// // // //                                                   fontSize: 7,
// // // //                                                   fontWeight: FontWeight.bold,
// // // //                                                   color: Colors.white,
// // // //                                                   height: 1.2,
// // // //                                                 ),
// // // //                                                 color: colors[entry.key % colors.length],
// // // //                                                 radius: 40,
// // // //                                               );
// // // //                                             }).toList()
// // // //                                         )
// // // //                                     ),
// // // //                                   ),
// // // //                                   const SizedBox(height: 12),
// // // //                                   Expanded(
// // // //                                     flex: 3,
// // // //                                     child: SingleChildScrollView(
// // // //                                       child: Column(
// // // //                                         crossAxisAlignment: CrossAxisAlignment.start,
// // // //                                         children: data.asMap().entries.map((entry) {
// // // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // // //                                               ? entry.value.category.tr(ref)
// // // //                                               : entry.value.category;
// // // //                                           return Padding(
// // // //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// // // //                                             child: _buildLegend(
// // // //                                                 colors[entry.key % colors.length],
// // // //                                                 // 📍 [수정] 범례 금액 다국어 포맷 적용
// // // //                                                 "$categoryName (${currencyFmt.format(entry.value.amount)})",
// // // //                                                 fontSize: 9
// // // //                                             ),
// // // //                                           );
// // // //                                         }).toList(),
// // // //                                       ),
// // // //                                     ),
// // // //                                   ),
// // // //                                 ],
// // // //                               );
// // // //                             },
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //             const SizedBox(height: 30),
// // // //
// // // //             // 📍 2. Tax Data Management 섹션
// // // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             Container(
// // // //               padding: const EdgeInsets.all(16),
// // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // //               child: Column(
// // // //                 children: [
// // // //                   Container(
// // // //                     padding: const EdgeInsets.all(12),
// // // //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // // //                     child: Row(
// // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                       children: [
// // // //                         Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}"),
// // // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 20),
// // // //                   SizedBox(
// // // //                     width: double.infinity,
// // // //                     child: ElevatedButton.icon(
// // // //                       style: ElevatedButton.styleFrom(
// // // //                         backgroundColor: const Color(0xFF4CAF50),
// // // //                         foregroundColor: Colors.white,
// // // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //                       ),
// // // //                       onPressed: () async {
// // // //                         final transactions = await ref.read(ledgerListProvider.future);
// // // //                         if (transactions.isEmpty) return;
// // // //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// // // //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// // // //                       },
// // // //                       icon: const Icon(Icons.file_download),
// // // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //             const SizedBox(height: 30),
// // // //
// // // //             // 📍 3. Unpaid Management 섹션
// // // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             Container(
// // // //               padding: const EdgeInsets.all(16),
// // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // //               child: Column(
// // // //                 children: [
// // // //                   RepaintBoundary(
// // // //                     key: _unpaidCaptureKey,
// // // //                     child: Container(
// // // //                       width: double.infinity,
// // // //                       padding: const EdgeInsets.all(12),
// // // //                       decoration: BoxDecoration(
// // // //                         color: Colors.white,
// // // //                         border: Border.all(color: Colors.grey.shade300),
// // // //                         borderRadius: BorderRadius.circular(8),
// // // //                       ),
// // // //                       child: unpaidAsync.when(
// // // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // // //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// // // //                         data: (list) {
// // // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // // //                           return Column(
// // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // //                             children: [
// // // //                               Text(
// // // //                                 // 📍 [수정] 미납 총액 다국어 포맷 적용
// // // //                                   "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// // // //                                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
// // // //                               ),
// // // //                               const SizedBox(height: 8),
// // // //                               ...overdue.take(5).map((u) => Padding(
// // // //                                 padding: const EdgeInsets.symmetric(vertical: 2),
// // // //                                 // 📍 [수정] 개별 미납액 다국어 포맷 적용
// // // //                                 child: Text("• ${u.unit.roomNumber}${ 'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? '익명'}): ${currencyFmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
// // // //                               )),
// // // //                             ],
// // // //                           );
// // // //                         },
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                   const SizedBox(height: 20),
// // // //                   Row(
// // // //                     children: [
// // // //                       Expanded(
// // // //                         child: ElevatedButton.icon(
// // // //                           style: ElevatedButton.styleFrom(
// // // //                             backgroundColor: const Color(0xFF4CAF50),
// // // //                             foregroundColor: Colors.white,
// // // //                             padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //                           ),
// // // //                           onPressed: () async {
// // // //                             final list = await ref.read(unpaidListProvider.future);
// // // //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // // //                             if (overdue.isEmpty) return;
// // // //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // // //                           },
// // // //                           icon: const Icon(Icons.file_download),
// // // //                           label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(width: 10),
// // // //                       Expanded(
// // // //                         child: ElevatedButton.icon(
// // // //                           style: ElevatedButton.styleFrom(
// // // //                             backgroundColor: Colors.orangeAccent,
// // // //                             foregroundColor: Colors.white,
// // // //                             padding: const EdgeInsets.symmetric(vertical: 16),
// // // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //                           ),
// // // //                           onPressed: () => _captureAndShareImage(context, ref),
// // // //                           icon: const Icon(Icons.share_outlined),
// // // //                           label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //
// // // //             const SizedBox(height: 30),
// // // //
// // // //             // 📍 4. Annual Summary
// // // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // // //             const SizedBox(height: 10),
// // // //             Container(
// // // //               padding: const EdgeInsets.all(16),
// // // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // // //               child: monthlyTrendAsync.when(
// // // //                 loading: () => const Center(child: CircularProgressIndicator()),
// // // //                 error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// // // //                 data: (trend) {
// // // //                   final int currentYear = DateTime.now().year;
// // // //                   final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// // // //
// // // //                   int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// // // //                   int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// // // //                   int yearlyProfit = yearlyIncome - yearlyExpense;
// // // //
// // // //                   return Column(
// // // //                     children: [
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.end,
// // // //                         children: [
// // // //                           Text("${'COMMON_YEAR'.tr(ref)}: $currentYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 10),
// // // //                       // 📍 [수정] 요약 금액들 다국어 포맷 적용
// // // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// // // //                       const Divider(height: 20),
// // // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// // // //                       const Divider(height: 20),
// // // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// // // //                       const SizedBox(height: 15),
// // // //                       Text(
// // // //                         "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// // // //                         style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// // // //                       )
// // // //                     ],
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 50),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
// // // //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// // // //     return Row(
// // // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //       children: [
// // // //         Text(
// // // //           label,
// // // //           style: TextStyle(
// // // //             fontSize: 14,
// // // //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
// // // //             color: Colors.black87,
// // // //           ),
// // // //         ),
// // // //         Text(
// // // //           // 📍 국가별 통화 포맷 적용
// // // //           fmt.format(amount),
// // // //           style: TextStyle(
// // // //             fontSize: 16,
// // // //             fontWeight: FontWeight.bold,
// // // //             color: color,
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildSectionTitle(IconData icon, String title) {
// // // //     return Row(
// // // //       children: [
// // // //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// // // //         const SizedBox(width: 8),
// // // //         Text(
// // // //           title,
// // // //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// // // //     return Row(
// // // //       mainAxisSize: MainAxisSize.min,
// // // //       mainAxisAlignment: MainAxisAlignment.start,
// // // //       crossAxisAlignment: CrossAxisAlignment.center,
// // // //       children: [
// // // //         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
// // // //         const SizedBox(width: 6),
// // // //         Flexible(
// // // //           child: Text(
// // // //             label,
// // // //             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
// // // //             overflow: TextOverflow.ellipsis,
// // // //             textAlign: TextAlign.left,
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// // // //     try {
// // // //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // // //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // // //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // // //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// // // //       final tempDir = await getTemporaryDirectory();
// // // //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// // // //       await file.writeAsBytes(pngBytes);
// // // //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// // // //     } catch (e) {
// // // //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
// // // //     }
// // // //   }
// // // // }
// // //
// // //
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
// // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
// // // import '../ledger/ledger_provider.dart';
// // // import '../ledger/unpaid_provider.dart';
// // // import 'excel_export_service.dart';
// // //
// // // class ReportsScreen extends ConsumerWidget {
// // //   const ReportsScreen({super.key});
// // //
// // //   // 📍 이미지 캡처를 위한 GlobalKey
// // //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// // //
// // //   @override
// // //   Widget build(BuildContext context, WidgetRef ref) {
// // //     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
// // //     final isPro = ref.watch(isProProvider);
// // //
// // //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// // //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// // //     final unpaidAsync = ref.watch(unpaidListProvider);
// // //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// // //
// // //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// // //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// // //
// // //     // ✅ [추가] Free 사용자면 Reports 전체를 잠금 화면(Paywall)로 대체
// // //     // - "Reports / 분석 / Export" 중심으로 Pro 기능 잠금이라는 목표에 맞춰
// // //     //   ReportsScreen 자체를 Gate로 사용합니다.
// // //     // - 아직 IAP 연동 전이므로 결제 버튼은 "준비 중" 형태로 두고,
// // //     //   Restore/Reload 정도만 제공해도 충분합니다.
// // //     if (!isPro) {
// // //       return Scaffold(
// // //         backgroundColor: Colors.grey[100],
// // //         appBar: AppBar(
// // //           backgroundColor: const Color(0xFF1A237E),
// // //           foregroundColor: Colors.white,
// // //           elevation: 0,
// // //           scrolledUnderElevation: 0,
// // //           automaticallyImplyLeading: false,
// // //           centerTitle: false,
// // //           title: Text(
// // //             "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // //             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // //           ),
// // //         ),
// // //         body: _buildReportsPaywall(context, ref),
// // //       );
// // //     }
// // //
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[100],
// // //       appBar: AppBar(
// // //         backgroundColor: const Color(0xFF1A237E),
// // //         foregroundColor: Colors.white,
// // //         elevation: 0,
// // //         scrolledUnderElevation: 0,
// // //         automaticallyImplyLeading: false,
// // //         centerTitle: false,
// // //         title: Text(
// // //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// // //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // //         ),
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             // 📍 1. Financial Analytics 섹션
// // //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// // //             const SizedBox(height: 10),
// // //             Container(
// // //               height: 320,
// // //               padding: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // //               child: Row(
// // //                 children: [
// // //                   Expanded(
// // //                     flex: 3,
// // //                     child: Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // //                         const SizedBox(height: 25),
// // //                         Expanded(
// // //                           child: monthlyTrendAsync.when(
// // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // //                             error: (_, __) => const SizedBox(),
// // //                             data: (data) => BarChart(
// // //                               BarChartData(
// // //                                 barTouchData: BarTouchData(
// // //                                   enabled: false,
// // //                                   touchTooltipData: BarTouchTooltipData(
// // //                                     tooltipBgColor: Colors.transparent,
// // //                                     tooltipPadding: EdgeInsets.zero,
// // //                                     tooltipMargin: 4,
// // //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// // //                                       if (rod.toY == 0) return null;
// // //                                       return BarTooltipItem(
// // //                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
// // //                                         currencyFmt.format(rod.toY),
// // //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// // //                                       );
// // //                                     },
// // //                                   ),
// // //                                 ),
// // //                                 barGroups: data.asMap().entries.map((e) {
// // //                                   final List<int> indicators = [];
// // //                                   if (e.value.income > 0) indicators.add(0);
// // //                                   if (e.value.expense > 0) indicators.add(1);
// // //
// // //                                   return BarChartGroupData(
// // //                                     x: e.key,
// // //                                     barsSpace: 4,
// // //                                     showingTooltipIndicators: indicators,
// // //                                     barRods: [
// // //                                       BarChartRodData(
// // //                                           toY: e.value.income.toDouble(),
// // //                                           color: Colors.blue,
// // //                                           width: 8,
// // //                                           borderRadius: const BorderRadius.vertical(top: Radius.circular(2))
// // //                                       ),
// // //                                       BarChartRodData(
// // //                                           toY: e.value.expense.toDouble(),
// // //                                           color: Colors.redAccent,
// // //                                           width: 8,
// // //                                           borderRadius: const BorderRadius.vertical(top: Radius.circular(2))
// // //                                       ),
// // //                                     ],
// // //                                   );
// // //                                 }).toList(),
// // //                                 titlesData: FlTitlesData(
// // //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// // //                                   bottomTitles: AxisTitles(
// // //                                     sideTitles: SideTitles(
// // //                                       showTitles: true,
// // //                                       getTitlesWidget: (value, meta) {
// // //                                         int index = value.toInt();
// // //                                         if (index >= 0 && index < data.length) {
// // //                                           return Padding(
// // //                                             padding: const EdgeInsets.only(top: 8.0),
// // //                                             child: Text(DateFormat.MMM(lang).format(data[index].month), style: const TextStyle(fontSize: 9)),
// // //                                           );
// // //                                         }
// // //                                         return const Text('');
// // //                                       },
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                                 gridData: const FlGridData(show: false),
// // //                                 borderData: FlBorderData(show: false),
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 12),
// // //                         Row(
// // //                           mainAxisAlignment: MainAxisAlignment.start,
// // //                           children: [
// // //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// // //                             const SizedBox(width: 12),
// // //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// // //                           ],
// // //                         )
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 12),
// // //                   // 📍 연간 지출 차트 섹션
// // //                   Expanded(
// // //                     flex: 2,
// // //                     child: Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// // //                         const SizedBox(height: 10),
// // //                         Expanded(
// // //                           child: categoryStatsAsync.when(
// // //                             loading: () => const Center(child: CircularProgressIndicator()),
// // //                             error: (_, __) => const SizedBox(),
// // //                             data: (data) {
// // //                               if (data.isEmpty) return Center(child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// // //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// // //
// // //                               return Column(
// // //                                 children: [
// // //                                   Expanded(
// // //                                     flex: 3,
// // //                                     child: PieChart(
// // //                                         PieChartData(
// // //                                             sectionsSpace: 2,
// // //                                             centerSpaceRadius: 10,
// // //                                             sections: data.asMap().entries.map((entry) {
// // //                                               final double pctValue = entry.value.percentage * 100;
// // //                                               final String percentageStr = pctValue.toStringAsFixed(0);
// // //                                               final String categoryName = entry.value.category.startsWith('CAT_')
// // //                                                   ? entry.value.category.tr(ref)
// // //                                                   : entry.value.category;
// // //
// // //                                               final String sectionTitle = pctValue <= 1
// // //                                                   ? ''
// // //                                                   : '$categoryName\n($percentageStr%)';
// // //
// // //                                               return PieChartSectionData(
// // //                                                 value: entry.value.amount.toDouble(),
// // //                                                 title: sectionTitle,
// // //                                                 titleStyle: const TextStyle(
// // //                                                   fontSize: 7,
// // //                                                   fontWeight: FontWeight.bold,
// // //                                                   color: Colors.white,
// // //                                                   height: 1.2,
// // //                                                 ),
// // //                                                 color: colors[entry.key % colors.length],
// // //                                                 radius: 40,
// // //                                               );
// // //                                             }).toList()
// // //                                         )
// // //                                     ),
// // //                                   ),
// // //                                   const SizedBox(height: 12),
// // //                                   Expanded(
// // //                                     flex: 3,
// // //                                     child: SingleChildScrollView(
// // //                                       child: Column(
// // //                                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                                         children: data.asMap().entries.map((entry) {
// // //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// // //                                               ? entry.value.category.tr(ref)
// // //                                               : entry.value.category;
// // //                                           return Padding(
// // //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// // //                                             child: _buildLegend(
// // //                                                 colors[entry.key % colors.length],
// // //                                                 // 📍 [수정] 범례 금액 다국어 포맷 적용
// // //                                                 "$categoryName (${currencyFmt.format(entry.value.amount)})",
// // //                                                 fontSize: 9
// // //                                             ),
// // //                                           );
// // //                                         }).toList(),
// // //                                       ),
// // //                                     ),
// // //                                   ),
// // //                                 ],
// // //                               );
// // //                             },
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             const SizedBox(height: 30),
// // //
// // //             // 📍 2. Tax Data Management 섹션
// // //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// // //             const SizedBox(height: 10),
// // //             Container(
// // //               padding: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // //               child: Column(
// // //                 children: [
// // //                   Container(
// // //                     padding: const EdgeInsets.all(12),
// // //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// // //                     child: Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: [
// // //                         Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}"),
// // //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   SizedBox(
// // //                     width: double.infinity,
// // //                     child: ElevatedButton.icon(
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: const Color(0xFF4CAF50),
// // //                         foregroundColor: Colors.white,
// // //                         padding: const EdgeInsets.symmetric(vertical: 16),
// // //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //                       ),
// // //                       onPressed: () async {
// // //                         final transactions = await ref.read(ledgerListProvider.future);
// // //                         if (transactions.isEmpty) return;
// // //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// // //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// // //                       },
// // //                       icon: const Icon(Icons.file_download),
// // //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             const SizedBox(height: 30),
// // //
// // //             // 📍 3. Unpaid Management 섹션
// // //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// // //             const SizedBox(height: 10),
// // //             Container(
// // //               padding: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // //               child: Column(
// // //                 children: [
// // //                   RepaintBoundary(
// // //                     key: _unpaidCaptureKey,
// // //                     child: Container(
// // //                       width: double.infinity,
// // //                       padding: const EdgeInsets.all(12),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.white,
// // //                         border: Border.all(color: Colors.grey.shade300),
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                       child: unpaidAsync.when(
// // //                         loading: () => const Center(child: CircularProgressIndicator()),
// // //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// // //                         data: (list) {
// // //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// // //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// // //                           return Column(
// // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // //                             children: [
// // //                               Text(
// // //                                 // 📍 [수정] 미납 총액 다국어 포맷 적용
// // //                                   "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// // //                                   style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
// // //                               ),
// // //                               const SizedBox(height: 8),
// // //                               ...overdue.take(5).map((u) => Padding(
// // //                                 padding: const EdgeInsets.symmetric(vertical: 2),
// // //                                 // 📍 [수정] 개별 미납액 다국어 포맷 적용
// // //                                 child: Text("• ${u.unit.roomNumber}${ 'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? '익명'}): ${currencyFmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
// // //                               )),
// // //                             ],
// // //                           );
// // //                         },
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 20),
// // //                   Row(
// // //                     children: [
// // //                       Expanded(
// // //                         child: ElevatedButton.icon(
// // //                           style: ElevatedButton.styleFrom(
// // //                             backgroundColor: const Color(0xFF4CAF50),
// // //                             foregroundColor: Colors.white,
// // //                             padding: const EdgeInsets.symmetric(vertical: 16),
// // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //                           ),
// // //                           onPressed: () async {
// // //                             final list = await ref.read(unpaidListProvider.future);
// // //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// // //                             if (overdue.isEmpty) return;
// // //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// // //                           },
// // //                           icon: const Icon(Icons.file_download),
// // //                           label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                         ),
// // //                       ),
// // //                       const SizedBox(width: 10),
// // //                       Expanded(
// // //                         child: ElevatedButton.icon(
// // //                           style: ElevatedButton.styleFrom(
// // //                             backgroundColor: Colors.orangeAccent,
// // //                             foregroundColor: Colors.white,
// // //                             padding: const EdgeInsets.symmetric(vertical: 16),
// // //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //                           ),
// // //                           onPressed: () => _captureAndShareImage(context, ref),
// // //                           icon: const Icon(Icons.share_outlined),
// // //                           label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             const SizedBox(height: 30),
// // //
// // //             // 📍 4. Annual Summary
// // //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// // //             const SizedBox(height: 10),
// // //             Container(
// // //               padding: const EdgeInsets.all(16),
// // //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // //               child: monthlyTrendAsync.when(
// // //                 loading: () => const Center(child: CircularProgressIndicator()),
// // //                 error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// // //                 data: (trend) {
// // //                   final int currentYear = DateTime.now().year;
// // //                   final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// // //
// // //                   int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// // //                   int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// // //                   int yearlyProfit = yearlyIncome - yearlyExpense;
// // //
// // //                   return Column(
// // //                     children: [
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.end,
// // //                         children: [
// // //                           Text("${'COMMON_YEAR'.tr(ref)}: $currentYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 10),
// // //                       // 📍 [수정] 요약 금액들 다국어 포맷 적용
// // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// // //                       const Divider(height: 20),
// // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// // //                       const Divider(height: 20),
// // //                       _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// // //                       const SizedBox(height: 15),
// // //                       Text(
// // //                         "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// // //                         style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// // //                       )
// // //                     ],
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //             const SizedBox(height: 50),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [추가] Reports 전용 Paywall(잠금) UI
// // //   // - 아직 IAP 연동 전이므로 결제 버튼은 “준비 중”으로 두고
// // //   // - Restore/Reload 등 사용자 행동만 제공해도 충분합니다.
// // //   Widget _buildReportsPaywall(BuildContext context, WidgetRef ref) {
// // //     return SingleChildScrollView(
// // //       padding: const EdgeInsets.all(16),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // 📍 섹션 타이틀 형태를 유지하면서 "잠금" 메시지를 표시합니다.
// // //           _buildSectionTitle(Icons.lock_outline, "SiRE Pro"),
// // //           const SizedBox(height: 10),
// // //           Container(
// // //             width: double.infinity,
// // //             padding: const EdgeInsets.all(16),
// // //             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 const Text(
// // //                   "Reports / 분석 / Export 기능은 Pro에서 제공됩니다.",
// // //                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 const Text(
// // //                   "• Financial Analytics (월별 추세 / 카테고리 분석)\n"
// // //                       "• Tax Excel Export\n"
// // //                       "• Unpaid Excel Export / Image Share\n"
// // //                       "• Annual Summary",
// // //                   style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
// // //                 ),
// // //                 const SizedBox(height: 16),
// // //
// // //                 // ✅ [정리] IAP 연동 전 단계에서는 구매 버튼을 활성화하지 않습니다.
// // //                 // - Step 3에서 in_app_purchase 연결 후 "구매" 버튼을 연결할 예정입니다.
// // //                 SizedBox(
// // //                   width: double.infinity,
// // //                   child: ElevatedButton.icon(
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFF1A237E),
// // //                       foregroundColor: Colors.white,
// // //                       padding: const EdgeInsets.symmetric(vertical: 14),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //                     ),
// // //                     onPressed: () {
// // //                       showDialog(
// // //                         context: context,
// // //                         builder: (_) => AlertDialog(
// // //                           title: const Text('Pro 결제'),
// // //                           content: const Text('인앱 결제 연동은 다음 단계에서 연결할 예정입니다.'),
// // //                           actions: [
// // //                             TextButton(
// // //                               onPressed: () => Navigator.of(context).pop(),
// // //                               child: const Text('OK'),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       );
// // //                     },
// // //                     icon: const Icon(Icons.workspace_premium_outlined),
// // //                     label: const Text("Pro 구매 (준비 중)", style: TextStyle(fontWeight: FontWeight.bold)),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 10),
// // //
// // //                 // ✅ Restore/Reload 버튼: 현재는 로컬 상태 reload 정도만 제공
// // //                 SizedBox(
// // //                   width: double.infinity,
// // //                   child: OutlinedButton.icon(
// // //                     style: OutlinedButton.styleFrom(
// // //                       padding: const EdgeInsets.symmetric(vertical: 14),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // //                     ),
// // //                     onPressed: () async {
// // //                       await ref.read(purchaseControllerProvider.notifier).reload();
// // //
// // //                       // 로컬 reload 결과는 즉시 반영되며, 스낵바로 안내합니다.
// // //                       if (context.mounted) {
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           const SnackBar(content: Text("구매 상태를 다시 확인했습니다.")),
// // //                         );
// // //                       }
// // //                     },
// // //                     icon: const Icon(Icons.restore),
// // //                     label: const Text("구매 복원/상태 새로고침"),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
// // //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// // //     return Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         Text(
// // //           label,
// // //           style: TextStyle(
// // //             fontSize: 14,
// // //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
// // //             color: Colors.black87,
// // //           ),
// // //         ),
// // //         Text(
// // //           // 📍 국가별 통화 포맷 적용
// // //           fmt.format(amount),
// // //           style: TextStyle(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.bold,
// // //             color: color,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildSectionTitle(IconData icon, String title) {
// // //     return Row(
// // //       children: [
// // //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// // //         const SizedBox(width: 8),
// // //         Text(
// // //           title,
// // //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// // //     return Row(
// // //       mainAxisSize: MainAxisSize.min,
// // //       mainAxisAlignment: MainAxisAlignment.start,
// // //       crossAxisAlignment: CrossAxisAlignment.center,
// // //       children: [
// // //         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
// // //         const SizedBox(width: 6),
// // //         Flexible(
// // //           child: Text(
// // //             label,
// // //             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
// // //             overflow: TextOverflow.ellipsis,
// // //             textAlign: TextAlign.left,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// // //     try {
// // //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// // //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// // //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// // //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// // //       final tempDir = await getTemporaryDirectory();
// // //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// // //       await file.writeAsBytes(pngBytes);
// // //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// // //     } catch (e) {
// // //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
// // //     }
// // //   }
// // // }
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
// // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // import '../../core/purchase/models/purchase_status.dart';
// // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
// //
// // // ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
// // import '../../core/purchase/ui/paywall_screen.dart';
// //
// // import '../ledger/ledger_provider.dart';
// // import '../ledger/unpaid_provider.dart';
// // import 'excel_export_service.dart';
// //
// // class ReportsScreen extends ConsumerWidget {
// //   const ReportsScreen({super.key});
// //
// //   // 📍 이미지 캡처를 위한 GlobalKey
// //   static final GlobalKey _unpaidCaptureKey = GlobalKey();
// //
// //   // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
// //   // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
// //   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
// //
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
// //     final isPro = ref.watch(isProProvider);
// //
// //     // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
// //     // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
// //     final purchaseState = ref.watch(purchaseControllerProvider);
// //
// //     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
// //     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
// //     final unpaidAsync = ref.watch(unpaidListProvider);
// //     final lang = ref.watch(localizationProvider.notifier).currentLang;
// //
// //     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
// //     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
// //
// //     // -------------------------------------------------------------------------
// //     // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
// //     // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
// //     // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
// //     //
// //     // ✅ [중요]
// //     // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
// //     // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
// //     // -------------------------------------------------------------------------
// //     ref.listen<bool>(isProProvider, (prev, next) {
// //       // ✅ Pro → Free로 바뀌는 순간만 감지
// //       if (prev == true && next == false) {
// //         final alreadyShown = ref.read(_proDisabledToastShownProvider);
// //         if (alreadyShown) return;
// //
// //         // ✅ 플래그 ON (연속 표시 방지)
// //         ref.read(_proDisabledToastShownProvider.notifier).state = true;
// //
// //         // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
// //         if (context.mounted) {
// //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text("Google Play 환불 또는 구매 취소로 인해 Pro가 비활성화되었습니다."),
// //               behavior: SnackBarBehavior.floating,
// //             ),
// //           );
// //         }
// //       }
// //
// //       // ✅ Free → Pro로 복구되면(재구매/복원 등)
// //       // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
// //       if (prev == false && next == true) {
// //         ref.read(_proDisabledToastShownProvider.notifier).state = false;
// //       }
// //     });
// //
// //     // ✅ [2번 적용] Free 사용자면 Reports 전체를 공용 PaywallScreen으로 대체
// //     // - ReportsScreen에 Paywall UI/구매 로직을 넣지 않습니다.
// //     // - PaywallScreen은 다른 기능 화면에서도 재사용 가능합니다.
// //     if (!isPro) {
// //       return const PaywallScreen();
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF1A237E),
// //         foregroundColor: Colors.white,
// //         elevation: 0,
// //         scrolledUnderElevation: 0,
// //         automaticallyImplyLeading: false,
// //         centerTitle: false,
// //         title: Text(
// //           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
// //           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // 📍 1. Financial Analytics 섹션
// //             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
// //             const SizedBox(height: 10),
// //             Container(
// //               height: 320,
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     flex: 3,
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// //                         const SizedBox(height: 25),
// //                         Expanded(
// //                           child: monthlyTrendAsync.when(
// //                             loading: () => const Center(child: CircularProgressIndicator()),
// //                             error: (_, __) => const SizedBox(),
// //                             data: (data) => BarChart(
// //                               BarChartData(
// //                                 barTouchData: BarTouchData(
// //                                   enabled: false,
// //                                   touchTooltipData: BarTouchTooltipData(
// //                                     tooltipBgColor: Colors.transparent,
// //                                     tooltipPadding: EdgeInsets.zero,
// //                                     tooltipMargin: 4,
// //                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
// //                                       if (rod.toY == 0) return null;
// //                                       return BarTooltipItem(
// //                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
// //                                         currencyFmt.format(rod.toY),
// //                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
// //                                       );
// //                                     },
// //                                   ),
// //                                 ),
// //                                 barGroups: data.asMap().entries.map((e) {
// //                                   final List<int> indicators = [];
// //                                   if (e.value.income > 0) indicators.add(0);
// //                                   if (e.value.expense > 0) indicators.add(1);
// //
// //                                   return BarChartGroupData(
// //                                     x: e.key,
// //                                     barsSpace: 4,
// //                                     showingTooltipIndicators: indicators,
// //                                     barRods: [
// //                                       BarChartRodData(
// //                                         toY: e.value.income.toDouble(),
// //                                         color: Colors.blue,
// //                                         width: 8,
// //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// //                                       ),
// //                                       BarChartRodData(
// //                                         toY: e.value.expense.toDouble(),
// //                                         color: Colors.redAccent,
// //                                         width: 8,
// //                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
// //                                       ),
// //                                     ],
// //                                   );
// //                                 }).toList(),
// //                                 titlesData: FlTitlesData(
// //                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// //                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// //                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
// //                                   bottomTitles: AxisTitles(
// //                                     sideTitles: SideTitles(
// //                                       showTitles: true,
// //                                       getTitlesWidget: (value, meta) {
// //                                         int index = value.toInt();
// //                                         if (index >= 0 && index < data.length) {
// //                                           return Padding(
// //                                             padding: const EdgeInsets.only(top: 8.0),
// //                                             child: Text(DateFormat.MMM(lang).format(data[index].month), style: const TextStyle(fontSize: 9)),
// //                                           );
// //                                         }
// //                                         return const Text('');
// //                                       },
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 gridData: const FlGridData(show: false),
// //                                 borderData: FlBorderData(show: false),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 12),
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.start,
// //                           children: [
// //                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
// //                             const SizedBox(width: 12),
// //                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
// //                           ],
// //                         )
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   // 📍 연간 지출 차트 섹션
// //                   Expanded(
// //                     flex: 2,
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
// //                         const SizedBox(height: 10),
// //                         Expanded(
// //                           child: categoryStatsAsync.when(
// //                             loading: () => const Center(child: CircularProgressIndicator()),
// //                             error: (_, __) => const SizedBox(),
// //                             data: (data) {
// //                               if (data.isEmpty) return Center(child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
// //                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
// //
// //                               return Column(
// //                                 children: [
// //                                   Expanded(
// //                                     flex: 3,
// //                                     child: PieChart(
// //                                       PieChartData(
// //                                         sectionsSpace: 2,
// //                                         centerSpaceRadius: 10,
// //                                         sections: data.asMap().entries.map((entry) {
// //                                           final double pctValue = entry.value.percentage * 100;
// //                                           final String percentageStr = pctValue.toStringAsFixed(0);
// //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// //                                               ? entry.value.category.tr(ref)
// //                                               : entry.value.category;
// //
// //                                           final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';
// //
// //                                           return PieChartSectionData(
// //                                             value: entry.value.amount.toDouble(),
// //                                             title: sectionTitle,
// //                                             titleStyle: const TextStyle(
// //                                               fontSize: 7,
// //                                               fontWeight: FontWeight.bold,
// //                                               color: Colors.white,
// //                                               height: 1.2,
// //                                             ),
// //                                             color: colors[entry.key % colors.length],
// //                                             radius: 40,
// //                                           );
// //                                         }).toList(),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 12),
// //                                   Expanded(
// //                                     flex: 3,
// //                                     child: SingleChildScrollView(
// //                                       child: Column(
// //                                         crossAxisAlignment: CrossAxisAlignment.start,
// //                                         children: data.asMap().entries.map((entry) {
// //                                           final String categoryName = entry.value.category.startsWith('CAT_')
// //                                               ? entry.value.category.tr(ref)
// //                                               : entry.value.category;
// //                                           return Padding(
// //                                             padding: const EdgeInsets.symmetric(vertical: 3),
// //                                             child: _buildLegend(
// //                                               colors[entry.key % colors.length],
// //                                               // 📍 [수정] 범례 금액 다국어 포맷 적용
// //                                               "$categoryName (${currencyFmt.format(entry.value.amount)})",
// //                                               fontSize: 9,
// //                                             ),
// //                                           );
// //                                         }).toList(),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               );
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 30),
// //
// //             // 📍 2. Tax Data Management 섹션
// //             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
// //             const SizedBox(height: 10),
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// //               child: Column(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}"),
// //                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF4CAF50),
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                       ),
// //                       onPressed: () async {
// //                         final transactions = await ref.read(ledgerListProvider.future);
// //                         if (transactions.isEmpty) return;
// //                         final pureTransactions = transactions.map((e) => e.transaction).toList();
// //                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
// //                       },
// //                       icon: const Icon(Icons.file_download),
// //                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 30),
// //
// //             // 📍 3. Unpaid Management 섹션
// //             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
// //             const SizedBox(height: 10),
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// //               child: Column(
// //                 children: [
// //                   RepaintBoundary(
// //                     key: _unpaidCaptureKey,
// //                     child: Container(
// //                       width: double.infinity,
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         border: Border.all(color: Colors.grey.shade300),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: unpaidAsync.when(
// //                         loading: () => const Center(child: CircularProgressIndicator()),
// //                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
// //                         data: (list) {
// //                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// //                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
// //                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
// //                           return Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 // 📍 [수정] 미납 총액 다국어 포맷 적용
// //                                 "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
// //                                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// //                               ),
// //                               const SizedBox(height: 8),
// //                               ...overdue.take(5).map(
// //                                     (u) => Padding(
// //                                   padding: const EdgeInsets.symmetric(vertical: 2),
// //                                   // 📍 [수정] 개별 미납액 다국어 포맷 적용
// //                                   child: Text(
// //                                     "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? '익명'}): ${currencyFmt.format(u.unit.monthlyRent)}",
// //                                     style: const TextStyle(fontSize: 12, color: Colors.black87),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF4CAF50),
// //                             foregroundColor: Colors.white,
// //                             padding: const EdgeInsets.symmetric(vertical: 16),
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                           ),
// //                           onPressed: () async {
// //                             final list = await ref.read(unpaidListProvider.future);
// //                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
// //                             if (overdue.isEmpty) return;
// //                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
// //                           },
// //                           icon: const Icon(Icons.file_download),
// //                           label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.orangeAccent,
// //                             foregroundColor: Colors.white,
// //                             padding: const EdgeInsets.symmetric(vertical: 16),
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                           ),
// //                           onPressed: () => _captureAndShareImage(context, ref),
// //                           icon: const Icon(Icons.share_outlined),
// //                           label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 30),
// //
// //             // 📍 4. Annual Summary
// //             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
// //             const SizedBox(height: 10),
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
// //               child: monthlyTrendAsync.when(
// //                 loading: () => const Center(child: CircularProgressIndicator()),
// //                 error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
// //                 data: (trend) {
// //                   final int currentYear = DateTime.now().year;
// //                   final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
// //
// //                   int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
// //                   int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
// //                   int yearlyProfit = yearlyIncome - yearlyExpense;
// //
// //                   return Column(
// //                     children: [
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.end,
// //                         children: [
// //                           Text(
// //                             "${'COMMON_YEAR'.tr(ref)}: $currentYear",
// //                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       // 📍 [수정] 요약 금액들 다국어 포맷 적용
// //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
// //                       const Divider(height: 20),
// //                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
// //                       const Divider(height: 20),
// //                       _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
// //                       const SizedBox(height: 15),
// //                       Text(
// //                         "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
// //                         style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
// //                       )
// //                     ],
// //                   );
// //                 },
// //               ),
// //             ),
// //             const SizedBox(height: 50),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
// //   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 14,
// //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         Text(
// //           // 📍 국가별 통화 포맷 적용
// //           fmt.format(amount),
// //           style: TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.bold,
// //             color: color,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildSectionTitle(IconData icon, String title) {
// //     return Row(
// //       children: [
// //         Icon(icon, size: 22, color: const Color(0xFF1A237E)),
// //         const SizedBox(width: 8),
// //         Text(
// //           title,
// //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
// //     return Row(
// //       mainAxisSize: MainAxisSize.min,
// //       mainAxisAlignment: MainAxisAlignment.start,
// //       crossAxisAlignment: CrossAxisAlignment.center,
// //       children: [
// //         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
// //         const SizedBox(width: 6),
// //         Flexible(
// //           child: Text(
// //             label,
// //             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
// //             overflow: TextOverflow.ellipsis,
// //             textAlign: TextAlign.left,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
// //     try {
// //       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //       Uint8List pngBytes = byteData!.buffer.asUint8List();
// //       final tempDir = await getTemporaryDirectory();
// //       final file = await File('${tempDir.path}/unpaid_report.png').create();
// //       await file.writeAsBytes(pngBytes);
// //       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
// //     } catch (e) {
// //       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
// //     }
// //   }
// // }
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
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../../core/purchase/models/purchase_status.dart';
// import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider
//
// // ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
// import '../../core/purchase/ui/paywall_screen.dart';
//
// import '../ledger/ledger_provider.dart';
// import '../ledger/unpaid_provider.dart';
// import 'excel_export_service.dart';
//
// class ReportsScreen extends ConsumerWidget {
//   const ReportsScreen({super.key});
//
//   // 📍 이미지 캡처를 위한 GlobalKey
//   static final GlobalKey _unpaidCaptureKey = GlobalKey();
//
//   // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
//   // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
//   static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
//     final isPro = ref.watch(isProProvider);
//
//     // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
//     // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
//     // ignore: unused_local_variable
//     final purchaseState = ref.watch(purchaseControllerProvider);
//
//     final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
//     final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
//     final unpaidAsync = ref.watch(unpaidListProvider);
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//
//     // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
//     final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
//
//     // -------------------------------------------------------------------------
//     // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
//     // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
//     // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
//     //
//     // ✅ [중요]
//     // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
//     // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
//     // -------------------------------------------------------------------------
//     ref.listen<bool>(isProProvider, (prev, next) {
//       // ✅ Pro → Free로 바뀌는 순간만 감지
//       if (prev == true && next == false) {
//         final alreadyShown = ref.read(_proDisabledToastShownProvider);
//         if (alreadyShown) return;
//
//         // ✅ 플래그 ON (연속 표시 방지)
//         ref.read(_proDisabledToastShownProvider.notifier).state = true;
//
//         // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("REPORT_PRO_DISABLED_BY_REFUND".tr(ref)),
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         }
//       }
//
//       // ✅ Free → Pro로 복구되면(재구매/복원 등)
//       // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
//       if (prev == false && next == true) {
//         ref.read(_proDisabledToastShownProvider.notifier).state = false;
//       }
//     });
//
//     // ✅ [2번 적용] Free 사용자면 Reports 전체를 공용 PaywallScreen으로 대체
//     // - ReportsScreen에 Paywall UI/구매 로직을 넣지 않습니다.
//     // - PaywallScreen은 다른 기능 화면에서도 재사용 가능합니다.
//     if (!isPro) {
//       return const PaywallScreen();
//     }
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
//           "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
//           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 📍 1. Financial Analytics 섹션
//             _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
//             const SizedBox(height: 10),
//             Container(
//               height: 320,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 25),
//                         Expanded(
//                           child: monthlyTrendAsync.when(
//                             loading: () => const Center(child: CircularProgressIndicator()),
//                             error: (_, __) => const SizedBox(),
//                             data: (data) => BarChart(
//                               BarChartData(
//                                 barTouchData: BarTouchData(
//                                   enabled: false,
//                                   touchTooltipData: BarTouchTooltipData(
//                                     tooltipBgColor: Colors.transparent,
//                                     tooltipPadding: EdgeInsets.zero,
//                                     tooltipMargin: 4,
//                                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                                       if (rod.toY == 0) return null;
//                                       return BarTooltipItem(
//                                         // 📍 [수정] 툴팁 금액 다국어 포맷 적용
//                                         currencyFmt.format(rod.toY),
//                                         TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 barGroups: data.asMap().entries.map((e) {
//                                   final List<int> indicators = [];
//                                   if (e.value.income > 0) indicators.add(0);
//                                   if (e.value.expense > 0) indicators.add(1);
//
//                                   return BarChartGroupData(
//                                     x: e.key,
//                                     barsSpace: 4,
//                                     showingTooltipIndicators: indicators,
//                                     barRods: [
//                                       BarChartRodData(
//                                         toY: e.value.income.toDouble(),
//                                         color: Colors.blue,
//                                         width: 8,
//                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
//                                       ),
//                                       BarChartRodData(
//                                         toY: e.value.expense.toDouble(),
//                                         color: Colors.redAccent,
//                                         width: 8,
//                                         borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
//                                       ),
//                                     ],
//                                   );
//                                 }).toList(),
//                                 titlesData: FlTitlesData(
//                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                                   bottomTitles: AxisTitles(
//                                     sideTitles: SideTitles(
//                                       showTitles: true,
//                                       getTitlesWidget: (value, meta) {
//                                         int index = value.toInt();
//                                         if (index >= 0 && index < data.length) {
//                                           return Padding(
//                                             padding: const EdgeInsets.only(top: 8.0),
//                                             child: Text(DateFormat.MMM(lang).format(data[index].month), style: const TextStyle(fontSize: 9)),
//                                           );
//                                         }
//                                         return const Text('');
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 gridData: const FlGridData(show: false),
//                                 borderData: FlBorderData(show: false),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
//                             const SizedBox(width: 12),
//                             _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // 📍 연간 지출 차트 섹션
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 10),
//                         Expanded(
//                           child: categoryStatsAsync.when(
//                             loading: () => const Center(child: CircularProgressIndicator()),
//                             error: (_, __) => const SizedBox(),
//                             data: (data) {
//                               if (data.isEmpty) return Center(child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
//                               final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];
//
//                               return Column(
//                                 children: [
//                                   Expanded(
//                                     flex: 3,
//                                     child: PieChart(
//                                       PieChartData(
//                                         sectionsSpace: 2,
//                                         centerSpaceRadius: 10,
//                                         sections: data.asMap().entries.map((entry) {
//                                           final double pctValue = entry.value.percentage * 100;
//                                           final String percentageStr = pctValue.toStringAsFixed(0);
//                                           final String categoryName = entry.value.category.startsWith('CAT_')
//                                               ? entry.value.category.tr(ref)
//                                               : entry.value.category;
//
//                                           final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';
//
//                                           return PieChartSectionData(
//                                             value: entry.value.amount.toDouble(),
//                                             title: sectionTitle,
//                                             titleStyle: const TextStyle(
//                                               fontSize: 7,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                               height: 1.2,
//                                             ),
//                                             color: colors[entry.key % colors.length],
//                                             radius: 40,
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Expanded(
//                                     flex: 3,
//                                     child: SingleChildScrollView(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: data.asMap().entries.map((entry) {
//                                           final String categoryName = entry.value.category.startsWith('CAT_')
//                                               ? entry.value.category.tr(ref)
//                                               : entry.value.category;
//                                           return Padding(
//                                             padding: const EdgeInsets.symmetric(vertical: 3),
//                                             child: _buildLegend(
//                                               colors[entry.key % colors.length],
//                                               // 📍 [수정] 범례 금액 다국어 포맷 적용
//                                               "$categoryName (${currencyFmt.format(entry.value.amount)})",
//                                               fontSize: 9,
//                                             ),
//                                           );
//                                         }).toList(),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // 📍 2. Tax Data Management 섹션
//             _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}"),
//                         const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF4CAF50),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       onPressed: () async {
//                         final transactions = await ref.read(ledgerListProvider.future);
//                         if (transactions.isEmpty) return;
//                         final pureTransactions = transactions.map((e) => e.transaction).toList();
//                         await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
//                       },
//                       icon: const Icon(Icons.file_download),
//                       label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // 📍 3. Unpaid Management 섹션
//             _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 children: [
//                   RepaintBoundary(
//                     key: _unpaidCaptureKey,
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: unpaidAsync.when(
//                         loading: () => const Center(child: CircularProgressIndicator()),
//                         error: (_, __) => Text("COMMON_ERROR".tr(ref)),
//                         data: (list) {
//                           final overdue = list.where((u) => u.status == 'OVERDUE').toList();
//                           final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
//                           if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 // 📍 [수정] 미납 총액 다국어 포맷 적용
//                                 "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
//                                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8),
//                               ...overdue.take(5).map(
//                                     (u) => Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 2),
//                                   // 📍 [수정] 개별 미납액 다국어 포맷 적용
//                                   child: Text(
//                                     "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? 'COMMON_ANONYMOUS'.tr(ref)}): ${currencyFmt.format(u.unit.monthlyRent)}",
//                                     style: const TextStyle(fontSize: 12, color: Colors.black87),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4CAF50),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           onPressed: () async {
//                             final list = await ref.read(unpaidListProvider.future);
//                             final overdue = list.where((u) => u.status == 'OVERDUE').toList();
//                             if (overdue.isEmpty) return;
//                             await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
//                           },
//                           icon: const Icon(Icons.file_download),
//                           label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orangeAccent,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           onPressed: () => _captureAndShareImage(context, ref),
//                           icon: const Icon(Icons.share_outlined),
//                           label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             // 📍 4. Annual Summary
//             _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//               child: monthlyTrendAsync.when(
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
//                 data: (trend) {
//                   final int currentYear = DateTime.now().year;
//                   final currentYearData = trend.where((item) => item.month.year == currentYear).toList();
//
//                   int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
//                   int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
//                   int yearlyProfit = yearlyIncome - yearlyExpense;
//
//                   return Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text(
//                             "${'COMMON_YEAR'.tr(ref)}: $currentYear",
//                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       // 📍 [수정] 요약 금액들 다국어 포맷 적용
//                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
//                       const Divider(height: 20),
//                       _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
//                       const Divider(height: 20),
//                       _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
//                       const SizedBox(height: 15),
//                       Text(
//                         "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
//                         style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
//                       )
//                     ],
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 50),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 📍 [수정] 요약 표 행 빌더에 포매터 추가
//   Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: Colors.black87,
//           ),
//         ),
//         Text(
//           // 📍 국가별 통화 포맷 적용
//           fmt.format(amount),
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
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
//
//   Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 6),
//         Flexible(
//           child: Text(
//             label,
//             style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.left,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
//     try {
//       RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();
//       final tempDir = await getTemporaryDirectory();
//       final file = await File('${tempDir.path}/unpaid_report.png').create();
//       await file.writeAsBytes(pngBytes);
//       await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
//     } catch (e) {
//       if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
//     }
//   }
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
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/purchase/models/purchase_status.dart';
import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 잠금(Gate)용 Provider

// ✅ [2번 적용] Reports에서 Paywall UI를 직접 들고 있지 않고, 공용 PaywallScreen을 사용합니다.
import '../../core/purchase/ui/paywall_screen.dart';

import '../ledger/ledger_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'excel_export_service.dart';

// ✅ [추가] Pro 인사이트 서비스
import 'financial_insight_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  // 📍 이미지 캡처를 위한 GlobalKey
  static final GlobalKey _unpaidCaptureKey = GlobalKey();

  // ✅ [2번 적용] "Pro 해제됨" 메시지를 테스트로 1회만 띄우기 위한 플래그
  // - build가 여러 번 호출될 수 있으므로 스낵바가 연속으로 뜨는 것을 방지합니다.
  static final _proDisabledToastShownProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ [추가] Pro 여부 체크 (Reports 화면부터 Pro 잠금 적용)
    final isPro = ref.watch(isProProvider);

    // ✅ [추가] 결제 상태(로딩/에러)도 함께 사용 (Paywall 버튼 비활성화, 메시지 표시 등)
    // - PaywallScreen 내부에서도 상태를 사용할 수 있으므로, ReportsScreen에서 직접 쓰지 않아도 됩니다.
    // ignore: unused_local_variable
    final purchaseState = ref.watch(purchaseControllerProvider);

    final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
    final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final lang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
    final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

    // -------------------------------------------------------------------------
    // ✅ [2번 적용] Pro → Free 전환(환불/취소/소유권 회수 등) 감지 시:
    // 1) Paywall로 전환되는 것(아래 if(!isPro)로 자동 처리)
    // 2) "메시지가 뜨는지만" 테스트할 수 있도록 스낵바 1회 표시
    //
    // ✅ [중요]
    // - 자동 구매 다이얼로그/자동 팝업은 "깜빡임/연속 팝업" 원인이 될 수 있어 제거했습니다.
    // - 지금 단계에서는 "환불되면 Pro가 해제되었다는 신호가 UI에 보이는지"만 확인합니다.
    // -------------------------------------------------------------------------
    ref.listen<bool>(isProProvider, (prev, next) {
      // ✅ Pro → Free로 바뀌는 순간만 감지
      if (prev == true && next == false) {
        final alreadyShown = ref.read(_proDisabledToastShownProvider);
        if (alreadyShown) return;

        // ✅ 플래그 ON (연속 표시 방지)
        ref.read(_proDisabledToastShownProvider.notifier).state = true;

        // ✅ 토스트/배너(스낵바) 표시: "Pro 해제됨" (테스트 용)
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("REPORT_PRO_DISABLED_BY_REFUND".tr(ref)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // ✅ Free → Pro로 복구되면(재구매/복원 등)
      // 다음번 Pro→Free 전환에서도 다시 메시지를 띄울 수 있도록 플래그를 리셋합니다.
      if (prev == false && next == true) {
        ref.read(_proDisabledToastShownProvider.notifier).state = false;
      }
    });

    // ✅ [2번 적용] Free 사용자면 Reports 전체를 공용 PaywallScreen으로 대체
    // - ReportsScreen에 Paywall UI/구매 로직을 넣지 않습니다.
    // - PaywallScreen은 다른 기능 화면에서도 재사용 가능합니다.
    if (!isPro) {
      return const PaywallScreen();
    }

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
          "NAV_REPORTS".tr(ref), // 📍 다국어: "Reports"
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // ✅ [추가] Pro 인사이트 카드 (데이터 → 해석 → 경고)
            // // - 차트보다 먼저 보여 사용자 가치 체감 강화
            // // - monthlyTrendAsync + unpaidAsync에서 필요한 값만 안전하게 추출해 생성
            // Builder(
            //   builder: (context) {
            //     int thisMonthIncome = 0;
            //     int thisMonthExpense = 0;
            //     int lastMonthExpense = 0;
            //
            //     // monthlyTrendAsync: 이번 달 / 지난 달 지출 비교
            //     monthlyTrendAsync.whenData((data) {
            //       if (data.isEmpty) return;
            //
            //       final now = DateTime.now();
            //       final thisMonthItem = data.where((e) =>
            //       e.month.year == now.year && e.month.month == now.month).toList();
            //       if (thisMonthItem.isNotEmpty) {
            //         thisMonthIncome = thisMonthItem.first.income;
            //         thisMonthExpense = thisMonthItem.first.expense;
            //       }
            //
            //       final last = DateTime(now.year, now.month - 1, 1);
            //       final lastMonthItem = data.where((e) =>
            //       e.month.year == last.year && e.month.month == last.month).toList();
            //       if (lastMonthItem.isNotEmpty) {
            //         lastMonthExpense = lastMonthItem.first.expense;
            //       }
            //     });
            //
            //     // unpaidAsync: 미납 존재 여부
            //     bool hasUnpaid = false;
            //     unpaidAsync.whenData((list) {
            //       final overdue = list.where((u) => u.status == 'OVERDUE').toList();
            //       hasUnpaid = overdue.isNotEmpty;
            //     });
            //
            //     final insights = FinancialInsightService.generate(
            //       thisMonthIncome: thisMonthIncome,
            //       thisMonthExpense: thisMonthExpense,
            //       lastMonthExpense: lastMonthExpense,
            //       hasUnpaid: hasUnpaid,
            //     );
            //
            //     return Column(
            //       children: [
            //         _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
            //         const SizedBox(height: 10),
            //         ...insights.map((i) => _buildInsightCard(ref, i)).toList(),
            //         const SizedBox(height: 20),
            //       ],
            //     );
            //   },
            // ),

            // ✅ [추가] Pro 인사이트 카드 (데이터 → 해석 → 경고)
            monthlyTrendAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (trendData) {
                return unpaidAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (unpaidList) {
                    int thisMonthIncome = 0;
                    int thisMonthExpense = 0;
                    int lastMonthExpense = 0;

                    final now = DateTime.now();

                    // ✅ 이번 달 데이터
                    final thisMonthItem = trendData.where((e) =>
                    e.month.year == now.year && e.month.month == now.month).toList();
                    if (thisMonthItem.isNotEmpty) {
                      thisMonthIncome = thisMonthItem.first.income;
                      thisMonthExpense = thisMonthItem.first.expense;
                    }

                    // ✅ 지난 달 데이터
                    final last = DateTime(now.year, now.month - 1, 1);
                    final lastMonthItem = trendData.where((e) =>
                    e.month.year == last.year && e.month.month == last.month).toList();
                    if (lastMonthItem.isNotEmpty) {
                      lastMonthExpense = lastMonthItem.first.expense;
                    }

                    // ✅ 미납 여부
                    final overdue = unpaidList.where((u) => u.status == 'OVERDUE').toList();
                    final hasUnpaid = overdue.isNotEmpty;

                    final insights = FinancialInsightService.generate(
                      thisMonthIncome: thisMonthIncome,
                      thisMonthExpense: thisMonthExpense,
                      lastMonthExpense: lastMonthExpense,
                      hasUnpaid: hasUnpaid,
                    );

                    // ✅ 인사이트가 없으면 섹션 자체를 숨겨도 되고,
                    // 안정 메시지를 서비스에서 항상 1개라도 반환하게 해도 됨.
                    if (insights.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.lightbulb_outline, "REPORT_SEC_INSIGHTS".tr(ref)),
                        const SizedBox(height: 10),
                        ...insights.map((i) => _buildInsightCard(ref, i)).toList(),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                );
              },
            ),


            // 📍 1. Financial Analytics 섹션
            _buildSectionTitle(Icons.analytics_outlined, "REPORT_SEC_FINANCIAL".tr(ref)),
            const SizedBox(height: 10),
            Container(
              height: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REPORT_MONTHLY_TREND_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 25),
                        Expanded(
                          child: monthlyTrendAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox(),
                            data: (data) => BarChart(
                              BarChartData(
                                barTouchData: BarTouchData(
                                  enabled: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.transparent,
                                    tooltipPadding: EdgeInsets.zero,
                                    tooltipMargin: 4,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      if (rod.toY == 0) return null;
                                      return BarTooltipItem(
                                        // 📍 [수정] 툴팁 금액 다국어 포맷 적용
                                        currencyFmt.format(rod.toY),
                                        TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 9),
                                      );
                                    },
                                  ),
                                ),
                                barGroups: data.asMap().entries.map((e) {
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
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                      BarChartRodData(
                                        toY: e.value.expense.toDouble(),
                                        color: Colors.redAccent,
                                        width: 8,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 && index < data.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(DateFormat.MMM(lang).format(data[index].month), style: const TextStyle(fontSize: 9)),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildLegend(Colors.blue, "COMMON_INCOME".tr(ref)),
                            const SizedBox(width: 12),
                            _buildLegend(Colors.redAccent, "COMMON_EXPENSE".tr(ref)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 📍 연간 지출 차트 섹션
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REPORT_ANNUAL_EXPENSE_TITLE".tr(ref), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: categoryStatsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox(),
                            data: (data) {
                              if (data.isEmpty) return Center(child: Text("REPORT_NO_DATA".tr(ref), style: const TextStyle(fontSize: 10)));
                              final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.brown, Colors.purple];

                              return Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 10,
                                        sections: data.asMap().entries.map((entry) {
                                          final double pctValue = entry.value.percentage * 100;
                                          final String percentageStr = pctValue.toStringAsFixed(0);
                                          final String categoryName = entry.value.category.startsWith('CAT_')
                                              ? entry.value.category.tr(ref)
                                              : entry.value.category;

                                          final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';

                                          return PieChartSectionData(
                                            value: entry.value.amount.toDouble(),
                                            title: sectionTitle,
                                            titleStyle: const TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              height: 1.2,
                                            ),
                                            color: colors[entry.key % colors.length],
                                            radius: 40,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    flex: 3,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: data.asMap().entries.map((entry) {
                                          final String categoryName = entry.value.category.startsWith('CAT_')
                                              ? entry.value.category.tr(ref)
                                              : entry.value.category;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3),
                                            child: _buildLegend(
                                              colors[entry.key % colors.length],
                                              // 📍 [수정] 범례 금액 다국어 포맷 적용
                                              "$categoryName (${currencyFmt.format(entry.value.amount)})",
                                              fontSize: 9,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📍 2. Tax Data Management 섹션
            _buildSectionTitle(Icons.assessment_outlined, "REPORT_SEC_TAX".tr(ref)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${'REPORT_TAX_PERIOD'.tr(ref)}: ${DateFormat('yyyy.01.01').format(DateTime.now())} - ${'COMMON_TODAY'.tr(ref)}"),
                        const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final transactions = await ref.read(ledgerListProvider.future);
                        if (transactions.isEmpty) return;
                        final pureTransactions = transactions.map((e) => e.transaction).toList();
                        await ExcelExportService().exportTransactionsToExcel(pureTransactions, ref);
                      },
                      icon: const Icon(Icons.file_download),
                      label: Text("REPORT_BTN_TAX_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📍 3. Unpaid Management 섹션
            _buildSectionTitle(Icons.notification_important_outlined, "REPORT_SEC_UNPAID".tr(ref)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _unpaidCaptureKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: unpaidAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => Text("COMMON_ERROR".tr(ref)),
                        data: (list) {
                          final overdue = list.where((u) => u.status == 'OVERDUE').toList();
                          final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
                          if (overdue.isEmpty) return Text("REPORT_UNPAID_ALL_COLLECTED".tr(ref), textAlign: TextAlign.center);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 📍 [수정] 미납 총액 다국어 포맷 적용
                                "${'ALERT_OVERDUE_TITLE'.tr(ref)}: ${overdue.length} ${'COMMON_ROOMS'.tr(ref)} / ${'PROP_TOTAL'.tr(ref)}: ${currencyFmt.format(totalOverdueAmount)}",
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...overdue.take(5).map(
                                    (u) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  // 📍 [수정] 개별 미납액 다국어 포맷 적용
                                  child: Text(
                                    "• ${u.unit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? 'COMMON_ANONYMOUS'.tr(ref)}): ${currencyFmt.format(u.unit.monthlyRent)}",
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final list = await ref.read(unpaidListProvider.future);
                            final overdue = list.where((u) => u.status == 'OVERDUE').toList();
                            if (overdue.isEmpty) return;
                            await ExcelExportService().exportUnpaidListToExcel(overdue, ref);
                          },
                          icon: const Icon(Icons.file_download),
                          label: Text("REPORT_BTN_UNPAID_EXCEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _captureAndShareImage(context, ref),
                          icon: const Icon(Icons.share_outlined),
                          label: Text("REPORT_BTN_UNPAID_IMAGE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📍 4. Annual Summary
            _buildSectionTitle(Icons.table_chart_outlined, "REPORT_SEC_ANNUAL_SUMMARY".tr(ref)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: monthlyTrendAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text("REPORT_ERROR_LOADING".tr(ref)),
                data: (trend) {
                  final int currentYear = DateTime.now().year;
                  final currentYearData = trend.where((item) => item.month.year == currentYear).toList();

                  int yearlyIncome = currentYearData.fold(0, (sum, item) => sum + item.income);
                  int yearlyExpense = currentYearData.fold(0, (sum, item) => sum + item.expense);
                  int yearlyProfit = yearlyIncome - yearlyExpense;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${'COMMON_YEAR'.tr(ref)}: $currentYear",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 📍 [수정] 요약 금액들 다국어 포맷 적용
                      _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_REVENUE".tr(ref), yearlyIncome, Colors.blue),
                      const Divider(height: 20),
                      _buildSummaryRow(ref, currencyFmt, "REPORT_YEARLY_EXPENSES".tr(ref), yearlyExpense, Colors.redAccent),
                      const Divider(height: 20),
                      _buildSummaryRow(ref, currencyFmt, "REPORT_ANNUAL_NET_PROFIT".tr(ref), yearlyProfit, Colors.indigo, isBold: true),
                      const SizedBox(height: 15),
                      Text(
                        "* ${'REPORT_SUMMARY_FOOTNOTE'.tr(ref)}",
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                      )
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ✅ [추가] Pro 인사이트 카드 UI
  // - 다국어는 messageKey.tr(ref)로 처리
  // - 레벨별 색상/아이콘을 다르게 표시
  Widget _buildInsightCard(WidgetRef ref, FinancialInsight insight) {
    final Color color = switch (insight.level) {
      InsightLevel.info => Colors.blueGrey,
      InsightLevel.warning => Colors.orange,
      InsightLevel.alert => Colors.redAccent,
    };

    final IconData icon = switch (insight.level) {
      InsightLevel.info => Icons.info_outline,
      InsightLevel.warning => Icons.warning_amber_rounded,
      InsightLevel.alert => Icons.report_gmailerrorred_outlined,
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight.messageKey.tr(ref),
              style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 📍 [수정] 요약 표 행 빌더에 포매터 추가
  Widget _buildSummaryRow(WidgetRef ref, NumberFormat fmt, String label, int amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          // 📍 국가별 통화 포맷 적용
          fmt.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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

  Widget _buildLegend(Color color, String label, {double fontSize = 10}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, color: Colors.black87, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Future<void> _captureAndShareImage(BuildContext context, WidgetRef ref) async {
    try {
      RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/unpaid_report.png').create();
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'REPORT_SHARE_UNPAID_TEXT'.tr(ref));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'REPORT_CAPTURE_FAILED'.tr(ref)}: $e")));
    }
  }
}
