import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
  const PropertyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyListAsync = ref.watch(propertyListProvider);
    // 📍 요약 데이터 프로바이더 감시
    final summaryAsync = ref.watch(propertySummaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Properties",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Building",
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No properties yet.\nTap + to add your first building.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 📍 1. 상단 종합 요약 대시보드 위젯
              summaryAsync.when(
                data: (summary) => _buildSummaryDashboard(summary, context),
                loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              const Text(
                "My Buildings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 16),
              // 📍 2. 기존 빌딩 카드 리스트
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

  // 📍 [수정] 종합 요약 대시보드 UI 빌더: 개별 클릭 기능 반영
  Widget _buildSummaryDashboard(PropertySummary summary, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Monthly Collection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("${(summary.collectionRate * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A237E))),
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
              // 📍 미납(Unpaid) 클릭 시 이동
              _buildClickableSummaryItem(
                  context, Icons.warning_amber_rounded, "Unpaid", "${summary.totalUnpaid}", Colors.red, UnitFilterType.unpaid
              ),
              // 📍 공실(Vacant) 클릭 시 이동
              _buildClickableSummaryItem(
                  context, Icons.door_front_door_outlined, "Vacant", "${summary.totalVacancies}", Colors.grey, UnitFilterType.vacant
              ),
              // 📍 만기임박(Expiring) 클릭 시 이동
              _buildClickableSummaryItem(
                  context, Icons.event_available_outlined, "Expiring", "${summary.expiringSoon}", Colors.orange, UnitFilterType.expiring
              ),
              // 수익률 (단순 표시)
              _buildSummaryItem(Icons.trending_up, "Yield", "${summary.averageYield.toStringAsFixed(1)}%", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  // 📍 [신규] 클릭 가능한 요약 아이템 헬퍼
  Widget _buildClickableSummaryItem(BuildContext context, IconData icon, String label, String value, Color color, UnitFilterType type) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UnitFilteredListScreen(filterType: type))
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: _buildSummaryItem(icon, label, value, color),
      ),
    );
  }

  // 📍 요약 항목 빌더 (메서드 부활)
  Widget _buildSummaryItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                            Text(
                              building.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text("Total ${item.units.length} Units",
                                style: const TextStyle(fontSize: 14, color: Colors.white70)),
                          ],
                        ),
                      ),
                      _buildAdminPopupMenu(
                        context,
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
                    Text("Occupancy Status", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    Text("Yield: $yieldVal%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  ],
                ),
                const SizedBox(height: 12),
                if (item.units.isEmpty)
                  _buildEmptyUnitPlaceholder()
                else
                  _buildRoomGrid(context, ref, item.units),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPopupMenu(BuildContext context, {required VoidCallback onEdit, required VoidCallback onDelete}) {
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
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 22, color: Color(0xFF1A237E)),
              SizedBox(width: 12),
              Text("Edit", style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 22, color: Colors.redAccent),
              SizedBox(width: 12),
              Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyUnitPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: Text("No units added yet.\nClick + to add rooms.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
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
      loading: () => _buildBaseRoomContainer(unit, Colors.grey, "로딩 중", null),
      error: (err, _) => _buildBaseRoomContainer(unit, Colors.red, "에러", null),
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
        String statusText = "완납";
        Widget? leaseBadge = _buildLeaseBadge(unit.leaseType);

        if (unit.tenantName == null || unit.tenantName!.isEmpty) {
          statusColor = Colors.grey;
          statusText = "공실";
          leaseBadge = null;
        } else if (myStatus.status == 'OVERDUE' && (unit.leaseType == '월세' || unit.leaseType == '반전세')) {
          statusColor = AppColors.expenseRed;
          statusText = "미납";
        } else {
          bool isExpiring = false;
          if (unit.contractEnd != null) {
            final daysLeft = unit.contractEnd!.difference(DateTime.now()).inDays;
            if (daysLeft >= 0 && daysLeft <= 30) isExpiring = true;
          }

          if (isExpiring) {
            statusColor = Colors.orange;
            statusText = "만기임박";
          } else if (myStatus.status == 'PAID') {
            statusColor = const Color(0xFF1A237E);
            statusText = "완납";
          } else {
            statusColor = AppColors.incomeGreen;
            statusText = unit.leaseType == '전세' ? "전세" : "대기";
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

  Widget? _buildLeaseBadge(String? leaseType) {
    if (leaseType == null || leaseType == '공실') return null;

    Color badgeColor;
    String label;

    switch (leaseType) {
      case '월세':
        badgeColor = const Color(0xFF2196F3);
        label = "월";
        break;
      case '전세':
        badgeColor = const Color(0xFF9C27B0);
        label = "전";
        break;
      case '반전세':
        badgeColor = const Color(0xFFFF9800);
        label = "반";
        break;
      default:
        return null;
    }

    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 2, offset: const Offset(0, 1))]),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.normal, letterSpacing: -0.5)),
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
                Text(unit.roomNumber, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
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
            Padding(padding: const EdgeInsets.all(20), child: Text("${unit.roomNumber}호 퀵 메뉴", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            if (unit.tenantName != null && unit.tenantName!.isNotEmpty) ...[
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white)),
                title: Text("${unit.tenantName}님에게 전화"),
                onTap: () { Navigator.pop(context); _makePhoneCall(unit.tenantPhone ?? ""); },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: isOverdue ? Colors.orange : Colors.blue, child: Icon(isOverdue ? Icons.notification_important : Icons.message, color: Colors.white)),
                title: Text(isOverdue ? "미납 안내 문자 발송" : "문자 메시지 보내기"),
                onTap: () { Navigator.pop(context); if (isOverdue) { _sendRemindSMS(unit, context); } else { _sendSMS(unit.tenantPhone ?? ""); } },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF1A237E), child: Icon(Icons.info_outline, color: Colors.white)),
              title: const Text("상세 정보 보기"),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit))); },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.delete_outline, color: Colors.white)),
              title: const Text("호실 삭제"),
              onTap: () { Navigator.pop(context); _showDeleteUnitConfirm(context, ref, unit); },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 📍 독촉 문자/전화 기능
  Future<void> _sendRemindSMS(Unit unit, BuildContext context) async {
    if (unit.tenantPhone == null || unit.tenantPhone!.isEmpty) return;
    final now = DateTime.now();
    final String message = "[임대료 안내]\n안녕하세요, ${unit.tenantName}님.\n${now.month}월분 임대료(${NumberFormat('#,###').format(unit.monthlyRent)}만원)가 아직 확인되지 않아 연락드립니다.\n\n확인 후 입금 부탁드립니다.\n항상 감사합니다. 😊";
    final String encodedMessage = Uri.encodeComponent(message).replaceAll('+', '%20');
    final String smsUrl = Platform.isAndroid ? "sms:${unit.tenantPhone}?body=$encodedMessage" : "sms:${unit.tenantPhone}&body=$encodedMessage";
    final Uri uri = Uri.parse(smsUrl);
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
    else if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("문자 앱을 실행할 수 없습니다."))); }
  }

  Future<void> _makePhoneCall(String phoneNumber) async { if (phoneNumber.isEmpty) return; final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber); if (await canLaunchUrl(launchUri)) await launchUrl(launchUri); }
  Future<void> _sendSMS(String phoneNumber) async { if (phoneNumber.isEmpty) return; final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber); if (await canLaunchUrl(launchUri)) await launchUrl(launchUri); }

  Future<void> _showDeleteUnitConfirm(BuildContext context, WidgetRef ref, Unit unit) {
    return showDialog(
        context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Text("Delete Unit"), content: Text("Are you sure you want to delete room '${unit.roomNumber}'?"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () async { final db = ref.read(databaseProvider); await (db.delete(db.units)..where((t) => t.id.equals(unit.id))).go(); ref.invalidate(propertyListProvider); if (context.mounted) Navigator.pop(context); }, child: const Text("Delete"))]));
  }

  Future<void> _showDeleteBuildingConfirm(BuildContext context, WidgetRef ref, Building building) {
    return showDialog(
        context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Text("Delete Building"), content: Text("Delete '${building.name}' and all its units?"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () async { final db = ref.read(databaseProvider); await (db.delete(db.buildings)..where((t) => t.id.equals(building.id))).go(); ref.invalidate(propertyListProvider); if (context.mounted) Navigator.pop(context); }, child: const Text("Delete"))]));
  }
}