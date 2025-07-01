import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';
import '../../main.dart';

class CategoryService {
  late Box<CategoryModel> _categoriesBox;
  late Box<TaskModel> _tasksBox;
  final Uuid _uuid = const Uuid();

  CategoryService() {
    _categoriesBox = Hive.box<CategoryModel>(categoriesBoxName);
    _tasksBox = Hive.box<TaskModel>(tasksBoxName);
  }

  Future<void> addDefaultCategoriesForUser(String userId) async {
    final userCategories = _categoriesBox.values.where((cat) => cat.userId == userId).toList();
    if (userCategories.isEmpty) {
      final defaultCategories = [
        CategoryModel(id: 'work_$userId', name: 'İş', colorValue: Colors.blue.value, userId: userId),
        CategoryModel(id: 'personal_$userId', name: 'Kişisel', colorValue: Colors.green.value, userId: userId),
        CategoryModel(id: 'other_$userId', name: 'Diğer', colorValue: Colors.grey.value, userId: userId),
      ];
      for (var category in defaultCategories) {
        await _categoriesBox.put(category.id, category);
      }
    }
  }

  List<CategoryModel> getAllCategoriesForUser(String userId) {
    final categories = _categoriesBox.values.where((cat) => cat.userId == userId).toList();
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  Future<CategoryModel> addNewCategory({
    required String name,
    required int colorValue,
    required String userId,
  }) async {
    final String newId = _uuid.v4();
    final newCategory = CategoryModel(
      id: newId,
      name: name,
      colorValue: colorValue,
      userId: userId,
    );
    await _categoriesBox.put(newCategory.id, newCategory);
    return newCategory;
  }

  Future<void> updateCategory(CategoryModel category, String userId) async {
    if (category.userId != userId) {
      throw Exception("Bu kategoriyi güncelleme yetkiniz yok.");
    }
    if (_categoriesBox.containsKey(category.id)) {
      await _categoriesBox.put(category.id, category);
    } else {
      throw Exception("Güncellenecek kategori bulunamadı.");
    }
  }

  Future<Map<String, dynamic>> attemptDeleteCategory(String categoryId, String userId) async {
    final category = _categoriesBox.get(categoryId);
    if (category == null || category.userId != userId) {
      return {'deleted': false, 'taskCount': 0, 'message': 'Kategori bulunamadı veya size ait değil.'};
    }

    int associatedTaskCount = 0;
    for (final task in _tasksBox.values) {
      if (task.userId == userId && task.categoryId == categoryId) {
        associatedTaskCount++;
      }
    }

    if (associatedTaskCount > 0) {
      return {
        'deleted': false,
        'taskCount': associatedTaskCount,
        'message': 'Bu kategoride $associatedTaskCount adet göreviniz var. Silmek istediğinize emin misiniz?'
      };
    } else {
      await _categoriesBox.delete(categoryId);
      return {'deleted': true, 'taskCount': 0, 'message': 'Kategori başarıyla silindi.'};
    }
  }

  Future<void> deleteCategoryConfirmed(String categoryId, String userId, {String defaultCategoryIdPrefix = 'other_'}) async {
    final category = _categoriesBox.get(categoryId);
    if (category == null || category.userId != userId) return;

    String userSpecificDefaultCategoryId = '${defaultCategoryIdPrefix}$userId';

    CategoryModel? defaultCategory = _categoriesBox.get(userSpecificDefaultCategoryId);
    if(defaultCategory == null){
      defaultCategory = CategoryModel(id: userSpecificDefaultCategoryId, name: 'Diğer', colorValue: Colors.grey.value, userId: userId);
      await _categoriesBox.put(defaultCategory.id, defaultCategory);
    }

    List<TaskModel> tasksToUpdate = _tasksBox.values.where((task) => task.userId == userId && task.categoryId == categoryId).toList();
    for (TaskModel task in tasksToUpdate) {
      task.categoryId = userSpecificDefaultCategoryId;
      if (task.isInBox) {
        await task.save();
      } else {
        await _tasksBox.put(task.id, task);
      }
    }
    await _categoriesBox.delete(categoryId);
  }

  CategoryModel? getCategoryById(String categoryId, String userId) {
    final category = _categoriesBox.get(categoryId);
    if (category != null && category.userId == userId) {
      return category;
    }
    return null;
  }
}