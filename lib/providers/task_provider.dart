import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  final Uuid _uuid = const Uuid();

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskProvider(this._taskService) {
    loadAllTasks();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.endDateTime == null && b.endDateTime == null) return 0;
      if (a.endDateTime == null) return 1;
      if (b.endDateTime == null) return -1;
      return a.endDateTime!.compareTo(b.endDateTime!);
    });
  }

  Future<void> loadAllTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = _taskService.getAllTasks();
      _sortTasks();
    } catch (e) {
      _error = "Görevler yüklenirken bir sorun oluştu.";
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
      await loadAllTasks();
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
      await loadAllTasks();
    } catch (e) {
      _error = "Görev güncellenirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    _error = null;
    try {
      final TaskModel? taskToUpdate = _tasks.firstWhere((task) => task.id == taskId, orElse: () => _tasks.first );


      await _taskService.toggleTaskCompletion(taskId);
      int taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
        _sortTasks();
        notifyListeners();
      } else {
        await loadAllTasks();
      }
    } catch (e) {
      _error = "Görev durumu güncellenirken bir sorun oluştu.";
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _taskService.deleteTask(taskId);
      await loadAllTasks();
    } catch (e) {
      _error = "Görev silinirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = _taskService.getTasksByCategory(categoryId);
      _sortTasks();
    } catch (e) {
      _error = "Kategoriye göre görevler yüklenirken bir sorun oluştu.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}