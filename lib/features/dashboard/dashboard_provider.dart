// lib/src/features/dashboard/dashboard_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drift/drift.dart';

import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../ledger/ledger_provider.dart';
import '../property/property_provider.dart';

part 'dashboard_provider.g.dart';

class DashboardState {
  final int totalIncome;
  final int totalExpense;
  final double occupancyRate;
  final int totalUnits;
  final int vacantUnits;
  // 📍 [수정] Transaction -> TransactionWithImages로 변경하여 장부와 타입 일치
  final List<TransactionWithImages> recentTransactions;
  final List<FlSpot> revenueSpots;
  final List<FlSpot> expenseSpots;

  DashboardState({
    required this.totalIncome,
    required this.totalExpense,
    required this.occupancyRate,
    required this.totalUnits,
    required this.vacantUnits,
    required this.recentTransactions,
    required this.revenueSpots,
    required this.expenseSpots,
  });
}

@riverpod
Future<DashboardState> dashboardData(DashboardDataRef ref) async {
  final db = ref.watch(databaseProvider);

  // 📍 다국어 노티파이어 참조 (향후 상태 내 동적 메시지 생성이 필요할 경우 대비)
  // final l10n = ref.read(localizationProvider.notifier);

  // 1. 요약 및 부동산 정보
  final summary = await ref.watch(ledgerSummaryProvider.future);
  final propertyWithUnits = await ref.watch(propertyListProvider.future);

  // 2. 공실률 계산
  int totalUnits = 0;
  int occupiedCount = 0;
  for (var building in propertyWithUnits) {
    totalUnits += building.units.length;
    occupiedCount += building.units
        .where((u) => u.tenantName != null && u.tenantName!.isNotEmpty)
        .length;
  }
  final int vacantCount = totalUnits - occupiedCount;
  final double occupancy = totalUnits > 0 ? occupiedCount / totalUnits : 0.0;

  // 📍 3. 최근 활동 (장부 로직과 완벽 동기화)
  // 이번 달 내역에 국한되지 않고 전체 내역에서 최신 5개를 가져오기 위해 직접 쿼리 수행
  final txs = await (db.select(db.transactions)
    ..orderBy([
          (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)
    ])
    ..limit(5))
      .get();

  // 영수증 유무 포함된 객체로 변환
  final List<TransactionWithImages> recentWithImages = [];
  for (var tx in txs) {
    final imgCheck = await (db.select(db.transactionImages)
      ..where((ti) => ti.transactionId.equals(tx.id))
      ..limit(1))
        .get();
    recentWithImages.add(TransactionWithImages(transaction: tx, hasImages: imgCheck.isNotEmpty));
  }

  // 4. 최근 6개월 트렌드 (그래프용)
  final List<FlSpot> revenueSpots = [];
  final List<FlSpot> expenseSpots = [];
  final now = DateTime.now();

  for (int i = 0; i < 6; i++) {
    // 📍 5개월 전부터 이번 달까지 순차적으로 계산
    final targetMonth = DateTime(now.year, now.month - (5 - i), 1);
    final nextMonth = DateTime(now.year, now.month - (5 - i) + 1, 1);

    final revenueQuery = db.selectOnly(db.transactions)
      ..addColumns([db.transactions.amount.sum()])
      ..where(db.transactions.type.equals('INC') &
      db.transactions.transactionDate.isBetweenValues(targetMonth, nextMonth.subtract(const Duration(seconds: 1))));

    final expenseQuery = db.selectOnly(db.transactions)
      ..addColumns([db.transactions.amount.sum()])
      ..where(db.transactions.type.equals('EXP') &
      db.transactions.transactionDate.isBetweenValues(targetMonth, nextMonth.subtract(const Duration(seconds: 1))));

    final rev = await revenueQuery.map((row) => row.read(db.transactions.amount.sum())).getSingle();
    final exp = await expenseQuery.map((row) => row.read(db.transactions.amount.sum())).getSingle();

    revenueSpots.add(FlSpot(i.toDouble(), (rev ?? 0).toDouble()));
    expenseSpots.add(FlSpot(i.toDouble(), (exp ?? 0).toDouble()));
  }

  return DashboardState(
    totalIncome: summary.totalIncome,
    totalExpense: summary.totalExpense,
    occupancyRate: occupancy,
    totalUnits: totalUnits,
    vacantUnits: vacantCount,
    recentTransactions: recentWithImages, // 📍 영수증 여부 포함된 최신 5건
    revenueSpots: revenueSpots,
    expenseSpots: expenseSpots,
  );
}