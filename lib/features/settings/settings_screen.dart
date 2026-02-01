// // // // // import 'dart:io';
// // // // // import 'package:drift/drift.dart' hide Column;
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // // import 'package:share_plus/share_plus.dart';
// // // // // import 'package:file_picker/file_picker.dart';
// // // // // import 'package:path_provider/path_provider.dart';
// // // // // import 'package:path/path.dart' as p;
// // // // // import 'package:image_picker/image_picker.dart';
// // // // //
// // // // // import '../../core/localization/localization_provider.dart';
// // // // // import '../security/security_provider.dart';
// // // // // import '../security/pin_screen.dart';
// // // // // import 'category_management_screen.dart';
// // // // // import 'user_provider.dart';
// // // // // import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가
// // // // //
// // // // // class SettingsScreen extends ConsumerWidget {
// // // // //   const SettingsScreen({super.key});
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // // //     final hasPin = ref.watch(securityNotifierProvider).value ?? false;
// // // // //     final profile = ref.watch(userNicknameProvider);
// // // // //
// // // // //     // 지원하는 20개 언어 리스트
// // // // //     final Map<String, String> languages = {
// // // // //       "ar": "العربية", "bn": "বাংলা", "zh": "中文 (简体)", "nl": "Nederlands",
// // // // //       "en": "English", "fr": "Français", "de": "Deutsch", "hi": "हिन्दी",
// // // // //       "id": "Bahasa Indonesia", "it": "Italiano", "ja": "日本語", "ko": "한국어",
// // // // //       "ms": "Bahasa Melayu", "pl": "Polski", "pt": "Português", "ru": "Русский",
// // // // //       "es": "Español", "th": "ไทย", "tr": "Türkçe", "vi": "Tiếng Việt"
// // // // //     };
// // // // //
// // // // //     return Scaffold(
// // // // //       backgroundColor: Colors.grey[50],
// // // // //       appBar: AppBar(
// // // // //         title: Text("NAV_SETTINGS".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // //         backgroundColor: const Color(0xFF1A237E),
// // // // //         foregroundColor: Colors.white,
// // // // //         elevation: 0,
// // // // //       ),
// // // // //       body: ListView(
// // // // //         children: [
// // // // //           // --- 1. User Profile Section (사용자 프로필: 최상단 배치) ---
// // // // //           _buildSectionTitle("SETTINGS_USER_PROFILE".tr(ref)),
// // // // //           _buildCard([
// // // // //             ListTile(
// // // // //               leading: GestureDetector(
// // // // //                 onTap: () => _pickImage(ref),
// // // // //                 child: CircleAvatar(
// // // // //                   radius: 25,
// // // // //                   backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
// // // // //                   backgroundImage: profile.imagePath != null ? FileImage(File(profile.imagePath!)) : null,
// // // // //                   child: profile.imagePath == null ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E)) : null,
// // // // //                 ),
// // // // //               ),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // // //               trailing: const Icon(Icons.chevron_right),
// // // // //               onTap: () => _pickImage(ref),
// // // // //             ),
// // // // //             const Divider(height: 1),
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text(
// // // // //                   profile.nickname.startsWith('SETTINGS_') ? profile.nickname.tr(ref) : profile.nickname,
// // // // //                   maxLines: 1,
// // // // //                   overflow: TextOverflow.ellipsis
// // // // //               ),
// // // // //               trailing: const Icon(Icons.edit_outlined, size: 20),
// // // // //               onTap: () => _showEditNicknameDialog(context, ref),
// // // // //             ),
// // // // //           ]),
// // // // //
// // // // //           // --- 2. Security Section (보안: PIN 설정) ---
// // // // //           _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
// // // // //           _buildCard([
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
// // // // //               title: FractionallySizedBox(
// // // // //                 widthFactor: 0.9,
// // // // //                 child: FittedBox(
// // // // //                   alignment: Alignment.centerLeft,
// // // // //                   fit: BoxFit.scaleDown,
// // // // //                   child: Text("SETTINGS_USE_PIN".tr(ref)),
// // // // //                 ),
// // // // //               ),
// // // // //               trailing: Switch(
// // // // //                 value: hasPin,
// // // // //                 activeColor: const Color(0xFF1A237E),
// // // // //                 onChanged: (value) async {
// // // // //                   if (value) {
// // // // //                     Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true)));
// // // // //                   } else {
// // // // //                     await _showDeleteConfirmDialog(context, ref);
// // // // //                   }
// // // // //                 },
// // // // //               ),
// // // // //             ),
// // // // //             if (hasPin) ...[
// // // // //               const Divider(height: 1),
// // // // //               ListTile(
// // // // //                 leading: const Icon(Icons.password, color: Color(0xFF1A237E)),
// // // // //                 title: FittedBox(
// // // // //                   alignment: Alignment.centerLeft,
// // // // //                   fit: BoxFit.scaleDown,
// // // // //                   child: Text("SETTINGS_CHANGE_PIN".tr(ref)),
// // // // //                 ),
// // // // //                 trailing: const Icon(Icons.chevron_right),
// // // // //                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true))),
// // // // //               ),
// // // // //             ],
// // // // //           ]),
// // // // //
// // // // //           // --- 3. Language Section (언어 설정: 다국어) ---
// // // // //           _buildSectionTitle("SETTINGS_LANGUAGE_SECTION".tr(ref)),
// // // // //           _buildCard([
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.language, color: Color(0xFF1A237E)),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_SELECT_LANGUAGE".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text(languages[ref.read(localizationProvider.notifier).currentLang] ?? ""),
// // // // //               trailing: const Icon(Icons.chevron_right),
// // // // //               onTap: () => _showLanguageDialog(context, ref, languages),
// // // // //             ),
// // // // //           ]),
// // // // //
// // // // //           // --- 4. Customization Section (맞춤 설정: 카테고리 관리) ---
// // // // //           _buildSectionTitle("SETTINGS_CUSTOMIZATION".tr(ref)),
// // // // //           _buildCard([
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.category_outlined, color: Colors.teal),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_MANAGE_CATEGORIES".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // // //               trailing: const Icon(Icons.chevron_right),
// // // // //               onTap: () {
// // // // //                 Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen()));
// // // // //               },
// // // // //             ),
// // // // //           ]),
// // // // //
// // // // //           // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
// // // // //           _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
// // // // //           _buildCard([
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_BACKUP".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // // //               onTap: () => _handleBackup(context, ref),
// // // // //             ),
// // // // //             const Divider(height: 1),
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_RESTORE".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // // //               onTap: () => _handleRestore(context, ref),
// // // // //             ),
// // // // //           ]),
// // // // //
// // // // //           // --- 6. App Support Section (지원: 문의 및 환불 정책) ---
// // // // //           _buildSectionTitle("SETTINGS_SUPPORT_SECTION".tr(ref)),
// // // // //           _buildCard([
// // // // //             ListTile(
// // // // //               leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
// // // // //               title: FittedBox(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 fit: BoxFit.scaleDown,
// // // // //                 child: Text("SETTINGS_SUPPORT".tr(ref)),
// // // // //               ),
// // // // //               subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // // //               trailing: const Icon(Icons.mail_outline, size: 20),
// // // // //               onTap: () async {
// // // // //                 try {
// // // // //                   await SupportService.sendSupportEmail();
// // // // //                 } catch (e) {
// // // // //                   if (context.mounted) {
// // // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // // //                       SnackBar(content: Text("ERROR_NO_EMAIL_APP".tr(ref))),
// // // // //                     );
// // // // //                   }
// // // // //                 }
// // // // //               },
// // // // //             ),
// // // // //           ]),
// // // // //
// // // // //           const SizedBox(height: 40),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // --- Helper Widgets ---
// // // // //
// // // // //   Widget _buildSectionTitle(String title) {
// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
// // // // //       child: FittedBox(
// // // // //         alignment: Alignment.centerLeft,
// // // // //         fit: BoxFit.scaleDown,
// // // // //         child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Widget _buildCard(List<Widget> children) {
// // // // //     return Container(
// // // // //       margin: const EdgeInsets.symmetric(horizontal: 16),
// // // // //       decoration: BoxDecoration(
// // // // //         color: Colors.white,
// // // // //         borderRadius: BorderRadius.circular(12),
// // // // //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
// // // // //       ),
// // // // //       child: Column(children: children),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   // --- Logic Methods ---
// // // // //
// // // // //   void _showLanguageDialog(BuildContext context, WidgetRef ref, Map<String, String> languages) {
// // // // //     final currentLang = ref.read(localizationProvider.notifier).currentLang;
// // // // //     showModalBottomSheet(
// // // // //       context: context,
// // // // //       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// // // // //       builder: (context) => Container(
// // // // //         padding: const EdgeInsets.symmetric(vertical: 20),
// // // // //         child: Column(
// // // // //           mainAxisSize: MainAxisSize.min,
// // // // //           children: [
// // // // //             Text("SETTINGS_SELECT_LANGUAGE".tr(ref), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             const Divider(),
// // // // //             Expanded(
// // // // //               child: ListView.builder(
// // // // //                 itemCount: languages.length,
// // // // //                 itemBuilder: (context, index) {
// // // // //                   String key = languages.keys.elementAt(index);
// // // // //                   String value = languages.values.elementAt(index);
// // // // //                   bool isSelected = currentLang == key;
// // // // //                   return ListTile(
// // // // //                     title: Text(value, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF1A237E) : Colors.black)),
// // // // //                     trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1A237E)) : null,
// // // // //                     onTap: () async {
// // // // //                       await ref.read(localizationProvider.notifier).changeLanguage(key);
// // // // //                       if (context.mounted) Navigator.pop(context);
// // // // //                       if (context.mounted) {
// // // // //                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // // //                             SnackBar(
// // // // //                               content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
// // // // //                               behavior: SnackBarBehavior.floating,
// // // // //                             )
// // // // //                         );
// // // // //                       }
// // // // //                     },
// // // // //                   );
// // // // //                 },
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Future<void> _pickImage(WidgetRef ref) async {
// // // // //     final picker = ImagePicker();
// // // // //     final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
// // // // //     if (image != null) await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
// // // // //   }
// // // // //
// // // // //   void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
// // // // //     final currentNickname = ref.read(userNicknameProvider).nickname;
// // // // //     final displayNickname = currentNickname.startsWith('SETTINGS_') ? currentNickname.tr(ref) : currentNickname;
// // // // //
// // // // //     final controller = TextEditingController(text: displayNickname);
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => StatefulBuilder(
// // // // //         builder: (context, setState) => AlertDialog(
// // // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // // //           title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // //           content: TextField(
// // // // //             controller: controller,
// // // // //             autofocus: true,
// // // // //             onChanged: (value) => setState(() {}),
// // // // //             decoration: InputDecoration(
// // // // //               hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
// // // // //               filled: true,
// // // // //               fillColor: Colors.grey[100],
// // // // //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
// // // // //               suffixIcon: controller.text.isNotEmpty ? GestureDetector(onTap: () { controller.clear(); setState(() {}); }, child: const Icon(Icons.cancel, color: Colors.grey, size: 20)) : null,
// // // // //             ),
// // // // //           ),
// // // // //           actions: [
// // // // //             TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref), style: const TextStyle(color: Colors.grey))),
// // // // //             ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white), onPressed: () async {
// // // // //               if (controller.text.trim().isNotEmpty) {
// // // // //                 await ref.read(userNicknameProvider.notifier).updateNickname(controller.text.trim());
// // // // //                 if (context.mounted) Navigator.pop(context);
// // // // //               }
// // // // //             }, child: Text("COMMON_SAVE".tr(ref))),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // //
// // // // //   Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
// // // // //     try {
// // // // //       final dbFolder = await getApplicationDocumentsDirectory();
// // // // //       final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
// // // // //       if (await dbFile.exists()) { await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup'); }
// // // // //       else { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref)))); }
// // // // //     } catch (e) { debugPrint("Backup Error: $e"); }
// // // // //   }
// // // // //
// // // // //   Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
// // // // //     final result = await FilePicker.platform.pickFiles();
// // // // //     if (result != null && result.files.single.path != null) {
// // // // //       try {
// // // // //         final dbFolder = await getApplicationDocumentsDirectory();
// // // // //         final newDbFile = File(result.files.single.path!);
// // // // //         await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
// // // // //         if (context.mounted) {
// // // // //           showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
// // // // //             title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
// // // // //             content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
// // // // //             actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_OK".tr(ref)))],
// // // // //           ));
// // // // //         }
// // // // //       } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref)))); }
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
// // // // //     return showDialog(context: context, builder: (context) => AlertDialog(
// // // // //       title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
// // // // //       content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
// // // // //       actions: [
// // // // //         TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
// // // // //         TextButton(onPressed: () async { await ref.read(securityNotifierProvider.notifier).removePin(); if (context.mounted) Navigator.pop(context); }, child: Text("COMMON_DISABLE".tr(ref), style: const TextStyle(color: Colors.red))),
// // // // //       ],
// // // // //     ));
// // // // //   }
// // // // // }
// // //
// // // //
// // // // import 'dart:io';
// // // // import 'package:drift/drift.dart' hide Column;
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:share_plus/share_plus.dart';
// // // // import 'package:file_picker/file_picker.dart';
// // // // import 'package:path_provider/path_provider.dart';
// // // // import 'package:path/path.dart' as p;
// // // // import 'package:image_picker/image_picker.dart';
// // // //
// // // // import '../../core/localization/localization_provider.dart';
// // // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 상태/복원(리로드)용
// // // // import '../security/security_provider.dart';
// // // // import '../security/pin_screen.dart';
// // // // import 'category_management_screen.dart';
// // // // import 'user_provider.dart';
// // // // import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가
// // // //
// // // // class SettingsScreen extends ConsumerWidget {
// // // //   const SettingsScreen({super.key});
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context, WidgetRef ref) {
// // // //     final hasPin = ref.watch(securityNotifierProvider).value ?? false;
// // // //     final profile = ref.watch(userNicknameProvider);
// // // //
// // // //     // ✅ [추가] Pro 상태 확인
// // // //     final isPro = ref.watch(isProProvider);
// // // //     final purchaseState = ref.watch(purchaseControllerProvider);
// // // //
// // // //     // 지원하는 20개 언어 리스트
// // // //     final Map<String, String> languages = {
// // // //       "ar": "العربية", "bn": "বাংলা", "zh": "中文 (简体)", "nl": "Nederlands",
// // // //       "en": "English", "fr": "Français", "de": "Deutsch", "hi": "हिन्दी",
// // // //       "id": "Bahasa Indonesia", "it": "Italiano", "ja": "日本語", "ko": "한국어",
// // // //       "ms": "Bahasa Melayu", "pl": "Polski", "pt": "Português", "ru": "Русский",
// // // //       "es": "Español", "th": "ไทย", "tr": "Türkçe", "vi": "Tiếng Việt"
// // // //     };
// // // //
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.grey[50],
// // // //       appBar: AppBar(
// // // //         title: Text("NAV_SETTINGS".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //         backgroundColor: const Color(0xFF1A237E),
// // // //         foregroundColor: Colors.white,
// // // //         elevation: 0,
// // // //       ),
// // // //       body: ListView(
// // // //         children: [
// // // //           // --- 1. User Profile Section (사용자 프로필: 최상단 배치) ---
// // // //           _buildSectionTitle("SETTINGS_USER_PROFILE".tr(ref)),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: GestureDetector(
// // // //                 onTap: () => _pickImage(ref),
// // // //                 child: CircleAvatar(
// // // //                   radius: 25,
// // // //                   backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
// // // //                   backgroundImage: profile.imagePath != null ? FileImage(File(profile.imagePath!)) : null,
// // // //                   child: profile.imagePath == null ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E)) : null,
// // // //                 ),
// // // //               ),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
// // // //               ),
// // // //               subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // //               trailing: const Icon(Icons.chevron_right),
// // // //               onTap: () => _pickImage(ref),
// // // //             ),
// // // //             const Divider(height: 1),
// // // //             ListTile(
// // // //               leading: const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
// // // //               ),
// // // //               subtitle: Text(
// // // //                   profile.nickname.startsWith('SETTINGS_') ? profile.nickname.tr(ref) : profile.nickname,
// // // //                   maxLines: 1,
// // // //                   overflow: TextOverflow.ellipsis
// // // //               ),
// // // //               trailing: const Icon(Icons.edit_outlined, size: 20),
// // // //               onTap: () => _showEditNicknameDialog(context, ref),
// // // //             ),
// // // //           ]),
// // // //
// // // //           // --- 2. Security Section (보안: PIN 설정) ---
// // // //           _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
// // // //               title: FractionallySizedBox(
// // // //                 widthFactor: 0.9,
// // // //                 child: FittedBox(
// // // //                   alignment: Alignment.centerLeft,
// // // //                   fit: BoxFit.scaleDown,
// // // //                   child: Text("SETTINGS_USE_PIN".tr(ref)),
// // // //                 ),
// // // //               ),
// // // //               trailing: Switch(
// // // //                 value: hasPin,
// // // //                 activeColor: const Color(0xFF1A237E),
// // // //                 onChanged: (value) async {
// // // //                   if (value) {
// // // //                     Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true)));
// // // //                   } else {
// // // //                     await _showDeleteConfirmDialog(context, ref);
// // // //                   }
// // // //                 },
// // // //               ),
// // // //             ),
// // // //             if (hasPin) ...[
// // // //               const Divider(height: 1),
// // // //               ListTile(
// // // //                 leading: const Icon(Icons.password, color: Color(0xFF1A237E)),
// // // //                 title: FittedBox(
// // // //                   alignment: Alignment.centerLeft,
// // // //                   fit: BoxFit.scaleDown,
// // // //                   child: Text("SETTINGS_CHANGE_PIN".tr(ref)),
// // // //                 ),
// // // //                 trailing: const Icon(Icons.chevron_right),
// // // //                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true))),
// // // //               ),
// // // //             ],
// // // //           ]),
// // // //
// // // //           // --- ✅ [추가] Pro Section (결제: SiRE Pro 평생 구매) ---
// // // //           // - 현재는 IAP 연동 전 단계이므로, 구매 버튼은 "준비 중"으로 두고
// // // //           // - 상태 표시 + 복원/새로고침(reload)은 동작하게 유지합니다.
// // // //           _buildSectionTitle("SiRE Pro"),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: Icon(
// // // //                 isPro ? Icons.verified : Icons.workspace_premium_outlined,
// // // //                 color: isPro ? Colors.green : const Color(0xFF1A237E),
// // // //               ),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text(isPro ? "Pro 활성화됨" : "Pro 기능 잠금"),
// // // //               ),
// // // //               subtitle: Text(
// // // //                 isPro
// // // //                     ? "Reports / 분석 / Export 기능을 사용할 수 있습니다."
// // // //                     : "Reports / 분석 / Export 기능은 Pro에서 제공됩니다.",
// // // //                 maxLines: 2,
// // // //                 overflow: TextOverflow.ellipsis,
// // // //               ),
// // // //               trailing: purchaseState.isLoading
// // // //                   ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
// // // //                   : const Icon(Icons.chevron_right),
// // // //               onTap: () => _showProDialog(context, ref, isPro),
// // // //             ),
// // // //             if (!isPro) ...[
// // // //               const Divider(height: 1),
// // // //               ListTile(
// // // //                 leading: const Icon(Icons.lock_outline, color: Colors.grey),
// // // //                 title: FittedBox(
// // // //                   alignment: Alignment.centerLeft,
// // // //                   fit: BoxFit.scaleDown,
// // // //                   child: const Text("Pro 구매 (준비 중)"),
// // // //                 ),
// // // //                 subtitle: const Text("인앱 결제 연동은 다음 단계에서 연결할 예정입니다."),
// // // //                 onTap: () => _showIapComingSoonDialog(context),
// // // //               ),
// // // //             ],
// // // //             const Divider(height: 1),
// // // //             ListTile(
// // // //               leading: const Icon(Icons.restore, color: Colors.orange),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: const Text("구매 복원/상태 새로고침"),
// // // //               ),
// // // //               subtitle: const Text("결제 연동 후에는 스토어 복원 기능으로 동작합니다."),
// // // //               onTap: () async {
// // // //                 await ref.read(purchaseControllerProvider.notifier).reload();
// // // //                 if (context.mounted) {
// // // //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     const SnackBar(
// // // //                       content: Text("구매 상태를 다시 확인했습니다."),
// // // //                       behavior: SnackBarBehavior.floating,
// // // //                     ),
// // // //                   );
// // // //                 }
// // // //               },
// // // //             ),
// // // //
// // // //             // ✅ [개발 편의] 지금은 IAP 연동 전이므로, 디버깅용 토글을 넣어두면 테스트가 편합니다.
// // // //             // - 실제 배포 전에는 제거하거나, 개발/디버그 빌드에서만 보이게 처리하세요.
// // // //             const Divider(height: 1),
// // // //             SwitchListTile(
// // // //               secondary: const Icon(Icons.build_outlined, color: Colors.teal),
// // // //               title: const Text("개발용: Pro 상태 토글"),
// // // //               subtitle: const Text("테스트 편의를 위한 임시 기능입니다. 배포 전 제거 권장"),
// // // //               value: isPro,
// // // //               onChanged: (value) async {
// // // //                 await ref.read(purchaseControllerProvider.notifier).setPro(value);
// // // //                 if (context.mounted) {
// // // //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     SnackBar(
// // // //                       content: Text(value ? "Pro가 활성화되었습니다." : "Pro가 비활성화되었습니다."),
// // // //                       behavior: SnackBarBehavior.floating,
// // // //                     ),
// // // //                   );
// // // //                 }
// // // //               },
// // // //             ),
// // // //           ]),
// // // //
// // // //           // --- 3. Language Section (언어 설정: 다국어) ---
// // // //           _buildSectionTitle("SETTINGS_LANGUAGE_SECTION".tr(ref)),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: const Icon(Icons.language, color: Color(0xFF1A237E)),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_SELECT_LANGUAGE".tr(ref)),
// // // //               ),
// // // //               subtitle: Text(languages[ref.read(localizationProvider.notifier).currentLang] ?? ""),
// // // //               trailing: const Icon(Icons.chevron_right),
// // // //               onTap: () => _showLanguageDialog(context, ref, languages),
// // // //             ),
// // // //           ]),
// // // //
// // // //           // --- 4. Customization Section (맞춤 설정: 카테고리 관리) ---
// // // //           _buildSectionTitle("SETTINGS_CUSTOMIZATION".tr(ref)),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: const Icon(Icons.category_outlined, color: Colors.teal),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_MANAGE_CATEGORIES".tr(ref)),
// // // //               ),
// // // //               subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // //               trailing: const Icon(Icons.chevron_right),
// // // //               onTap: () {
// // // //                 Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen()));
// // // //               },
// // // //             ),
// // // //           ]),
// // // //
// // // //           // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
// // // //           _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_BACKUP".tr(ref)),
// // // //               ),
// // // //               subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // //               onTap: () => _handleBackup(context, ref),
// // // //             ),
// // // //             const Divider(height: 1),
// // // //             ListTile(
// // // //               leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_RESTORE".tr(ref)),
// // // //               ),
// // // //               subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // //               onTap: () => _handleRestore(context, ref),
// // // //             ),
// // // //           ]),
// // // //
// // // //           // --- 6. App Support Section (지원: 문의 및 환불 정책) ---
// // // //           _buildSectionTitle("SETTINGS_SUPPORT_SECTION".tr(ref)),
// // // //           _buildCard([
// // // //             ListTile(
// // // //               leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
// // // //               title: FittedBox(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 fit: BoxFit.scaleDown,
// // // //                 child: Text("SETTINGS_SUPPORT".tr(ref)),
// // // //               ),
// // // //               subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // // //               trailing: const Icon(Icons.mail_outline, size: 20),
// // // //               onTap: () async {
// // // //                 try {
// // // //                   await SupportService.sendSupportEmail();
// // // //                 } catch (e) {
// // // //                   if (context.mounted) {
// // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // //                       SnackBar(content: Text("ERROR_NO_EMAIL_APP".tr(ref))),
// // // //                     );
// // // //                   }
// // // //                 }
// // // //               },
// // // //             ),
// // // //           ]),
// // // //
// // // //           const SizedBox(height: 40),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // --- Helper Widgets ---
// // // //
// // // //   Widget _buildSectionTitle(String title) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
// // // //       child: FittedBox(
// // // //         alignment: Alignment.centerLeft,
// // // //         fit: BoxFit.scaleDown,
// // // //         child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildCard(List<Widget> children) {
// // // //     return Container(
// // // //       margin: const EdgeInsets.symmetric(horizontal: 16),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
// // // //       ),
// // // //       child: Column(children: children),
// // // //     );
// // // //   }
// // // //
// // // //   // --- Logic Methods ---
// // // //
// // // //   void _showLanguageDialog(BuildContext context, WidgetRef ref, Map<String, String> languages) {
// // // //     final currentLang = ref.read(localizationProvider.notifier).currentLang;
// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// // // //       builder: (context) => Container(
// // // //         padding: const EdgeInsets.symmetric(vertical: 20),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Text("SETTINGS_SELECT_LANGUAGE".tr(ref), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //             const Divider(),
// // // //             Expanded(
// // // //               child: ListView.builder(
// // // //                 itemCount: languages.length,
// // // //                 itemBuilder: (context, index) {
// // // //                   String key = languages.keys.elementAt(index);
// // // //                   String value = languages.values.elementAt(index);
// // // //                   bool isSelected = currentLang == key;
// // // //                   return ListTile(
// // // //                     title: Text(value, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF1A237E) : Colors.black)),
// // // //                     trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1A237E)) : null,
// // // //                     onTap: () async {
// // // //                       await ref.read(localizationProvider.notifier).changeLanguage(key);
// // // //                       if (context.mounted) Navigator.pop(context);
// // // //                       if (context.mounted) {
// // // //                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // //                             SnackBar(
// // // //                               content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
// // // //                               behavior: SnackBarBehavior.floating,
// // // //                             )
// // // //                         );
// // // //                       }
// // // //                     },
// // // //                   );
// // // //                 },
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Future<void> _pickImage(WidgetRef ref) async {
// // // //     final picker = ImagePicker();
// // // //     final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
// // // //     if (image != null) await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
// // // //   }
// // // //
// // // //   void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
// // // //     final currentNickname = ref.read(userNicknameProvider).nickname;
// // // //     final displayNickname = currentNickname.startsWith('SETTINGS_') ? currentNickname.tr(ref) : currentNickname;
// // // //
// // // //     final controller = TextEditingController(text: displayNickname);
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => StatefulBuilder(
// // // //         builder: (context, setState) => AlertDialog(
// // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // //           title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //           content: TextField(
// // // //             controller: controller,
// // // //             autofocus: true,
// // // //             onChanged: (value) => setState(() {}),
// // // //             decoration: InputDecoration(
// // // //               hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
// // // //               filled: true,
// // // //               fillColor: Colors.grey[100],
// // // //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
// // // //               suffixIcon: controller.text.isNotEmpty ? GestureDetector(onTap: () { controller.clear(); setState(() {}); }, child: const Icon(Icons.cancel, color: Colors.grey, size: 20)) : null,
// // // //             ),
// // // //           ),
// // // //           actions: [
// // // //             TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref), style: const TextStyle(color: Colors.grey))),
// // // //             ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white), onPressed: () async {
// // // //               if (controller.text.trim().isNotEmpty) {
// // // //                 await ref.read(userNicknameProvider.notifier).updateNickname(controller.text.trim());
// // // //                 if (context.mounted) Navigator.pop(context);
// // // //               }
// // // //             }, child: Text("COMMON_SAVE".tr(ref))),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
// // // //     try {
// // // //       final dbFolder = await getApplicationDocumentsDirectory();
// // // //       final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
// // // //       if (await dbFile.exists()) { await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup'); }
// // // //       else { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref)))); }
// // // //     } catch (e) { debugPrint("Backup Error: $e"); }
// // // //   }
// // // //
// // // //   Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
// // // //     final result = await FilePicker.platform.pickFiles();
// // // //     if (result != null && result.files.single.path != null) {
// // // //       try {
// // // //         final dbFolder = await getApplicationDocumentsDirectory();
// // // //         final newDbFile = File(result.files.single.path!);
// // // //         await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
// // // //         if (context.mounted) {
// // // //           showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
// // // //             title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
// // // //             content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
// // // //             actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_OK".tr(ref)))],
// // // //           ));
// // // //         }
// // // //       } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref)))); }
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
// // // //     return showDialog(context: context, builder: (context) => AlertDialog(
// // // //       title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
// // // //       content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
// // // //       actions: [
// // // //         TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
// // // //         TextButton(onPressed: () async { await ref.read(securityNotifierProvider.notifier).removePin(); if (context.mounted) Navigator.pop(context); }, child: Text("COMMON_DISABLE".tr(ref), style: const TextStyle(color: Colors.red))),
// // // //       ],
// // // //     ));
// // // //   }
// // // //
// // // //   // ✅ [추가] Pro 안내 다이얼로그
// // // //   void _showProDialog(BuildContext context, WidgetRef ref, bool isPro) {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text(isPro ? 'SiRE Pro' : 'SiRE Pro (잠금)'),
// // // //         content: Text(
// // // //           isPro
// // // //               ? '현재 Pro가 활성화되어 있습니다.\nReports / 분석 / Export 기능을 사용할 수 있습니다.'
// // // //               : 'Reports / 분석 / Export 기능은 Pro에서 제공됩니다.\n인앱 결제 연동은 다음 단계에서 연결할 예정입니다.',
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(context),
// // // //             child: const Text('OK'),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   // ✅ [추가] IAP 준비 중 다이얼로그
// // // //   void _showIapComingSoonDialog(BuildContext context) {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: const Text('Pro 결제'),
// // // //         content: const Text('인앱 결제 연동은 다음 단계에서 연결할 예정입니다.'),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(context),
// // // //             child: const Text('OK'),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // //
// // //
// // //
// // // import 'dart:io';
// // // import 'package:drift/drift.dart' hide Column;
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:share_plus/share_plus.dart';
// // // import 'package:file_picker/file_picker.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:path/path.dart' as p;
// // // import 'package:image_picker/image_picker.dart';
// // //
// // // import '../../core/localization/localization_provider.dart';
// // // import '../../core/purchase/models/purchase_status.dart';
// // // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 상태/구매/복원용
// // // import '../security/security_provider.dart';
// // // import '../security/pin_screen.dart';
// // // import 'category_management_screen.dart';
// // // import 'user_provider.dart';
// // // import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가
// // //
// // // // ✅ [변경] SettingsScreen을 ConsumerStatefulWidget으로 변경
// // // // - build()는 여러 번 호출될 수 있으므로, "Settings 진입 시 verify"는 initState에서 1회만 실행해야 합니다.
// // // // - 그렇지 않으면 reload()/verify가 build마다 반복 호출되어 UI 깜빡임/오탐 토스트가 발생할 수 있습니다.
// // // class SettingsScreen extends ConsumerStatefulWidget {
// // //   const SettingsScreen({super.key});
// // //
// // //   @override
// // //   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// // // }
// // //
// // // class _SettingsScreenState extends ConsumerState<SettingsScreen> {
// // //   // ✅ [추가] Settings 진입 시 verify를 1회만 실행하기 위한 플래그
// // //   bool _didTriggerVerifyOnEnter = false;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     // ✅ [추가] Settings 진입 시 1회 스토어 소유(owned) 재검증 트리거
// // //     // - build() 안에서 호출하면 재빌드 때마다 반복 실행되어 UI가 깜빡거릴 수 있음
// // //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// // //       if (!mounted) return;
// // //       if (_didTriggerVerifyOnEnter) return;
// // //       _didTriggerVerifyOnEnter = true;
// // //
// // //       // ✅ [정리]
// // //       // - 여기서는 "앱 시작 시점 verify"와 동일한 흐름을 Settings 진입 시에도 1회 재실행합니다.
// // //       // - reload() 내부에서 로컬 캐시 복원 + 스토어 owned 재검증을 수행합니다.
// // //       await ref.read(purchaseControllerProvider.notifier).reload();
// // //     });
// // //
// // //     // ✅ [추가] purchase state listen을 initState에서 1회만 등록
// // //     // - build 안에서 listen을 걸면 화면 리빌드 상황에 따라 중복 등록/오동작 가능성이 있습니다.
// // //     ref.listen<PurchaseState>(purchaseControllerProvider, (prev, next) {
// // //       // build 컨텍스트가 필요하므로 mounted 체크
// // //       if (!mounted) return;
// // //
// // //       // ------------------------------------------------------------------
// // //       // ✅ [유지] 기존 에러 메시지 처리
// // //       // ------------------------------------------------------------------
// // //       final msg = next.errorMessage;
// // //       if (msg != null && msg.isNotEmpty) {
// // //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text(msg),
// // //             behavior: SnackBarBehavior.floating,
// // //           ),
// // //         );
// // //       }
// // //
// // //       // ------------------------------------------------------------------
// // //       // ✅ [개선] 환불/권한 회수로 인한 Pro 해제 안내 (오탐 방지 강화)
// // //       //
// // //       // 문제 원인:
// // //       // - reload()가 loading 상태를 거치거나,
// // //       // - 스토어/캐시 초기화 직후 일시적으로 상태가 흔들릴 때
// // //       //   "Pro → Free"처럼 보이는 순간이 생길 수 있음.
// // //       //
// // //       // 해결:
// // //       // - "최종 상태"가 확정된 경우에만 안내
// // //       // - prev/next 모두 isLoading=false일 때만 띄움
// // //       // ------------------------------------------------------------------
// // //       final wasPro = prev?.isPro == true;
// // //       final isNowFree = next.isPro == false;
// // //
// // //       final prevStable = (prev?.isLoading ?? false) == false;
// // //       final nextStable = next.isLoading == false;
// // //
// // //       // ✅ loading 중간 상태에서는 절대 띄우지 않음
// // //       if (wasPro && isNowFree && prevStable && nextStable) {
// // //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text("Google Play 환불 또는 구매 취소로 인해 Pro가 비활성화되었습니다."),
// // //             behavior: SnackBarBehavior.floating,
// // //             duration: Duration(seconds: 4),
// // //           ),
// // //         );
// // //       }
// // //     });
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final hasPin = ref.watch(securityNotifierProvider).value ?? false;
// // //     final profile = ref.watch(userNicknameProvider);
// // //
// // //     // ✅ [추가] Pro 상태 확인
// // //     final isPro = ref.watch(isProProvider);
// // //     final purchaseState = ref.watch(purchaseControllerProvider);
// // //
// // //     // 지원하는 20개 언어 리스트
// // //     final Map<String, String> languages = {
// // //       "ar": "العربية", "bn": "বাংলা", "zh": "中文 (简体)", "nl": "Nederlands",
// // //       "en": "English", "fr": "Français", "de": "Deutsch", "hi": "हिन्दी",
// // //       "id": "Bahasa Indonesia", "it": "Italiano", "ja": "日本語", "ko": "한국어",
// // //       "ms": "Bahasa Melayu", "pl": "Polski", "pt": "Português", "ru": "Русский",
// // //       "es": "Español", "th": "ไทย", "tr": "Türkçe", "vi": "Tiếng Việt"
// // //     };
// // //
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[50],
// // //       appBar: AppBar(
// // //         title: Text("NAV_SETTINGS".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //         backgroundColor: const Color(0xFF1A237E),
// // //         foregroundColor: Colors.white,
// // //         elevation: 0,
// // //       ),
// // //
// // //       // ✅ [개선] purchaseState.errorMessage가 생기면 자동으로 스낵바 표시
// // //       // - 기존에는 Builder 안에서 listen을 등록했으나,
// // //       //   rebuild마다 중복 listen 가능성이 있어 initState로 이동했습니다.
// // //       body: ListView(
// // //         children: [
// // //           // --- 1. User Profile Section (사용자 프로필: 최상단 배치) ---
// // //           _buildSectionTitle("SETTINGS_USER_PROFILE".tr(ref)),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: GestureDetector(
// // //                 onTap: () => _pickImage(ref),
// // //                 child: CircleAvatar(
// // //                   radius: 25,
// // //                   backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
// // //                   backgroundImage: profile.imagePath != null ? FileImage(File(profile.imagePath!)) : null,
// // //                   child: profile.imagePath == null ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E)) : null,
// // //                 ),
// // //               ),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
// // //               ),
// // //               subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // //               trailing: const Icon(Icons.chevron_right),
// // //               onTap: () => _pickImage(ref),
// // //             ),
// // //             const Divider(height: 1),
// // //             ListTile(
// // //               leading: const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
// // //               ),
// // //               subtitle: Text(
// // //                 profile.nickname.startsWith('SETTINGS_') ? profile.nickname.tr(ref) : profile.nickname,
// // //                 maxLines: 1,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               trailing: const Icon(Icons.edit_outlined, size: 20),
// // //               onTap: () => _showEditNicknameDialog(context, ref),
// // //             ),
// // //           ]),
// // //
// // //           // --- 2. Security Section (보안: PIN 설정) ---
// // //           _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
// // //               title: FractionallySizedBox(
// // //                 widthFactor: 0.9,
// // //                 child: FittedBox(
// // //                   alignment: Alignment.centerLeft,
// // //                   fit: BoxFit.scaleDown,
// // //                   child: Text("SETTINGS_USE_PIN".tr(ref)),
// // //                 ),
// // //               ),
// // //               trailing: Switch(
// // //                 value: hasPin,
// // //                 activeColor: const Color(0xFF1A237E),
// // //                 onChanged: (value) async {
// // //                   if (value) {
// // //                     Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true)));
// // //                   } else {
// // //                     await _showDeleteConfirmDialog(context, ref);
// // //                   }
// // //                 },
// // //               ),
// // //             ),
// // //             if (hasPin) ...[
// // //               const Divider(height: 1),
// // //               ListTile(
// // //                 leading: const Icon(Icons.password, color: Color(0xFF1A237E)),
// // //                 title: FittedBox(
// // //                   alignment: Alignment.centerLeft,
// // //                   fit: BoxFit.scaleDown,
// // //                   child: Text("SETTINGS_CHANGE_PIN".tr(ref)),
// // //                 ),
// // //                 trailing: const Icon(Icons.chevron_right),
// // //                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true))),
// // //               ),
// // //             ],
// // //           ]),
// // //
// // //           // --- ✅ [추가] Pro Section (결제: SiRE Pro 평생 구매) ---
// // //           _buildSectionTitle("SiRE Pro"),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: Icon(
// // //                 isPro ? Icons.verified : Icons.workspace_premium_outlined,
// // //                 color: isPro ? Colors.green : const Color(0xFF1A237E),
// // //               ),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text(isPro ? "Pro 활성화됨" : "Pro 기능 잠금"),
// // //               ),
// // //               subtitle: Text(
// // //                 isPro
// // //                     ? "Reports / 분석 / Export 기능을 사용할 수 있습니다."
// // //                     : "Reports / 분석 / Export 기능은 Pro에서 제공됩니다.",
// // //                 maxLines: 2,
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //               trailing: purchaseState.isLoading
// // //                   ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
// // //                   : const Icon(Icons.chevron_right),
// // //               onTap: () => _showProDialog(context, ref, isPro),
// // //             ),
// // //
// // //             // ✅ Pro 미구매 상태에서만 구매 메뉴 노출
// // //             if (!isPro) ...[
// // //               const Divider(height: 1),
// // //               ListTile(
// // //                 leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E)),
// // //                 title: FittedBox(
// // //                   alignment: Alignment.centerLeft,
// // //                   fit: BoxFit.scaleDown,
// // //                   child: const Text("Pro 구매 (평생)"),
// // //                 ),
// // //                 subtitle: const Text("1회 구매로 Reports / 분석 / Export 기능을 잠금 해제합니다."),
// // //                 onTap: purchaseState.isLoading
// // //                     ? null
// // //                     : () async {
// // //                   if (context.mounted) {
// // //                     ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //                   }
// // //
// // //                   await ref.read(purchaseControllerProvider.notifier).purchaseProLifetime();
// // //
// // //                   final latest = ref.read(purchaseControllerProvider);
// // //
// // //                   if (latest.errorMessage != null && latest.errorMessage!.isNotEmpty) {
// // //                     if (context.mounted) {
// // //                       ScaffoldMessenger.of(context).showSnackBar(
// // //                         SnackBar(
// // //                           content: Text("결제 시작 실패: ${latest.errorMessage}"),
// // //                           behavior: SnackBarBehavior.floating,
// // //                         ),
// // //                       );
// // //                     }
// // //                     return;
// // //                   }
// // //
// // //                   if (context.mounted) {
// // //                     ScaffoldMessenger.of(context).showSnackBar(
// // //                       const SnackBar(
// // //                         content: Text("결제 화면이 표시되면 안내에 따라 진행해주세요."),
// // //                         behavior: SnackBarBehavior.floating,
// // //                       ),
// // //                     );
// // //                   }
// // //                 },
// // //               ),
// // //             ],
// // //
// // //             const Divider(height: 1),
// // //             ListTile(
// // //               leading: const Icon(Icons.restore, color: Colors.orange),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: const Text("구매 복원"),
// // //               ),
// // //               subtitle: const Text("기기 변경/재설치 시 구매 내역을 복원합니다."),
// // //               onTap: purchaseState.isLoading
// // //                   ? null
// // //                   : () async {
// // //                 await ref.read(purchaseControllerProvider.notifier).restorePurchases();
// // //                 await ref.read(purchaseControllerProvider.notifier).reload();
// // //
// // //                 if (context.mounted) {
// // //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(
// // //                       content: Text("구매 복원 요청을 보냈습니다. 복원 결과는 잠시 후 반영될 수 있습니다."),
// // //                       behavior: SnackBarBehavior.floating,
// // //                     ),
// // //                   );
// // //                 }
// // //               },
// // //             ),
// // //
// // //             // ---------------------------------------------------------------------
// // //             // ✅ [개발자 토글] 유지 방식 (요청 반영)
// // //             //
// // //             // 너가 요청한대로 "삭제"하지 않고, 아래처럼 "주석으로 보관"해둡니다.
// // //             // 나중에 개발/디버깅이 필요할 때 주석을 해제하여 다시 사용할 수 있습니다.
// // //             //
// // //             // 권장 운영 방식:
// // //             // 1) 디버그 빌드에서만 노출하도록 if (kDebugMode)로 감싸서 사용
// // //             // 2) 스토어 배포(릴리즈) 직전에는 반드시 숨김/삭제
// // //             //
// // //             // 현재는 안전하게 "완전 비활성(주석)" 상태로 두었습니다.
// // //             // ---------------------------------------------------------------------
// // //
// // //             /*
// // //             const Divider(height: 1),
// // //             SwitchListTile(
// // //               secondary: const Icon(Icons.build_outlined, color: Colors.teal),
// // //               title: const Text("개발용: Pro 상태 토글"),
// // //               subtitle: const Text("테스트 편의를 위한 임시 기능입니다. 배포 전 제거 권장"),
// // //               value: isPro,
// // //               onChanged: (value) async {
// // //                 await ref.read(purchaseControllerProvider.notifier).setPro(value);
// // //                 if (context.mounted) {
// // //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     SnackBar(
// // //                       content: Text(value ? "Pro가 활성화되었습니다." : "Pro가 비활성화되었습니다."),
// // //                       behavior: SnackBarBehavior.floating,
// // //                     ),
// // //                   );
// // //                 }
// // //               },
// // //             ),
// // //             */
// // //           ]),
// // //
// // //           // --- 3. Language Section (언어 설정: 다국어) ---
// // //           _buildSectionTitle("SETTINGS_LANGUAGE_SECTION".tr(ref)),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: const Icon(Icons.language, color: Color(0xFF1A237E)),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_SELECT_LANGUAGE".tr(ref)),
// // //               ),
// // //               subtitle: Text(languages[ref.read(localizationProvider.notifier).currentLang] ?? ""),
// // //               trailing: const Icon(Icons.chevron_right),
// // //               onTap: () => _showLanguageDialog(context, ref, languages),
// // //             ),
// // //           ]),
// // //
// // //           // --- 4. Customization Section (맞춤 설정: 카테고리 관리) ---
// // //           _buildSectionTitle("SETTINGS_CUSTOMIZATION".tr(ref)),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: const Icon(Icons.category_outlined, color: Colors.teal),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_MANAGE_CATEGORIES".tr(ref)),
// // //               ),
// // //               subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // //               trailing: const Icon(Icons.chevron_right),
// // //               onTap: () {
// // //                 Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen()));
// // //               },
// // //             ),
// // //           ]),
// // //
// // //           // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
// // //           _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_BACKUP".tr(ref)),
// // //               ),
// // //               subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // //               onTap: () => _handleBackup(context, ref),
// // //             ),
// // //             const Divider(height: 1),
// // //             ListTile(
// // //               leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_RESTORE".tr(ref)),
// // //               ),
// // //               subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // //               onTap: () => _handleRestore(context, ref),
// // //             ),
// // //           ]),
// // //
// // //           // --- 6. App Support Section (지원: 문의 및 환불 정책) ---
// // //           _buildSectionTitle("SETTINGS_SUPPORT_SECTION".tr(ref)),
// // //           _buildCard([
// // //             ListTile(
// // //               leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
// // //               title: FittedBox(
// // //                 alignment: Alignment.centerLeft,
// // //                 fit: BoxFit.scaleDown,
// // //                 child: Text("SETTINGS_SUPPORT".tr(ref)),
// // //               ),
// // //               subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
// // //               trailing: const Icon(Icons.mail_outline, size: 20),
// // //               onTap: () async {
// // //                 try {
// // //                   await SupportService.sendSupportEmail();
// // //                 } catch (e) {
// // //                   if (context.mounted) {
// // //                     ScaffoldMessenger.of(context).showSnackBar(
// // //                       SnackBar(content: Text("ERROR_NO_EMAIL_APP".tr(ref))),
// // //                     );
// // //                   }
// // //                 }
// // //               },
// // //             ),
// // //           ]),
// // //
// // //           const SizedBox(height: 40),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // --- Helper Widgets ---
// // //
// // //   Widget _buildSectionTitle(String title) {
// // //     return Padding(
// // //       padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
// // //       child: FittedBox(
// // //         alignment: Alignment.centerLeft,
// // //         fit: BoxFit.scaleDown,
// // //         child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildCard(List<Widget> children) {
// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(horizontal: 16),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(12),
// // //         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
// // //       ),
// // //       child: Column(children: children),
// // //     );
// // //   }
// // //
// // //   // --- Logic Methods ---
// // //
// // //   void _showLanguageDialog(BuildContext context, WidgetRef ref, Map<String, String> languages) {
// // //     final currentLang = ref.read(localizationProvider.notifier).currentLang;
// // //     showModalBottomSheet(
// // //       context: context,
// // //       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// // //       builder: (context) => Container(
// // //         padding: const EdgeInsets.symmetric(vertical: 20),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Text("SETTINGS_SELECT_LANGUAGE".tr(ref), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //             const Divider(),
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: languages.length,
// // //                 itemBuilder: (context, index) {
// // //                   String key = languages.keys.elementAt(index);
// // //                   String value = languages.values.elementAt(index);
// // //                   bool isSelected = currentLang == key;
// // //                   return ListTile(
// // //                     title: Text(
// // //                       value,
// // //                       style: TextStyle(
// // //                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
// // //                         color: isSelected ? const Color(0xFF1A237E) : Colors.black,
// // //                       ),
// // //                     ),
// // //                     trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1A237E)) : null,
// // //                     onTap: () async {
// // //                       await ref.read(localizationProvider.notifier).changeLanguage(key);
// // //                       if (context.mounted) Navigator.pop(context);
// // //                       if (context.mounted) {
// // //                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           SnackBar(
// // //                             content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
// // //                             behavior: SnackBarBehavior.floating,
// // //                           ),
// // //                         );
// // //                       }
// // //                     },
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<void> _pickImage(WidgetRef ref) async {
// // //     final picker = ImagePicker();
// // //     final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
// // //     if (image != null) await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
// // //   }
// // //
// // //   void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
// // //     final currentNickname = ref.read(userNicknameProvider).nickname;
// // //     final displayNickname = currentNickname.startsWith('SETTINGS_') ? currentNickname.tr(ref) : currentNickname;
// // //
// // //     final controller = TextEditingController(text: displayNickname);
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => StatefulBuilder(
// // //         builder: (context, setState) => AlertDialog(
// // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //           title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
// // //           content: TextField(
// // //             controller: controller,
// // //             autofocus: true,
// // //             onChanged: (value) => setState(() {}),
// // //             decoration: InputDecoration(
// // //               hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
// // //               filled: true,
// // //               fillColor: Colors.grey[100],
// // //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
// // //               suffixIcon: controller.text.isNotEmpty
// // //                   ? GestureDetector(
// // //                 onTap: () {
// // //                   controller.clear();
// // //                   setState(() {});
// // //                 },
// // //                 child: const Icon(Icons.cancel, color: Colors.grey, size: 20),
// // //               )
// // //                   : null,
// // //             ),
// // //           ),
// // //           actions: [
// // //             TextButton(
// // //               onPressed: () => Navigator.pop(context),
// // //               child: Text("COMMON_CANCEL".tr(ref), style: const TextStyle(color: Colors.grey)),
// // //             ),
// // //             ElevatedButton(
// // //               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
// // //               onPressed: () async {
// // //                 if (controller.text.trim().isNotEmpty) {
// // //                   await ref.read(userNicknameProvider.notifier).updateNickname(controller.text.trim());
// // //                   if (context.mounted) Navigator.pop(context);
// // //                 }
// // //               },
// // //               child: Text("COMMON_SAVE".tr(ref)),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
// // //     try {
// // //       final dbFolder = await getApplicationDocumentsDirectory();
// // //       final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
// // //       if (await dbFile.exists()) {
// // //         await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup');
// // //       } else {
// // //         if (context.mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref))));
// // //         }
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Backup Error: $e");
// // //     }
// // //   }
// // //
// // //   Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
// // //     final result = await FilePicker.platform.pickFiles();
// // //     if (result != null && result.files.single.path != null) {
// // //       try {
// // //         final dbFolder = await getApplicationDocumentsDirectory();
// // //         final newDbFile = File(result.files.single.path!);
// // //         await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
// // //         if (context.mounted) {
// // //           showDialog(
// // //             context: context,
// // //             barrierDismissible: false,
// // //             builder: (context) => AlertDialog(
// // //               title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
// // //               content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
// // //               actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_OK".tr(ref)))],
// // //             ),
// // //           );
// // //         }
// // //       } catch (e) {
// // //         if (context.mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref))));
// // //         }
// // //       }
// // //     }
// // //   }
// // //
// // //   Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
// // //     return showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
// // //         content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
// // //         actions: [
// // //           TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
// // //           TextButton(
// // //             onPressed: () async {
// // //               await ref.read(securityNotifierProvider.notifier).removePin();
// // //               if (context.mounted) Navigator.pop(context);
// // //             },
// // //             child: Text("COMMON_DISABLE".tr(ref), style: const TextStyle(color: Colors.red)),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [추가] Pro 안내 다이얼로그
// // //   void _showProDialog(BuildContext context, WidgetRef ref, bool isPro) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: Text(isPro ? 'SiRE Pro' : 'SiRE Pro (잠금)'),
// // //         content: Text(
// // //           isPro
// // //               ? '현재 Pro가 활성화되어 있습니다.\nReports / 분석 / Export 기능을 사용할 수 있습니다.'
// // //               : 'Reports / 분석 / Export 기능은 Pro에서 제공됩니다.\n설정 > SiRE Pro에서 구매/복원을 진행할 수 있습니다.',
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             child: const Text('OK'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ✅ [추가] IAP 준비 중 다이얼로그
// // //   void _showIapComingSoonDialog(BuildContext context) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('Pro 결제'),
// // //         content: const Text('스토어 결제 환경이 준비되지 않았습니다. (테스트 기기/계정/스토어 설정 확인 필요)'),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             child: const Text('OK'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'dart:io';
// // import 'package:drift/drift.dart' hide Column;
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:path/path.dart' as p;
// // import 'package:image_picker/image_picker.dart';
// //
// // import '../../core/localization/localization_provider.dart';
// // import '../../core/purchase/models/purchase_status.dart';
// // import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 상태/구매/복원용
// // import '../security/security_provider.dart';
// // import '../security/pin_screen.dart';
// // import 'category_management_screen.dart';
// // import 'user_provider.dart';
// // import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가
// //
// // // ✅ [변경] SettingsScreen을 ConsumerStatefulWidget으로 변경
// // // - build()는 여러 번 호출될 수 있으므로, "Settings 진입 시 verify"는 initState에서 1회만 실행해야 합니다.
// // // - 그렇지 않으면 reload()/verify가 build마다 반복 호출되어 UI 깜빡임/오탐 토스트가 발생할 수 있습니다.
// // class SettingsScreen extends ConsumerStatefulWidget {
// //   const SettingsScreen({super.key});
// //
// //   @override
// //   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// // }
// //
// // class _SettingsScreenState extends ConsumerState<SettingsScreen> {
// //   // ✅ [추가] Settings 진입 시 verify를 1회만 실행하기 위한 플래그
// //   bool _didTriggerVerifyOnEnter = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     // ✅ [추가] Settings 진입 시 1회 스토어 소유(owned) 재검증 트리거
// //     // - build() 안에서 호출하면 재빌드 때마다 반복 실행되어 UI가 깜빡거릴 수 있음
// //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// //       if (!mounted) return;
// //       if (_didTriggerVerifyOnEnter) return;
// //       _didTriggerVerifyOnEnter = true;
// //
// //       // ✅ [중요 변경]
// //       // - 이전에는 reload()를 호출했는데, reload()는 "로컬 캐시 복원 + verify"를 동시에 수행하면서
// //       //   상태가 loading/free/pro로 흔들릴 수 있어 오탐 메시지/깜빡임의 원인이 될 수 있습니다.
// //       // - Settings 진입 시에는 "스토어 소유 재검증"만 조용히 1회 수행하는 게 안정적입니다.
// //       //
// //       // ✅ 따라서, PurchaseController에 추가한 공개 메서드 verifyEntitlementFromStore()를 호출합니다.
// //       // - 결과 메시지를 반환하므로, "메시지가 뜨는지만" 테스트도 여기서 가능합니다.
// //       final result = await ref
// //           .read(purchaseControllerProvider.notifier)
// //           .verifyEntitlementFromStore();
// //
// //       // ✅ [테스트] 메시지가 뜨는지만 확인
// //       // - 원하면 이 부분을 나중에 제거하거나, 특정 조건에서만 보이게 할 수 있습니다.
// //       if (!mounted) return;
// //       final msg = result.message;
// //       if (msg != null && msg.isNotEmpty) {
// //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(msg),
// //             behavior: SnackBarBehavior.floating,
// //           ),
// //         );
// //       }
// //     });
// //
// //     // ✅ [추가] purchase state listen을 initState에서 1회만 등록
// //     // - build 안에서 listen을 걸면 화면 리빌드 상황에 따라 중복 등록/오동작 가능성이 있습니다.
// //     ref.listen<PurchaseState>(purchaseControllerProvider, (prev, next) {
// //       // build 컨텍스트가 필요하므로 mounted 체크
// //       if (!mounted) return;
// //
// //       // ------------------------------------------------------------------
// //       // ✅ [유지] 기존 에러 메시지 처리
// //       // ------------------------------------------------------------------
// //       final msg = next.errorMessage;
// //       if (msg != null && msg.isNotEmpty) {
// //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(msg),
// //             behavior: SnackBarBehavior.floating,
// //           ),
// //         );
// //       }
// //
// //       // ------------------------------------------------------------------
// //       // ✅ [개선] 환불/권한 회수로 인한 Pro 해제 안내 (오탐 방지 강화)
// //       //
// //       // 문제 원인:
// //       // - reload()가 loading 상태를 거치거나,
// //       // - 스토어/캐시 초기화 직후 일시적으로 상태가 흔들릴 때
// //       //   "Pro → Free"처럼 보이는 순간이 생길 수 있음.
// //       //
// //       // 해결:
// //       // - "최종 상태"가 확정된 경우에만 안내
// //       // - prev/next 모두 isLoading=false일 때만 띄움
// //       // ------------------------------------------------------------------
// //       final wasPro = prev?.isPro == true;
// //       final isNowFree = next.isPro == false;
// //
// //       final prevStable = (prev?.isLoading ?? false) == false;
// //       final nextStable = next.isLoading == false;
// //
// //       // ✅ loading 중간 상태에서는 절대 띄우지 않음
// //       // if (wasPro && isNowFree && prevStable && nextStable) {
// //       //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //       //   ScaffoldMessenger.of(context).showSnackBar(
// //       //     const SnackBar(
// //       //       content: Text("Google Play 환불 또는 구매 취소로 인해 Pro가 비활성화되었습니다."),
// //       //       behavior: SnackBarBehavior.floating,
// //       //       duration: Duration(seconds: 4),
// //       //     ),
// //       //   );
// //       // }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final hasPin = ref.watch(securityNotifierProvider).value ?? false;
// //     final profile = ref.watch(userNicknameProvider);
// //
// //     // ✅ [추가] Pro 상태 확인
// //     final isPro = ref.watch(isProProvider);
// //     final purchaseState = ref.watch(purchaseControllerProvider);
// //
// //     // 지원하는 20개 언어 리스트
// //     final Map<String, String> languages = {
// //       "ar": "العربية",
// //       "bn": "বাংলা",
// //       "zh": "中文 (简体)",
// //       "nl": "Nederlands",
// //       "en": "English",
// //       "fr": "Français",
// //       "de": "Deutsch",
// //       "hi": "हिन्दी",
// //       "id": "Bahasa Indonesia",
// //       "it": "Italiano",
// //       "ja": "日本語",
// //       "ko": "한국어",
// //       "ms": "Bahasa Melayu",
// //       "pl": "Polski",
// //       "pt": "Português",
// //       "ru": "Русский",
// //       "es": "Español",
// //       "th": "ไทย",
// //       "tr": "Türkçe",
// //       "vi": "Tiếng Việt"
// //     };
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       appBar: AppBar(
// //         title: Text("NAV_SETTINGS".tr(ref),
// //             style: const TextStyle(fontWeight: FontWeight.bold)),
// //         backgroundColor: const Color(0xFF1A237E),
// //         foregroundColor: Colors.white,
// //         elevation: 0,
// //       ),
// //
// //       // ✅ [개선] purchaseState.errorMessage가 생기면 자동으로 스낵바 표시
// //       // - 기존에는 Builder 안에서 listen을 등록했으나,
// //       //   rebuild마다 중복 listen 가능성이 있어 initState로 이동했습니다.
// //       body: ListView(
// //         children: [
// //           // --- 1. User Profile Section (사용자 프로필: 최상단 배치) ---
// //           _buildSectionTitle("SETTINGS_USER_PROFILE".tr(ref)),
// //           _buildCard([
// //             ListTile(
// //               leading: GestureDetector(
// //                 onTap: () => _pickImage(ref),
// //                 child: CircleAvatar(
// //                   radius: 25,
// //                   backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
// //                   backgroundImage: profile.imagePath != null
// //                       ? FileImage(File(profile.imagePath!))
// //                       : null,
// //                   child: profile.imagePath == null
// //                       ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E))
// //                       : null,
// //                 ),
// //               ),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
// //               ),
// //               subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref),
// //                   maxLines: 1, overflow: TextOverflow.ellipsis),
// //               trailing: const Icon(Icons.chevron_right),
// //               onTap: () => _pickImage(ref),
// //             ),
// //             const Divider(height: 1),
// //             ListTile(
// //               leading:
// //               const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
// //               ),
// //               subtitle: Text(
// //                 profile.nickname.startsWith('SETTINGS_')
// //                     ? profile.nickname.tr(ref)
// //                     : profile.nickname,
// //                 maxLines: 1,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               trailing: const Icon(Icons.edit_outlined, size: 20),
// //               onTap: () => _showEditNicknameDialog(context, ref),
// //             ),
// //           ]),
// //
// //           // --- 2. Security Section (보안: PIN 설정) ---
// //           _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
// //           _buildCard([
// //             ListTile(
// //               leading:
// //               const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
// //               title: FractionallySizedBox(
// //                 widthFactor: 0.9,
// //                 child: FittedBox(
// //                   alignment: Alignment.centerLeft,
// //                   fit: BoxFit.scaleDown,
// //                   child: Text("SETTINGS_USE_PIN".tr(ref)),
// //                 ),
// //               ),
// //               trailing: Switch(
// //                 value: hasPin,
// //                 activeColor: const Color(0xFF1A237E),
// //                 onChanged: (value) async {
// //                   if (value) {
// //                     Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                             builder: (context) =>
// //                             const PinScreen(isSetting: true)));
// //                   } else {
// //                     await _showDeleteConfirmDialog(context, ref);
// //                   }
// //                 },
// //               ),
// //             ),
// //             if (hasPin) ...[
// //               const Divider(height: 1),
// //               ListTile(
// //                 leading: const Icon(Icons.password, color: Color(0xFF1A237E)),
// //                 title: FittedBox(
// //                   alignment: Alignment.centerLeft,
// //                   fit: BoxFit.scaleDown,
// //                   child: Text("SETTINGS_CHANGE_PIN".tr(ref)),
// //                 ),
// //                 trailing: const Icon(Icons.chevron_right),
// //                 onTap: () => Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                         builder: (context) =>
// //                         const PinScreen(isSetting: true))),
// //               ),
// //             ],
// //           ]),
// //
// //           // --- ✅ [추가] Pro Section (결제: SiRE Pro 평생 구매) ---
// //           _buildSectionTitle("SiRE Pro"),
// //           _buildCard([
// //             // ListTile(
// //             //   leading: Icon(
// //             //     isPro ? Icons.verified : Icons.workspace_premium_outlined,
// //             //     color: isPro ? Colors.green : const Color(0xFF1A237E),
// //             //   ),
// //             //   title: FittedBox(
// //             //     alignment: Alignment.centerLeft,
// //             //     fit: BoxFit.scaleDown,
// //             //     child: Text(isPro ? "Pro 활성화됨" : "Pro 기능 잠금"),
// //             //   ),
// //             //   subtitle: Text(
// //             //     isPro
// //             //         ? "Reports / 분석 / Export 기능을 사용할 수 있습니다."
// //             //         : "Reports / 분석 / Export 기능은 Pro에서 제공됩니다.",
// //             //     maxLines: 2,
// //             //     overflow: TextOverflow.ellipsis,
// //             //   ),
// //             //   trailing: purchaseState.isLoading
// //             //       ? const SizedBox(
// //             //       width: 18,
// //             //       height: 18,
// //             //       child: CircularProgressIndicator(strokeWidth: 2))
// //             //       : const Icon(Icons.chevron_right),
// //             //   onTap: () => _showProDialog(context, ref, isPro),
// //             // ),
// //
// //             // ✅ Pro 미구매 상태에서만 구매 메뉴 노출
// //             // if (!isPro) ...[
// //             //   const Divider(height: 1),
// //             //   ListTile(
// //             //     leading: const Icon(Icons.workspace_premium_outlined,
// //             //         color: Color(0xFF1A237E)),
// //             //     title: FittedBox(
// //             //       alignment: Alignment.centerLeft,
// //             //       fit: BoxFit.scaleDown,
// //             //       child: const Text("Pro 구매 (평생)"),
// //             //     ),
// //             //     subtitle: const Text("1회 구매로 Reports / 분석 / Export 기능을 잠금 해제합니다."),
// //             //     onTap: purchaseState.isLoading
// //             //         ? null
// //             //         : () async {
// //             //       if (context.mounted) {
// //             //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //             //       }
// //             //
// //             //       await ref
// //             //           .read(purchaseControllerProvider.notifier)
// //             //           .purchaseProLifetime();
// //             //
// //             //       final latest = ref.read(purchaseControllerProvider);
// //             //
// //             //       if (latest.errorMessage != null &&
// //             //           latest.errorMessage!.isNotEmpty) {
// //             //         if (context.mounted) {
// //             //           ScaffoldMessenger.of(context).showSnackBar(
// //             //             SnackBar(
// //             //               content:
// //             //               Text("결제 시작 실패: ${latest.errorMessage}"),
// //             //               behavior: SnackBarBehavior.floating,
// //             //             ),
// //             //           );
// //             //         }
// //             //         return;
// //             //       }
// //             //
// //             //       if (context.mounted) {
// //             //         ScaffoldMessenger.of(context).showSnackBar(
// //             //           const SnackBar(
// //             //             content: Text("결제 화면이 표시되면 안내에 따라 진행해주세요."),
// //             //             behavior: SnackBarBehavior.floating,
// //             //           ),
// //             //         );
// //             //       }
// //             //     },
// //             //   ),
// //             // ],
// //
// //             ListTile(
// //               leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E)),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: const Text("Pro 구매 (평생)"),
// //               ),
// //               subtitle: Text(
// //                 isPro
// //                     ? "이미 Pro가 활성화되어 있습니다."
// //                     : "1회 구매로 Reports / 분석 / Export 기능을 잠금 해제합니다.",
// //                 maxLines: 2,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               // ✅ Pro면 탭해도 구매 시작 안 하게 막고(또는 안내만)
// //               onTap: (purchaseState.isLoading || isPro)
// //                   ? () {
// //                 if (!context.mounted) return;
// //                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text("이미 Pro가 활성화되어 있습니다."),
// //                     behavior: SnackBarBehavior.floating,
// //                   ),
// //                 );
// //               }
// //                   : () async {
// //                 if (context.mounted) {
// //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //                 }
// //
// //                 await ref.read(purchaseControllerProvider.notifier).purchaseProLifetime();
// //
// //                 final latest = ref.read(purchaseControllerProvider);
// //
// //                 if (latest.errorMessage != null && latest.errorMessage!.isNotEmpty) {
// //                   if (context.mounted) {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(
// //                         content: Text("결제 시작 실패: ${latest.errorMessage}"),
// //                         behavior: SnackBarBehavior.floating,
// //                       ),
// //                     );
// //                   }
// //                   return;
// //                 }
// //
// //                 if (context.mounted) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text("결제 화면이 표시되면 안내에 따라 진행해주세요."),
// //                       behavior: SnackBarBehavior.floating,
// //                     ),
// //                   );
// //                 }
// //               },
// //             ),
// //
// //             const Divider(height: 1),
// //
// //             ListTile(
// //               leading: const Icon(Icons.restore, color: Colors.orange),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: const Text("구매 복원"),
// //               ),
// //               subtitle: const Text("기기 변경/재설치 시 구매 내역을 복원합니다."),
// //               onTap: purchaseState.isLoading
// //                   ? null
// //                   : () async {
// //                 await ref
// //                     .read(purchaseControllerProvider.notifier)
// //                     .restorePurchases();
// //
// //                 // ✅ [정리]
// //                 // - restore 후 reload()는 상태 흔들림을 만들 수 있으니 여기서는 제거합니다.
// //                 // - restore 결과는 purchaseStream 이벤트로 반영됩니다.
// //                 // - 필요하다면 Settings 진입 verifyEntitlementFromStore()가 추가 안전망 역할을 합니다.
// //
// //                 if (context.mounted) {
// //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text(
// //                           "구매 복원 요청을 보냈습니다. 복원 결과는 잠시 후 반영될 수 있습니다."),
// //                       behavior: SnackBarBehavior.floating,
// //                     ),
// //                   );
// //                 }
// //               },
// //             ),
// //
// //             // ---------------------------------------------------------------------
// //             // ✅ [개발자 토글] 유지 방식 (요청 반영)
// //             //
// //             // 너가 요청한대로 "삭제"하지 않고, 아래처럼 "주석으로 보관"해둡니다.
// //             // 나중에 개발/디버깅이 필요할 때 주석을 해제하여 다시 사용할 수 있습니다.
// //             //
// //             // 권장 운영 방식:
// //             // 1) 디버그 빌드에서만 노출하도록 if (kDebugMode)로 감싸서 사용
// //             // 2) 스토어 배포(릴리즈) 직전에는 반드시 숨김/삭제
// //             //
// //             // 현재는 안전하게 "완전 비활성(주석)" 상태로 두었습니다.
// //             // ---------------------------------------------------------------------
// //
// //             /*
// //             const Divider(height: 1),
// //             SwitchListTile(
// //               secondary: const Icon(Icons.build_outlined, color: Colors.teal),
// //               title: const Text("개발용: Pro 상태 토글"),
// //               subtitle: const Text("테스트 편의를 위한 임시 기능입니다. 배포 전 제거 권장"),
// //               value: isPro,
// //               onChanged: (value) async {
// //                 await ref.read(purchaseControllerProvider.notifier).setPro(value);
// //                 if (context.mounted) {
// //                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text(value ? "Pro가 활성화되었습니다." : "Pro가 비활성화되었습니다."),
// //                       behavior: SnackBarBehavior.floating,
// //                     ),
// //                   );
// //                 }
// //               },
// //             ),
// //             */
// //           ]),
// //
// //           // --- 3. Language Section (언어 설정: 다국어) ---
// //           _buildSectionTitle("SETTINGS_LANGUAGE_SECTION".tr(ref)),
// //           _buildCard([
// //             ListTile(
// //               leading: const Icon(Icons.language, color: Color(0xFF1A237E)),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_SELECT_LANGUAGE".tr(ref)),
// //               ),
// //               subtitle: Text(
// //                   languages[ref.read(localizationProvider.notifier).currentLang] ??
// //                       ""),
// //               trailing: const Icon(Icons.chevron_right),
// //               onTap: () => _showLanguageDialog(context, ref, languages),
// //             ),
// //           ]),
// //
// //           // --- 4. Customization Section (맞춤 설정: 카테고리 관리) ---
// //           _buildSectionTitle("SETTINGS_CUSTOMIZATION".tr(ref)),
// //           _buildCard([
// //             ListTile(
// //               leading: const Icon(Icons.category_outlined, color: Colors.teal),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_MANAGE_CATEGORIES".tr(ref)),
// //               ),
// //               subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref),
// //                   maxLines: 1, overflow: TextOverflow.ellipsis),
// //               trailing: const Icon(Icons.chevron_right),
// //               onTap: () {
// //                 Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                         builder: (context) =>
// //                         const CategoryManagementScreen()));
// //               },
// //             ),
// //           ]),
// //
// //           // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
// //           _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
// //           _buildCard([
// //             ListTile(
// //               leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_BACKUP".tr(ref)),
// //               ),
// //               subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref),
// //                   maxLines: 1, overflow: TextOverflow.ellipsis),
// //               onTap: () => _handleBackup(context, ref),
// //             ),
// //             const Divider(height: 1),
// //             ListTile(
// //               leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_RESTORE".tr(ref)),
// //               ),
// //               subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref),
// //                   maxLines: 1, overflow: TextOverflow.ellipsis),
// //               onTap: () => _handleRestore(context, ref),
// //             ),
// //           ]),
// //
// //           // --- 6. App Support Section (지원: 문의 및 환불 정책) ---
// //           _buildSectionTitle("SETTINGS_SUPPORT_SECTION".tr(ref)),
// //           _buildCard([
// //             ListTile(
// //               leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
// //               title: FittedBox(
// //                 alignment: Alignment.centerLeft,
// //                 fit: BoxFit.scaleDown,
// //                 child: Text("SETTINGS_SUPPORT".tr(ref)),
// //               ),
// //               subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref),
// //                   maxLines: 1, overflow: TextOverflow.ellipsis),
// //               trailing: const Icon(Icons.mail_outline, size: 20),
// //               onTap: () async {
// //                 try {
// //                   await SupportService.sendSupportEmail();
// //                 } catch (e) {
// //                   if (context.mounted) {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(content: Text("ERROR_NO_EMAIL_APP".tr(ref))),
// //                     );
// //                   }
// //                 }
// //               },
// //             ),
// //           ]),
// //
// //           const SizedBox(height: 40),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // --- Helper Widgets ---
// //
// //   Widget _buildSectionTitle(String title) {
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
// //       child: FittedBox(
// //         alignment: Alignment.centerLeft,
// //         fit: BoxFit.scaleDown,
// //         child: Text(title,
// //             style: const TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.grey)),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCard(List<Widget> children) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //               color: Colors.black.withOpacity(0.03),
// //               blurRadius: 10,
// //               offset: const Offset(0, 4))
// //         ],
// //       ),
// //       child: Column(children: children),
// //     );
// //   }
// //
// //   // --- Logic Methods ---
// //
// //   void _showLanguageDialog(
// //       BuildContext context, WidgetRef ref, Map<String, String> languages) {
// //     final currentLang = ref.read(localizationProvider.notifier).currentLang;
// //     showModalBottomSheet(
// //       context: context,
// //       shape: const RoundedRectangleBorder(
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// //       builder: (context) => Container(
// //         padding: const EdgeInsets.symmetric(vertical: 20),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text("SETTINGS_SELECT_LANGUAGE".tr(ref),
// //                 style:
// //                 const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             const Divider(),
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: languages.length,
// //                 itemBuilder: (context, index) {
// //                   String key = languages.keys.elementAt(index);
// //                   String value = languages.values.elementAt(index);
// //                   bool isSelected = currentLang == key;
// //                   return ListTile(
// //                     title: Text(
// //                       value,
// //                       style: TextStyle(
// //                         fontWeight:
// //                         isSelected ? FontWeight.bold : FontWeight.normal,
// //                         color: isSelected
// //                             ? const Color(0xFF1A237E)
// //                             : Colors.black,
// //                       ),
// //                     ),
// //                     trailing: isSelected
// //                         ? const Icon(Icons.check, color: Color(0xFF1A237E))
// //                         : null,
// //                     onTap: () async {
// //                       await ref
// //                           .read(localizationProvider.notifier)
// //                           .changeLanguage(key);
// //                       if (context.mounted) Navigator.pop(context);
// //                       if (context.mounted) {
// //                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           SnackBar(
// //                             content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
// //                             behavior: SnackBarBehavior.floating,
// //                           ),
// //                         );
// //                       }
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _pickImage(WidgetRef ref) async {
// //     final picker = ImagePicker();
// //     final XFile? image = await picker.pickImage(
// //         source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
// //     if (image != null)
// //       await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
// //   }
// //
// //   void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
// //     final currentNickname = ref.read(userNicknameProvider).nickname;
// //     final displayNickname =
// //     currentNickname.startsWith('SETTINGS_') ? currentNickname.tr(ref) : currentNickname;
// //
// //     final controller = TextEditingController(text: displayNickname);
// //     showDialog(
// //       context: context,
// //       builder: (context) => StatefulBuilder(
// //         builder: (context, setState) => AlertDialog(
// //           shape:
// //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref),
// //               style: const TextStyle(fontWeight: FontWeight.bold)),
// //           content: TextField(
// //             controller: controller,
// //             autofocus: true,
// //             onChanged: (value) => setState(() {}),
// //             decoration: InputDecoration(
// //               hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
// //               filled: true,
// //               fillColor: Colors.grey[100],
// //               border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                   borderSide: BorderSide.none),
// //               suffixIcon: controller.text.isNotEmpty
// //                   ? GestureDetector(
// //                 onTap: () {
// //                   controller.clear();
// //                   setState(() {});
// //                 },
// //                 child: const Icon(Icons.cancel,
// //                     color: Colors.grey, size: 20),
// //               )
// //                   : null,
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text("COMMON_CANCEL".tr(ref),
// //                   style: const TextStyle(color: Colors.grey)),
// //             ),
// //             ElevatedButton(
// //               style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF1A237E),
// //                   foregroundColor: Colors.white),
// //               onPressed: () async {
// //                 if (controller.text.trim().isNotEmpty) {
// //                   await ref
// //                       .read(userNicknameProvider.notifier)
// //                       .updateNickname(controller.text.trim());
// //                   if (context.mounted) Navigator.pop(context);
// //                 }
// //               },
// //               child: Text("COMMON_SAVE".tr(ref)),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
// //     try {
// //       final dbFolder = await getApplicationDocumentsDirectory();
// //       final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
// //       if (await dbFile.exists()) {
// //         await Share.shareXFiles([XFile(dbFile.path)],
// //             text: 'SiRE App Data Backup');
// //       } else {
// //         if (context.mounted) {
// //           ScaffoldMessenger.of(context)
// //               .showSnackBar(SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref))));
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("Backup Error: $e");
// //     }
// //   }
// //
// //   Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
// //     final result = await FilePicker.platform.pickFiles();
// //     if (result != null && result.files.single.path != null) {
// //       try {
// //         final dbFolder = await getApplicationDocumentsDirectory();
// //         final newDbFile = File(result.files.single.path!);
// //         await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
// //         if (context.mounted) {
// //           showDialog(
// //             context: context,
// //             barrierDismissible: false,
// //             builder: (context) => AlertDialog(
// //               title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
// //               content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
// //               actions: [
// //                 TextButton(
// //                     onPressed: () => Navigator.pop(context),
// //                     child: Text("COMMON_OK".tr(ref)))
// //               ],
// //             ),
// //           );
// //         }
// //       } catch (e) {
// //         if (context.mounted) {
// //           ScaffoldMessenger.of(context)
// //               .showSnackBar(SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref))));
// //         }
// //       }
// //     }
// //   }
// //
// //   Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
// //     return showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
// //         content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
// //         actions: [
// //           TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text("COMMON_CANCEL".tr(ref))),
// //           TextButton(
// //             onPressed: () async {
// //               await ref.read(securityNotifierProvider.notifier).removePin();
// //               if (context.mounted) Navigator.pop(context);
// //             },
// //             child: Text("COMMON_DISABLE".tr(ref),
// //                 style: const TextStyle(color: Colors.red)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ [추가] Pro 안내 다이얼로그
// //   void _showProDialog(BuildContext context, WidgetRef ref, bool isPro) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text(isPro ? 'SiRE Pro' : 'SiRE Pro (잠금)'),
// //         content: Text(
// //           isPro
// //               ? '현재 Pro가 활성화되어 있습니다.\nReports / 분석 / Export 기능을 사용할 수 있습니다.'
// //               : 'Reports / 분석 / Export 기능은 Pro에서 제공됩니다.\n설정 > SiRE Pro에서 구매/복원을 진행할 수 있습니다.',
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('OK'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ✅ [추가] IAP 준비 중 다이얼로그
// //   void _showIapComingSoonDialog(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Pro 결제'),
// //         content:
// //         const Text('스토어 결제 환경이 준비되지 않았습니다. (테스트 기기/계정/스토어 설정 확인 필요)'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('OK'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'dart:io';
// import 'package:drift/drift.dart' hide Column;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:image_picker/image_picker.dart';
//
// import '../../core/localization/localization_provider.dart';
// import '../../core/purchase/models/purchase_status.dart';
// import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 상태/구매/복원용
// import '../security/security_provider.dart';
// import '../security/pin_screen.dart';
// import 'category_management_screen.dart';
// import 'user_provider.dart';
// import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가
//
// // ✅ [변경] SettingsScreen을 ConsumerStatefulWidget으로 변경
// // - build()는 여러 번 호출될 수 있으므로, "Settings 진입 시 verify"는 initState에서 1회만 실행해야 합니다.
// // - 그렇지 않으면 reload()/verify가 build마다 반복 호출되어 UI 깜빡임/오탐 토스트가 발생할 수 있습니다.
// class SettingsScreen extends ConsumerStatefulWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends ConsumerState<SettingsScreen> {
//   // ✅ [추가] Settings 진입 시 verify를 1회만 실행하기 위한 플래그
//   bool _didTriggerVerifyOnEnter = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ✅ [추가] Settings 진입 시 1회 스토어 소유(owned) 재검증 트리거
//     // - build() 안에서 호출하면 재빌드 때마다 반복 실행되어 UI가 깜빡거릴 수 있음
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (!mounted) return;
//       if (_didTriggerVerifyOnEnter) return;
//       _didTriggerVerifyOnEnter = true;
//
//       // ✅ [중요 변경]
//       // - 이전에는 reload()를 호출했는데, reload()는 "로컬 캐시 복원 + verify"를 동시에 수행하면서
//       //   상태가 loading/free/pro로 흔들릴 수 있어 오탐 메시지/깜빡임의 원인이 될 수 있습니다.
//       // - Settings 진입 시에는 "스토어 소유 재검증"만 조용히 1회 수행하는 게 안정적입니다.
//       //
//       // ✅ 따라서, PurchaseController에 추가한 공개 메서드 verifyEntitlementFromStore()를 호출합니다.
//       // - 결과 메시지를 반환하므로, "메시지가 뜨는지만" 테스트도 여기서 가능합니다.
//       final result = await ref
//           .read(purchaseControllerProvider.notifier)
//           .verifyEntitlementFromStore();
//
//       // ✅ [테스트] 메시지가 뜨는지만 확인
//       // - 원하면 이 부분을 나중에 제거하거나, 특정 조건에서만 보이게 할 수 있습니다.
//       if (!mounted) return;
//       final msg = result.message;
//       if (msg != null && msg.isNotEmpty) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(msg),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     });
//
//     // ✅ [추가] purchase state listen을 initState에서 1회만 등록
//     // - build 안에서 listen을 걸면 화면 리빌드 상황에 따라 중복 등록/오동작 가능성이 있습니다.
//     ref.listen<PurchaseState>(purchaseControllerProvider, (prev, next) {
//       // build 컨텍스트가 필요하므로 mounted 체크
//       if (!mounted) return;
//
//       // ------------------------------------------------------------------
//       // ✅ [유지] 기존 에러 메시지 처리
//       // ------------------------------------------------------------------
//       final msg = next.errorMessage;
//       if (msg != null && msg.isNotEmpty) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(msg),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//
//       // ------------------------------------------------------------------
//       // ✅ [개선] 환불/권한 회수로 인한 Pro 해제 안내 (오탐 방지 강화)
//       //
//       // 문제 원인:
//       // - reload()가 loading 상태를 거치거나,
//       // - 스토어/캐시 초기화 직후 일시적으로 상태가 흔들릴 때
//       //   "Pro → Free"처럼 보이는 순간이 생길 수 있음.
//       //
//       // 해결:
//       // - "최종 상태"가 확정된 경우에만 안내
//       // - prev/next 모두 isLoading=false일 때만 띄움
//       // ------------------------------------------------------------------
//       final wasPro = prev?.isPro == true;
//       final isNowFree = next.isPro == false;
//
//       final prevStable = (prev?.isLoading ?? false) == false;
//       final nextStable = next.isLoading == false;
//
//       // ✅ loading 중간 상태에서는 절대 띄우지 않음
//       // if (wasPro && isNowFree && prevStable && nextStable) {
//       //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(
//       //       content: Text("Google Play 환불 또는 구매 취소로 인해 Pro가 비활성화되었습니다."),
//       //       behavior: SnackBarBehavior.floating,
//       //       duration: Duration(seconds: 4),
//       //     ),
//       //   );
//       // }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final hasPin = ref.watch(securityNotifierProvider).value ?? false;
//     final profile = ref.watch(userNicknameProvider);
//
//     // ✅ [추가] Pro 상태 확인
//     final isPro = ref.watch(isProProvider);
//     final purchaseState = ref.watch(purchaseControllerProvider);
//
//     // 지원하는 20개 언어 리스트
//     final Map<String, String> languages = {
//       "ar": "العربية",
//       "bn": "বাংলা",
//       "zh": "中文 (简体)",
//       "nl": "Nederlands",
//       "en": "English",
//       "fr": "Français",
//       "de": "Deutsch",
//       "hi": "हिन्दी",
//       "id": "Bahasa Indonesia",
//       "it": "Italiano",
//       "ja": "日本語",
//       "ko": "한국어",
//       "ms": "Bahasa Melayu",
//       "pl": "Polski",
//       "pt": "Português",
//       "ru": "Русский",
//       "es": "Español",
//       "th": "ไทย",
//       "tr": "Türkçe",
//       "vi": "Tiếng Việt"
//     };
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text("NAV_SETTINGS".tr(ref),
//             style: const TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF1A237E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//
//       // ✅ [개선] purchaseState.errorMessage가 생기면 자동으로 스낵바 표시
//       // - 기존에는 Builder 안에서 listen을 등록했으나,
//       //   rebuild마다 중복 listen 가능성이 있어 initState로 이동했습니다.
//       body: ListView(
//         children: [
//           // --- 1. User Profile Section (사용자 프로필: 최상단 배치) ---
//           _buildSectionTitle("SETTINGS_USER_PROFILE".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading: GestureDetector(
//                 onTap: () => _pickImage(ref),
//                 child: CircleAvatar(
//                   radius: 25,
//                   backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
//                   backgroundImage: profile.imagePath != null
//                       ? FileImage(File(profile.imagePath!))
//                       : null,
//                   child: profile.imagePath == null
//                       ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E))
//                       : null,
//                 ),
//               ),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
//               ),
//               subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () => _pickImage(ref),
//             ),
//             const Divider(height: 1),
//             ListTile(
//               leading:
//               const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
//               ),
//               subtitle: Text(
//                 profile.nickname.startsWith('SETTINGS_')
//                     ? profile.nickname.tr(ref)
//                     : profile.nickname,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               trailing: const Icon(Icons.edit_outlined, size: 20),
//               onTap: () => _showEditNicknameDialog(context, ref),
//             ),
//           ]),
//
//           // --- 2. Security Section (보안: PIN 설정) ---
//           _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading:
//               const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
//               title: FractionallySizedBox(
//                 widthFactor: 0.9,
//                 child: FittedBox(
//                   alignment: Alignment.centerLeft,
//                   fit: BoxFit.scaleDown,
//                   child: Text("SETTINGS_USE_PIN".tr(ref)),
//                 ),
//               ),
//               trailing: Switch(
//                 value: hasPin,
//                 activeColor: const Color(0xFF1A237E),
//                 onChanged: (value) async {
//                   if (value) {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                             const PinScreen(isSetting: true)));
//                   } else {
//                     await _showDeleteConfirmDialog(context, ref);
//                   }
//                 },
//               ),
//             ),
//             if (hasPin) ...[
//               const Divider(height: 1),
//               ListTile(
//                 leading: const Icon(Icons.password, color: Color(0xFF1A237E)),
//                 title: FittedBox(
//                   alignment: Alignment.centerLeft,
//                   fit: BoxFit.scaleDown,
//                   child: Text("SETTINGS_CHANGE_PIN".tr(ref)),
//                 ),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                         const PinScreen(isSetting: true))),
//               ),
//             ],
//           ]),
//
//           // --- ✅ [추가] Pro Section (결제: SiRE Pro 평생 구매) ---
//           _buildSectionTitle("SETTINGS_PRO_SECTION_TITLE".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1A237E)),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref)),
//               ),
//               subtitle: Text(
//                 isPro
//                     ? "SETTINGS_PRO_ALREADY_ACTIVE".tr(ref)
//                     : "SETTINGS_PRO_BUY_LIFETIME_DESC_LOCKED".tr(ref),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               // ✅ Pro면 탭해도 구매 시작 안 하게 막고(또는 안내만)
//               onTap: (purchaseState.isLoading || isPro)
//                   ? () {
//                 if (!context.mounted) return;
//                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("SETTINGS_PRO_ALREADY_ACTIVE".tr(ref)),
//                     behavior: SnackBarBehavior.floating,
//                   ),
//                 );
//               }
//                   : () async {
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                 }
//
//                 await ref.read(purchaseControllerProvider.notifier).purchaseProLifetime();
//
//                 final latest = ref.read(purchaseControllerProvider);
//
//                 if (latest.errorMessage != null && latest.errorMessage!.isNotEmpty) {
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           '${"IAP_PURCHASE_START_FAILED".tr(ref)}: ${latest.errorMessage}',
//                         ),
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   }
//                   return;
//                 }
//
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("IAP_FOLLOW_STORE_INSTRUCTIONS".tr(ref)),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 }
//               },
//             ),
//
//             const Divider(height: 1),
//
//             ListTile(
//               leading: const Icon(Icons.restore, color: Colors.orange),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_PRO_RESTORE_TITLE".tr(ref)),
//               ),
//               subtitle: Text("SETTINGS_PRO_RESTORE_DESC".tr(ref)),
//               onTap: purchaseState.isLoading
//                   ? null
//                   : () async {
//                 await ref
//                     .read(purchaseControllerProvider.notifier)
//                     .restorePurchases();
//
//                 // ✅ [정리]
//                 // - restore 후 reload()는 상태 흔들림을 만들 수 있으니 여기서는 제거합니다.
//                 // - restore 결과는 purchaseStream 이벤트로 반영됩니다.
//                 // - 필요하다면 Settings 진입 verifyEntitlementFromStore()가 추가 안전망 역할을 합니다.
//
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("SETTINGS_PRO_RESTORE_REQUEST_SENT".tr(ref)),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 }
//               },
//             ),
//
//             // ---------------------------------------------------------------------
//             // ✅ [개발자 토글] 유지 방식 (요청 반영)
//             //
//             // 너가 요청한대로 "삭제"하지 않고, 아래처럼 "주석으로 보관"해둡니다.
//             // 나중에 개발/디버깅이 필요할 때 주석을 해제하여 다시 사용할 수 있습니다.
//             //
//             // 권장 운영 방식:
//             // 1) 디버그 빌드에서만 노출하도록 if (kDebugMode)로 감싸서 사용
//             // 2) 스토어 배포(릴리즈) 직전에는 반드시 숨김/삭제
//             //
//             // 현재는 안전하게 "완전 비활성(주석)" 상태로 두었습니다.
//             // ---------------------------------------------------------------------
//
//             /*
//             const Divider(height: 1),
//             SwitchListTile(
//               secondary: const Icon(Icons.build_outlined, color: Colors.teal),
//               title: const Text("개발용: Pro 상태 토글"),
//               subtitle: const Text("테스트 편의를 위한 임시 기능입니다. 배포 전 제거 권장"),
//               value: isPro,
//               onChanged: (value) async {
//                 await ref.read(purchaseControllerProvider.notifier).setPro(value);
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(value ? "Pro가 활성화되었습니다." : "Pro가 비활성화되었습니다."),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 }
//               },
//             ),
//             */
//           ]),
//
//           // --- 3. Language Section (언어 설정: 다국어) ---
//           _buildSectionTitle("SETTINGS_LANGUAGE_SECTION".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading: const Icon(Icons.language, color: Color(0xFF1A237E)),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_SELECT_LANGUAGE".tr(ref)),
//               ),
//               subtitle: Text(
//                   languages[ref.read(localizationProvider.notifier).currentLang] ??
//                       ""),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () => _showLanguageDialog(context, ref, languages),
//             ),
//           ]),
//
//           // --- 4. Customization Section (맞춤 설정: 카테고리 관리) ---
//           _buildSectionTitle("SETTINGS_CUSTOMIZATION".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading: const Icon(Icons.category_outlined, color: Colors.teal),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_MANAGE_CATEGORIES".tr(ref)),
//               ),
//               subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                         const CategoryManagementScreen()));
//               },
//             ),
//           ]),
//
//           // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
//           _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_BACKUP".tr(ref)),
//               ),
//               subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               onTap: () => _handleBackup(context, ref),
//             ),
//             const Divider(height: 1),
//             ListTile(
//               leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_RESTORE".tr(ref)),
//               ),
//               subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               onTap: () => _handleRestore(context, ref),
//             ),
//           ]),
//
//           // --- 6. App Support Section (지원: 문의 및 환불 정책) ---
//           _buildSectionTitle("SETTINGS_SUPPORT_SECTION".tr(ref)),
//           _buildCard([
//             ListTile(
//               leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
//               title: FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Text("SETTINGS_SUPPORT".tr(ref)),
//               ),
//               subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref),
//                   maxLines: 1, overflow: TextOverflow.ellipsis),
//               trailing: const Icon(Icons.mail_outline, size: 20),
//               onTap: () async {
//                 try {
//                   await SupportService.sendSupportEmail();
//                 } catch (e) {
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("ERROR_NO_EMAIL_APP".tr(ref))),
//                     );
//                   }
//                 }
//               },
//             ),
//           ]),
//
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
//
//   // --- Helper Widgets ---
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//       child: FittedBox(
//         alignment: Alignment.centerLeft,
//         fit: BoxFit.scaleDown,
//         child: Text(title,
//             style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey)),
//       ),
//     );
//   }
//
//   Widget _buildCard(List<Widget> children) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }
//
//   // --- Logic Methods ---
//
//   void _showLanguageDialog(
//       BuildContext context, WidgetRef ref, Map<String, String> languages) {
//     final currentLang = ref.read(localizationProvider.notifier).currentLang;
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => Container(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("SETTINGS_SELECT_LANGUAGE".tr(ref),
//                 style:
//                 const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const Divider(),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: languages.length,
//                 itemBuilder: (context, index) {
//                   String key = languages.keys.elementAt(index);
//                   String value = languages.values.elementAt(index);
//                   bool isSelected = currentLang == key;
//                   return ListTile(
//                     title: Text(
//                       value,
//                       style: TextStyle(
//                         fontWeight:
//                         isSelected ? FontWeight.bold : FontWeight.normal,
//                         color: isSelected
//                             ? const Color(0xFF1A237E)
//                             : Colors.black,
//                       ),
//                     ),
//                     trailing: isSelected
//                         ? const Icon(Icons.check, color: Color(0xFF1A237E))
//                         : null,
//                     onTap: () async {
//                       await ref
//                           .read(localizationProvider.notifier)
//                           .changeLanguage(key);
//                       if (context.mounted) Navigator.pop(context);
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickImage(WidgetRef ref) async {
//     final picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
//     if (image != null)
//       await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
//   }
//
//   void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
//     final currentNickname = ref.read(userNicknameProvider).nickname;
//     final displayNickname =
//     currentNickname.startsWith('SETTINGS_') ? currentNickname.tr(ref) : currentNickname;
//
//     final controller = TextEditingController(text: displayNickname);
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref),
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//           content: TextField(
//             controller: controller,
//             autofocus: true,
//             onChanged: (value) => setState(() {}),
//             decoration: InputDecoration(
//               hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
//               filled: true,
//               fillColor: Colors.grey[100],
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none),
//               suffixIcon: controller.text.isNotEmpty
//                   ? GestureDetector(
//                 onTap: () {
//                   controller.clear();
//                   setState(() {});
//                 },
//                 child: const Icon(Icons.cancel,
//                     color: Colors.grey, size: 20),
//               )
//                   : null,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("COMMON_CANCEL".tr(ref),
//                   style: const TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1A237E),
//                   foregroundColor: Colors.white),
//               onPressed: () async {
//                 if (controller.text.trim().isNotEmpty) {
//                   await ref
//                       .read(userNicknameProvider.notifier)
//                       .updateNickname(controller.text.trim());
//                   if (context.mounted) Navigator.pop(context);
//                 }
//               },
//               child: Text("COMMON_SAVE".tr(ref)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
//     try {
//       final dbFolder = await getApplicationDocumentsDirectory();
//       final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
//       if (await dbFile.exists()) {
//         await Share.shareXFiles([XFile(dbFile.path)],
//             text: 'SiRE App Data Backup');
//       } else {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref))));
//         }
//       }
//     } catch (e) {
//       debugPrint("Backup Error: $e");
//     }
//   }
//
//   Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null && result.files.single.path != null) {
//       try {
//         final dbFolder = await getApplicationDocumentsDirectory();
//         final newDbFile = File(result.files.single.path!);
//         await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
//         if (context.mounted) {
//           showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (context) => AlertDialog(
//               title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
//               content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
//               actions: [
//                 TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("COMMON_OK".tr(ref)))
//               ],
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref))));
//         }
//       }
//     }
//   }
//
//   Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
//         content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("COMMON_CANCEL".tr(ref))),
//           TextButton(
//             onPressed: () async {
//               await ref.read(securityNotifierProvider.notifier).removePin();
//               if (context.mounted) Navigator.pop(context);
//             },
//             child: Text("COMMON_DISABLE".tr(ref),
//                 style: const TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ [추가] Pro 안내 다이얼로그
//   void _showProDialog(BuildContext context, WidgetRef ref, bool isPro) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           isPro
//               ? "DIALOG_PRO_TITLE_UNLOCKED".tr(ref)
//               : "DIALOG_PRO_TITLE_LOCKED".tr(ref),
//         ),
//         content: Text(
//           isPro
//               ? "DIALOG_PRO_CONTENT_UNLOCKED".tr(ref)
//               : "DIALOG_PRO_CONTENT_LOCKED".tr(ref),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("COMMON_OK".tr(ref)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ [추가] IAP 준비 중 다이얼로그
//   void _showIapComingSoonDialog(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("DIALOG_IAP_COMING_SOON_TITLE".tr(ref)),
//         content: Text("DIALOG_IAP_COMING_SOON_CONTENT".tr(ref)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("COMMON_OK".tr(ref)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//

import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';

import '../../core/localization/localization_provider.dart';
import '../../core/purchase/models/purchase_status.dart';
import '../../core/purchase/state/purchase_provider.dart'; // ✅ [추가] Pro 상태/구매/복원용
import '../security/security_provider.dart';
import '../security/pin_screen.dart';
import 'category_management_screen.dart';
import 'user_provider.dart';
import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가

// ✅ [변경] SettingsScreen을 ConsumerStatefulWidget으로 변경
// - build()는 여러 번 호출될 수 있으므로, "Settings 진입 시 verify"는 initState에서 1회만 실행해야 합니다.
// - 그렇지 않으면 reload()/verify가 build마다 반복 호출되어 UI 깜빡임/오탐 토스트가 발생할 수 있습니다.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ✅ [추가] Settings 진입 시 verify를 1회만 실행하기 위한 플래그
  bool _didTriggerVerifyOnEnter = false;

  // ✅✅ [핵심 수정] initState에서 ref.listen()은 금지 → listenManual 구독을 저장
  ProviderSubscription<PurchaseState>? _purchaseSub;

  @override
  void initState() {
    super.initState();

    // ✅ [추가] Settings 진입 시 1회 스토어 소유(owned) 재검증 트리거
    // - build() 안에서 호출하면 재빌드 때마다 반복 실행되어 UI가 깜빡거릴 수 있음
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_didTriggerVerifyOnEnter) return;
      _didTriggerVerifyOnEnter = true;

      // ✅ [중요 변경]
      // - 이전에는 reload()를 호출했는데, reload()는 "로컬 캐시 복원 + verify"를 동시에 수행하면서
      //   상태가 loading/free/pro로 흔들릴 수 있어 오탐 메시지/깜빡임의 원인이 될 수 있습니다.
      // - Settings 진입 시에는 "스토어 소유 재검증"만 조용히 1회 수행하는 게 안정적입니다.
      //
      // ✅ 따라서, PurchaseController에 추가한 공개 메서드 verifyEntitlementFromStore()를 호출합니다.
      // - 결과 메시지를 반환하므로, "메시지가 뜨는지만" 테스트도 여기서 가능합니다.
      final result = await ref
          .read(purchaseControllerProvider.notifier)
          .verifyEntitlementFromStore();

      // ✅ [테스트] 메시지가 뜨는지만 확인
      // - 원하면 이 부분을 나중에 제거하거나, 특정 조건에서만 보이게 할 수 있습니다.
      if (!mounted) return;
      final msg = result.message;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // ✅✅ [핵심 수정] purchase state listen을 initState에서 1회만 등록
    // - build 안에서 listen을 걸면 화면 리빌드 상황에 따라 중복 등록/오동작 가능성이 있습니다.
    // - 단, ConsumerState의 initState에서는 ref.listen()이 금지 → ref.listenManual() 사용
    _purchaseSub = ref.listenManual<PurchaseState>(
      purchaseControllerProvider,
          (prev, next) {
        // build 컨텍스트가 필요하므로 mounted 체크
        if (!mounted) return;

        // ------------------------------------------------------------------
        // ✅ [유지] 기존 에러 메시지 처리
        // ------------------------------------------------------------------
        final msg = next.errorMessage;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // ------------------------------------------------------------------
        // ✅ [개선] 환불/권한 회수로 인한 Pro 해제 안내 (오탐 방지 강화)
        //
        // 문제 원인:
        // - reload()가 loading 상태를 거치거나,
        // - 스토어/캐시 초기화 직후 일시적으로 상태가 흔들릴 때
        //   "Pro → Free"처럼 보이는 순간이 생길 수 있음.
        //
        // 해결:
        // - "최종 상태"가 확정된 경우에만 안내
        // - prev/next 모두 isLoading=false일 때만 띄움
        // ------------------------------------------------------------------
        final wasPro = prev?.isPro == true;
        final isNowFree = next.isPro == false;

        final prevStable = (prev?.isLoading ?? false) == false;
        final nextStable = next.isLoading == false;

        // ✅ loading 중간 상태에서는 절대 띄우지 않음
        // if (wasPro && isNowFree && prevStable && nextStable) {
        //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Google Play 환불 또는 구매 취소로 인해 Pro가 비활성화되었습니다."),
        //       behavior: SnackBarBehavior.floating,
        //       duration: Duration(seconds: 4),
        //     ),
        //   );
        // }
      },
    );
  }

  @override
  void dispose() {
    // ✅✅ [필수] listenManual 구독 해제
    _purchaseSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPin = ref.watch(securityNotifierProvider).value ?? false;
    final profile = ref.watch(userNicknameProvider);

    // ✅ [추가] Pro 상태 확인
    final isPro = ref.watch(isProProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);

    // 지원하는 20개 언어 리스트
    final Map<String, String> languages = {
      "ar": "العربية",
      "bn": "বাংলা",
      "zh": "中文 (简体)",
      "nl": "Nederlands",
      "en": "English",
      "fr": "Français",
      "de": "Deutsch",
      "hi": "हिन्दी",
      "id": "Bahasa Indonesia",
      "it": "Italiano",
      "ja": "日本語",
      "ko": "한국어",
      "ms": "Bahasa Melayu",
      "pl": "Polski",
      "pt": "Português",
      "ru": "Русский",
      "es": "Español",
      "th": "ไทย",
      "tr": "Türkçe",
      "vi": "Tiếng Việt"
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("NAV_SETTINGS".tr(ref),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ✅ [개선] purchaseState.errorMessage가 생기면 자동으로 스낵바 표시
      // - 기존에는 Builder 안에서 listen을 등록했으나,
      //   rebuild마다 중복 listen 가능성이 있어 initState로 이동했습니다.
      body: ListView(
        children: [
          // --- 1. User Profile Section (사용자 프로필: 최상단 배치) ---
          _buildSectionTitle("SETTINGS_USER_PROFILE".tr(ref)),
          _buildCard([
            ListTile(
              leading: GestureDetector(
                onTap: () => _pickImage(ref),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
                  backgroundImage: profile.imagePath != null
                      ? FileImage(File(profile.imagePath!))
                      : null,
                  child: profile.imagePath == null
                      ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E))
                      : null,
                ),
              ),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
              ),
              subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickImage(ref),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
              const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
              ),
              subtitle: Text(
                profile.nickname.startsWith('SETTINGS_')
                    ? profile.nickname.tr(ref)
                    : profile.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _showEditNicknameDialog(context, ref),
            ),
          ]),

          // --- 2. Security Section (보안: PIN 설정) ---
          _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
          _buildCard([
            ListTile(
              leading:
              const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
              title: FractionallySizedBox(
                widthFactor: 0.9,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text("SETTINGS_USE_PIN".tr(ref)),
                ),
              ),
              trailing: Switch(
                value: hasPin,
                activeColor: const Color(0xFF1A237E),
                onChanged: (value) async {
                  if (value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const PinScreen(isSetting: true)));
                  } else {
                    await _showDeleteConfirmDialog(context, ref);
                  }
                },
              ),
            ),
            if (hasPin) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.password, color: Color(0xFF1A237E)),
                title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text("SETTINGS_CHANGE_PIN".tr(ref)),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const PinScreen(isSetting: true))),
              ),
            ],
          ]),

          // --- ✅ [추가] Pro Section (결제: SiRE Pro 평생 구매) ---
          _buildSectionTitle("SETTINGS_PRO_SECTION_TITLE".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined,
                  color: Color(0xFF1A237E)),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_PRO_BUY_LIFETIME_TITLE".tr(ref)),
              ),
              subtitle: Text(
                isPro
                    ? "SETTINGS_PRO_ALREADY_ACTIVE".tr(ref)
                    : "SETTINGS_PRO_BUY_LIFETIME_DESC_LOCKED".tr(ref),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // ✅ Pro면 탭해도 구매 시작 안 하게 막고(또는 안내만)
              onTap: (purchaseState.isLoading || isPro)
                  ? () {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("SETTINGS_PRO_ALREADY_ACTIVE".tr(ref)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
                  : () async {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }

                await ref
                    .read(purchaseControllerProvider.notifier)
                    .purchaseProLifetime();

                final latest = ref.read(purchaseControllerProvider);

                if (latest.errorMessage != null &&
                    latest.errorMessage!.isNotEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${"IAP_PURCHASE_START_FAILED".tr(ref)}: ${latest.errorMessage}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  return;
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("IAP_FOLLOW_STORE_INSTRUCTIONS".tr(ref)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),

            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.restore, color: Colors.orange),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_PRO_RESTORE_TITLE".tr(ref)),
              ),
              subtitle: Text("SETTINGS_PRO_RESTORE_DESC".tr(ref)),
              onTap: purchaseState.isLoading
                  ? null
                  : () async {
                await ref
                    .read(purchaseControllerProvider.notifier)
                    .restorePurchases();

                // ✅ [정리]
                // - restore 후 reload()는 상태 흔들림을 만들 수 있으니 여기서는 제거합니다.
                // - restore 결과는 purchaseStream 이벤트로 반영됩니다.
                // - 필요하다면 Settings 진입 verifyEntitlementFromStore()가 추가 안전망 역할을 합니다.

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("SETTINGS_PRO_RESTORE_REQUEST_SENT".tr(ref)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),

            // ---------------------------------------------------------------------
            // ✅ [개발자 토글] 유지 방식 (요청 반영)
            //
            // 너가 요청한대로 "삭제"하지 않고, 아래처럼 "주석으로 보관"해둡니다.
            // 나중에 개발/디버깅이 필요할 때 주석을 해제하여 다시 사용할 수 있습니다.
            //
            // 권장 운영 방식:
            // 1) 디버그 빌드에서만 노출하도록 if (kDebugMode)로 감싸서 사용
            // 2) 스토어 배포(릴리즈) 직전에는 반드시 숨김/삭제
            //
            // 현재는 안전하게 "완전 비활성(주석)" 상태로 두었습니다.
            // ---------------------------------------------------------------------

            /*
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.build_outlined, color: Colors.teal),
              title: const Text("개발용: Pro 상태 토글"),
              subtitle: const Text("테스트 편의를 위한 임시 기능입니다. 배포 전 제거 권장"),
              value: isPro,
              onChanged: (value) async {
                await ref.read(purchaseControllerProvider.notifier).setPro(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? "Pro가 활성화되었습니다." : "Pro가 비활성화되었습니다."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            */
          ]),

          // --- 3. Language Section (언어 설정: 다국어) ---
          _buildSectionTitle("SETTINGS_LANGUAGE_SECTION".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.language, color: Color(0xFF1A237E)),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_SELECT_LANGUAGE".tr(ref)),
              ),
              subtitle: Text(languages[
              ref.read(localizationProvider.notifier).currentLang] ??
                  ""),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, ref, languages),
            ),
          ]),

          // --- 4. Customization Section (맞춤 설정: 카테고리 관리) ---
          _buildSectionTitle("SETTINGS_CUSTOMIZATION".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.category_outlined, color: Colors.teal),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_MANAGE_CATEGORIES".tr(ref)),
              ),
              subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const CategoryManagementScreen()));
              },
            ),
          ]),

          // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
          _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined,
                  color: Colors.blue),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_BACKUP".tr(ref)),
              ),
              subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _handleBackup(context, ref),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore,
                  color: Colors.orange),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_RESTORE".tr(ref)),
              ),
              subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _handleRestore(context, ref),
            ),
          ]),

          // --- 6. App Support Section (지원: 문의 및 환불 정책) ---
          _buildSectionTitle("SETTINGS_SUPPORT_SECTION".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_SUPPORT".tr(ref)),
              ),
              subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.mail_outline, size: 20),
              onTap: () async {
                try {
                  await SupportService.sendSupportEmail();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("ERROR_NO_EMAIL_APP".tr(ref))),
                    );
                  }
                }
              },
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  // --- Logic Methods ---

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, Map<String, String> languages) {
    final currentLang = ref.read(localizationProvider.notifier).currentLang;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("SETTINGS_SELECT_LANGUAGE".tr(ref),
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  String key = languages.keys.elementAt(index);
                  String value = languages.values.elementAt(index);
                  bool isSelected = currentLang == key;
                  return ListTile(
                    title: Text(
                      value,
                      style: TextStyle(
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF1A237E)
                            : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF1A237E))
                        : null,
                    onTap: () async {
                      await ref
                          .read(localizationProvider.notifier)
                          .changeLanguage(key);
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
    if (image != null) {
      await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
    }
  }

  void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
    final currentNickname = ref.read(userNicknameProvider).nickname;
    final displayNickname = currentNickname.startsWith('SETTINGS_')
        ? currentNickname.tr(ref)
        : currentNickname;

    final controller = TextEditingController(text: displayNickname);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              suffixIcon: controller.text.isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  controller.clear();
                  setState(() {});
                },
                child:
                const Icon(Icons.cancel, color: Colors.grey, size: 20),
              )
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("COMMON_CANCEL".tr(ref),
                  style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white),
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await ref
                      .read(userNicknameProvider.notifier)
                      .updateNickname(controller.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text("COMMON_SAVE".tr(ref)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
      if (await dbFile.exists()) {
        await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref))));
        }
      }
    } catch (e) {
      debugPrint("Backup Error: $e");
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      try {
        final dbFolder = await getApplicationDocumentsDirectory();
        final newDbFile = File(result.files.single.path!);
        await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
              content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("COMMON_OK".tr(ref)))
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref))));
        }
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
        content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("COMMON_CANCEL".tr(ref))),
          TextButton(
            onPressed: () async {
              await ref.read(securityNotifierProvider.notifier).removePin();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text("COMMON_DISABLE".tr(ref),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ [추가] Pro 안내 다이얼로그
  void _showProDialog(BuildContext context, WidgetRef ref, bool isPro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPro
              ? "DIALOG_PRO_TITLE_UNLOCKED".tr(ref)
              : "DIALOG_PRO_TITLE_LOCKED".tr(ref),
        ),
        content: Text(
          isPro
              ? "DIALOG_PRO_CONTENT_UNLOCKED".tr(ref)
              : "DIALOG_PRO_CONTENT_LOCKED".tr(ref),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("COMMON_OK".tr(ref)),
          ),
        ],
      ),
    );
  }

  // ✅ [추가] IAP 준비 중 다이얼로그
  void _showIapComingSoonDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("DIALOG_IAP_COMING_SOON_TITLE".tr(ref)),
        content: Text("DIALOG_IAP_COMING_SOON_CONTENT".tr(ref)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("COMMON_OK".tr(ref)),
          ),
        ],
      ),
    );
  }
}
