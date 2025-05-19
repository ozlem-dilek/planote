import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common_widgets/custom_tab_chip_bar.dart';

// Örnek veri yapıları TODO:(Provider ve Hive ile değiştirilecek)
class Category {
  final String id;
  final String name;
  final Color color;

  Category({required this.id, required this.name, required this.color});
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String categoryId;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.categoryId,
    required this.dueDate,
  });
}

class GorevlerEkrani extends StatefulWidget {
  const GorevlerEkrani({super.key});

  @override
  State<GorevlerEkrani> createState() => _GorevlerEkraniState();
}

class _GorevlerEkraniState extends State<GorevlerEkrani> {
  // TODO: Bu veriler Provider ve Servis Katmanı ile Hive'dan gelecek
  final List<Category> _categories = [
    Category(id: 'all', name: 'Tümü', color: Colors.grey),
    Category(id: 'work', name: 'Work', color: AppColors.primaryDark),
    Category(id: 'personal', name: 'Personal', color: Colors.orange),
    Category(id: 'shopping', name: 'Shopping', color: Colors.lightBlue),
    // TODO: Kullanıcının eklediği kategoriler buraya gelecek
  ];

  String _selectedCategoryId = 'all'; // Başlangıçta "Tümü" seçili

  // Örnek görevler TODO:(Tarih ve kategoriye göre filtrelenecek)
  final List<Task> _allTasks = [
    Task(id: '1', title: "Y-y-y-yess y'all", isCompleted: true, categoryId: 'work', dueDate: DateTime.now()),
    Task(id: '2', title: 'feelin', isCompleted: true, categoryId: 'personal', dueDate: DateTime.now().add(const Duration(hours: 1))),
    Task(id: '3', title: 'funky', isCompleted: false, categoryId: 'work', dueDate: DateTime.now().add(const Duration(hours: 2))),
    Task(id: '4', title: '**', isCompleted: false, categoryId: 'work', dueDate: DateTime.now().subtract(const Duration(days:1))), // Dünkü görev
    Task(id: '5', title: 'fresh', isCompleted: true, categoryId: 'shopping', dueDate: DateTime.now().add(const Duration(days: 2))),
    Task(id: '6', title: "y'all", isCompleted: true, categoryId: 'work', dueDate: DateTime.now().add(const Duration(days: 3))),
    Task(id: '7', title: '**', isCompleted: false, categoryId: 'personal', dueDate: DateTime.now().add(const Duration(days: 6))),
    Task(id: '8', title: '***', isCompleted: false, categoryId: 'shopping', dueDate: DateTime.now().add(const Duration(days:1))),
    Task(id: '9', title: '***', isCompleted: true, categoryId: 'personal', dueDate: DateTime.now().add(const Duration(days:8))), // Gelecek hafta dışı
  ];

  List<Task> _getFilteredTasks() {
    // TODO: Bu filtreleme mantığı Provider'da veya Service'de olacak
    List<Task> tasksToShow;
    if (_selectedCategoryId == 'all') {
      tasksToShow = _allTasks;
    } else {
      tasksToShow = _allTasks.where((task) => task.categoryId == _selectedCategoryId).toList();
    }
    return tasksToShow;
  }

  List<Task> _getTodaysTasks(List<Task> filteredTasks) {
    final now = DateTime.now();
    return filteredTasks.where((task) =>
    task.dueDate.year == now.year &&
        task.dueDate.month == now.month &&
        task.dueDate.day == now.day
    ).toList();
  }

  List<Task> _getUpcomingTasks(List<Task> filteredTasks) {
    final now = DateTime.now();
    final oneWeekFromNow = now.add(const Duration(days: 7));
    return filteredTasks.where((task) =>
    !DateUtils.isSameDay(task.dueDate, now) && // Bugünün görevlerini tekrar gösterme
        task.dueDate.isAfter(now) &&
        task.dueDate.isBefore(oneWeekFromNow)
    ).toList();
  }


  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final todaysTasks = _getTodaysTasks(filteredTasks);
    final upcomingTasks = _getUpcomingTasks(filteredTasks);

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
              Builder(
                  builder: (buttonContext) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.primaryText, size: 28),
                      onPressed: () => Scaffold.of(buttonContext).openDrawer(),
                      tooltip: 'Menüyü Aç',
                    );
                  }
              ),
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CustomTabChip(
                    label: category.name,
                    isSelected: _selectedCategoryId == category.id,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                      // TODO: Provider ile görev listesini yeniden yükle/filtrele
                    },
                    // CustomTabChip'e renk parametresi eklenebilir
                    // backgroundColor: category.color.withOpacity(0.2),
                    // selectedColor: category.color,
                  ),
                );
              },
            ),
          ),
        ),

        Expanded(
          child: Container(
            color: AppColors.screenBackground,
            child: ListView( // Ana kaydırma
              padding: const EdgeInsets.all(16.0),
              children: [
                if (todaysTasks.isNotEmpty)
                  _buildTaskGroup(context, "Bugünkü Görevler", todaysTasks),
                if (upcomingTasks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildTaskGroup(context, "Yaklaşan Görevler (1 Hafta)", upcomingTasks),
                ],
                if (todaysTasks.isEmpty && upcomingTasks.isEmpty && _selectedCategoryId != 'all')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: Text("Bu kategoride gösterilecek görev yok.", style: TextStyle(color: AppColors.secondaryText))),
                  ),
                if (todaysTasks.isEmpty && upcomingTasks.isEmpty && _selectedCategoryId == 'all')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: Text("Harika! Hiç göreviniz yok gibi görünüyor.", style: TextStyle(color: AppColors.secondaryText))),
                  ),
                // TODO: "Tüm Görevler" veya "Diğer Görevler" gibi ek gruplar olabilir
              ],
            ),
          ),
        ),
        // TODO: FloatingActionButton AppShell seviyesinde veya sayfa bazlı eklenebilir.
        // Şimdilik FAB eklemiyorum, onu AppShell'e eklemek daha merkezi olabilir.
      ],
    );
  }

  Widget _buildTaskGroup(BuildContext context, String title, List<Task> tasks) {
    return Card(
      elevation: 1.0, // Hafif gölge
      margin: const EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                    fontSize: 18
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final categoryColor = _categories.firstWhere(
                        (cat) => cat.id == task.categoryId,
                    orElse: () => Category(id: 'unknown', name: 'Unknown', color: Colors.grey)
                ).color;

                return _buildTaskItem(context, task, categoryColor);
              },
              separatorBuilder: (context, index) => const Divider(height: 12, color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, Color categoryColor) {
    return InkWell(
      onTap: () {
        // TODO: Görev detayını göster / düzenle
        print("Görev tıklandı: ${task.title}");
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: categoryColor, width: 1.5)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryText.withOpacity(0.85),
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  // Bu sadece UI'da değiştirir, Todo: Provider ve Hive'a kaydedilmeli
                  final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      isCompleted: !task.isCompleted,
                      categoryId: task.categoryId,
                      dueDate: task.dueDate);
                  int taskIndex = _allTasks.indexWhere((t) => t.id == task.id);
                  if (taskIndex != -1) {
                    _allTasks[taskIndex] = updatedTask;
                  }
                });
                // TODO: Provider -> taskProvider.toggleTaskCompletion(task);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
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
    );
  }
}