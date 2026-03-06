import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 📍 숫자 입력 제한을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // 📍 화폐 심볼 추출을 위해 추가
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
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
  late TextEditingController _priceController; // 📍 매입가 컨트롤러 추가

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
      text: widget.building?.purchasePrice != null ? widget.building!.purchasePrice!.toInt().toString() : "",
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
      HapticFeedback.mediumImpact(); // 📍 이미지 선택 시 피드백
      setState(() => _selectedImages.addAll(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.building != null;
    final db = ref.watch(databaseProvider);

    // 📍 [화폐 다국어 처리] 현재 언어 설정에 따른 통화 심볼 및 위치 정보 추출
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    final currencyFormat = NumberFormat.simpleCurrency(locale: currentLang);
    final String currencySymbol = currencyFormat.currencySymbol;

    // 심볼이 앞에 붙는 언어(영어 등)인지 확인
    final bool isSymbolPrefix = currentLang.startsWith('en');

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEdit ? "PROP_EDIT_BUILDING".tr(ref) : "PROP_ADD_BUILDING".tr(ref),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PROP_PHOTO_HINT".tr(ref),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              SizedBox(height: 110, child: _buildPhotoGallery(db)),
              const SizedBox(height: 16),
              // 📍 빌딩 이름 입력
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "PROP_NAME_LABEL".tr(ref),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.apartment),
                ),
              ),
              const SizedBox(height: 12),
              // 📍 주소 입력 필드 추가
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "PROP_ADDRESS_LABEL".tr(ref),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              // 📍 매입가 입력 필드 추가 (수익률 계산의 핵심)
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number, // 숫자 패드 노출
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 허용
                decoration: InputDecoration(
                  labelText: "PROP_PRICE_LABEL".tr(ref),
                  hintText: "PROP_PRICE_HINT".tr(ref),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  // 📍 국가별 통화 관습에 따라 심볼 위치 유동적 배치
                  prefixText: isSymbolPrefix ? currencySymbol : null,
                  suffixText: !isSymbolPrefix ? currencySymbol : null,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "COMMON_CANCEL".tr(ref),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ElevatedButton(
          onPressed: _saveBuilding,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
          child: Text(
            isEdit ? "COMMON_SAVE".tr(ref) : "COMMON_CONFIRM".tr(ref),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
                  HapticFeedback.selectionClick();
                  await (db.update(db.buildingImages)..where((t) => t.buildingId.equals(widget.building!.id)))
                      .write(const BuildingImagesCompanion(isPrimary: Value(false)));
                  await (db.update(db.buildingImages)..where((t) => t.id.equals(img.id)))
                      .write(const BuildingImagesCompanion(isPrimary: Value(true)));
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
              onSetPrimary: () {
                HapticFeedback.selectionClick();
                setState(() => _primaryIndex = newImgIndex);
              },
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
        width: 90,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Icon(Icons.add_a_photo, color: Colors.grey),
      ),
    );
  }

  Widget _buildPhotoItem(
      String path, {
        required bool isPrimary,
        required VoidCallback onDelete,
        VoidCallback? onSetPrimary,
      }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onSetPrimary,
          child: Container(
            width: 90,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isPrimary ? Border.all(color: Colors.amber, width: 3) : null,
              image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
            ),
          ),
        ),
        if (isPrimary) const Positioned(bottom: 4, left: 4, child: Icon(Icons.star, color: Colors.amber, size: 20)),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onDelete,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
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

    try {
      if (widget.building != null) {
        buildingId = widget.building!.id;
        // 📍 수정 모드: 이름, 주소, 매입가 업데이트
        await (db.update(db.buildings)..where((t) => t.id.equals(buildingId))).write(
          BuildingsCompanion(
            name: Value(name),
            address: Value(address),
            purchasePrice: Value(price),
          ),
        );
      } else {
        // 📍 신규 생성: 매입가와 주소 포함하여 저장
        buildingId = await db.into(db.buildings).insert(
          BuildingsCompanion.insert(
            name: name,
            address: Value(address),
            purchasePrice: Value(price),
          ),
        );
      }

      for (int i = 0; i < _selectedImages.length; i++) {
        await db.into(db.buildingImages).insert(
          BuildingImagesCompanion.insert(
            buildingId: buildingId,
            imagePath: _selectedImages[i].path,
            isPrimary: Value(i == _primaryIndex),
          ),
        );
      }
      ref.invalidate(propertyListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${"ERROR_SAVE_FAILED".tr(ref)}: $e")));
      }
    }
  }
}
