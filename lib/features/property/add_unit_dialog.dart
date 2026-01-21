import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'property_provider.dart';

class AddUnitDialog extends ConsumerStatefulWidget {
  final int buildingId;
  const AddUnitDialog({super.key, required this.buildingId});

  @override
  ConsumerState<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends ConsumerState<AddUnitDialog> {
  final _roomController = TextEditingController();
  final _tenantNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _depositController = TextEditingController(text: '0');
  final _rentController = TextEditingController(text: '0');
  final _paymentDayController = TextEditingController();
  final _memoController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedLeaseType = '공실';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _roomController.dispose();
    _tenantNameController.dispose();
    _phoneController.dispose();
    _depositController.dispose();
    _rentController.dispose();
    _paymentDayController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("신규 호실 등록", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("현장 사진", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildPhotoGallery(),
                const SizedBox(height: 24),
                _buildTextField(_roomController, "호수"),
                const SizedBox(height: 20),
                _buildLeaseTypeToggle(),
                if (_selectedLeaseType != '공실') ...[
                  const SizedBox(height: 20),
                  _buildTextField(_tenantNameController, "세입자 성함"),
                  const SizedBox(height: 12),
                  _buildTextField(_phoneController, "연락처", isNumber: true),
                  const SizedBox(height: 12),
                  _buildTextField(_depositController, "보증금 (만원)", isNumber: true),
                  if (_selectedLeaseType == '월세' || _selectedLeaseType == '반전세') ...[
                    const SizedBox(height: 12),
                    _buildTextField(_rentController, "월세 (만원)", isNumber: true),
                    const SizedBox(height: 12),
                    _buildTextField(_paymentDayController, "납입 예정일", isNumber: true),
                  ],
                  const SizedBox(height: 20),
                  _buildDateSection(),
                ],
                const SizedBox(height: 20),
                _buildTextField(_memoController, "메모", maxLines: 2),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
        ElevatedButton(
          onPressed: _saveUnit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, minimumSize: const Size(100, 45)),
          child: const Text("호실 추가"),
        ),
      ],
    );
  }

  // 일관된 디자인을 위한 헬퍼 위젯들
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    );
  }

  Widget _buildLeaseTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("계약 유형", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          return ToggleButtons(
            isSelected: ['월세', '전세', '반전세', '공실'].map((e) => _selectedLeaseType == e).toList(),
            onPressed: (index) => setState(() => _selectedLeaseType = ['월세', '전세', '반전세', '공실'][index]),
            borderRadius: BorderRadius.circular(8),
            constraints: BoxConstraints(minWidth: (constraints.maxWidth - 5) / 4, minHeight: 45),
            children: const [Text('월세'), Text('전세'), Text('반전세'), Text('공실')],
          );
        }),
      ],
    );
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: () => _selectDate(context, true), child: Text(_startDate == null ? '시작일' : DateFormat('yy-MM-dd').format(_startDate!)))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('~')),
        Expanded(child: OutlinedButton(onPressed: () => _selectDate(context, false), child: Text(_endDate == null ? '종료일' : DateFormat('yy-MM-dd').format(_endDate!)))),
      ],
    );
  }

  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: () async {
                final picked = await _picker.pickMultiImage(imageQuality: 70);
                if (picked.isNotEmpty) setState(() => _selectedImages.addAll(picked));
              },
              child: Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)), child: const Icon(Icons.add_a_photo, color: Colors.grey)),
            );
          }
          return Stack(
            children: [
              Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(File(_selectedImages[index].path)), fit: BoxFit.cover))),
              Positioned(top: 4, right: 12, child: GestureDetector(onTap: () => setState(() => _selectedImages.removeAt(index)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)))),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveUnit() async {
    if (_roomController.text.isEmpty) return;
    final db = ref.read(databaseProvider);
    final unitId = await db.into(db.units).insert(UnitsCompanion.insert(
      buildingId: widget.buildingId,
      roomNumber: _roomController.text,
      leaseType: Value(_selectedLeaseType),
      tenantName: Value(_tenantNameController.text),
      tenantPhone: Value(_phoneController.text),
      deposit: Value(int.tryParse(_depositController.text) ?? 0),
      monthlyRent: Value(int.tryParse(_rentController.text) ?? 0),
      paymentDay: Value(int.tryParse(_paymentDayController.text)),
      contractStart: Value(_startDate),
      contractEnd: Value(_endDate),
      memo: Value(_memoController.text),
    ));
    for (var image in _selectedImages) {
      await db.into(db.unitImages).insert(UnitImagesCompanion.insert(unitId: unitId, imagePath: image.path));
    }
    ref.invalidate(propertyListProvider);
    if (mounted) Navigator.pop(context);
  }
}