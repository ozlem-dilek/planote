import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../models/task_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../common_widgets/add_category_dialog.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel taskToEdit;

  const EditTaskScreen({super.key, required this.taskToEdit});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit.title);
    _descriptionController = TextEditingController(text: widget.taskToEdit.description ?? "");

    if (widget.taskToEdit.startDateTime != null) {
      _selectedStartDate = widget.taskToEdit.startDateTime;
      _selectedStartTime = TimeOfDay.fromDateTime(widget.taskToEdit.startDateTime!);
    }
    if (widget.taskToEdit.endDateTime != null) {
      _selectedEndDate = widget.taskToEdit.endDateTime;
      _selectedEndTime = TimeOfDay.fromDateTime(widget.taskToEdit.endDateTime!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      if (categoryProvider.categories.isNotEmpty) {
        CategoryModel? foundCategory;
        try {
          foundCategory = categoryProvider.categories.firstWhere(
                  (cat) => cat.id == widget.taskToEdit.categoryId
          );
        } catch (e) {
          foundCategory = null;
        }

        if (mounted) {
          setState(() {
            if (foundCategory != null) {
              _selectedCategory = foundCategory;
            } else if (categoryProvider.categories.isNotEmpty) {
              _selectedCategory = categoryProvider.categories.first;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required BuildContext context,
    required bool isStartDate,
    DateTime? initialDate,
    TimeOfDay? initialTime,
  }) async {
    final ThemeData currentTheme = Theme.of(context);
    final ColorScheme pickerColorScheme = currentTheme.brightness == Brightness.light
        ? const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.whiteText,
      onSurface: AppColors.primaryText,
    )
        : const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.blackText,
      onSurface: AppColors.whiteText,
      surface: AppColors.primaryDark,
    );

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: currentTheme.copyWith(
              colorScheme: pickerColorScheme,
              dialogBackgroundColor: currentTheme.scaffoldBackgroundColor
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime ?? TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: currentTheme.copyWith(
              colorScheme: pickerColorScheme.copyWith(surface: currentTheme.cardColor),
            ),
            child: child!,
          );
        },
      );

      if (mounted) {
        setState(() {
          if (isStartDate) {
            _selectedStartDate = pickedDate;
            _selectedStartTime = pickedTime;
          } else {
            _selectedEndDate = pickedDate;
            _selectedEndTime = pickedTime;
          }
        });
      }
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

  void _updateTask() async {
    if (_formKey.currentState!.validate()) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? currentUserId = authProvider.currentUser?.userId;

      if (currentUserId == null || widget.taskToEdit.userId != currentUserId) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu görevi güncelleme yetkiniz yok.')),
          );
        }
        return;
      }

      DateTime? finalStartDateTime;
      if (_selectedStartDate != null) {
        finalStartDateTime = DateTime(
            _selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day,
            _selectedStartTime?.hour ?? 0, _selectedStartTime?.minute ?? 0
        );
      }

      DateTime? finalEndDateTime;
      if (_selectedEndDate != null) {
        finalEndDateTime = DateTime(
            _selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day,
            _selectedEndTime?.hour ?? 23, _selectedEndTime?.minute ?? 59
        );
      }

      if (finalEndDateTime == null) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir bitiş tarihi seçin!')));
        return;
      }

      if (finalStartDateTime != null && finalEndDateTime.isBefore(finalStartDateTime)) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitiş tarihi, başlangıç tarihinden önce olamaz!')));
        return;
      }

      if (_selectedCategory == null && categoryProvider.categories.isNotEmpty) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir kategori seçin!')));
        return;
      }
      if (_selectedCategory == null && categoryProvider.categories.isEmpty) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen önce bir kategori ekleyin veya seçin!')));
        return;
      }

      final updatedTask = TaskModel(
        id: widget.taskToEdit.id,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        startDateTime: finalStartDateTime,
        endDateTime: finalEndDateTime,
        categoryId: _selectedCategory!.id,
        isCompleted: widget.taskToEdit.isCompleted,
        createdAt: widget.taskToEdit.createdAt,
        completedAt: widget.taskToEdit.completedAt,
        userId: currentUserId,
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      try {
        await taskProvider.updateTask(updatedTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görev başarıyla güncellendi!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Görev güncellenirken hata oluştu: ${taskProvider.error ?? e.toString()}')),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'Seçilmedi';
    if (time == null) return DateFormat('dd MMMM y, EEEE', 'tr_TR').format(date);

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('dd MMMM y, EEEE HH:mm', 'tr_TR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Görevi Düzenle', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded, color: theme.appBarTheme.actionsIconTheme?.color),
            tooltip: 'Kaydet',
            onPressed: _updateTask,
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
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'Görev Başlığı', prefixIcon: Icon(Icons.title_rounded, color: theme.inputDecorationTheme.prefixIconColor)),
              validator: (value) => (value == null || value.isEmpty) ? 'Lütfen bir başlık girin' : null,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'Açıklama (Opsiyonel)', prefixIcon: Icon(Icons.description_outlined, color: theme.inputDecorationTheme.prefixIconColor)),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.play_circle_outline_rounded, color: theme.colorScheme.primary),
              title: Text('Başlangıç: ${_formatDateTime(_selectedStartDate, _selectedStartTime)}', style: theme.textTheme.titleMedium),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_selectedStartDate != null || _selectedStartTime != null) IconButton(icon: Icon(Icons.clear_rounded, size: 20, color: theme.iconTheme.color?.withOpacity(0.7)), tooltip: 'Temizle', onPressed: (){ setState(() { _selectedStartDate = null; _selectedStartTime = null; }); }),
                Icon(Icons.edit_calendar_outlined, color: theme.iconTheme.color?.withOpacity(0.7)),
              ]),
              onTap: () => _pickDateTime(context: context, isStartDate: true, initialDate: _selectedStartDate, initialTime: _selectedStartTime),
            ),
            Divider(color: theme.dividerColor),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.primary),
              title: Text('Bitiş: ${_formatDateTime(_selectedEndDate, _selectedEndTime)}', style: theme.textTheme.titleMedium),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_selectedEndDate != null || _selectedEndTime != null) IconButton(icon: Icon(Icons.clear_rounded, size: 20, color: theme.iconTheme.color?.withOpacity(0.7)), tooltip: 'Temizle', onPressed: (){ setState(() { _selectedEndDate = null; _selectedEndTime = null; }); }),
                Icon(Icons.edit_calendar_outlined, color: theme.iconTheme.color?.withOpacity(0.7)),
              ]),
              onTap: () => _pickDateTime(context: context, isStartDate: false, initialDate: _selectedEndDate, initialTime: _selectedEndTime),
            ),
            Divider(color: theme.dividerColor),
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
                    child: Text("Kategoriler yüklenemedi: ${categoryProvider.error}", style: TextStyle(color: theme.colorScheme.error)),
                  )
                      : DropdownButtonFormField<CategoryModel>(
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined, color: theme.inputDecorationTheme.prefixIconColor),
                      hintText: categoryProvider.categories.isEmpty ? 'Önce kategori ekleyin' : 'Bir kategori seçin',
                    ),
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.titleMedium,
                    value: (_selectedCategory != null && categoryProvider.categories.any((cat) => cat.id == _selectedCategory!.id))
                        ? _selectedCategory
                        : null,
                    isExpanded: true,
                    items: categoryProvider.categories.map((CategoryModel category) {
                      return DropdownMenuItem<CategoryModel>(
                        value: category,
                        child: Row(children: [
                          Container(width: 16, height: 16, decoration: BoxDecoration(color: Color(category.colorValue), shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ]),
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
                    icon: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary, size: 28),
                    tooltip: 'Yeni Kategori Ekle',
                    onPressed: _showAddCategoryDialog,
                  ),
                ),
              ],
            ),
            if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading && categoryProvider.error == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text("Henüz kategori eklenmemiş. '+' ikonuna basarak yeni bir kategori ekleyebilirsiniz.", style: theme.textTheme.bodySmall),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Değişiklikleri Kaydet'),
              onPressed: _updateTask,
              style: theme.elevatedButtonTheme.style,
            ),
          ],
        ),
      ),
    );
  }
}