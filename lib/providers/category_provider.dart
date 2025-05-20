import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider(this._categoryService) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = _categoryService.getAllCategories();
    } catch (e) {
      _error = "Kategoriler yüklenirken bir sorun oluştu.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewCategory({required String name, required Color color}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService.addNewCategory(name: name, colorValue: color.value);
      await loadCategories();
    } catch (e) {
      _error = "Yeni kategori eklenirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> attemptDeleteCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    Map<String, dynamic> result;
    try {
      result = await _categoryService.attemptDeleteCategory(categoryId);
      if (result['deleted'] == true) {
        await loadCategories();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = "Kategori silme denemesi sırasında bir hata oluştu.";
      result = {'deleted': false, 'taskCount': -1, 'message': _error!};
      _isLoading = false;
      notifyListeners();
    }
    return result;
  }

  Future<void> deleteCategoryConfirmed(String categoryId, {String defaultCategoryIdForTasks = 'other'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService.deleteCategoryConfirmed(categoryId, defaultCategoryId: defaultCategoryIdForTasks);
      await loadCategories();
    } catch (e) {
      _error = "Kategori onay sonrası silinirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService.updateCategory(category);
      await loadCategories();
    } catch (e) {
      _error = "Kategori güncellenirken bir sorun oluştu: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  CategoryModel? getCategoryById(String categoryId) {
    return _categoryService.getCategoryById(categoryId);
  }
}