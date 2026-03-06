import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/database_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'room_detail_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import 'property_provider.dart';
import 'add_building_dialog.dart';
import 'add_unit_dialog.dart';
// 📍 새로 만든 통합 필터 리스트 화면 임포트
import 'unit_filtered_list_screen.dart';

class PropertyScreen extends ConsumerWidget {
  // 📍 [에러 해결] 생성자 이름을 클래스명과 동일하게 PropertyScreen으로 수정함
  const PropertyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyListAsync = ref.watch(propertyListProvider);
    final summaryAsync = ref.watch(propertySummaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "NAV_PROPERTIES".tr(ref), // 📍 다국어 적용: "Properties"
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // 📍 [최종 수정] 빌딩 리스트가 비어있을 때 AppBar 내부에 직접 가이드 표시 (사라짐 방지)
          propertyListAsync.maybeWhen(
            data: (list) => list.isEmpty
                ? _FloatingGuideArrow(label: "PROP_ADD_BUILDING".tr(ref))
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "PROP_ADD_BUILDING".tr(ref), // 📍 다국어 적용: "Add Building"
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddBuildingDialog(),
              );
            },
          ),
        ],
      ),
      body: propertyListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (buildingList) {
          if (buildingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apartment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                      "PROP_NO_BUILDINGS_DESC".tr(ref), // 📍 다국어 적용
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16)
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              summaryAsync.when(
                data: (summary) => _buildSummaryDashboard(summary, context, ref),
                loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              Text(
                "PROP_MY_BUILDINGS".tr(ref), // 📍 다국어 적용: "My Buildings"
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ...buildingList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildBuildingCard(context, ref, item),
              )),
            ],
          );
        },
      ),
    );
  }

  // 종합 요약 대시보드 UI 빌더
  Widget _buildSummaryDashboard(PropertySummary summary, BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "PROP_MONTHLY_COLLECTION".tr(ref),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${(summary.collectionRate * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A237E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.collectionRate,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _buildClickableSummaryItem(
                      context,
                      ref,
                      Icons.warning_amber_rounded,
                      "ALERT_OVERDUE_TITLE".tr(ref),
                      "${summary.totalUnpaid}",
                      Colors.red,
                      UnitFilterType.unpaid,
                    ),
                  ),
                  Flexible(
                    child: _buildClickableSummaryItem(
                      context,
                      ref,
                      Icons.door_front_door_outlined,
                      "DASHBOARD_VACANT_UNITS".tr(ref),
                      "${summary.totalVacancies}",
                      Colors.grey,
                      UnitFilterType.vacant,
                    ),
                  ),
                  Flexible(
                    child: _buildClickableSummaryItem(
                      context,
                      ref,
                      Icons.event_available_outlined,
                      "ALERT_CONTRACT_ENDING_TITLE".tr(ref),
                      "${summary.expiringSoon}",
                      Colors.orange,
                      UnitFilterType.expiring,
                    ),
                  ),
                  Flexible(child: _buildSummaryItem(Icons.trending_up, "PROP_YIELD".tr(ref), "${summary.averageYield.toStringAsFixed(1)}%", Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableSummaryItem(BuildContext context, WidgetRef ref, IconData icon, String label, String value, Color color, UnitFilterType type) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          if (context.mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UnitFilteredListScreen(filterType: type))
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: _buildSummaryItem(icon, label, value, color),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min, // 📍 에러 해결: MainAxisSize.min
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
        ),
      ],
    );
  }

  Widget _buildBuildingCard(BuildContext context, WidgetRef ref, BuildingWithUnits item) {
    final building = item.building;
    final db = ref.watch(databaseProvider);
    final yieldVal = item.yieldRate.isNaN ? "0.0" : item.yieldRate.toStringAsFixed(1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<BuildingImage>>(
            stream: (db.select(db.buildingImages)..where((t) => t.buildingId.equals(building.id))).watch(),
            builder: (context, snapshot) {
              final images = snapshot.data ?? [];
              final bool hasImage = images.isNotEmpty;

              BuildingImage? displayImage;
              if (hasImage) {
                displayImage = images.firstWhere(
                        (img) => img.isPrimary,
                    orElse: () => images.first
                );
              }
              return Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: hasImage
                      ? DecorationImage(
                    image: FileImage(File(displayImage!.imagePath)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                  )
                      : null,
                  gradient: !hasImage
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1A237E).withOpacity(0.8), const Color(0xFF1A237E).withOpacity(0.6)],
                  )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, size: 48, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📍 건물 이름 자동 크기 조절 적용
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                building.name.startsWith('COMMON_') ? building.name.tr(ref) : building.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              "${"PROP_TOTAL".tr(ref)} ${item.units.length} ${"COMMON_ROOMS".tr(ref)}",
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildAdminPopupMenu(
                        context,
                        ref,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddBuildingDialog(building: building),
                          );
                        },
                        onDelete: () => _showDeleteBuildingConfirm(context, ref, building),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddUnitDialog(buildingId: building.id),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "DASHBOARD_OCCUPANCY".tr(ref),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${"PROP_YIELD".tr(ref)}: $yieldVal%",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (item.units.isEmpty)
                  _buildEmptyUnitPlaceholder(ref)
                else
                  _buildRoomGrid(context, ref, item.units),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPopupMenu(BuildContext context, WidgetRef ref, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      offset: const Offset(0, 45),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 22, color: Color(0xFF1A237E)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "COMMON_EDIT".tr(ref),
                  style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, size: 22, color: Colors.redAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "COMMON_DELETE".tr(ref),
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyUnitPlaceholder(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Text("PROP_NO_UNITS_DESC".tr(ref),
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ),
    );
  }

  Widget _buildRoomGrid(BuildContext context, WidgetRef ref, List<Unit> units) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: units.length,
      itemBuilder: (context, index) => _buildRoomButton(context, ref, units[index]),
    );
  }

  Widget _buildRoomButton(BuildContext context, WidgetRef ref, Unit unit) {
    final unpaidAsync = ref.watch(unpaidListProvider);

    return unpaidAsync.when(
      loading: () => _buildBaseRoomContainer(unit, Colors.grey, "COMMON_LOADING".tr(ref), null),
      error: (err, _) => _buildBaseRoomContainer(unit, Colors.red, "COMMON_ERROR".tr(ref), null),
      data: (unpaidList) {
        final myStatus = unpaidList.firstWhere(
              (s) => s.unit.id == unit.id,
          orElse: () => UnpaidStatus(
            unit: unit,
            status: 'WAITING',
            paidAmount: 0,
            dueDate: DateTime.now(),
          ),
        );

        Color statusColor = AppColors.incomeGreen;
        String statusText = "STATUS_PAID".tr(ref);
        Widget? leaseBadge = _buildLeaseBadge(unit.leaseType, ref);

        if (unit.tenantName == null || unit.tenantName!.isEmpty) {
          statusColor = Colors.grey;
          statusText = "DASHBOARD_VACANT_UNITS".tr(ref);
          leaseBadge = null;
        } else if (myStatus.status == 'OVERDUE' && (unit.leaseType == '월세' || unit.leaseType == '반전세')) {
          statusColor = AppColors.expenseRed;
          statusText = "ALERT_OVERDUE_TITLE".tr(ref);
        } else {
          bool isExpiring = false;
          if (unit.contractEnd != null) {
            final daysLeft = unit.contractEnd!.difference(DateTime.now()).inDays;
            if (daysLeft >= 0 && daysLeft <= 30) isExpiring = true;
          }

          if (isExpiring) {
            statusColor = Colors.orange;
            statusText = "ALERT_CONTRACT_ENDING_TITLE".tr(ref);
          } else if (myStatus.status == 'PAID') {
            statusColor = const Color(0xFF1A237E);
            statusText = "STATUS_PAID".tr(ref);
          } else {
            statusColor = AppColors.incomeGreen;
            statusText = unit.leaseType == '전세' ? "LEASE_JEONSE".tr(ref) : "STATUS_WAITING".tr(ref);
          }
        }

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit)),
          ),
          onLongPress: () => _showUnitManagementMenu(context, ref, unit, myStatus.status == 'OVERDUE'),
          child: _buildBaseRoomContainer(unit, statusColor, statusText, leaseBadge),
        );
      },
    );
  }

  Widget? _buildLeaseBadge(String? leaseType, WidgetRef ref) {
    if (leaseType == null || leaseType == '공실') return null;

    Color badgeColor;
    String fullLabel;

    switch (leaseType) {
      case '월세':
        badgeColor = const Color(0xFF2196F3);
        fullLabel = "LEASE_MONTHLY_SHORT".tr(ref);
        break;
      case '전세':
        badgeColor = const Color(0xFF9C27B0);
        fullLabel = "LEASE_JEONSE_SHORT".tr(ref);
        break;
      case '반전세':
        badgeColor = const Color(0xFFFF9800);
        fullLabel = "LEASE_HALF_JEONSE_SHORT".tr(ref);
        break;
      default:
        return null;
    }

    String firstChar = fullLabel.isNotEmpty ? fullLabel.substring(0, 1).toUpperCase() : "";

    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 2, offset: const Offset(0, 1))]
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
            firstChar,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: -0.5)
        ),
      ),
    );
  }

  Widget _buildBaseRoomContainer(Unit unit, Color color, String text, Widget? badge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color, width: 1.2)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(unit.roomNumber, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500), maxLines: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (badge != null) Positioned(top: -4, right: -4, child: badge),
      ],
    );
  }

  void _showUnitManagementMenu(BuildContext context, WidgetRef ref, Unit unit, bool isOverdue) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "${unit.roomNumber}${"COMMON_ROOM_UNIT".tr(ref)} ${"PROP_QUICK_MENU".tr(ref)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
            ),
            if (unit.tenantName != null && unit.tenantName!.isNotEmpty) ...[
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white)),
                title: Text(
                  "${"PROP_CALL_TO".tr(ref)} ${unit.tenantName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () { Navigator.pop(context); _makePhoneCall(unit.tenantPhone ?? ""); },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: isOverdue ? Colors.orange : Colors.blue, child: Icon(isOverdue ? Icons.notification_important : Icons.message, color: Colors.white)),
                title: Text(
                  isOverdue ? "PROP_SEND_REMIND_SMS".tr(ref) : "PROP_SEND_SMS".tr(ref),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () { Navigator.pop(context); if (isOverdue) { _sendRemindSMS(unit, context, ref); } else { _sendSMS(unit.tenantPhone ?? ""); } },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF1A237E), child: Icon(Icons.info_outline, color: Colors.white)),
              title: Text("PROP_VIEW_DETAIL".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit))); },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.delete_outline, color: Colors.white)),
              title: Text("PROP_DELETE_UNIT".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () { Navigator.pop(context); _showDeleteUnitConfirm(context, ref, unit); },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _sendRemindSMS(Unit unit, BuildContext context, WidgetRef ref) async {
    if (unit.tenantPhone == null || unit.tenantPhone!.isEmpty) return;
    final now = DateTime.now();
    final lang = ref.read(localizationProvider.notifier).currentLang;
    final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);
    final String msgTemplate = "PROP_SMS_REMIND_TEMPLATE".tr(ref);
    final String message = msgTemplate
        .replaceAll("{tenant}", unit.tenantName ?? "")
        .replaceAll("{month}", "${now.month}")
        .replaceAll("{amount}", currencyFmt.format(unit.monthlyRent));

    final String encodedMessage = Uri.encodeComponent(message).replaceAll('+', '%20');
    final String smsUrl = Platform.isAndroid ? "sms:${unit.tenantPhone}?body=$encodedMessage" : "sms:${unit.tenantPhone}&body=$encodedMessage";
    final Uri uri = Uri.parse(smsUrl);
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
    else if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ALERT_SMS_APP_ERROR".tr(ref)))); }
  }

  Future<void> _makePhoneCall(String phoneNumber) async { if (phoneNumber.isEmpty) return; final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber); if (await canLaunchUrl(launchUri)) { await launchUrl(launchUri); } }
  Future<void> _sendSMS(String phoneNumber) async { if (phoneNumber.isEmpty) return; final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber); if (await canLaunchUrl(launchUri)) { await launchUrl(launchUri); } }

  Future<void> _showDeleteUnitConfirm(BuildContext context, WidgetRef ref, Unit unit) {
    return showDialog(
        context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("PROP_DELETE_UNIT".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
        content: Text("${"PROP_DELETE_UNIT_CONFIRM".tr(ref)} '${unit.roomNumber}'?", maxLines: 3, overflow: TextOverflow.ellipsis),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async { final db = ref.read(databaseProvider); await (db.delete(db.units)..where((t) => t.id.equals(unit.id))).go(); ref.invalidate(propertyListProvider); if (context.mounted) Navigator.pop(context); },
              child: Text("COMMON_DELETE".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis))]));
  }

  Future<void> _showDeleteBuildingConfirm(BuildContext context, WidgetRef ref, Building building) {
    return showDialog(
        context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("PROP_DELETE_BUILDING".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
        content: Text("${"PROP_DELETE_BUILDING_CONFIRM".tr(ref)} '${building.name}'?", maxLines: 3, overflow: TextOverflow.ellipsis),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async { final db = ref.read(databaseProvider); await (db.delete(db.buildings)..where((t) => t.id.equals(building.id))).go(); ref.invalidate(propertyListProvider); if (context.mounted) Navigator.pop(context); },
              child: Text("COMMON_DELETE".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis))]));
  }
}

// 📍 [최종 수정] AppBar 내부에 직접 배치되도록 설계된 가이드 위젯 (사라짐 방지)
class _FloatingGuideArrow extends StatefulWidget {
  final String label;
  const _FloatingGuideArrow({required this.label});

  @override
  State<_FloatingGuideArrow> createState() => _FloatingGuideArrowState();
}

class _FloatingGuideArrowState extends State<_FloatingGuideArrow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📍 AppBar의 actions 리스트 내에서 IconButton 바로 왼쪽에 정렬됨
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-_animation.value, 0), // 수평 방향으로 톡톡 치는 애니메이션
            child: GestureDetector(
              // 📍 [추가] 가이드 클릭 시 빌딩 추가 다이얼로그 호출
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddBuildingDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.95), // 눈에 잘 띄는 주황색 계열
                  borderRadius: BorderRadius.circular(20), // 세련된 둥근 박스
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label, // "빌딩 추가" 다국어 텍스트
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded, // + 버튼을 가리키는 화살표
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}