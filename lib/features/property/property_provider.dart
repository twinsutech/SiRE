import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

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
    // (공실이 아닌 방만 계산해야 하지만, 일단 단순 합계로 갑니다)
    int totalMonthlyRent = units.fold(0, (sum, unit) => sum + unit.monthlyRent);
    int totalDeposit = units.fold(0, (sum, unit) => sum + unit.deposit);

    double investment = building.purchasePrice! - totalDeposit;
    if (investment <= 0) return 0.0;

    return ((totalMonthlyRent * 12) / investment) * 100;
  }
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