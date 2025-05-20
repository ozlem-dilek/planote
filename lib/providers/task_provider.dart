import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  //final CategoryService _categoryService;

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

  Future<void> loadAllTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = _taskService.getAllTasks();
      // TODO: Görevleri tarihe veya başka bir kritere göre sıralanacak
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      print("TaskProvider: ${_tasks.length} görev yüklendi.");
    } catch (e) {
      _error = "Görevler yüklenirken bir sorun oluştu.";
      print("TaskProvider Hata: Görevler yüklenemedi - $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return _taskService.getTasksForDate(date);
  }

  Future<void> addNewTask({
    required String title,
    String? description,
    required DateTime dueDate,
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
      dueDate: dueDate,
      categoryId: categoryId,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    try {
      await _taskService.addNewTask(newTask);
      await loadAllTasks();
    } catch (e) {
      _error = "Yeni görev eklenirken bir sorun oluştu.";
      print("TaskProvider Hata: Yeni görev eklenemedi - $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _taskService.updateTask(task);
      await loadAllTasks();
    } catch (e) {
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      await _taskService.toggleTaskCompletion(taskId);
      int taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
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
    try {
      await _taskService.deleteTask(taskId);
      await loadAllTasks();
    } catch (e) {
    }
  }

  Future<void> loadTasksByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = _taskService.getTasksByCategory(categoryId);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      _error = "Kategoriye göre görevler yüklenirken bir sorun oluştu.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}