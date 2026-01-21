import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../property/property_provider.dart';
import '../ledger/unpaid_provider.dart';

enum AlertType { overdue, contractEnding }

class AppAlert {
  final String title;
  final String body;
  final AlertType type;
  final DateTime date;
  final String? roomNumber;
  // 📍 실제 연락처 연동을 위한 필드 추가
  final String? phoneNumber;

  AppAlert({
    required this.title,
    required this.body,
    required this.type,
    required this.date,
    this.roomNumber,
    this.phoneNumber, // 생성자 추가
  });
}

final appAlertProvider = Provider<List<AppAlert>>((ref) {
  final List<AppAlert> alerts = [];
  final now = DateTime.now();

  // 1️⃣ 미납 체크 (whenData 대신 value를 직접 참조하여 순서 보장)
  final unpaidAsync = ref.watch(unpaidListProvider);
  final unpaidList = unpaidAsync.value ?? []; // 데이터가 있으면 가져오고 없으면 빈 리스트

  for (var unpaid in unpaidList) {
    if (unpaid.status == 'OVERDUE') {
      alerts.add(AppAlert(
        title: "임대료 미납",
        body: "${unpaid.unit.roomNumber}호 임대료가 아직 미납입니다.",
        type: AlertType.overdue,
        date: now,
        roomNumber: unpaid.unit.roomNumber,
        // 📍 tables.dart에 정의된 tenantPhone 필드 연결
        phoneNumber: unpaid.unit.tenantPhone,
      ));
    }
  }

  // 2️⃣ 계약 만료 체크 (📍 contractEnd 필드명 반영)
  final propertyAsync = ref.watch(propertyListProvider);
  final buildings = propertyAsync.value ?? []; // 데이터가 있으면 가져오고 없으면 빈 리스트

  for (var building in buildings) {
    for (var unit in building.units) {
      // 테이블 정의서의 'contractEnd' 필드 사용
      if (unit.contractEnd != null) {
        final daysLeft = unit.contractEnd!.difference(now).inDays;

        // 만료 30일 이내 알림 생성
        if (daysLeft >= 0 && daysLeft <= 30) {
          alerts.add(AppAlert(
            title: "계약 만료 예정",
            body: "${unit.roomNumber}호 계약 만료가 $daysLeft일 남았습니다.",
            type: AlertType.contractEnding,
            date: unit.contractEnd!,
            roomNumber: unit.roomNumber,
            // 📍 tables.dart에 정의된 tenantPhone 필드 연결
            phoneNumber: unit.tenantPhone,
          ));
        }
      }
    }
  }

  return alerts;
});