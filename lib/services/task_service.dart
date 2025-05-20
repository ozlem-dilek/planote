import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../../main.dart';

class TaskService {
  late Box<TaskModel> _tasksBox;
  final Uuid _uuid = const Uuid();

  TaskService() {
    _tasksBox = Hive.box<TaskModel>(tasksBoxName);
  }

  Future<void> addNewTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
    print("TaskService: Görev eklendi/güncellendi: ${task.title} ID: ${task.id}");
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasksBox.values.where((task) {
      return DateUtils.isSameDay(task.dueDate, date);
    }).toList();
  }

  List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }

  Future<void> updateTask(TaskModel task) async {
    if (_tasksBox.containsKey(task.id)) {
      await _tasksBox.put(task.id, task);
      print("TaskService: Görev güncellendi: ${task.title}");
    } else {
      print("TaskService: Güncellenecek görev bulunamadı ID: ${task.id}");
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasksBox.get(taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await _tasksBox.put(taskId, task);
      print("TaskService: Görev tamamlanma durumu değiştirildi: ${task.title} -> ${task.isCompleted}");
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
    print("TaskService: Görev silindi: ID $taskId");
  }

  List<TaskModel> getTasksByCategory(String categoryId) {
    if (categoryId == 'all') {
      return getAllTasks();
    }
    return _tasksBox.values.where((task) => task.categoryId == categoryId).toList();
  }
}