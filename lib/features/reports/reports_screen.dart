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
