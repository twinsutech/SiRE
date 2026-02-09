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