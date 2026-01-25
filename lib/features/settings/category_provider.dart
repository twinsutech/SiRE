import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'package:drift/drift.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final db = ref.watch(databaseProvider);
    // 📍 카테고리 목록 조회 (ID 순으로 정렬)
    return (db.select(db.categories)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  // 📍 카테고리 추가 (INC/EXP 표준 코드 강제 적용)
  Future<void> addCategory(String name, String type) async {
    final db = ref.read(databaseProvider);

    // 혹시 'INCOME'이 들어와도 'INC'로 변환하여 저장
    // 📍 다국어와 상관없이 DB 내부 타입 코드는 'INC' / 'EXP'로 고정 관리합니다.
    final normalizedType = (type == 'INCOME' || type == 'INC') ? 'INC' : 'EXP';

    await db.into(db.categories).insert(
      CategoriesCompanion.insert(
          name: name,
          type: normalizedType
      ),
    );
    ref.invalidateSelf();
  }

  // 📍 카테고리 삭제
  Future<void> deleteCategory(int id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
    ref.invalidateSelf();
  }
}