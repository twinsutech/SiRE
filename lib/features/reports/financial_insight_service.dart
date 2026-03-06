/// lib/features/reports/financial_insight_service.dart

enum InsightLevel { info, warning, alert }

class FinancialInsight {
  final String messageKey;
  final InsightLevel level;
  // 📍 다국어 메시지에 동적으로 숫자를 넣기 위한 인자
  final Map<String, String>? arguments;

  FinancialInsight({required this.messageKey, required this.level, this.arguments});
}

class FinancialInsightService {
  static List<FinancialInsight> generate({
    required int thisMonthIncome,
    required int thisMonthExpense,
    required int lastMonthExpense,
    required int overdueCount,
    required int totalOverdueAmount,
  }) {
    final List<FinancialInsight> insights = [];

    // 1️⃣ 수지 타당성 분석 (수입 대비 지출 비중)
    if (thisMonthIncome > 0) {
      double expenseRatio = (thisMonthExpense / thisMonthIncome) * 100;
      if (expenseRatio >= 100) {
        insights.add(FinancialInsight(messageKey: 'INSIGHT_RATIO_DEFICIT', level: InsightLevel.alert));
      } else if (expenseRatio >= 70) {
        insights.add(FinancialInsight(
          messageKey: 'INSIGHT_RATIO_WARNING',
          level: InsightLevel.warning,
          arguments: {'percent': expenseRatio.toStringAsFixed(0)},
        ));
      }
    }

    // 2️⃣ 지출 변동성 진단 (전월 대비)
    if (lastMonthExpense > 0) {
      double growthRate = ((thisMonthExpense - lastMonthExpense) / lastMonthExpense) * 100;
      if (growthRate >= 30) {
        insights.add(FinancialInsight(
          messageKey: 'INSIGHT_SPEND_SPIKE',
          level: InsightLevel.alert,
          arguments: {'percent': growthRate.toStringAsFixed(0)},
        ));
      }
    }

    // 3️⃣ 미납 심각도 진단 (단순 존재 -> 구체적 액수와 비중)
    if (overdueCount > 0) {
      if (thisMonthIncome > 0 && totalOverdueAmount > (thisMonthIncome * 0.5)) {
        insights.add(FinancialInsight(messageKey: 'INSIGHT_UNPAID_CRITICAL', level: InsightLevel.alert));
      } else {
        insights.add(FinancialInsight(
          messageKey: 'INSIGHT_UNPAID_SUMMARY',
          level: InsightLevel.warning,
          arguments: {'count': overdueCount.toString()},
        ));
      }
    }

    // 4️⃣ 안정적 관리 상태 (기본 메시지)
    if (insights.isEmpty && thisMonthIncome > thisMonthExpense) {
      insights.add(FinancialInsight(messageKey: 'INSIGHT_ALL_GOOD', level: InsightLevel.info));
    }

    return insights;
  }
}