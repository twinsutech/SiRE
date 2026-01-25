import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'ledger_provider.dart';
import 'package:drift/drift.dart'; // 📍 필터 확장을 위해 추가

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

  // 2. 월세 혹은 반전세 계약이면서, 월세 금액이 0보다 큰 모든 호실 정보를 가져옵니다.
  // 📍 수정 포인트: u.leaseType.equals('반전세') 조건 추가
  final units = await (db.select(db.units)
    ..where((u) =>
    u.leaseType.equals('월세') | u.leaseType.equals('반전세')
    )).get();

  final now = DateTime.now();
  final List<UnpaidStatus> results = [];

  for (var unit in units) {
    // 📍 월세가 0원인 경우는 미납 체크 의미가 없으므로 스킵 (전세 등 예외처리)
    if (unit.monthlyRent <= 0) continue;

    // 3. 납부 기한일 계산 (IntColumn인 paymentDay 활용)
    final dueDay = unit.paymentDay ?? 1;
    // 이번 달 납부 기한 날짜 생성
    final dueDate = DateTime(now.year, now.month, dueDay);

    // 4. 해당 호실의 이번 달 입금액 합산
    // 📍 다국어 최적화: 특정 언어 텍스트가 아닌 '고정 키'나 포함 여부로 판별합니다.
    final paidAmount = transactions
        .where((t) {
      final tx = t.transaction;
      final cat = tx.category.toUpperCase();
      return tx.unitId == unit.id &&
          tx.type == 'INC' &&
          // 📍 카테고리가 월세 관련 키워드(CAT_RENT 등)를 포함하는지 확인
          (cat.contains('RENT') || cat.contains('월세') || cat.contains('임대료') || cat.contains('家賃'));
    })
        .fold(0, (sum, t) => sum + t.transaction.amount.toInt());

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