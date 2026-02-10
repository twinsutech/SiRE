// lib/src/features/ledger/ledger_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트

part 'ledger_provider.g.dart';

// -----------------------------------------------------------------------------
// 📍 1. 데이터 모델 정의
// -----------------------------------------------------------------------------
class TransactionWithImages {
  final Transaction transaction;
  final bool hasImages;

  TransactionWithImages({required this.transaction, required this.hasImages});
}

class LedgerSummary {
  final int totalIncome;
  final int totalExpense;
  final int balance;

  LedgerSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });
}

// -----------------------------------------------------------------------------
// 📍 2. 날짜 선택 상태 관리
// -----------------------------------------------------------------------------
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();
  void update(DateTime date) => state = date;
  void updateMonth(int monthToAdd) {
    state = DateTime(state.year, state.month + monthToAdd, state.day);
  }
}

// -----------------------------------------------------------------------------
// 📍 3. 트랜잭션 리스트 (장부 화면용)
// -----------------------------------------------------------------------------
@riverpod
Future<List<TransactionWithImages>> ledgerList(LedgerListRef ref) async {
  final db = ref.watch(databaseProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
  final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);

  // 📍 수정 사항 반영: 날짜 내림차순(desc) 및 ID 내림차순(desc)으로 정렬하여 최신 입력건이 항상 위로 오게 함
  final txs = await (db.select(db.transactions)
    ..where((t) => t.transactionDate.isBetweenValues(firstDay, lastDay))
    ..orderBy([
          (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]))
      .get();

  final List<TransactionWithImages> result = [];
  for (var tx in txs) {
    final images = await (db.select(db.transactionImages)
      ..where((ti) => ti.transactionId.equals(tx.id))
      ..limit(1))
        .get();

    result.add(TransactionWithImages(
      transaction: tx,
      hasImages: images.isNotEmpty,
    ));
  }

  return result;
}

// -----------------------------------------------------------------------------
// 📍 4. 요약 정보 계산
// -----------------------------------------------------------------------------
@riverpod
Future<LedgerSummary> ledgerSummary(LedgerSummaryRef ref) async {
  // 📍 Future<List<TransactionWithImages>>임을 명시적으로 인지
  final List<TransactionWithImages> items = await ref.watch(ledgerListProvider.future);

  int income = 0;
  int expense = 0;

  for (var item in items) {
    final tx = item.transaction;
    if (tx.type == 'INC') {
      income += tx.amount.toInt(); // 📍 num -> int 형변환
    } else if (tx.type == 'EXP') {
      expense += tx.amount.toInt(); // 📍 num -> int 형변환
    }
  }

  return LedgerSummary(
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
  );
}

// -----------------------------------------------------------------------------
// 📍 5. 카테고리별 지출 통계
// -----------------------------------------------------------------------------
@riverpod
Future<List<({String category, int amount, double percentage})>> categoryStatistics(CategoryStatisticsRef ref) async {
  final List<TransactionWithImages> items = await ref.watch(ledgerListProvider.future);
  final expenses = items.where((item) => item.transaction.type == 'EXP').toList();

  if (expenses.isEmpty) return [];

  int totalExpense = 0;
  final Map<String, int> grouped = {};

  for (var item in expenses) {
    final tx = item.transaction;
    final amount = tx.amount.toInt();
    totalExpense += amount;
    grouped[tx.category] = (grouped[tx.category] ?? 0) + amount;
  }

  final result = grouped.entries.map((entry) => (
  category: entry.key,
  amount: entry.value,
  percentage: totalExpense > 0 ? entry.value / totalExpense : 0.0,
  )).toList();

  // 금액이 큰 항목순으로 정렬
  result.sort((a, b) => b.amount.compareTo(a.amount));
  return result;
}

// -----------------------------------------------------------------------------
// 📍 [신규 추가] 연간 카테고리별 지출 통계 (보고서 화면 전용)
// -----------------------------------------------------------------------------
// @riverpod
// Future<List<({String category, int amount, double percentage})>> annualCategoryStatistics(AnnualCategoryStatisticsRef ref) async {
//   final db = ref.watch(databaseProvider);
//
//   // 📍 현재 연도의 1월 1일부터 12월 31일까지 데이터를 직접 가져옵니다.
//   final now = DateTime.now();
//   final firstDayOfYear = DateTime(now.year, 1, 1);
//   final lastDayOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
//
//   final annualExpenses = await (db.select(db.transactions)
//     ..where((t) {
//       return t.type.equals('EXP') &
//       t.transactionDate.isBetweenValues(firstDayOfYear, lastDayOfYear);
//     }))
//       .get();
//
//   if (annualExpenses.isEmpty) { return []; }
//
//   int totalExpense = 0;
//   final Map<String, int> grouped = {};
//
//   for (var tx in annualExpenses) {
//     final amount = tx.amount.toInt();
//     totalExpense += amount;
//     grouped[tx.category] = (grouped[tx.category] ?? 0) + amount;
//   }
//
//   final result = grouped.entries.map((entry) {
//     return (
//     category: entry.key,
//     amount: entry.value,
//     percentage: totalExpense > 0 ? entry.value / totalExpense : 0.0,
//     );
//   }).toList();
//
//   result.sort((a, b) { return b.amount.compareTo(a.amount); });
//   return result;
// }

// 📍 [고도화] 연도별 통계를 위한 프로바이더 (선택된 연도를 인자로 받음)
@riverpod
Future<List<({String category, int amount, double percentage})>> annualCategoryStatistics(
    AnnualCategoryStatisticsRef ref,
    int year // 📍 연도를 인자로 받도록 수정
    ) async {
  final db = ref.watch(databaseProvider);

  // 📍 회계 기준: 해당 연도 1월 1일 ~ 12월 31일
  final firstDay = DateTime(year, 1, 1);
  final lastDay = DateTime(year, 12, 31, 23, 59, 59);

  final annualExpenses = await (db.select(db.transactions)
    ..where((t) {
      return t.type.equals('EXP') &
      t.transactionDate.isBetweenValues(firstDay, lastDay);
    }))
      .get();

  if (annualExpenses.isEmpty) { return []; }

  int totalExpense = 0;
  final Map<String, int> grouped = {};

  for (var tx in annualExpenses) {
    final amount = tx.amount.toInt();
    totalExpense += amount;
    grouped[tx.category] = (grouped[tx.category] ?? 0) + amount;
  }

  final result = grouped.entries.map((entry) {
    return (
    category: entry.key,
    amount: entry.value,
    percentage: totalExpense > 0 ? entry.value / totalExpense : 0.0,
    );
  }).toList();

  result.sort((a, b) { return b.amount.compareTo(a.amount); });
  return result;
}



// -----------------------------------------------------------------------------
// 📍 6. 검색 기능 (최신순 정렬 반영)
// -----------------------------------------------------------------------------
@riverpod
Future<List<Transaction>> searchTransactions(SearchTransactionsRef ref, String keyword) async {
  if (keyword.trim().isEmpty) return [];
  final db = ref.watch(databaseProvider);
  return (db.select(db.transactions)
    ..where((t) => t.category.contains(keyword) | (t.memo.contains(keyword)))
  // 📍 정렬 수정: 검색 결과도 최신 입력 날짜가 가장 먼저 보이도록 수정
    ..orderBy([
          (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]))
      .get();
}

// -----------------------------------------------------------------------------
// 📍 7. 달력용 데이터
// -----------------------------------------------------------------------------
@riverpod
Future<Map<DateTime, List<Transaction>>> calendarEvents(CalendarEventsRef ref) async {
  final List<TransactionWithImages> items = await ref.watch(ledgerListProvider.future);
  final Map<DateTime, List<Transaction>> events = {};

  for (var item in items) {
    final tx = item.transaction;
    final date = DateTime.utc(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);
    if (events[date] == null) events[date] = [];
    events[date]!.add(tx);
  }
  return events;
}

// -----------------------------------------------------------------------------
// 📍 월별 추이 데이터 (보고서용)
// -----------------------------------------------------------------------------
// @riverpod
// Future<List<({DateTime month, int income, int expense})>> monthlyTrend(MonthlyTrendRef ref) async {
//   final db = ref.watch(databaseProvider);
//   final now = DateTime.now();
//   final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
//
//   final transactions = await (db.select(db.transactions)
//     ..where((t) => t.transactionDate.isBiggerOrEqualValue(sixMonthsAgo))
//     ..orderBy([(t) => OrderingTerm.asc(t.transactionDate)]))
//       .get();
//
//   final List<({DateTime month, int income, int expense})> result = [];
//
//   for (int i = 5; i >= 0; i--) {
//     final m = DateTime(now.year, now.month - i, 1);
//     int mIncome = 0;
//     int mExpense = 0;
//
//     for (var tx in transactions) {
//       if (tx.transactionDate.year == m.year && tx.transactionDate.month == m.month) {
//         if (tx.type == 'INC') mIncome += tx.amount.toInt();
//         if (tx.type == 'EXP') mExpense += tx.amount.toInt();
//       }
//     }
//     result.add((month: m, income: mIncome, expense: mExpense));
//   }
//   return result;
// }
// 📍 월별 추이 데이터 (보고서 전용 - 12개월로 확장)
@riverpod
Future<List<({DateTime month, int income, int expense})>> monthlyTrend(MonthlyTrendRef ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  // 📍 기존 5에서 11로 변경하여 현재 포함 최근 1년(12개월) 데이터를 가져옴
  final twelveMonthsAgo = DateTime(now.year, now.month - 11, 1);

  final transactions = await (db.select(db.transactions)
    ..where((t) { return t.transactionDate.isBiggerOrEqualValue(twelveMonthsAgo); })
    ..orderBy([(t) { return OrderingTerm.asc(t.transactionDate); }]))
      .get();

  final List<({DateTime month, int income, int expense})> result = [];

  // 📍 11부터 0까지 역순으로 12개월치 데이터 생성
  for (int i = 11; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i, 1);
    int mIncome = 0;
    int mExpense = 0;

    for (var tx in transactions) {
      if (tx.transactionDate.year == m.year && tx.transactionDate.month == m.month) {
        if (tx.type == 'INC') { mIncome += tx.amount.toInt(); }
        if (tx.type == 'EXP') { mExpense += tx.amount.toInt(); }
      }
    }
    result.add((month: m, income: mIncome, expense: mExpense));
  }
  return result;
}


// -----------------------------------------------------------------------------
// 📍 8. 통합 액션
// -----------------------------------------------------------------------------
@riverpod
class LedgerAction extends _$LedgerAction {
  @override
  FutureOr<void> build() => null;

  Future<void> addTransaction({
    required String type,
    required int amount,
    required String category,
    required DateTime date,
    String? memo,
    String? receiptPath,
  }) async {
    final db = ref.read(databaseProvider);

    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        buildingId: 1,
        type: type,
        amount: amount,
        category: category,
        transactionDate: date,
        memo: memo != null ? Value(memo) : const Value.absent(),
        receiptImagePath: receiptPath != null ? Value(receiptPath) : const Value.absent(),
      ),
    );

    _invalidateLedgerData();
  }

  Future<void> processPayment({
    required int buildingId,
    required int unitId,
    required String tenantName,
    required int amount,
    required String buildingName,
    required String unitNumber,
  }) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    // 📍 다국어 지원을 위해 노티파이어 참조
    final l10n = ref.read(localizationProvider.notifier);

    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        buildingId: buildingId,
        unitId: Value(unitId),
        amount: amount,
        type: 'INC',
        // 📍 카테고리도 'CAT_RENT' 같은 고유 키로 저장하는 것이 다국어 환경에서 안전합니다.
        category: 'CAT_RENT',
        // 📍 메모 역시 현재 언어 설정에 맞춰 자동 생성되도록 수정
        memo: Value('$unitNumber${l10n.translate("COMMON_ROOM_UNIT")} ($tenantName) ${l10n.translate("DASHBOARD_PAYMENT_CONFIRM")}'),
        transactionDate: now,
      ),
    );

    _invalidateLedgerData();
  }

  void _invalidateLedgerData() {
    ref.invalidate(ledgerListProvider);
    ref.invalidate(ledgerSummaryProvider);
    ref.invalidate(monthlyTrendProvider);
    ref.invalidate(categoryStatisticsProvider);
    ref.invalidate(calendarEventsProvider);
  }
}