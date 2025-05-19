import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common_widgets/custom_tab_chip_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedChipIndex = 1;
  final List<String> _chipLabels = ["Planning", "Calendar", "Snow/Gorev"];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  //TODO: Odaklanılan ayı değiştirmek için (Provider'a taşınacak)
  void _onMonthNavigate(bool previous) {
    setState(() {
      if (previous) {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      }
      // Odak değişince seçili günü de o ayın ilk günü yapabiliriz veya null yapabiliriz
      _selectedDay = _focusedDay;
      // TODO: Provider ile takvim verilerini yeniden yükle
    });
  }

  // TODO: Bir güne tıklandığında (Provider'a taşınacak)
  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
      _focusedDay = day; // Takvim o güne odaklansın
      // TODO: Provider ile seçili günün olaylarını yükle
    });
  }

  //TODO:  Bir çipe tıklandığında (Provider'a taşınacak)
  void _onChipSelected(int index) {
    setState(() {
      _selectedChipIndex = index;
      // TODO: Provider ile içeriği bu çipe göre filtrele
      print("Chip seçildi: ${_chipLabels[index]}");
    });
  }

  String _getDayName(int weekday, {String locale = 'en'}) {
    if (locale == 'tr') {
      const days = ["", "PZT", "SAL", "ÇAR", "PER", "CUM", "CMT", "PAZ"];
      return days[weekday];
    }
    const days = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    if (weekday == 7) return "Sun";
    return days[weekday];
  }


  @override
  Widget build(BuildContext context) {
    // Bu ekran AppShell içinde kullanılacağı için kendi Scaffold'u yok.
    // AppShell SafeArea'yı zaten sağlıyor.
    return Container(
      color: AppColors.screenBackground,
      child: Column(
        children: [
          _buildTopHeaderSection(context),
          _buildCalendarGrid(context),
          const _WavyDecorationSection(),
          _buildEventsListSection(context),
        ],
      ),
    );
  }

  Widget _buildTopHeaderSection(BuildContext context) {
    String currentMonthYear = "${_getMonthName(_focusedDay.month)} ${_focusedDay.year}";

    String dayAndTitle = "${_getDayName(_focusedDay.weekday, locale: 'en')} Calendar"; // Daha dinamik yapılabilir

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
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.calendarTitle,
                      height: 1.1,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '$dayAndTitle\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                      TextSpan(text: currentMonthYear, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: AppColors.secondaryText.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
              // Ay navigasyon okları
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 34, color: AppColors.secondaryText.withOpacity(0.7)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Önceki Ay',
                    onPressed: () => _onMonthNavigate(true),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 34, color: AppColors.secondaryText.withOpacity(0.7)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Sonraki Ay',
                    onPressed: () => _onMonthNavigate(false),
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
                    onTap: () => _onChipSelected(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final List<String> dayAbbreviations = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Takvim matrisi için günler (Bu mantık Provider/Service katmanında daha detaylı olmalı)
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    int startingDayOffset = firstDayOfMonth.weekday % 7;

    List<DateTime?> monthDays = List.generate(startingDayOffset, (_) => null);
    for (int i = 0; i < daysInMonth; i++) {
      monthDays.add(DateTime(_focusedDay.year, _focusedDay.month, i + 1));
    }
    int totalCells = 35; // Genellikle 5 hafta
    if (monthDays.length > 28 && startingDayOffset + daysInMonth > 35) {
      totalCells = 42;
    }
    if (monthDays.length < totalCells) {
      monthDays.addAll(List.generate(totalCells - monthDays.length, (_) => null));
    }
    if (monthDays.length > totalCells) {
      monthDays = monthDays.sublist(0, totalCells);
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayAbbreviations
                .map((day) => Text(day, style: TextStyle(color: AppColors.calendarDayText, fontWeight: FontWeight.w500, fontSize: 13)))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: monthDays.length,
            itemBuilder: (context, index) {
              final day = monthDays[index];
              if (day == null) return Container(); // Boş günler

              bool isSelected = _selectedDay != null && DateUtils.isSameDay(day, _selectedDay);
              bool isToday = DateUtils.isSameDay(day, DateTime.now());
              // TODO: Olayları olan günleri Provider'dan alıp işaretle

              return GestureDetector(
                onTap: () => _onDaySelected(day),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.calendarSelectedDayBackground : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isToday && !isSelected ? Border.all(color: AppColors.calendarTodayBorder.withOpacity(0.6), width: 1.5) : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : (isToday ? AppColors.calendarTodayBorder : AppColors.primaryText.withOpacity(0.8)),
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsListSection(BuildContext context) {
    // TODO: Seçili güne ait olaylar Provider ile Hive'dan çekilip burada listelenecek
    return Expanded(
      child: Container(
        width: double.infinity,

        color: AppColors.wavyGreenish.withOpacity(0.7),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 10),
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    // İngilizce için:
    // const monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return monthNames[month];
  }
}

class _WavyDecorationSection extends StatelessWidget {
  const _WavyDecorationSection();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: CustomPaint(
        painter: WavyLinePainter(
          waveColor1: AppColors.wavyBlueish,
          waveColor2: AppColors.wavyGreenish.withOpacity(0.7),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
                top: -8,
                left: MediaQuery.of(context).size.width * 0.22,
                child: Icon(Icons.ac_unit, color: AppColors.wavyBlueish.withOpacity(0.9), size: 18)),
            Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width * 0.32,
                child: Icon(Icons.drag_handle_rounded, color: AppColors.wavyBlueish.withOpacity(0.9), size: 18)),
          ],
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