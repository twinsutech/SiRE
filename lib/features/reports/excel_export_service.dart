import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 WidgetRef 사용을 위해 추가
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/app_database.dart'; // Transaction 모델 사용
import '../ledger/unpaid_provider.dart'; // 📍 UnpaidStatus 모델 사용을 위해 추가

class ExcelExportService {

  // 엑셀 파일 생성 및 공유 함수
  // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
  Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
    final l10n = ref.read(localizationProvider.notifier); // 번역 함수 준비

    // 📍 엑셀 저장 전 데이터를 날짜순(오름차순)으로 정렬하여 장부 가독성 향상
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    // 1. 엑셀 객체 생성
    var excel = Excel.createExcel();

    // 기본 Sheet 이름 변경
    final sheetName = l10n.translate('NAV_LEDGER');
    Sheet sheetObject = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    // 2. 헤더(제목) 줄 만들기 (다국어 적용)
    List<String> headers = [
      l10n.translate('FILTER_EXPIRY_DATE'), // Date
      l10n.translate('PROP_LEASE_TYPE_LABEL'), // Type
      l10n.translate('COMMON_CATEGORY'), // Category
      l10n.translate('COMMON_AMOUNT'), // Amount
      l10n.translate('COMMON_MEMO_HINT'), // Memo
    ];

    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 3. 데이터 한 줄씩 추가하기
    for (var tx in sortedTransactions) {
      final date = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
      // 📍 INC/EXP를 다국어 수입/지출로 변환
      final type = tx.type == 'INC' ? l10n.translate('COMMON_INCOME') : l10n.translate('COMMON_EXPENSE');
      final category = tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category;
      final amount = tx.amount;
      final memo = tx.memo ?? '';

      sheetObject.appendRow([
        TextCellValue(date),
        TextCellValue(type),
        TextCellValue(category),
        IntCellValue(amount),
        TextCellValue(memo),
      ]);
    }

    // 4. 파일로 저장하기
    final directory = await getApplicationDocumentsDirectory();
    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'Tax_Report_$now.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      // 5. 공유하기
      await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_BTN_TAX_EXCEL'));
    }
  }

  // 📍 미납 내역 전용 엑셀 생성 및 공유 함수
  // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
  Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
    final l10n = ref.read(localizationProvider.notifier);

    // 1. 엑셀 객체 생성
    var excel = Excel.createExcel();
    final sheetName = l10n.translate('REPORT_SEC_UNPAID');
    Sheet sheetObject = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    // 2. 헤더 구성 (다국어 적용)
    List<String> headers = [
      l10n.translate('PROP_ROOM_NUMBER_LABEL'), // 호수
      l10n.translate('PROP_TENANT_NAME_LABEL'), // 세입자
      l10n.translate('PROP_PHONE_LABEL'), // 연락처
      l10n.translate('PROP_PAYMENT_STATUS'), // 상태
      '${l10n.translate('STATUS_PAID')} (${l10n.translate('COMMON_AMOUNT')})', // 이번달 입금액
      '${l10n.translate('CAT_RENT')} (${l10n.translate('COMMON_AMOUNT')})', // 월세금액
      l10n.translate('FILTER_EXPIRY_DATE') // 납기일
    ];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 3. 미납 데이터 추가
    for (var unpaid in unpaidList) {
      final roomNo = unpaid.unit.roomNumber;
      final tenant = unpaid.unit.tenantName ?? '-';
      final phone = unpaid.unit.tenantPhone ?? '-';
      final status = unpaid.status == 'OVERDUE' ? l10n.translate('STATUS_OVERDUE') : l10n.translate('STATUS_WAITING');
      final paid = unpaid.paidAmount;
      final monthly = unpaid.unit.monthlyRent;
      final due = DateFormat('yyyy-MM-dd').format(unpaid.dueDate);

      sheetObject.appendRow([
        TextCellValue(roomNo),
        TextCellValue(tenant),
        TextCellValue(phone),
        TextCellValue(status),
        IntCellValue(paid),
        IntCellValue(monthly),
        TextCellValue(due),
      ]);
    }

    // 4. 파일 저장 및 공유 로직 (동일)
    final directory = await getApplicationDocumentsDirectory();
    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'Unpaid_Report_$now.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_SHARE_UNPAID_TEXT'));
    }
  }
}