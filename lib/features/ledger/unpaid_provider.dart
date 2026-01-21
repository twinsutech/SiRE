import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'ledger_provider.dart';

part 'unpaid_provider.g.dart';

// 📍 미납 상태 정보 클래스
class UnpaidStatus {
  final Unit unit;
  final String status; // 'PAID'(완납), 'WAITING'(입금대기), 'OVERDUE'(미납/연체)
  final int paidAmount;
  final DateTime dueDate;

  UnpaidStatus({
    required this.unit,
    required this.status,
    required this.paidAmount,
    required this.dueDate,
  });
}

@riverpod
Future<List<UnpaidStatus>> unpaidList(UnpaidListRef ref) async {
  final db = ref.watch(databaseProvider);

  // 1. 이번 달 장부 내역(ledgerList)을 구독합니다.
  final transactions = await ref.watch(ledgerListProvider.future);

  // 2. 월세 계약인 모든 호실 정보를 가져옵니다.
  final units = await (db.select(db.units)..where((u) => u.leaseType.equals('월세'))).get();

  final now = DateTime.now();
  final List<UnpaidStatus> results = [];

  for (var unit in units) {
    // 3. 납부 기한일 계산 (IntColumn인 paymentDay 활용)
    final dueDay = unit.paymentDay ?? 1;
    // 이번 달 납부 기한 날짜 생성
    final dueDate = DateTime(now.year, now.month, dueDay);

    // 4. 해당 호실의 이번 달 '월세' 입금액 합산
    // 장부의 unitId와 카테고리가 '월세'인 INC 내역을 찾습니다.
    final paidAmount = transactions
        .where((t) =>
    t.transaction.unitId == unit.id &&
        t.transaction.type == 'INC' &&
        t.transaction.category == '월세'
    )
        .fold(0, (sum, t) => sum + t.transaction.amount.toInt()); // toInt()로 형변환 에러까지 해결

    // 5. 상태 판별 로직
    String status;
    if (paidAmount >= unit.monthlyRent) {
      status = 'PAID'; // 완납
    } else if (now.isAfter(dueDate.add(const Duration(days: 1)))) {
      // 기한일 자정 이후인데 입금이 부족한 경우
      status = 'OVERDUE';
    } else {
      // 아직 기한이 지나지 않은 경우
      status = 'WAITING';
    }

    results.add(UnpaidStatus(
      unit: unit,
      status: status,
      paidAmount: paidAmount,
      dueDate: dueDate,
    ));
  }

  // 📍 정렬: 미납(OVERDUE) -> 대기(WAITING) -> 완료(PAID) 순
  results.sort((a, b) {
    const statusOrder = {'OVERDUE': 0, 'WAITING': 1, 'PAID': 2};
    return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
  });

  return results;
}