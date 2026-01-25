// lib/core/database/data_seeder.dart

import 'package:drift/drift.dart';
import 'app_database.dart';

Future<void> seedDatabase(AppDatabase db) async {
  print("🚀 데이터 확인 및 초기화를 시작합니다...");

  // --- 1. 건물 데이터 확인 ---
  final buildingCount = await db.select(db.buildings).get();
  if (buildingCount.isEmpty) {
    print("🏢 등록된 건물 데이터가 없습니다.");
  }

  // --- 2. 카테고리 데이터 시딩 (번역 키와 100% 일치시킴) ---
  final categoryCount = await db.select(db.categories).get();
  if (categoryCount.isEmpty) {
    print("📂 필수 시스템 카테고리 생성을 시작합니다...");

    await db.batch((batch) {
      batch.insertAll(db.categories, [
        // 📍 수입 항목 (INC) - 2개
        CategoriesCompanion.insert(name: 'CAT_RENT_INCOME', type: 'INC'),
        CategoriesCompanion.insert(name: 'CAT_OTHER_INCOME', type: 'INC'),

        // 📍 지출 항목 (EXP) - 6개
        CategoriesCompanion.insert(name: 'CAT_MAINTENANCE', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_MANAGEMENT_FEE', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_UTILITIES', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_CLEANING_FEE', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_INSURANCE', type: 'EXP'),
        CategoriesCompanion.insert(name: 'CAT_TAX_BILL', type: 'EXP'),
      ]);
    });
    print("✅ 카테고리 초기 데이터(시스템 키) 생성 완료");
  } else {
    print("👉 카테고리 데이터가 이미 존재합니다.");
  }

  print("✅ 모든 초기 데이터 프로세스 완료!");
}