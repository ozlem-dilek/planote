import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;
  final AuthProvider _authProvider;

  String? get _currentUserId => _authProvider.currentUser?.userId;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider(this._categoryService, this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _loadInitialDataOrClear();
  }

  void _onAuthStateChanged() {
    _loadInitialDataOrClear();
  }

  void _loadInitialDataOrClear() {
    if (_currentUserId != null) {
      loadCategories();
    } else {
      _categories = [];
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<void> loadCategories() async {
    if (_currentUserId == null) {
      _categories = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _categoryService.addDefaultCategoriesForUser(_currentUserId!);
      _categories = _categoryService.getAllCategoriesForUser(_currentUserId!);
    } catch (e) {
      _error = "Kategoriler yüklenirken bir sorun oluştu.";
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewCategory({required String name, required Color color}) async {
    if (_currentUserId == null) {
      _error = "Kategori eklemek için giriş yapmalısınız.";
      notifyListeners();
      throw Exception(_error);
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService.addNewCategory(name: name, colorValue: color.value, userId: _currentUserId!);
      await loadCategories();
    } catch (e) {
      _error = "Yeni kategori eklenirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<Map<String, dynamic>> attemptDeleteCategory(String categoryId) async {
    if (_currentUserId == null) {
      return {'deleted': false, 'taskCount': 0, 'message': 'Giriş yapmalısınız.'};
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    Map<String, dynamic> result;
    try {
      result = await _categoryService.attemptDeleteCategory(categoryId, _currentUserId!);
      if (result['deleted'] == true) {
        await loadCategories();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = "Kategori silinirken bir sorun oluştu.";
      result = {'deleted': false, 'taskCount': -1, 'message': _error!};
      _isLoading = false;
      notifyListeners();
    }
    return result;
  }

  Future<void> deleteCategoryConfirmed(String categoryId, {String defaultCategoryIdPrefix = 'other_'}) async {
    if (_currentUserId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService.deleteCategoryConfirmed(categoryId, _currentUserId!, defaultCategoryIdPrefix: defaultCategoryIdPrefix);
      await loadCategories();
    } catch (e) {
      _error = "Kategori onay sonrası silinirken bir sorun oluştu.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (_currentUserId == null || category.userId != _currentUserId) {
      _error = "Bu kategoriyi güncelleme yetkiniz yok.";
      notifyListeners();
      throw Exception(_error);
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _categoryService.updateCategory(category, _currentUserId!);
      await loadCategories();
    } catch (e) {
      _error = "Kategori güncellenirken bir sorun oluştu: $e";
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  CategoryModel? getCategoryById(String categoryId) {
    if (_currentUserId == null) return null;
    return _categoryService.getCategoryById(categoryId, _currentUserId!);
  }
}