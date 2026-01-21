// lib/src/features/property/unit_filtered_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../core/database/app_database.dart';
import '../ledger/unpaid_provider.dart';
import 'property_provider.dart';
import '../../core/theme/app_colors.dart';
import 'room_detail_screen.dart';

// 필터 타입을 정의합니다.
enum UnitFilterType { unpaid, vacant, expiring }

class UnitFilteredListScreen extends ConsumerWidget {
  final UnitFilterType filterType;

  const UnitFilteredListScreen({super.key, required this.filterType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 미납 상태 정보와 전체 호실 정보를 함께 활용합니다.
    final unpaidAsync = ref.watch(unpaidListProvider);
    final propertyListAsync = ref.watch(propertyListProvider);

    // 화면 제목 및 테마 색상 결정
    String title;
    Color themeColor;
    switch (filterType) {
      case UnitFilterType.unpaid:
        title = "전체 미납자 관리";
        themeColor = AppColors.expenseRed;
        break;
      case UnitFilterType.vacant:
        title = "전체 공실 현황";
        themeColor = Colors.grey;
        break;
      case UnitFilterType.expiring:
        title = "계약 만기 임박";
        themeColor = Colors.orange;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: unpaidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("에러 발생: $err")),
        data: (unpaidStatusList) {
          // 📍 필터 로직 적용
          List<dynamic> filteredList = [];

          if (filterType == UnitFilterType.unpaid) {
            // 미납자: UnpaidStatus 리스트에서 OVERDUE인 것만 필터링
            filteredList = unpaidStatusList.where((s) => s.status == 'OVERDUE').toList();
          } else {
            // 공실 및 만기임박은 propertyListProvider의 데이터를 기반으로 필터링
            propertyListAsync.whenData((buildingWithUnitsList) {
              for (var building in buildingWithUnitsList) {
                for (var unit in building.units) {
                  if (filterType == UnitFilterType.vacant) {
                    if (unit.tenantName == null || unit.tenantName!.isEmpty) filteredList.add(unit);
                  } else if (filterType == UnitFilterType.expiring) {
                    if (unit.contractEnd != null) {
                      final daysLeft = unit.contractEnd!.difference(DateTime.now()).inDays;
                      if (daysLeft >= 0 && daysLeft <= 30) filteredList.add(unit);
                    }
                  }
                }
              }
            });
          }

          if (filteredList.isEmpty) {
            return Center(child: Text("$title 내역이 없습니다.", style: const TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              // 데이터 타입에 따라 적절한 카드 빌드 (UnpaidStatus 혹은 Unit)
              if (item is UnpaidStatus) return _buildUnitCard(context, item.unit, overdueStatus: item);
              return _buildUnitCard(context, item as Unit);
            },
          );
        },
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, dynamic unit, {UnpaidStatus? overdueStatus}) {
    final bool isVacant = unit.tenantName == null || unit.tenantName!.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text("${unit.roomNumber}호 ${unit.tenantName ?? '(공실)'}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: isVacant
            ? const Text("입주 대기 중")
            : Text(overdueStatus != null
            ? "미납금액: ${NumberFormat('#,###').format(unit.monthlyRent - overdueStatus.paidAmount)} 만원"
            : "만기일: ${unit.contractEnd != null ? DateFormat('yyyy.MM.dd').format(unit.contractEnd!) : '-'}"),
        trailing: isVacant ? null : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () => _makePhoneCall(unit.tenantPhone ?? "")),
            IconButton(icon: const Icon(Icons.message, color: Colors.blue), onPressed: () => _sendSMS(unit.tenantPhone ?? "")),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit))),
      ),
    );
  }

  // 기존 전화/문자 헬퍼 함수들 유지... (생략)
  Future<void> _makePhoneCall(String phoneNumber) async { /* ... */ }
  Future<void> _sendSMS(String phoneNumber) async { /* ... */ }
}