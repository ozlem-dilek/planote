import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class _TempCategory {
  final String id;
  final String name;
  final Color color;
  _TempCategory({required this.id, required this.name, required this.color});
}

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
  _TempCategory? _selectedCategory;

  // TODO: Bu kategoriler CategoryProvider'dan dinamik olarak gelecek
  final List<_TempCategory> _sampleCategories = [
    _TempCategory(id: 'work', name: 'Work', color: AppColors.primaryDark),
    _TempCategory(id: 'personal', name: 'Personal', color: Colors.orange),
    _TempCategory(id: 'shopping', name: 'Shopping', color: Colors.lightBlue),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (_sampleCategories.isNotEmpty) {
      _selectedCategory = _sampleCategories.first;
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
      // TODO: Yeni TaskModel oluşturup Provider -> Service -> Hive ile kaydet
      print('Görev Kaydedildi:');
      print('Başlık: $title');
      print('Açıklama: $description');
      print('Tarih: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}');
      print('Kategori: ${_selectedCategory!.name}');

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Yeni Görev Ekle', style: TextStyle(color: AppColors.primaryText)),
        backgroundColor: AppColors.todoAppBarBackground,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
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
        child: ListView( // SingleChildScrollView da olabilirdi
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Görev Başlığı
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

            // Görev Açıklaması (Opsiyonel)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (Opsiyonel)',
                hintText: 'Görevin detayları...',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3, // Birden fazla satır
            ),
            const SizedBox(height: 20.0),

            // Tarih Seçimi
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              title: Text(
                _selectedDate == null
                    ? 'Tarih Seçilmedi'
                    : 'Tarih: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate!)}', // Türkçe format
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
              ),
              trailing: const Icon(Icons.edit_calendar_outlined, color: AppColors.secondaryText),
              onTap: () => _pickDate(context),
            ),
            const Divider(),

            // Kategori Seçimi
            // TODO: CategoryProvider'dan kategorileri alıp DropdownMenuItem'ları dinamik oluştur
            DropdownButtonFormField<_TempCategory>(
              decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(), // Veya UnderlineInputBorder()
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)
              ),
              value: _selectedCategory,
              hint: const Text('Bir kategori seçin'),
              isExpanded: true,
              items: _sampleCategories.map((_TempCategory category) {
                return DropdownMenuItem<_TempCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: category.color,
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
              onPressed: _saveTask,
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