import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import 'add_transaction_sheet.dart';
import 'ledger_provider.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  late PageController _pageController;
  final int _initialPage = 500;

  // 📍 1단계 핵심: 지출 분석 섹션을 펼치고 숨길 상태 변수
  bool _isAnalysisOpen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final transactionsAsync = ref.watch(ledgerListProvider);
    final summaryAsync = ref.watch(ledgerSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "NAV_LEDGER".tr(ref), // 📍 다국어 적용: "Ledger"
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildMonthSelector(context, ref, selectedDate),
          _buildSummaryHeader(summaryAsync, ref),

          // 📍 1단계 수정: 분석 토글 버튼 (아래쪽 라운드 적용)
          _buildAnalysisToggleButton(ref),

          // 📍 1단계 수정: 차트 고정 노출 (리스트 밖 배치)
          if (_isAnalysisOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _buildExpenseStatistics(ref),
            ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                final diff = index - _initialPage;
                final now = DateTime.now();
                ref.read(selectedDateProvider.notifier).state =
                    DateTime(now.year, now.month + diff, 1);
              },
              itemBuilder: (context, index) {
                return transactionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (transactions) {
                    // 📍 정렬 문제 해결 핵심: 리스트를 최신순으로 강제 정렬
                    final sortedList = transactions.toList()
                      ..sort((a, b) {
                        // 1. 날짜 기준 내림차순 (최신 날짜가 위로)
                        int dateCompare = b.transaction.transactionDate.compareTo(a.transaction.transactionDate);
                        if (dateCompare != 0) return dateCompare;
                        // 2. 날짜가 같다면 ID 기준 내림차순 (나중에 입력한 ID가 큰 값이 위로)
                        return b.transaction.id.compareTo(a.transaction.id);
                      });

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (sortedList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                "LEDGER_NO_TRANSACTIONS".tr(ref), // 📍 다국어 적용
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                        // 📍 정렬된 sortedList를 사용하여 카드 출력
                          ...sortedList.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: _buildTransactionCard(context, ref, item),
                          )),

                        const SizedBox(height: 80),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          HapticFeedback.lightImpact(); // 📍 터치 피드백
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTransactionSheet(
              initialDate: selectedDate,
            ),
          );
        },
      ),
    );
  }

  // 📍 1단계: 분석 토글 버튼 위젯 (다국어 및 햅틱 적용)
  Widget _buildAnalysisToggleButton(WidgetRef ref) {
    final Color bgColor = _isAnalysisOpen ? const Color(0xFF3F51B5) : const Color(0xFF1A237E);
    final Color contentColor = _isAnalysisOpen ? Colors.white : Colors.white70;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick(); // 📍 상태 변경 피드백
        setState(() => _isAnalysisOpen = !_isAnalysisOpen);
      },
      customBorder: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          boxShadow: _isAnalysisOpen ? [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAnalysisOpen ? Icons.keyboard_arrow_up : Icons.pie_chart_outline,
              color: contentColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _isAnalysisOpen ? "LEDGER_CLOSE_ANALYSIS".tr(ref) : "LEDGER_OPEN_ANALYSIS".tr(ref), // 📍 다국어
              style: TextStyle(
                color: contentColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final now = DateTime.now();
    final isTodayMonth = selectedDate.year == now.year && selectedDate.month == now.month;
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 [수정] 하드코딩된 'MMMM yyyy' 대신 언어별 표준 포맷인 yMMMM을 사용합니다.
    // 한국어: "2026년 1월", 영어: "January 2026" 등으로 자동 정렬됩니다.
    final dateStr = DateFormat.yMMMM(currentLang).format(selectedDate);

    return Container(
      color: const Color(0xFF1A237E),
      height: 55,
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 28),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 28),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),
          if (!isTodayMonth)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      _initialPage,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "COMMON_TODAY".tr(ref), // 📍 다국어: "Today"
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseStatistics(WidgetRef ref) {
    final statsAsync = ref.watch(categoryStatisticsProvider);
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    return statsAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text("LEDGER_NO_EXPENSE_DATA".tr(ref), style: const TextStyle(color: Colors.grey))),
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "LEDGER_EXPENSE_RATIO_TITLE".tr(ref), // 📍 다국어: "이번 달 지출 항목 비중"
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: stats.map((s) {
                      final double pctValue = s.percentage * 100;
                      final String percentageStr = pctValue.toStringAsFixed(0);

                      // 📍 핵심 수정: 통계 차트의 카테고리명 번역
                      final String categoryName = s.category.startsWith('CAT_') ? s.category.tr(ref) : s.category;
                      final String sectionTitle = pctValue <= 1 ? '' : '$categoryName\n($percentageStr%)';

                      return PieChartSectionData(
                        color: _getCategoryColor(s.category),
                        value: s.amount.toDouble(),
                        title: sectionTitle,
                        radius: 40,
                        titleStyle: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: stats.map((s) {
                  // 📍 핵심 수정: 범례 카테고리명 및 통화 포맷 번역
                  final String categoryName = s.category.startsWith('CAT_') ? s.category.tr(ref) : s.category;
                  // 📍 [수정] 통계 범례 금액 표시를 국가별 통화 관습에 맞게 변경
                  final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: _getCategoryColor(s.category), size: 8),
                      const SizedBox(width: 4),
                      Text(
                        "$categoryName (${currencyFmt.format(s.amount)})",
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // 이제 언어가 무엇이든 상관없이 고정된 키값으로만 판단합니다.
  IconData _getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case 'CAT_RENT': return Icons.home_work_rounded;
      case 'CAT_TAX': return Icons.request_quote_rounded;
      case 'CAT_REPAIR': return Icons.build_circle_rounded;
      case 'CAT_UTILITY': return Icons.lightbulb_circle_rounded;
      case 'CAT_CLEANING': return Icons.cleaning_services_rounded;
      case 'CAT_MAINTENANCE': return Icons.settings_suggest_rounded;
      case 'CAT_INSURANCE': return Icons.verified_user_rounded;
      case 'CAT_DEPOSIT': return Icons.vpn_key_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'CAT_RENT': return Colors.indigo;
      case 'CAT_TAX': return Colors.redAccent;
      case 'CAT_REPAIR': return Colors.orange;
      case 'CAT_UTILITY': return Colors.teal;
      case 'CAT_CLEANING': return Colors.blue;
      case 'CAT_MAINTENANCE': return Colors.amber;
      case 'CAT_INSURANCE': return Colors.purple;
      case 'CAT_DEPOSIT': return Colors.brown;
      default: return Colors.blueGrey;
    }
  }

  Widget _buildSummaryHeader(AsyncValue<LedgerSummary> summaryAsync, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: summaryAsync.when(
        loading: () => const Center(child: LinearProgressIndicator(color: Colors.white)),
        error: (err, stack) => Text("Error: $err", style: const TextStyle(color: Colors.white)),
        data: (summary) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _summaryItem(ref, "COMMON_INCOME", summary.totalIncome, Colors.greenAccent),
            Container(width: 1, height: 40, color: Colors.white24),
            _summaryItem(ref, "COMMON_EXPENSE", summary.totalExpense, Colors.redAccent),
            Container(width: 1, height: 40, color: Colors.white24),
            _summaryItem(ref, "COMMON_BALANCE", summary.balance, Colors.amberAccent),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(WidgetRef ref, String labelKey, int amount, Color color) {
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    // 📍 [수정] 상단 요약 바 금액 표시를 로케일별 통화 관습($ ₩ 등)에 맞게 변경
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(labelKey.tr(ref), style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
              currencyFmt.format(amount),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, WidgetRef ref, TransactionWithImages item) {
    final tx = item.transaction;
    final isIncome = tx.type == 'INC';
    final themeColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 [수정] 리스트의 각 항목 금액 표시를 로케일별 통화 관습($ ₩ 등)에 맞게 변경
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact(); // 📍 터치 피드백
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTransactionSheet(transaction: tx),
          );
        },
        leading: CircleAvatar(
          backgroundColor: themeColor.withOpacity(0.1),
          child: Icon(_getCategoryIcon(tx.category), color: themeColor, size: 22),
        ),
        title: Row(
          children: [
            // 📍 핵심 수정: 리스트의 카테고리명 번역 (CAT_... 키값인 경우)
            Text(
                tx.category.startsWith('CAT_') ? tx.category.tr(ref) : tx.category,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            if (item.hasImages) ...[
              const SizedBox(width: 6),
              const Icon(Icons.receipt_long, size: 14, color: Colors.blueGrey),
            ]
          ],
        ),
        subtitle: Text("${DateFormat('MM.dd').format(tx.transactionDate)} ${tx.memo ?? ''}"),
        trailing: Text(
          "${isIncome ? '+' : '-'}${currencyFmt.format(tx.amount)}",
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}