import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 📍 숫자 입력 제한을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'property_provider.dart';

class AddBuildingDialog extends ConsumerStatefulWidget {
  final Building? building;
  const AddBuildingDialog({super.key, this.building});

  @override
  ConsumerState<AddBuildingDialog> createState() => _AddBuildingDialogState();
}

class _AddBuildingDialogState extends ConsumerState<AddBuildingDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController; // 📍 주소 컨트롤러 추가
  late TextEditingController _priceController;   // 📍 매입가 컨트롤러 추가

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  int _primaryIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.building?.name);
    _addressController = TextEditingController(text: widget.building?.address);
    // 매입가가 있으면 문자열로 변환하여 표시
    _priceController = TextEditingController(
        text: widget.building?.purchasePrice != null
            ? widget.building!.purchasePrice!.toInt().toString()
            : ""
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() => _selectedImages.addAll(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.building != null;
    final db = ref.watch(databaseProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? "Edit Building" : "New Building"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Photos (Tap to set Primary)", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(height: 110, child: _buildPhotoGallery(db)),
              const SizedBox(height: 16),
              // 📍 빌딩 이름 입력
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Building Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment),
                ),
              ),
              const SizedBox(height: 12),
              // 📍 주소 입력 필드 추가
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              // 📍 매입가 입력 필드 추가 (수익률 계산의 핵심)
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number, // 숫자 패드 노출
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 허용
                decoration: const InputDecoration(
                  labelText: "Purchase Price",
                  hintText: "Enter amount",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  suffixText: "KRW",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _saveBuilding,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
          child: Text(isEdit ? "Save" : "Create"),
        ),
      ],
    );
  }

  Widget _buildPhotoGallery(AppDatabase db) {
    return StreamBuilder<List<BuildingImage>>(
      stream: widget.building == null
          ? Stream.value([])
          : (db.select(db.buildingImages)..where((t) => t.buildingId.equals(widget.building!.id))).watch(),
      builder: (context, snapshot) {
        final existingImages = snapshot.data ?? [];
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: existingImages.length + _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == existingImages.length + _selectedImages.length) {
              return _buildAddButton();
            }
            if (index < existingImages.length) {
              final img = existingImages[index];
              return _buildPhotoItem(
                img.imagePath,
                isPrimary: img.isPrimary,
                onDelete: () async => await (db.delete(db.buildingImages)..where((t) => t.id.equals(img.id))).go(),
                onSetPrimary: () async {
                  await (db.update(db.buildingImages)..where((t) => t.buildingId.equals(widget.building!.id))).write(const BuildingImagesCompanion(isPrimary: Value(false)));
                  await (db.update(db.buildingImages)..where((t) => t.id.equals(img.id))).write(const BuildingImagesCompanion(isPrimary: Value(true)));
                },
              );
            }
            final newImgIndex = index - existingImages.length;
            return _buildPhotoItem(
              _selectedImages[newImgIndex].path,
              isPrimary: newImgIndex == _primaryIndex,
              onDelete: () => setState(() {
                _selectedImages.removeAt(newImgIndex);
                if (_primaryIndex >= _selectedImages.length) _primaryIndex = 0;
              }),
              onSetPrimary: () => setState(() => _primaryIndex = newImgIndex),
            );
          },
        );
      },
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 90, margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
        child: const Icon(Icons.add_a_photo, color: Colors.grey),
      ),
    );
  }

  Widget _buildPhotoItem(String path, {required bool isPrimary, required VoidCallback onDelete, VoidCallback? onSetPrimary}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onSetPrimary,
          child: Container(
            width: 90, margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isPrimary ? Border.all(color: Colors.amber, width: 3) : null,
              image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
            ),
          ),
        ),
        if (isPrimary) const Positioned(bottom: 4, left: 4, child: Icon(Icons.star, color: Colors.amber, size: 20)),
        Positioned(
          top: 4, right: 12,
          child: GestureDetector(
            onTap: onDelete,
            child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _saveBuilding() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (name.isEmpty) return;
    final db = ref.read(databaseProvider);
    int buildingId;

    if (widget.building != null) {
      buildingId = widget.building!.id;
      // 📍 수정 모드: 이름, 주소, 매입가 업데이트
      await (db.update(db.buildings)..where((t) => t.id.equals(buildingId))).write(
          BuildingsCompanion(
            name: Value(name),
            address: Value(address),
            purchasePrice: Value(price),
          )
      );
    } else {
      // 📍 신규 생성: 매입가와 주소 포함하여 저장
      buildingId = await db.into(db.buildings).insert(
          BuildingsCompanion.insert(
            name: name,
            address: Value(address),
            purchasePrice: Value(price),
          )
      );
    }

    for (int i = 0; i < _selectedImages.length; i++) {
      await db.into(db.buildingImages).insert(BuildingImagesCompanion.insert(
        buildingId: buildingId, imagePath: _selectedImages[i].path, isPrimary: Value(i == _primaryIndex),
      ));
    }
    ref.invalidate(propertyListProvider);
    if (mounted) Navigator.pop(context);
  }
}