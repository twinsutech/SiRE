import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/database/database_provider.dart';
import '../ledger/unpaid_provider.dart';
import 'room_detail_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import 'property_provider.dart';
import 'add_building_dialog.dart'; // 📍 분리된 파일 임포트
import 'add_unit_dialog.dart';     // 📍 분리된 파일 임포트

class PropertyScreen extends ConsumerWidget {
  const PropertyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyListAsync = ref.watch(propertyListProvider);

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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: buildingList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) => _buildBuildingCard(context, ref, buildingList[index]),
          );
        },
      ),
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
          // 📍 빌딩 헤더: 다중 이미지 중 첫 번째 이미지를 배경으로 사용
          StreamBuilder<List<BuildingImage>>(
            stream: (db.select(db.buildingImages)..where((t) => t.buildingId.equals(building.id))).watch(),
            builder: (context, snapshot) {
              final images = snapshot.data ?? [];

              // 📍 수정 포인트: 리스트가 비어있는지 먼저 확인 (bad state 방지)
              final bool hasImage = images.isNotEmpty;

              // 대표 이미지 찾기 (isPrimary가 true인 것, 없으면 첫 번째 것)
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
                  // 이미지가 있을 때만 DecorationImage 실행
                  image: hasImage
                      ? DecorationImage(
                    image: FileImage(File(displayImage!.imagePath)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                  )
                      : null,
                  // 이미지가 없을 때만 그라데이션 표시
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

  // 📍 _buildRoomButton 부분을 아래 코드로 교체하세요.
  Widget _buildRoomButton(BuildContext context, WidgetRef ref, Unit unit) {
    // 1. 미납 리스트 프로바이더를 감시합니다.
    final unpaidAsync = ref.watch(unpaidListProvider);

    return unpaidAsync.when(
      loading: () => _buildBaseRoomContainer(unit, Colors.grey, "Loading..."),
      error: (err, _) => _buildBaseRoomContainer(unit, Colors.red, "Error"),
      data: (unpaidList) {
        // 2. 현재 호실의 상태 정보를 찾습니다.
        final myStatus = unpaidList.firstWhere(
              (s) => s.unit.id == unit.id,
          orElse: () => UnpaidStatus(
            unit: unit,
            status: 'WAITING',
            paidAmount: 0,
            dueDate: DateTime.now(),
          ),
        );

        // 3. UI 스타일 결정 로직
        Color statusColor = AppColors.incomeGreen;
        String statusText = unit.leaseType ?? "Paid";

        if (unit.tenantName == null || unit.tenantName!.isEmpty) {
          // 공실 상태
          statusColor = Colors.grey;
          statusText = "Vacant";
        } else if (myStatus.status == 'OVERDUE') {
          // 📍 실시간 미납 상태 (기존 memo 체크 방식보다 우선순위 높음)
          statusColor = AppColors.expenseRed;
          statusText = "Unpaid";
        } else if (myStatus.status == 'PAID') {
          // 완납 상태
          statusColor = AppColors.incomeGreen;
          statusText = "Paid";
        } else {
          // 입금 대기 상태 (WAITING)
          statusColor = AppColors.primaryNavy;
          statusText = unit.leaseType ?? "Waiting";
        }

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit)),
          ),
          onLongPress: () => _showUnitManagementMenu(context, ref, unit),
          child: _buildBaseRoomContainer(unit, statusColor, statusText),
        );
      },
    );
  }

  // 📍 UI 코드를 깔끔하게 유지하기 위한 헬퍼 위젯
  Widget _buildBaseRoomContainer(Unit unit, Color color, String text) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unit.roomNumber,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showUnitManagementMenu(BuildContext context, WidgetRef ref, Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Unit ${unit.roomNumber}"),
        content: const Text("Choose an action for this unit."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(unit: unit)));
            },
            child: const Text("Edit Details", style: TextStyle(color: Color(0xFF1A237E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteUnitConfirm(context, ref, unit);
            },
            child: const Text("Delete Unit", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ],
      ),
    );
  }

  Future<void> _showDeleteUnitConfirm(BuildContext context, WidgetRef ref, Unit unit) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Unit"),
        content: Text("Are you sure you want to delete room '${unit.roomNumber}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(db.units)..where((t) => t.id.equals(unit.id))).go();
              ref.invalidate(propertyListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteBuildingConfirm(BuildContext context, WidgetRef ref, Building building) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Building"),
        content: Text("Delete '${building.name}' and all its units?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(db.buildings)..where((t) => t.id.equals(building.id))).go();
              ref.invalidate(propertyListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
