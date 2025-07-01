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

  List<TaskModel> getAllTasksForUser(String userId) {
    return _tasksBox.values.where((task) => task.userId == userId).toList();
  }

  List<TaskModel> getTasksForDate(String userId, DateTime date) {
    final selectedDateOnly = DateUtils.dateOnly(date);
    return _tasksBox.values.where((task) {
      if (task.userId != userId) return false;

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

  Future<void> updateTask(TaskModel task, String userId) async {
    final existingTask = _tasksBox.get(task.id);
    if (existingTask != null && existingTask.userId == userId && task.userId == userId) {
      await _tasksBox.put(task.id, task);
    } else {
      throw Exception("Bu görevi güncelleme yetkiniz yok veya görev bulunamadı.");
    }
  }

  Future<void> toggleTaskCompletion(String taskId, String userId) async {
    final task = _tasksBox.get(taskId);
    if (task != null && task.userId == userId) {
      task.isCompleted = !task.isCompleted;
      if (task.isCompleted) {
        task.completedAt = DateTime.now();
      } else {
        task.completedAt = null;
      }
      await task.save();
    } else {
      throw Exception("Görev bulunamadı veya size ait değil.");
    }
  }

  Future<void> deleteTask(String taskId, String userId) async {
    final task = _tasksBox.get(taskId);
    if (task != null && task.userId == userId) {
      await _tasksBox.delete(taskId);
    } else {
      throw Exception("Silinecek görev bulunamadı veya size ait değil.");
    }
  }

  List<TaskModel> getTasksByCategoryForUser(String userId, String categoryId) {
    if (categoryId.toLowerCase() == 'all' || categoryId.toLowerCase() == 'tümü') {
      return getAllTasksForUser(userId);
    }
    return _tasksBox.values.where((task) => task.userId == userId && task.categoryId == categoryId).toList();
  }

  List<TaskModel> getTasksForMonthForUser(String userId, int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final endOfLastDayOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return _tasksBox.values.where((task) {
      if (task.userId != userId) return false;
      if (task.startDateTime == null && task.endDateTime == null) return false;

      DateTime taskEffectiveStart = DateUtils.dateOnly(task.startDateTime ?? task.endDateTime!);
      DateTime taskEffectiveEnd = DateUtils.dateOnly(task.endDateTime ?? task.startDateTime!);

      return !taskEffectiveStart.isAfter(endOfLastDayOfMonth) &&
          !taskEffectiveEnd.isBefore(firstDayOfMonth);
    }).toList();
  }
}