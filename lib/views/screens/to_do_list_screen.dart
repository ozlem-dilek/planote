import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../common_widgets/custom_tab_chip_bar.dart';
import '../../models/category_model.dart';
import '../../models/task_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_task_screen.dart';

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? currentUserId = authProvider.currentUser?.userId;

      if (currentUserId != null) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        if (taskProvider.filteredTasks.isEmpty && !taskProvider.isLoading) {
          taskProvider.loadTasksForCategory(currentUserId, taskProvider.selectedCategoryId);
        }

        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading) {
          categoryProvider.loadCategories();
        }
      }
    });
  }

  Widget _buildCategoryChips(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final authProvider = context.read<AuthProvider>();
    final String? currentUserId = authProvider.currentUser?.userId;

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
            if (currentUserId != null) {
              context.read<TaskProvider>().loadTasksForCategory(currentUserId, 'all');
            }
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
              if (currentUserId != null) {
                context.read<TaskProvider>().loadTasksForCategory(currentUserId, category.id);
              }
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

    final List<TaskModel> pastDueTasks = taskProvider.pastDueUncompletedTasks;
    final List<TaskModel> todaysTasks = taskProvider.todaysTasks;
    final List<TaskModel> upcomingTasks = taskProvider.upcomingTasks;
    final List<TaskModel> otherPendingTasks = taskProvider.otherTasks;
    final bool allTaskListsEmpty = pastDueTasks.isEmpty && todaysTasks.isEmpty && upcomingTasks.isEmpty && otherPendingTasks.isEmpty;

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
                'Görevler',
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
            child: taskProvider.isLoading && allTaskListsEmpty
                ? const Center(child: CircularProgressIndicator())
                : taskProvider.error != null
                ? Center(child: Text("Hata: ${taskProvider.error}", style: const TextStyle(color: AppColors.error)))
                : (allTaskListsEmpty && !taskProvider.isLoading
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
                if (pastDueTasks.isNotEmpty) ...[
                  _buildTaskGroup(context, "Geçmiş Görevler", pastDueTasks, categoryProvider),
                  const SizedBox(height: 20),
                ],
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
                    color: title == "Geçmiş Görevler" ? AppColors.error : AppColors.primaryText,
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

                  bool isPastDueTaskGroup = title == "Geçmiş Görevler";

                  return _buildTaskItem(context, task, categoryColor, isDueSoon, isPastDueTaskGroup);
                },
                separatorBuilder: (context, index) => const Divider(height: 10, color: Colors.transparent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task, Color categoryColor, bool isDueSoon, bool isPastDueTaskGroup) {
    final authProvider = context.read<AuthProvider>();
    final String? currentUserId = authProvider.currentUser?.userId;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.blue.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.edit_note_outlined,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(taskToEdit: task),
            ),
          );
          return false;
        } else if (direction == DismissDirection.endToStart) {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Görevi Sil'),
                content: Text('"${task.title}" adlı görevi silmek istediğinize emin misiniz?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('İptal'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                    child: const Text('Sil'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              );
            },
          );
          return confirm ?? false;
        }
        return false;
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          if(currentUserId != null) {
            Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
          }
        }
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(taskToEdit: task),
            ),
          );
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
                          DateFormat('dd MMM HH:mm', 'tr_TR').format(task.endDateTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: (isDueSoon || isPastDueTaskGroup) && !task.isCompleted ? AppColors.error : AppColors.secondaryText,
                            fontWeight: (isDueSoon || isPastDueTaskGroup) && !task.isCompleted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if ((isDueSoon || isPastDueTaskGroup) && !task.isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.warning_amber_rounded, color: AppColors.error.withOpacity(0.8), size: 20),
                ),
              InkWell(
                onTap: () {
                  if (currentUserId != null) {
                    context.read<TaskProvider>().toggleTaskCompletion(task.id);
                  }
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