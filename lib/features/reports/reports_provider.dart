// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../ledger/ledger_provider.dart';
//
// // 1. 월별 수입(Income) 데이터 Provider
// // 결과: {1: 10000, 2: 25000, ...} (월: 금액)
// final monthlyRevenueProvider = FutureProvider<Map<int, double>>((ref) async {
//   // 📍 반환 타입이 List<TransactionWithImages>로 변경됨
//   final transactions = await ref.watch(ledgerListProvider.future);
//
//   final Map<int, double> monthlyData = {};
//
//   // 1월~6월까지 0원으로 초기화 (그래프 모양 잡기 위해)
//   for (int i = 1; i <= 6; i++) {
//     monthlyData[i] = 0.0;
//   }
//
//   for (var item in transactions) {
//     // 📍 포장지(TransactionWithImages)에서 알맹이(transaction) 추출
//     final tx = item.transaction;
//
//     // 📍 수정: 'INC' 표준 키 사용 및 연도 체크
//     if (tx.type == 'INC' && tx.transactionDate.year == DateTime.now().year) {
//       final month = tx.transactionDate.month;
//       // 상반기(1~6월) 데이터만 예시로 집계
//       if (month <= 6) {
//         monthlyData[month] = (monthlyData[month] ?? 0) + tx.amount.toDouble();
//       }
//     }
//   }
//   return monthlyData;
// });
//
// // 2. 건물별 수입 데이터 Provider
// // 결과: {'Villa Sunrise': 50000, 'Other': 10000}
// final buildingRevenueProvider = FutureProvider<Map<String, double>>((ref) async {
//   final transactions = await ref.watch(ledgerListProvider.future);
//   final Map<String, double> buildingData = {};
//
//   // 📍 다국어 지원을 위해 번역 함수 준비
//   final l10n = ref.read(localizationProvider.notifier);
//
//   for (var item in transactions) {
//     // 📍 포장지에서 알맹이 추출
//     final tx = item.transaction;
//
//     // 📍 수정: 'INC' 표준 키 사용
//     if (tx.type == 'INC') {
//       // 현재는 건물 ID가 1로 고정되어 있으니 이름을 하드코딩하거나
//       // 나중에 건물 DB와 조인해야 합니다. 지금은 'Main Bldg'로 통일합니다.
//       // 📍 다국어 적용: "기본 건물" 명칭을 다국어 키로 처리
//       final buildingName = l10n.translate("REPORT_MAIN_BUILDING");
//
//       buildingData[buildingName] = (buildingData[buildingName] ?? 0) + tx.amount.toDouble();
//     }
//   }
//
//   // (테스트용) 차트가 예쁘게 나오도록 가짜 데이터 하나 추가
//   if (buildingData.isNotEmpty) {
//     // 📍 다국어 적용: "부속 건물" 명칭
//     final sideBldgName = l10n.translate("REPORT_SIDE_BUILDING");
//     buildingData[sideBldgName] = buildingData.values.first * 0.3;
//   }
//
//   return buildingData;
// });
//
// // 📍 [최종 수정] 다중 이미지 데이터를 포함하여 지출 증빙 완료율을 정확히 계산하는 Provider
// final annualReceiptCompletionProvider = FutureProvider.family<double, int>((ref, year) async {
//   // 전체 장부 데이터를 가져옴
//   final transactions = await ref.watch(ledgerListProvider.future);
//
//   // 해당 연도의 지출(EXP) 항목만 필터링
//   final annualExpenses = transactions.where((item) {
//     return item.transaction.type == 'EXP' && item.transaction.transactionDate.year == year;
//   }).toList();
//
//   // 지출 내역이 없으면 0% 반환
//   if (annualExpenses.isEmpty) return 0.0;
//
//   // 증빙이 완료된(사진이 있는) 항목 수 계산
//   final completedCount = annualExpenses.where((item) {
//     // 1. 단일 이미지 필드 확인 (기존 방식)
//     final bool hasSingleReceipt = item.transaction.receiptImagePath != null &&
//         item.transaction.receiptImagePath!.isNotEmpty;
//
//     // 2. 다중 이미지 리스트 확인 (실제 사진 추가 기능을 통해 등록된 경우)
//     // 📍 [수정 포인트]: 에러 메시지에 따라 'images' 대신 실제 필드명을 확인해야 함.
//     // 만약 에러가 계속된다면 ledger_provider.dart의 필드명을 'images'로 맞추거나
//     // 아래의 필드명을 해당 클래스의 리스트 이름으로 수정하세요.
//     final bool hasMultipleImages = item.images.isNotEmpty;
//
//     // 두 조건 중 하나만 만족해도 증빙 완료로 간주
//     return hasSingleReceipt || hasMultipleImages;
//   }).length;
//
//   // 백분율 계산 (완료 수 / 전체 지출 수 * 100)
//   return (completedCount / annualExpenses.length) * 100;
// });


//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:drift/drift.dart'; // 📍 drift 쿼리를 위해 추가
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../../core/database/database_provider.dart'; // 📍 DB 접근을 위해 추가
// import '../ledger/ledger_provider.dart';
//
// // 1. 월별 수입(Income) 데이터 Provider
// // 결과: {1: 10000, 2: 25000, ...} (월: 금액)
// final monthlyRevenueProvider = FutureProvider<Map<int, double>>((ref) async {
//   // 📍 반환 타입이 List<TransactionWithImages>로 변경됨
//   final transactions = await ref.watch(ledgerListProvider.future);
//
//   final Map<int, double> monthlyData = {};
//
//   // 1월~6월까지 0원으로 초기화 (그래프 모양 잡기 위해)
//   for (int i = 1; i <= 6; i++) {
//     monthlyData[i] = 0.0;
//   }
//
//   for (var item in transactions) {
//     // 📍 포장지(TransactionWithImages)에서 알맹이(transaction) 추출
//     final tx = item.transaction;
//
//     // 📍 수정: 'INC' 표준 키 사용 및 연도 체크
//     if (tx.type == 'INC' && tx.transactionDate.year == DateTime.now().year) {
//       final month = tx.transactionDate.month;
//       // 상반기(1~6월) 데이터만 예시로 집계
//       if (month <= 6) {
//         monthlyData[month] = (monthlyData[month] ?? 0) + tx.amount.toDouble();
//       }
//     }
//   }
//   return monthlyData;
// });
//
// // 2. 건물별 수입 데이터 Provider
// // 결과: {'Villa Sunrise': 50000, 'Other': 10000}
// final buildingRevenueProvider = FutureProvider<Map<String, double>>((ref) async {
//   final transactions = await ref.watch(ledgerListProvider.future);
//   final Map<String, double> buildingData = {};
//
//   // 📍 다국어 지원을 위해 번역 함수 준비
//   final l10n = ref.read(localizationProvider.notifier);
//
//   for (var item in transactions) {
//     // 📍 포장지에서 알맹이 추출
//     final tx = item.transaction;
//
//     // 📍 수정: 'INC' 표준 키 사용
//     if (tx.type == 'INC') {
//       // 현재는 건물 ID가 1로 고정되어 있으니 이름을 하드코딩하거나
//       // 나중에 건물 DB와 조인해야 합니다. 지금은 'Main Bldg'로 통일합니다.
//       // 📍 다국어 적용: "기본 건물" 명칭을 다국어 키로 처리
//       final buildingName = l10n.translate("REPORT_MAIN_BUILDING");
//
//       buildingData[buildingName] = (buildingData[buildingName] ?? 0) + tx.amount.toDouble();
//     }
//   }
//
//   // (테스트용) 차트가 예쁘게 나오도록 가짜 데이터 하나 추가
//   if (buildingData.isNotEmpty) {
//     // 📍 다국어 적용: "부속 건물" 명칭
//     final sideBldgName = l10n.translate("REPORT_SIDE_BUILDING");
//     buildingData[sideBldgName] = buildingData.values.first * 0.3;
//   }
//
//   return buildingData;
// });
//
// // // 📍 [최종 수정] 1번 기능: 지출 증빙 완료율 계산 (DB 직접 조회 방식)
// // final annualReceiptCompletionProvider = FutureProvider.family<double, int>((ref, year) async {
// //   final transactions = await ref.watch(ledgerListProvider.future);
// //   final db = ref.watch(databaseProvider);
// //
// //   // 해당 연도의 지출(EXP)만 필터링
// //   final annualExpenses = transactions.where((item) {
// //     return item.transaction.type == 'EXP' && item.transaction.transactionDate.year == year;
// //   }).toList();
// //
// //   if (annualExpenses.isEmpty) return 0.0;
// //
// //   int completedCount = 0;
// //
// //   for (var item in annualExpenses) {
// //     // 1. 단일 이미지 필드 체크
// //     final bool hasSingleReceipt = item.transaction.receiptImagePath != null &&
// //         item.transaction.receiptImagePath!.isNotEmpty;
// //
// //     if (hasSingleReceipt) {
// //       completedCount++;
// //       continue;
// //     }
// //
// //     // 2. [가장 정확한 방법] DB의 TransactionImages 테이블에서 해당 트랜잭션 ID의 이미지가 있는지 직접 확인
// //     final imageExists = await (db.select(db.transactionImages)
// //       ..where((t) => t.transactionId.equals(item.transaction.id))
// //       ..limit(1))
// //         .getSingleOrNull();
// //
// //     if (imageExists != null) {
// //       completedCount++;
// //     }
// //   }
// //
// //   return (completedCount / annualExpenses.length) * 100;
// // });
// //
// // // 📍 [수정] 연간 순이익률 계산 Provider (데이터 불일치 해결 버전)
// // final annualProfitMarginProvider = FutureProvider.family<double, int>((ref, year) async {
// //   // 📍 임시 월별 데이터가 아닌 전체 장부 데이터를 직접 참조
// //   final transactions = await ref.watch(ledgerListProvider.future);
// //
// //   double totalIncome = 0.0;
// //   double totalExpense = 0.0;
// //
// //   for (var item in transactions) {
// //     final tx = item.transaction;
// //     // 선택된 연도와 일치하는 데이터만 합산
// //     if (tx.transactionDate.year == year) {
// //       if (tx.type == 'INC') {
// //         totalIncome += tx.amount.toDouble();
// //       } else if (tx.type == 'EXP') {
// //         totalExpense += tx.amount.toDouble();
// //       }
// //     }
// //   }
// //
// //   // 수입이 0원 이하인 경우 계산 불가 (0% 반환)
// //   if (totalIncome <= 0) return 0.0;
// //
// //   // 순이익률 공식: ((총수입 - 총지출) / 총수입) * 100
// //   double netProfit = totalIncome - totalExpense;
// //   double margin = (netProfit / totalIncome) * 100;
// //
// //   return margin;
// // });
//
// // 📍 [실시간 수정] 지출 증빙 완료율: Stream을 통해 DB 변화를 실시간 감지
// final annualReceiptCompletionProvider = StreamProvider.family<double, int>((ref, year) {
//   final db = ref.watch(databaseProvider);
//
//   final startDate = DateTime(year, 1, 1);
//   final endDate = DateTime(year, 12, 31, 23, 59, 59);
//
//   // 1. 해당 연도 지출 데이터를 watch()하여 실시간 스트림 생성
//   final expenseStream = (db.select(db.transactions)
//     ..where((t) =>
//     t.type.equals('EXP') &
//     t.transactionDate.isBetweenValues(startDate, endDate)
//     ))
//       .watch();
//
//   // 2. 스트림 데이터를 가공하여 완료율 계산
//   return expenseStream.asyncMap((annualExpenses) async {
//     if (annualExpenses.isEmpty) return 0.0;
//
//     int completedCount = 0;
//     for (var tx in annualExpenses) {
//       // 단일 이미지 확인
//       if (tx.receiptImagePath != null && tx.receiptImagePath!.isNotEmpty) {
//         completedCount++;
//         continue;
//       }
//
//       // 다중 이미지 확인 (해당 트랜잭션의 이미지 존재 여부 쿼리)
//       final imageExists = await (db.select(db.transactionImages)
//         ..where((t) => t.transactionId.equals(tx.id))
//         ..limit(1))
//           .getSingleOrNull();
//
//       if (imageExists != null) {
//         completedCount++;
//       }
//     }
//     return (completedCount / annualExpenses.length) * 100;
//   });
// });
//
// // 📍 [실시간 수정] 순이익률: Stream을 통해 수입/지출 변화를 실시간 감지
// final annualProfitMarginProvider = StreamProvider.family<double, int>((ref, year) {
//   final db = ref.watch(databaseProvider);
//
//   final startDate = DateTime(year, 1, 1);
//   final endDate = DateTime(year, 12, 31, 23, 59, 59);
//
//   // 해당 연도의 모든 데이터를 watch()
//   return (db.select(db.transactions)
//     ..where((t) => t.transactionDate.isBetweenValues(startDate, endDate)))
//       .watch()
//       .map((annualTxs) {
//     double totalIncome = 0.0;
//     double totalExpense = 0.0;
//
//     for (var tx in annualTxs) {
//       if (tx.type == 'INC') {
//         totalIncome += tx.amount.toDouble();
//       } else if (tx.type == 'EXP') {
//         totalExpense += tx.amount.toDouble();
//       }
//     }
//
//     if (totalIncome <= 0) return 0.0;
//
//     double netProfit = totalIncome - totalExpense;
//     return (netProfit / totalIncome) * 100;
//   });
// });

//
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:drift/drift.dart'; // 📍 drift 쿼리를 위해 추가
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../../core/database/database_provider.dart'; // 📍 DB 접근을 위해 추가
// import '../ledger/ledger_provider.dart';
//
// // 📍 [신규] 전체 기간 누적 잔액을 실시간으로 계산하는 StreamProvider
// // 재무 위험도 지수가 연도 변경과 상관없이 '현재 자산 상태'를 유지하도록 함
// final totalCumulativeBalanceProvider = StreamProvider<double>((ref) {
//   final db = ref.watch(databaseProvider);
//
//   // 연도 필터 없이 모든 트랜잭션을 watch
//   return db.select(db.transactions).watch().map((allTxs) {
//     double totalIncome = 0.0;
//     double totalExpense = 0.0;
//
//     for (var tx in allTxs) {
//       if (tx.type == 'INC') {
//         totalIncome += tx.amount.toDouble();
//       } else if (tx.type == 'EXP') {
//         totalExpense += tx.amount.toDouble();
//       }
//     }
//     // 전 생애주기 총 순이익 (수입 - 지출 = 현재 잔액)
//     return totalIncome - totalExpense;
//   });
// });
//
// // 1. 월별 수입(Income) 데이터 Provider
// // 결과: {1: 10000, 2: 25000, ...} (월: 금액)
// final monthlyRevenueProvider = FutureProvider<Map<int, double>>((ref) async {
//   // 📍 반환 타입이 List<TransactionWithImages>로 변경됨
//   final transactions = await ref.watch(ledgerListProvider.future);
//
//   final Map<int, double> monthlyData = {};
//
//   // 1월~6월까지 0원으로 초기화 (그래프 모양 잡기 위해)
//   for (int i = 1; i <= 6; i++) {
//     monthlyData[i] = 0.0;
//   }
//
//   for (var item in transactions) {
//     // 📍 포장지(TransactionWithImages)에서 알맹이(transaction) 추출
//     final tx = item.transaction;
//
//     // 📍 수정: 'INC' 표준 키 사용 및 연도 체크
//     if (tx.type == 'INC' && tx.transactionDate.year == DateTime.now().year) {
//       final month = tx.transactionDate.month;
//       // 상반기(1~6월) 데이터만 예시로 집계
//       if (month <= 6) {
//         monthlyData[month] = (monthlyData[month] ?? 0) + tx.amount.toDouble();
//       }
//     }
//   }
//   return monthlyData;
// });
//
// // 2. 건물별 수입 데이터 Provider
// // 결과: {'Villa Sunrise': 50000, 'Other': 10000}
// final buildingRevenueProvider = FutureProvider<Map<String, double>>((ref) async {
//   final transactions = await ref.watch(ledgerListProvider.future);
//   final Map<String, double> buildingData = {};
//
//   // 📍 다국어 지원을 위해 번역 함수 준비
//   final l10n = ref.read(localizationProvider.notifier);
//
//   for (var item in transactions) {
//     // 📍 포장지에서 알맹이 추출
//     final tx = item.transaction;
//
//     // 📍 수정: 'INC' 표준 키 사용
//     if (tx.type == 'INC') {
//       // 현재는 건물 ID가 1로 고정되어 있으니 이름을 하드코딩하거나
//       // 나중에 건물 DB와 조인해야 합니다. 지금은 'Main Bldg'로 통일합니다.
//       // 📍 다국어 적용: "기본 건물" 명칭을 다국어 키로 처리
//       final buildingName = l10n.translate("REPORT_MAIN_BUILDING");
//
//       buildingData[buildingName] = (buildingData[buildingName] ?? 0) + tx.amount.toDouble();
//     }
//   }
//
//   // (테스트용) 차트가 예쁘게 나오도록 가짜 데이터 하나 추가
//   if (buildingData.isNotEmpty) {
//     // 📍 다국어 적용: "부속 건물" 명칭
//     final sideBldgName = l10n.translate("REPORT_SIDE_BUILDING");
//     buildingData[sideBldgName] = buildingData.values.first * 0.3;
//   }
//
//   return buildingData;
// });
//
// // 📍 [실시간 수정] 지출 증빙 완료율: Stream을 통해 DB 변화를 실시간 감지
// final annualReceiptCompletionProvider = StreamProvider.family<double, int>((ref, year) {
//   final db = ref.watch(databaseProvider);
//
//   final startDate = DateTime(year, 1, 1);
//   final endDate = DateTime(year, 12, 31, 23, 59, 59);
//
//   // 1. 해당 연도 지출 데이터를 watch()하여 실시간 스트림 생성
//   final expenseStream = (db.select(db.transactions)
//     ..where((t) =>
//     t.type.equals('EXP') &
//     t.transactionDate.isBetweenValues(startDate, endDate)
//     ))
//       .watch();
//
//   // 2. 스트림 데이터를 가공하여 완료율 계산
//   return expenseStream.asyncMap((annualExpenses) async {
//     if (annualExpenses.isEmpty) return 0.0;
//
//     int completedCount = 0;
//     for (var tx in annualExpenses) {
//       // 단일 이미지 확인
//       if (tx.receiptImagePath != null && tx.receiptImagePath!.isNotEmpty) {
//         completedCount++;
//         continue;
//       }
//
//       // 다중 이미지 확인 (해당 트랜잭션의 이미지 존재 여부 쿼리)
//       final imageExists = await (db.select(db.transactionImages)
//         ..where((t) => t.transactionId.equals(tx.id))
//         ..limit(1))
//           .getSingleOrNull();
//
//       if (imageExists != null) {
//         completedCount++;
//       }
//     }
//     return (completedCount / annualExpenses.length) * 100;
//   });
// });
//
// // 📍 [실시간 수정] 순이익률: Stream을 통해 수입/지출 변화를 실시간 감지
// final annualProfitMarginProvider = StreamProvider.family<double, int>((ref, year) {
//   final db = ref.watch(databaseProvider);
//
//   final startDate = DateTime(year, 1, 1);
//   final endDate = DateTime(year, 12, 31, 23, 59, 59);
//
//   // 해당 연도의 모든 데이터를 watch()
//   return (db.select(db.transactions)
//     ..where((t) => t.transactionDate.isBetweenValues(startDate, endDate)))
//       .watch()
//       .map((annualTxs) {
//     double totalIncome = 0.0;
//     double totalExpense = 0.0;
//
//     for (var tx in annualTxs) {
//       if (tx.type == 'INC') {
//         totalIncome += tx.amount.toDouble();
//       } else if (tx.type == 'EXP') {
//         totalExpense += tx.amount.toDouble();
//       }
//     }
//
//     if (totalIncome <= 0) return 0.0;
//
//     double netProfit = totalIncome - totalExpense;
//     return (netProfit / totalIncome) * 100;
//   });
// });


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart'; // 📍 drift 쿼리를 위해 추가
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/database_provider.dart'; // 📍 DB 접근을 위해 추가
import '../ledger/ledger_provider.dart';

// 📍 [신규] 전체 기간 누적 잔액을 실시간으로 계산하는 StreamProvider
// 재무 위험도 지수가 연도 변경과 상관없이 '현재 자산 상태'를 유지하도록 함
final totalCumulativeBalanceProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);

  // 연도 필터 없이 모든 트랜잭션을 watch
  return db.select(db.transactions).watch().map((allTxs) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in allTxs) {
      if (tx.type == 'INC') {
        totalIncome += tx.amount.toDouble();
      } else if (tx.type == 'EXP') {
        totalExpense += tx.amount.toDouble();
      }
    }
    // 전 생애주기 총 순이익 (수입 - 지출 = 현재 잔액)
    return totalIncome - totalExpense;
  });
});

// 1. 월별 수입(Income) 데이터 Provider
// 결과: {1: 10000, 2: 25000, ...} (월: 금액)
final monthlyRevenueProvider = FutureProvider<Map<int, double>>((ref) async {
  // 📍 반환 타입이 List<TransactionWithImages>로 변경됨
  final transactions = await ref.watch(ledgerListProvider.future);

  final Map<int, double> monthlyData = {};

  // 1월~6월까지 0원으로 초기화 (그래프 모양 잡기 위해)
  for (int i = 1; i <= 6; i++) {
    monthlyData[i] = 0.0;
  }

  for (var item in transactions) {
    // 📍 포장지(TransactionWithImages)에서 알맹이(transaction) 추출
    final tx = item.transaction;

    // 📍 수정: 'INC' 표준 키 사용 및 연도 체크
    if (tx.type == 'INC' && tx.transactionDate.year == DateTime.now().year) {
      final month = tx.transactionDate.month;
      // 상반기(1~6월) 데이터만 예시로 집계
      if (month <= 6) {
        monthlyData[month] = (monthlyData[month] ?? 0) + tx.amount.toDouble();
      }
    }
  }
  return monthlyData;
});

// 2. 건물별 수입 데이터 Provider
// 결과: {'Villa Sunrise': 50000, 'Other': 10000}
final buildingRevenueProvider = FutureProvider<Map<String, double>>((ref) async {
  final transactions = await ref.watch(ledgerListProvider.future);
  final Map<String, double> buildingData = {};

  // 📍 다국어 지원을 위해 번역 함수 준비
  final l10n = ref.read(localizationProvider.notifier);

  for (var item in transactions) {
    // 📍 포장지에서 알맹이 추출
    final tx = item.transaction;

    // 📍 수정: 'INC' 표준 키 사용
    if (tx.type == 'INC') {
      // 현재는 건물 ID가 1로 고정되어 있으니 이름을 하드코딩하거나
      // 나중에 건물 DB와 조인해야 합니다. 지금은 'Main Bldg'로 통일합니다.
      // 📍 다국어 적용: "기본 건물" 명칭을 다국어 키로 처리
      final buildingName = l10n.translate("REPORT_MAIN_BUILDING");

      buildingData[buildingName] = (buildingData[buildingName] ?? 0) + tx.amount.toDouble();
    }
  }

  // (테스트용) 차트가 예쁘게 나오도록 가짜 데이터 하나 추가
  if (buildingData.isNotEmpty) {
    // 📍 다국어 적용: "부속 건물" 명칭
    final sideBldgName = l10n.translate("REPORT_SIDE_BUILDING");
    buildingData[sideBldgName] = buildingData.values.first * 0.3;
  }

  return buildingData;
});

// 📍 [실시간 수정] 지출 증빙 완료율: Stream을 통해 DB 변화를 실시간 감지
final annualReceiptCompletionProvider = StreamProvider.family<double, int>((ref, year) {
  final db = ref.watch(databaseProvider);

  final startDate = DateTime(year, 1, 1);
  final endDate = DateTime(year, 12, 31, 23, 59, 59);

  // 1. 해당 연도 지출 데이터를 watch()하여 실시간 스트림 생성
  final expenseStream = (db.select(db.transactions)
    ..where((t) =>
    t.type.equals('EXP') &
    t.transactionDate.isBetweenValues(startDate, endDate)
    ))
      .watch();

  // 2. 스트림 데이터를 가공하여 완료율 계산
  return expenseStream.asyncMap((annualExpenses) async {
    if (annualExpenses.isEmpty) return 0.0;

    int completedCount = 0;
    for (var tx in annualExpenses) {
      // 단일 이미지 확인
      if (tx.receiptImagePath != null && tx.receiptImagePath!.isNotEmpty) {
        completedCount++;
        continue;
      }

      // 다중 이미지 확인 (해당 트랜잭션의 이미지 존재 여부 쿼리)
      final imageExists = await (db.select(db.transactionImages)
        ..where((t) => t.transactionId.equals(tx.id))
        ..limit(1))
          .getSingleOrNull();

      if (imageExists != null) {
        completedCount++;
      }
    }
    return (completedCount / annualExpenses.length) * 100;
  });
});

// 📍 [실시간 수정] 순이익률: Stream을 통해 수입/지출 변화를 실시간 감지
final annualProfitMarginProvider = StreamProvider.family<double, int>((ref, year) {
  final db = ref.watch(databaseProvider);

  final startDate = DateTime(year, 1, 1);
  final endDate = DateTime(year, 12, 31, 23, 59, 59);

  // 해당 연도의 모든 데이터를 watch()
  return (db.select(db.transactions)
    ..where((t) => t.transactionDate.isBetweenValues(startDate, endDate)))
      .watch()
      .map((annualTxs) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in annualTxs) {
      if (tx.type == 'INC') {
        totalIncome += tx.amount.toDouble();
      } else if (tx.type == 'EXP') {
        totalExpense += tx.amount.toDouble();
      }
    }

    if (totalIncome <= 0) return 0.0;

    double netProfit = totalIncome - totalExpense;
    return (netProfit / totalIncome) * 100;
  });
});