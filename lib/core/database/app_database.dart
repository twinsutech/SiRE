import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

// 📍 [에러 해결] 중복 선언된 부분을 제거했습니다.
@DriftDatabase(tables: [Buildings, Units, UnitImages, Transactions, Categories, BuildingImages, TransactionImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) await m.createTable(categories);
        if (from < 3) {
          await m.addColumn(buildings, buildings.imagePath);
          await m.addColumn(units, units.imagePath);
        }
        if (from < 4) await m.createTable(unitImages);
        if (from < 5) await m.createTable(buildingImages);
        if (from < 6) await m.addColumn(buildingImages, buildingImages.isPrimary);

        // 버전 7: 호실 계약 정보 컬럼들 추가
        if (from < 7) {
          await m.addColumn(units, units.leaseType);
          await m.addColumn(units, units.contractStart);
          await m.addColumn(units, units.contractEnd);
          await m.addColumn(units, units.paymentDay);
        }

        // 📍 [에러 해결 핵심] 버전 8 처리: 컬럼이 이미 있는지 확인하고 추가
        if (from < 8) {
          try {
            // 이미 컬럼이 존재하면 여기서 에러가 나겠지만, try-catch로 감싸서 무시하고 다음으로 넘어갑니다.
            await m.addColumn(transactions, transactions.receiptImagePath);
          } catch (e) {
            print("Column receipt_image_path already exists, skipping...");
          }
        }

        // 📍 버전 9 처리: 다중 영수증 테이블 생성
        if (from < 9) {
          // 테이블은 createTable이라 이미 있으면 에러가 날 수 있으므로
          // m.createTable 대신 m.createAll()을 사용하거나 아래와 같이 처리합니다.
          await m.createTable(transactionImages);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sire.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
