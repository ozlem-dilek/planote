import 'package:flutter/material.dart';
import '../common_widgets/my_common_drawer.dart';
import '../common_widgets/my_custom_bottom_bar.dart';
import 'calendar_screen.dart';
import 'to_do_list_screen.dart';
import 'stat_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const TodoListScreen(),
    const CalendarScreen(),
    const IstatistiklerEkrani(),
    const ProfilEkrani()
  ];

  final List<CustomBottomBarItemData> _barItems = [
    CustomBottomBarItemData(iconData: Icons.checklist_rtl_outlined, label: "Görevler", hasLabel: true),
    CustomBottomBarItemData(iconData: Icons.calendar_today_outlined, label: "Takvim", hasLabel: true),
    CustomBottomBarItemData(iconData: Icons.bar_chart_outlined, label: "İstatistikler", hasLabel: true),
    CustomBottomBarItemData(iconData: Icons.person_outline, label: "Profil", hasLabel: true),
  ];

  void _onPageSelected(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyCommonDrawer(onPageSelected: _onPageSelected),

      appBar: null,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
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