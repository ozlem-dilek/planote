import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MyCommonDrawer extends StatelessWidget {
  final Function(int) onPageSelected;

  const MyCommonDrawer({super.key, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.person, size: 40, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kullanıcı Adı', // TODO: Dinamik kullanıcı adı
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.whiteText),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.checklist_rtl_outlined, color: AppColors.primaryText),
            title: Text('Görevler', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryText),
            title: Text('Takvim', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined, color: AppColors.primaryText),
            title: Text('İstatistikler', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primaryText),
            title: Text('Profil', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primaryText),
            title: Text('Hakkında', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(context: context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text('Çıkış Yap', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Çıkış yapma Provider/Servis çağrısı
              print('Çıkış yap tıklandı.');
            },
          ),
        ],
      ),
    );
  }
}