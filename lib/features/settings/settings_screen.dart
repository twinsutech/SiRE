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
import '../security/security_provider.dart';
import '../security/pin_screen.dart';
import 'category_management_screen.dart';
import 'user_provider.dart';
import 'support_service.dart'; // 📍 유료 앱 문의 및 환불 서비스를 위해 추가

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPin = ref.watch(securityNotifierProvider).value ?? false;
    final profile = ref.watch(userNicknameProvider);

    // 지원하는 20개 언어 리스트
    final Map<String, String> languages = {
      "ar": "العربية", "bn": "বাংলা", "zh": "中文 (简体)", "nl": "Nederlands",
      "en": "English", "fr": "Français", "de": "Deutsch", "hi": "हिन्दी",
      "id": "Bahasa Indonesia", "it": "Italiano", "ja": "日本語", "ko": "한국어",
      "ms": "Bahasa Melayu", "pl": "Polski", "pt": "Português", "ru": "Русский",
      "es": "Español", "th": "ไทย", "tr": "Türkçe", "vi": "Tiếng Việt"
    };

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("NAV_SETTINGS".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                  backgroundImage: profile.imagePath != null ? FileImage(File(profile.imagePath!)) : null,
                  child: profile.imagePath == null ? const Icon(Icons.camera_alt, color: Color(0xFF1A237E)) : null,
                ),
              ),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_PROFILE_IMAGE".tr(ref)),
              ),
              subtitle: Text("SETTINGS_CHANGE_PHOTO_HINT".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickImage(ref),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_LANDLORD_NICKNAME".tr(ref)),
              ),
              subtitle: Text(
                  profile.nickname.startsWith('SETTINGS_') ? profile.nickname.tr(ref) : profile.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _showEditNicknameDialog(context, ref),
            ),
          ]),

          // --- 2. Security Section (보안: PIN 설정) ---
          _buildSectionTitle("SETTINGS_SECURITY".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true)));
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
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true))),
              ),
            ],
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
              subtitle: Text(languages[ref.read(localizationProvider.notifier).currentLang] ?? ""),
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
              subtitle: Text("SETTINGS_CATEGORIES_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementScreen()));
              },
            ),
          ]),

          // --- 5. Data Management Section (데이터 관리: 백업 및 복구) ---
          _buildSectionTitle("SETTINGS_DATA_MANAGEMENT".tr(ref)),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_BACKUP".tr(ref)),
              ),
              subtitle: Text("SETTINGS_BACKUP_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => _handleBackup(context, ref),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
              title: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("SETTINGS_RESTORE".tr(ref)),
              ),
              subtitle: Text("SETTINGS_RESTORE_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
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
              subtitle: Text("SETTINGS_SUPPORT_DESC".tr(ref), maxLines: 1, overflow: TextOverflow.ellipsis),
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
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  // --- Logic Methods ---

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Map<String, String> languages) {
    final currentLang = ref.read(localizationProvider.notifier).currentLang;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("SETTINGS_SELECT_LANGUAGE".tr(ref), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  String key = languages.keys.elementAt(index);
                  String value = languages.values.elementAt(index);
                  bool isSelected = currentLang == key;
                  return ListTile(
                    title: Text(value, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF1A237E) : Colors.black)),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1A237E)) : null,
                    onTap: () async {
                      await ref.read(localizationProvider.notifier).changeLanguage(key);
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("SETTINGS_LANGUAGE_CHANGED".tr(ref)),
                              behavior: SnackBarBehavior.floating,
                            )
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);
    if (image != null) await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
  }

  void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
    final currentNickname = ref.read(userNicknameProvider).nickname;
    final displayNickname = currentNickname.startsWith('SETTINGS_') ? currentNickname.tr(ref) : currentNickname;

    final controller = TextEditingController(text: displayNickname);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("SETTINGS_EDIT_NICKNAME_TITLE".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: "SETTINGS_EDIT_NICKNAME_HINT".tr(ref),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixIcon: controller.text.isNotEmpty ? GestureDetector(onTap: () { controller.clear(); setState(() {}); }, child: const Icon(Icons.cancel, color: Colors.grey, size: 20)) : null,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref), style: const TextStyle(color: Colors.grey))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white), onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.read(userNicknameProvider.notifier).updateNickname(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            }, child: Text("COMMON_SAVE".tr(ref))),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));
      if (await dbFile.exists()) { await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup'); }
      else { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_DB_NOT_FOUND".tr(ref)))); }
    } catch (e) { debugPrint("Backup Error: $e"); }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      try {
        final dbFolder = await getApplicationDocumentsDirectory();
        final newDbFile = File(result.files.single.path!);
        await newDbFile.copy(p.join(dbFolder.path, 'sire.sqlite'));
        if (context.mounted) {
          showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
            title: Text("RESTORE_SUCCESS_TITLE".tr(ref)),
            content: Text("RESTORE_SUCCESS_DESC".tr(ref)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_OK".tr(ref)))],
          ));
        }
      } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR_RESTORE_FAILED".tr(ref)))); }
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("SECURITY_DISABLE_PIN_TITLE".tr(ref)),
      content: Text("SECURITY_DISABLE_PIN_DESC".tr(ref)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
        TextButton(onPressed: () async { await ref.read(securityNotifierProvider.notifier).removePin(); if (context.mounted) Navigator.pop(context); }, child: Text("COMMON_DISABLE".tr(ref), style: const TextStyle(color: Colors.red))),
      ],
    ));
  }
}