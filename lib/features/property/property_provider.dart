import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
// 📍 실제 미납 데이터를 가져오기 위해 임포트
import '../ledger/unpaid_provider.dart';

part 'property_provider.g.dart';

// 1. 데이터를 묶어줄 클래스 (건물 1개 + 그 건물의 방들)
class BuildingWithUnits {
  final Building building;
  final List<Unit> units;

  BuildingWithUnits({required this.building, required this.units});

  // 수익률 계산 로직 (간단 버전)
  double get yieldRate {
    if (building.purchasePrice == null || building.purchasePrice == 0) return 0.0;

    // 연간 임대료 = (월세 * 12) 들의 합
    int totalMonthlyRent = units.fold(0, (sum, unit) => sum + unit.monthlyRent);
    int totalDeposit = units.fold(0, (sum, unit) => sum + unit.deposit);

    double investment = building.purchasePrice!.toDouble() - totalDeposit;
    if (investment <= 0) return 0.0;

    return ((totalMonthlyRent * 12) / investment) * 100;
  }
}

// 📍 [신규 추가] 전체 요약 데이터를 담는 클래스
class PropertySummary {
  final double collectionRate; // 수금 진척도 (0.0 ~ 1.0)
  final int totalUnpaid;      // 📍 미납 호실 수
  final int totalVacancies;    // 전체 공실 수
  final int expiringSoon;      // 만기 임박 수 (30일 이내)
  final double averageYield;   // 전체 평균 수익률

  PropertySummary({
    required this.collectionRate,
    required this.totalUnpaid,
    required this.totalVacancies,
    required this.expiringSoon,
    required this.averageYield,
  });
}

// 2. 리버팟 프로바이더 (DB에서 데이터를 가져오는 역할)
@riverpod
Future<List<BuildingWithUnits>> propertyList(PropertyListRef ref) async {
  final db = ref.watch(databaseProvider);

  // 1) 모든 건물 조회
  final buildings = await db.select(db.buildings).get();

  // 2) 각 건물별로 세대(Unit) 정보 조회해서 합치기
  final List<BuildingWithUnits> result = [];

  for (final b in buildings) {
    final units = await (db.select(db.units)
      ..where((tbl) => tbl.buildingId.equals(b.id))) // 건물 ID로 필터링
        .get();

    result.add(BuildingWithUnits(building: b, units: units));
  }

  return result;
}

// 📍 [신규 추가] 요약 통계 프로바이더
@riverpod
Future<PropertySummary> propertySummary(PropertySummaryRef ref) async {
  // 📍 건물 리스트와 미납 리스트를 모두 구독합니다.
  // 📍 다국어 대응: 미납 리스트는 내부적으로 CAT_RENT 등 고정 키를 사용하여 계산되므로 안전합니다.
  final propertyList = await ref.watch(propertyListProvider.future);
  final unpaidList = await ref.watch(unpaidListProvider.future);

  if (propertyList.isEmpty) {
    return PropertySummary(
      collectionRate: 0,
      totalUnpaid: 0,
      totalVacancies: 0,
      expiringSoon: 0,
      averageYield: 0,
    );
  }

  int totalUnits = 0;
  int vacantUnits = 0;
  int expiringCount = 0;
  double sumYield = 0;
  int totalTenantUnits = 0; // 실제 거주중인 세대 수

  // 1. 건물별 루프를 돌며 공실, 만기임박, 수익률 합산
  for (var item in propertyList) {
    totalUnits += item.units.length;
    sumYield += item.yieldRate;

    for (var unit in item.units) {
      // 공실 체크 (tenantName이 비어있으면 공실로 판단)
      if (unit.tenantName == null || unit.tenantName!.trim().isEmpty) {
        vacantUnits++;
      } else {
        totalTenantUnits++;
        // 만기 임박 체크 (30일 이내)
        if (unit.contractEnd != null) {
          final daysLeft = unit.contractEnd!.difference(DateTime.now()).inDays;
          if (daysLeft >= 0 && daysLeft <= 30) expiringCount++;
        }
      }
    }
  }

  // 📍 2. 미납 데이터 처리 (unpaidListProvider 활용)
  // status가 'OVERDUE'인 호실의 개수를 셉니다.
  // 이 로직은 언어 설정과 관계없이 고정된 ENUM 성격의 문자열 'OVERDUE'를 기준으로 작동합니다.
  final overdueUnits = unpaidList.where((s) => s.status == 'OVERDUE').toList();
  final int unpaidCount = overdueUnits.length;

  // 📍 3. 실제 수금율 계산
  // 수금율 = (거주 세대 중 미납이 아닌 세대) / 거주 세대
  double actualCollectionRate = 0.0;
  if (totalTenantUnits > 0) {
    actualCollectionRate = (totalTenantUnits - unpaidCount) / totalTenantUnits;
  }

  return PropertySummary(
    collectionRate: actualCollectionRate,
    totalUnpaid: unpaidCount, // 📍 실제 계산된 미납 수 전달
    totalVacancies: vacantUnits,
    expiringSoon: expiringCount,
    averageYield: propertyList.isNotEmpty ? (sumYield / propertyList.length) : 0,
  );
}