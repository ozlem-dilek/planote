import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../common_widgets/custom_tab_chip_bar.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/task_model.dart';
import '../../models/category_model.dart';
import 'edit_task_screen.dart';
import 'add_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedChipIndex = 1;
  final List<String> _chipLabels = ["Görevlerim"];

  String _getDayName(int weekday, {String locale = 'tr'}) {
    if (locale == 'tr') {
      const days = ["", "PZT", "SAL", "ÇAR", "PER", "CUM", "CMT", "PAZ"];
      if (weekday >= 1 && weekday <= 7) return days[weekday];
      return "";
    }
    const days = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    if (weekday == 7) return "Sun";
    if (weekday >= 1 && weekday <= 6) return days[weekday];
    return "";
  }

  String _getMonthName(int month, {String locale = 'tr'}) {
    if (locale == 'tr') {
      const monthNames = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
      if (month >= 1 && month <= 12) return monthNames[month];
      return "";
    }
    const monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    if (month >= 1 && month <= 12) return monthNames[month];
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final DateTime focusedDay = calendarProvider.focusedDay;
    final DateTime selectedDay = calendarProvider.selectedDay;
    final ThemeData theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopHeaderSection(context, focusedDay, theme),
            _buildCalendarGrid(context, focusedDay, selectedDay, theme),
            _WavyDecorationSection(theme: theme),
            _buildEventsListSection(context, calendarProvider.tasksForSelectedDay, calendarProvider.isLoadingTasks, calendarProvider.errorLoadingTasks, theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderSection(BuildContext context, DateTime focusedDayForDisplay, ThemeData theme) {
    final calendarProvider = context.read<CalendarProvider>();
    String currentMonthYear = "${_getMonthName(focusedDayForDisplay.month, locale: 'tr')} ${focusedDayForDisplay.year}";
    String dayName = "";
    try {
      dayName = DateFormat('EEEE', 'tr_TR').format(focusedDayForDisplay);
      dayName = dayName[0].toUpperCase() + dayName.substring(1);
    } catch (e) {
      dayName = "Takvim";
    }
    String title = dayName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onBackground,
                        height: 1.1,
                        fontSize: 26
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: currentMonthYear, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline_rounded, size: 28, color: theme.colorScheme.primary),
                    tooltip: 'Yeni Görev Ekle',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(
                            preSelectedDate: calendarProvider.selectedDay,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 34, color: theme.iconTheme.color?.withOpacity(0.7)),
                    tooltip: 'Önceki Ay',
                    onPressed: () => calendarProvider.changeFocusedDay(DateTime(focusedDayForDisplay.year, focusedDayForDisplay.month - 1, 1)),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 34, color: theme.iconTheme.color?.withOpacity(0.7)),
                    tooltip: 'Sonraki Ay',
                    onPressed: () => calendarProvider.changeFocusedDay(DateTime(focusedDayForDisplay.year, focusedDayForDisplay.month + 1, 1)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _chipLabels.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CustomTabChip(
                      label: _chipLabels[index],
                      isSelected: _selectedChipIndex == index,
                      onTap: () {
                        setState(() { _selectedChipIndex = index; });
                        // TODO: Bu chiplerin işlevselliğini Provider ile bağla (ilerleyen süreçte)
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime focusedDayForGrid, DateTime currentSelectedDay, ThemeData theme) {
    final calendarProvider = context.watch<CalendarProvider>();
    final List<String> dayAbbreviations = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    final firstDayOfMonth = DateTime(focusedDayForGrid.year, focusedDayForGrid.month, 1);
    final daysInMonth = DateTime(focusedDayForGrid.year, focusedDayForGrid.month + 1, 0).day;

    int startingDayOffset = firstDayOfMonth.weekday - 1;

    List<DateTime?> monthDays = List.generate(startingDayOffset, (_) => null);
    for (int i = 0; i < daysInMonth; i++) {
      monthDays.add(DateTime(focusedDayForGrid.year, focusedDayForGrid.month, i + 1));
    }
    int totalCells = 35;
    if (monthDays.length > 28 && startingDayOffset + daysInMonth > 35) {
      totalCells = 42;
    }
    if (monthDays.length < totalCells) {
      monthDays.addAll(List.generate(totalCells - monthDays.length, (_) => null));
    }
    if (monthDays.length > totalCells) {
      monthDays = monthDays.sublist(0, totalCells);
    }

    final markers = calendarProvider.monthlyTaskMarkers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayAbbreviations
                .map((day) => Text(day, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontWeight: FontWeight.w500, fontSize: 13)))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 0.85, crossAxisSpacing: 6, mainAxisSpacing: 6,
            ),
            itemCount: monthDays.length,
            itemBuilder: (context, index) {
              final day = monthDays[index];
              if (day == null) return Container();

              bool isSelected = DateUtils.isSameDay(day, currentSelectedDay);
              bool isToday = DateUtils.isSameDay(day, DateTime.now());

              final dayOnlyForMarker = DateTime(day.year, day.month, day.day);
              List<Color>? dayMarkers = markers[dayOnlyForMarker];

              return GestureDetector(
                onTap: () => context.read<CalendarProvider>().selectDay(day, day),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.6), width: 1.5) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : (isToday ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color?.withOpacity(0.8)),
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      if (dayMarkers != null && dayMarkers.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayMarkers.take(3).map((color) => Container(
                            width: 5, height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1.2),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          )).toList(),
                        ),
                      ] else ... [
                        const SizedBox(height: 3 + 5),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsListSection(BuildContext context, List<TaskModel> tasks, bool isLoading, String? error, ThemeData theme) {
    final calendarProvider = context.read<CalendarProvider>();

    if (isLoading) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: CircularProgressIndicator(color: theme.colorScheme.primary)));
    }
    if (error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(error, style: TextStyle(color: theme.colorScheme.error))));
    }
    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        color: theme.brightness == Brightness.light
            ? AppColors.wavyGreenish.withOpacity(0.7)
            : AppColors.wavyGreenish.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        alignment: Alignment.center,
        child: Text("Bu gün için planlanmış görev yok.", style: theme.textTheme.bodyMedium),
      );
    }

    return Container(
      color: theme.brightness == Brightness.light
          ? AppColors.wavyGreenish.withOpacity(0.7)
          : AppColors.wavyGreenish.withOpacity(0.2),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          CategoryModel? category;
          if(task.categoryId.isNotEmpty) {
            category = context.read<CategoryProvider>().getCategoryById(task.categoryId);
          }
          final Color categoryColor = category != null ? Color(category.colorValue) : AppColors.disabled;

          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            elevation: theme.cardTheme.elevation,
            shape: theme.cardTheme.shape,
            color: theme.cardTheme.color,
            child: ListTile(
              leading: Container(width: 5, height: 40, color: categoryColor),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: task.isCompleted ? theme.textTheme.bodyMedium?.color : theme.textTheme.bodyLarge?.color,
                  fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
                ),
              ),
              subtitle: task.startDateTime != null || task.endDateTime != null
                  ? Text(
                "${task.startDateTime != null ? DateFormat('HH:mm', 'tr_TR').format(task.startDateTime!) : ''}${task.startDateTime != null && task.endDateTime != null ? ' - ' : ''}${task.endDateTime != null ? DateFormat('HH:mm', 'tr_TR').format(task.endDateTime!) : ''}".trim() == "-" ? DateFormat('dd MMM', 'tr_TR').format(task.endDateTime ?? task.startDateTime!) : "${task.startDateTime != null ? DateFormat('HH:mm', 'tr_TR').format(task.startDateTime!) : ''}${task.startDateTime != null && task.endDateTime != null ? ' - ' : ''}${task.endDateTime != null ? DateFormat('HH:mm', 'tr_TR').format(task.endDateTime!) : ''}",
                style: theme.textTheme.bodySmall,
              )
                  : null,
              trailing: IconButton(
                icon: Icon(
                  task.isCompleted ? Icons.check_box_outlined : Icons.check_box_outline_blank_rounded,
                  color: task.isCompleted ? theme.colorScheme.primary : theme.iconTheme.color?.withOpacity(0.7),
                ),
                onPressed: () {
                  calendarProvider.toggleTaskCompletionOnCalendar(task.id);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTaskScreen(taskToEdit: task),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _WavyDecorationSection extends StatelessWidget {
  final ThemeData theme;
  const _WavyDecorationSection({required this.theme});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: CustomPaint(
        painter: WavyLinePainter(
          waveColor1: theme.brightness == Brightness.light ? AppColors.wavyBlueish : AppColors.wavyBlueish.withOpacity(0.15),
          waveColor2: theme.brightness == Brightness.light ? AppColors.wavyGreenish.withOpacity(0.7) : AppColors.wavyGreenish.withOpacity(0.2),
        ),
      ),
    );
  }
}

class WavyLinePainter extends CustomPainter {
  final Color waveColor1;
  final Color waveColor2;
  WavyLinePainter({required this.waveColor1, required this.waveColor2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = waveColor1..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.05, size.width * 0.45, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = waveColor2..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.85, size.width * 0.55, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.80, size.height * 0.20, size.width, size.height * 0.40)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }
  @override
  bool shouldRepaint(covariant WavyLinePainter oldDelegate) =>
      oldDelegate.waveColor1 != waveColor1 || oldDelegate.waveColor2 != waveColor2;
}