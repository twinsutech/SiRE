import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/theme/app_colors.dart';
import 'ledger_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 통계 데이터 구독
    final statsAsync = ref.watch(categoryStatisticsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // 📍 [화폐 다국어] 현재 설정된 언어 로케일 가져오기
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    // 📍 [화폐 다국어] 국가별 표준 통화 포매터 정의 (심볼 위치 자동 조절)
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        // 📍 다국어: "{월} 지출 분석"
        title: Text("${selectedDate.month}${"COMMON_MONTH_UNIT".tr(ref)} ${"STATS_TITLE".tr(ref)}"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (stats) {
          if (stats.isEmpty) {
            return Center(
              child: Text(
                "STATS_EMPTY_MSG".tr(ref), // 📍 다국어: "지출 내역이 없습니다.\n돈을 아끼셨군요! 🎉"
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final item = stats[index];

              return Column(
                children: [
                  // 카테고리 이름과 금액
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // 순위 배지 (1, 2, 3등)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: index < 3 ? AppColors.expenseRed : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            // 📍 카테고리 다국어 처리 (CAT_ 키워드 대응)
                            item.category.startsWith('CAT_') ? item.category.tr(ref) : item.category,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        // 📍 [수정] 하드코딩된 단위 대신 국가별 표준 통화 포맷 적용
                        "${currencyFmt.format(item.amount)} (${(item.percentage * 100).toStringAsFixed(1)}%)",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 막대 그래프 (게이지)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item.percentage, // 0.0 ~ 1.0
                      minHeight: 12,
                      backgroundColor: Colors.grey[100],
                      color: AppColors.expenseRed.withOpacity(0.7),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}