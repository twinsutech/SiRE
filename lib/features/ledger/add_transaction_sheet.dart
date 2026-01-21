import 'dart:io'; // 📍 File 처리를 위해 추가
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // 📍 영수증 선택을 위해 추가
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_provider.dart';
import '../settings/category_provider.dart';
import 'ledger_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;
  final DateTime? initialDate;

  const AddTransactionSheet({super.key, this.transaction, this.initialDate});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  String _type = 'INC';
  String? _category;
  DateTime _selectedDate = DateTime.now();

  // 📍 다중 영수증 관리를 위한 리스트 (RoomDetailScreen과 동일한 로직)
  final List<String> _newReceiptImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // 📍 수정 핵심: 기존 데이터의 타입을 표준 코드(INC/EXP)로 변환하여 할당
      final existingType = widget.transaction!.type;
      if (existingType == '수입' || existingType == 'INC') {
        _type = 'INC';
      } else {
        _type = 'EXP';
      }

      _amountController.text = widget.transaction!.amount.toString();
      _memoController.text = widget.transaction!.memo ?? '';
      _category = widget.transaction!.category;
      _selectedDate = widget.transaction!.transactionDate;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _type = 'INC';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // 📍 다중 이미지 선택 (갤러리/카메라 소스 선택 포함)
  Future<void> _pickReceiptImages() async {
    final picker = ImagePicker();

    // RoomDetailScreen과 일관성을 위해 다중 선택 기능을 기본으로 사용합니다.
    final List<XFile> selectedFiles = await picker.pickMultiImage(imageQuality: 70);

    if (selectedFiles.isNotEmpty) {
      setState(() {
        _newReceiptImages.addAll(selectedFiles.map((file) => file.path));
      });
    }
  }

  // 📍 [요청사항] 확대 기능이 포함된 전체 화면 뷰어 (RoomDetailScreen 일관성 유지)
  void _showFullScreenImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 📍 InteractiveViewer를 통해 확대/축소 가능
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(File(path)),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = _type == 'INC';
    final Color themeColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final bool isEdit = widget.transaction != null;

    final categoriesAsync = ref.watch(categoryListProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), color: Colors.grey[300]),
            Text(isEdit ? "Edit Record" : "New Record", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 수입/지출 선택 탭
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildTypeButton("INC", "Income", isIncome ? AppColors.incomeGreen : Colors.transparent, isIncome ? Colors.white : Colors.grey),
                  _buildTypeButton("EXP", "Expense", !isIncome ? AppColors.expenseRed : Colors.transparent, !isIncome ? Colors.white : Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 날짜 선택
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: themeColor)),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('yyyy-MM-dd (EEEE)').format(_selectedDate)),
                    Icon(Icons.calendar_today, size: 20, color: themeColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 📍 카테고리 드롭다운
            categoriesAsync.when(
              data: (categories) {
                final filtered = categories.where((c) {
                  final dbType = c.type.toUpperCase();
                  if (_type == 'INC') {
                    return dbType == 'INC' || dbType == 'INCOME';
                  } else {
                    return dbType == 'EXP' || dbType == 'EXPENSE';
                  }
                }).toList();

                return DropdownButtonFormField<String>(
                  value: filtered.any((c) => c.name == _category) ? _category : null,
                  isExpanded: true,
                  hint: const Text("Select Category"),
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: Icon(Icons.category, color: themeColor),
                    border: const OutlineInputBorder(),
                  ),
                  items: filtered.map((c) => DropdownMenuItem(
                      value: c.name,
                      child: Text(c.name)
                  )).toList(),
                  onChanged: (val) => setState(() => _category = val),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, __) => Text("Error: $err"),
            ),
            const SizedBox(height: 15),

            // 금액 입력
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Amount",
                prefixIcon: Icon(Icons.attach_money, color: themeColor),
                suffixText: "만",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 메모 입력
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: "Memo (Optional)",
                prefixIcon: Icon(Icons.edit_note, color: themeColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 📍 다중 영수증 갤러리 섹션 (RoomDetailScreen과 동일한 구조)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Receipt Gallery", style: TextStyle(color: Colors.grey, fontSize: 14)),
                TextButton.icon(
                  onPressed: _pickReceiptImages,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text("Add Photo"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMultiReceiptGallery(),
            const SizedBox(height: 25),

            // 하단 버튼
            Row(
              children: [
                if (isEdit)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => _deleteTransaction(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Icon(Icons.delete_outline),
                    ),
                  ),
                if (isEdit) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _saveTransaction(context),
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(isEdit ? "Update Changes" : "Add Transaction", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 📍 다중 영수증 갤러리 위젯 (RoomDetailScreen 일관성 유지)
  Widget _buildMultiReceiptGallery() {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<TransactionImage>>(
      stream: widget.transaction == null
          ? Stream.value([])
          : (db.select(db.transactionImages)..where((t) => t.transactionId.equals(widget.transaction!.id))).watch(),
      builder: (context, snapshot) {
        final savedImages = snapshot.data ?? [];
        if (savedImages.isEmpty && _newReceiptImages.isEmpty) {
          return Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: const Center(child: Text("No receipts attached", style: TextStyle(color: Colors.grey, fontSize: 12))),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 1. 새로 추가한 이미지들 (임시 상태)
              ..._newReceiptImages.asMap().entries.map((entry) {
                return _buildImageThumbnail(
                  entry.value,
                  onDelete: () => setState(() => _newReceiptImages.removeAt(entry.key)),
                );
              }),
              // 2. 이미 DB에 저장된 이미지들
              ...savedImages.map((img) {
                return _buildImageThumbnail(
                  img.imagePath,
                  onDelete: () async {
                    await (db.delete(db.transactionImages)..where((t) => t.id.equals(img.id))).go();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // 📍 이미지 썸네일 아이템 빌더
  Widget _buildImageThumbnail(String path, {required VoidCallback onDelete}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showFullScreenImage(context, path),
          child: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 17,
          child: GestureDetector(
            onTap: onDelete,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black87,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, String label, Color bgColor, Color textColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _type = type; _category = null; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }


  Future<void> _saveTransaction(BuildContext context) async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check amount and category."), backgroundColor: Colors.orange));
      return;
    }

    final db = ref.read(databaseProvider);
    int transactionId;

    try {
      if (widget.transaction == null) {
        // 📍 [신규 저장]
        transactionId = await db.into(db.transactions).insert(TransactionsCompanion.insert(
          buildingId: 1,
          type: _type,
          amount: amount,
          transactionDate: _selectedDate,
          category: _category!,
          memo: Value(_memoController.text),
          // 📍 기존 단일 영수증 컬럼은 이제 사용하지 않으므로 absent 처리하거나 null 허용
          receiptImagePath: const Value.absent(),
        ));
      } else {
        // 📍 [수정]
        transactionId = widget.transaction!.id;
        await (db.update(db.transactions)..where((t) => t.id.equals(transactionId))).write(
          TransactionsCompanion(
            type: Value(_type),
            amount: Value(amount),
            transactionDate: Value(_selectedDate),
            category: Value(_category!),
            memo: Value(_memoController.text),
            // 수정 시에도 기존 단일 컬럼은 건드리지 않음
          ),
        );
      }

      // 📍 [다중 이미지 저장] 신규 리스트에 있는 파일들을 TransactionImages 테이블에 인서트
      if (_newReceiptImages.isNotEmpty) {
        for (var path in _newReceiptImages) {
          await db.into(db.transactionImages).insert(
            TransactionImagesCompanion.insert(
              transactionId: transactionId,
              imagePath: path,
            ),
          );
        }
      }

      // 📍 모든 상태 무효화 (실시간 반영의 핵심)
      ref.invalidate(ledgerListProvider);
      ref.invalidate(ledgerSummaryProvider);
      ref.invalidate(dashboardDataProvider);

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      // 에러 발생 시 사용자에게 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: $e"), backgroundColor: Colors.red));
      }
    }
  }


  Future<void> _deleteTransaction(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Delete this record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await (db.delete(db.transactions)..where((t) => t.id.equals(widget.transaction!.id))).go();
      ref.invalidate(ledgerListProvider);
      ref.invalidate(ledgerSummaryProvider);
      ref.invalidate(dashboardDataProvider);
      Navigator.pop(context);
    }
  }
}