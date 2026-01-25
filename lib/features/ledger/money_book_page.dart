import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/database_provider.dart';
import '../../core/theme/app_colors.dart';
import 'ledger_provider.dart';
import 'add_transaction_sheet.dart';

class MoneyBookPage extends ConsumerWidget {
  const MoneyBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 상태 구독
    final selectedDate = ref.watch(selectedDateProvider);
    final summaryAsync = ref.watch(ledgerSummaryProvider);
    // 📍 이제 List<TransactionWithImages>를 반환합니다.
    final ledgerListAsync = ref.watch(ledgerListProvider);

    // 📍 [화폐 다국어] 현재 설정된 언어 로케일 가져오기
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).updateMonth(-1);
              },
            ),
            Text(
              DateFormat('yyyy.MM').format(selectedDate),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.black),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).updateMonth(1);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 2. 수입/지출 요약 카드
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (summary) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        ref,
                        "COMMON_INCOME", // 📍 다국어: "수익"
                        summary.totalIncome,
                        AppColors.incomeGreen,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    Expanded(
                      child: _buildSummaryItem(
                        ref,
                        "COMMON_EXPENSE", // 📍 다국어: "지출"
                        summary.totalExpense,
                        AppColors.expenseRed,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 3. 내역 리스트
          Expanded(
            child: ledgerListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (items) { // 📍 List<TransactionWithImages> 수신
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      "LEDGER_EMPTY_DESC".tr(ref), // 📍 다국어: "내역이 없습니다. +버튼을 눌러 추가하세요."
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // 📍 포장지에서 알맹이(transaction)와 영수증 유무(hasImages) 추출
                    final item = items[index];
                    final tx = item.transaction;
                    final isIncome = tx.type == 'INC'; // 📍 'INCOME' -> 'INC'로 수정

                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        HapticFeedback.mediumImpact(); // 📍 삭제 피드백
                        final db = ref.read(databaseProvider);
                        await (db.delete(db.transactions)
                          ..where((t) => t.id.equals(tx.id)))
                            .go();
                        ref.invalidate(ledgerListProvider);
                        ref.invalidate(ledgerSummaryProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("COMMON_DELETED_MSG".tr(ref))), // 📍 다국어: "삭제되었습니다."
                          );
                        }
                      },
                      child: InkWell( // 📍 클릭 시 상세 보기로 이동 추가
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddTransactionSheet(transaction: tx),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isIncome
                                      ? AppColors.incomeGreen.withOpacity(0.1)
                                      : AppColors.expenseRed.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isIncome
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isIncome
                                      ? AppColors.incomeGreen
                                      : AppColors.expenseRed,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // 📍 카테고리 명칭 다국어 키 처리
                                        Text(
                                          tx.category.startsWith('CAT_') ? tx.category.tr(ref) : tx.category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        // 📍 영수증 아이콘 표시 추가
                                        if (item.hasImages) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.receipt_long, size: 14, color: Colors.blueGrey),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${DateFormat('MM.dd').format(tx.transactionDate)} | ${tx.memo ?? ''}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                // 📍 [수정] 하드코딩된 단위 대신 국가별 표준 통화 포맷 적용
                                "${isIncome ? '+' : '-'}${currencyFmt.format(tx.amount)}",
                                style: TextStyle(
                                  color: isIncome
                                      ? AppColors.incomeGreen
                                      : AppColors.expenseRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 4. 입력 버튼 (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTransactionSheet(initialDate: selectedDate),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryItem(WidgetRef ref, String titleKey, int amount, Color color) {
    // 📍 [화폐 다국어] 요약 아이템에서도 로케일 포맷터 적용
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(titleKey.tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            // 📍 [수정] 요약 카드에도 글로벌 표준 통화 포맷 적용
            currencyFmt.format(amount),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}