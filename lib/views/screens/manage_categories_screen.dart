import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? currentUserId = authProvider.currentUser?.userId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kategori düzenlemek için giriş yapmalısınız.")));
      return;
    }
    if (categoryToEdit.userId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu kategoriyi düzenleme yetkiniz yok.")));
      return;
    }

    final TextEditingController nameController = TextEditingController(text: categoryToEdit.name);
    Color selectedColor = Color(categoryToEdit.colorValue);
    final formKey = GlobalKey<FormState>();


    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (stfContext, stfSetState) {
              final ThemeData dialogTheme = Theme.of(dialogContext);
              return AlertDialog(
                backgroundColor: dialogTheme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text('Kategoriyi Düzenle', style: dialogTheme.textTheme.titleLarge),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: nameController,
                          style: dialogTheme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                              labelText: 'Kategori Adı',
                              labelStyle: dialogTheme.textTheme.bodyMedium
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir kategori adı girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Renk Seçin:', style: dialogTheme.textTheme.bodyMedium),
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
                                        ? dialogTheme.colorScheme.primary
                                        : dialogTheme.dividerColor,
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
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('İptal', style: TextStyle(color: dialogTheme.colorScheme.secondary)),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: dialogTheme.colorScheme.primary),
                    child: Text('Güncelle', style: TextStyle(color: dialogTheme.colorScheme.onPrimary)),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final updatedCategory = CategoryModel(
                          id: categoryToEdit.id,
                          name: nameController.text,
                          colorValue: selectedColor.value,
                          userId: currentUserId,
                        );
                        categoryProvider.updateCategory(updatedCategory).then((_){
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                        }).catchError((e){
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(false);
                            ScaffoldMessenger.of(stfContext).showSnackBar(SnackBar(content: Text("Güncelleme hatası: $e"), backgroundColor: AppColors.error));
                          }
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
          final ThemeData dialogTheme = Theme.of(dialogContext);
          return AlertDialog(
            backgroundColor: dialogTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('Kategoriyi Sil', style: dialogTheme.textTheme.titleLarge),
            content: Text(
              result['message'] ?? 'Bu kategoride ${result['taskCount']} görev var. Silmek istediğinize emin misiniz? İlişkili görevler "Diğer" kategorisine taşınacak.',
              style: dialogTheme.textTheme.bodyMedium,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('İptal', style: TextStyle(color: dialogTheme.colorScheme.secondary)),
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: dialogTheme.colorScheme.error),
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
          SnackBar(content: Text('"${categoryToDelete.name}" kategorisi ve ilişkili görevler güncellendi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Kategorileri Yönet', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: theme.appBarTheme.actionsIconTheme?.color),
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
              return Center(child: Text("Hata: ${categoryProvider.error}", style: TextStyle(color: theme.colorScheme.error)));
            }
            if (categoryProvider.categories.isEmpty) {
              return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Henüz hiç kategori eklenmemiş.\nSağ üstteki '+' ikonuna basarak yeni bir kategori ekleyebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
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
                  elevation: theme.cardTheme.elevation,
                  margin: theme.cardTheme.margin,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: Color(category.colorValue),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.dividerColor)
                      ),
                    ),
                    title: Text(category.name, style: theme.textTheme.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: theme.iconTheme.color?.withOpacity(0.8)),
                          tooltip: 'Düzenle',
                          onPressed: () => _showEditCategoryDialog(context, category),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error.withOpacity(0.8)),
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