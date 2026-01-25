import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅
import 'package:path/path.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import 'property_provider.dart';
// 📍 미납 상태 리프레시 및 실시간 판단을 위해 추가
import '../ledger/unpaid_provider.dart';
import '../ledger/ledger_provider.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomDetailScreen extends ConsumerWidget {
  final Unit unit;

  const RoomDetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;

    // 📍 실시간 미납 리스트 상태 감시 (아이콘 색상 결정용)
    final unpaidAsync = ref.watch(unpaidListProvider);

    return StreamBuilder<Unit>(
      stream: (db.select(db.units)..where((u) => u.id.equals(unit.id))).watchSingle(),
      initialData: unit,
      builder: (context, snapshot) {
        final currentUnit = snapshot.data ?? unit;

        // 📍 장부 기반 실시간 연체 판단 로직
        bool isRealOverdue = false;
        unpaidAsync.whenData((list) {
          final myStatus = list.firstWhere(
                (s) => s.unit.id == currentUnit.id,
            orElse: () => UnpaidStatus(
                unit: currentUnit,
                status: 'WAITING',
                paidAmount: 0,
                dueDate: DateTime.now()
            ),
          );
          isRealOverdue = myStatus.status == 'OVERDUE';
        });

        // UI 스타일 결정 (메모에 '밀림'이 있거나, 장부상 OVERDUE인 경우 모두 포함)
        final bool isOverdueUI = isRealOverdue || (currentUnit.memo?.contains('밀림') ?? false);
        final statusColor = isOverdueUI ? AppColors.expenseRed : AppColors.primaryNavy;
        final statusText = isOverdueUI ? "(${'STATUS_OVERDUE'.tr(ref)})" : "";

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text("${currentUnit.roomNumber}${'COMMON_ROOM_UNIT'.tr(ref)} ${'PROP_VIEW_DETAIL'.tr(ref)} $statusText"),
            backgroundColor: statusColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, ref, currentUnit),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref, currentUnit),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTenantInfoCard(currentUnit, isOverdueUI, context, ref), // 📍 연체 여부 전달
                _buildRentPaymentCard(context, ref, currentUnit), // 📍 수납 버튼 섹션 추가
                const SizedBox(height: 20),
                _buildContractCard(currentUnit, ref, currentLang),
                const SizedBox(height: 20),
                Text("PROP_MEMO_PHOTO_TITLE".tr(ref), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PROP_ADMIN_MEMO".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(currentUnit.memo ?? "PROP_NO_MEMO".tr(ref),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("PROP_ROOM_GALLERY".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          TextButton.icon(
                            onPressed: () => _pickAndAddImages(ref, currentUnit),
                            icon: const Icon(Icons.add_a_photo, size: 18),
                            label: Text("COMMON_ADD_PHOTO".tr(ref)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildMultiPhotoGallery(context, ref, currentUnit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. 세입자 정보 카드 (연락처 및 유형 표시)
  Widget _buildTenantInfoCard(Unit currentUnit, bool isOverdue, BuildContext context, WidgetRef ref) {
    final rawLeaseType = currentUnit.leaseType ?? '공실';
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    // 📍 [화폐 다국어] 국가별 통화 포매터 정의
    final currencyFmt = NumberFormat.simpleCurrency(locale: currentLang, decimalDigits: 0);

    String leaseTypeLabel = "";
    if (rawLeaseType == '공실') leaseTypeLabel = 'DASHBOARD_VACANT_UNITS'.tr(ref);
    else if (rawLeaseType == '월세') leaseTypeLabel = 'LEASE_MONTHLY'.tr(ref);
    else if (rawLeaseType == '전세') leaseTypeLabel = 'LEASE_JEONSE'.tr(ref);
    else if (rawLeaseType == '반전세') leaseTypeLabel = 'LEASE_HALF_JEONSE'.tr(ref);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: rawLeaseType == '공실' ? Colors.grey : AppColors.primaryNavy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(leaseTypeLabel, style: TextStyle(color: rawLeaseType == '공실' ? Colors.white : AppColors.primaryNavy, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(currentUnit.tenantName ?? "PROP_NO_TENANT".tr(ref), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              if (rawLeaseType != '공실')
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: IconButton(onPressed: () => _makePhoneCall(currentUnit.tenantPhone ?? ""), icon: const Icon(Icons.phone, color: Colors.green)),
                    ),
                    const SizedBox(width: 8),
                    // 📍 독촉 문자 발송 로직 적용 (isOverdue에 따라 아이콘과 기능 가변)
                    CircleAvatar(
                      backgroundColor: isOverdue ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                      child: IconButton(
                          onPressed: () {
                            if (isOverdue) {
                              _sendRemindSMS(currentUnit, context, ref); // 연체 시 독촉 양식 발송
                            } else {
                              _sendSMS(currentUnit.tenantPhone ?? ""); // 일반 문자 발송
                            }
                          },
                          icon: Icon(
                              isOverdue ? Icons.notification_important : Icons.message,
                              color: isOverdue ? Colors.orange : Colors.blue
                          )
                      ),
                    ),
                  ],
                )
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 📍 [수정] 보증금 및 임대료 금액 표시 다국어 포맷 적용
              _infoItem("CAT_DEPOSIT".tr(ref), currencyFmt.format(currentUnit.deposit)),
              if (rawLeaseType == '월세' || rawLeaseType == '반전세')
                _infoItem("CAT_RENT".tr(ref), currencyFmt.format(currentUnit.monthlyRent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 2. 계약 상세 정보 카드
  Widget _buildContractCard(Unit currentUnit, WidgetRef ref, String lang) {
    if (currentUnit.leaseType == '공실' || currentUnit.leaseType == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text("PROP_NO_CONTRACT_INFO".tr(ref), style: const TextStyle(color: Colors.grey))),
      );
    }

    final startDate = currentUnit.contractStart != null ? DateFormat.yMd(lang).format(currentUnit.contractStart!) : "-";
    final endDate = currentUnit.contractEnd != null ? DateFormat.yMd(lang).format(currentUnit.contractEnd!) : "-";
    final paymentDay = currentUnit.paymentDay != null ? "${'PROP_EVERY_MONTH'.tr(ref)} ${currentUnit.paymentDay}${ 'PROP_DAY_UNIT'.tr(ref)}" : "COMMON_ERROR".tr(ref);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text("PROP_CONTRACT_DETAIL_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _contractRow("PROP_CONTRACT_PERIOD".tr(ref), "$startDate ~ $endDate"),
          if (currentUnit.leaseType != '전세') ...[
            const SizedBox(height: 10),
            _contractRow("PROP_PAYMENT_DAY_LABEL".tr(ref), paymentDay),
          ],
        ],
      ),
    );
  }

  // 📍 수정된 월세 수납 현황 카드 (화폐 다국어 적용)
  Widget _buildRentPaymentCard(BuildContext context, WidgetRef ref, Unit currentUnit) {
    if (currentUnit.leaseType == '공실' || currentUnit.leaseType == '전세') {
      return const SizedBox.shrink();
    }

    final db = ref.watch(databaseProvider);
    final now = DateTime.now();
    final lang = ref.watch(localizationProvider.notifier).currentLang;
    final currentMonthLabel = DateFormat.yMMMM(lang).format(now);
    // 📍 [화폐 다국어] 통화 포매터 정의
    final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

    // 📍 DB에서 이번 달, 이 호실의 수납 내역이 있는지 실시간 감시
    return StreamBuilder<List<Transaction>>(
      stream: (db.select(db.transactions)
        ..where((t) =>
        t.unitId.equals(currentUnit.id) &
        t.transactionDate.year.equals(now.year) &
        t.transactionDate.month.equals(now.month) &
        (t.category.equals('월세') | t.category.equals('CAT_RENT'))))
          .watch(),
      builder: (context, snapshot) {
        final isPaid = snapshot.hasData && snapshot.data!.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPaid ? Colors.green.withOpacity(0.3) : AppColors.primaryNavy.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$currentMonthLabel ${'PROP_PAYMENT_STATUS'.tr(ref)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Icon(
                    isPaid ? Icons.check_circle : Icons.monetization_on,
                    color: isPaid ? Colors.green : AppColors.incomeGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PROP_MONTHLY_RENT_THIS_MONTH".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        // 📍 [수정] 수납 카드 내 금액 표시 다국어 포맷 적용
                        Text(currencyFmt.format(currentUnit.monthlyRent),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // 📍 수납 여부에 따라 버튼 상태 변경
                  ElevatedButton.icon(
                    onPressed: isPaid ? null : () => _handleRentPayment(context, ref, currentUnit),
                    icon: Icon(isPaid ? Icons.done_all : Icons.check_circle),
                    label: Text(isPaid ? "STATUS_PAID".tr(ref) : "DASHBOARD_PAYMENT_CONFIRM".tr(ref)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaid ? Colors.grey : AppColors.incomeGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              if (isPaid)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("PROP_ALREADY_RECORDED_MSG".tr(ref),
                      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }

  // 📍 수납 핸들러 (기존 유지)
  Future<void> _handleRentPayment(BuildContext context, WidgetRef ref, Unit unit) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final l10n = ref.read(localizationProvider.notifier);

    // 1. 중복 체크: 이번 달 동일 호실의 '월세' 수납 내역 확인
    final existing = await (db.select(db.transactions)
      ..where((t) =>
      t.unitId.equals(unit.id) &
      t.transactionDate.year.equals(now.year) &
      t.transactionDate.month.equals(now.month) &
      (t.category.equals('월세') | t.category.equals('CAT_RENT'))))
        .get();

    if (existing.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PROP_ALREADY_RECORDED_MSG".tr(ref))));
      }
      return;
    }

    try {
      // 2. 장부에 데이터 추가 (type을 '수입'으로 명확히 기록)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          buildingId: unit.buildingId,
          unitId: Value(unit.id),
          type: 'INC',
          category: 'CAT_RENT',
          amount: unit.monthlyRent,
          transactionDate: now,
          memo: Value("${unit.roomNumber}${l10n.translate('COMMON_ROOM_UNIT')} ${now.month}${l10n.translate('COMMON_MONTH_UNIT')} ${l10n.translate('CAT_RENT')} ${l10n.translate('STATUS_PAID')}"),
        ),
      );

      // 3. 호실 메모 업데이트 (연체 문구 자동 제거)
      if (unit.memo?.contains('밀림') ?? false) {
        await (db.update(db.units)..where((u) => u.id.equals(unit.id))).write(
          UnitsCompanion(memo: Value(unit.memo!.replaceAll('밀림', '').trim())),
        );
      }

      // 📍 핵심: 모든 관련 프로바이더 무효화하여 즉시 반영
      ref.invalidate(unpaidListProvider);   // 미납 리스트 갱신
      ref.invalidate(propertyListProvider); // 호실 그리드 갱신
      ref.invalidate(ledgerListProvider);   // 장부 리스트 갱신
      ref.invalidate(dashboardDataProvider); // 대시보드 요약 갱신

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${unit.roomNumber}${l10n.translate('COMMON_ROOM_UNIT')} ${l10n.translate('STATUS_PAID')}")));
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("COMMON_ERROR".tr(ref))));
      }
    }
  }

  // 📍 독촉 문자 발송 로직 (화폐 다국어 적용)
  Future<void> _sendRemindSMS(Unit unit, BuildContext context, WidgetRef ref) async {
    if (unit.tenantPhone == null || unit.tenantPhone!.isEmpty) return;

    final now = DateTime.now();
    final lang = ref.read(localizationProvider.notifier).currentLang;
    // 📍 [화폐 다국어] 독촉 문자 내 금액 포맷팅을 위해 포매터 생성
    final currencyFmt = NumberFormat.simpleCurrency(locale: lang, decimalDigits: 0);

    final String msgTemplate = "PROP_SMS_REMIND_TEMPLATE".tr(ref);
    final String message = msgTemplate
        .replaceAll("{tenant}", unit.tenantName ?? "")
        .replaceAll("{month}", "${now.month}")
    // 📍 [수정] 독촉 문자 속 금액 표시를 로케일에 맞게 다국어 포맷으로 변경
        .replaceAll("{amount}", currencyFmt.format(unit.monthlyRent));

    final String encodedMessage = Uri.encodeComponent(message).replaceAll('+', '%20');
    final String smsUrl = Platform.isAndroid
        ? "sms:${unit.tenantPhone}?body=$encodedMessage"
        : "sms:${unit.tenantPhone}&body=$encodedMessage";

    final Uri uri = Uri.parse(smsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ALERT_SMS_APP_ERROR".tr(ref))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'COMMON_ERROR'.tr(ref)}: $e")));
      }
    }
  }

  Widget _contractRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  // 3. 다중 사진 갤러리 및 로직 (기존 유지)
  Widget _buildMultiPhotoGallery(BuildContext context, WidgetRef ref, Unit currentUnit) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<UnitImage>>(
      stream: (db.select(db.unitImages)..where((t) => t.unitId.equals(currentUnit.id))).watch(),
      builder: (context, snapshot) {
        final images = snapshot.data ?? [];
        if (images.isEmpty) {
          return GestureDetector(
            onTap: () => _pickAndAddImages(ref, currentUnit),
            child: Container(
              height: 100, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid)),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.photo_library, color: Colors.grey), Text("PROP_NO_PHOTO_DESC".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            ),
          );
        }
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final img = images[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showFullScreenImage(context, img.imagePath),
                    child: Container(
                      width: 120, margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)], image: DecorationImage(image: FileImage(File(img.imagePath)), fit: BoxFit.cover)),
                    ),
                  ),
                  Positioned(
                    top: 5, right: 17,
                    child: GestureDetector(
                      onTap: () async {
                        await (db.delete(db.unitImages)..where((t) => t.id.equals(img.id))).go();
                      },
                      child: const CircleAvatar(radius: 12, backgroundColor: Colors.black87, child: Icon(Icons.close, size: 14, color: Colors.white)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // 4. 고도화된 정보 수정 다이얼로그 (화폐 다국어 대응)
  void _showEditDialog(BuildContext context, WidgetRef ref, Unit currentUnit) {
    final roomController = TextEditingController(text: currentUnit.roomNumber);
    final tenantController = TextEditingController(text: currentUnit.tenantName);
    final phoneController = TextEditingController(text: currentUnit.tenantPhone);
    final depositController = TextEditingController(text: currentUnit.deposit.toString());
    final rentController = TextEditingController(text: currentUnit.monthlyRent.toString());
    final paymentDayController = TextEditingController(text: currentUnit.paymentDay?.toString() ?? "");
    final memoController = TextEditingController(text: currentUnit.memo);

    String selectedType = currentUnit.leaseType ?? '공실';
    DateTime? startDate = currentUnit.contractStart;
    DateTime? endDate = currentUnit.contractEnd;

    // 📍 [화폐 다국어] 다이얼로그 내 심볼 표시용
    final currentLang = ref.read(localizationProvider.notifier).currentLang;
    final currencySymbol = NumberFormat.simpleCurrency(locale: currentLang).currencySymbol;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("PROP_EDIT_INFO_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: roomController, decoration: InputDecoration(labelText: "PROP_ROOM_NUMBER_LABEL".tr(ref), border: const OutlineInputBorder(), isDense: true)),
                    const SizedBox(height: 20),
                    Text("PROP_LEASE_TYPE_LABEL".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    LayoutBuilder(builder: (context, constraints) {
                      final types = ['월세', '전세', '반전세', '공실'];
                      final labels = [
                        'LEASE_MONTHLY_SHORT'.tr(ref),
                        'LEASE_JEONSE_SHORT'.tr(ref),
                        'LEASE_HALF_JEONSE_SHORT'.tr(ref),
                        'DASHBOARD_VACANT_UNITS'.tr(ref)
                      ];
                      return ToggleButtons(
                        isSelected: types.map((e) => selectedType == e).toList(),
                        onPressed: (index) => setState(() => selectedType = types[index]),
                        borderRadius: BorderRadius.circular(8),
                        constraints: BoxConstraints(minWidth: (constraints.maxWidth - 5) / 4, minHeight: 45),
                        children: labels.map((l) => Text(l)).toList(),
                      );
                    }),
                    if (selectedType != '공실') ...[
                      const SizedBox(height: 20),
                      TextField(controller: tenantController, decoration: InputDecoration(labelText: "PROP_TENANT_NAME_LABEL".tr(ref), border: const OutlineInputBorder(), isDense: true)),
                      const SizedBox(height: 12),
                      TextField(controller: phoneController, decoration: InputDecoration(labelText: "PROP_PHONE_LABEL".tr(ref), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      // 📍 [수정] 보증금 및 임대료 입력창 레이블에 다국어 심볼 적용
                      TextField(controller: depositController, decoration: InputDecoration(labelText: "${'CAT_DEPOSIT'.tr(ref)} ($currencySymbol)", border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                      if (selectedType == '월세' || selectedType == '반전세') ...[
                        const SizedBox(height: 12),
                        TextField(controller: rentController, decoration: InputDecoration(labelText: "${'CAT_RENT'.tr(ref)} ($currencySymbol)", border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        const SizedBox(height: 12),
                        TextField(controller: paymentDayController, decoration: InputDecoration(labelText: "PROP_PAYMENT_DAY_LABEL".tr(ref), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () async {
                            final picked = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (picked != null) setState(() => startDate = picked);
                          }, child: Text(startDate == null ? 'PROP_START_DATE'.tr(ref) : DateFormat('yy-MM-dd').format(startDate!)))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('~')),
                          Expanded(child: OutlinedButton(onPressed: () async {
                            final picked = await showDatePicker(context: context, initialDate: endDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (picked != null) setState(() => endDate = picked);
                          }, child: Text(endDate == null ? 'PROP_END_DATE'.tr(ref) : DateFormat('yy-MM-dd').format(endDate!)))),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(controller: memoController, decoration: InputDecoration(labelText: "PROP_ADMIN_MEMO".tr(ref), border: const OutlineInputBorder(), isDense: true), maxLines: 2),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(databaseProvider);
                await (db.update(db.units)..where((u) => u.id.equals(currentUnit.id))).write(
                  UnitsCompanion(
                    roomNumber: Value(roomController.text),
                    leaseType: Value(selectedType),
                    tenantName: Value(tenantController.text),
                    tenantPhone: Value(phoneController.text),
                    deposit: Value(int.tryParse(depositController.text) ?? 0),
                    monthlyRent: Value(int.tryParse(rentController.text) ?? 0),
                    paymentDay: Value(int.tryParse(paymentDayController.text)),
                    contractStart: Value(startDate),
                    contractEnd: Value(endDate),
                    memo: Value(memoController.text),
                  ),
                );
                // 📍 수정 시에도 상태 갱신
                ref.invalidate(propertyListProvider);
                ref.invalidate(unpaidListProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text("COMMON_SAVE".tr(ref)),
            ),
          ],
        ),
      ),
    );
  }

  // 나머지 헬퍼 함수들 (기존 유지)
  Future<void> _pickAndAddImages(WidgetRef ref, Unit currentUnit) async {
    final picker = ImagePicker();
    final List<XFile> selectedFiles = await picker.pickMultiImage(imageQuality: 70);
    if (selectedFiles.isNotEmpty) {
      final db = ref.read(databaseProvider);
      for (var file in selectedFiles) {
        await db.into(db.unitImages).insert(UnitImagesCompanion.insert(unitId: currentUnit.id, imagePath: file.path));
      }
      ref.invalidate(propertyListProvider);
    }
  }

  void _showFullScreenImage(BuildContext context, String path) {
    showDialog(context: context, builder: (context) => Dialog(backgroundColor: Colors.black, insetPadding: EdgeInsets.zero, child: Stack(alignment: Alignment.center, children: [InteractiveViewer(child: Image.file(File(path))), Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)))])));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Unit currentUnit) {
    showDialog(context: context, builder: (context) => AlertDialog(title: Text("PROP_DELETE_UNIT".tr(ref)), content: Text("PROP_DELETE_CONFIRM_DESC".tr(ref)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))), ElevatedButton(onPressed: () async { final db = ref.read(databaseProvider); await (db.delete(db.units)..where((u) => u.id.equals(currentUnit.id))).go(); ref.invalidate(propertyListProvider); ref.invalidate(unpaidListProvider); if (context.mounted) { Navigator.pop(context); Navigator.pop(context); } }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed), child: Text("COMMON_DELETE".tr(ref), style: const TextStyle(color: Colors.white)))]));
  }

  Future<void> _makePhoneCall(String phoneNumber) async { if (phoneNumber.isEmpty) return; final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber); if (await canLaunchUrl(launchUri)) await launchUrl(launchUri); }
  Future<void> _sendSMS(String phoneNumber) async { if (phoneNumber.isEmpty) return; final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber); if (await canLaunchUrl(launchUri)) await launchUrl(launchUri); }
}