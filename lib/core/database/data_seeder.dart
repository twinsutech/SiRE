import 'package:drift/drift.dart';
import 'app_database.dart';

// 초기 데이터를 넣는 함수
Future<void> seedDatabase(AppDatabase db) async {
  print("🚀 데이터 확인 및 초기화를 시작합니다...");

  // --- 1. 건물 및 유닛 데이터 시딩 ---
  final buildingCount = await db.select(db.buildings).get();
  if (buildingCount.isEmpty) {
    print("🏢 건물 데이터가 없어 생성을 시작합니다...");

    // 건물 추가 (Villa Sunrise)
    final buildingId = await db.into(db.buildings).insert(
      BuildingsCompanion.insert(
        name: 'Villa Sunrise',
        address: const Value('Seoul, Gangnam-gu, 123-45'),
        purchasePrice: const Value(1200000),
      ),
    );

    // 101호: 정상 납부
    await db.into(db.units).insert(
      UnitsCompanion.insert(
        buildingId: buildingId,
        roomNumber: '101',
        tenantName: const Value('John Doe'),
        tenantPhone: const Value('010-1234-5678'),
        deposit: const Value(5000),
        monthlyRent: const Value(500),
        contractStart: Value(DateTime(2023, 1, 1)),
        contractEnd: Value(DateTime(2025, 1, 1)),
      ),
    );

    // 201호: 연체 중
    await db.into(db.units).insert(
      UnitsCompanion.insert(
        buildingId: buildingId,
        roomNumber: '201',
        tenantName: const Value('Jane Smith'),
        deposit: const Value(5000),
        monthlyRent: const Value(600),
        contractStart: Value(DateTime(2023, 1, 1)),
        contractEnd: Value(DateTime(2025, 1, 1)),
        memo: const Value('월세 자주 밀림'),
      ),
    );

    // 202호: 공실
    await db.into(db.units).insert(
      UnitsCompanion.insert(
        buildingId: buildingId,
        roomNumber: '202',
        deposit: const Value(0),
        monthlyRent: const Value(550),
      ),
    );
    print("✅ 건물/유닛 데이터 생성 완료");
  } else {
    print("👉 건물 데이터가 이미 존재합니다.");
  }

  // --- 2. 카테고리 데이터 시딩 (새로 추가된 부분) ---
  final categoryCount = await db.select(db.categories).get();
  if (categoryCount.isEmpty) {
    print("📂 카테고리 데이터가 없어 생성을 시작합니다...");

    await db.batch((batch) {
      batch.insertAll(db.categories, [
        // 수입 항목
        CategoriesCompanion.insert(name: '임대료 수입', type: 'INCOME'),
        CategoriesCompanion.insert(name: '기타 수입', type: 'INCOME'),

        // 지출 항목
        CategoriesCompanion.insert(name: '수리보수비', type: 'EXPENSE'),
        CategoriesCompanion.insert(name: '관리비', type: 'EXPENSE'),
        CategoriesCompanion.insert(name: '전기/수도료', type: 'EXPENSE'),
        CategoriesCompanion.insert(name: '청소비', type: 'EXPENSE'),
        CategoriesCompanion.insert(name: '보험료', type: 'EXPENSE'),
        CategoriesCompanion.insert(name: '세금/공과금', type: 'EXPENSE'),
      ]);
    });
    print("✅ 카테고리 초기 데이터 생성 완료");
  } else {
    print("👉 카테고리 데이터가 이미 존재합니다.");
  }

  print("✅ 모든 초기 데이터 프로세스 완료!");
}