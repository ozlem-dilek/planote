import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final TaskService _taskService;
  final CategoryService _categoryService;
  final AuthProvider _authProvider;

  String? get _currentUserId => _authProvider.currentUser?.userId;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  List<TaskModel> _tasksForSelectedDay = [];
  Map<DateTime, List<Color>> _monthlyTaskMarkers = {};

  bool _isLoadingTasks = false;
  String? _errorLoadingTasks;
  bool _isLoadingMarkers = false;

  CalendarProvider(this._taskService, this._categoryService, this._authProvider)
      : _selectedDay = DateTime.now() {
    _authProvider.addListener(_onAuthStateChanged);
    _initializeCalendarData();
  }

  void _initializeCalendarData() {
    if (_currentUserId != null) {
      loadTasksForDay(_selectedDay);
      loadTaskMarkersForMonth(_focusedDay);
    } else {
      _tasksForSelectedDay = [];
      _monthlyTaskMarkers = {};
      notifyListeners();
    }
  }

  void _onAuthStateChanged() {
    _initializeCalendarData();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
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
    if (_currentUserId == null) {
      _tasksForSelectedDay = [];
      _isLoadingTasks = false;
      notifyListeners();
      return;
    }
    _isLoadingTasks = true;
    _errorLoadingTasks = null;
    notifyListeners();

    try {
      List<TaskModel> allTasksForDay = _taskService.getTasksForDate(_currentUserId!, day);
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
    if (_currentUserId == null) {
      _monthlyTaskMarkers = {};
      _isLoadingMarkers = false;
      notifyListeners();
      return;
    }
    _isLoadingMarkers = true;
    notifyListeners();

    final Map<DateTime, List<Color>> newMarkers = {};
    try {
      final tasksInMonth = _taskService.getTasksForMonthForUser(_currentUserId!, monthDate.year, monthDate.month);
      final allCategories = _categoryService.getAllCategoriesForUser(_currentUserId!);

      for (var task in tasksInMonth) {
        if (task.isCompleted) continue;

        DateTime currentDateToMark = DateUtils.dateOnly(task.startDateTime ?? task.endDateTime!);
        DateTime taskLoopEndDate = DateUtils.dateOnly(task.endDateTime ?? task.startDateTime!);

        DateTime firstDayOfCurrentMonth = DateUtils.dateOnly(DateTime(monthDate.year, monthDate.month, 1));
        DateTime lastDayOfCurrentMonth = DateUtils.dateOnly(DateTime(monthDate.year, monthDate.month + 1, 0));

        DateTime dayIterator = currentDateToMark;

        while(!dayIterator.isAfter(taskLoopEndDate)){
          if(!dayIterator.isBefore(firstDayOfCurrentMonth) && !dayIterator.isAfter(lastDayOfCurrentMonth)){
            CategoryModel? category;
            try {
              category = allCategories.firstWhere((cat) => cat.id == task.categoryId);
            } catch (e) {
              category = null;
            }
            final color = category != null ? Color(category.colorValue) : Colors.grey;
            final normalizedDayKey = DateTime(dayIterator.year, dayIterator.month, dayIterator.day);

            if (newMarkers.containsKey(normalizedDayKey)) {
              if (!newMarkers[normalizedDayKey]!.contains(color)) {
                newMarkers[normalizedDayKey]!.add(color);
              }
            } else {
              newMarkers[normalizedDayKey] = [color];
            }
          }
          if(DateUtils.isSameDay(dayIterator, taskLoopEndDate)) break;
          dayIterator = DateUtils.addDaysToDate(dayIterator, 1);
        }
      }
      _monthlyTaskMarkers = newMarkers;
    } catch (e) {
      // Hata yönetimi
    } finally {
      _isLoadingMarkers = false;
      notifyListeners();
    }
  }

  void selectDay(DateTime newSelectedDay, DateTime newFocusedDay) {
    bool monthChanged = !DateUtils.isSameMonth(_focusedDay, newFocusedDay);

    _selectedDay = newSelectedDay;
    _focusedDay = newFocusedDay;

    if (_currentUserId != null) {
      loadTasksForDay(newSelectedDay);
      if (monthChanged) {
        loadTaskMarkersForMonth(newFocusedDay);
      } else {
        notifyListeners();
      }
    } else {
      _tasksForSelectedDay = [];
      _monthlyTaskMarkers = {};
      notifyListeners();
    }
  }

  void changeFocusedDay(DateTime newFocusedDay) {
    if (!DateUtils.isSameMonth(_focusedDay, newFocusedDay)) {
      _focusedDay = newFocusedDay;
      if (_currentUserId != null) {
        loadTaskMarkersForMonth(newFocusedDay);
      } else {
        _monthlyTaskMarkers = {};
        notifyListeners();
      }
    }
  }

  Future<void> toggleTaskCompletionOnCalendar(String taskId) async {
    if (_currentUserId == null) return;
    _isLoadingTasks = true;
    _errorLoadingTasks = null;
    notifyListeners();

    try {
      await _taskService.toggleTaskCompletion(taskId, _currentUserId!);
      await loadTasksForDay(_selectedDay);
      await loadTaskMarkersForMonth(_focusedDay);
    } catch (e) {
      _errorLoadingTasks = "Görev durumu güncellenirken bir sorun oluştu.";
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }
}