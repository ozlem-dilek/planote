import 'dart:io'; // File için
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class MyCommonDrawer extends StatelessWidget {
  final Function(int) onPageSelected;

  const MyCommonDrawer({super.key, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final UserModel? currentUser = authProvider.currentUser;

    final String userName = currentUser?.username ?? "Kullanıcı";
    final String userEmail = currentUser?.email ?? "";
    final String? profileImagePath = currentUser?.profileImagePath;

    Widget avatarChild;
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.file(
          File(profileImagePath),
          fit: BoxFit.cover,
          width: 60,
          height: 60,
        ),
      );
    } else {
      avatarChild = const Icon(
        Icons.person,
        size: 40,
        color: AppColors.primaryDark,
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accent,
                  child: avatarChild,
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.whiteText,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (userEmail.isNotEmpty)
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.whiteText.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.checklist_rtl_outlined,
              color: AppColors.primaryText,
            ),
            title: Text(
              'Görevler',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryText,
            ),
            title: Text('Takvim', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.bar_chart_outlined,
              color: AppColors.primaryText,
            ),
            title: Text(
              'İstatistikler',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: AppColors.primaryText,
            ),
            title: Text('Profil', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              onPageSelected(3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.primaryText,
            ),
            title: Text(
              'Hakkında',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Planote App',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.flutter_dash,
                  size: 48,
                  color: AppColors.primary,
                ),
                applicationLegalese: '© 2025 Planote',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Çıkış Yap',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }
}
