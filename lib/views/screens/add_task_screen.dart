import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';
import '../common_widgets/add_category_dialog.dart';

class AddTaskScreen extends StatefulWidget {
  final DateTime? preSelectedDate;

  const AddTaskScreen({super.key, this.preSelectedDate});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  CategoryModel? _selectedCategory;
  bool _isCategoryInitializationAttempted = false;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedDate != null) {
      // Eğer bir tarih önceden seçilmişse, hem başlangıç hem de bitiş için onu kullan
      _selectedStartDate = widget.preSelectedDate;
      _selectedEndDate = widget.preSelectedDate;
      // Saatleri varsayılan olarak null bırakabiliriz veya o anki saati atayabiliriz
      // _selectedStartTime = TimeOfDay.fromDateTime(DateTime.now());
      // _selectedEndTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    } else {
      // Varsayılan olarak bitiş bugünün tarihi, saat tanımsız
      _selectedEndDate = DateTime.now();
      _selectedEndTime = null;
    }
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

  Future<void> _pickDateTime({
    required BuildContext context,
    required bool isStartDate,
    DateTime? initialDate,
    TimeOfDay? initialTime,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('tr', 'TR'),
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

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime ?? TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.whiteText,
                onSurface: AppColors.primaryText,
                surface: AppColors.screenBackground,
              ),
              dialogBackgroundColor: AppColors.screenBackground,
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
            if (pickedTime != null) {
              final combinedStart = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
              if (_selectedEndDate != null && _selectedEndTime != null) {
                final combinedEnd = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day, _selectedEndTime!.hour, _selectedEndTime!.minute);
                if (combinedEnd.isBefore(combinedStart)) {
                  _selectedEndDate = pickedDate;
                  _selectedEndTime = TimeOfDay(hour: pickedTime.hour + 1, minute: pickedTime.minute);
                }
              } else if (_selectedEndDate != null && _selectedEndDate!.isBefore(pickedDate)){
                _selectedEndDate = pickedDate;
                _selectedEndTime = TimeOfDay(hour: pickedTime.hour + 1, minute: pickedTime.minute);
              } else if (_selectedEndDate == null) {
                _selectedEndDate = pickedDate;
                _selectedEndTime = TimeOfDay(hour: pickedTime.hour + 1, minute: pickedTime.minute);
              }
            }
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

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

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
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen bir bitiş tarihi seçin!')),
          );
        }
        return;
      }

      if (finalStartDateTime != null && finalEndDateTime.isBefore(finalStartDateTime)) {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bitiş tarihi, başlangıç tarihinden önce olamaz!')),
          );
        }
        return;
      }

      if (_selectedCategory == null && categoryProvider.categories.isNotEmpty) {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen bir kategori seçin!')),
          );
        }
        return;
      }
      if (_selectedCategory == null && categoryProvider.categories.isEmpty) {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen önce bir kategori ekleyin veya seçin!')),
          );
        }
        return;
      }

      final String title = _titleController.text;
      final String description = _descriptionController.text;
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      try {
        await taskProvider.addNewTask(
          title: title,
          description: description.isNotEmpty ? description : null,
          startDateTime: finalStartDateTime,
          endDateTime: finalEndDateTime,
          categoryId: _selectedCategory!.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görev başarıyla eklendi!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Görev eklenirken hata oluştu: ${taskProvider.error ?? e.toString()}')),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'Seçilmedi';
    if (time == null) return DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(date);

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('dd MMMM yyyy, EEEE HH:mm', 'tr_TR').format(dateTime);
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
              leading: const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary),
              title: Text(
                'Başlangıç: ${_formatDateTime(_selectedStartDate, _selectedStartTime)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_selectedStartDate != null || _selectedStartTime != null) IconButton(icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.secondaryText), tooltip: 'Temizle', onPressed: (){ setState(() { _selectedStartDate = null; _selectedStartTime = null; }); }),
                const Icon(Icons.edit_calendar_outlined, color: AppColors.secondaryText),
              ]),
              onTap: () => _pickDateTime(
                  context: context,
                  isStartDate: true,
                  initialDate: _selectedStartDate,
                  initialTime: _selectedStartTime
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
              title: Text(
                'Bitiş: ${_formatDateTime(_selectedEndDate, _selectedEndTime)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_selectedEndDate != null || _selectedEndTime != null) IconButton(icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.secondaryText), tooltip: 'Temizle', onPressed: (){ setState(() { _selectedEndDate = null; _selectedEndTime = null; }); }),
                const Icon(Icons.edit_calendar_outlined, color: AppColors.secondaryText),
              ]),
              onTap: () => _pickDateTime(
                  context: context,
                  isStartDate: false,
                  initialDate: _selectedEndDate,
                  initialTime: _selectedEndTime
              ),
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