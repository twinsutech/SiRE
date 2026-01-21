import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart'; // 📍 추가 필요

import '../security/security_provider.dart';
import '../security/pin_screen.dart';
import 'category_management_screen.dart';
import 'user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPin = ref.watch(securityNotifierProvider).value ?? false;
    // 📍 UserNickname 프로바이더가 이제 UserProfileData 객체를 반환합니다.
    final profile = ref.watch(userNicknameProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // --- User Profile Section ---
          _buildSectionTitle("User Profile"),
          _buildCard([
            // 📍 프로필 이미지 설정 ListTile
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
              title: const Text("Profile Image"),
              subtitle: const Text("Tap to change photo"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickImage(ref),
            ),
            const Divider(height: 1),
            // 닉네임 설정 ListTile
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF1A237E)),
              title: const Text("Landlord Nickname"),
              subtitle: Text(profile.nickname), // 📍 profile.nickname으로 수정
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _showEditNicknameDialog(context, ref),
            ),
          ]),

          // --- Security Section ---
          _buildSectionTitle("Security"),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xFF1A237E)),
              title: const Text("Use PIN Lock"),
              trailing: Switch(
                value: hasPin,
                activeColor: const Color(0xFF1A237E),
                onChanged: (value) async {
                  if (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true)),
                    );
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
                title: const Text("Change PIN"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PinScreen(isSetting: true)),
                  );
                },
              ),
            ],
          ]),

          // --- Data Management Section ---
          _buildSectionTitle("Data Management"),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
              title: const Text("Backup Data"),
              subtitle: const Text("Export database to cloud or email"),
              onTap: () => _handleBackup(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
              title: const Text("Restore Data"),
              subtitle: const Text("Restore from .sqlite backup file"),
              onTap: () => _handleRestore(context),
            ),
          ]),

          // --- Customization Section ---
          _buildSectionTitle("Customization"),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.category_outlined, color: Colors.teal),
              title: const Text("Manage Categories"),
              subtitle: const Text("Add or edit income/expense categories"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
                );
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
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  // --- Logic Methods ---

  // 📍 이미지 선택 로직
  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500, // 최적화를 위해 사이즈 제한
      imageQuality: 80,
    );

    if (image != null) {
      await ref.read(userNicknameProvider.notifier).updateImagePath(image.path);
    }
  }

  // 📍 닉네임 변경 다이얼로그 (X 버튼 포함)
  void _showEditNicknameDialog(BuildContext context, WidgetRef ref) {
    // 📍 .nickname으로 접근
    final controller = TextEditingController(text: ref.read(userNicknameProvider).nickname);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("닉네임 변경", style: TextStyle(fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              autofocus: true,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: "새로운 닉네임을 입력하세요",
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    setState(() {});
                  },
                  child: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  await ref.read(userNicknameProvider.notifier).updateNickname(value.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("취소", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    await ref.read(userNicknameProvider.notifier).updateNickname(controller.text.trim());
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("저장"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ... (Backup, Restore, DeleteConfirm 로직은 기존과 동일하게 유지)
  Future<void> _handleBackup(BuildContext context) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'sire.sqlite'));

      if (await dbFile.exists()) {
        await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Database file not found.")));
        }
      }
    } catch (e) {
      debugPrint("Backup Error: $e");
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
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
              title: const Text("Restore Success"),
              content: const Text("Data has been restored. Please restart the app to apply changes."),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
              ],
            ),
          );
        }
      } catch (e) {
        debugPrint("Restore Error: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to restore data.")));
        }
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Disable PIN"),
        content: const Text("Are you sure you want to disable the security lock?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await ref.read(securityNotifierProvider.notifier).removePin();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Disable", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}