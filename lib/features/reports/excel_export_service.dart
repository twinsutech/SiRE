// // // // // // // // // import 'dart:io';
// // // // // // // // // import 'package:excel/excel.dart';
// // // // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 WidgetRef 사용을 위해 추가
// // // // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // // // import 'package:intl/intl.dart';
// // // // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // // // import '../../core/database/app_database.dart'; // Transaction 모델 사용
// // // // // // // // // import '../ledger/unpaid_provider.dart'; // 📍 UnpaidStatus 모델 사용을 위해 추가
// // // // // // // // //
// // // // // // // // // class ExcelExportService {
// // // // // // // // //
// // // // // // // // //   // 엑셀 파일 생성 및 공유 함수
// // // // // // // // //   // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
// // // // // // // // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // // // // // // // //     final l10n = ref.read(localizationProvider.notifier); // 번역 함수 준비
// // // // // // // // //
// // // // // // // // //     // 📍 엑셀 저장 전 데이터를 날짜순(오름차순)으로 정렬하여 장부 가독성 향상
// // // // // // // // //     final sortedTransactions = List<Transaction>.from(transactions)
// // // // // // // // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // // // // // // // //
// // // // // // // // //     // 1. 엑셀 객체 생성
// // // // // // // // //     var excel = Excel.createExcel();
// // // // // // // // //
// // // // // // // // //     // 기본 Sheet 이름 변경
// // // // // // // // //     final sheetName = l10n.translate('NAV_LEDGER');
// // // // // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // // // // //     excel.setDefaultSheet(sheetName);
// // // // // // // // //
// // // // // // // // //     // 2. 헤더(제목) 줄 만들기 (다국어 적용)
// // // // // // // // //     List<String> headers = [
// // // // // // // // //       l10n.translate('FILTER_EXPIRY_DATE'), // Date
// // // // // // // // //       l10n.translate('PROP_LEASE_TYPE_LABEL'), // Type
// // // // // // // // //       l10n.translate('COMMON_CATEGORY'), // Category
// // // // // // // // //       l10n.translate('COMMON_AMOUNT'), // Amount
// // // // // // // // //       l10n.translate('COMMON_MEMO_HINT'), // Memo
// // // // // // // // //     ];
// // // // // // // // //
// // // // // // // // //     sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
// // // // // // // // //
// // // // // // // // //     // 3. 데이터 한 줄씩 추가하기
// // // // // // // // //     for (var tx in sortedTransactions) {
// // // // // // // // //       final date = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
// // // // // // // // //       // 📍 INC/EXP를 다국어 수입/지출로 변환
// // // // // // // // //       final type = tx.type == 'INC' ? l10n.translate('COMMON_INCOME') : l10n.translate('COMMON_EXPENSE');
// // // // // // // // //       final category = tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category;
// // // // // // // // //       final amount = tx.amount;
// // // // // // // // //       final memo = tx.memo ?? '';
// // // // // // // // //
// // // // // // // // //       sheetObject.appendRow([
// // // // // // // // //         TextCellValue(date),
// // // // // // // // //         TextCellValue(type),
// // // // // // // // //         TextCellValue(category),
// // // // // // // // //         IntCellValue(amount),
// // // // // // // // //         TextCellValue(memo),
// // // // // // // // //       ]);
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 4. 파일로 저장하기
// // // // // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // // // // //     final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
// // // // // // // // //     final fileName = 'Tax_Report_$now.xlsx';
// // // // // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // // // // //
// // // // // // // // //     final fileBytes = excel.save();
// // // // // // // // //     if (fileBytes != null) {
// // // // // // // // //       File(filePath)
// // // // // // // // //         ..createSync(recursive: true)
// // // // // // // // //         ..writeAsBytesSync(fileBytes);
// // // // // // // // //
// // // // // // // // //       // 5. 공유하기
// // // // // // // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_BTN_TAX_EXCEL'));
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   // 📍 미납 내역 전용 엑셀 생성 및 공유 함수
// // // // // // // // //   // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
// // // // // // // // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // // // // // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // // // // // //
// // // // // // // // //     // 1. 엑셀 객체 생성
// // // // // // // // //     var excel = Excel.createExcel();
// // // // // // // // //     final sheetName = l10n.translate('REPORT_SEC_UNPAID');
// // // // // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // // // // //     excel.setDefaultSheet(sheetName);
// // // // // // // // //
// // // // // // // // //     // 2. 헤더 구성 (다국어 적용)
// // // // // // // // //     List<String> headers = [
// // // // // // // // //       l10n.translate('PROP_ROOM_NUMBER_LABEL'), // 호수
// // // // // // // // //       l10n.translate('PROP_TENANT_NAME_LABEL'), // 세입자
// // // // // // // // //       l10n.translate('PROP_PHONE_LABEL'), // 연락처
// // // // // // // // //       l10n.translate('PROP_PAYMENT_STATUS'), // 상태
// // // // // // // // //       '${l10n.translate('STATUS_PAID')} (${l10n.translate('COMMON_AMOUNT')})', // 이번달 입금액
// // // // // // // // //       '${l10n.translate('CAT_RENT')} (${l10n.translate('COMMON_AMOUNT')})', // 월세금액
// // // // // // // // //       l10n.translate('FILTER_EXPIRY_DATE') // 납기일
// // // // // // // // //     ];
// // // // // // // // //     sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
// // // // // // // // //
// // // // // // // // //     // 3. 미납 데이터 추가
// // // // // // // // //     for (var unpaid in unpaidList) {
// // // // // // // // //       final roomNo = unpaid.unit.roomNumber;
// // // // // // // // //       final tenant = unpaid.unit.tenantName ?? '-';
// // // // // // // // //       final phone = unpaid.unit.tenantPhone ?? '-';
// // // // // // // // //       final status = unpaid.status == 'OVERDUE' ? l10n.translate('STATUS_OVERDUE') : l10n.translate('STATUS_WAITING');
// // // // // // // // //       final paid = unpaid.paidAmount;
// // // // // // // // //       final monthly = unpaid.unit.monthlyRent;
// // // // // // // // //       final due = DateFormat('yyyy-MM-dd').format(unpaid.dueDate);
// // // // // // // // //
// // // // // // // // //       sheetObject.appendRow([
// // // // // // // // //         TextCellValue(roomNo),
// // // // // // // // //         TextCellValue(tenant),
// // // // // // // // //         TextCellValue(phone),
// // // // // // // // //         TextCellValue(status),
// // // // // // // // //         IntCellValue(paid),
// // // // // // // // //         IntCellValue(monthly),
// // // // // // // // //         TextCellValue(due),
// // // // // // // // //       ]);
// // // // // // // // //     }
// // // // // // // // //
// // // // // // // // //     // 4. 파일 저장 및 공유 로직 (동일)
// // // // // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // // // // //     final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
// // // // // // // // //     final fileName = 'Unpaid_Report_$now.xlsx';
// // // // // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // // // // //
// // // // // // // // //     final fileBytes = excel.save();
// // // // // // // // //     if (fileBytes != null) {
// // // // // // // // //       File(filePath)
// // // // // // // // //         ..createSync(recursive: true)
// // // // // // // // //         ..writeAsBytesSync(fileBytes);
// // // // // // // // //
// // // // // // // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_SHARE_UNPAID_TEXT'));
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // //
// // // // // // // //
// // // // // // // // import 'dart:io';
// // // // // // // // import 'package:excel/excel.dart';
// // // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 WidgetRef 사용을 위해 추가
// // // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // // import 'package:intl/intl.dart';
// // // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // // import '../../core/database/app_database.dart'; // Transaction 모델 사용
// // // // // // // // import '../ledger/unpaid_provider.dart'; // 📍 UnpaidStatus 모델 사용을 위해 추가
// // // // // // // //
// // // // // // // // class ExcelExportService {
// // // // // // // //
// // // // // // // //   // 📍 전문적인 리포트 스타일 정의 (헤더용)
// // // // // // // //   CellStyle _getHeaderStyle() {
// // // // // // // //     return CellStyle(
// // // // // // // //       // 📍 [수정] String 대신 ExcelColor.fromHexString 사용
// // // // // // // //       backgroundColorHex: ExcelColor.fromHexString("#1A237E"), // SiRE 메인 인디고 컬러
// // // // // // // //       fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
// // // // // // // //       bold: true,
// // // // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // 📍 데이터 셀 스타일 정의
// // // // // // // //   CellStyle _getDataStyle() {
// // // // // // // //     return CellStyle(
// // // // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // 엑셀 파일 생성 및 공유 함수 (세무 신고용 장부 추출)
// // // // // // // //   // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
// // // // // // // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // // // // // // //     final l10n = ref.read(localizationProvider.notifier); // 번역 함수 준비
// // // // // // // //
// // // // // // // //     // 📍 엑셀 저장 전 데이터를 날짜순(오름차순)으로 정렬하여 장부 가독성 향상
// // // // // // // //     final sortedTransactions = List<Transaction>.from(transactions)
// // // // // // // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // // // // // // //
// // // // // // // //     // 1. 엑셀 객체 생성
// // // // // // // //     var excel = Excel.createExcel();
// // // // // // // //
// // // // // // // //     // 기본 Sheet 이름 변경
// // // // // // // //     final sheetName = l10n.translate('NAV_LEDGER');
// // // // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // // // //     excel.setDefaultSheet(sheetName);
// // // // // // // //
// // // // // // // //     // 📍 열 너비 설정 (가독성 향상)
// // // // // // // //     sheetObject.setColumnWidth(0, 15); // 날짜
// // // // // // // //     sheetObject.setColumnWidth(1, 10); // 유형
// // // // // // // //     sheetObject.setColumnWidth(2, 20); // 카테고리
// // // // // // // //     sheetObject.setColumnWidth(3, 15); // 금액
// // // // // // // //     sheetObject.setColumnWidth(4, 30); // 메모
// // // // // // // //
// // // // // // // //     // 2. 헤더(제목) 줄 만들기 (다국어 적용 및 스타일링)
// // // // // // // //     List<String> headers = [
// // // // // // // //       l10n.translate('FILTER_EXPIRY_DATE'), // Date
// // // // // // // //       l10n.translate('PROP_LEASE_TYPE_LABEL'), // Type
// // // // // // // //       l10n.translate('COMMON_CATEGORY'), // Category
// // // // // // // //       l10n.translate('COMMON_AMOUNT'), // Amount
// // // // // // // //       l10n.translate('COMMON_MEMO_HINT'), // Memo
// // // // // // // //     ];
// // // // // // // //
// // // // // // // //     for (var i = 0; i < headers.length; i++) {
// // // // // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
// // // // // // // //       cell.value = TextCellValue(headers[i]);
// // // // // // // //       cell.cellStyle = _getHeaderStyle();
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // 3. 데이터 한 줄씩 추가하기
// // // // // // // //     for (var i = 0; i < sortedTransactions.length; i++) {
// // // // // // // //       final tx = sortedTransactions[i];
// // // // // // // //       final rowIndex = i + 1;
// // // // // // // //
// // // // // // // //       final date = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
// // // // // // // //       // 📍 INC/EXP를 다국어 수입/지출로 변환
// // // // // // // //       final type = tx.type == 'INC' ? l10n.translate('COMMON_INCOME') : l10n.translate('COMMON_EXPENSE');
// // // // // // // //       final category = tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category;
// // // // // // // //       final amount = tx.amount;
// // // // // // // //       final memo = tx.memo ?? '';
// // // // // // // //
// // // // // // // //       // 각 셀에 데이터 입력 및 스타일 적용
// // // // // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(date));
// // // // // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(type));
// // // // // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(category));
// // // // // // // //       _addStyledCell(sheetObject, 3, rowIndex, IntCellValue(amount));
// // // // // // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(memo));
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // 📍 [여기서부터 추가!] 4. 합계 줄(Total Row) 계산 및 추가
// // // // // // // //     final totalRowIndex = sortedTransactions.length + 1;
// // // // // // // //
// // // // // // // //     // 수입(+)과 지출(-)을 구분해서 합산하고 싶다면 별도 로직이 필요하지만,
// // // // // // // //     // 여기서는 단순히 전체 금액의 절대값 합계를 구하는 예시입니다.
// // // // // // // //     final totalAmount = sortedTransactions.fold(0, (sum, tx) => sum + tx.amount);
// // // // // // // //
// // // // // // // //     // 합계 텍스트와 금액 입력
// // // // // // // //     _addStyledCell(sheetObject, 2, totalRowIndex, TextCellValue(l10n.translate('COMMON_TOTAL')));
// // // // // // // //     _addStyledCell(sheetObject, 3, totalRowIndex, IntCellValue(totalAmount));
// // // // // // // //
// // // // // // // //     // 합계 줄 전용 스타일링 (연한 남색 배경 + 굵은 글씨)
// // // // // // // //     final totalStyle = CellStyle(
// // // // // // // //       backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"),
// // // // // // // //       bold: true,
// // // // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // // // //     );
// // // // // // // //
// // // // // // // //     // 2번 컬럼(합계 텍스트)과 3번 컬럼(금액)에 스타일 적용
// // // // // // // //     sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRowIndex)).cellStyle = totalStyle;
// // // // // // // //     sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRowIndex)).cellStyle = totalStyle;
// // // // // // // //
// // // // // // // //     // 5. 파일로 저장하기
// // // // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // // // //     final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
// // // // // // // //     final fileName = 'Tax_Report_$now.xlsx';
// // // // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // // // //
// // // // // // // //     final fileBytes = excel.save();
// // // // // // // //     if (fileBytes != null) {
// // // // // // // //       File(filePath)
// // // // // // // //         ..createSync(recursive: true)
// // // // // // // //         ..writeAsBytesSync(fileBytes);
// // // // // // // //
// // // // // // // //       // 5. 공유하기
// // // // // // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_BTN_TAX_EXCEL'));
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // 📍 미납 내역 전용 엑셀 생성 및 공유 함수
// // // // // // // //   // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
// // // // // // // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // // // // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // // // // //
// // // // // // // //     // 1. 엑셀 객체 생성
// // // // // // // //     var excel = Excel.createExcel();
// // // // // // // //     final sheetName = l10n.translate('REPORT_SEC_UNPAID');
// // // // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // // // //     excel.setDefaultSheet(sheetName);
// // // // // // // //
// // // // // // // //     // 📍 열 너비 설정
// // // // // // // //     sheetObject.setColumnWidth(0, 10); // 호수
// // // // // // // //     sheetObject.setColumnWidth(1, 15); // 세입자
// // // // // // // //     sheetObject.setColumnWidth(2, 15); // 연락처
// // // // // // // //     sheetObject.setColumnWidth(3, 10); // 상태
// // // // // // // //     sheetObject.setColumnWidth(4, 15); // 이번달 입금액
// // // // // // // //     sheetObject.setColumnWidth(5, 15); // 월세금액
// // // // // // // //     sheetObject.setColumnWidth(6, 15); // 납기일
// // // // // // // //
// // // // // // // //     // 2. 헤더 구성 (다국어 적용 및 스타일링)
// // // // // // // //     List<String> headers = [
// // // // // // // //       l10n.translate('PROP_ROOM_NUMBER_LABEL'), // 호수
// // // // // // // //       l10n.translate('PROP_TENANT_NAME_LABEL'), // 세입자
// // // // // // // //       l10n.translate('PROP_PHONE_LABEL'), // 연락처
// // // // // // // //       l10n.translate('PROP_PAYMENT_STATUS'), // 상태
// // // // // // // //       '${l10n.translate('STATUS_PAID')} (${l10n.translate('COMMON_AMOUNT')})', // 이번달 입금액
// // // // // // // //       '${l10n.translate('CAT_RENT')} (${l10n.translate('COMMON_AMOUNT')})', // 월세금액
// // // // // // // //       l10n.translate('FILTER_EXPIRY_DATE') // 납기일
// // // // // // // //     ];
// // // // // // // //
// // // // // // // //     for (var i = 0; i < headers.length; i++) {
// // // // // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
// // // // // // // //       cell.value = TextCellValue(headers[i]);
// // // // // // // //       cell.cellStyle = _getHeaderStyle();
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // 3. 미납 데이터 추가
// // // // // // // //     for (var i = 0; i < unpaidList.length; i++) {
// // // // // // // //       final unpaid = unpaidList[i];
// // // // // // // //       final rowIndex = i + 1;
// // // // // // // //
// // // // // // // //       final roomNo = unpaid.unit.roomNumber;
// // // // // // // //       final tenant = unpaid.unit.tenantName ?? '-';
// // // // // // // //       final phone = unpaid.unit.tenantPhone ?? '-';
// // // // // // // //       final status = unpaid.status == 'OVERDUE' ? l10n.translate('STATUS_OVERDUE') : l10n.translate('STATUS_WAITING');
// // // // // // // //       final paid = unpaid.paidAmount;
// // // // // // // //       final monthly = unpaid.unit.monthlyRent;
// // // // // // // //       final due = DateFormat('yyyy-MM-dd').format(unpaid.dueDate);
// // // // // // // //
// // // // // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(roomNo));
// // // // // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(tenant));
// // // // // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(phone));
// // // // // // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(status));
// // // // // // // //       _addStyledCell(sheetObject, 4, rowIndex, IntCellValue(paid));
// // // // // // // //       _addStyledCell(sheetObject, 5, rowIndex, IntCellValue(monthly));
// // // // // // // //       _addStyledCell(sheetObject, 6, rowIndex, TextCellValue(due));
// // // // // // // //     }
// // // // // // // //
// // // // // // // //     // 4. 파일 저장 및 공유 로직 (동일)
// // // // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // // // //     final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
// // // // // // // //     final fileName = 'Unpaid_Report_$now.xlsx';
// // // // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // // // //
// // // // // // // //     final fileBytes = excel.save();
// // // // // // // //     if (fileBytes != null) {
// // // // // // // //       File(filePath)
// // // // // // // //         ..createSync(recursive: true)
// // // // // // // //         ..writeAsBytesSync(fileBytes);
// // // // // // // //
// // // // // // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_SHARE_UNPAID_TEXT'));
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // 📍 셀 데이터 추가 및 기본 스타일 적용 헬퍼 함수
// // // // // // // //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value) {
// // // // // // // //     var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
// // // // // // // //     cell.value = value;
// // // // // // // //     cell.cellStyle = _getDataStyle();
// // // // // // // //   }
// // // // // // // //
// // // // // // // //
// // // // // // // //
// // // // // // // // }
// // // // // // //
// // // // // // //
// // // // // // //
// // // // // // // import 'dart:io';
// // // // // // // import 'package:excel/excel.dart';
// // // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 WidgetRef 사용을 위해 추가
// // // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // // import 'package:intl/intl.dart';
// // // // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // // // import '../../core/database/app_database.dart'; // Transaction 모델 사용
// // // // // // // import '../ledger/unpaid_provider.dart'; // 📍 UnpaidStatus 모델 사용을 위해 추가
// // // // // // //
// // // // // // // class ExcelExportService {
// // // // // // //   // 📍 금액에 콤마(,)를 넣기 위한 포맷터
// // // // // // //   final _numberFormat = NumberFormat('#,###');
// // // // // // //
// // // // // // //   // 📍 전문적인 리포트 스타일 정의 (헤더용)
// // // // // // //   CellStyle _getHeaderStyle() {
// // // // // // //     return CellStyle(
// // // // // // //       backgroundColorHex: ExcelColor.fromHexString("#1A237E"), // SiRE 메인 인디고 컬러
// // // // // // //       fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
// // // // // // //       bold: true,
// // // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // 📍 데이터 셀 스타일 정의 (기본)
// // // // // // //   CellStyle _getDataStyle({bool isIncome = false, bool isExpense = false}) {
// // // // // // //     return CellStyle(
// // // // // // //       // 수입은 파란색, 지출은 빨간색으로 가독성 부여
// // // // // // //       fontColorHex: isIncome
// // // // // // //           ? ExcelColor.fromHexString("#0D47A1")
// // // // // // //           : (isExpense ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")),
// // // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // 📍 합계 줄 전용 스타일
// // // // // // //   CellStyle _getTotalStyle(String hexColor) {
// // // // // // //     return CellStyle(
// // // // // // //       backgroundColorHex: ExcelColor.fromHexString(hexColor),
// // // // // // //       bold: true,
// // // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // // // //     );
// // // // // // //   }
// // // // // // //
// // // // // // //   // 엑셀 파일 생성 및 공유 함수 (세무 신고용 장부 추출)
// // // // // // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // // // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // // // //
// // // // // // //     // 📍 엑셀 저장 전 데이터를 날짜순(오름차순)으로 정렬
// // // // // // //     final sortedTransactions = List<Transaction>.from(transactions)
// // // // // // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // // // // // //
// // // // // // //     var excel = Excel.createExcel();
// // // // // // //     final sheetName = l10n.translate('NAV_LEDGER');
// // // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // // //     excel.setDefaultSheet(sheetName);
// // // // // // //
// // // // // // //     // 📍 열 너비 설정 (가독성 향상)
// // // // // // //     sheetObject.setColumnWidth(0, 15); // 거래일자
// // // // // // //     sheetObject.setColumnWidth(1, 12); // 구분(수입/지출)
// // // // // // //     sheetObject.setColumnWidth(2, 20); // 항목(카테고리)
// // // // // // //     sheetObject.setColumnWidth(3, 18); // 금액
// // // // // // //     sheetObject.setColumnWidth(4, 30); // 메모
// // // // // // //
// // // // // // //     // 📍 1. 헤더 수정 (세무 용어로 명확화)
// // // // // // //     List<String> headers = [
// // // // // // //       "거래일자",     // Date
// // // // // // //       "수입/지출",    // Type
// // // // // // //       "항목",        // Category
// // // // // // //       "금액(원)",    // Amount
// // // // // // //       "비고(메모)",   // Memo
// // // // // // //     ];
// // // // // // //
// // // // // // //     for (var i = 0; i < headers.length; i++) {
// // // // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
// // // // // // //       cell.value = TextCellValue(headers[i]);
// // // // // // //       cell.cellStyle = _getHeaderStyle();
// // // // // // //     }
// // // // // // //
// // // // // // //     int totalIncome = 0;
// // // // // // //     int totalExpense = 0;
// // // // // // //
// // // // // // //     // 📍 2. 데이터 한 줄씩 추가하기
// // // // // // //     for (var i = 0; i < sortedTransactions.length; i++) {
// // // // // // //       final tx = sortedTransactions[i];
// // // // // // //       final rowIndex = i + 1;
// // // // // // //       final bool isIncome = tx.type == 'INC';
// // // // // // //
// // // // // // //       final date = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
// // // // // // //       final type = isIncome ? "수입" : "지출";
// // // // // // //       final category = tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category;
// // // // // // //       final amount = tx.amount;
// // // // // // //       final memo = tx.memo ?? '';
// // // // // // //
// // // // // // //       // 합계 계산
// // // // // // //       if (isIncome) totalIncome += amount; else totalExpense += amount;
// // // // // // //
// // // // // // //       // 셀 데이터 입력 및 스타일 적용 (콤마 표시 포함)
// // // // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(date), isInc: isIncome, isExp: !isIncome);
// // // // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(type), isInc: isIncome, isExp: !isIncome);
// // // // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(category), isInc: isIncome, isExp: !isIncome);
// // // // // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(_numberFormat.format(amount)), isInc: isIncome, isExp: !isIncome);
// // // // // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(memo), isInc: isIncome, isExp: !isIncome);
// // // // // // //     }
// // // // // // //
// // // // // // //     // 📍 3. 합계 섹션 추가 (총수입, 총지출, 순수익)
// // // // // // //     int summaryStartRow = sortedTransactions.length + 2;
// // // // // // //
// // // // // // //     // 총 수입
// // // // // // //     _addSummaryRow(sheetObject, summaryStartRow, "총 수입 (+)", totalIncome, "#E3F2FD");
// // // // // // //     // 총 지출
// // // // // // //     _addSummaryRow(sheetObject, summaryStartRow + 1, "총 지출 (-)", totalExpense, "#FFEBEE");
// // // // // // //     // 최종 수익 (수지 차액)
// // // // // // //     _addSummaryRow(sheetObject, summaryStartRow + 2, "최종 수익 (수지차액)", totalIncome - totalExpense, "#F1F8E9");
// // // // // // //
// // // // // // //     // 📍 4. 파일 저장 및 공유 로직
// // // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // // //     final now = DateFormat('yyyyMMdd').format(DateTime.now());
// // // // // // //     final fileName = 'SiRE_Tax_Report_$now.xlsx';
// // // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // // //
// // // // // // //     final fileBytes = excel.save();
// // // // // // //     if (fileBytes != null) {
// // // // // // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // // // // // //       await Share.shareXFiles([XFile(filePath)], text: "세무 신고용 엑셀 리포트");
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // 📍 미납 내역 전용 엑셀 생성 및 공유 함수
// // // // // // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // // // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // // // //
// // // // // // //     var excel = Excel.createExcel();
// // // // // // //     final sheetName = l10n.translate('REPORT_SEC_UNPAID');
// // // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // // //     excel.setDefaultSheet(sheetName);
// // // // // // //
// // // // // // //     sheetObject.setColumnWidth(0, 10); // 호수
// // // // // // //     sheetObject.setColumnWidth(1, 15); // 세입자
// // // // // // //     sheetObject.setColumnWidth(2, 15); // 연락처
// // // // // // //     sheetObject.setColumnWidth(3, 10); // 상태
// // // // // // //     sheetObject.setColumnWidth(4, 15); // 이번달 입금액
// // // // // // //     sheetObject.setColumnWidth(5, 15); // 월세금액
// // // // // // //     sheetObject.setColumnWidth(6, 15); // 납기일
// // // // // // //
// // // // // // //     List<String> headers = [
// // // // // // //       l10n.translate('PROP_ROOM_NUMBER_LABEL'),
// // // // // // //       l10n.translate('PROP_TENANT_NAME_LABEL'),
// // // // // // //       l10n.translate('PROP_PHONE_LABEL'),
// // // // // // //       l10n.translate('PROP_PAYMENT_STATUS'),
// // // // // // //       '입금액(원)',
// // // // // // //       '월세(원)',
// // // // // // //       '납기일'
// // // // // // //     ];
// // // // // // //
// // // // // // //     for (var i = 0; i < headers.length; i++) {
// // // // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
// // // // // // //       cell.value = TextCellValue(headers[i]);
// // // // // // //       cell.cellStyle = _getHeaderStyle();
// // // // // // //     }
// // // // // // //
// // // // // // //     for (var i = 0; i < unpaidList.length; i++) {
// // // // // // //       final unpaid = unpaidList[i];
// // // // // // //       final rowIndex = i + 1;
// // // // // // //
// // // // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(unpaid.unit.roomNumber));
// // // // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(unpaid.unit.tenantName ?? '-'));
// // // // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(unpaid.unit.tenantPhone ?? '-'));
// // // // // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(unpaid.status == 'OVERDUE' ? "미납" : "대기"));
// // // // // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(_numberFormat.format(unpaid.paidAmount)));
// // // // // // //       _addStyledCell(sheetObject, 5, rowIndex, TextCellValue(_numberFormat.format(unpaid.unit.monthlyRent)));
// // // // // // //       _addStyledCell(sheetObject, 6, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(unpaid.dueDate)));
// // // // // // //     }
// // // // // // //
// // // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // // //     final fileName = 'Unpaid_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// // // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // // //
// // // // // // //     final fileBytes = excel.save();
// // // // // // //     if (fileBytes != null) {
// // // // // // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // // // // // //       await Share.shareXFiles([XFile(filePath)], text: "미납 내역 리포트");
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // 📍 셀 데이터 추가 및 기본 스타일 적용 헬퍼 함수
// // // // // // //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) {
// // // // // // //     var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
// // // // // // //     cell.value = value;
// // // // // // //     cell.cellStyle = _getDataStyle(isIncome: isInc, isExpense: isExp);
// // // // // // //   }
// // // // // // //
// // // // // // //   // 📍 합계 요약 줄 추가 헬퍼 함수
// // // // // // //   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) {
// // // // // // //     final style = _getTotalStyle(colorHex);
// // // // // // //
// // // // // // //     var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
// // // // // // //     titleCell.value = TextCellValue(title);
// // // // // // //     titleCell.cellStyle = style;
// // // // // // //
// // // // // // //     var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row));
// // // // // // //     amountCell.value = TextCellValue(_numberFormat.format(amount));
// // // // // // //     amountCell.cellStyle = style;
// // // // // // //   }
// // // // // // // }
// // // // // //
// // // // // //
// // // // // // import 'dart:io';
// // // // // // import 'package:excel/excel.dart';
// // // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // // import 'package:path_provider/path_provider.dart';
// // // // // // import 'package:share_plus/share_plus.dart';
// // // // // // import 'package:intl/intl.dart';
// // // // // // import '../../core/localization/localization_provider.dart';
// // // // // // import '../../core/database/app_database.dart';
// // // // // // import '../ledger/unpaid_provider.dart';
// // // // // //
// // // // // // class ExcelExportService {
// // // // // //   final _numberFormat = NumberFormat('#,###');
// // // // // //
// // // // // //   // 📍 [신규] 메인 대타이틀 스타일 (크고 굵게)
// // // // // //   CellStyle _getMainTitleStyle() {
// // // // // //     return CellStyle(
// // // // // //       backgroundColorHex: ExcelColor.fromHexString("#1A237E"),
// // // // // //       fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
// // // // // //       bold: true,
// // // // // //       fontSize: 16,
// // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   CellStyle _getHeaderStyle() {
// // // // // //     return CellStyle(
// // // // // //       backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"), // 연한 인디고
// // // // // //       fontColorHex: ExcelColor.fromHexString("#1A237E"),
// // // // // //       bold: true,
// // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   CellStyle _getDataStyle({bool isIncome = false, bool isExpense = false}) {
// // // // // //     return CellStyle(
// // // // // //       fontColorHex: isIncome
// // // // // //           ? ExcelColor.fromHexString("#0D47A1")
// // // // // //           : (isExpense ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")),
// // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // //       verticalAlign: VerticalAlign.Center,
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   CellStyle _getTotalStyle(String hexColor) {
// // // // // //     return CellStyle(
// // // // // //       backgroundColorHex: ExcelColor.fromHexString(hexColor),
// // // // // //       bold: true,
// // // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // // //     );
// // // // // //   }
// // // // // //
// // // // // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // // //     final sortedTransactions = List<Transaction>.from(transactions)
// // // // // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // // // // //
// // // // // //     var excel = Excel.createExcel();
// // // // // //     final sheetName = l10n.translate('NAV_LEDGER');
// // // // // //     Sheet sheetObject = excel[sheetName];
// // // // // //     excel.setDefaultSheet(sheetName);
// // // // // //
// // // // // //     // 열 너비 설정
// // // // // //     sheetObject.setColumnWidth(0, 18); // 거래일자
// // // // // //     sheetObject.setColumnWidth(1, 12); // 구분
// // // // // //     sheetObject.setColumnWidth(2, 22); // 항목
// // // // // //     sheetObject.setColumnWidth(3, 20); // 금액
// // // // // //     sheetObject.setColumnWidth(4, 35); // 메모
// // // // // //
// // // // // //     // 📍 1. 최상단 메인 타이틀 추가 및 셀 병합
// // // // // //     // 0번 행의 0번~4번 컬럼을 병합하여 타이틀 작성
// // // // // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // // // // //         CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
// // // // // //
// // // // // //     var mainTitleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // // // // //     mainTitleCell.value = TextCellValue("SiRE 자산 경영 리포트 (세무 증빙용)");
// // // // // //     mainTitleCell.cellStyle = _getMainTitleStyle();
// // // // // //
// // // // // //     // 📍 2. 헤더 (이제 1번 행에 위치)
// // // // // //     List<String> headers = ["거래일자", "수입/지출", "항목", "금액(원)", "비고(메모)"];
// // // // // //     for (var i = 0; i < headers.length; i++) {
// // // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // // // // //       cell.value = TextCellValue(headers[i]);
// // // // // //       cell.cellStyle = _getHeaderStyle();
// // // // // //     }
// // // // // //
// // // // // //     int totalIncome = 0;
// // // // // //     int totalExpense = 0;
// // // // // //
// // // // // //     // 📍 3. 데이터 추가 (2번 행부터 시작)
// // // // // //     for (var i = 0; i < sortedTransactions.length; i++) {
// // // // // //       final tx = sortedTransactions[i];
// // // // // //       final rowIndex = i + 2; // 0:타이틀, 1:헤더 이므로 2부터 시작
// // // // // //       final bool isIncome = tx.type == 'INC';
// // // // // //
// // // // // //       if (isIncome) totalIncome += tx.amount; else totalExpense += tx.amount;
// // // // // //
// // // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(tx.transactionDate)), isInc: isIncome, isExp: !isIncome);
// // // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(isIncome ? "수입" : "지출"), isInc: isIncome, isExp: !isIncome);
// // // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category), isInc: isIncome, isExp: !isIncome);
// // // // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(_numberFormat.format(tx.amount)), isInc: isIncome, isExp: !isIncome);
// // // // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(tx.memo ?? ''), isInc: isIncome, isExp: !isIncome);
// // // // // //     }
// // // // // //
// // // // // //     // 📍 4. 합계 섹션 (데이터 끝난 후 2칸 띄우고 시작)
// // // // // //     int summaryStartRow = sortedTransactions.length + 4;
// // // // // //     _addSummaryRow(sheetObject, summaryStartRow, "총 수입 (+)", totalIncome, "#E3F2FD");
// // // // // //     _addSummaryRow(sheetObject, summaryStartRow + 1, "총 지출 (-)", totalExpense, "#FFEBEE");
// // // // // //     _addSummaryRow(sheetObject, summaryStartRow + 2, "최종 수익 (수지차액)", totalIncome - totalExpense, "#F1F8E9");
// // // // // //
// // // // // //     // 파일 저장 로직
// // // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // // //     final fileName = 'SiRE_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// // // // // //     final filePath = '${directory.path}/$fileName';
// // // // // //     final fileBytes = excel.save();
// // // // // //     if (fileBytes != null) {
// // // // // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // // // // //       await Share.shareXFiles([XFile(filePath)], text: "SiRE 자산 경영 리포트 추출 완료");
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // (미납 내역 함수도 위와 유사한 방식으로 상단 타이틀 추가 가능)
// // // // // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // // //     var excel = Excel.createExcel();
// // // // // //     Sheet sheetObject = excel[l10n.translate('REPORT_SEC_UNPAID')];
// // // // // //
// // // // // //     // 미납 리포트 타이틀
// // // // // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // // // // //         CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
// // // // // //     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // // // // //     titleCell.value = TextCellValue("임대료 미납 관리 명세서");
// // // // // //     titleCell.cellStyle = _getMainTitleStyle();
// // // // // //
// // // // // //     // ... (이후 헤더 및 데이터 로직은 rowIndex를 +1씩 조정하여 위와 동일하게 적용)
// // // // // //   }
// // // // // //
// // // // // //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) {
// // // // // //     var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
// // // // // //     cell.value = value;
// // // // // //     cell.cellStyle = _getDataStyle(isIncome: isInc, isExpense: isExp);
// // // // // //   }
// // // // // //
// // // // // //   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) {
// // // // // //     final style = _getTotalStyle(colorHex);
// // // // // //     var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
// // // // // //     titleCell.value = TextCellValue(title);
// // // // // //     titleCell.cellStyle = style;
// // // // // //     var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row));
// // // // // //     amountCell.value = TextCellValue(_numberFormat.format(amount));
// // // // // //     amountCell.cellStyle = style;
// // // // // //   }
// // // // // // }
// // // // //
// // // // //
// // // // // import 'dart:io';
// // // // // import 'package:excel/excel.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 WidgetRef 사용을 위해 추가
// // // // // import 'package:path_provider/path_provider.dart';
// // // // // import 'package:share_plus/share_plus.dart';
// // // // // import 'package:intl/intl.dart';
// // // // // import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// // // // // import '../../core/database/app_database.dart'; // Transaction 모델 사용
// // // // // import '../ledger/unpaid_provider.dart'; // 📍 UnpaidStatus 모델 사용을 위해 추가
// // // // //
// // // // // class ExcelExportService {
// // // // //   // 📍 금액에 콤마(,)를 넣기 위한 포맷터
// // // // //   final _numberFormat = NumberFormat('#,###');
// // // // //
// // // // //   // 📍 [신규] 메인 대타이틀 스타일 (짙은 남색 배경, 흰색 글자, 크게)
// // // // //   CellStyle _getMainTitleStyle() {
// // // // //     return CellStyle(
// // // // //       backgroundColorHex: ExcelColor.fromHexString("#1A237E"), // SiRE 메인 인디고 컬러
// // // // //       fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
// // // // //       bold: true,
// // // // //       fontSize: 16,
// // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // //       verticalAlign: VerticalAlign.Center,
// // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // 📍 전문적인 리포트 스타일 정의 (헤더용)
// // // // //   CellStyle _getHeaderStyle() {
// // // // //     return CellStyle(
// // // // //       backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"), // 연한 인디고 배경
// // // // //       fontColorHex: ExcelColor.fromHexString("#1A237E"),
// // // // //       bold: true,
// // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // //       verticalAlign: VerticalAlign.Center,
// // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // 📍 데이터 셀 스타일 정의 (기본)
// // // // //   CellStyle _getDataStyle({bool isIncome = false, bool isExpense = false}) {
// // // // //     return CellStyle(
// // // // //       // 수입은 파란색, 지출은 빨간색으로 가독성 부여
// // // // //       fontColorHex: isIncome
// // // // //           ? ExcelColor.fromHexString("#0D47A1")
// // // // //           : (isExpense ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")),
// // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // //       verticalAlign: VerticalAlign.Center,
// // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // 📍 합계 줄 전용 스타일
// // // // //   CellStyle _getTotalStyle(String hexColor) {
// // // // //     return CellStyle(
// // // // //       backgroundColorHex: ExcelColor.fromHexString(hexColor),
// // // // //       bold: true,
// // // // //       horizontalAlign: HorizontalAlign.Center,
// // // // //       verticalAlign: VerticalAlign.Center,
// // // // //       fontFamily: getFontFamily(FontFamily.Arial),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // 엑셀 파일 생성 및 공유 함수 (세무 신고용 장부 추출)
// // // // //   // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
// // // // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // // // //     final l10n = ref.read(localizationProvider.notifier); // 번역 함수 준비
// // // // //
// // // // //     // 📍 엑셀 저장 전 데이터를 날짜순(오름차순)으로 정렬하여 장부 가독성 향상
// // // // //     final sortedTransactions = List<Transaction>.from(transactions)
// // // // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // // // //
// // // // //     // 1. 엑셀 객체 생성
// // // // //     var excel = Excel.createExcel();
// // // // //
// // // // //     // 기본 Sheet 이름 변경
// // // // //     final sheetName = l10n.translate('NAV_LEDGER');
// // // // //     Sheet sheetObject = excel[sheetName];
// // // // //     excel.setDefaultSheet(sheetName);
// // // // //
// // // // //     // 📍 열 너비 설정 (가독성 향상)
// // // // //     sheetObject.setColumnWidth(0, 18); // 거래일자
// // // // //     sheetObject.setColumnWidth(1, 12); // 구분(수입/지출)
// // // // //     sheetObject.setColumnWidth(2, 22); // 항목(카테고리)
// // // // //     sheetObject.setColumnWidth(3, 20); // 금액
// // // // //     sheetObject.setColumnWidth(4, 35); // 메모
// // // // //
// // // // //     // 📍 [고도화] 1. 최상단 메인 타이틀 추가 및 셀 병합 (Row 0, 다국어 적용)
// // // // //     // 0번 행의 0번~4번 컬럼을 병합하여 타이틀 작성
// // // // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // // // //         CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
// // // // //
// // // // //     var mainTitleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // // // //     mainTitleCell.value = TextCellValue(l10n.translate('REPORT_EXCEL_MAIN_TITLE'));
// // // // //     mainTitleCell.cellStyle = _getMainTitleStyle();
// // // // //
// // // // //     // 📍 [고도화] 2. 헤더(제목) 줄 만들기 (Row 1, 다국어 적용 및 스타일링)
// // // // //     List<String> headers = [
// // // // //       l10n.translate('REPORT_EXCEL_COLUMN_DATE'), // 거래일자
// // // // //       l10n.translate('REPORT_EXCEL_COLUMN_TYPE'), // 수입/지출
// // // // //       l10n.translate('COMMON_CATEGORY'),          // 항목
// // // // //       "${l10n.translate('COMMON_AMOUNT')}(${l10n.translate('COMMON_CURRENCY_WON')})", // 금액(원)
// // // // //       l10n.translate('COMMON_MEMO_HINT'),         // 비고(메모)
// // // // //     ];
// // // // //
// // // // //     for (var i = 0; i < headers.length; i++) {
// // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // // // //       cell.value = TextCellValue(headers[i]);
// // // // //       cell.cellStyle = _getHeaderStyle();
// // // // //     }
// // // // //
// // // // //     int totalIncome = 0;
// // // // //     int totalExpense = 0;
// // // // //
// // // // //     // 3. 데이터 한 줄씩 추가하기 (Row 2부터 시작)
// // // // //     for (var i = 0; i < sortedTransactions.length; i++) {
// // // // //       final tx = sortedTransactions[i];
// // // // //       final rowIndex = i + 2; // 0:타이틀, 1:헤더 이므로 2부터 시작
// // // // //       final bool isIncome = tx.type == 'INC';
// // // // //
// // // // //       final date = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
// // // // //       // 📍 INC/EXP를 다국어 수입/지출로 변환
// // // // //       final type = isIncome ? l10n.translate('COMMON_INCOME') : l10n.translate('COMMON_EXPENSE');
// // // // //       final category = tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category;
// // // // //       final amount = tx.amount;
// // // // //       final memo = tx.memo ?? '';
// // // // //
// // // // //       // 합계 계산
// // // // //       if (isIncome) totalIncome += amount; else totalExpense += amount;
// // // // //
// // // // //       // 각 셀에 데이터 입력 및 스타일 적용 (콤마 표시 포함)
// // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(date), isInc: isIncome, isExp: !isIncome);
// // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(type), isInc: isIncome, isExp: !isIncome);
// // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(category), isInc: isIncome, isExp: !isIncome);
// // // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(_numberFormat.format(amount)), isInc: isIncome, isExp: !isIncome);
// // // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(memo), isInc: isIncome, isExp: !isIncome);
// // // // //     }
// // // // //
// // // // //     // 📍 [고도화] 4. 합계 섹션 (데이터 끝난 후 2칸 띄우고 시작, 다국어 적용)
// // // // //     int summaryStartRow = sortedTransactions.length + 4;
// // // // //
// // // // //     // 총 수입 (+), 총 지출 (-), 최종 수익 (수지차액)
// // // // //     _addSummaryRow(sheetObject, summaryStartRow, l10n.translate('REPORT_EXCEL_TOTAL_INCOME'), totalIncome, "#E3F2FD");
// // // // //     _addSummaryRow(sheetObject, summaryStartRow + 1, l10n.translate('REPORT_EXCEL_TOTAL_EXPENSE'), totalExpense, "#FFEBEE");
// // // // //     _addSummaryRow(sheetObject, summaryStartRow + 2, l10n.translate('REPORT_EXCEL_TOTAL_PROFIT'), totalIncome - totalExpense, "#F1F8E9");
// // // // //
// // // // //     // 5. 파일로 저장하기
// // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // //     final now = DateFormat('yyyyMMdd').format(DateTime.now());
// // // // //     final fileName = 'SiRE_Report_$now.xlsx';
// // // // //     final filePath = '${directory.path}/$fileName';
// // // // //
// // // // //     final fileBytes = excel.save();
// // // // //     if (fileBytes != null) {
// // // // //       File(filePath)
// // // // //         ..createSync(recursive: true)
// // // // //         ..writeAsBytesSync(fileBytes);
// // // // //
// // // // //       // 6. 공유하기 (다국어 리포트명 적용)
// // // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_EXCEL_MAIN_TITLE'));
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // 📍 미납 내역 전용 엑셀 생성 및 공유 함수
// // // // //   // 📍 다국어를 위해 WidgetRef를 매개변수에 추가
// // // // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // // // //     final l10n = ref.read(localizationProvider.notifier);
// // // // //
// // // // //     // 1. 엑셀 객체 생성
// // // // //     var excel = Excel.createExcel();
// // // // //     final sheetName = l10n.translate('REPORT_SEC_UNPAID');
// // // // //     Sheet sheetObject = excel[sheetName];
// // // // //     excel.setDefaultSheet(sheetName);
// // // // //
// // // // //     // 📍 열 너비 설정
// // // // //     sheetObject.setColumnWidth(0, 10); // 호수
// // // // //     sheetObject.setColumnWidth(1, 15); // 세입자
// // // // //     sheetObject.setColumnWidth(2, 15); // 연락처
// // // // //     sheetObject.setColumnWidth(3, 10); // 상태
// // // // //     sheetObject.setColumnWidth(4, 15); // 이번달 입금액
// // // // //     sheetObject.setColumnWidth(5, 15); // 월세금액
// // // // //     sheetObject.setColumnWidth(6, 15); // 납기일
// // // // //
// // // // //     // 📍 [고도화] 최상단 미납 리포트 타이틀 추가 (Row 0, 다국어 적용)
// // // // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // // // //         CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
// // // // //     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // // // //     titleCell.value = TextCellValue(l10n.translate('REPORT_EXCEL_UNPAID_TITLE'));
// // // // //     titleCell.cellStyle = _getMainTitleStyle();
// // // // //
// // // // //     // 2. 헤더 구성 (Row 1, 다국어 적용 및 스타일링)
// // // // //     List<String> headers = [
// // // // //       l10n.translate('PROP_ROOM_NUMBER_LABEL'), // 호수
// // // // //       l10n.translate('PROP_TENANT_NAME_LABEL'), // 세입자
// // // // //       l10n.translate('PROP_PHONE_LABEL'), // 연락처
// // // // //       l10n.translate('PROP_PAYMENT_STATUS'), // 상태
// // // // //       '${l10n.translate('STATUS_PAID')}(${l10n.translate('COMMON_CURRENCY_WON')})', // 이번달 입금액(원)
// // // // //       '${l10n.translate('CAT_RENT')}(${l10n.translate('COMMON_CURRENCY_WON')})', // 월세금액(원)
// // // // //       l10n.translate('FILTER_EXPIRY_DATE') // 납기일
// // // // //     ];
// // // // //
// // // // //     for (var i = 0; i < headers.length; i++) {
// // // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // // // //       cell.value = TextCellValue(headers[i]);
// // // // //       cell.cellStyle = _getHeaderStyle();
// // // // //     }
// // // // //
// // // // //     // 3. 미납 데이터 추가 (Row 2부터 시작)
// // // // //     for (var i = 0; i < unpaidList.length; i++) {
// // // // //       final unpaid = unpaidList[i];
// // // // //       final rowIndex = i + 2;
// // // // //
// // // // //       final roomNo = unpaid.unit.roomNumber;
// // // // //       final tenant = unpaid.unit.tenantName ?? '-';
// // // // //       final phone = unpaid.unit.tenantPhone ?? '-';
// // // // //       final status = unpaid.status == 'OVERDUE' ? l10n.translate('STATUS_OVERDUE') : l10n.translate('STATUS_WAITING');
// // // // //       final paid = unpaid.paidAmount;
// // // // //       final monthly = unpaid.unit.monthlyRent;
// // // // //       final due = DateFormat('yyyy-MM-dd').format(unpaid.dueDate);
// // // // //
// // // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(roomNo));
// // // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(tenant));
// // // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(phone));
// // // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(status));
// // // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(_numberFormat.format(paid)));
// // // // //       _addStyledCell(sheetObject, 5, rowIndex, TextCellValue(_numberFormat.format(monthly)));
// // // // //       _addStyledCell(sheetObject, 6, rowIndex, TextCellValue(due));
// // // // //     }
// // // // //
// // // // //     // 4. 파일 저장 및 공유 로직
// // // // //     final directory = await getApplicationDocumentsDirectory();
// // // // //     final now = DateFormat('yyyyMMdd').format(DateTime.now());
// // // // //     final fileName = 'Unpaid_Report_$now.xlsx';
// // // // //     final filePath = '${directory.path}/$fileName';
// // // // //
// // // // //     final fileBytes = excel.save();
// // // // //     if (fileBytes != null) {
// // // // //       File(filePath)
// // // // //         ..createSync(recursive: true)
// // // // //         ..writeAsBytesSync(fileBytes);
// // // // //
// // // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_EXCEL_UNPAID_TITLE'));
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // 📍 셀 데이터 추가 및 기본 스타일 적용 헬퍼 함수
// // // // //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) {
// // // // //     var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
// // // // //     cell.value = value;
// // // // //     cell.cellStyle = _getDataStyle(isIncome: isInc, isExpense: isExp);
// // // // //   }
// // // // //
// // // // //   // 📍 합계 요약 줄 추가 헬퍼 함수
// // // // //   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) {
// // // // //     final style = _getTotalStyle(colorHex);
// // // // //
// // // // //     var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
// // // // //     titleCell.value = TextCellValue(title);
// // // // //     titleCell.cellStyle = style;
// // // // //
// // // // //     var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row));
// // // // //     amountCell.value = TextCellValue(_numberFormat.format(amount));
// // // // //     amountCell.cellStyle = style;
// // // // //   }
// // // // // }
// // // //
// // // // import 'dart:io';
// // // // import 'package:excel/excel.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:share_plus/share_plus.dart';
// // // // import 'package:intl/intl.dart';
// // // // import '../../core/localization/localization_provider.dart';
// // // // import '../../core/database/app_database.dart';
// // // // import '../ledger/unpaid_provider.dart';
// // // //
// // // // class ExcelExportService {
// // // //   final _numberFormat = NumberFormat('#,###');
// // // //
// // // //   // 스타일 정의 (기존 스타일 유지)
// // // //   CellStyle _getMainTitleStyle() => CellStyle(
// // // //     backgroundColorHex: ExcelColor.fromHexString("#1A237E"),
// // // //     fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
// // // //     bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // // //   );
// // // //
// // // //   CellStyle _getHeaderStyle() => CellStyle(
// // // //     backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"),
// // // //     fontColorHex: ExcelColor.fromHexString("#1A237E"),
// // // //     bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // // //   );
// // // //
// // // //   CellStyle _getDataStyle({bool isInc = false, bool isExp = false}) => CellStyle(
// // // //     fontColorHex: isInc ? ExcelColor.fromHexString("#0D47A1") : (isExp ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")),
// // // //     horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // // //   );
// // // //
// // // //   CellStyle _getTotalStyle(String hexColor) => CellStyle(
// // // //     backgroundColorHex: ExcelColor.fromHexString(hexColor),
// // // //     bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // // //   );
// // // //
// // // //   // 엑셀 파일 생성 및 공유 함수
// // // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // // //     final l10n = ref.read(localizationProvider.notifier);
// // // //     final sortedTransactions = List<Transaction>.from(transactions)
// // // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // // //
// // // //     var excel = Excel.createExcel();
// // // //     final sheetName = l10n.translate('NAV_LEDGER');
// // // //     Sheet sheetObject = excel[sheetName];
// // // //     excel.setDefaultSheet(sheetName);
// // // //
// // // //     sheetObject.setColumnWidth(0, 18);
// // // //     sheetObject.setColumnWidth(1, 12);
// // // //     sheetObject.setColumnWidth(2, 22);
// // // //     sheetObject.setColumnWidth(3, 20);
// // // //     sheetObject.setColumnWidth(4, 35);
// // // //
// // // //     // 📍 1. 최상단 메인 타이틀 (셀 병합)
// // // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // // //         CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
// // // //     var mainTitleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // // //     mainTitleCell.value = TextCellValue(l10n.translate('REPORT_EXCEL_MAIN_TITLE'));
// // // //     mainTitleCell.cellStyle = _getMainTitleStyle();
// // // //
// // // //     // 📍 2. 헤더 컬럼 (괄호 안 다국어 적용 방식 수정)
// // // //     // 괄호와 키값이 섞이지 않도록 변수로 먼저 처리합니다.
// // // //     final String amountLabel = l10n.translate('COMMON_AMOUNT');
// // // //     final String currencyLabel = l10n.translate('COMMON_CURRENCY_WON');
// // // //
// // // //     List<String> headers = [
// // // //       l10n.translate('REPORT_EXCEL_COLUMN_DATE'),
// // // //       l10n.translate('REPORT_EXCEL_COLUMN_TYPE'),
// // // //       l10n.translate('COMMON_CATEGORY'),
// // // //       "$amountLabel($currencyLabel)", // 👈 괄호 안 다국어 변수 결합
// // // //       l10n.translate('COMMON_MEMO_HINT')
// // // //     ];
// // // //
// // // //     for (var i = 0; i < headers.length; i++) {
// // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // // //       cell.value = TextCellValue(headers[i]);
// // // //       cell.cellStyle = _getHeaderStyle();
// // // //     }
// // // //
// // // //     int totalIncome = 0;
// // // //     int totalExpense = 0;
// // // //
// // // //     // 3. 데이터 로드 (Row 2부터 시작)
// // // //     for (var i = 0; i < sortedTransactions.length; i++) {
// // // //       final tx = sortedTransactions[i];
// // // //       final rowIndex = i + 2;
// // // //       final bool isIncome = tx.type == 'INC';
// // // //       if (isIncome) totalIncome += tx.amount; else totalExpense += tx.amount;
// // // //
// // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(tx.transactionDate)), isInc: isIncome, isExp: !isIncome);
// // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(isIncome ? l10n.translate('COMMON_INCOME') : l10n.translate('COMMON_EXPENSE')), isInc: isIncome, isExp: !isIncome);
// // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(tx.category.startsWith('CAT_') ? l10n.translate(tx.category) : tx.category), isInc: isIncome, isExp: !isIncome);
// // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(_numberFormat.format(tx.amount)), isInc: isIncome, isExp: !isIncome);
// // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(tx.memo ?? ''), isInc: isIncome, isExp: !isIncome);
// // // //     }
// // // //
// // // //     // 📍 4. 합계 섹션 (다국어 키 적용)
// // // //     int summaryStartRow = sortedTransactions.length + 4;
// // // //     _addSummaryRow(sheetObject, summaryStartRow, l10n.translate('REPORT_EXCEL_TOTAL_INCOME'), totalIncome, "#E3F2FD");
// // // //     _addSummaryRow(sheetObject, summaryStartRow + 1, l10n.translate('REPORT_EXCEL_TOTAL_EXPENSE'), totalExpense, "#FFEBEE");
// // // //     _addSummaryRow(sheetObject, summaryStartRow + 2, l10n.translate('REPORT_EXCEL_TOTAL_PROFIT'), totalIncome - totalExpense, "#F1F8E9");
// // // //
// // // //     final directory = await getApplicationDocumentsDirectory();
// // // //     final fileName = 'SiRE_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// // // //     final filePath = '${directory.path}/$fileName';
// // // //     final fileBytes = excel.save();
// // // //     if (fileBytes != null) {
// // // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_EXCEL_MAIN_TITLE'));
// // // //     }
// // // //   }
// // // //
// // // //   // (미납 내역 함수)
// // // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // // //     final l10n = ref.read(localizationProvider.notifier);
// // // //     var excel = Excel.createExcel();
// // // //     final sheetName = l10n.translate('REPORT_SEC_UNPAID');
// // // //     Sheet sheetObject = excel[sheetName];
// // // //     excel.setDefaultSheet(sheetName);
// // // //
// // // //     // 최상단 타이틀
// // // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // // //         CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
// // // //     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // // //     titleCell.value = TextCellValue(l10n.translate('REPORT_EXCEL_UNPAID_TITLE'));
// // // //     titleCell.cellStyle = _getMainTitleStyle();
// // // //
// // // //     // 📍 헤더 구성 (괄호 다국어 처리 동일 적용)
// // // //     final String paidLabel = l10n.translate('STATUS_PAID');
// // // //     final String rentLabel = l10n.translate('CAT_RENT');
// // // //     final String currencyLabel = l10n.translate('COMMON_CURRENCY_WON');
// // // //
// // // //     List<String> headers = [
// // // //       l10n.translate('PROP_ROOM_NUMBER_LABEL'),
// // // //       l10n.translate('PROP_TENANT_NAME_LABEL'),
// // // //       l10n.translate('PROP_PHONE_LABEL'),
// // // //       l10n.translate('PROP_PAYMENT_STATUS'),
// // // //       "$paidLabel($currencyLabel)", // 입금액(원)
// // // //       "$rentLabel($currencyLabel)", // 월세(원)
// // // //       l10n.translate('FILTER_EXPIRY_DATE')
// // // //     ];
// // // //
// // // //     for (var i = 0; i < headers.length; i++) {
// // // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // // //       cell.value = TextCellValue(headers[i]);
// // // //       cell.cellStyle = _getHeaderStyle();
// // // //     }
// // // //
// // // //     // ... (이후 데이터 추가 로직)
// // // //     for (var i = 0; i < unpaidList.length; i++) {
// // // //       final unpaid = unpaidList[i];
// // // //       final rowIndex = i + 2;
// // // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(unpaid.unit.roomNumber));
// // // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(unpaid.unit.tenantName ?? '-'));
// // // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(unpaid.unit.tenantPhone ?? '-'));
// // // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(unpaid.status == 'OVERDUE' ? l10n.translate('STATUS_OVERDUE') : l10n.translate('STATUS_WAITING')));
// // // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(_numberFormat.format(unpaid.paidAmount)));
// // // //       _addStyledCell(sheetObject, 5, rowIndex, TextCellValue(_numberFormat.format(unpaid.unit.monthlyRent)));
// // // //       _addStyledCell(sheetObject, 6, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(unpaid.dueDate)));
// // // //     }
// // // //
// // // //     final directory = await getApplicationDocumentsDirectory();
// // // //     final now = DateFormat('yyyyMMdd').format(DateTime.now());
// // // //     final fileName = 'Unpaid_Report_$now.xlsx';
// // // //     final filePath = '${directory.path}/$fileName';
// // // //     final fileBytes = excel.save();
// // // //     if (fileBytes != null) {
// // // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // // //       await Share.shareXFiles([XFile(filePath)], text: l10n.translate('REPORT_EXCEL_UNPAID_TITLE'));
// // // //     }
// // // //   }
// // // //
// // // //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) {
// // // //     var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
// // // //     cell.value = value;
// // // //     cell.cellStyle = _getDataStyle(isInc: isInc, isExp: isExp);
// // // //   }
// // // //
// // // //   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) {
// // // //     final style = _getTotalStyle(colorHex);
// // // //     var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
// // // //     titleCell.value = TextCellValue(title);
// // // //     titleCell.cellStyle = style;
// // // //     var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row));
// // // //     amountCell.value = TextCellValue(_numberFormat.format(amount));
// // // //     amountCell.cellStyle = style;
// // // //   }
// // // // }
// // //
// // //
// // //
// // // import 'dart:io';
// // // import 'package:excel/excel.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:share_plus/share_plus.dart';
// // // import 'package:intl/intl.dart';
// // // import '../../core/localization/localization_provider.dart';
// // // import '../../core/database/app_database.dart';
// // // import '../ledger/unpaid_provider.dart';
// // //
// // // class ExcelExportService {
// // //   final _numberFormat = NumberFormat('#,###');
// // //
// // //   // 스타일 정의
// // //   CellStyle _getMainTitleStyle() => CellStyle(
// // //     backgroundColorHex: ExcelColor.fromHexString("#1A237E"),
// // //     fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
// // //     bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // //   );
// // //
// // //   CellStyle _getHeaderStyle() => CellStyle(
// // //     backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"),
// // //     fontColorHex: ExcelColor.fromHexString("#1A237E"),
// // //     bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // //   );
// // //
// // //   CellStyle _getDataStyle({bool isInc = false, bool isExp = false}) => CellStyle(
// // //     fontColorHex: isInc ? ExcelColor.fromHexString("#0D47A1") : (isExp ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")),
// // //     horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // //   );
// // //
// // //   CellStyle _getTotalStyle(String hexColor) => CellStyle(
// // //     backgroundColorHex: ExcelColor.fromHexString(hexColor),
// // //     bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center,
// // //   );
// // //
// // //   // 엑셀 파일 생성 및 공유 함수 (세무 신고용)
// // //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// // //     final l10n = ref.read(localizationProvider.notifier);
// // //
// // //     // 안전한 번역 추출 함수
// // //     String tr(String key) => l10n.translate(key).isEmpty ? key : l10n.translate(key);
// // //
// // //     final sortedTransactions = List<Transaction>.from(transactions)
// // //       ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// // //
// // //     var excel = Excel.createExcel();
// // //     final sheetName = tr('NAV_LEDGER');
// // //     Sheet sheetObject = excel[sheetName];
// // //     excel.setDefaultSheet(sheetName);
// // //
// // //     sheetObject.setColumnWidth(0, 18);
// // //     sheetObject.setColumnWidth(1, 12);
// // //     sheetObject.setColumnWidth(2, 22);
// // //     sheetObject.setColumnWidth(3, 20);
// // //     sheetObject.setColumnWidth(4, 35);
// // //
// // //     // 📍 1. 최상단 메인 타이틀 (셀 병합)
// // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // //         CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
// // //     var mainTitleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // //     mainTitleCell.value = TextCellValue(tr('REPORT_EXCEL_MAIN_TITLE'));
// // //     mainTitleCell.cellStyle = _getMainTitleStyle();
// // //
// // //     // 📍 2. 헤더 컬럼 (다국어 키 적용)
// // //     final String amountLabel = tr('COMMON_AMOUNT');
// // //     final String currencyLabel = tr('COMMON_CURRENCY_WON');
// // //
// // //     List<String> headers = [
// // //       tr('REPORT_EXCEL_COLUMN_DATE'),
// // //       tr('REPORT_EXCEL_COLUMN_TYPE'),
// // //       tr('COMMON_CATEGORY'),
// // //       "$amountLabel ($currencyLabel)",
// // //       tr('COMMON_MEMO_HINT')
// // //     ];
// // //
// // //     for (var i = 0; i < headers.length; i++) {
// // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // //       cell.value = TextCellValue(headers[i]);
// // //       cell.cellStyle = _getHeaderStyle();
// // //     }
// // //
// // //     int totalIncome = 0;
// // //     int totalExpense = 0;
// // //
// // //     // 3. 데이터 로드 (Row 2부터 시작)
// // //     for (var i = 0; i < sortedTransactions.length; i++) {
// // //       final tx = sortedTransactions[i];
// // //       final rowIndex = i + 2;
// // //       final bool isIncome = tx.type == 'INC';
// // //       if (isIncome) totalIncome += tx.amount; else totalExpense += tx.amount;
// // //
// // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(tx.transactionDate)), isInc: isIncome, isExp: !isIncome);
// // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(isIncome ? tr('COMMON_INCOME') : tr('COMMON_EXPENSE')), isInc: isIncome, isExp: !isIncome);
// // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(tx.category.startsWith('CAT_') ? tr(tx.category) : tx.category), isInc: isIncome, isExp: !isIncome);
// // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(_numberFormat.format(tx.amount)), isInc: isIncome, isExp: !isIncome);
// // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(tx.memo ?? ''), isInc: isIncome, isExp: !isIncome);
// // //     }
// // //
// // //     // 📍 4. 합계 섹션 (다국어 적용)
// // //     int summaryStartRow = sortedTransactions.length + 4;
// // //     _addSummaryRow(sheetObject, summaryStartRow, tr('REPORT_EXCEL_TOTAL_INCOME'), totalIncome, "#E3F2FD");
// // //     _addSummaryRow(sheetObject, summaryStartRow + 1, tr('REPORT_EXCEL_TOTAL_EXPENSE'), totalExpense, "#FFEBEE");
// // //     _addSummaryRow(sheetObject, summaryStartRow + 2, tr('REPORT_EXCEL_TOTAL_PROFIT'), totalIncome - totalExpense, "#F1F8E9");
// // //
// // //     final directory = await getApplicationDocumentsDirectory();
// // //     final fileName = 'SiRE_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// // //     final filePath = '${directory.path}/$fileName';
// // //     final fileBytes = excel.save();
// // //     if (fileBytes != null) {
// // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // //       await Share.shareXFiles([XFile(filePath)], text: tr('REPORT_EXCEL_MAIN_TITLE'));
// // //     }
// // //   }
// // //
// // //   // (미납 내역 전용 엑셀 함수)
// // //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// // //     final l10n = ref.read(localizationProvider.notifier);
// // //     String tr(String key) => l10n.translate(key).isEmpty ? key : l10n.translate(key);
// // //
// // //     var excel = Excel.createExcel();
// // //     final sheetName = tr('REPORT_SEC_UNPAID');
// // //     Sheet sheetObject = excel[sheetName];
// // //     excel.setDefaultSheet(sheetName);
// // //
// // //     // 열 너비
// // //     sheetObject.setColumnWidth(0, 10); // 호수
// // //     sheetObject.setColumnWidth(1, 15); // 세입자
// // //     sheetObject.setColumnWidth(2, 15); // 연락처
// // //     sheetObject.setColumnWidth(3, 10); // 상태
// // //     sheetObject.setColumnWidth(4, 15); // 입금액
// // //     sheetObject.setColumnWidth(5, 15); // 월세액
// // //     sheetObject.setColumnWidth(6, 15); // 납기일
// // //
// // //     // 최상단 타이틀
// // //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
// // //         CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
// // //     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// // //     titleCell.value = TextCellValue(tr('REPORT_EXCEL_UNPAID_TITLE'));
// // //     titleCell.cellStyle = _getMainTitleStyle();
// // //
// // //     final String currencyLabel = tr('COMMON_CURRENCY_WON');
// // //
// // //     List<String> headers = [
// // //       tr('PROP_ROOM_NUMBER_LABEL'),
// // //       tr('PROP_TENANT_NAME_LABEL'),
// // //       tr('PROP_PHONE_LABEL'),
// // //       tr('PROP_PAYMENT_STATUS'),
// // //       "${tr('STATUS_PAID')} ($currencyLabel)",
// // //       "${tr('CAT_RENT')} ($currencyLabel)",
// // //       tr('FILTER_EXPIRY_DATE')
// // //     ];
// // //
// // //     for (var i = 0; i < headers.length; i++) {
// // //       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
// // //       cell.value = TextCellValue(headers[i]);
// // //       cell.cellStyle = _getHeaderStyle();
// // //     }
// // //
// // //     for (var i = 0; i < unpaidList.length; i++) {
// // //       final unpaid = unpaidList[i];
// // //       final rowIndex = i + 2;
// // //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(unpaid.unit.roomNumber));
// // //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(unpaid.unit.tenantName ?? '-'));
// // //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(unpaid.unit.tenantPhone ?? '-'));
// // //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(unpaid.status == 'OVERDUE' ? tr('STATUS_OVERDUE') : tr('STATUS_WAITING')));
// // //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(_numberFormat.format(unpaid.paidAmount)));
// // //       _addStyledCell(sheetObject, 5, rowIndex, TextCellValue(_numberFormat.format(unpaid.unit.monthlyRent)));
// // //       _addStyledCell(sheetObject, 6, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(unpaid.dueDate)));
// // //     }
// // //
// // //     final directory = await getApplicationDocumentsDirectory();
// // //     final fileName = 'Unpaid_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// // //     final filePath = '${directory.path}/$fileName';
// // //     final fileBytes = excel.save();
// // //     if (fileBytes != null) {
// // //       File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
// // //       await Share.shareXFiles([XFile(filePath)], text: tr('REPORT_EXCEL_UNPAID_TITLE'));
// // //     }
// // //   }
// // //
// // //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) {
// // //     var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
// // //     cell.value = value;
// // //     cell.cellStyle = _getDataStyle(isInc: isInc, isExp: isExp);
// // //   }
// // //
// // //   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) {
// // //     final style = _getTotalStyle(colorHex);
// // //     var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row));
// // //     titleCell.value = TextCellValue(title);
// // //     titleCell.cellStyle = style;
// // //     var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row));
// // //     amountCell.value = TextCellValue(_numberFormat.format(amount));
// // //     amountCell.cellStyle = style;
// // //   }
// // // }
// //
// //
// //
// // import 'dart:io';
// // import 'package:excel/excel.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:intl/intl.dart';
// // import '../../core/localization/localization_provider.dart';
// // import '../../core/database/app_database.dart';
// // import '../ledger/unpaid_provider.dart';
// //
// // class ExcelExportService {
// //   final _numberFormat = NumberFormat('#,###');
// //
// //   CellStyle _getMainTitleStyle() => CellStyle(backgroundColorHex: ExcelColor.fromHexString("#1A237E"), fontColorHex: ExcelColor.fromHexString("#FFFFFF"), bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
// //   CellStyle _getHeaderStyle() => CellStyle(backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"), fontColorHex: ExcelColor.fromHexString("#1A237E"), bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
// //   CellStyle _getDataStyle({bool isInc = false, bool isExp = false}) => CellStyle(fontColorHex: isInc ? ExcelColor.fromHexString("#0D47A1") : (isExp ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")), horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
// //   CellStyle _getTotalStyle(String hexColor) => CellStyle(backgroundColorHex: ExcelColor.fromHexString(hexColor), bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
// //
// //   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
// //     final l10n = ref.read(localizationProvider.notifier);
// //     String tr(String key, String fallback) { final val = l10n.translate(key); return (val.isEmpty || val == key) ? fallback : val; }
// //     final sortedTransactions = List<Transaction>.from(transactions)..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
// //     var excel = Excel.createExcel();
// //     final sheetName = tr('NAV_LEDGER', '장부 관리');
// //     Sheet sheetObject = excel[sheetName];
// //     excel.setDefaultSheet(sheetName);
// //     sheetObject.setColumnWidth(0, 18); sheetObject.setColumnWidth(1, 12); sheetObject.setColumnWidth(2, 22); sheetObject.setColumnWidth(3, 20); sheetObject.setColumnWidth(4, 35);
// //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
// //     var mainTitle = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// //     mainTitle.value = TextCellValue(tr('REPORT_EXCEL_MAIN_TITLE', 'SiRE 자산 경영 리포트 (세무 증빙용)'));
// //     mainTitle.cellStyle = _getMainTitleStyle();
// //     final String amountLabel = tr('COMMON_AMOUNT', '금액');
// //     final String currencyLabel = tr('COMMON_CURRENCY_WON', '원');
// //     List<String> headers = [tr('REPORT_EXCEL_COLUMN_DATE', '거래일자'), tr('REPORT_EXCEL_COLUMN_TYPE', '수입/지출'), tr('COMMON_CATEGORY', '항목'), "$amountLabel ($currencyLabel)", tr('COMMON_MEMO_HINT', '비고(메모)')];
// //     for (var i = 0; i < headers.length; i++) { var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)); cell.value = TextCellValue(headers[i]); cell.cellStyle = _getHeaderStyle(); }
// //     int incTotal = 0, expTotal = 0;
// //     for (var i = 0; i < sortedTransactions.length; i++) {
// //       final tx = sortedTransactions[i]; final rIdx = i + 2; final isInc = tx.type == 'INC'; if (isInc) incTotal += tx.amount; else expTotal += tx.amount;
// //       _addStyledCell(sheetObject, 0, rIdx, TextCellValue(DateFormat('yyyy-MM-dd').format(tx.transactionDate)), isInc: isInc, isExp: !isInc);
// //       _addStyledCell(sheetObject, 1, rIdx, TextCellValue(isInc ? tr('COMMON_INCOME', '수입') : tr('COMMON_EXPENSE', '지출')), isInc: isInc, isExp: !isInc);
// //       _addStyledCell(sheetObject, 2, rIdx, TextCellValue(tx.category.startsWith('CAT_') ? tr(tx.category, tx.category) : tx.category), isInc: isInc, isExp: !isInc);
// //       _addStyledCell(sheetObject, 3, rIdx, TextCellValue(_numberFormat.format(tx.amount)), isInc: isInc, isExp: !isInc);
// //       _addStyledCell(sheetObject, 4, rIdx, TextCellValue(tx.memo ?? ''), isInc: isInc, isExp: !isInc);
// //     }
// //     int sRow = sortedTransactions.length + 4;
// //     _addSummaryRow(sheetObject, sRow, tr('REPORT_EXCEL_TOTAL_INCOME', '총 수입 (+)'), incTotal, "#E3F2FD");
// //     _addSummaryRow(sheetObject, sRow + 1, tr('REPORT_EXCEL_TOTAL_EXPENSE', '총 지출 (-)'), expTotal, "#FFEBEE");
// //     _addSummaryRow(sheetObject, sRow + 2, tr('REPORT_EXCEL_TOTAL_PROFIT', '최종 수익 (수지차액)'), incTotal - expTotal, "#F1F8E9");
// //     final directory = await getApplicationDocumentsDirectory();
// //     final fileName = 'SiRE_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// //     final filePath = '${directory.path}/$fileName';
// //     final bytes = excel.save();
// //     if (bytes != null) { File(filePath)..createSync(recursive: true)..writeAsBytesSync(bytes); await Share.shareXFiles([XFile(filePath)], text: tr('REPORT_EXCEL_MAIN_TITLE', 'SiRE Report')); }
// //   }
// //
// //   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
// //     final l10n = ref.read(localizationProvider.notifier);
// //     String tr(String key, String fallback) { final val = l10n.translate(key); return (val.isEmpty || val == key) ? fallback : val; }
// //     var excel = Excel.createExcel();
// //     final sheetName = tr('REPORT_SEC_UNPAID', '미납 관리');
// //     Sheet sheetObject = excel[sheetName];
// //     excel.setDefaultSheet(sheetName);
// //     sheetObject.setColumnWidth(0, 10); sheetObject.setColumnWidth(1, 15); sheetObject.setColumnWidth(2, 15); sheetObject.setColumnWidth(3, 10); sheetObject.setColumnWidth(4, 15); sheetObject.setColumnWidth(5, 15); sheetObject.setColumnWidth(6, 15);
// //     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
// //     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
// //     titleCell.value = TextCellValue(tr('REPORT_EXCEL_UNPAID_TITLE', '임대료 미납 관리 명세서'));
// //     titleCell.cellStyle = _getMainTitleStyle();
// //     final String currencyLabel = tr('COMMON_CURRENCY_WON', '원');
// //     List<String> headers = [tr('PROP_ROOM_NUMBER_LABEL', '호수'), tr('PROP_TENANT_NAME_LABEL', '세입자'), tr('PROP_PHONE_LABEL', '연락처'), tr('PROP_PAYMENT_STATUS', '상태'), "${tr('STATUS_PAID', '입금액')} ($currencyLabel)", "${tr('CAT_RENT', '월세')} ($currencyLabel)", tr('FILTER_EXPIRY_DATE', '납기일')];
// //     for (var i = 0; i < headers.length; i++) { var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)); cell.value = TextCellValue(headers[i]); cell.cellStyle = _getHeaderStyle(); }
// //     for (var i = 0; i < unpaidList.length; i++) {
// //       final unpaid = unpaidList[i]; final rowIndex = i + 2;
// //       _addStyledCell(sheetObject, 0, rowIndex, TextCellValue(unpaid.unit.roomNumber));
// //       _addStyledCell(sheetObject, 1, rowIndex, TextCellValue(unpaid.unit.tenantName ?? '-'));
// //       _addStyledCell(sheetObject, 2, rowIndex, TextCellValue(unpaid.unit.tenantPhone ?? '-'));
// //       _addStyledCell(sheetObject, 3, rowIndex, TextCellValue(unpaid.status == 'OVERDUE' ? tr('STATUS_OVERDUE', '미납') : tr('STATUS_WAITING', '대기')));
// //       _addStyledCell(sheetObject, 4, rowIndex, TextCellValue(_numberFormat.format(unpaid.paidAmount)));
// //       _addStyledCell(sheetObject, 5, rowIndex, TextCellValue(_numberFormat.format(unpaid.unit.monthlyRent)));
// //       _addStyledCell(sheetObject, 6, rowIndex, TextCellValue(DateFormat('yyyy-MM-dd').format(unpaid.dueDate)));
// //     }
// //     final directory = await getApplicationDocumentsDirectory();
// //     final fileName = 'Unpaid_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
// //     final filePath = '${directory.path}/$fileName';
// //     final bytes = excel.save();
// //     if (bytes != null) { File(filePath)..createSync(recursive: true)..writeAsBytesSync(bytes); await Share.shareXFiles([XFile(filePath)], text: tr('REPORT_EXCEL_UNPAID_TITLE', 'Unpaid Report')); }
// //   }
// //
// //   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) { var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)); cell.value = value; cell.cellStyle = _getDataStyle(isInc: isInc, isExp: isExp); }
// //   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) { final style = _getTotalStyle(colorHex); var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)); titleCell.value = TextCellValue(title); titleCell.cellStyle = style; var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)); amountCell.value = TextCellValue(_numberFormat.format(amount)); amountCell.cellStyle = style; }
// // }
//
//
// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:intl/intl.dart';
// import '../../core/localization/localization_provider.dart';
// import '../../core/database/app_database.dart';
// import '../ledger/unpaid_provider.dart';
//
// class ExcelExportService {
//   final _numberFormat = NumberFormat('#,###');
//
//   // 스타일 정의
//   CellStyle _getMainTitleStyle() => CellStyle(backgroundColorHex: ExcelColor.fromHexString("#1A237E"), fontColorHex: ExcelColor.fromHexString("#FFFFFF"), bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
//   CellStyle _getHeaderStyle() => CellStyle(backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"), fontColorHex: ExcelColor.fromHexString("#1A237E"), bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
//   CellStyle _getDataStyle({bool isInc = false, bool isExp = false}) => CellStyle(fontColorHex: isInc ? ExcelColor.fromHexString("#0D47A1") : (isExp ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")), horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
//   CellStyle _getTotalStyle(String hexColor) => CellStyle(backgroundColorHex: ExcelColor.fromHexString(hexColor), bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
//
//   // 📍 엑셀 추출 (세무 리포트)
//   Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
//     final l10n = ref.read(localizationProvider.notifier);
//     String tr(String key, String fallback) {
//       final val = l10n.translate(key);
//       return (val.isEmpty || val == key) ? fallback : val;
//     }
//
//     final sorted = List<Transaction>.from(transactions)..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
//     var excel = Excel.createExcel();
//     final sheetName = tr('NAV_LEDGER', '장부 관리');
//     Sheet sheetObject = excel[sheetName];
//     excel.setDefaultSheet(sheetName);
//
//     sheetObject.setColumnWidth(0, 18); sheetObject.setColumnWidth(1, 12); sheetObject.setColumnWidth(2, 22); sheetObject.setColumnWidth(3, 20); sheetObject.setColumnWidth(4, 35);
//     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
//
//     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
//     titleCell.value = TextCellValue(tr('REPORT_EXCEL_MAIN_TITLE', 'SiRE 자산 경영 리포트 (세무 증빙용)'));
//     titleCell.cellStyle = _getMainTitleStyle();
//
//     final String amtLabel = tr('COMMON_AMOUNT', '금액');
//     final String curLabel = tr('COMMON_CURRENCY_WON', '원');
//     List<String> headers = [tr('REPORT_EXCEL_COLUMN_DATE', '거래일자'), tr('REPORT_EXCEL_COLUMN_TYPE', '수입/지출'), tr('COMMON_CATEGORY', '항목'), "$amtLabel ($curLabel)", tr('COMMON_MEMO_HINT', '비고(메모)')];
//
//     for (var i = 0; i < headers.length; i++) {
//       var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
//       cell.value = TextCellValue(headers[i]);
//       cell.cellStyle = _getHeaderStyle();
//     }
//
//     int incT = 0, expT = 0;
//     for (var i = 0; i < sorted.length; i++) {
//       final tx = sorted[i]; final r = i + 2; final isI = tx.type == 'INC';
//       if (isI) incT += tx.amount; else expT += tx.amount;
//       _addStyledCell(sheetObject, 0, r, TextCellValue(DateFormat('yyyy-MM-dd').format(tx.transactionDate)), isInc: isI, isExp: !isI);
//       _addStyledCell(sheetObject, 1, r, TextCellValue(isI ? tr('COMMON_INCOME', '수입') : tr('COMMON_EXPENSE', '지출')), isInc: isI, isExp: !isI);
//       _addStyledCell(sheetObject, 2, r, TextCellValue(tx.category.startsWith('CAT_') ? tr(tx.category, tx.category) : tx.category), isInc: isI, isExp: !isI);
//       _addStyledCell(sheetObject, 3, r, TextCellValue(_numberFormat.format(tx.amount)), isInc: isI, isExp: !isI);
//       _addStyledCell(sheetObject, 4, r, TextCellValue(tx.memo ?? ''), isInc: isI, isExp: !isI);
//     }
//
//     int sR = sorted.length + 4;
//     _addSummaryRow(sheetObject, sR, tr('REPORT_EXCEL_TOTAL_INCOME', '총 수입 (+)'), incT, "#E3F2FD");
//     _addSummaryRow(sheetObject, sR + 1, tr('REPORT_EXCEL_TOTAL_EXPENSE', '총 지출 (-)'), expT, "#FFEBEE");
//     _addSummaryRow(sheetObject, sR + 2, tr('REPORT_EXCEL_TOTAL_PROFIT', '최종 수익 (수지차액)'), incT - expT, "#F1F8E9");
//
//     final dir = await getApplicationDocumentsDirectory();
//     final path = '${dir.path}/SiRE_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
//     final bytes = excel.save();
//     if (bytes != null) { File(path)..createSync(recursive: true)..writeAsBytesSync(bytes); await Share.shareXFiles([XFile(path)], text: tr('REPORT_EXCEL_MAIN_TITLE', 'SiRE Report')); }
//   }
//
//   // 📍 미납 명단 엑셀 추출
//   Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
//     final l10n = ref.read(localizationProvider.notifier);
//     String tr(String key, String fallback) { final val = l10n.translate(key); return (val.isEmpty || val == key) ? fallback : val; }
//     var excel = Excel.createExcel();
//     final sheetName = tr('REPORT_SEC_UNPAID', '미납 관리');
//     Sheet sheetObject = excel[sheetName];
//     excel.setDefaultSheet(sheetName);
//     sheetObject.setColumnWidth(0, 10); sheetObject.setColumnWidth(1, 15); sheetObject.setColumnWidth(2, 15); sheetObject.setColumnWidth(3, 10); sheetObject.setColumnWidth(4, 15); sheetObject.setColumnWidth(5, 15); sheetObject.setColumnWidth(6, 15);
//     sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
//     var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
//     titleCell.value = TextCellValue(tr('REPORT_EXCEL_UNPAID_TITLE', '임대료 미납 관리 명세서'));
//     titleCell.cellStyle = _getMainTitleStyle();
//     final String curLabel = tr('COMMON_CURRENCY_WON', '원');
//     List<String> headers = [tr('PROP_ROOM_NUMBER_LABEL', '호수'), tr('PROP_TENANT_NAME_LABEL', '세입자'), tr('PROP_PHONE_LABEL', '연락처'), tr('PROP_PAYMENT_STATUS', '상태'), "${tr('STATUS_PAID', '입금액')} ($curLabel)", "${tr('CAT_RENT', '월세')} ($curLabel)", tr('FILTER_EXPIRY_DATE', '납기일')];
//     for (var i = 0; i < headers.length; i++) { var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)); cell.value = TextCellValue(headers[i]); cell.cellStyle = _getHeaderStyle(); }
//     for (var i = 0; i < unpaidList.length; i++) {
//       final u = unpaidList[i]; final r = i + 2;
//       _addStyledCell(sheetObject, 0, r, TextCellValue(u.unit.roomNumber));
//       _addStyledCell(sheetObject, 1, r, TextCellValue(u.unit.tenantName ?? '-'));
//       _addStyledCell(sheetObject, 2, r, TextCellValue(u.unit.tenantPhone ?? '-'));
//       _addStyledCell(sheetObject, 3, r, TextCellValue(u.status == 'OVERDUE' ? tr('STATUS_OVERDUE', '미납') : tr('STATUS_WAITING', '대기')));
//       _addStyledCell(sheetObject, 4, r, TextCellValue(_numberFormat.format(u.paidAmount)));
//       _addStyledCell(sheetObject, 5, r, TextCellValue(_numberFormat.format(u.unit.monthlyRent)));
//       _addStyledCell(sheetObject, 6, r, TextCellValue(DateFormat('yyyy-MM-dd').format(u.dueDate)));
//     }
//     final dir = await getApplicationDocumentsDirectory();
//     final path = '${dir.path}/Unpaid_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
//     final bytes = excel.save();
//     if (bytes != null) { File(path)..createSync(recursive: true)..writeAsBytesSync(bytes); await Share.shareXFiles([XFile(path)], text: tr('REPORT_EXCEL_UNPAID_TITLE', 'Unpaid Report')); }
//   }
//
//   void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) { var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)); cell.value = value; cell.cellStyle = _getDataStyle(isInc: isInc, isExp: isExp); }
//   void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) { final style = _getTotalStyle(colorHex); var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)); titleCell.value = TextCellValue(title); titleCell.cellStyle = style; var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)); amountCell.value = TextCellValue(_numberFormat.format(amount)); amountCell.cellStyle = style; }
// }


import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/database/app_database.dart';
import '../ledger/unpaid_provider.dart';

class ExcelExportService {
  final _numberFormat = NumberFormat('#,###');

  CellStyle _getMainTitleStyle() => CellStyle(backgroundColorHex: ExcelColor.fromHexString("#1A237E"), fontColorHex: ExcelColor.fromHexString("#FFFFFF"), bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
  CellStyle _getHeaderStyle() => CellStyle(backgroundColorHex: ExcelColor.fromHexString("#E8EAF6"), fontColorHex: ExcelColor.fromHexString("#1A237E"), bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
  CellStyle _getDataStyle({bool isInc = false, bool isExp = false}) => CellStyle(fontColorHex: isInc ? ExcelColor.fromHexString("#0D47A1") : (isExp ? ExcelColor.fromHexString("#B71C1C") : ExcelColor.fromHexString("#000000")), horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);
  CellStyle _getTotalStyle(String hexColor) => CellStyle(backgroundColorHex: ExcelColor.fromHexString(hexColor), bold: true, horizontalAlign: HorizontalAlign.Center, verticalAlign: VerticalAlign.Center);

  // 📍 엑셀 추출 (세무 리포트)
  Future<void> exportTransactionsToExcel(List<Transaction> transactions, WidgetRef ref) async {
    final l10n = ref.read(localizationProvider.notifier);

    // ✅ [해결] 키값이 안 나오게 막아주는 안전 헬퍼 함수
    String tr(String key, String fallback) {
      final val = l10n.translate(key);
      return (val.isEmpty || val == key) ? fallback : val;
    }

    final sorted = List<Transaction>.from(transactions)..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
    var excel = Excel.createExcel();
    final sheetName = tr('NAV_LEDGER', '장부 관리');
    Sheet sheetObject = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    sheetObject.setColumnWidth(0, 18); sheetObject.setColumnWidth(1, 12); sheetObject.setColumnWidth(2, 22); sheetObject.setColumnWidth(3, 20); sheetObject.setColumnWidth(4, 35);
    sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));

    var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    titleCell.value = TextCellValue(tr('REPORT_EXCEL_MAIN_TITLE', 'SiRE 자산 경영 리포트 (세무 증빙용)'));
    titleCell.cellStyle = _getMainTitleStyle();

    final String amtLabel = tr('COMMON_AMOUNT', '금액');
    final String curLabel = tr('COMMON_CURRENCY_WON', '원');
    List<String> headers = [tr('REPORT_EXCEL_COLUMN_DATE', '거래일자'), tr('REPORT_EXCEL_COLUMN_TYPE', '수입/지출'), tr('COMMON_CATEGORY', '항목'), "$amtLabel ($curLabel)", tr('COMMON_MEMO_HINT', '비고(메모)')];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _getHeaderStyle();
    }

    int incT = 0, expT = 0;
    for (var i = 0; i < sorted.length; i++) {
      final tx = sorted[i]; final r = i + 2; final isI = tx.type == 'INC';
      if (isI) incT += tx.amount; else expT += tx.amount;
      _addStyledCell(sheetObject, 0, r, TextCellValue(DateFormat('yyyy-MM-dd').format(tx.transactionDate)), isInc: isI, isExp: !isI);
      _addStyledCell(sheetObject, 1, r, TextCellValue(isI ? tr('COMMON_INCOME', '수입') : tr('COMMON_EXPENSE', '지출')), isInc: isI, isExp: !isI);
      _addStyledCell(sheetObject, 2, r, TextCellValue(tx.category.startsWith('CAT_') ? tr(tx.category, tx.category) : tx.category), isInc: isI, isExp: !isI);
      _addStyledCell(sheetObject, 3, r, TextCellValue(_numberFormat.format(tx.amount)), isInc: isI, isExp: !isI);
      _addStyledCell(sheetObject, 4, r, TextCellValue(tx.memo ?? ''), isInc: isI, isExp: !isI);
    }

    int sR = sorted.length + 4;
    _addSummaryRow(sheetObject, sR, tr('REPORT_EXCEL_TOTAL_INCOME', '총 수입 (+)'), incT, "#E3F2FD");
    _addSummaryRow(sheetObject, sR + 1, tr('REPORT_EXCEL_TOTAL_EXPENSE', '총 지출 (-)'), expT, "#FFEBEE");
    _addSummaryRow(sheetObject, sR + 2, tr('REPORT_EXCEL_TOTAL_PROFIT', '최종 수익 (수지차액)'), incT - expT, "#F1F8E9");

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/SiRE_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final bytes = excel.save();
    if (bytes != null) { File(path)..createSync(recursive: true)..writeAsBytesSync(bytes); await Share.shareXFiles([XFile(path)], text: tr('REPORT_EXCEL_MAIN_TITLE', 'SiRE Report')); }
  }

  // 📍 미납 명단 엑셀 추출
  Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList, WidgetRef ref) async {
    final l10n = ref.read(localizationProvider.notifier);
    String tr(String key, String fallback) { final val = l10n.translate(key); return (val.isEmpty || val == key) ? fallback : val; }
    var excel = Excel.createExcel();
    final sheetName = tr('REPORT_SEC_UNPAID', '미납 관리');
    Sheet sheetObject = excel[sheetName];
    excel.setDefaultSheet(sheetName);
    sheetObject.setColumnWidth(0, 10); sheetObject.setColumnWidth(1, 15); sheetObject.setColumnWidth(2, 15); sheetObject.setColumnWidth(3, 10); sheetObject.setColumnWidth(4, 15); sheetObject.setColumnWidth(5, 15); sheetObject.setColumnWidth(6, 15);
    sheetObject.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
    var titleCell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    titleCell.value = TextCellValue(tr('REPORT_EXCEL_UNPAID_TITLE', '임대료 미납 관리 명세서'));
    titleCell.cellStyle = _getMainTitleStyle();
    final String curLabel = tr('COMMON_CURRENCY_WON', '원');
    List<String> headers = [tr('PROP_ROOM_NUMBER_LABEL', '호수'), tr('PROP_TENANT_NAME_LABEL', '세입자'), tr('PROP_PHONE_LABEL', '연락처'), tr('PROP_PAYMENT_STATUS', '상태'), "${tr('STATUS_PAID', '입금액')} ($curLabel)", "${tr('CAT_RENT', '월세')} ($curLabel)", tr('FILTER_EXPIRY_DATE', '납기일')];
    for (var i = 0; i < headers.length; i++) { var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)); cell.value = TextCellValue(headers[i]); cell.cellStyle = _getHeaderStyle(); }
    for (var i = 0; i < unpaidList.length; i++) {
      final u = unpaidList[i]; final r = i + 2;
      _addStyledCell(sheetObject, 0, r, TextCellValue(u.unit.roomNumber));
      _addStyledCell(sheetObject, 1, r, TextCellValue(u.unit.tenantName ?? '-'));
      _addStyledCell(sheetObject, 2, r, TextCellValue(u.unit.tenantPhone ?? '-'));
      _addStyledCell(sheetObject, 3, r, TextCellValue(u.status == 'OVERDUE' ? tr('STATUS_OVERDUE', '미납') : tr('STATUS_WAITING', '대기')));
      _addStyledCell(sheetObject, 4, r, TextCellValue(_numberFormat.format(u.paidAmount)));
      _addStyledCell(sheetObject, 5, r, TextCellValue(_numberFormat.format(u.unit.monthlyRent)));
      _addStyledCell(sheetObject, 6, r, TextCellValue(DateFormat('yyyy-MM-dd').format(u.dueDate)));
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/Unpaid_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final bytes = excel.save();
    if (bytes != null) { File(path)..createSync(recursive: true)..writeAsBytesSync(bytes); await Share.shareXFiles([XFile(path)], text: tr('REPORT_EXCEL_UNPAID_TITLE', 'Unpaid Report')); }
  }

  void _addStyledCell(Sheet sheet, int col, int row, CellValue value, {bool isInc = false, bool isExp = false}) { var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)); cell.value = value; cell.cellStyle = _getDataStyle(isInc: isInc, isExp: isExp); }
  void _addSummaryRow(Sheet sheet, int row, String title, int amount, String colorHex) { final style = _getTotalStyle(colorHex); var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)); titleCell.value = TextCellValue(title); titleCell.cellStyle = style; var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)); amountCell.value = TextCellValue(_numberFormat.format(amount)); amountCell.cellStyle = style; }
}