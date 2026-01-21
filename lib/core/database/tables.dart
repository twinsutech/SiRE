import 'package:drift/drift.dart';

// 1. 건물 테이블
class Buildings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get address => text().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  TextColumn get imagePath => text().nullable()(); // 빌딩 대표 사진
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. 세대 테이블 (계약 정보 고도화)
class Units extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get buildingId => integer().references(Buildings, #id, onDelete: KeyAction.cascade)();
  TextColumn get roomNumber => text()();

  // --- [신규 추가/확장된 계약 정보] ---
  // 계약 유형: '월세', '전세', '반전세', '공실', '단기임대' 등
  TextColumn get leaseType => text().nullable()();

  // 세입자 정보
  TextColumn get tenantName => text().nullable()();
  TextColumn get tenantPhone => text().nullable()();

  // 금액 정보
  IntColumn get deposit => integer().withDefault(const Constant(0))(); // 보증금
  IntColumn get monthlyRent => integer().withDefault(const Constant(0))(); // 월세

  // 기간 및 납부일
  DateTimeColumn get contractStart => dateTime().nullable()(); // 계약 시작일
  DateTimeColumn get contractEnd => dateTime().nullable()();   // 계약 종료일
  IntColumn get paymentDay => integer().nullable()();           // 월세 납부일 (매달 n일)

  TextColumn get imagePath => text().nullable()(); // 호실 대표 사진
  TextColumn get memo => text().nullable()();
}

// 3. 호실별 다중 사진 테이블
class UnitImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get unitId => integer().references(Units, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 4. 빌딩별 다중 사진 테이블
class BuildingImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get buildingId => integer().references(Buildings, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 5. 장부 테이블
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get buildingId => integer().references(Buildings, #id, onDelete: KeyAction.cascade)();
  IntColumn get unitId => integer().nullable().references(Units, #id, onDelete: KeyAction.setNull)();

  TextColumn get type => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get category => text()();
  TextColumn get memo => text().nullable()();

  // 📍 기존 기능을 해치지 않고 이 필드만 추가합니다.
  TextColumn get receiptImagePath => text().nullable()();
}

// 📍 영수증 다중 이미지를 위한 테이블 추가
class TransactionImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 6. 카테고리 테이블
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  TextColumn get type => text()();
}