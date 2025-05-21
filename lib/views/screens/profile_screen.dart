import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
// import '../../providers/auth_provider.dart'; // TODO: Gerçek kullanıcı bilgileri için

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
// TODO: Gerçek kullanıcı bilgilerini AuthProvider'dan al
// final authProvider = Provider.of<AuthProvider>(context);
// final userName = authProvider.userName ?? "Misafir Kullanıcı";
// final userEmail = authProvider.userEmail ?? "email@example.com";
    const userName = "Özlem Dilek Acar";
    const userEmail = "ozlem.acar@example.com";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.screenBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Profil ve Ayarlar',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Menüyü Aç',
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildProfileHeader(context, userName, userEmail),
          const SizedBox(height: 24),
          _buildSectionTitle(context, "Genel Ayarlar"),
          Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
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
            ),
          ),
          _buildProfileOptionTile(
            context: context,
            icon: Icons.category_outlined,
            title: "Kategorileri Yönet",
            onTap: () {
              // TODO: Kategorileri yönetme ekranına git
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kategori yönetimi yakında!"))
              );
            },
          ),
          _buildProfileOptionTile(
            context: context,
            icon: Icons.notifications_none_outlined,
            title: "Bildirim Ayarları",
            onTap: () {
              // TODO: Bildirim ayarları ekranına git
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
              // TODO: Profili düzenleme ekranına git
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil düzenleme yakında!"))
              );
            },
          ),
          _buildProfileOptionTile(
            context: context,
            icon: Icons.logout,
            title: "Çıkış Yap",
            textColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () {
              // TODO: Drawer'daki ile aynı logout fonksiyonunu çağır
              // Provider.of<AuthProvider>(context, listen: false).logout().then((_){
              //   Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(builder: (context) => LoginScreen()), // LoginScreen'i import edin
              //     (Route<dynamic> route) => false,
              //   );
              // });
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Çıkış yapma özelliği Drawer'da mevcut."))
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
// TODO: Gerçek profil resmi için backgroundImage
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
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
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
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
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