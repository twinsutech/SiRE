// import 'dart:io';
// import 'package:drift/drift.dart' hide Column;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../../core/database/database_provider.dart';
// import '../../core/database/app_database.dart';
// import 'property_provider.dart';
//
// // 📍 [핵심 수정] 비즈니스 로직 및 DB 저장을 위한 고정 키값 정의 (언어 변경에 무관)
// const String LEASE_TYPE_MONTHLY = '월세';
// const String LEASE_TYPE_JEONSE = '전세';
// const String LEASE_TYPE_HALF = '반전세';
// const String LEASE_TYPE_VACANT = '공실';
//
// class AddUnitDialog extends ConsumerStatefulWidget {
//   final int buildingId;
//   const AddUnitDialog({super.key, required this.buildingId});
//
//   @override
//   ConsumerState<AddUnitDialog> createState() => _AddUnitDialogState();
// }
//
// class _AddUnitDialogState extends ConsumerState<AddUnitDialog> {
//   final _roomController = TextEditingController();
//   final _tenantNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _depositController = TextEditingController(text: '0');
//   final _rentController = TextEditingController(text: '0');
//   final _paymentDayController = TextEditingController();
//   final _memoController = TextEditingController();
//
//   final List<XFile> _selectedImages = [];
//   final ImagePicker _picker = ImagePicker();
//
//   // 📍 초기값을 고정 키값으로 설정
//   String _selectedLeaseType = LEASE_TYPE_VACANT;
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   @override
//   void dispose() {
//     _roomController.dispose();
//     _tenantNameController.dispose();
//     _phoneController.dispose();
//     _depositController.dispose();
//     _rentController.dispose();
//     _paymentDayController.dispose();
//     _memoController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     // 📍 현재 설정된 언어 코드를 가져와 달력 로케일에 적용
//     final currentLang = ref.read(localizationProvider.notifier).currentLang;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       locale: Locale(currentLang), // 📍 달력 언어 설정 적용
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) _startDate = picked;
//         else _endDate = picked;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 [화폐 다국어 처리] 현재 언어 설정에 따른 통화 심볼 추출 ($ 또는 ₩ 등)
//     final currentLang = ref.watch(localizationProvider.notifier).currentLang;
//     final format = NumberFormat.simpleCurrency(locale: currentLang);
//     final String currencySymbol = format.currencySymbol;
//
//     return AlertDialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       // 📍 PROP_ADD_UNIT_TITLE 키 번역 적용 확인
//       title: Text("PROP_ADD_UNIT_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 PROP_SITE_PHOTOS 키 번역 적용
//                 Text("PROP_SITE_PHOTOS".tr(ref), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 _buildPhotoGallery(),
//                 const SizedBox(height: 24),
//                 // 📍 PROP_ROOM_NUMBER_LABEL 키 번역 적용
//                 _buildTextField(_roomController, "PROP_ROOM_NUMBER_LABEL".tr(ref)),
//                 const SizedBox(height: 20),
//                 _buildLeaseTypeToggle(),
//
//                 // 📍 [수정] 고정 키값을 비교하여 다국어 환경에서도 로직 유지
//                 if (_selectedLeaseType != LEASE_TYPE_VACANT) ...[
//                   const SizedBox(height: 20),
//                   // 📍 PROP_TENANT_NAME_LABEL 키 번역 적용
//                   _buildTextField(_tenantNameController, "PROP_TENANT_NAME_LABEL".tr(ref)),
//                   const SizedBox(height: 12),
//                   // 📍 PROP_PHONE_LABEL 키 번역 적용
//                   _buildTextField(_phoneController, "PROP_PHONE_LABEL".tr(ref), isNumber: true),
//                   const SizedBox(height: 12),
//
//                   // 📍 [수정] 보증금 입력 필드: CAT_DEPOSIT 번역과 화폐 심볼 동적 결합
//                   _buildTextField(
//                       _depositController,
//                       "${'CAT_DEPOSIT'.tr(ref)} ($currencySymbol)",
//                       isNumber: true
//                   ),
//
//                   // 📍 [수정] 고정 키값 비교 (월세 또는 반전세인 경우만 임대료 필드 노출)
//                   if (_selectedLeaseType == LEASE_TYPE_MONTHLY || _selectedLeaseType == LEASE_TYPE_HALF) ...[
//                     const SizedBox(height: 12),
//
//                     // 📍 [수정] 임대료 입력 필드: CAT_RENT 번역과 화폐 심볼 동적 결합
//                     _buildTextField(
//                         _rentController,
//                         "${'CAT_RENT'.tr(ref)} ($currencySymbol)",
//                         isNumber: true
//                     ),
//
//                     const SizedBox(height: 12),
//                     // 📍 PROP_PAYMENT_DAY_LABEL 키 번역 적용
//                     _buildTextField(_paymentDayController, "PROP_PAYMENT_DAY_LABEL".tr(ref), isNumber: true),
//                   ],
//                   const SizedBox(height: 20),
//                   _buildDateSection(),
//                 ],
//                 const SizedBox(height: 20),
//                 // 📍 COMMON_MEMO_HINT 키 번역 적용
//                 _buildTextField(_memoController, "COMMON_MEMO_HINT".tr(ref), maxLines: 2),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         // 📍 COMMON_CANCEL 키 번역 적용
//         TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
//         ElevatedButton(
//           onPressed: _saveUnit,
//           style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, minimumSize: const Size(100, 45)),
//           // 📍 PROP_ADD_UNIT_ACTION 키 번역 적용 확인
//           child: Text("PROP_ADD_UNIT_ACTION".tr(ref)),
//         ),
//       ],
//     );
//   }
//
//   // 일관된 디자인을 위한 헬퍼 위젯들
//   Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//       inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
//       decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           isDense: true
//       ),
//     );
//   }
//
//   Widget _buildLeaseTypeToggle() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "PROP_LEASE_TYPE_LABEL".tr(ref),
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 12),
//         LayoutBuilder(builder: (context, constraints) {
//           final types = [LEASE_TYPE_MONTHLY, LEASE_TYPE_JEONSE, LEASE_TYPE_HALF, LEASE_TYPE_VACANT];
//           final labels = [
//             'LEASE_MONTHLY_SHORT'.tr(ref),
//             'LEASE_JEONSE_SHORT'.tr(ref),
//             'LEASE_HALF_JEONSE_SHORT'.tr(ref),
//             'DASHBOARD_VACANT_UNITS'.tr(ref)
//           ];
//
//           // 📍 전체 가용 너비 (334.6px 등)
//           final double totalWidth = constraints.maxWidth;
//
//           return Container(
//             width: totalWidth,
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: ToggleButtons(
//               isSelected: types.map((e) => _selectedLeaseType == e).toList(),
//               onPressed: (index) => setState(() => _selectedLeaseType = types[index]),
//               borderRadius: BorderRadius.circular(10),
//               selectedColor: Colors.white,
//               fillColor: const Color(0xFF1A237E),
//               color: Colors.grey[700],
//               // 📍 핵심: constraints를 null로 설정하거나 아주 작게 주어
//               // 아래의 SizedBox가 실제 너비를 결정하게 합니다.
//               constraints: const BoxConstraints(minHeight: 48),
//               renderBorder: true,
//               children: List.generate(labels.length, (index) {
//                 return SizedBox(
//                   // 📍 전체 너비를 버튼 개수(4개)로 정확히 나눔 (테두리 두께 고려)
//                   width: (totalWidth - (labels.length + 1)) / labels.length,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown, // 📍 텍스트가 길면 자동으로 크기를 줄임
//                       alignment: Alignment.center,
//                       child: Text(
//                         labels[index],
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//
//   Widget _buildDateSection() {
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     return Row(
//       children: [
//         // 📍 PROP_START_DATE 및 선택된 날짜 다국어 포맷 적용
//         Expanded(child: OutlinedButton(onPressed: () => _selectDate(context, true), child: Text(_startDate == null ? 'PROP_START_DATE'.tr(ref) : DateFormat.yMd(lang).format(_startDate!)))),
//         const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('~')),
//         // 📍 PROP_END_DATE 및 선택된 날짜 다국어 포맷 적용
//         Expanded(child: OutlinedButton(onPressed: () => _selectDate(context, false), child: Text(_endDate == null ? 'PROP_END_DATE'.tr(ref) : DateFormat.yMd(lang).format(_endDate!)))),
//       ],
//     );
//   }
//
//   Widget _buildPhotoGallery() {
//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _selectedImages.length + 1,
//         itemBuilder: (context, index) {
//           if (index == _selectedImages.length) {
//             return GestureDetector(
//               onTap: () async {
//                 final picked = await _picker.pickMultiImage(imageQuality: 70);
//                 if (picked.isNotEmpty) {
//                   HapticFeedback.mediumImpact(); // 📍 이미지 선택 피드백
//                   setState(() => _selectedImages.addAll(picked));
//                 }
//               },
//               child: Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)), child: const Icon(Icons.add_a_photo, color: Colors.grey)),
//             );
//           }
//           return Stack(
//             children: [
//               Container(width: 100, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(File(_selectedImages[index].path)), fit: BoxFit.cover))),
//               Positioned(top: 4, right: 12, child: GestureDetector(onTap: () => setState(() => _selectedImages.removeAt(index)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)))),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _saveUnit() async {
//     if (_roomController.text.isEmpty) return;
//     final db = ref.read(databaseProvider);
//     // 📍 [DB 저장] 언어와 상관없이 고정된 키값(_selectedLeaseType)이 저장됩니다.
//     final unitId = await db.into(db.units).insert(UnitsCompanion.insert(
//       buildingId: widget.buildingId,
//       roomNumber: _roomController.text,
//       leaseType: Value(_selectedLeaseType),
//       tenantName: Value(_tenantNameController.text),
//       tenantPhone: Value(_phoneController.text),
//       deposit: Value(int.tryParse(_depositController.text) ?? 0),
//       monthlyRent: Value(int.tryParse(_rentController.text) ?? 0),
//       paymentDay: Value(int.tryParse(_paymentDayController.text)),
//       contractStart: Value(_startDate),
//       contractEnd: Value(_endDate),
//       memo: Value(_memoController.text),
//     ));
//     for (var image in _selectedImages) {
//       await db.into(db.unitImages).insert(UnitImagesCompanion.insert(unitId: unitId, imagePath: image.path));
//     }
//     ref.invalidate(propertyListProvider);
//     if (mounted) Navigator.pop(context);
//   }
// }

//
// import 'dart:io';
// import 'package:drift/drift.dart' hide Column;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
// import '../../core/database/database_provider.dart';
// import '../../core/database/app_database.dart';
// import 'property_provider.dart';
//
// // 📍 [핵심 수정] 비즈니스 로직 및 DB 저장을 위한 고정 키값 정의 (언어 변경에 무관)
// const String LEASE_TYPE_MONTHLY = '월세';
// const String LEASE_TYPE_JEONSE = '전세';
// const String LEASE_TYPE_HALF = '반전세';
// const String LEASE_TYPE_VACANT = '공실';
//
// class AddUnitDialog extends ConsumerStatefulWidget {
//   final int buildingId;
//   const AddUnitDialog({super.key, required this.buildingId});
//
//   @override
//   ConsumerState<AddUnitDialog> createState() => _AddUnitDialogState();
// }
//
// class _AddUnitDialogState extends ConsumerState<AddUnitDialog> {
//   final _roomController = TextEditingController();
//   final _tenantNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   // final _depositController = TextEditingController(text: '0');
//   // final _rentController = TextEditingController(text: '0');
//   final _depositController = TextEditingController();
//   final _rentController = TextEditingController();
//   final _paymentDayController = TextEditingController();
//   final _memoController = TextEditingController();
//
//   final _roomFocusNode = FocusNode(); // 📍 추가
//   String? _roomErrorText;
//
//   final List<XFile> _selectedImages = [];
//   final ImagePicker _picker = ImagePicker();
//
//   // 📍 초기값을 고정 키값으로 설정
//   String _selectedLeaseType = LEASE_TYPE_VACANT;
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   @override
//   void dispose() {
//     _roomController.dispose();
//     _tenantNameController.dispose();
//     _phoneController.dispose();
//     _depositController.dispose();
//     _rentController.dispose();
//     _paymentDayController.dispose();
//     _memoController.dispose();
//
//     _roomFocusNode.dispose(); // 📍 추가
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     // 📍 현재 설정된 언어 코드를 가져와 달력 로케일에 적용
//     final currentLang = ref.read(localizationProvider.notifier).currentLang;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       locale: Locale(currentLang), // 📍 달력 언어 설정 적용
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           _startDate = picked;
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 📍 [화폐 다국어 처리] 현재 언어 설정에 따른 통화 심볼 추출 ($ 또는 ₩ 등)
//     final currentLang = ref.watch(localizationProvider.notifier).currentLang;
//     final format = NumberFormat.simpleCurrency(locale: currentLang);
//     final String currencySymbol = format.currencySymbol;
//
//     return AlertDialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       // 📍 PROP_ADD_UNIT_TITLE 키 번역 적용 확인
//       title: Text(
//         "PROP_ADD_UNIT_TITLE".tr(ref),
//         style: const TextStyle(fontWeight: FontWeight.bold),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📍 PROP_SITE_PHOTOS 키 번역 적용
//                 Text(
//                   "PROP_SITE_PHOTOS".tr(ref),
//                   style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//                 _buildPhotoGallery(),
//                 const SizedBox(height: 24),
//                 // 📍 PROP_ROOM_NUMBER_LABEL 키 번역 적용
//                 _buildTextField(_roomController, "PROP_ROOM_NUMBER_LABEL".tr(ref)),
//                 const SizedBox(height: 20),
//                 _buildLeaseTypeToggle(),
//
//                 // 📍 [수정] 고정 키값을 비교하여 다국어 환경에서도 로직 유지
//                 if (_selectedLeaseType != LEASE_TYPE_VACANT) ...[
//                   const SizedBox(height: 20),
//                   // 📍 PROP_TENANT_NAME_LABEL 키 번역 적용
//                   _buildTextField(_tenantNameController, "PROP_TENANT_NAME_LABEL".tr(ref)),
//                   const SizedBox(height: 12),
//                   // 📍 PROP_PHONE_LABEL 키 번역 적용
//                   _buildTextField(_phoneController, "PROP_PHONE_LABEL".tr(ref), isNumber: true),
//                   const SizedBox(height: 12),
//
//                   // 📍 [수정] 보증금 입력 필드: CAT_DEPOSIT 번역과 화폐 심볼 동적 결합
//                   _buildTextField(
//                     _depositController,
//                     "${'CAT_DEPOSIT'.tr(ref)} ($currencySymbol)",
//                     isNumber: true,
//                   ),
//
//                   // 📍 [수정] 고정 키값 비교 (월세 또는 반전세인 경우만 임대료 필드 노출)
//                   if (_selectedLeaseType == LEASE_TYPE_MONTHLY || _selectedLeaseType == LEASE_TYPE_HALF) ...[
//                     const SizedBox(height: 12),
//
//                     // 📍 [수정] 임대료 입력 필드: CAT_RENT 번역과 화폐 심볼 동적 결합
//                     _buildTextField(
//                       _rentController,
//                       "${'CAT_RENT'.tr(ref)} ($currencySymbol)",
//                       isNumber: true,
//                     ),
//
//                     const SizedBox(height: 12),
//                     // 📍 PROP_PAYMENT_DAY_LABEL 키 번역 적용
//                     _buildTextField(_paymentDayController, "PROP_PAYMENT_DAY_LABEL".tr(ref), isNumber: true),
//                   ],
//                   const SizedBox(height: 20),
//                   _buildDateSection(),
//                 ],
//                 const SizedBox(height: 20),
//                 // 📍 COMMON_MEMO_HINT 키 번역 적용
//                 _buildTextField(_memoController, "COMMON_MEMO_HINT".tr(ref), maxLines: 2),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         // 📍 COMMON_CANCEL 키 번역 적용
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text(
//             "COMMON_CANCEL".tr(ref),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         ElevatedButton(
//           onPressed: _saveUnit,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF1A237E),
//             foregroundColor: Colors.white,
//             minimumSize: const Size(100, 45),
//           ),
//           // 📍 PROP_ADD_UNIT_ACTION 키 번역 적용 확인
//           child: Text(
//             "PROP_ADD_UNIT_ACTION".tr(ref),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   // 일관된 디자인을 위한 헬퍼 위젯들
//   Widget _buildTextField(
//       TextEditingController controller,
//       String label, {
//         bool isNumber = false,
//         int maxLines = 1,
//       }) {
//     final isRoomField = label == "PROP_ROOM_NUMBER_LABEL".tr(ref);
//
//     return TextField(
//       controller: controller,
//       focusNode: isRoomField ? _roomFocusNode : null, // 📍 호수 필드일 때 노드 연결
//       maxLines: maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//       //inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
//       // [수정 코드]
//       inputFormatters: isNumber ? [
//         FilteringTextInputFormatter.digitsOnly,
//         TextInputFormatter.withFunction((oldValue, newValue) {
//           if (newValue.text.isEmpty) return newValue;
//           final intValue = int.parse(newValue.text);
//           final newText = NumberFormat('#,###').format(intValue); // 콤마 포맷 적용
//           return newValue.copyWith(
//             text: newText,
//             selection: TextSelection.collapsed(offset: newText.length),
//           );
//         }),
//       ] : null,
//
//
//       // decoration: InputDecoration(
//       //   labelText: label,
//       //   border: const OutlineInputBorder(),
//       //   isDense: true,
//       // ),
//       decoration: InputDecoration(
//         labelText: label,
//         errorText: label == "PROP_ROOM_NUMBER_LABEL".tr(ref) ? _roomErrorText : null, // 📍 호수 필드일 때만 에러 표시
//         border: const OutlineInputBorder(),
//         isDense: true,
//       ),
//       onChanged: (value) {
//         if (label == "PROP_ROOM_NUMBER_LABEL".tr(ref) && value.isNotEmpty) {
//           setState(() => _roomErrorText = null); // 📍 입력 시작하면 에러 메시지 삭제
//         }
//       },
//
//     );
//   }
//
//   Widget _buildLeaseTypeToggle() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "PROP_LEASE_TYPE_LABEL".tr(ref),
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         const SizedBox(height: 12),
//         LayoutBuilder(builder: (context, constraints) {
//           final types = [LEASE_TYPE_MONTHLY, LEASE_TYPE_JEONSE, LEASE_TYPE_HALF, LEASE_TYPE_VACANT];
//           final labels = [
//             'LEASE_MONTHLY_SHORT'.tr(ref),
//             'LEASE_JEONSE_SHORT'.tr(ref),
//             'LEASE_HALF_JEONSE_SHORT'.tr(ref),
//             'DASHBOARD_VACANT_UNITS'.tr(ref)
//           ];
//
//           // 📍 전체 가용 너비 (334.6px 등)
//           final double totalWidth = constraints.maxWidth;
//
//           return Container(
//             width: totalWidth,
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: ToggleButtons(
//               isSelected: types.map((e) => _selectedLeaseType == e).toList(),
//               onPressed: (index) => setState(() => _selectedLeaseType = types[index]),
//               borderRadius: BorderRadius.circular(10),
//               selectedColor: Colors.white,
//               fillColor: const Color(0xFF1A237E),
//               color: Colors.grey[700],
//               // 📍 핵심: constraints를 null로 설정하거나 아주 작게 주어
//               // 아래의 SizedBox가 실제 너비를 결정하게 합니다.
//               constraints: const BoxConstraints(minHeight: 48),
//               renderBorder: true,
//               children: List.generate(labels.length, (index) {
//                 return SizedBox(
//                   // 📍 전체 너비를 버튼 개수(4개)로 정확히 나눔 (테두리 두께 고려)
//                   width: (totalWidth - (labels.length + 1)) / labels.length,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown, // 📍 텍스트가 길면 자동으로 크기를 줄임
//                       alignment: Alignment.center,
//                       child: Text(
//                         labels[index],
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildDateSection() {
//     final lang = ref.watch(localizationProvider.notifier).currentLang;
//     return Row(
//       children: [
//         // 📍 PROP_START_DATE 및 선택된 날짜 다국어 포맷 적용
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => _selectDate(context, true),
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(_startDate == null ? 'PROP_START_DATE'.tr(ref) : DateFormat.yMd(lang).format(_startDate!)),
//             ),
//           ),
//         ),
//         const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('~')),
//         // 📍 PROP_END_DATE 및 선택된 날짜 다국어 포맷 적용
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => _selectDate(context, false),
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(_endDate == null ? 'PROP_END_DATE'.tr(ref) : DateFormat.yMd(lang).format(_endDate!)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPhotoGallery() {
//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _selectedImages.length + 1,
//         itemBuilder: (context, index) {
//           if (index == _selectedImages.length) {
//             return GestureDetector(
//               onTap: () async {
//                 final picked = await _picker.pickMultiImage(imageQuality: 70);
//                 if (picked.isNotEmpty) {
//                   HapticFeedback.mediumImpact(); // 📍 이미지 선택 피드백
//                   setState(() => _selectedImages.addAll(picked));
//                 }
//               },
//               child: Container(
//                 width: 100,
//                 margin: const EdgeInsets.only(right: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: const Icon(Icons.add_a_photo, color: Colors.grey),
//               ),
//             );
//           }
//           return Stack(
//             children: [
//               Container(
//                 width: 100,
//                 margin: const EdgeInsets.only(right: 8),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   image: DecorationImage(
//                     image: FileImage(File(_selectedImages[index].path)),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 4,
//                 right: 12,
//                 child: GestureDetector(
//                   onTap: () => setState(() => _selectedImages.removeAt(index)),
//                   child: const CircleAvatar(
//                     radius: 10,
//                     backgroundColor: Colors.black54,
//                     child: Icon(Icons.close, size: 14, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _saveUnit() async {
//     // if (_roomController.text.trim().isEmpty) {
//     //   setState(() {
//     //     _roomErrorText = "VALIDATION_REQUIRED_ROOM".tr(ref); // 📍 에러 메시지 설정
//     //   });
//     //
//     //   // 📍 스낵바로 직접적인 피드백 제공
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(
//     //       content: Text("VALIDATION_REQUIRED_ROOM".tr(ref)),
//     //       backgroundColor: Colors.redAccent,
//     //     ),
//     //   );
//     //   return; // 📍 여기서 중단하여 저장을 막음
//     // }
//     // 📍 1. 호수 입력 확인
//     if (_roomController.text.trim().isEmpty) {
//       HapticFeedback.heavyImpact(); // 📍 강력한 진동으로 "안 됨"을 알림
//       setState(() {
//         _roomErrorText = "VALIDATION_REQUIRED_ROOM".tr(ref);
//       });
//       // 📍 핵심: 호수 입력창으로 커서(포커스) 강제 이동
//       _roomFocusNode.requestFocus();
//       return; // 중단
//     }
//
//     if (_roomController.text.isEmpty) return;
//     final db = ref.read(databaseProvider);
//     // 📍 [DB 저장] 언어와 상관없이 고정된 키값(_selectedLeaseType)이 저장됩니다.
//     final unitId = await db.into(db.units).insert(
//       UnitsCompanion.insert(
//         buildingId: widget.buildingId,
//         roomNumber: _roomController.text,
//         leaseType: Value(_selectedLeaseType),
//         tenantName: Value(_tenantNameController.text),
//         tenantPhone: Value(_phoneController.text),
//         //deposit: Value(int.tryParse(_depositController.text) ?? 0),
//         //monthlyRent: Value(int.tryParse(_rentController.text) ?? 0),
//         // 콤마(,)를 제거한 뒤 숫자로 변환하여 저장합니다.
//         deposit: Value(int.tryParse(_depositController.text.replaceAll(',', '')) ?? 0),
//         monthlyRent: Value(int.tryParse(_rentController.text.replaceAll(',', '')) ?? 0),
//
//         paymentDay: Value(int.tryParse(_paymentDayController.text)),
//         contractStart: Value(_startDate),
//         contractEnd: Value(_endDate),
//         memo: Value(_memoController.text),
//       ),
//     );
//     for (var image in _selectedImages) {
//       await db.into(db.unitImages).insert(UnitImagesCompanion.insert(unitId: unitId, imagePath: image.path));
//     }
//     ref.invalidate(propertyListProvider);
//     if (mounted) Navigator.pop(context);
//   }
// }

import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'property_provider.dart';

// 📍 [핵심 수정] 비즈니스 로직 및 DB 저장을 위한 고정 키값 정의 (언어 변경에 무관)
const String LEASE_TYPE_MONTHLY = '월세';
const String LEASE_TYPE_JEONSE = '전세';
const String LEASE_TYPE_HALF = '반전세';
const String LEASE_TYPE_VACANT = '공실';

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
  // final _depositController = TextEditingController(text: '0');
  // final _rentController = TextEditingController(text: '0');
  final _depositController = TextEditingController();
  final _rentController = TextEditingController();
  final _paymentDayController = TextEditingController();
  final _memoController = TextEditingController();

  final _roomFocusNode = FocusNode(); // 📍 추가
  String? _roomErrorText;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // 📍 초기값을 고정 키값으로 설정
  String _selectedLeaseType = LEASE_TYPE_VACANT;
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

    _roomFocusNode.dispose(); // 📍 추가
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    // 📍 현재 설정된 언어 코드를 가져와 달력 로케일에 적용
    final currentLang = ref.read(localizationProvider.notifier).currentLang;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Locale(currentLang), // 📍 달력 언어 설정 적용
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📍 [화폐 다국어 처리] 현재 언어 설정에 따른 통화 심볼 추출 ($ 또는 ₩ 등)
    final currentLang = ref.watch(localizationProvider.notifier).currentLang;
    final format = NumberFormat.simpleCurrency(locale: currentLang);
    final String currencySymbol = format.currencySymbol;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // 📍 PROP_ADD_UNIT_TITLE 키 번역 적용 확인
      title: Text(
        "PROP_ADD_UNIT_TITLE".tr(ref),
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📍 PROP_SITE_PHOTOS 키 번역 적용
                Text(
                  "PROP_SITE_PHOTOS".tr(ref),
                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildPhotoGallery(),
                const SizedBox(height: 24),
                // 📍 PROP_ROOM_NUMBER_LABEL 키 번역 적용
                _buildTextField(_roomController, "PROP_ROOM_NUMBER_LABEL".tr(ref)),
                const SizedBox(height: 20),
                _buildLeaseTypeToggle(),

                // 📍 [수정] 고정 키값을 비교하여 다국어 환경에서도 로직 유지
                if (_selectedLeaseType != LEASE_TYPE_VACANT) ...[
                  const SizedBox(height: 20),
                  // 📍 PROP_TENANT_NAME_LABEL 키 번역 적용
                  _buildTextField(_tenantNameController, "PROP_TENANT_NAME_LABEL".tr(ref)),
                  const SizedBox(height: 12),
                  // 📍 PROP_PHONE_LABEL 키 번역 적용
                  _buildTextField(_phoneController, "PROP_PHONE_LABEL".tr(ref), isNumber: true),
                  const SizedBox(height: 12),

                  // 📍 [수정] 보증금 입력 필드: CAT_DEPOSIT 번역과 화폐 심볼 동적 결합
                  _buildTextField(
                    _depositController,
                    "${'CAT_DEPOSIT'.tr(ref)} ($currencySymbol)",
                    isNumber: true,
                  ),

                  // 📍 [수정] 고정 키값 비교 (월세 또는 반전세인 경우만 임대료 필드 노출)
                  if (_selectedLeaseType == LEASE_TYPE_MONTHLY || _selectedLeaseType == LEASE_TYPE_HALF) ...[
                    const SizedBox(height: 12),

                    // 📍 [수정] 임대료 입력 필드: CAT_RENT 번역과 화폐 심볼 동적 결합
                    _buildTextField(
                      _rentController,
                      "${'CAT_RENT'.tr(ref)} ($currencySymbol)",
                      isNumber: true,
                    ),

                    const SizedBox(height: 12),
                    // 📍 PROP_PAYMENT_DAY_LABEL 키 번역 적용
                    _buildTextField(_paymentDayController, "PROP_PAYMENT_DAY_LABEL".tr(ref), isNumber: true),
                  ],
                  const SizedBox(height: 20),
                  _buildDateSection(),
                ],
                const SizedBox(height: 20),
                // 📍 COMMON_MEMO_HINT 키 번역 적용
                _buildTextField(_memoController, "COMMON_MEMO_HINT".tr(ref), maxLines: 2),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // 📍 COMMON_CANCEL 키 번역 적용
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "COMMON_CANCEL".tr(ref),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ElevatedButton(
          onPressed: _saveUnit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 45),
          ),
          // 📍 PROP_ADD_UNIT_ACTION 키 번역 적용 확인
          child: Text(
            "PROP_ADD_UNIT_ACTION".tr(ref),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }


  // 일관된 디자인을 위한 헬퍼 위젯들
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isNumber = false,
        int maxLines = 1,
      }) {
    final isRoomField = label == "PROP_ROOM_NUMBER_LABEL".tr(ref);
    // 📍 전화번호 필드인지 확인 (전화번호는 숫자여도 콤마 포맷 제외)
    final isPhoneField = label == "PROP_PHONE_LABEL".tr(ref);

    return TextField(
      controller: controller,
      focusNode: isRoomField ? _roomFocusNode : null, // 📍 호수 필드일 때 노드 연결
      maxLines: maxLines,
      keyboardType: isNumber ? (isPhoneField ? TextInputType.phone : TextInputType.number) : TextInputType.text,
      //inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      // [수정 코드]
      inputFormatters: isNumber ? [
        FilteringTextInputFormatter.digitsOnly,
        if (!isPhoneField) // 📍 전화번호 필드가 아닐 때만 콤마 포맷 적용
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) return newValue;
            final intValue = int.parse(newValue.text);
            final newText = NumberFormat('#,###').format(intValue); // 콤마 포맷 적용
            return newValue.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: newText.length),
            );
          }),
      ] : null,


      // decoration: InputDecoration(
      //   labelText: label,
      //   border: const OutlineInputBorder(),
      //   isDense: true,
      // ),
      decoration: InputDecoration(
        labelText: label,
        errorText: label == "PROP_ROOM_NUMBER_LABEL".tr(ref) ? _roomErrorText : null, // 📍 호수 필드일 때만 에러 표시
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        if (label == "PROP_ROOM_NUMBER_LABEL".tr(ref) && value.isNotEmpty) {
          setState(() => _roomErrorText = null); // 📍 입력 시작하면 에러 메시지 삭제
        }
      },

    );
  }

  Widget _buildLeaseTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PROP_LEASE_TYPE_LABEL".tr(ref),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final types = [LEASE_TYPE_MONTHLY, LEASE_TYPE_JEONSE, LEASE_TYPE_HALF, LEASE_TYPE_VACANT];
          final labels = [
            'LEASE_MONTHLY_SHORT'.tr(ref),
            'LEASE_JEONSE_SHORT'.tr(ref),
            'LEASE_HALF_JEONSE_SHORT'.tr(ref),
            'DASHBOARD_VACANT_UNITS'.tr(ref)
          ];

          // 📍 전체 가용 너비 (334.6px 등)
          final double totalWidth = constraints.maxWidth;

          return Container(
            width: totalWidth,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ToggleButtons(
              isSelected: types.map((e) => _selectedLeaseType == e).toList(),
              onPressed: (index) => setState(() => _selectedLeaseType = types[index]),
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: const Color(0xFF1A237E),
              color: Colors.grey[700],
              // 📍 핵심: constraints를 null로 설정하거나 아주 작게 주어
              // 아래의 SizedBox가 실제 너비를 결정하게 합니다.
              constraints: const BoxConstraints(minHeight: 48),
              renderBorder: true,
              children: List.generate(labels.length, (index) {
                return SizedBox(
                  // 📍 전체 너비를 버튼 개수(4개)로 정확히 나눔 (테두리 두께 고려)
                  width: (totalWidth - (labels.length + 1)) / labels.length,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // 📍 텍스트가 길면 자동으로 크기를 줄임
                      alignment: Alignment.center,
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateSection() {
    final lang = ref.watch(localizationProvider.notifier).currentLang;
    return Row(
      children: [
        // 📍 PROP_START_DATE 및 선택된 날짜 다국어 포맷 적용
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selectDate(context, true),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_startDate == null ? 'PROP_START_DATE'.tr(ref) : DateFormat.yMd(lang).format(_startDate!)),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('~')),
        // 📍 PROP_END_DATE 및 선택된 날짜 다국어 포맷 적용
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selectDate(context, false),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_endDate == null ? 'PROP_END_DATE'.tr(ref) : DateFormat.yMd(lang).format(_endDate!)),
            ),
          ),
        ),
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
                if (picked.isNotEmpty) {
                  HapticFeedback.mediumImpact(); // 📍 이미지 선택 피드백
                  setState(() => _selectedImages.addAll(picked));
                }
              },
              child: Container(
                width: 100,
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
          return Stack(
            children: [
              Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(_selectedImages[index].path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedImages.removeAt(index)),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveUnit() async {
    // if (_roomController.text.trim().isEmpty) {
    //   setState(() {
    //     _roomErrorText = "VALIDATION_REQUIRED_ROOM".tr(ref); // 📍 에러 메시지 설정
    //   });
    //
    //   // 📍 스낵바로 직접적인 피드백 제공
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("VALIDATION_REQUIRED_ROOM".tr(ref)),
    //       backgroundColor: Colors.redAccent,
    //     ),
    //   );
    //   return; // 📍 여기서 중단하여 저장을 막음
    // }
    // 📍 1. 호수 입력 확인
    if (_roomController.text.trim().isEmpty) {
      HapticFeedback.heavyImpact(); // 📍 강력한 진동으로 "안 됨"을 알림
      setState(() {
        _roomErrorText = "VALIDATION_REQUIRED_ROOM".tr(ref);
      });
      // 📍 핵심: 호수 입력창으로 커서(포커스) 강제 이동
      _roomFocusNode.requestFocus();
      return; // 중단
    }

    if (_roomController.text.isEmpty) return;
    final db = ref.read(databaseProvider);
    // 📍 [DB 저장] 언어와 상관없이 고정된 키값(_selectedLeaseType)이 저장됩니다.
    final unitId = await db.into(db.units).insert(
      UnitsCompanion.insert(
        buildingId: widget.buildingId,
        roomNumber: _roomController.text,
        leaseType: Value(_selectedLeaseType),
        tenantName: Value(_tenantNameController.text),
        tenantPhone: Value(_phoneController.text),
        //deposit: Value(int.tryParse(_depositController.text) ?? 0),
        //monthlyRent: Value(int.tryParse(_rentController.text) ?? 0),
        // 콤마(,)를 제거한 뒤 숫자로 변환하여 저장합니다.
        deposit: Value(int.tryParse(_depositController.text.replaceAll(',', '')) ?? 0),
        monthlyRent: Value(int.tryParse(_rentController.text.replaceAll(',', '')) ?? 0),

        paymentDay: Value(int.tryParse(_paymentDayController.text)),
        contractStart: Value(_startDate),
        contractEnd: Value(_endDate),
        memo: Value(_memoController.text),
      ),
    );
    for (var image in _selectedImages) {
      await db.into(db.unitImages).insert(UnitImagesCompanion.insert(unitId: unitId, imagePath: image.path));
    }
    ref.invalidate(propertyListProvider);
    if (mounted) Navigator.pop(context);
  }
}
