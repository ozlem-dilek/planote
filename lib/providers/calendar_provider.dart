import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';
import 'task_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final TaskService _taskService;
  final CategoryService _categoryService;
  final TaskProvider _taskProvider;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  List<TaskModel> _tasksForSelectedDay = [];
  Map<DateTime, List<Color>> _monthlyTaskMarkers = {};

  bool _isLoadingTasks = false;
  String? _errorLoadingTasks;
  bool _isLoadingMarkers = false;

  CalendarProvider(this._taskService, this._categoryService, this._taskProvider)
      : _selectedDay = DateTime.now() {
    _taskProvider.addListener(_onTaskProviderChanged);
    _initializeCalendar();
  }

  void _initializeCalendar() {
    loadTasksForDay(_selectedDay);
    loadTaskMarkersForMonth(_focusedDay);
  }

  void _onTaskProviderChanged() {
    loadTaskMarkersForMonth(_focusedDay);
    loadTasksForDay(_selectedDay);
  }

  @override
  void dispose() {
    _taskProvider.removeListener(_onTaskProviderChanged);
    super.dispose();
  }

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  List<TaskModel> get tasksForSelectedDay => _tasksForSelectedDay;
  Map<DateTime, List<Color>> get monthlyTaskMarkers => _monthlyTaskMarkers;
  bool get isLoadingTasks => _isLoadingTasks;
  String? get errorLoadingTasks => _errorLoadingTasks;
  bool get isLoadingMarkers => _isLoadingMarkers;

  void _sortTasks(List<TaskModel> tasks) {
    tasks.sort((a, b) {
      DateTime? aTime = a.startDateTime ?? a.endDateTime;
      DateTime? bTime = b.startDateTime ?? b.endDateTime;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });
  }

  Future<void> loadTasksForDay(DateTime day) async {
    _isLoadingTasks = true;
    _errorLoadingTasks = null;
    notifyListeners();

    try {
      List<TaskModel> allTasksForDay = _taskService.getTasksForDate(day);
      _tasksForSelectedDay = allTasksForDay.where((task) => !task.isCompleted).toList();
      _sortTasks(_tasksForSelectedDay);
    } catch (e) {
      _errorLoadingTasks = "Görevler yüklenirken bir sorun oluştu.";
      _tasksForSelectedDay = [];
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }

  Future<void> loadTaskMarkersForMonth(DateTime monthDate) async {
    _isLoadingMarkers = true;
    notifyListeners();

    final Map<DateTime, List<Color>> newMarkers = {};
    try {
      final tasksInMonth = _taskService.getTasksForMonth(monthDate.year, monthDate.month);
      final allCategories = _categoryService.getAllCategories();

      for (var task in tasksInMonth) {
        if (task.isCompleted) continue;

        DateTime currentDateToMark = task.startDateTime ?? task.endDateTime!;
        DateTime taskLoopEndDate = task.endDateTime ?? task.startDateTime!;

        DateTime dayToMark = DateUtils.dateOnly(currentDateToMark);
        DateTime endDayToMark = DateUtils.dateOnly(taskLoopEndDate);

        DateTime firstDayOfCurrentMonth = DateUtils.dateOnly(DateTime(monthDate.year, monthDate.month, 1));
        DateTime lastDayOfCurrentMonth = DateUtils.dateOnly(DateTime(monthDate.year, monthDate.month + 1, 0));

        while(!dayToMark.isAfter(endDayToMark)){
          if(!dayToMark.isBefore(firstDayOfCurrentMonth) && !dayToMark.isAfter(lastDayOfCurrentMonth)){
            CategoryModel? category;
            try {
              category = allCategories.firstWhere((cat) => cat.id == task.categoryId);
            } catch (e) {
              category = null;
            }
            final color = category != null ? Color(category.colorValue) : Colors.grey;
            final normalizedDayKey = DateTime(dayToMark.year, dayToMark.month, dayToMark.day);

            if (newMarkers.containsKey(normalizedDayKey)) {
              if (!newMarkers[normalizedDayKey]!.contains(color)) {
                newMarkers[normalizedDayKey]!.add(color);
              }
            } else {
              newMarkers[normalizedDayKey] = [color];
            }
          }
          if(DateUtils.isSameDay(dayToMark, endDayToMark)) break;
          dayToMark = DateUtils.addDaysToDate(dayToMark, 1);
        }
      }
      _monthlyTaskMarkers = newMarkers;
    } catch (e) {
    } finally {
      _isLoadingMarkers = false;
      notifyListeners();
    }
  }

  void selectDay(DateTime newSelectedDay, DateTime newFocusedDay) {
    bool monthChanged = !DateUtils.isSameMonth(_focusedDay, newFocusedDay);

    _selectedDay = newSelectedDay;
    _focusedDay = newFocusedDay;

    loadTasksForDay(newSelectedDay);

    if (monthChanged) {
      loadTaskMarkersForMonth(newFocusedDay);
    } else {
      notifyListeners();
    }
  }

  void changeFocusedDay(DateTime newFocusedDay) {
    if (!DateUtils.isSameMonth(_focusedDay, newFocusedDay)) {
      _focusedDay = newFocusedDay;
      notifyListeners();
      loadTaskMarkersForMonth(newFocusedDay);
      // TODO: Ay değiştiğinde o ay için task işaretlerini (noktaları) yükle
    }
  }

  Future<void> toggleTaskCompletionOnCalendar(String taskId) async {
    _isLoadingTasks = true;
    _errorLoadingTasks = null;
    notifyListeners();

    try {
      await _taskService.toggleTaskCompletion(taskId);
      await loadTasksForDay(_selectedDay);
      // await loadTaskMarkersForMonth(_focusedDay); //  _onTaskProviderChanged tarafından tetiklenecek
    } catch (e) {
      _errorLoadingTasks = "Görev durumu güncellenirken hata oluştu.";
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }
}