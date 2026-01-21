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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          "Reports",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📍 1. Financial Analytics 섹션 (아이콘 추가)
            _buildSectionTitle(Icons.analytics_outlined, "Financial Analytics"),
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
                        const Text("Monthly Trend (6 Months)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                                        NumberFormat('#,###').format(rod.toY),
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
                                            child: Text(DateFormat('MMM').format(data[index].month), style: const TextStyle(fontSize: 9)),
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
                            _buildLegend(Colors.blue, "Income"),
                            const SizedBox(width: 12),
                            _buildLegend(Colors.redAccent, "Expense"),
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
                        const Text("Annual Expenses", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: categoryStatsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox(),
                            data: (data) {
                              if (data.isEmpty) return const Center(child: Text("No Data", style: TextStyle(fontSize: 10)));
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

                                              final String sectionTitle = pctValue <= 1
                                                  ? ''
                                                  : '${entry.value.category}\n($percentageStr%)';

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
                                        children: data.asMap().entries.map((entry) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3),
                                          child: _buildLegend(
                                              colors[entry.key % colors.length],
                                              "${entry.value.category} (${NumberFormat('#,###').format(entry.value.amount)}만)",
                                              fontSize: 9
                                          ),
                                        )).toList(),
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
            _buildSectionTitle(Icons.assessment_outlined, "Tax Data Management"),
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
                        Text("Period: ${DateFormat('yyyy.01.01').format(DateTime.now())} - Present"),
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
                        await ExcelExportService().exportTransactionsToExcel(pureTransactions);
                      },
                      icon: const Icon(Icons.file_download),
                      label: const Text("Tax Excel", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📍 3. Unpaid Management 섹션
            _buildSectionTitle(Icons.notification_important_outlined, "Unpaid Management"),
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
                        error: (_, __) => const Text("Failed to load data"),
                        data: (list) {
                          final overdue = list.where((u) => u.status == 'OVERDUE').toList();
                          final totalOverdueAmount = overdue.fold(0, (sum, item) => sum + item.unit.monthlyRent);
                          if (overdue.isEmpty) return const Text("All rent is collected! 🎉", textAlign: TextAlign.center);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Overdue: ${overdue.length} Units / Total: ${NumberFormat('#,###').format(totalOverdueAmount)}원",
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 8),
                              ...overdue.take(5).map((u) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text("• ${u.unit.roomNumber}호 (${u.unit.tenantName ?? '익명'}): ${NumberFormat('#,###').format(u.unit.monthlyRent)}원", style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
                            await ExcelExportService().exportUnpaidListToExcel(overdue);
                          },
                          icon: const Icon(Icons.file_download),
                          label: const Text("Unpaid Excel", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          onPressed: () => _captureAndShareImage(context),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text("Unpaid Image", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📍 4. Annual Summary (당해 연도 데이터 반영)
            _buildSectionTitle(Icons.table_chart_outlined, "Annual Summary"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: monthlyTrendAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text("Error loading summary"),
                data: (trend) {
                  // 당해 연도(1월~현재) 데이터만 필터링하여 합산
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
                          Text("Year: $currentYear", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildSummaryRow("Yearly Revenue", yearlyIncome, Colors.blue),
                      const Divider(height: 20),
                      _buildSummaryRow("Yearly Expenses", yearlyExpense, Colors.redAccent),
                      const Divider(height: 20),
                      _buildSummaryRow("Annual Net Profit", yearlyProfit, Colors.indigo, isBold: true),
                      const SizedBox(height: 15),
                      const Text(
                        "* Figures are based on cumulative data from January 1st.",
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
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

  // 📍 요약 표를 위한 행 빌더
  Widget _buildSummaryRow(String label, int amount, Color color, {bool isBold = false}) {
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
          "${NumberFormat('#,###').format(amount)} 만",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 📍 섹션 타이틀 빌더
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

  // 📍 범례 위젯
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

  Future<void> _captureAndShareImage(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _unpaidCaptureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/unpaid_report.png').create();
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], text: '미납 호실 현황 리포트');
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("캡처 실패: $e")));
    }
  }
}