import 'package:drift/drift.dart';
import 'app_database.dart';

// 초기 데이터를 넣는 함수
Future<void> seedDatabase(AppDatabase db) async {
  print("🚀 데이터 확인 및 초기화를 시작합니다...");

  // --- 1. 건물 및 유닛 데이터 시딩 (배포 시 삭제) ---
  final buildingCount = await db.select(db.buildings).get();
  if (buildingCount.isEmpty) {
    // 📍 배포용 클린업: 실제 사용자가 자신의 건물을 직접 등록할 수 있도록
    // 기존의 Villa Sunrise 등 테스트 데이터 생성 로직을 제거했습니다.
    print("🏢 등록된 건물 데이터가 없습니다. (새 사용자 상태)");
  } else {
    print("👉 건물 데이터가 이미 존재합니다.");
  }

  // --- 2. 카테고리 데이터 시딩 ---
  final categoryCount = await db.select(db.categories).get();
  if (categoryCount.isEmpty) {
    print("📂 카테고리 데이터가 없어 필수 시스템 항목 생성을 시작합니다...");

    // 📍 다국어 대응을 위해 카테고리 이름을 시스템 키(Key) 형태로 저장합니다.
    // UI에서 이 키를 감지하여 사용자의 언어로 번역해 보여줍니다.
    await db.batch((batch) {
      batch.insertAll(db.categories, [
        // 수입 항목 (INC)
        CategoriesCompanion.insert(name: 'CAT_RENT', type: 'INC'),
        CategoriesCompanion.insert(name: 'CAT_OTHER_INCOME', type: 'INC'),

        // 지출 항목 (EXP)
        CategoriesCompanion.insert(name: 'CAT_REPAIR', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_MAINTENANCE', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_UTILITY', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_CLEANING', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_INSURANCE', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_TAX', type: 'EXP'),
      ]);
    });
    print("✅ 카테고리 초기 데이터(시스템 키) 생성 완료");
  } else {
    print("👉 카테고리 데이터가 이미 존재합니다.");
  }

  print("✅ 모든 초기 데이터 프로세스 완료!");
}