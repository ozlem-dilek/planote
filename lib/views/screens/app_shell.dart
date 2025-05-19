import 'package:flutter/material.dart';
import '../common_widgets/my_common_drawer.dart';
import '../common_widgets/my_custom_bottom_bar.dart';
import '../../core/constants/app_colors.dart';
import 'calendar_screen.dart';


//gerçek ekranlar yerine şimdilik placeholder page'leri kullanıyorum.
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 50, color: AppColors.secondaryText.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.secondaryText.withOpacity(0.8)))
        ]));
  }
}


class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0; // Varsayılan olarak ilk sayfa (Görevler)

  // MyCustomBottomBar için sayfa listesi - 4 ANA SAYFA
  static final List<Widget> _pages = <Widget>[
    const PlaceholderPage(title: 'Görevler Sayfası', icon: Icons.checklist_rtl_outlined), // İndeks 0
    const CalendarScreen(),
    const PlaceholderPage(title: 'İstatistikler Sayfası', icon: Icons.bar_chart_outlined),// İndeks 2
    const PlaceholderPage(title: 'Profil Sayfası', icon: Icons.person_outline),      // İndeks 3
  ];

  // MyCustomBottomBar için item tanımlamaları - 4 ANA SEKMEYE KARŞILIK GELENLER
  final List<CustomBottomBarItemData> _barItems = [
    CustomBottomBarItemData(iconData: Icons.checklist_rtl_outlined, label: "Görevler"),
    CustomBottomBarItemData(iconData: Icons.calendar_today_outlined, label: "Takvim"),
    CustomBottomBarItemData(iconData: Icons.bar_chart_outlined, label: "İstatistikler"),
    CustomBottomBarItemData(iconData: Icons.person_outline, label: "Profil"),
  ];

  void _onPageSelected(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }


  int _chipSelectedIndex = 0;
  final List<String> _chipLabels = ['Tümü', 'Bugün', 'Bu Hafta'];

  void _onChipTapped(int index) {
    setState(() {
      _chipSelectedIndex = index;
      print('Chip seçildi: ${_chipLabels[_chipSelectedIndex]}');
      // TODO: Görevler listesini filtrele
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? topSectionForTasks;
    if (_selectedIndex == 0) {
      topSectionForTasks = Container(
        padding: const EdgeInsets.all(8.0),
        color: AppColors.chipBarBackground,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: AppColors.primaryText),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _chipLabels.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(_chipLabels[i]),
                      selected: _chipSelectedIndex == i,
                      onSelected: (_) => _onChipTapped(i),
                      showCheckmark: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: (_selectedIndex != 0 && _selectedIndex != 1) // Görevler ve Takvim hariç AppBar
          ? AppBar(
        title: Text(_barItems[_selectedIndex].label ?? "Sayfa"),
      )
          : null,
      drawer: MyCommonDrawer(onPageSelected: _onPageSelected),
      body: SafeArea(
        bottom: false, // Custom bottom bar kendi safe area'sını yönetebilir veya padding alabilir
        child: Column(
          children: [
            if (_selectedIndex == 0 && topSectionForTasks != null)
              topSectionForTasks,
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyCustomBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onPageSelected,
        items: _barItems,
      ),
    );
  }
}