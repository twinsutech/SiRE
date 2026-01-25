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
import '../ledger/ledger_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'excel_export_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  // 📍 이미지 캡처를 위한 GlobalKey
  static final GlobalKey _unpaidCaptureKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyTrendAsync = ref.watch(monthlyTrendProvider);
    final categoryStatsAsync = ref.watch(categoryStatisticsProvider);
    final unpaidAsync = ref.watch(unpaidListProvider);
    final lang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
    final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

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
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(2))
                                      ),
                                      BarChartRodData(
                                          toY: e.value.expense.toDouble(),
                                          color: Colors.redAccent,
                                          width: 8,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(2))
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

                                              final String sectionTitle = pctValue <= 1
                                                  ? ''
                                                  : '$categoryName\n($percentageStr%)';

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
                                            }).toList()
                                        )
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
                                                fontSize: 9
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
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 8),
                              ...overdue.take(5).map((u) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                // 📍 [수정] 개별 미납액 다국어 포맷 적용
                                child: Text("• ${u.unit.roomNumber}${ 'COMMON_ROOM_UNIT'.tr(ref)} (${u.unit.tenantName ?? '익명'}): ${currencyFmt.format(u.unit.monthlyRent)}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              )),
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
                          Text("${'COMMON_YEAR'.tr(ref)}: $currentYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
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