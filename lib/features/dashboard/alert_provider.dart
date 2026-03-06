import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization_provider.dart';
import '../property/property_provider.dart';
import '../ledger/unpaid_provider.dart';

enum AlertType { overdue, contractEnding }

class AppAlert {
  // 📍 String 대신 나중에 번역할 수 있도록 필드 유지 (UI에서 번역 수행 예정)
  final String title;
  final String body;
  final AlertType type;
  final DateTime date;
  final String? roomNumber;
  final String? phoneNumber;
  final int? daysLeft; // 📍 남은 일수 계산용 필드 추가

  AppAlert({
    required this.title,
    required this.body,
    required this.type,
    required this.date,
    this.roomNumber,
    this.phoneNumber,
    this.daysLeft, // 생성자 추가
  });
}

final appAlertProvider = Provider<List<AppAlert>>((ref) {
  // 📍 [핵심 추가] 다국어 상태 변경을 감지하여 Provider를 리빌드하도록 watch 추가
  ref.watch(localizationProvider);

  final List<AppAlert> alerts = [];
  final now = DateTime.now();

  // 1️⃣ 미납 체크
  final unpaidAsync = ref.watch(unpaidListProvider);
  final unpaidList = unpaidAsync.value ?? [];

  for (var unpaid in unpaidList) {
    if (unpaid.status == 'OVERDUE') {
      final String room = unpaid.unit.roomNumber;
      alerts.add(AppAlert(
        title: "ALERT_OVERDUE_TITLE", // 📍 키값을 전달
        body: "ALERT_OVERDUE_BODY",   // 📍 키값을 전달
        type: AlertType.overdue,
        date: now,
        roomNumber: room,
        phoneNumber: unpaid.unit.tenantPhone,
      ));
    }
  }

  // 2️⃣ 계약 만료 체크
  final propertyAsync = ref.watch(propertyListProvider);
  final buildings = propertyAsync.value ?? [];

  for (var building in buildings) {
    for (var unit in building.units) {
      if (unit.contractEnd != null) {
        final daysLeft = unit.contractEnd!.difference(now).inDays;
        if (daysLeft >= 0 && daysLeft <= 30) {
          final String room = unit.roomNumber;
          alerts.add(AppAlert(
            title: "ALERT_CONTRACT_ENDING_TITLE", // 📍 키값
            body: "ALERT_CONTRACT_ENDING_BODY",   // 📍 통합된 하나의 바디 키 사용
            type: AlertType.contractEnding,
            date: unit.contractEnd!,
            roomNumber: room,
            phoneNumber: unit.tenantPhone,
            daysLeft: daysLeft, // 📍 남은 일수 전달
          ));
        }
      }
    }
  }

  return alerts;
});