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
    _addDefaultCategoriesIfEmpty();
  }

  Future<void> _addDefaultCategoriesIfEmpty() async {
    if (_categoriesBox.isEmpty) {
      print("CategoryService: Varsayılan kategoriler ekleniyor...");
      final defaultCategories = [
        CategoryModel(id: 'work', name: 'İş', colorValue: Colors.blue.value),
        CategoryModel(id: 'personal', name: 'Kişisel', colorValue: Colors.green.value),
        CategoryModel(id: 'shopping', name: 'Alışveriş', colorValue: Colors.orange.value),
        CategoryModel(id: 'other', name: 'Diğer', colorValue: Colors.grey.value),
      ];
      for (var category in defaultCategories) {
        await _categoriesBox.put(category.id, category);
      }
      print("CategoryService: Default kategoriler eklendi.");
    }
  }

  List<CategoryModel> getAllCategories() {
    final categories = _categoriesBox.values.toList();
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  Future<CategoryModel> addNewCategory({required String name, required int colorValue}) async {
    final String newId = _uuid.v4();
    final newCategory = CategoryModel(
      id: newId,
      name: name,
      colorValue: colorValue,
    );
    await _categoriesBox.put(newCategory.id, newCategory);
    return newCategory;
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (_categoriesBox.containsKey(category.id)) {
      await _categoriesBox.put(category.id, category);
    }
  }


  Future<Map<String, dynamic>> attemptDeleteCategory(String categoryId) async {
    int associatedTaskCount = 0;
    for (final task in _tasksBox.values) {
      if (task.categoryId == categoryId) {
        associatedTaskCount++;
      }
    }

    if (associatedTaskCount > 0) {
      print("CategoryService: Kategori ID $categoryId, $associatedTaskCount görevle ilişkili. Silme işlemi için onay bekleniyor.");
      return {
        'deleted': false,
        'taskCount': associatedTaskCount,
        'message': 'Bu kategoride $associatedTaskCount adet görev var. Yine de silmek istiyor musunuz?'
      };
    } else {

      await _categoriesBox.delete(categoryId);
      print("CategoryService: Kategori (ilişkili görev yoktu) silindi: ID $categoryId");
      return {'deleted': true, 'taskCount': 0, 'message': 'Kategori başarıyla silindi.'};
    }
  }



  Future<void> deleteCategoryConfirmed(String categoryId, {String defaultCategoryId = 'other'}) async {

    if (!_categoriesBox.containsKey(defaultCategoryId) && defaultCategoryId == 'other') {
      await addNewCategory(name: 'Diğer', colorValue: Colors.grey.value);
    }

    List<TaskModel> tasksToUpdate = _tasksBox.values.where((task) => task.categoryId == categoryId).toList();
    for (TaskModel task in tasksToUpdate) {
      if (task.isInBox) {
        task.categoryId = defaultCategoryId;
        await task.save();
        print("CategoryService: Görev '${task.title}' ID'si '$defaultCategoryId' kategorisine taşındı.");
      } else {
        final taskFromBox = _tasksBox.get(task.id);
        if(taskFromBox != null){
          taskFromBox.categoryId = defaultCategoryId;
          await _tasksBox.put(taskFromBox.id, taskFromBox);
          print("CategoryService: Görev '${taskFromBox.title}' ID'si '$defaultCategoryId' kategorisine taşındı.");
        }
      }
    }


    List<TaskModel> tasksToDelete = _tasksBox.values.where((task) => task.categoryId == categoryId).toList();
    for (TaskModel task in tasksToDelete) {
      if (task.isInBox) {
        await task.delete();
      } else {
        await _tasksBox.delete(task.id);
      }
    }
    print("CategoryService: $categoryId kategorisindeki ${tasksToDelete.length} görev de silindi.");


    await _categoriesBox.delete(categoryId);
    print("CategoryService: Kategori (kullanıcı onayı sonrası) silindi: ID $categoryId");
  }


  CategoryModel? getCategoryById(String categoryId) {
    return _categoriesBox.get(categoryId);
  }
}