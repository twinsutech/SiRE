import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_provider.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
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
              title: Text(category.name),
              subtitle: Text(category.type), // 현재 저장된 실제 값을 보여줌
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => ref.read(categoryListProvider.notifier).deleteCategory(category.id),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A237E),
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
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
          title: const Text("Add Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Category Name",
                  hintText: "e.g. 보험료, 관리비",
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'INC', child: Text("Income (수입)")),
                  DropdownMenuItem(value: 'EXP', child: Text("Expense (지출)")),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(categoryListProvider.notifier).addCategory(nameController.text, selectedType);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}