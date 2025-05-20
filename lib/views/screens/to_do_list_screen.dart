import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../common_widgets/custom_tab_chip_bar.dart';
import '../../models/category_model.dart';
import '../../models/task_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (taskProvider.filteredTasks.isEmpty && !taskProvider.isLoading) {
        taskProvider.loadTasksForCategory(taskProvider.selectedCategoryId);
      }
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading) {
        categoryProvider.loadCategories();
      }
    });
  }

  Widget _buildCategoryChips(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final taskProvider = context.watch<TaskProvider>();

    if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
      return const SizedBox(
        height: 42,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (categoryProvider.error != null && categoryProvider.categories.isEmpty) {
      return SizedBox(
        height: 42,
        child: Center(child: Text("Kategoriler yüklenemedi", style: TextStyle(color: AppColors.error))),
      );
    }

    List<Widget> chips = [];

    chips.add(
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CustomTabChip(
          label: "Tümü",
          isSelected: taskProvider.selectedCategoryId == 'all',
          onTap: () {
            context.read<TaskProvider>().loadTasksForCategory('all');
          },
          activeCategoryColor: taskProvider.selectedCategoryId == 'all' ? AppColors.primary : null,
        ),
      ),
    );

    for (var category in categoryProvider.categories) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CustomTabChip(
            label: category.name,
            isSelected: taskProvider.selectedCategoryId == category.id,
            onTap: () {
              context.read<TaskProvider>().loadTasksForCategory(category.id);
            },
            activeCategoryColor: Color(category.colorValue),
          ),
        ),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: chips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final List<TaskModel> todaysTasks = taskProvider.todaysTasks;
    final List<TaskModel> upcomingTasks = taskProvider.upcomingTasks;
    final List<TaskModel> otherPendingTasks = taskProvider.otherTasks;
    final bool allTaskListsEmpty = todaysTasks.isEmpty && upcomingTasks.isEmpty && otherPendingTasks.isEmpty;

    return Column(
      children: [
        Container(
          color: AppColors.todoAppBarBackground,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 4,
            right: 16,
            bottom: 10,
          ),
          child: Row(
            children: [
              Builder(builder: (buttonContext) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primaryText, size: 28),
                  onPressed: () => Scaffold.of(buttonContext).openDrawer(),
                  tooltip: 'Menüyü Aç',
                );
              }),
              const Text(
                'To-Do List',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        Container(
          color: AppColors.todoAppBarBackground,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: _buildCategoryChips(context),
        ),
        Expanded(
          child: Container(
            color: AppColors.screenBackground,
            child: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskProvider.error != null
                ? Center(child: Text("Hata: ${taskProvider.error}", style: const TextStyle(color: AppColors.error)))
                : (allTaskListsEmpty
                ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    taskProvider.selectedCategoryId == 'all'
                        ? "Harika! Hiç göreviniz yok gibi görünüyor."
                        : "Bu kategoride gösterilecek görev yok.",
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
            )
                : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (todaysTasks.isNotEmpty)
                  _buildTaskGroup(context, "Bugünkü Görevler", todaysTasks, categoryProvider),
                if (upcomingTasks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildTaskGroup(context, "Yaklaşan Görevler (1 Hafta)", upcomingTasks, categoryProvider),
                ],
                if (otherPendingTasks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildTaskGroup(context, "Diğer Bekleyen Görevler", otherPendingTasks, categoryProvider),
                ]
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskGroup(BuildContext context, String title, List<TaskModel> tasks, CategoryProvider categoryProvider) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text("Bu grupta görev yok.", style: TextStyle(color: AppColors.secondaryText)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final category = categoryProvider.getCategoryById(task.categoryId);
                  final categoryColor = category != null ? Color(category.colorValue) : AppColors.disabled;

                  bool isDueSoon = task.endDateTime != null &&
                      !task.isCompleted &&
                      task.endDateTime!.isAfter(DateTime.now().subtract(const Duration(days:1))) &&
                      task.endDateTime!.isBefore(DateTime.now().add(const Duration(days: 2)));

                  return _buildTaskItem(context, task, categoryColor, isDueSoon);
                },
                separatorBuilder: (context, index) => const Divider(height: 10, color: Colors.transparent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, Color categoryColor, bool isDueSoon) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${task.title} silindi."),
          ),
        );
      },
      background: Container(
        color: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: () {
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: categoryColor, width: 1.5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryText,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: AppColors.secondaryText,
                      ),
                    ),
                    if (task.endDateTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          DateFormat('dd MMM, HH:mm', 'tr_TR').format(task.endDateTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDueSoon && !task.isCompleted ? AppColors.error : AppColors.secondaryText,
                            fontWeight: isDueSoon && !task.isCompleted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isDueSoon && !task.isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.warning_amber_rounded, color: AppColors.error.withOpacity(0.8), size: 20),
                ),
              InkWell(
                onTap: () {
                  context.read<TaskProvider>().toggleTaskCompletion(task.id);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: task.isCompleted ? AppColors.primary : AppColors.secondaryText.withOpacity(0.5),
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}