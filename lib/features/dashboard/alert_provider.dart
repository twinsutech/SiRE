// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../property/property_provider.dart';
// import '../ledger/unpaid_provider.dart';
//
// enum AlertType { overdue, contractEnding }
//
// class AppAlert {
//   final String title;
//   final String body;
//   final AlertType type;
//   final DateTime date;
//   final String? roomNumber;
//   // 📍 실제 연락처 연동을 위한 필드 추가
//   final String? phoneNumber;
//
//   AppAlert({
//     required this.title,
//     required this.body,
//     required this.type,
//     required this.date,
//     this.roomNumber,
//     this.phoneNumber, // 생성자 추가
//   });
// }
//
// final appAlertProvider = Provider<List<AppAlert>>((ref) {
//   final List<AppAlert> alerts = [];
//   final now = DateTime.now();
//
//   // 📍 번역을 위한 노티파이어 참조
//   final l10n = ref.read(localizationProvider.notifier);
//
//   // 1️⃣ 미납 체크 (whenData 대신 value를 직접 참조하여 순서 보장)
//   final unpaidAsync = ref.watch(unpaidListProvider);
//   final unpaidList = unpaidAsync.value ?? []; // 데이터가 있으면 가져오고 없으면 빈 리스트
//
//   for (var unpaid in unpaidList) {
//     if (unpaid.status == 'OVERDUE') {
//       // 📍 다국어 적용: "임대료 미납", "{room}호 임대료가 아직 미납입니다."
//       final String room = unpaid.unit.roomNumber;
//       alerts.add(AppAlert(
//         title: l10n.translate("ALERT_OVERDUE_TITLE"),
//         body: "${l10n.translate("COMMON_ROOM_UNIT")}$room ${l10n.translate("ALERT_OVERDUE_BODY")}",
//         type: AlertType.overdue,
//         date: now,
//         roomNumber: room,
//         // 📍 tables.dart에 정의된 tenantPhone 필드 연결
//         phoneNumber: unpaid.unit.tenantPhone,
//       ));
//     }
//   }
//
//   // 2️⃣ 계약 만료 체크 (📍 contractEnd 필드명 반영)
//   final propertyAsync = ref.watch(propertyListProvider);
//   final buildings = propertyAsync.value ?? []; // 데이터가 있으면 가져오고 없으면 빈 리스트
//
//   for (var building in buildings) {
//     for (var unit in building.units) {
//       // 테이블 정의서의 'contractEnd' 필드 사용
//       if (unit.contractEnd != null) {
//         final daysLeft = unit.contractEnd!.difference(now).inDays;
//
//         // 만료 30일 이내 알림 생성
//         if (daysLeft >= 0 && daysLeft <= 30) {
//           // 📍 다국어 적용: "계약 만료 예정", "{room}호 계약 만료가 {days}일 남았습니다."
//           final String room = unit.roomNumber;
//           alerts.add(AppAlert(
//             title: l10n.translate("ALERT_CONTRACT_ENDING_TITLE"),
//             body: "${l10n.translate("COMMON_ROOM_UNIT")}$room ${l10n.translate("ALERT_CONTRACT_ENDING_BODY_1")} $daysLeft${l10n.translate("ALERT_CONTRACT_ENDING_BODY_2")}",
//             type: AlertType.contractEnding,
//             date: unit.contractEnd!,
//             roomNumber: room,
//             // 📍 tables.dart에 정의된 tenantPhone 필드 연결
//             phoneNumber: unit.tenantPhone,
//           ));
//         }
//       }
//     }
//   }
//
//   return alerts;
// });
//
//


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