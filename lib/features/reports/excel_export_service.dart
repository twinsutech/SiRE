import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart'; // Transaction 모델 사용
import '../ledger/unpaid_provider.dart'; // 📍 UnpaidStatus 모델 사용을 위해 추가

class ExcelExportService {

  // 엑셀 파일 생성 및 공유 함수
  Future<void> exportTransactionsToExcel(List<Transaction> transactions) async {
    // 📍 엑셀 저장 전 데이터를 날짜순(오름차순)으로 정렬하여 장부 가독성 향상
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    // 1. 엑셀 객체 생성
    var excel = Excel.createExcel();

    // 기본 Sheet 이름 변경
    Sheet sheetObject = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    // 2. 헤더(제목) 줄 만들기
    List<String> headers = ['Date', 'Type', 'Category', 'Amount', 'Memo'];

    // 스타일: 볼드체, 가운데 정렬 (라이브러리 버전에 따라 스타일 적용 방식이 다를 수 있어 기본값 사용)
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 3. 데이터 한 줄씩 추가하기
    for (var tx in transactions) {
      final date = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
      // 📍 가독성을 위해 INC/EXP를 수입/지출로 변환하여 저장
      final type = tx.type == 'INC' ? '수입' : '지출';
      final category = tx.category;
      final amount = tx.amount;
      final memo = tx.memo ?? '';

      sheetObject.appendRow([
        TextCellValue(date),
        TextCellValue(type),
        TextCellValue(category),
        IntCellValue(amount), // 숫자는 IntCellValue
        TextCellValue(memo),
      ]);
    }

    // 4. 파일로 저장하기
    // 앱 전용 임시 폴더 경로 가져오기
    final directory = await getApplicationDocumentsDirectory();
    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'Tax_Report_$now.xlsx';
    final filePath = '${directory.path}/$fileName';

    // 파일 생성 및 쓰기
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      // 5. 공유하기 (Share Sheet 띄우기)
      // 사용자가 카톡, 이메일, 파일 앱 등으로 보낼 수 있음
      await Share.shareXFiles([XFile(filePath)], text: 'SiRE Tax Report Export');
    }
  }

  // ---------------------------------------------------------------------------
  // 📍 [추가] 미납 내역 전용 엑셀 생성 및 공유 함수
  // ---------------------------------------------------------------------------
  Future<void> exportUnpaidListToExcel(List<UnpaidStatus> unpaidList) async {
    // 1. 엑셀 객체 생성
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Unpaid_List'];
    excel.setDefaultSheet('Unpaid_List');

    // 2. 헤더 구성
    List<String> headers = ['호수', '세입자', '연락처', '상태', '이번달 입금액', '월세금액', '납기일'];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 3. 미납 데이터 추가
    for (var unpaid in unpaidList) {
      final roomNo = unpaid.unit.roomNumber;
      final tenant = unpaid.unit.tenantName ?? '-';
      final phone = unpaid.unit.tenantPhone ?? '-';
      final status = unpaid.status == 'OVERDUE' ? '연체' : '입금대기';
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

    // 4. 파일 저장 및 경로 설정
    final directory = await getApplicationDocumentsDirectory();
    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'Unpaid_Report_$now.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      // 5. 공유하기
      await Share.shareXFiles([XFile(filePath)], text: 'SiRE 미납 내역 리포트');
    }
  }
}