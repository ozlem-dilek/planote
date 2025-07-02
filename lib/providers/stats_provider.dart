import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import '../../core/constants/app_colors.dart';
import 'auth_provider.dart';


class StatsProvider extends ChangeNotifier {
  final TaskService _taskService;
  final CategoryService _categoryService;
  final AuthProvider _authProvider;

  String? get _currentUserId => _authProvider.currentUser?.userId;

  bool _isLoading = false;
  String? _error;

  List<PieChartSectionData> _completionRateSections = [];
  int _totalTasks = 0;
  int _completedTasks = 0;

  List<BarChartGroupData> _tasksByCategoryGroups = [];
  List<CategoryModel> _allCategoriesForChartTitles = [];

  List<BarChartGroupData> _weeklyActivityGroups = [];
  final List<String> _last7DaysLabels = [];

  List<FlSpot> _monthlyCompletionSpots = [];
  final List<String> _last6MonthsLabels = [];
  double _maxMonthlyCompletedTasks = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PieChartSectionData> get completionRateSections => _completionRateSections;
  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;
  List<BarChartGroupData> get tasksByCategoryGroups => _tasksByCategoryGroups;
  List<CategoryModel> get allCategoriesForChartTitles => _allCategoriesForChartTitles;
  List<BarChartGroupData> get weeklyActivityGroups => _weeklyActivityGroups;
  List<String> get last7DaysLabels => _last7DaysLabels;
  List<FlSpot> get monthlyCompletionSpots => _monthlyCompletionSpots;
  List<String> get last6MonthsLabels => _last6MonthsLabels;
  double get maxMonthlyCompletedTasks => _maxMonthlyCompletedTasks;


  StatsProvider(this._taskService, this._categoryService, this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _loadInitialDataOrClear();
  }

  void _onAuthStateChanged() {
    _loadInitialDataOrClear();
  }

  void _loadInitialDataOrClear() {
    if (_currentUserId != null) {
      fetchAllStats();
    } else {
      _isLoading = false;
      _error = null;
      _completionRateSections = [];
      _totalTasks = 0;
      _completedTasks = 0;
      _tasksByCategoryGroups = [];
      _allCategoriesForChartTitles = [];
      _weeklyActivityGroups = [];
      _last7DaysLabels.clear();
      _monthlyCompletionSpots = [];
      _last6MonthsLabels.clear();
      _maxMonthlyCompletedTasks = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }


  Future<void> fetchAllStats() async {
    if (_currentUserId == null) {
      _isLoading = false;
      _error = "İstatistikleri görmek için giriş yapmalısınız.";
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allTasks = _taskService.getAllTasksForUser(_currentUserId!);
      final userCategories = _categoryService.getAllCategoriesForUser(_currentUserId!);

      _prepareCompletionRateStats(allTasks);
      _prepareTasksByCategoryStats(allTasks, userCategories);
      _prepareWeeklyActivityStats(allTasks);
      _prepareMonthlyCompletionStats(allTasks);

    } catch (e) {
      _error = "İstatistikler yüklenirken bir sorun oluştu: $e";
      _completionRateSections = [];
      _tasksByCategoryGroups = [];
      _allCategoriesForChartTitles = [];
      _weeklyActivityGroups = [];
      _last7DaysLabels.clear();
      _monthlyCompletionSpots = [];
      _last6MonthsLabels.clear();
      _maxMonthlyCompletedTasks = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _prepareCompletionRateStats(List<TaskModel> tasks) {
    _totalTasks = tasks.length;
    _completedTasks = tasks.where((task) => task.isCompleted).length;
    int uncompletedTasks = _totalTasks - _completedTasks;

    _completionRateSections = [];
    if (_totalTasks > 0) {
      if (_completedTasks > 0) {
        _completionRateSections.add(PieChartSectionData(
          value: _completedTasks.toDouble(),
          title: '${(_completedTasks / _totalTasks * 100).toStringAsFixed(0)}%',
          color: AppColors.primary,
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.whiteText),
        ));
      }
      if (uncompletedTasks > 0) {
        _completionRateSections.add(PieChartSectionData(
          value: uncompletedTasks.toDouble(),
          title: '${(uncompletedTasks / _totalTasks * 100).toStringAsFixed(0)}%',
          color: AppColors.disabled.withOpacity(0.5),
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ));
      }
      if (_completionRateSections.isEmpty && _totalTasks > 0) {
        _completionRateSections.add(PieChartSectionData(
          value: _totalTasks.toDouble(),
          title: _completedTasks == _totalTasks ? '100%' : '0%',
          color: _completedTasks == _totalTasks ? AppColors.primary : AppColors.disabled.withOpacity(0.5),
          radius: 50,
          titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _completedTasks == _totalTasks ? AppColors.whiteText : AppColors.primaryText),
        ));
      }
    }

    if (_totalTasks == 0) {
      _completionRateSections.add(PieChartSectionData(
        value: 1,
        title: 'Veri Yok',
        color: Colors.grey.shade300,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
      ));
    }
  }

  void _prepareTasksByCategoryStats(List<TaskModel> tasks, List<CategoryModel> categories) {
    Map<String, int> tasksCountMap = {};
    if (_currentUserId == null) return;

    for (var category in categories) {
      tasksCountMap[category.id] = 0;
    }
    for (var task in tasks) {
      if(tasksCountMap.containsKey(task.categoryId)) {
        tasksCountMap[task.categoryId] = tasksCountMap[task.categoryId]! + 1;
      } else {
        tasksCountMap['other_${_currentUserId!}'] = (tasksCountMap['other_${_currentUserId!}'] ?? 0) + 1;
      }
    }

    _tasksByCategoryGroups = [];
    int i = 0;
    List<CategoryModel> categoriesWithData = [];

    categories.forEach((category) {
      final taskCount = tasksCountMap[category.id] ?? 0;
      if (taskCount > 0) {
        _tasksByCategoryGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: taskCount.toDouble(),
                color: Color(category.colorValue),
                width: 16,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ],
          ),
        );
        categoriesWithData.add(category);
        i++;
      }
    });

    String otherCategoryKey = 'other_${_currentUserId!}';
    if (tasksCountMap.containsKey(otherCategoryKey) && (tasksCountMap[otherCategoryKey] ?? 0) > 0) {
      _tasksByCategoryGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (tasksCountMap[otherCategoryKey]!).toDouble(),
              color: AppColors.disabled,
              width: 16,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        ),
      );
      categoriesWithData.add(CategoryModel(id: otherCategoryKey, name: 'Diğer', colorValue: AppColors.disabled.value, userId: _currentUserId!));
      i++;
    }
    _allCategoriesForChartTitles = categoriesWithData;
  }

  void _prepareWeeklyActivityStats(List<TaskModel> allTasks) {
    _weeklyActivityGroups = [];
    _last7DaysLabels.clear();
    final now = DateTime.now();
    Map<int, double> dailyCompletedTasks = {};

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      _last7DaysLabels.add(DateFormat('E', 'tr_TR').format(day));
      dailyCompletedTasks[6 - i] = 0;
    }
    _last7DaysLabels.setAll(0, _last7DaysLabels.reversed);

    for (var task in allTasks) {
      if (task.isCompleted && task.completedAt != null) {
        for (int i = 0; i < 7; i++) {
          final referenceDay = now.subtract(Duration(days: i));
          if (DateUtils.isSameDay(task.completedAt, referenceDay)) {
            dailyCompletedTasks[6-i] = (dailyCompletedTasks[6-i] ?? 0) + 1;
            break;
          }
        }
      }
    }

    dailyCompletedTasks.forEach((dayIndex, count) {
      _weeklyActivityGroups.add(
        BarChartGroupData(
          x: dayIndex,
          barRods: [
            BarChartRodData(
              toY: count,
              color: AppColors.primary.withOpacity(0.7),
              width: 14,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        ),
      );
    });
    if (_weeklyActivityGroups.isNotEmpty) {
      _weeklyActivityGroups.sort((a,b) => a.x.compareTo(b.x));
    }
  }

  void _prepareMonthlyCompletionStats(List<TaskModel> allTasks) {
    _monthlyCompletionSpots = [];
    _last6MonthsLabels.clear();
    _maxMonthlyCompletedTasks = 0;

    final now = DateTime.now();
    Map<int, double> monthlyCompletedCounts = {};

    for (int i = 0; i < 6; i++) {
      final targetMonthDateTime = DateTime(now.year, now.month - (5 - i), 1);
      _last6MonthsLabels.add(DateFormat('MMM', 'tr_TR').format(targetMonthDateTime));
      monthlyCompletedCounts[i] = 0;
    }

    for (var task in allTasks) {
      if (task.isCompleted && task.completedAt != null) {
        for (int i = 0; i < 6; i++) {
          final int monthOffset = 5 - i;
          final DateTime monthStart = DateTime(now.year, now.month - monthOffset, 1);
          final DateTime monthEnd = DateTime(now.year, now.month - monthOffset + 1, 0, 23, 59, 59);

          if (task.completedAt!.isAfter(monthStart.subtract(const Duration(microseconds: 1))) &&
              task.completedAt!.isBefore(monthEnd.add(const Duration(microseconds: 1)))) {
            monthlyCompletedCounts[i] = (monthlyCompletedCounts[i] ?? 0) + 1;
            if (monthlyCompletedCounts[i]! > _maxMonthlyCompletedTasks) {
              _maxMonthlyCompletedTasks = monthlyCompletedCounts[i]!;
            }
            break;
          }
        }
      }
    }

    monthlyCompletedCounts.forEach((monthIndex, count) {
      _monthlyCompletionSpots.add(FlSpot(monthIndex.toDouble(), count));
    });

    if (_monthlyCompletionSpots.isEmpty && monthlyCompletedCounts.isNotEmpty) {
      for(int i=0; i < 6; i++) {
        _monthlyCompletionSpots.add(FlSpot(i.toDouble(),0));
      }
    }
    if (_monthlyCompletionSpots.isNotEmpty) {
      _monthlyCompletionSpots.sort((a,b) => a.x.compareTo(b.x));
    }
  }
}