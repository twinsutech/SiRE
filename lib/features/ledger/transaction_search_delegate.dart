import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'ledger_provider.dart';

class TransactionSearchDelegate extends SearchDelegate {
  // [수정 1] 생성자에서 ref를 받을 필요가 없어졌습니다.
  TransactionSearchDelegate();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResultBody();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResultBody();
  }

  // [수정 2] Consumer 위젯을 사용하여 검색 화면이 직접 데이터 신호를 받도록 변경
  Widget _buildSearchResultBody() {
    if (query.trim().isEmpty) {
      return const Center(child: Text("검색어를 입력하세요 (예: 월세, 커피)"));
    }

    return Consumer(
      builder: (context, ref, child) {
        // Consumer 안에서 watch를 해야 이 화면이 새로고침 됩니다.
        final searchAsync = ref.watch(searchTransactionsProvider(query));

        return searchAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Center(child: Text("검색 결과가 없습니다."));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'INCOME';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.category,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "${DateFormat('yyyy-MM-dd').format(tx.transactionDate)} | ${tx.memo ?? ''}",
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${NumberFormat('#,###').format(tx.amount)}원",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}