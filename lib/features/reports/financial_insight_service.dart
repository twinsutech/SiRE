// // // /// lib/features/reports/financial_insight_service.dart
// // // ///
// // // /// ✅ Reports Pro 전용 재무 인사이트 생성 서비스
// // // /// - 서버 없이 로컬 데이터 기반 규칙 판단
// // // /// - ReportsScreen 상단 "인사이트 카드"에서 사용
// // // /// - 다국어는 messageKey 기반으로 UI에서 처리
// // // ///
// // // /// 📌 설계 원칙
// // // /// - if 기반 명확한 규칙
// // // /// - 테스트/확장 용이
// // // /// - Pro 전용 기능으로만 사용
// // //
// // // enum InsightLevel {
// // //   info,
// // //   warning,
// // //   alert,
// // // }
// // //
// // // class FinancialInsight {
// // //   final String messageKey;
// // //   final InsightLevel level;
// // //
// // //   FinancialInsight({
// // //     required this.messageKey,
// // //     required this.level,
// // //   });
// // // }
// // //
// // // class FinancialInsightService {
// // //   /// ✅ Reports 데이터 기반 인사이트 생성
// // //   ///
// // //   /// [thisMonthIncome]   : 이번 달 총 수익
// // //   /// [thisMonthExpense]  : 이번 달 총 지출
// // //   /// [lastMonthExpense]  : 지난달 총 지출 (없으면 0)
// // //   /// [hasUnpaid]         : 미납 존재 여부
// // //   static List<FinancialInsight> generate({
// // //     required int thisMonthIncome,
// // //     required int thisMonthExpense,
// // //     required int lastMonthExpense,
// // //     required bool hasUnpaid,
// // //   }) {
// // //     final List<FinancialInsight> insights = [];
// // //
// // //     // --------------------------------------------------
// // //     // 1️⃣ 지출 급증 감지 (전월 대비 +15%)
// // //     // --------------------------------------------------
// // //     if (lastMonthExpense > 0 &&
// // //         thisMonthExpense > lastMonthExpense * 1.15) {
// // //       insights.add(
// // //         FinancialInsight(
// // //           messageKey: 'INSIGHT_EXPENSE_INCREASE',
// // //           level: InsightLevel.warning,
// // //         ),
// // //       );
// // //     }
// // //
// // //     // --------------------------------------------------
// // //     // 2️⃣ 순이익 적자 경고
// // //     // --------------------------------------------------
// // //     if (thisMonthIncome - thisMonthExpense < 0) {
// // //       insights.add(
// // //         FinancialInsight(
// // //           messageKey: 'INSIGHT_NET_LOSS',
// // //           level: InsightLevel.alert,
// // //         ),
// // //       );
// // //     }
// // //
// // //     // --------------------------------------------------
// // //     // 3️⃣ 미납 존재 경고
// // //     // --------------------------------------------------
// // //     if (hasUnpaid) {
// // //       insights.add(
// // //         FinancialInsight(
// // //           messageKey: 'INSIGHT_UNPAID_EXISTS',
// // //           level: InsightLevel.alert,
// // //         ),
// // //       );
// // //     }
// // //
// // //     // --------------------------------------------------
// // //     // 4️⃣ 이상 없음 (대체 메시지)
// // //     // --------------------------------------------------
// // //     if (insights.isEmpty) {
// // //       insights.add(
// // //         FinancialInsight(
// // //           messageKey: 'INSIGHT_ALL_GOOD',
// // //           level: InsightLevel.info,
// // //         ),
// // //       );
// // //     }
// // //
// // //     return insights;
// // //   }
// // // }
// //
// //
// // /// lib/features/reports/financial_insight_service.dart
// // ///
// // /// ✅ Reports Pro 전용 재무 인사이트 생성 서비스
// // /// - 서버 없이 로컬 데이터 기반 규칙 판단
// // /// - ReportsScreen 상단 "인사이트 카드"에서 사용
// // /// - 다국어는 messageKey 기반으로 UI에서 처리
// //
// // enum InsightLevel {
// //   info,
// //   warning,
// //   alert,
// // }
// //
// // class FinancialInsight {
// //   final String messageKey;
// //   final InsightLevel level;
// //
// //   FinancialInsight({
// //     required this.messageKey,
// //     required this.level,
// //   });
// // }
// //
// // class FinancialInsightService {
// //   /// ✅ Reports 데이터 기반 인사이트 생성
// //   static List<FinancialInsight> generate({
// //     required int thisMonthIncome,
// //     required int thisMonthExpense,
// //     required int lastMonthExpense,
// //     required bool hasUnpaid,
// //   }) {
// //     final List<FinancialInsight> insights = [];
// //
// //     // 1️⃣ 지출 급증 감지 (전월 대비 30% 이상은 Alert, 15% 이상은 Warning)
// //     if (lastMonthExpense > 0) {
// //       if (thisMonthExpense > lastMonthExpense * 1.30) {
// //         insights.add(FinancialInsight(messageKey: 'INSIGHT_EXPENSE_CRITICAL_INCREASE', level: InsightLevel.alert));
// //       } else if (thisMonthExpense > lastMonthExpense * 1.15) {
// //         insights.add(FinancialInsight(messageKey: 'INSIGHT_EXPENSE_INCREASE', level: InsightLevel.warning));
// //       }
// //     }
// //
// //     // 2️⃣ 순이익 적자 경고
// //     if (thisMonthIncome > 0 && (thisMonthIncome - thisMonthExpense < 0)) {
// //       insights.add(FinancialInsight(messageKey: 'INSIGHT_NET_LOSS', level: InsightLevel.alert));
// //     }
// //
// //     // 3️⃣ 무수입 지출 경고
// //     if (thisMonthIncome <= 0 && thisMonthExpense > 0) {
// //       insights.add(FinancialInsight(messageKey: 'INSIGHT_NO_INCOME_WITH_EXPENSE', level: InsightLevel.alert));
// //     }
// //
// //     // 4️⃣ 미납 존재 경고
// //     if (hasUnpaid) {
// //       insights.add(FinancialInsight(messageKey: 'INSIGHT_UNPAID_EXISTS', level: InsightLevel.alert));
// //     }
// //
// //     // 5️⃣ 지출 절감 알림 (긍정적 신호)
// //     if (lastMonthExpense > 0 && thisMonthExpense < lastMonthExpense * 0.9) {
// //       insights.add(FinancialInsight(messageKey: 'INSIGHT_EXPENSE_SAVED', level: InsightLevel.info));
// //     }
// //
// //     // 6️⃣ 기본 메시지
// //     if (insights.isEmpty) {
// //       insights.add(FinancialInsight(messageKey: 'INSIGHT_ALL_GOOD', level: InsightLevel.info));
// //     }
// //
// //     return insights;
// //   }
// // }
//
//
// /// lib/features/reports/financial_insight_service.dart
// ///
// /// ✅ Reports Pro 전용 재무 인사이트 생성 서비스
// /// - 수치 기반 지능형 진단 알고리즘 적용
// /// - 사용자가 즉각적인 위기/안도감을 느끼도록 설계 (구매 가치 증대)
//
// enum InsightLevel {
//   info,   // 긍정적/정보성
//   warning, // 주의 필요
//   alert,   // 즉각 조치 필요
// }
//
// class FinancialInsight {
//   final String messageKey;
//   final InsightLevel level;
//   // 📍 다국어 메시지에 동적으로 숫자를 넣기 위한 인자 (예: "지출이 30% 증가")
//   final Map<String, String>? arguments;
//
//   FinancialInsight({
//     required this.messageKey,
//     required this.level,
//     this.arguments,
//   });
// }
//
// class FinancialInsightService {
//   /// ✅ Reports 데이터 기반 지능형 인사이트 생성
//   static List<FinancialInsight> generate({
//     required int thisMonthIncome,
//     required int thisMonthExpense,
//     required int lastMonthExpense,
//     required bool hasUnpaid,
//     int overdueCount = 0,      // 미납 건수 추가
//     int totalOverdueAmount = 0, // 미납 총액 추가
//   }) {
//     final List<FinancialInsight> insights = [];
//
//     // --------------------------------------------------
//     // 1️⃣ 수지 타당성 분석 (수입 대비 지출 비중)
//     // --------------------------------------------------
//     if (thisMonthIncome > 0) {
//       double expenseRatio = (thisMonthExpense / thisMonthIncome) * 100;
//
//       if (expenseRatio >= 100) {
//         insights.add(FinancialInsight(
//           messageKey: 'INSIGHT_RATIO_DEFICIT', // "수입보다 지출이 많아 적자 상태입니다."
//           level: InsightLevel.alert,
//         ));
//       } else if (expenseRatio >= 70) {
//         insights.add(FinancialInsight(
//           messageKey: 'INSIGHT_RATIO_WARNING', // "수입의 {percent}%가 지출로 소비되었습니다."
//           level: InsightLevel.warning,
//           arguments: {'percent': expenseRatio.toStringAsFixed(0)},
//         ));
//       }
//     }
//
//     // --------------------------------------------------
//     // 2️⃣ 지출 변동성 정밀 진단 (전월 대비)
//     // --------------------------------------------------
//     if (lastMonthExpense > 0) {
//       double growthRate = ((thisMonthExpense - lastMonthExpense) / lastMonthExpense) * 100;
//
//       if (growthRate >= 30) {
//         insights.add(FinancialInsight(
//           messageKey: 'INSIGHT_SPEND_SPIKE', // "지출이 지난달보다 {percent}% 급증했습니다."
//           level: InsightLevel.alert,
//           arguments: {'percent': growthRate.toStringAsFixed(0)},
//         ));
//       }
//     }
//
//     // --------------------------------------------------
//     // 3️⃣ 미납의 심각성 진단
//     // --------------------------------------------------
//     if (hasUnpaid) {
//       // 단순 존재 여부가 아니라 수입 대비 미납 비중 계산
//       if (thisMonthIncome > 0 && totalOverdueAmount > (thisMonthIncome * 0.5)) {
//         insights.add(FinancialInsight(
//           messageKey: 'INSIGHT_UNPAID_CRITICAL', // "한 달 수입의 50%를 넘는 고위험 미납이 존재합니다."
//           level: InsightLevel.alert,
//         ));
//       } else {
//         insights.add(FinancialInsight(
//           messageKey: 'INSIGHT_UNPAID_EXISTS', // "미납 건 {count}건을 해결하여 현금흐름을 개선하세요."
//           level: InsightLevel.warning,
//           arguments: {'count': overdueCount.toString()},
//         ));
//       }
//     }
//
//     // --------------------------------------------------
//     // 4️⃣ 무수입 지출 상태 (공실 리스크 등)
//     // --------------------------------------------------
//     if (thisMonthIncome <= 0 && thisMonthExpense > 0) {
//       insights.add(FinancialInsight(
//         messageKey: 'INSIGHT_NO_INCOME_DANGER', // "현재 수입 없이 지출만 발생하고 있습니다."
//         level: InsightLevel.alert,
//       ));
//     }
//
//     // --------------------------------------------------
//     // 5️⃣ 효율적 관리 상태 (안도감 제공)
//     // --------------------------------------------------
//     if (insights.isEmpty && thisMonthIncome > thisMonthExpense) {
//       insights.add(FinancialInsight(
//         messageKey: 'INSIGHT_ALL_GOOD', // "안정적인 현금흐름을 유지하고 있습니다."
//         level: InsightLevel.info,
//       ));
//     }
//
//     return insights;
//   }
// }


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