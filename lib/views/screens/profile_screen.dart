import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'manage_categories_screen.dart';
import 'edit_profile_screen.dart';

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  Widget _buildProfileAppBar(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.screenBackground,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 4,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          Builder(
            builder: (BuildContext buttonContext) {
              return IconButton(
                icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color ?? AppColors.primaryText, size: 28),
                onPressed: () {
                  Scaffold.of(buttonContext).openDrawer();
                },
                tooltip: 'Menüyü Aç',
              );
            },
          ),
          Text(
            'Profil ve Ayarlar',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          const Spacer(),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = context.watch<AuthProvider>();
    final UserModel? currentUser = authProvider.currentUser;

    final String userName = currentUser?.username ?? "Kullanıcı";
    final String userEmail = currentUser?.email ?? "Email bilgisi yok";
    final String? profileImagePath = currentUser?.profileImagePath;

    return Column(
      children: [
        _buildProfileAppBar(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              _buildProfileHeader(context, userName, userEmail, profileImagePath),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Genel Ayarlar"),
              Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                color: Theme.of(context).cardColor,
                child: SwitchListTile(
                  title: Text("Koyu Mod", style: Theme.of(context).textTheme.titleMedium),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value);
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),
              _buildProfileOptionTile(
                context: context,
                icon: Icons.category_outlined,
                title: "Kategorileri Yönet",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
                  );
                },
              ),
              _buildProfileOptionTile(
                context: context,
                icon: Icons.notifications_none_outlined,
                title: "Bildirim Ayarları",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bildirim ayarları yakında!"))
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, "Hesap"),
              _buildProfileOptionTile(
                context: context,
                icon: Icons.edit_outlined,
                title: "Profili Düzenle",
                onTap: () {
                  if (currentUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(currentUser: currentUser)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Önce giriş yapmalısınız!"))
                    );
                  }
                },
              ),
              _buildProfileOptionTile(
                context: context,
                icon: Icons.logout,
                title: "Çıkış Yap",
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email, String? imagePath) {
    Widget imageWidget;
    if (imagePath != null && imagePath.isNotEmpty) {
      final File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        imageWidget = Image.file(imageFile, fit: BoxFit.cover, width: 90, height: 90);
      } else {
        imageWidget = Icon(
          Icons.person_rounded,
          size: 50,
          color: Theme.of(context).colorScheme.primary,
        );
      }
    } else {
      imageWidget = Icon(
        Icons.person_rounded,
        size: 50,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: ClipOval(child: imageWidget),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top:16.0, bottom: 8.0, left: 4.0),
      child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
    );
  }

  Widget _buildProfileOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation ?? 1.0,
      margin: Theme.of(context).cardTheme.margin ?? const EdgeInsets.symmetric(vertical: 4.0),
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color?.withOpacity(0.7)),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor)),
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}