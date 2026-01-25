import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트
import 'category_provider.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("CAT_MANAGE_TITLE".tr(ref)), // 📍 다국어: "Manage Categories"
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            // 📍 핵심 수정: 기존 'INCOME'과 새 'INC'를 모두 '수입'으로 판단
            final bool isIncome = category.type == 'INC' || category.type == 'INCOME';

            return ListTile(
              leading: Icon(
                isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: isIncome ? Colors.green : Colors.red,
              ),
              title: Text(
                // 📍 시스템 기본 카테고리는 번역 처리, 사용자 추가 카테고리는 그대로 표시
                  category.name.startsWith('CAT_') ? category.name.tr(ref) : category.name
              ),
              subtitle: Text(
                  isIncome ? "COMMON_INCOME".tr(ref) : "COMMON_EXPENSE".tr(ref)
              ), // 현재 저장된 실제 값을 보여줌
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _showDeleteConfirmDialog(context, ref, category.id),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("${"COMMON_ERROR".tr(ref)}: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A237E),
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 📍 카테고리 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("CAT_DELETE_CONFIRM".tr(ref)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
          TextButton(
            onPressed: () {
              ref.read(categoryListProvider.notifier).deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: Text("COMMON_DELETE".tr(ref), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedType = 'EXP'; // 초기값 지출(EXP)

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("CAT_ADD_NEW".tr(ref)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "CAT_NAME_LABEL".tr(ref),
                  hintText: "CAT_NAME_HINT".tr(ref),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'INC', child: Text("COMMON_INCOME".tr(ref))),
                  DropdownMenuItem(value: 'EXP', child: Text("COMMON_EXPENSE".tr(ref))),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("COMMON_CANCEL".tr(ref))),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(categoryListProvider.notifier).addCategory(nameController.text, selectedType);
                  Navigator.pop(context);
                }
              },
              // 📍 수정 반영: 버튼 텍스트에 .tr(ref) 적용하여 키 노출 문제 해결
              child: Text("COMMON_ADD".tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}