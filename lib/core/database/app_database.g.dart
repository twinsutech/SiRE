// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BuildingsTable extends Buildings
    with TableInfo<$BuildingsTable, Building> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, address, purchasePrice, imagePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buildings';
  @override
  VerificationContext validateIntegrity(Insertable<Building> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Building map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Building(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BuildingsTable createAlias(String alias) {
    return $BuildingsTable(attachedDatabase, alias);
  }
}

class Building extends DataClass implements Insertable<Building> {
  final int id;
  final String name;
  final String? address;
  final double? purchasePrice;
  final String? imagePath;
  final DateTime createdAt;
  const Building(
      {required this.id,
      required this.name,
      this.address,
      this.purchasePrice,
      this.imagePath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BuildingsCompanion toCompanion(bool nullToAbsent) {
    return BuildingsCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      createdAt: Value(createdAt),
    );
  }

  factory Building.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Building(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'imagePath': serializer.toJson<String?>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Building copyWith(
          {int? id,
          String? name,
          Value<String?> address = const Value.absent(),
          Value<double?> purchasePrice = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          DateTime? createdAt}) =>
      Building(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address.present ? address.value : this.address,
        purchasePrice:
            purchasePrice.present ? purchasePrice.value : this.purchasePrice,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        createdAt: createdAt ?? this.createdAt,
      );
  Building copyWithCompanion(BuildingsCompanion data) {
    return Building(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Building(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, purchasePrice, imagePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Building &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.purchasePrice == this.purchasePrice &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<double?> purchasePrice;
  final Value<String?> imagePath;
  final Value<DateTime> createdAt;
  const BuildingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BuildingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Building> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<double>? purchasePrice,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BuildingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? address,
      Value<double?>? purchasePrice,
      Value<String?>? imagePath,
      Value<DateTime>? createdAt}) {
    return BuildingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _buildingIdMeta =
      const VerificationMeta('buildingId');
  @override
  late final GeneratedColumn<int> buildingId = GeneratedColumn<int>(
      'building_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES buildings (id) ON DELETE CASCADE'));
  static const VerificationMeta _roomNumberMeta =
      const VerificationMeta('roomNumber');
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
      'room_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _leaseTypeMeta =
      const VerificationMeta('leaseType');
  @override
  late final GeneratedColumn<String> leaseType = GeneratedColumn<String>(
      'lease_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantNameMeta =
      const VerificationMeta('tenantName');
  @override
  late final GeneratedColumn<String> tenantName = GeneratedColumn<String>(
      'tenant_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tenantPhoneMeta =
      const VerificationMeta('tenantPhone');
  @override
  late final GeneratedColumn<String> tenantPhone = GeneratedColumn<String>(
      'tenant_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _depositMeta =
      const VerificationMeta('deposit');
  @override
  late final GeneratedColumn<int> deposit = GeneratedColumn<int>(
      'deposit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _monthlyRentMeta =
      const VerificationMeta('monthlyRent');
  @override
  late final GeneratedColumn<int> monthlyRent = GeneratedColumn<int>(
      'monthly_rent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _contractStartMeta =
      const VerificationMeta('contractStart');
  @override
  late final GeneratedColumn<DateTime> contractStart =
      GeneratedColumn<DateTime>('contract_start', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _contractEndMeta =
      const VerificationMeta('contractEnd');
  @override
  late final GeneratedColumn<DateTime> contractEnd = GeneratedColumn<DateTime>(
      'contract_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _paymentDayMeta =
      const VerificationMeta('paymentDay');
  @override
  late final GeneratedColumn<int> paymentDay = GeneratedColumn<int>(
      'payment_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        buildingId,
        roomNumber,
        leaseType,
        tenantName,
        tenantPhone,
        deposit,
        monthlyRent,
        contractStart,
        contractEnd,
        paymentDay,
        imagePath,
        memo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(Insertable<Unit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
          _buildingIdMeta,
          buildingId.isAcceptableOrUnknown(
              data['building_id']!, _buildingIdMeta));
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('room_number')) {
      context.handle(
          _roomNumberMeta,
          roomNumber.isAcceptableOrUnknown(
              data['room_number']!, _roomNumberMeta));
    } else if (isInserting) {
      context.missing(_roomNumberMeta);
    }
    if (data.containsKey('lease_type')) {
      context.handle(_leaseTypeMeta,
          leaseType.isAcceptableOrUnknown(data['lease_type']!, _leaseTypeMeta));
    }
    if (data.containsKey('tenant_name')) {
      context.handle(
          _tenantNameMeta,
          tenantName.isAcceptableOrUnknown(
              data['tenant_name']!, _tenantNameMeta));
    }
    if (data.containsKey('tenant_phone')) {
      context.handle(
          _tenantPhoneMeta,
          tenantPhone.isAcceptableOrUnknown(
              data['tenant_phone']!, _tenantPhoneMeta));
    }
    if (data.containsKey('deposit')) {
      context.handle(_depositMeta,
          deposit.isAcceptableOrUnknown(data['deposit']!, _depositMeta));
    }
    if (data.containsKey('monthly_rent')) {
      context.handle(
          _monthlyRentMeta,
          monthlyRent.isAcceptableOrUnknown(
              data['monthly_rent']!, _monthlyRentMeta));
    }
    if (data.containsKey('contract_start')) {
      context.handle(
          _contractStartMeta,
          contractStart.isAcceptableOrUnknown(
              data['contract_start']!, _contractStartMeta));
    }
    if (data.containsKey('contract_end')) {
      context.handle(
          _contractEndMeta,
          contractEnd.isAcceptableOrUnknown(
              data['contract_end']!, _contractEndMeta));
    }
    if (data.containsKey('payment_day')) {
      context.handle(
          _paymentDayMeta,
          paymentDay.isAcceptableOrUnknown(
              data['payment_day']!, _paymentDayMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      buildingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}building_id'])!,
      roomNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_number'])!,
      leaseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lease_type']),
      tenantName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_name']),
      tenantPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_phone']),
      deposit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deposit'])!,
      monthlyRent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monthly_rent'])!,
      contractStart: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}contract_start']),
      contractEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}contract_end']),
      paymentDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_day']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final int id;
  final int buildingId;
  final String roomNumber;
  final String? leaseType;
  final String? tenantName;
  final String? tenantPhone;
  final int deposit;
  final int monthlyRent;
  final DateTime? contractStart;
  final DateTime? contractEnd;
  final int? paymentDay;
  final String? imagePath;
  final String? memo;
  const Unit(
      {required this.id,
      required this.buildingId,
      required this.roomNumber,
      this.leaseType,
      this.tenantName,
      this.tenantPhone,
      required this.deposit,
      required this.monthlyRent,
      this.contractStart,
      this.contractEnd,
      this.paymentDay,
      this.imagePath,
      this.memo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['building_id'] = Variable<int>(buildingId);
    map['room_number'] = Variable<String>(roomNumber);
    if (!nullToAbsent || leaseType != null) {
      map['lease_type'] = Variable<String>(leaseType);
    }
    if (!nullToAbsent || tenantName != null) {
      map['tenant_name'] = Variable<String>(tenantName);
    }
    if (!nullToAbsent || tenantPhone != null) {
      map['tenant_phone'] = Variable<String>(tenantPhone);
    }
    map['deposit'] = Variable<int>(deposit);
    map['monthly_rent'] = Variable<int>(monthlyRent);
    if (!nullToAbsent || contractStart != null) {
      map['contract_start'] = Variable<DateTime>(contractStart);
    }
    if (!nullToAbsent || contractEnd != null) {
      map['contract_end'] = Variable<DateTime>(contractEnd);
    }
    if (!nullToAbsent || paymentDay != null) {
      map['payment_day'] = Variable<int>(paymentDay);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      buildingId: Value(buildingId),
      roomNumber: Value(roomNumber),
      leaseType: leaseType == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseType),
      tenantName: tenantName == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantName),
      tenantPhone: tenantPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantPhone),
      deposit: Value(deposit),
      monthlyRent: Value(monthlyRent),
      contractStart: contractStart == null && nullToAbsent
          ? const Value.absent()
          : Value(contractStart),
      contractEnd: contractEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(contractEnd),
      paymentDay: paymentDay == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDay),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      id: serializer.fromJson<int>(json['id']),
      buildingId: serializer.fromJson<int>(json['buildingId']),
      roomNumber: serializer.fromJson<String>(json['roomNumber']),
      leaseType: serializer.fromJson<String?>(json['leaseType']),
      tenantName: serializer.fromJson<String?>(json['tenantName']),
      tenantPhone: serializer.fromJson<String?>(json['tenantPhone']),
      deposit: serializer.fromJson<int>(json['deposit']),
      monthlyRent: serializer.fromJson<int>(json['monthlyRent']),
      contractStart: serializer.fromJson<DateTime?>(json['contractStart']),
      contractEnd: serializer.fromJson<DateTime?>(json['contractEnd']),
      paymentDay: serializer.fromJson<int?>(json['paymentDay']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'buildingId': serializer.toJson<int>(buildingId),
      'roomNumber': serializer.toJson<String>(roomNumber),
      'leaseType': serializer.toJson<String?>(leaseType),
      'tenantName': serializer.toJson<String?>(tenantName),
      'tenantPhone': serializer.toJson<String?>(tenantPhone),
      'deposit': serializer.toJson<int>(deposit),
      'monthlyRent': serializer.toJson<int>(monthlyRent),
      'contractStart': serializer.toJson<DateTime?>(contractStart),
      'contractEnd': serializer.toJson<DateTime?>(contractEnd),
      'paymentDay': serializer.toJson<int?>(paymentDay),
      'imagePath': serializer.toJson<String?>(imagePath),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  Unit copyWith(
          {int? id,
          int? buildingId,
          String? roomNumber,
          Value<String?> leaseType = const Value.absent(),
          Value<String?> tenantName = const Value.absent(),
          Value<String?> tenantPhone = const Value.absent(),
          int? deposit,
          int? monthlyRent,
          Value<DateTime?> contractStart = const Value.absent(),
          Value<DateTime?> contractEnd = const Value.absent(),
          Value<int?> paymentDay = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> memo = const Value.absent()}) =>
      Unit(
        id: id ?? this.id,
        buildingId: buildingId ?? this.buildingId,
        roomNumber: roomNumber ?? this.roomNumber,
        leaseType: leaseType.present ? leaseType.value : this.leaseType,
        tenantName: tenantName.present ? tenantName.value : this.tenantName,
        tenantPhone: tenantPhone.present ? tenantPhone.value : this.tenantPhone,
        deposit: deposit ?? this.deposit,
        monthlyRent: monthlyRent ?? this.monthlyRent,
        contractStart:
            contractStart.present ? contractStart.value : this.contractStart,
        contractEnd: contractEnd.present ? contractEnd.value : this.contractEnd,
        paymentDay: paymentDay.present ? paymentDay.value : this.paymentDay,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        memo: memo.present ? memo.value : this.memo,
      );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      id: data.id.present ? data.id.value : this.id,
      buildingId:
          data.buildingId.present ? data.buildingId.value : this.buildingId,
      roomNumber:
          data.roomNumber.present ? data.roomNumber.value : this.roomNumber,
      leaseType: data.leaseType.present ? data.leaseType.value : this.leaseType,
      tenantName:
          data.tenantName.present ? data.tenantName.value : this.tenantName,
      tenantPhone:
          data.tenantPhone.present ? data.tenantPhone.value : this.tenantPhone,
      deposit: data.deposit.present ? data.deposit.value : this.deposit,
      monthlyRent:
          data.monthlyRent.present ? data.monthlyRent.value : this.monthlyRent,
      contractStart: data.contractStart.present
          ? data.contractStart.value
          : this.contractStart,
      contractEnd:
          data.contractEnd.present ? data.contractEnd.value : this.contractEnd,
      paymentDay:
          data.paymentDay.present ? data.paymentDay.value : this.paymentDay,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('leaseType: $leaseType, ')
          ..write('tenantName: $tenantName, ')
          ..write('tenantPhone: $tenantPhone, ')
          ..write('deposit: $deposit, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('contractStart: $contractStart, ')
          ..write('contractEnd: $contractEnd, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('imagePath: $imagePath, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      buildingId,
      roomNumber,
      leaseType,
      tenantName,
      tenantPhone,
      deposit,
      monthlyRent,
      contractStart,
      contractEnd,
      paymentDay,
      imagePath,
      memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.roomNumber == this.roomNumber &&
          other.leaseType == this.leaseType &&
          other.tenantName == this.tenantName &&
          other.tenantPhone == this.tenantPhone &&
          other.deposit == this.deposit &&
          other.monthlyRent == this.monthlyRent &&
          other.contractStart == this.contractStart &&
          other.contractEnd == this.contractEnd &&
          other.paymentDay == this.paymentDay &&
          other.imagePath == this.imagePath &&
          other.memo == this.memo);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<int> id;
  final Value<int> buildingId;
  final Value<String> roomNumber;
  final Value<String?> leaseType;
  final Value<String?> tenantName;
  final Value<String?> tenantPhone;
  final Value<int> deposit;
  final Value<int> monthlyRent;
  final Value<DateTime?> contractStart;
  final Value<DateTime?> contractEnd;
  final Value<int?> paymentDay;
  final Value<String?> imagePath;
  final Value<String?> memo;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.leaseType = const Value.absent(),
    this.tenantName = const Value.absent(),
    this.tenantPhone = const Value.absent(),
    this.deposit = const Value.absent(),
    this.monthlyRent = const Value.absent(),
    this.contractStart = const Value.absent(),
    this.contractEnd = const Value.absent(),
    this.paymentDay = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.memo = const Value.absent(),
  });
  UnitsCompanion.insert({
    this.id = const Value.absent(),
    required int buildingId,
    required String roomNumber,
    this.leaseType = const Value.absent(),
    this.tenantName = const Value.absent(),
    this.tenantPhone = const Value.absent(),
    this.deposit = const Value.absent(),
    this.monthlyRent = const Value.absent(),
    this.contractStart = const Value.absent(),
    this.contractEnd = const Value.absent(),
    this.paymentDay = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.memo = const Value.absent(),
  })  : buildingId = Value(buildingId),
        roomNumber = Value(roomNumber);
  static Insertable<Unit> custom({
    Expression<int>? id,
    Expression<int>? buildingId,
    Expression<String>? roomNumber,
    Expression<String>? leaseType,
    Expression<String>? tenantName,
    Expression<String>? tenantPhone,
    Expression<int>? deposit,
    Expression<int>? monthlyRent,
    Expression<DateTime>? contractStart,
    Expression<DateTime>? contractEnd,
    Expression<int>? paymentDay,
    Expression<String>? imagePath,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (roomNumber != null) 'room_number': roomNumber,
      if (leaseType != null) 'lease_type': leaseType,
      if (tenantName != null) 'tenant_name': tenantName,
      if (tenantPhone != null) 'tenant_phone': tenantPhone,
      if (deposit != null) 'deposit': deposit,
      if (monthlyRent != null) 'monthly_rent': monthlyRent,
      if (contractStart != null) 'contract_start': contractStart,
      if (contractEnd != null) 'contract_end': contractEnd,
      if (paymentDay != null) 'payment_day': paymentDay,
      if (imagePath != null) 'image_path': imagePath,
      if (memo != null) 'memo': memo,
    });
  }

  UnitsCompanion copyWith(
      {Value<int>? id,
      Value<int>? buildingId,
      Value<String>? roomNumber,
      Value<String?>? leaseType,
      Value<String?>? tenantName,
      Value<String?>? tenantPhone,
      Value<int>? deposit,
      Value<int>? monthlyRent,
      Value<DateTime?>? contractStart,
      Value<DateTime?>? contractEnd,
      Value<int?>? paymentDay,
      Value<String?>? imagePath,
      Value<String?>? memo}) {
    return UnitsCompanion(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      roomNumber: roomNumber ?? this.roomNumber,
      leaseType: leaseType ?? this.leaseType,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      deposit: deposit ?? this.deposit,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      contractStart: contractStart ?? this.contractStart,
      contractEnd: contractEnd ?? this.contractEnd,
      paymentDay: paymentDay ?? this.paymentDay,
      imagePath: imagePath ?? this.imagePath,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<int>(buildingId.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (leaseType.present) {
      map['lease_type'] = Variable<String>(leaseType.value);
    }
    if (tenantName.present) {
      map['tenant_name'] = Variable<String>(tenantName.value);
    }
    if (tenantPhone.present) {
      map['tenant_phone'] = Variable<String>(tenantPhone.value);
    }
    if (deposit.present) {
      map['deposit'] = Variable<int>(deposit.value);
    }
    if (monthlyRent.present) {
      map['monthly_rent'] = Variable<int>(monthlyRent.value);
    }
    if (contractStart.present) {
      map['contract_start'] = Variable<DateTime>(contractStart.value);
    }
    if (contractEnd.present) {
      map['contract_end'] = Variable<DateTime>(contractEnd.value);
    }
    if (paymentDay.present) {
      map['payment_day'] = Variable<int>(paymentDay.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('leaseType: $leaseType, ')
          ..write('tenantName: $tenantName, ')
          ..write('tenantPhone: $tenantPhone, ')
          ..write('deposit: $deposit, ')
          ..write('monthlyRent: $monthlyRent, ')
          ..write('contractStart: $contractStart, ')
          ..write('contractEnd: $contractEnd, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('imagePath: $imagePath, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

class $UnitImagesTable extends UnitImages
    with TableInfo<$UnitImagesTable, UnitImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES units (id) ON DELETE CASCADE'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, unitId, imagePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_images';
  @override
  VerificationContext validateIntegrity(Insertable<UnitImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_id'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UnitImagesTable createAlias(String alias) {
    return $UnitImagesTable(attachedDatabase, alias);
  }
}

class UnitImage extends DataClass implements Insertable<UnitImage> {
  final int id;
  final int unitId;
  final String imagePath;
  final DateTime createdAt;
  const UnitImage(
      {required this.id,
      required this.unitId,
      required this.imagePath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unit_id'] = Variable<int>(unitId);
    map['image_path'] = Variable<String>(imagePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UnitImagesCompanion toCompanion(bool nullToAbsent) {
    return UnitImagesCompanion(
      id: Value(id),
      unitId: Value(unitId),
      imagePath: Value(imagePath),
      createdAt: Value(createdAt),
    );
  }

  factory UnitImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitImage(
      id: serializer.fromJson<int>(json['id']),
      unitId: serializer.fromJson<int>(json['unitId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unitId': serializer.toJson<int>(unitId),
      'imagePath': serializer.toJson<String>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UnitImage copyWith(
          {int? id, int? unitId, String? imagePath, DateTime? createdAt}) =>
      UnitImage(
        id: id ?? this.id,
        unitId: unitId ?? this.unitId,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
      );
  UnitImage copyWithCompanion(UnitImagesCompanion data) {
    return UnitImage(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitImage(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, unitId, imagePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitImage &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt);
}

class UnitImagesCompanion extends UpdateCompanion<UnitImage> {
  final Value<int> id;
  final Value<int> unitId;
  final Value<String> imagePath;
  final Value<DateTime> createdAt;
  const UnitImagesCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UnitImagesCompanion.insert({
    this.id = const Value.absent(),
    required int unitId,
    required String imagePath,
    this.createdAt = const Value.absent(),
  })  : unitId = Value(unitId),
        imagePath = Value(imagePath);
  static Insertable<UnitImage> custom({
    Expression<int>? id,
    Expression<int>? unitId,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UnitImagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? unitId,
      Value<String>? imagePath,
      Value<DateTime>? createdAt}) {
    return UnitImagesCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitImagesCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _buildingIdMeta =
      const VerificationMeta('buildingId');
  @override
  late final GeneratedColumn<int> buildingId = GeneratedColumn<int>(
      'building_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES buildings (id) ON DELETE CASCADE'));
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<int> unitId = GeneratedColumn<int>(
      'unit_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES units (id) ON DELETE SET NULL'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiptImagePathMeta =
      const VerificationMeta('receiptImagePath');
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
      'receipt_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        buildingId,
        unitId,
        type,
        amount,
        transactionDate,
        category,
        memo,
        receiptImagePath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
          _buildingIdMeta,
          buildingId.isAcceptableOrUnknown(
              data['building_id']!, _buildingIdMeta));
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('receipt_image_path')) {
      context.handle(
          _receiptImagePathMeta,
          receiptImagePath.isAcceptableOrUnknown(
              data['receipt_image_path']!, _receiptImagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      buildingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}building_id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      receiptImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receipt_image_path']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int buildingId;
  final int? unitId;
  final String type;
  final int amount;
  final DateTime transactionDate;
  final String category;
  final String? memo;
  final String? receiptImagePath;
  const Transaction(
      {required this.id,
      required this.buildingId,
      this.unitId,
      required this.type,
      required this.amount,
      required this.transactionDate,
      required this.category,
      this.memo,
      this.receiptImagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['building_id'] = Variable<int>(buildingId);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<int>(unitId);
    }
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      buildingId: Value(buildingId),
      unitId:
          unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
      type: Value(type),
      amount: Value(amount),
      transactionDate: Value(transactionDate),
      category: Value(category),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      buildingId: serializer.fromJson<int>(json['buildingId']),
      unitId: serializer.fromJson<int?>(json['unitId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      category: serializer.fromJson<String>(json['category']),
      memo: serializer.fromJson<String?>(json['memo']),
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'buildingId': serializer.toJson<int>(buildingId),
      'unitId': serializer.toJson<int?>(unitId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'category': serializer.toJson<String>(category),
      'memo': serializer.toJson<String?>(memo),
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
    };
  }

  Transaction copyWith(
          {int? id,
          int? buildingId,
          Value<int?> unitId = const Value.absent(),
          String? type,
          int? amount,
          DateTime? transactionDate,
          String? category,
          Value<String?> memo = const Value.absent(),
          Value<String?> receiptImagePath = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        buildingId: buildingId ?? this.buildingId,
        unitId: unitId.present ? unitId.value : this.unitId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        transactionDate: transactionDate ?? this.transactionDate,
        category: category ?? this.category,
        memo: memo.present ? memo.value : this.memo,
        receiptImagePath: receiptImagePath.present
            ? receiptImagePath.value
            : this.receiptImagePath,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      buildingId:
          data.buildingId.present ? data.buildingId.value : this.buildingId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      category: data.category.present ? data.category.value : this.category,
      memo: data.memo.present ? data.memo.value : this.memo,
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('unitId: $unitId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('category: $category, ')
          ..write('memo: $memo, ')
          ..write('receiptImagePath: $receiptImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, buildingId, unitId, type, amount,
      transactionDate, category, memo, receiptImagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.unitId == this.unitId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.transactionDate == this.transactionDate &&
          other.category == this.category &&
          other.memo == this.memo &&
          other.receiptImagePath == this.receiptImagePath);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> buildingId;
  final Value<int?> unitId;
  final Value<String> type;
  final Value<int> amount;
  final Value<DateTime> transactionDate;
  final Value<String> category;
  final Value<String?> memo;
  final Value<String?> receiptImagePath;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.category = const Value.absent(),
    this.memo = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int buildingId,
    this.unitId = const Value.absent(),
    required String type,
    required int amount,
    required DateTime transactionDate,
    required String category,
    this.memo = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
  })  : buildingId = Value(buildingId),
        type = Value(type),
        amount = Value(amount),
        transactionDate = Value(transactionDate),
        category = Value(category);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? buildingId,
    Expression<int>? unitId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<DateTime>? transactionDate,
    Expression<String>? category,
    Expression<String>? memo,
    Expression<String>? receiptImagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (unitId != null) 'unit_id': unitId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (category != null) 'category': category,
      if (memo != null) 'memo': memo,
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? buildingId,
      Value<int?>? unitId,
      Value<String>? type,
      Value<int>? amount,
      Value<DateTime>? transactionDate,
      Value<String>? category,
      Value<String?>? memo,
      Value<String?>? receiptImagePath}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<int>(buildingId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<int>(unitId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('unitId: $unitId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('category: $category, ')
          ..write('memo: $memo, ')
          ..write('receiptImagePath: $receiptImagePath')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;
  const Category({required this.id, required this.name, required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
    };
  }

  Category copyWith({int? id, String? name, String? type}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
  })  : name = Value(name),
        type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? type}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $BuildingImagesTable extends BuildingImages
    with TableInfo<$BuildingImagesTable, BuildingImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _buildingIdMeta =
      const VerificationMeta('buildingId');
  @override
  late final GeneratedColumn<int> buildingId = GeneratedColumn<int>(
      'building_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES buildings (id) ON DELETE CASCADE'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, buildingId, imagePath, isPrimary, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'building_images';
  @override
  VerificationContext validateIntegrity(Insertable<BuildingImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
          _buildingIdMeta,
          buildingId.isAcceptableOrUnknown(
              data['building_id']!, _buildingIdMeta));
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuildingImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuildingImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      buildingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}building_id'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BuildingImagesTable createAlias(String alias) {
    return $BuildingImagesTable(attachedDatabase, alias);
  }
}

class BuildingImage extends DataClass implements Insertable<BuildingImage> {
  final int id;
  final int buildingId;
  final String imagePath;
  final bool isPrimary;
  final DateTime createdAt;
  const BuildingImage(
      {required this.id,
      required this.buildingId,
      required this.imagePath,
      required this.isPrimary,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['building_id'] = Variable<int>(buildingId);
    map['image_path'] = Variable<String>(imagePath);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BuildingImagesCompanion toCompanion(bool nullToAbsent) {
    return BuildingImagesCompanion(
      id: Value(id),
      buildingId: Value(buildingId),
      imagePath: Value(imagePath),
      isPrimary: Value(isPrimary),
      createdAt: Value(createdAt),
    );
  }

  factory BuildingImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuildingImage(
      id: serializer.fromJson<int>(json['id']),
      buildingId: serializer.fromJson<int>(json['buildingId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'buildingId': serializer.toJson<int>(buildingId),
      'imagePath': serializer.toJson<String>(imagePath),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BuildingImage copyWith(
          {int? id,
          int? buildingId,
          String? imagePath,
          bool? isPrimary,
          DateTime? createdAt}) =>
      BuildingImage(
        id: id ?? this.id,
        buildingId: buildingId ?? this.buildingId,
        imagePath: imagePath ?? this.imagePath,
        isPrimary: isPrimary ?? this.isPrimary,
        createdAt: createdAt ?? this.createdAt,
      );
  BuildingImage copyWithCompanion(BuildingImagesCompanion data) {
    return BuildingImage(
      id: data.id.present ? data.id.value : this.id,
      buildingId:
          data.buildingId.present ? data.buildingId.value : this.buildingId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuildingImage(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('imagePath: $imagePath, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, buildingId, imagePath, isPrimary, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuildingImage &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.imagePath == this.imagePath &&
          other.isPrimary == this.isPrimary &&
          other.createdAt == this.createdAt);
}

class BuildingImagesCompanion extends UpdateCompanion<BuildingImage> {
  final Value<int> id;
  final Value<int> buildingId;
  final Value<String> imagePath;
  final Value<bool> isPrimary;
  final Value<DateTime> createdAt;
  const BuildingImagesCompanion({
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BuildingImagesCompanion.insert({
    this.id = const Value.absent(),
    required int buildingId,
    required String imagePath,
    this.isPrimary = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : buildingId = Value(buildingId),
        imagePath = Value(imagePath);
  static Insertable<BuildingImage> custom({
    Expression<int>? id,
    Expression<int>? buildingId,
    Expression<String>? imagePath,
    Expression<bool>? isPrimary,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (imagePath != null) 'image_path': imagePath,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BuildingImagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? buildingId,
      Value<String>? imagePath,
      Value<bool>? isPrimary,
      Value<DateTime>? createdAt}) {
    return BuildingImagesCompanion(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      imagePath: imagePath ?? this.imagePath,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<int>(buildingId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingImagesCompanion(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('imagePath: $imagePath, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionImagesTable extends TransactionImages
    with TableInfo<$TransactionImagesTable, TransactionImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE CASCADE'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, transactionId, imagePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_images';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionImagesTable createAlias(String alias) {
    return $TransactionImagesTable(attachedDatabase, alias);
  }
}

class TransactionImage extends DataClass
    implements Insertable<TransactionImage> {
  final int id;
  final int transactionId;
  final String imagePath;
  final DateTime createdAt;
  const TransactionImage(
      {required this.id,
      required this.transactionId,
      required this.imagePath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['image_path'] = Variable<String>(imagePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionImagesCompanion toCompanion(bool nullToAbsent) {
    return TransactionImagesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      imagePath: Value(imagePath),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionImage(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'imagePath': serializer.toJson<String>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionImage copyWith(
          {int? id,
          int? transactionId,
          String? imagePath,
          DateTime? createdAt}) =>
      TransactionImage(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
      );
  TransactionImage copyWithCompanion(TransactionImagesCompanion data) {
    return TransactionImage(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionImage(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, imagePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionImage &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt);
}

class TransactionImagesCompanion extends UpdateCompanion<TransactionImage> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<String> imagePath;
  final Value<DateTime> createdAt;
  const TransactionImagesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionImagesCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required String imagePath,
    this.createdAt = const Value.absent(),
  })  : transactionId = Value(transactionId),
        imagePath = Value(imagePath);
  static Insertable<TransactionImage> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionImagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<String>? imagePath,
      Value<DateTime>? createdAt}) {
    return TransactionImagesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionImagesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $UnitImagesTable unitImages = $UnitImagesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $BuildingImagesTable buildingImages = $BuildingImagesTable(this);
  late final $TransactionImagesTable transactionImages =
      $TransactionImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        buildings,
        units,
        unitImages,
        transactions,
        categories,
        buildingImages,
        transactionImages
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('buildings',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('units', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('units',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('unit_images', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('buildings',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('units',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('buildings',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('building_images', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transaction_images', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$BuildingsTableCreateCompanionBuilder = BuildingsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> address,
  Value<double?> purchasePrice,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
});
typedef $$BuildingsTableUpdateCompanionBuilder = BuildingsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> address,
  Value<double?> purchasePrice,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
});

final class $$BuildingsTableReferences
    extends BaseReferences<_$AppDatabase, $BuildingsTable, Building> {
  $$BuildingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UnitsTable, List<Unit>> _unitsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.units,
          aliasName:
              $_aliasNameGenerator(db.buildings.id, db.units.buildingId));

  $$UnitsTableProcessedTableManager get unitsRefs {
    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.buildingId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_unitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.buildings.id, db.transactions.buildingId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.buildingId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BuildingImagesTable, List<BuildingImage>>
      _buildingImagesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.buildingImages,
              aliasName: $_aliasNameGenerator(
                  db.buildings.id, db.buildingImages.buildingId));

  $$BuildingImagesTableProcessedTableManager get buildingImagesRefs {
    final manager = $$BuildingImagesTableTableManager($_db, $_db.buildingImages)
        .filter((f) => f.buildingId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_buildingImagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BuildingsTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> unitsRefs(
      Expression<bool> Function($$UnitsTableFilterComposer f) f) {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> buildingImagesRefs(
      Expression<bool> Function($$BuildingImagesTableFilterComposer f) f) {
    final $$BuildingImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.buildingImages,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingImagesTableFilterComposer(
              $db: $db,
              $table: $db.buildingImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BuildingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BuildingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> unitsRefs<T extends Object>(
      Expression<T> Function($$UnitsTableAnnotationComposer a) f) {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> buildingImagesRefs<T extends Object>(
      Expression<T> Function($$BuildingImagesTableAnnotationComposer a) f) {
    final $$BuildingImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.buildingImages,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.buildingImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BuildingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BuildingsTable,
    Building,
    $$BuildingsTableFilterComposer,
    $$BuildingsTableOrderingComposer,
    $$BuildingsTableAnnotationComposer,
    $$BuildingsTableCreateCompanionBuilder,
    $$BuildingsTableUpdateCompanionBuilder,
    (Building, $$BuildingsTableReferences),
    Building,
    PrefetchHooks Function(
        {bool unitsRefs, bool transactionsRefs, bool buildingImagesRefs})> {
  $$BuildingsTableTableManager(_$AppDatabase db, $BuildingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<double?> purchasePrice = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BuildingsCompanion(
            id: id,
            name: name,
            address: address,
            purchasePrice: purchasePrice,
            imagePath: imagePath,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> address = const Value.absent(),
            Value<double?> purchasePrice = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BuildingsCompanion.insert(
            id: id,
            name: name,
            address: address,
            purchasePrice: purchasePrice,
            imagePath: imagePath,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BuildingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {unitsRefs = false,
              transactionsRefs = false,
              buildingImagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (unitsRefs) db.units,
                if (transactionsRefs) db.transactions,
                if (buildingImagesRefs) db.buildingImages
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (unitsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$BuildingsTableReferences._unitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BuildingsTableReferences(db, table, p0).unitsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.buildingId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$BuildingsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BuildingsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.buildingId == item.id),
                        typedResults: items),
                  if (buildingImagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$BuildingsTableReferences
                            ._buildingImagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BuildingsTableReferences(db, table, p0)
                                .buildingImagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.buildingId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BuildingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BuildingsTable,
    Building,
    $$BuildingsTableFilterComposer,
    $$BuildingsTableOrderingComposer,
    $$BuildingsTableAnnotationComposer,
    $$BuildingsTableCreateCompanionBuilder,
    $$BuildingsTableUpdateCompanionBuilder,
    (Building, $$BuildingsTableReferences),
    Building,
    PrefetchHooks Function(
        {bool unitsRefs, bool transactionsRefs, bool buildingImagesRefs})>;
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  Value<int> id,
  required int buildingId,
  required String roomNumber,
  Value<String?> leaseType,
  Value<String?> tenantName,
  Value<String?> tenantPhone,
  Value<int> deposit,
  Value<int> monthlyRent,
  Value<DateTime?> contractStart,
  Value<DateTime?> contractEnd,
  Value<int?> paymentDay,
  Value<String?> imagePath,
  Value<String?> memo,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<int> id,
  Value<int> buildingId,
  Value<String> roomNumber,
  Value<String?> leaseType,
  Value<String?> tenantName,
  Value<String?> tenantPhone,
  Value<int> deposit,
  Value<int> monthlyRent,
  Value<DateTime?> contractStart,
  Value<DateTime?> contractEnd,
  Value<int?> paymentDay,
  Value<String?> imagePath,
  Value<String?> memo,
});

final class $$UnitsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitsTable, Unit> {
  $$UnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) => db.buildings
      .createAlias($_aliasNameGenerator(db.units.buildingId, db.buildings.id));

  $$BuildingsTableProcessedTableManager? get buildingId {
    if ($_item.buildingId == null) return null;
    final manager = $$BuildingsTableTableManager($_db, $_db.buildings)
        .filter((f) => f.id($_item.buildingId!));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$UnitImagesTable, List<UnitImage>>
      _unitImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.unitImages,
          aliasName: $_aliasNameGenerator(db.units.id, db.unitImages.unitId));

  $$UnitImagesTableProcessedTableManager get unitImagesRefs {
    final manager = $$UnitImagesTableTableManager($_db, $_db.unitImages)
        .filter((f) => f.unitId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_unitImagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.transactions,
          aliasName: $_aliasNameGenerator(db.units.id, db.transactions.unitId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.unitId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomNumber => $composableBuilder(
      column: $table.roomNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leaseType => $composableBuilder(
      column: $table.leaseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deposit => $composableBuilder(
      column: $table.deposit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractStart => $composableBuilder(
      column: $table.contractStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractEnd => $composableBuilder(
      column: $table.contractEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paymentDay => $composableBuilder(
      column: $table.paymentDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableFilterComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> unitImagesRefs(
      Expression<bool> Function($$UnitImagesTableFilterComposer f) f) {
    final $$UnitImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.unitImages,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitImagesTableFilterComposer(
              $db: $db,
              $table: $db.unitImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomNumber => $composableBuilder(
      column: $table.roomNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leaseType => $composableBuilder(
      column: $table.leaseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deposit => $composableBuilder(
      column: $table.deposit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractStart => $composableBuilder(
      column: $table.contractStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractEnd => $composableBuilder(
      column: $table.contractEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentDay => $composableBuilder(
      column: $table.paymentDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableOrderingComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomNumber => $composableBuilder(
      column: $table.roomNumber, builder: (column) => column);

  GeneratedColumn<String> get leaseType =>
      $composableBuilder(column: $table.leaseType, builder: (column) => column);

  GeneratedColumn<String> get tenantName => $composableBuilder(
      column: $table.tenantName, builder: (column) => column);

  GeneratedColumn<String> get tenantPhone => $composableBuilder(
      column: $table.tenantPhone, builder: (column) => column);

  GeneratedColumn<int> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => column);

  GeneratedColumn<int> get monthlyRent => $composableBuilder(
      column: $table.monthlyRent, builder: (column) => column);

  GeneratedColumn<DateTime> get contractStart => $composableBuilder(
      column: $table.contractStart, builder: (column) => column);

  GeneratedColumn<DateTime> get contractEnd => $composableBuilder(
      column: $table.contractEnd, builder: (column) => column);

  GeneratedColumn<int> get paymentDay => $composableBuilder(
      column: $table.paymentDay, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableAnnotationComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> unitImagesRefs<T extends Object>(
      Expression<T> Function($$UnitImagesTableAnnotationComposer a) f) {
    final $$UnitImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.unitImages,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.unitImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, $$UnitsTableReferences),
    Unit,
    PrefetchHooks Function(
        {bool buildingId, bool unitImagesRefs, bool transactionsRefs})> {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> buildingId = const Value.absent(),
            Value<String> roomNumber = const Value.absent(),
            Value<String?> leaseType = const Value.absent(),
            Value<String?> tenantName = const Value.absent(),
            Value<String?> tenantPhone = const Value.absent(),
            Value<int> deposit = const Value.absent(),
            Value<int> monthlyRent = const Value.absent(),
            Value<DateTime?> contractStart = const Value.absent(),
            Value<DateTime?> contractEnd = const Value.absent(),
            Value<int?> paymentDay = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> memo = const Value.absent(),
          }) =>
              UnitsCompanion(
            id: id,
            buildingId: buildingId,
            roomNumber: roomNumber,
            leaseType: leaseType,
            tenantName: tenantName,
            tenantPhone: tenantPhone,
            deposit: deposit,
            monthlyRent: monthlyRent,
            contractStart: contractStart,
            contractEnd: contractEnd,
            paymentDay: paymentDay,
            imagePath: imagePath,
            memo: memo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int buildingId,
            required String roomNumber,
            Value<String?> leaseType = const Value.absent(),
            Value<String?> tenantName = const Value.absent(),
            Value<String?> tenantPhone = const Value.absent(),
            Value<int> deposit = const Value.absent(),
            Value<int> monthlyRent = const Value.absent(),
            Value<DateTime?> contractStart = const Value.absent(),
            Value<DateTime?> contractEnd = const Value.absent(),
            Value<int?> paymentDay = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> memo = const Value.absent(),
          }) =>
              UnitsCompanion.insert(
            id: id,
            buildingId: buildingId,
            roomNumber: roomNumber,
            leaseType: leaseType,
            tenantName: tenantName,
            tenantPhone: tenantPhone,
            deposit: deposit,
            monthlyRent: monthlyRent,
            contractStart: contractStart,
            contractEnd: contractEnd,
            paymentDay: paymentDay,
            imagePath: imagePath,
            memo: memo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UnitsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {buildingId = false,
              unitImagesRefs = false,
              transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (unitImagesRefs) db.unitImages,
                if (transactionsRefs) db.transactions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (buildingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.buildingId,
                    referencedTable:
                        $$UnitsTableReferences._buildingIdTable(db),
                    referencedColumn:
                        $$UnitsTableReferences._buildingIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (unitImagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UnitsTableReferences._unitImagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UnitsTableReferences(db, table, p0)
                                .unitImagesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.unitId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UnitsTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UnitsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.unitId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, $$UnitsTableReferences),
    Unit,
    PrefetchHooks Function(
        {bool buildingId, bool unitImagesRefs, bool transactionsRefs})>;
typedef $$UnitImagesTableCreateCompanionBuilder = UnitImagesCompanion Function({
  Value<int> id,
  required int unitId,
  required String imagePath,
  Value<DateTime> createdAt,
});
typedef $$UnitImagesTableUpdateCompanionBuilder = UnitImagesCompanion Function({
  Value<int> id,
  Value<int> unitId,
  Value<String> imagePath,
  Value<DateTime> createdAt,
});

final class $$UnitImagesTableReferences
    extends BaseReferences<_$AppDatabase, $UnitImagesTable, UnitImage> {
  $$UnitImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units
      .createAlias($_aliasNameGenerator(db.unitImages.unitId, db.units.id));

  $$UnitsTableProcessedTableManager? get unitId {
    if ($_item.unitId == null) return null;
    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.id($_item.unitId!));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UnitImagesTableFilterComposer
    extends Composer<_$AppDatabase, $UnitImagesTable> {
  $$UnitImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UnitImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitImagesTable> {
  $$UnitImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableOrderingComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UnitImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitImagesTable> {
  $$UnitImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UnitImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitImagesTable,
    UnitImage,
    $$UnitImagesTableFilterComposer,
    $$UnitImagesTableOrderingComposer,
    $$UnitImagesTableAnnotationComposer,
    $$UnitImagesTableCreateCompanionBuilder,
    $$UnitImagesTableUpdateCompanionBuilder,
    (UnitImage, $$UnitImagesTableReferences),
    UnitImage,
    PrefetchHooks Function({bool unitId})> {
  $$UnitImagesTableTableManager(_$AppDatabase db, $UnitImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> unitId = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UnitImagesCompanion(
            id: id,
            unitId: unitId,
            imagePath: imagePath,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int unitId,
            required String imagePath,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UnitImagesCompanion.insert(
            id: id,
            unitId: unitId,
            imagePath: imagePath,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UnitImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({unitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (unitId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.unitId,
                    referencedTable:
                        $$UnitImagesTableReferences._unitIdTable(db),
                    referencedColumn:
                        $$UnitImagesTableReferences._unitIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UnitImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitImagesTable,
    UnitImage,
    $$UnitImagesTableFilterComposer,
    $$UnitImagesTableOrderingComposer,
    $$UnitImagesTableAnnotationComposer,
    $$UnitImagesTableCreateCompanionBuilder,
    $$UnitImagesTableUpdateCompanionBuilder,
    (UnitImage, $$UnitImagesTableReferences),
    UnitImage,
    PrefetchHooks Function({bool unitId})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required int buildingId,
  Value<int?> unitId,
  required String type,
  required int amount,
  required DateTime transactionDate,
  required String category,
  Value<String?> memo,
  Value<String?> receiptImagePath,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<int> buildingId,
  Value<int?> unitId,
  Value<String> type,
  Value<int> amount,
  Value<DateTime> transactionDate,
  Value<String> category,
  Value<String?> memo,
  Value<String?> receiptImagePath,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias(
          $_aliasNameGenerator(db.transactions.buildingId, db.buildings.id));

  $$BuildingsTableProcessedTableManager? get buildingId {
    if ($_item.buildingId == null) return null;
    final manager = $$BuildingsTableTableManager($_db, $_db.buildings)
        .filter((f) => f.id($_item.buildingId!));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units
      .createAlias($_aliasNameGenerator(db.transactions.unitId, db.units.id));

  $$UnitsTableProcessedTableManager? get unitId {
    if ($_item.unitId == null) return null;
    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.id($_item.unitId!));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TransactionImagesTable, List<TransactionImage>>
      _transactionImagesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactionImages,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.transactionImages.transactionId));

  $$TransactionImagesTableProcessedTableManager get transactionImagesRefs {
    final manager =
        $$TransactionImagesTableTableManager($_db, $_db.transactionImages)
            .filter((f) => f.transactionId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_transactionImagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptImagePath => $composableBuilder(
      column: $table.receiptImagePath,
      builder: (column) => ColumnFilters(column));

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableFilterComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> transactionImagesRefs(
      Expression<bool> Function($$TransactionImagesTableFilterComposer f) f) {
    final $$TransactionImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionImages,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionImagesTableFilterComposer(
              $db: $db,
              $table: $db.transactionImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptImagePath => $composableBuilder(
      column: $table.receiptImagePath,
      builder: (column) => ColumnOrderings(column));

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableOrderingComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableOrderingComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get receiptImagePath => $composableBuilder(
      column: $table.receiptImagePath, builder: (column) => column);

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableAnnotationComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> transactionImagesRefs<T extends Object>(
      Expression<T> Function($$TransactionImagesTableAnnotationComposer a) f) {
    final $$TransactionImagesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionImages,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionImagesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionImages,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool buildingId, bool unitId, bool transactionImagesRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> buildingId = const Value.absent(),
            Value<int?> unitId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<DateTime> transactionDate = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<String?> receiptImagePath = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            buildingId: buildingId,
            unitId: unitId,
            type: type,
            amount: amount,
            transactionDate: transactionDate,
            category: category,
            memo: memo,
            receiptImagePath: receiptImagePath,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int buildingId,
            Value<int?> unitId = const Value.absent(),
            required String type,
            required int amount,
            required DateTime transactionDate,
            required String category,
            Value<String?> memo = const Value.absent(),
            Value<String?> receiptImagePath = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            buildingId: buildingId,
            unitId: unitId,
            type: type,
            amount: amount,
            transactionDate: transactionDate,
            category: category,
            memo: memo,
            receiptImagePath: receiptImagePath,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {buildingId = false,
              unitId = false,
              transactionImagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionImagesRefs) db.transactionImages
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (buildingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.buildingId,
                    referencedTable:
                        $$TransactionsTableReferences._buildingIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._buildingIdTable(db).id,
                  ) as T;
                }
                if (unitId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.unitId,
                    referencedTable:
                        $$TransactionsTableReferences._unitIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._unitIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionImagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._transactionImagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .transactionImagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool buildingId, bool unitId, bool transactionImagesRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String type,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String type,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$BuildingImagesTableCreateCompanionBuilder = BuildingImagesCompanion
    Function({
  Value<int> id,
  required int buildingId,
  required String imagePath,
  Value<bool> isPrimary,
  Value<DateTime> createdAt,
});
typedef $$BuildingImagesTableUpdateCompanionBuilder = BuildingImagesCompanion
    Function({
  Value<int> id,
  Value<int> buildingId,
  Value<String> imagePath,
  Value<bool> isPrimary,
  Value<DateTime> createdAt,
});

final class $$BuildingImagesTableReferences
    extends BaseReferences<_$AppDatabase, $BuildingImagesTable, BuildingImage> {
  $$BuildingImagesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias(
          $_aliasNameGenerator(db.buildingImages.buildingId, db.buildings.id));

  $$BuildingsTableProcessedTableManager? get buildingId {
    if ($_item.buildingId == null) return null;
    final manager = $$BuildingsTableTableManager($_db, $_db.buildings)
        .filter((f) => f.id($_item.buildingId!));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BuildingImagesTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingImagesTable> {
  $$BuildingImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableFilterComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BuildingImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingImagesTable> {
  $$BuildingImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableOrderingComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BuildingImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingImagesTable> {
  $$BuildingImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableAnnotationComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BuildingImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BuildingImagesTable,
    BuildingImage,
    $$BuildingImagesTableFilterComposer,
    $$BuildingImagesTableOrderingComposer,
    $$BuildingImagesTableAnnotationComposer,
    $$BuildingImagesTableCreateCompanionBuilder,
    $$BuildingImagesTableUpdateCompanionBuilder,
    (BuildingImage, $$BuildingImagesTableReferences),
    BuildingImage,
    PrefetchHooks Function({bool buildingId})> {
  $$BuildingImagesTableTableManager(
      _$AppDatabase db, $BuildingImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> buildingId = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BuildingImagesCompanion(
            id: id,
            buildingId: buildingId,
            imagePath: imagePath,
            isPrimary: isPrimary,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int buildingId,
            required String imagePath,
            Value<bool> isPrimary = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BuildingImagesCompanion.insert(
            id: id,
            buildingId: buildingId,
            imagePath: imagePath,
            isPrimary: isPrimary,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BuildingImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({buildingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (buildingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.buildingId,
                    referencedTable:
                        $$BuildingImagesTableReferences._buildingIdTable(db),
                    referencedColumn:
                        $$BuildingImagesTableReferences._buildingIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BuildingImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BuildingImagesTable,
    BuildingImage,
    $$BuildingImagesTableFilterComposer,
    $$BuildingImagesTableOrderingComposer,
    $$BuildingImagesTableAnnotationComposer,
    $$BuildingImagesTableCreateCompanionBuilder,
    $$BuildingImagesTableUpdateCompanionBuilder,
    (BuildingImage, $$BuildingImagesTableReferences),
    BuildingImage,
    PrefetchHooks Function({bool buildingId})>;
typedef $$TransactionImagesTableCreateCompanionBuilder
    = TransactionImagesCompanion Function({
  Value<int> id,
  required int transactionId,
  required String imagePath,
  Value<DateTime> createdAt,
});
typedef $$TransactionImagesTableUpdateCompanionBuilder
    = TransactionImagesCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<String> imagePath,
  Value<DateTime> createdAt,
});

final class $$TransactionImagesTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionImagesTable, TransactionImage> {
  $$TransactionImagesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.transactionImages.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get transactionId {
    if ($_item.transactionId == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id($_item.transactionId!));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionImagesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionImagesTable> {
  $$TransactionImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionImagesTable> {
  $$TransactionImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionImagesTable> {
  $$TransactionImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionImagesTable,
    TransactionImage,
    $$TransactionImagesTableFilterComposer,
    $$TransactionImagesTableOrderingComposer,
    $$TransactionImagesTableAnnotationComposer,
    $$TransactionImagesTableCreateCompanionBuilder,
    $$TransactionImagesTableUpdateCompanionBuilder,
    (TransactionImage, $$TransactionImagesTableReferences),
    TransactionImage,
    PrefetchHooks Function({bool transactionId})> {
  $$TransactionImagesTableTableManager(
      _$AppDatabase db, $TransactionImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionImagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionImagesCompanion(
            id: id,
            transactionId: transactionId,
            imagePath: imagePath,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required String imagePath,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionImagesCompanion.insert(
            id: id,
            transactionId: transactionId,
            imagePath: imagePath,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionImagesTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionImagesTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionImagesTable,
    TransactionImage,
    $$TransactionImagesTableFilterComposer,
    $$TransactionImagesTableOrderingComposer,
    $$TransactionImagesTableAnnotationComposer,
    $$TransactionImagesTableCreateCompanionBuilder,
    $$TransactionImagesTableUpdateCompanionBuilder,
    (TransactionImage, $$TransactionImagesTableReferences),
    TransactionImage,
    PrefetchHooks Function({bool transactionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BuildingsTableTableManager get buildings =>
      $$BuildingsTableTableManager(_db, _db.buildings);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$UnitImagesTableTableManager get unitImages =>
      $$UnitImagesTableTableManager(_db, _db.unitImages);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$BuildingImagesTableTableManager get buildingImages =>
      $$BuildingImagesTableTableManager(_db, _db.buildingImages);
  $$TransactionImagesTableTableManager get transactionImages =>
      $$TransactionImagesTableTableManager(_db, _db.transactionImages);
}
