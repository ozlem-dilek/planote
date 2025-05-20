import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../main.dart';
import 'package:flutter/material.dart';

class TaskService {
  late Box<TaskModel> _tasksBox;

  TaskService() {
    _tasksBox = Hive.box<TaskModel>(tasksBoxName);
  }

  Future<void> addNewTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasksBox.values.where((task) {
      if (task.endDateTime == null) return false;
      return DateUtils.isSameDay(task.endDateTime, date);
    }).toList();
  }

  Future<void> updateTask(TaskModel task) async {
    if (_tasksBox.containsKey(task.id)) {
      await _tasksBox.put(task.id, task);
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasksBox.get(taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  List<TaskModel> getTasksByCategory(String categoryId) {
    if (categoryId.toLowerCase() == 'all' || categoryId.toLowerCase() == 'tümü') {
      return getAllTasks();
    }
    return _tasksBox.values.where((task) => task.categoryId == categoryId).toList();
  }
}