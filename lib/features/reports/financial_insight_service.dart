/// lib/features/reports/financial_insight_service.dart
///
/// ✅ Reports Pro 전용 재무 인사이트 생성 서비스
/// - 서버 없이 로컬 데이터 기반 규칙 판단
/// - ReportsScreen 상단 "인사이트 카드"에서 사용
/// - 다국어는 messageKey 기반으로 UI에서 처리
///
/// 📌 설계 원칙
/// - if 기반 명확한 규칙
/// - 테스트/확장 용이
/// - Pro 전용 기능으로만 사용

enum InsightLevel {
  info,
  warning,
  alert,
}

class FinancialInsight {
  final String messageKey;
  final InsightLevel level;

  FinancialInsight({
    required this.messageKey,
    required this.level,
  });
}

class FinancialInsightService {
  /// ✅ Reports 데이터 기반 인사이트 생성
  ///
  /// [thisMonthIncome]   : 이번 달 총 수익
  /// [thisMonthExpense]  : 이번 달 총 지출
  /// [lastMonthExpense]  : 지난달 총 지출 (없으면 0)
  /// [hasUnpaid]         : 미납 존재 여부
  static List<FinancialInsight> generate({
    required int thisMonthIncome,
    required int thisMonthExpense,
    required int lastMonthExpense,
    required bool hasUnpaid,
  }) {
    final List<FinancialInsight> insights = [];

    // --------------------------------------------------
    // 1️⃣ 지출 급증 감지 (전월 대비 +15%)
    // --------------------------------------------------
    if (lastMonthExpense > 0 &&
        thisMonthExpense > lastMonthExpense * 1.15) {
      insights.add(
        FinancialInsight(
          messageKey: 'INSIGHT_EXPENSE_INCREASE',
          level: InsightLevel.warning,
        ),
      );
    }

    // --------------------------------------------------
    // 2️⃣ 순이익 적자 경고
    // --------------------------------------------------
    if (thisMonthIncome - thisMonthExpense < 0) {
      insights.add(
        FinancialInsight(
          messageKey: 'INSIGHT_NET_LOSS',
          level: InsightLevel.alert,
        ),
      );
    }

    // --------------------------------------------------
    // 3️⃣ 미납 존재 경고
    // --------------------------------------------------
    if (hasUnpaid) {
      insights.add(
        FinancialInsight(
          messageKey: 'INSIGHT_UNPAID_EXISTS',
          level: InsightLevel.alert,
        ),
      );
    }

    // --------------------------------------------------
    // 4️⃣ 이상 없음 (대체 메시지)
    // --------------------------------------------------
    if (insights.isEmpty) {
      insights.add(
        FinancialInsight(
          messageKey: 'INSIGHT_ALL_GOOD',
          level: InsightLevel.info,
        ),
      );
    }

    return insights;
  }
}
