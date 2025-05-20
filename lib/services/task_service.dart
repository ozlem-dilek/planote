import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../main.dart';

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
    final selectedDateOnly = DateUtils.dateOnly(date);

    return _tasksBox.values.where((task) {
      if (task.startDateTime != null && task.endDateTime != null) {
        final taskStartDateOnly = DateUtils.dateOnly(task.startDateTime!);
        final taskEndDateOnly = DateUtils.dateOnly(task.endDateTime!);
        return !selectedDateOnly.isBefore(taskStartDateOnly) &&
            !selectedDateOnly.isAfter(taskEndDateOnly);
      }
      else if (task.endDateTime != null) {
        return DateUtils.isSameDay(task.endDateTime, selectedDateOnly);
      }
      else if (task.startDateTime != null) {
        return DateUtils.isSameDay(task.startDateTime, selectedDateOnly);
      }
      return false;
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

  List<TaskModel> getTasksForMonth(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final endOfLastDayOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return _tasksBox.values.where((task) {
      if (task.startDateTime == null && task.endDateTime == null) return false;

      DateTime taskEffectiveStart = task.startDateTime ?? task.endDateTime!;
      DateTime taskEffectiveEnd = task.endDateTime ?? task.startDateTime!;

      return !taskEffectiveStart.isAfter(endOfLastDayOfMonth) &&
          !taskEffectiveEnd.isBefore(firstDayOfMonth);
    }).toList();
  }
}