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
    return (db.select(db.categories)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  // 📍 카테고리 추가 (INC/EXP 표준 코드 강제 적용)
  Future<void> addCategory(String name, String type) async {
    final db = ref.read(databaseProvider);

    // 혹시 'INCOME'이 들어와도 'INC'로 변환하여 저장
    final normalizedType = (type == 'INCOME' || type == 'INC') ? 'INC' : 'EXP';

    await db.into(db.categories).insert(
      CategoriesCompanion.insert(
          name: name,
          type: normalizedType
      ),
    );
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(int id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
    ref.invalidateSelf();
  }
}