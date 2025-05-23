import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  List<TaskModel> _allFetchedTasks = [];
  List<TaskModel> _filteredAndSortedTasks = [];
  String _selectedCategoryId = 'all';

  bool _isLoading = false;
  String? _error;
  final Uuid _uuid = const Uuid();

  List<TaskModel> get filteredTasks => _filteredAndSortedTasks;

  List<TaskModel> get pastDueUncompletedTasks {
    final today = DateUtils.dateOnly(DateTime.now());
    return _filteredAndSortedTasks.where((task) =>
    !task.isCompleted &&
        task.endDateTime != null &&
        DateUtils.dateOnly(task.endDateTime!).isBefore(today)
    ).toList();
  }

  List<TaskModel> get todaysTasks {
    final now = DateTime.now();
    return _filteredAndSortedTasks.where((task) =>
    !task.isCompleted && // <-- YENİ FİLTRE EKLENDİ
        task.endDateTime != null &&
        DateUtils.isSameDay(task.endDateTime, now)
    ).toList();
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final oneWeekFromNow = today.add(const Duration(days: 7));
    return _filteredAndSortedTasks.where((task) {
      if (task.isCompleted) return false; // <-- YENİ FİLTRE EKLENDİ
      if (task.endDateTime == null) return false;

      final taskEndDateOnly = DateUtils.dateOnly(task.endDateTime!);
      return !DateUtils.isSameDay(task.endDateTime, now) &&
          taskEndDateOnly.isAfter(today) &&
          (taskEndDateOnly.isBefore(oneWeekFromNow) || DateUtils.isSameDay(taskEndDateOnly, oneWeekFromNow));
    }
    ).toList();
  }

  List<TaskModel> get otherTasks {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final endOfUpcomingWindow = today.add(const Duration(days: 7));

    return _filteredAndSortedTasks.where((task) {
      if (task.isCompleted) return false;
      if (task.endDateTime == null) return true;

      final taskEndDateOnly = DateUtils.dateOnly(task.endDateTime!);

      if (taskEndDateOnly.isBefore(today)) return false;
      if (DateUtils.isSameDay(task.endDateTime, now)) return false;
      // Aşağıdaki satır, endOfUpcomingWindow'u da dahil edecek şekilde düzeltildi:
      if (!taskEndDateOnly.isAfter(endOfUpcomingWindow) && (taskEndDateOnly.isBefore(endOfUpcomingWindow) || DateUtils.isSameDay(taskEndDateOnly, endOfUpcomingWindow))) return false;

      return true;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategoryId => _selectedCategoryId;

  TaskProvider(this._taskService) {
    loadTasksForCategory('all');
  }

  void _sortTasks(List<TaskModel> tasks) {
    tasks.sort((a, b) {
      if (a.endDateTime == null && b.endDateTime == null) return 0;
      if (a.endDateTime == null) return 1;
      if (b.endDateTime == null) return -1;
      return a.endDateTime!.compareTo(b.endDateTime!);
    });
  }

  Future<void> loadTasksForCategory(String categoryId) async {
    _selectedCategoryId = categoryId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (categoryId.toLowerCase() == 'all' || categoryId.toLowerCase() == 'tümü') {
        _allFetchedTasks = _taskService.getAllTasks();
      } else {
        _allFetchedTasks = _taskService.getTasksByCategory(categoryId);
      }
      _filteredAndSortedTasks = List.from(_allFetchedTasks);
      _sortTasks(_filteredAndSortedTasks);
    } catch (e) {
      _error = "Görevler yüklenirken bir sorun oluştu.";
      _allFetchedTasks = [];
      _filteredAndSortedTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewTask({
    required String title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    required String categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final String newId = _uuid.v4();
    final newTask = TaskModel(
      id: newId,
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      categoryId: categoryId,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    try {
      await _taskService.addNewTask(newTask);
      await loadTasksForCategory(_selectedCategoryId);
    } catch (e) {
      _error = "Yeni görev eklenirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _taskService.updateTask(task);
      await loadTasksForCategory(_selectedCategoryId);
    } catch (e) {
      _error = "Görev güncellenirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _taskService.toggleTaskCompletion(taskId);
      await loadTasksForCategory(_selectedCategoryId);
    } catch (e) {
      _error = "Görev durumu güncellenirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _taskService.deleteTask(taskId);
      await loadTasksForCategory(_selectedCategoryId);
    } catch (e) {
      _error = "Görev silinirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }
}