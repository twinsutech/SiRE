import 'dart:io'; // 📍 File 처리를 위해 추가
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // 📍 영수증 선택을 위해 추가

import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_provider.dart';
import '../settings/category_provider.dart';
import '../property/property_provider.dart'; // 📍 건물 리스트 갱신을 위해 추가
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

      // 📍 [수정] 초기 금액 표시 시 현재 로케일 포맷 적용
      final currentLang = ref.read(localizationProvider.notifier).currentLang;
      final formatter = NumberFormat.decimalPattern(currentLang);
      _amountController.text = formatter.format(widget.transaction!.amount);

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
    final List<XFile> selectedFiles = await picker.pickMultiImage(imageQuality: 70);

    if (selectedFiles.isNotEmpty) {
      HapticFeedback.mediumImpact(); // 📍 선택 시 피드백
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
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    final categoriesAsync = ref.watch(categoryListProvider);

    // 📍 [추가] 현재 국가의 통화 심볼 파악 ($ 또는 ₩ 등)
    final currencyFormat = NumberFormat.simpleCurrency(locale: currentLang);
    final String currencySymbol = currencyFormat.currencySymbol;

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
            Text(
                isEdit ? "COMMON_EDIT_RECORD".tr(ref) : "COMMON_NEW_RECORD".tr(ref),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),

            // 수입/지출 선택 탭
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildTypeButton("INC", "COMMON_INCOME".tr(ref), isIncome ? AppColors.incomeGreen : Colors.transparent, isIncome ? Colors.white : Colors.grey),
                  _buildTypeButton("EXP", "COMMON_EXPENSE".tr(ref), !isIncome ? AppColors.expenseRed : Colors.transparent, !isIncome ? Colors.white : Colors.grey),
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
                  locale: Locale(currentLang), // 📍 달력 언어 설정
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: themeColor)),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 📍 요일까지 포함된 현지화 날짜 포맷
                    Text(DateFormat.yMMMEd(currentLang).format(_selectedDate)),
                    Icon(Icons.calendar_today, size: 20, color: themeColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 📍 [핵심 수정] 카테고리 드롭다운 (다국어 실시간 대응)
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
                  hint: Text("LEDGER_SELECT_CATEGORY".tr(ref)),
                  decoration: InputDecoration(
                    labelText: "COMMON_CATEGORY".tr(ref),
                    prefixIcon: Icon(Icons.category, color: themeColor),
                    border: const OutlineInputBorder(),
                  ),
                  items: filtered.map((c) => DropdownMenuItem(
                      value: c.name,
                      // 📍 [핵심] 카테고리명이 키(CAT_...)인 경우 .tr(ref)를 호출하여 언어 설정에 맞게 실시간 번역
                      child: Text(
                        c.name.startsWith('CAT_')
                            ? c.name.tr(ref)
                            : c.name,
                        style: const TextStyle(fontSize: 15),
                      )
                  )).toList(),
                  onChanged: (val) => setState(() => _category = val),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, __) => Text("Error: $err"),
            ),
            const SizedBox(height: 15),

            // 📍 [금액 입력 UX 최적화 및 버그 수정]
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                CurrencyInputFormatter(locale: currentLang),
              ],
              decoration: InputDecoration(
                labelText: "COMMON_AMOUNT".tr(ref),
                // 📍 [수정] 통화 심볼을 왼쪽에 명확하게 표시
                prefixIcon: Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Text(currencySymbol, style: TextStyle(color: themeColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                // 📍 [해결] 오른쪽의 중복된 'W' 단위를 제거하여 영어 모드에서도 어색하지 않게 수정
                suffixText: null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 메모 입력
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: "COMMON_MEMO_HINT".tr(ref),
                prefixIcon: Icon(Icons.edit_note, color: themeColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 📍 다중 영수증 갤러리 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("COMMON_RECEIPT_GALLERY".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                TextButton.icon(
                  onPressed: _pickReceiptImages,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: Text("COMMON_ADD_PHOTO".tr(ref)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMultiReceiptGallery(ref),
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
                    child: Text(
                        isEdit ? "COMMON_UPDATE_CHANGES".tr(ref) : "COMMON_ADD_RECORD".tr(ref),
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiReceiptGallery(WidgetRef ref) {
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
            child: Center(child: Text("LEDGER_NO_RECEIPTS".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 12))),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._newReceiptImages.asMap().entries.map((entry) {
                return _buildImageThumbnail(
                  entry.value,
                  onDelete: () => setState(() => _newReceiptImages.removeAt(entry.key)),
                );
              }),
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
            onTap: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
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
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() { _type = type; _category = null; });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Future<void> _saveTransaction(BuildContext context) async {
    // 📍 [수정] 콤마가 포함된 문자열을 다시 숫자로 정규화하여 추출
    final rawAmountText = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = (double.tryParse(rawAmountText) ?? 0).toInt();

    if (amount <= 0 || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_CHECK_AMOUNT_CATEGORY".tr(ref)), backgroundColor: Colors.orange));
      return;
    }

    final db = ref.read(databaseProvider);
    int transactionId;

    try {
      final buildingList = await db.select(db.buildings).get();
      int targetBuildingId;

      if (buildingList.isEmpty) {
        targetBuildingId = await db.into(db.buildings).insert(
          BuildingsCompanion.insert(
            name: 'COMMON_BUILDING_NAME'.tr(ref),
            address: const Value('System Generated'),
          ),
        );
        ref.invalidate(propertyListProvider);
      } else {
        targetBuildingId = buildingList.first.id;
      }

      if (widget.transaction == null) {
        transactionId = await db.into(db.transactions).insert(TransactionsCompanion.insert(
          buildingId: targetBuildingId,
          type: _type,
          amount: amount,
          transactionDate: _selectedDate,
          category: _category!,
          memo: Value(_memoController.text),
          receiptImagePath: const Value.absent(),
        ));
      } else {
        transactionId = widget.transaction!.id;
        await (db.update(db.transactions)..where((t) => t.id.equals(transactionId))).write(
          TransactionsCompanion(
            type: Value(_type),
            amount: Value(amount),
            transactionDate: Value(_selectedDate),
            category: Value(_category!),
            memo: Value(_memoController.text),
          ),
        );
      }

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

      ref.invalidate(ledgerListProvider);
      ref.invalidate(ledgerSummaryProvider);
      ref.invalidate(dashboardDataProvider);

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${"ERROR_SAVE_FAILED".tr(ref)}: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("COMMON_DELETE".tr(ref)),
        content: Text("DIALOG_DELETE_TRANSACTION_DESC".tr(ref)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("COMMON_CANCEL".tr(ref))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("COMMON_DELETE".tr(ref), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await (db.delete(db.transactions)..where((t) => t.id.equals(widget.transaction!.id))).go();
      ref.invalidate(ledgerListProvider);
      ref.invalidate(ledgerSummaryProvider);
      ref.invalidate(dashboardDataProvider);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// 📍 [핵심 클래스] 통화 입력 포매터
class CurrencyInputFormatter extends TextInputFormatter {
  final String locale;
  CurrencyInputFormatter({required this.locale});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // 1. 숫자 이외의 문자 제거 (소수점 유지)
    String rawValue = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // 2. 숫자로 변환
    double? value = double.tryParse(rawValue);
    if (value == null) return oldValue;

    // 3. 로케일별 포맷 적용 (자동 콤마)
    final formatter = NumberFormat.decimalPattern(locale);
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}