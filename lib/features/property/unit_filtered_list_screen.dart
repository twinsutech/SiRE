import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
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

    // 📍 다국어: 화면 제목 및 테마 색상 결정
    String title;
    Color themeColor;
    switch (filterType) {
      case UnitFilterType.unpaid:
        title = "FILTER_TITLE_UNPAID".tr(ref); // 📍 다국어: "전체 미납자 관리"
        themeColor = AppColors.expenseRed;
        break;
      case UnitFilterType.vacant:
        title = "FILTER_TITLE_VACANT".tr(ref); // 📍 다국어: "전체 공실 현황"
        themeColor = Colors.grey;
        break;
      case UnitFilterType.expiring:
        title = "FILTER_TITLE_EXPIRING".tr(ref); // 📍 다국어: "계약 만기 임박"
        themeColor = Colors.orange;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: unpaidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("${"COMMON_ERROR".tr(ref)}: $err")),
        data: (unpaidStatusList) {
          // 📍 필터 로직 적용
          // ✅ propertyListAsync.whenData(...)로 List를 채우는 방식은 build 타이밍에 따라 빈 리스트가 될 수 있어,
          //    여기서는 propertyListAsync의 현재 값을 즉시 사용하도록 개선합니다.
          List<dynamic> filteredList = [];

          if (filterType == UnitFilterType.unpaid) {
            // 미납자: UnpaidStatus 리스트에서 OVERDUE인 것만 필터링
            filteredList = unpaidStatusList.where((s) => s.status == 'OVERDUE').toList();
          } else {
            // 공실 및 만기임박: propertyListProvider 값을 즉시 사용
            final buildingWithUnitsList = propertyListAsync.value ?? [];
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
          }

          if (filteredList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "$title ${"FILTER_EMPTY_DESC".tr(ref)}", // 📍 다국어: "{title} 내역이 없습니다."
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              // 데이터 타입에 따라 적절한 카드 빌드 (UnpaidStatus 혹은 Unit)
              if (item is UnpaidStatus) return _buildUnitCard(context, ref, item.unit, overdueStatus: item);
              return _buildUnitCard(context, ref, item as Unit);
            },
          );
        },
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, WidgetRef ref, dynamic unit, {UnpaidStatus? overdueStatus}) {
    final bool isVacant = unit.tenantName == null || unit.tenantName!.isEmpty;
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 [화폐 다국어 처리] 로케일별 통화 포매터 정의
    final currencyFmt = NumberFormat.simpleCurrency(
      locale: currentLang,
      decimalDigits: 0,
    );

    final String titleText =
        "${unit.roomNumber}${"COMMON_ROOM_UNIT".tr(ref)} ${unit.tenantName ?? "(${'DASHBOARD_VACANT_UNITS'.tr(ref)})"}";

    String subtitleText;
    if (isVacant) {
      subtitleText = "FILTER_VACANT_SUBTITLE".tr(ref); // 📍 다국어: "입주 대기 중"
    } else if (overdueStatus != null) {
      // 📍 [수정] 하드코딩된 단위를 제거하고 글로벌 표준 통화 포맷 적용
      subtitleText = "${"FILTER_UNPAID_AMOUNT".tr(ref)}: ${currencyFmt.format(unit.monthlyRent - overdueStatus.paidAmount)}";
    } else {
      subtitleText =
      "${"FILTER_EXPIRY_DATE".tr(ref)}: ${unit.contractEnd != null ? DateFormat.yMd(currentLang).format(unit.contractEnd!) : '-'}";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          titleText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitleText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isVacant
            ? null
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              tooltip: "PROP_CALL_TO".tr(ref),
              onPressed: () => _makePhoneCall(unit.tenantPhone ?? ""),
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.blue),
              tooltip: "PROP_SEND_SMS".tr(ref),
              onPressed: () => _sendSMS(unit.tenantPhone ?? ""),
            ),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit))),
      ),
    );
  }

  // 📍 기존 전화/문자 헬퍼 함수들 유지
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _sendSMS(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }
}


