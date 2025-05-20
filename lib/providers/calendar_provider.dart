import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class CalendarProvider extends ChangeNotifier {
  final TaskService _taskService;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  List<TaskModel> _tasksForSelectedDay = [];

  bool _isLoadingTasks = false;
  String? _errorLoadingTasks;

  CalendarProvider(this._taskService) : _selectedDay = DateTime.now() {
    loadTasksForDay(_selectedDay);
  }

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  List<TaskModel> get tasksForSelectedDay => _tasksForSelectedDay;
  bool get isLoadingTasks => _isLoadingTasks;
  String? get errorLoadingTasks => _errorLoadingTasks;

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
      _tasksForSelectedDay = _taskService.getTasksForDate(day);
      _sortTasks(_tasksForSelectedDay);
    } catch (e) {
      _errorLoadingTasks = "Görevler yüklenirken bir sorun oluştu.";
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }

  void selectDay(DateTime newSelectedDay, DateTime newFocusedDay) {
    if (!DateUtils.isSameDay(_selectedDay, newSelectedDay)) {
      _selectedDay = newSelectedDay;
      _focusedDay = newFocusedDay;
      loadTasksForDay(newSelectedDay);
    } else if (!DateUtils.isSameDay(_focusedDay, newFocusedDay)){
      _focusedDay = newFocusedDay;
      notifyListeners();
    }
  }

  void changeFocusedDay(DateTime newFocusedDay) {
    if (!DateUtils.isSameMonth(_focusedDay, newFocusedDay)) {
      _focusedDay = newFocusedDay;
      notifyListeners();
      // TODO: Ay değiştiğinde o ay için görev işaretlerini (noktaları) yükle
    }
  }

  Future<void> toggleTaskCompletionOnCalendar(String taskId) async {
    _errorLoadingTasks = null;
    final originalTasks = List<TaskModel>.from(_tasksForSelectedDay);
    int taskIndex = _tasksForSelectedDay.indexWhere((task) => task.id == taskId);

    if (taskIndex != -1) {
      _tasksForSelectedDay[taskIndex].isCompleted = !_tasksForSelectedDay[taskIndex].isCompleted;
      _sortTasks(_tasksForSelectedDay);
      notifyListeners();
    }

    try {
      await _taskService.toggleTaskCompletion(taskId);
    } catch (e) {
      _errorLoadingTasks = "Görev durumu güncellenirken hata oluştu.";
      if (taskIndex != -1) {
        _tasksForSelectedDay = originalTasks;
      }
      notifyListeners();
    }
  }
}