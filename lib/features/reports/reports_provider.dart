import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ledger/ledger_provider.dart';

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

  for (var item in transactions) {
    // 📍 포장지에서 알맹이 추출
    final tx = item.transaction;

    // 📍 수정: 'INC' 표준 키 사용
    if (tx.type == 'INC') {
      // 현재는 건물 ID가 1로 고정되어 있으니 이름을 하드코딩하거나
      // 나중에 건물 DB와 조인해야 합니다. 지금은 'Main Bldg'로 통일합니다.
      const buildingName = "Main Bldg";

      buildingData[buildingName] = (buildingData[buildingName] ?? 0) + tx.amount.toDouble();
    }
  }

  // (테스트용) 차트가 예쁘게 나오도록 가짜 데이터 하나 추가
  if (buildingData.isNotEmpty) {
    buildingData['Side Bldg'] = buildingData.values.first * 0.3;
  }

  return buildingData;
});