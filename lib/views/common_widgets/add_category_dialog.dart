import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = AppColors.defaultCategoryColors.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitCategory() {
    if (_formKey.currentState!.validate()) {
      final categoryName = _nameController.text;
      context.read<CategoryProvider>().addNewCategory(
        name: categoryName,
        color: _selectedColor,
      ).then((_) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kategori eklenirken hata: $error')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Kategori Ekle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Kategori Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir kategori adı girin.';
                  }
                  // TODO: Aynı isimde kategori olup olmadığını kontrol et (Provider/Service üzerinden)
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
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Theme.of(context).primaryColorDark
                              : Colors.grey.shade300,
                          width: _selectedColor == color ? 3.0 : 1.5,
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
          child: const Text('İptal'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(
          child: const Text('Ekle'),
          onPressed: _submitCategory,
        ),
      ],
    );
  }
}