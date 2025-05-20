/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // kategoriler hemen yükleniyorsa:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    //   if (categoryProvider.categories.isNotEmpty && _selectedCategory == null) {
    //     setState(() {
    //       _selectedCategory = categoryProvider.categories.first;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.whiteText,
              onSurface: AppColors.primaryText,
            ),
            dialogBackgroundColor: AppColors.screenBackground,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir tarih seçin!')),
        );
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir kategori seçin!')),
        );
        return;
      }

      final String title = _titleController.text;
      final String description = _descriptionController.text;

      // TODO: TaskProvider oluşturulduğunda:
      // final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      // taskProvider.addNewTask(
      //   title: title,
      //   description: description,
      //   dueDate: _selectedDate!,
      //   categoryId: _selectedCategory!.id,
      // );

      print('Görev Kaydedilecek (UI Verisi):');
      print('Başlık: $title');
      print('Açıklama: $description');
      print('Tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}');
      print('Kategori ID: ${_selectedCategory!.id}, Adı: ${_selectedCategory!.name}');

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (_selectedCategory == null && categoryProvider.categories.isNotEmpty) {
      _selectedCategory = categoryProvider.categories.first;
    } else if (_selectedCategory != null && categoryProvider.categories.isNotEmpty) {
      bool found = false;
      for (var cat in categoryProvider.categories) {
        if (cat.id == _selectedCategory!.id) {
          found = true;
          _selectedCategory = cat;
          break;
        }
      }
      if (!found) {
        _selectedCategory = categoryProvider.categories.first;
      }
    }


    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Yeni Görev Ekle', style: TextStyle(color: AppColors.primaryText)),
        backgroundColor: AppColors.screenBackground,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Kaydet',
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
                hintText: 'Ne yapılması gerekiyor?',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                hintText: 'Görevin detayları...',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              title: Text(
                _selectedDate == null
                    ? 'Tarih Seçilmedi'
                    : 'Tarih: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate!)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined, color: AppColors.secondaryText),
              onTap: () => _pickDate(context),
            ),
            const Divider(),
            if (categoryProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
            else if (categoryProvider.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Kategoriler yüklenemedi: ${categoryProvider.error}", style: const TextStyle(color: AppColors.error)),
              )
            else if (categoryProvider.categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Henüz kategori eklenmemiş. Lütfen önce kategori ekleyin.", style: TextStyle(color: AppColors.secondaryText)),
                )
              else
                DropdownButtonFormField<CategoryModel>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  value: _selectedCategory,
                  hint: const Text('Bir kategori seçin'),
                  isExpanded: true,
                  items: categoryProvider.categories.map((CategoryModel category) {
                    return DropdownMenuItem<CategoryModel>(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(category.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Lütfen bir kategori seçin' : null,
                ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Görevi Kaydet'),
              onPressed: (categoryProvider.categories.isEmpty || categoryProvider.isLoading) ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../common_widgets/add_category_dialog.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  CategoryModel? _selectedCategory;
  bool _isCategoryInitializationAttempted = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isCategoryInitializationAttempted) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      if (categoryProvider.categories.isNotEmpty) {
        if (_selectedCategory == null || !categoryProvider.categories.any((cat) => cat.id == _selectedCategory!.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedCategory = categoryProvider.categories.first;
              });
            }
          });
        }
        _isCategoryInitializationAttempted = true;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.whiteText,
              onSurface: AppColors.primaryText,
            ),
            dialogBackgroundColor: AppColors.screenBackground,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddCategoryDialog() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final newCategoryAdded = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const AddCategoryDialog();
      },
    );

    if (newCategoryAdded == true && mounted) {
      if (categoryProvider.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categoryProvider.categories.last;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni kategori başarıyla eklendi!')),
      );
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir tarih seçin!')),
        );
        return;
      }
      if (_selectedCategory == null && categoryProvider.categories.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir kategori seçin!')),
        );
        return;
      }
      if (_selectedCategory == null && categoryProvider.categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen önce bir kategori ekleyin veya seçin!')),
        );
        return;
      }

      final String title = _titleController.text;
      final String description = _descriptionController.text;

      print('Görev Kaydedilecek (UI Verisi):');
      print('Başlık: $title');
      print('Açıklama: $description');
      print('Tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}');
      if (_selectedCategory != null) {
        print('Kategori ID: ${_selectedCategory!.id}, Adı: ${_selectedCategory!.name}');
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Yeni Görev Ekle', style: TextStyle(color: AppColors.primaryText)),
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Kaydet',
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
                hintText: 'Ne yapılması gerekiyor?',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                hintText: 'Görevin detayları...',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              title: Text(
                _selectedDate == null
                    ? 'Tarih Seçilmedi'
                    : 'Tarih: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate!)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined, color: AppColors.secondaryText),
              onTap: () => _pickDate(context),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: categoryProvider.isLoading && categoryProvider.categories.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator()))
                      : categoryProvider.error != null && categoryProvider.categories.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Kategoriler yüklenemedi: ${categoryProvider.error}", style: const TextStyle(color: AppColors.error)),
                  )
                      : DropdownButtonFormField<CategoryModel>(
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      hintText: categoryProvider.categories.isEmpty ? 'Önce kategori ekleyin' : 'Bir kategori seçin',
                    ),
                    value: (_selectedCategory != null && categoryProvider.categories.any((cat) => cat.id == _selectedCategory!.id))
                        ? _selectedCategory
                        : null,
                    isExpanded: true,
                    items: categoryProvider.categories.map((CategoryModel category) {
                      return DropdownMenuItem<CategoryModel>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(color: Color(category.colorValue), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: categoryProvider.categories.isEmpty ? null : (newValue) {
                      setState(() { _selectedCategory = newValue; });
                    },
                    validator: (value) => value == null && categoryProvider.categories.isNotEmpty ? 'Lütfen bir kategori seçin' : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
                    tooltip: 'Yeni Kategori Ekle',
                    onPressed: _showAddCategoryDialog,
                  ),
                ),
              ],
            ),
            if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading && categoryProvider.error == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text("Henüz kategori eklenmemiş. '+' ikonuna basarak yeni bir kategori ekleyebilirsiniz.", style: TextStyle(color: AppColors.secondaryText)),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Görevi Kaydet'),
              onPressed: (categoryProvider.isLoading && categoryProvider.categories.isEmpty && _selectedCategory == null) ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}