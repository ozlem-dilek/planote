import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../common_widgets/add_category_dialog.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final newCategoryAdded = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const AddCategoryDialog();
      },
    );

    if (newCategoryAdded == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni kategori başarıyla eklendi!')),
      );
    }
  }

  Future<void> _showEditCategoryDialog(BuildContext context, CategoryModel categoryToEdit) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController(text: categoryToEdit.name);
    Color selectedColor = Color(categoryToEdit.colorValue);

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (stfContext, stfSetState) {
              return AlertDialog(
                title: const Text('Kategoriyi Düzenle'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Kategori Adı'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen bir kategori adı girin.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Renk Seçin:'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: AppColors.defaultCategoryColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              stfSetState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? Theme.of(context).primaryColorDark
                                      : Colors.grey.shade300,
                                  width: selectedColor == color ? 3.0 : 1.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('İptal'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  ElevatedButton(
                    child: const Text('Güncelle'),
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final updatedCategory = CategoryModel(
                          id: categoryToEdit.id,
                          name: nameController.text,
                          colorValue: selectedColor.value,
                        );
                        categoryProvider.updateCategory(updatedCategory).then((_){
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                        });
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori başarıyla güncellendi!')),
      );
    }
  }

  Future<void> _confirmDeleteCategory(BuildContext context, CategoryModel categoryToDelete) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final result = await categoryProvider.attemptDeleteCategory(categoryToDelete.id);

    if (!context.mounted) return;

    if (result['deleted'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${categoryToDelete.name}" kategorisi silindi.')),
      );
    } else {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Kategoriyi Sil'),
            content: Text(result['message'] ?? 'Bu kategoride ${result['taskCount']} görev var. Silmek istediğinize emin misiniz? İlişkili görevler "Diğer" kategorisine taşınacak.'),
            actions: <Widget>[
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Sil'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmed == true && context.mounted) {
        await categoryProvider.deleteCategoryConfirmed(categoryToDelete.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${categoryToDelete.name}" kategorisi ve ilişkili görevler güncellendi/silindi.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Kategorileri Yönet', style: TextStyle(color: AppColors.primaryText)),
        backgroundColor: AppColors.screenBackground,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Yeni Kategori Ekle',
            onPressed: () => _showAddCategoryDialog(context),
          )
        ],
      ),
      body: Builder(
          builder: (context) {
            if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (categoryProvider.error != null) {
              return Center(child: Text("Hata: ${categoryProvider.error}", style: const TextStyle(color: AppColors.error)));
            }
            if (categoryProvider.categories.isEmpty) {
              return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Henüz hiç kategori eklenmemiş.\nSağ üstteki '+' ikonuna basarak yeni bir kategori ekleyebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondaryText),
                    ),
                  )
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: Color(category.colorValue),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black.withOpacity(0.1))
                      ),
                    ),
                    title: Text(category.name, style: Theme.of(context).textTheme.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: AppColors.secondaryText.withOpacity(0.8)),
                          tooltip: 'Düzenle',
                          onPressed: () => _showEditCategoryDialog(context, category),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: AppColors.error.withOpacity(0.8)),
                          tooltip: 'Sil',
                          onPressed: () => _confirmDeleteCategory(context, category),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 0),
            );
          }
      ),
    );
  }
}