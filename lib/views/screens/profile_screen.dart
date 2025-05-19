import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  // TODO: Bu değerler Provider ile yönetilecek
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;
  String _userName = "Kullanıcı Adı"; // Placeholder
  String _userEmail = "kullanici@email.com"; // Placeholder

  @override
  Widget build(BuildContext context) {
    // TODO: Kullanıcı bilgilerini ve ayarları Provider'dan al
    // final authProvider = Provider.of<AuthProvider>(context);
    // final settingsProvider = Provider.of<SettingsProvider>(context);
    // _userName = authProvider.userName ?? "Kullanıcı Adı";
    // _userEmail = authProvider.userEmail ?? "kullanici@email.com";
    // _isDarkTheme = settingsProvider.isDarkMode;
    // _notificationsEnabled = settingsProvider.notificationsEnabled;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        title: const Text(
          'Profilim',
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primaryText),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // AppShell'in Drawer'ını açar
              },
              tooltip: 'Menüyü Aç',
            );
          },
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.edit_outlined, color: AppColors.primaryText),
        //     onPressed: () {
        //       // TODO: Profili düzenleme sayfasına git
        //       print("Profili Düzenle tıklandı");
        //     },
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProfileHeader(context, _userName, _userEmail),
            const SizedBox(height: 30),
            _buildSectionTitle(context, "Hesap Ayarları"),
            _buildProfileOptionTile(
              context: context,
              icon: Icons.edit_outlined,
              title: "Profili Düzenle",
              onTap: () {
                // TODO: Profili düzenleme sayfasına git
                print("Profili Düzenle tıklandı");
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profili düzenleme özelliği yakında!"))
                );
              },
            ),
            _buildProfileOptionTile(
              context: context,
              icon: Icons.lock_outline,
              title: "Şifre Değiştir",
              onTap: () {
                // TODO: Şifre değiştirme sayfasına/dialoguna git
                print("Şifre Değiştir tıklandı");
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Şifre değiştirme özelliği yakında!"))
                );
              },
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(context, "Uygulama Ayarları"),
            SwitchListTile(
              title: Text("Koyu Tema", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
              value: _isDarkTheme,
              onChanged: (bool value) {
                setState(() {
                  _isDarkTheme = value;
                });
                // TODO: settingsProvider.toggleTheme(value);
                print("Koyu Tema: $_isDarkTheme");
              },
              secondary: Icon(Icons.dark_mode_outlined, color: AppColors.secondaryText),
              activeColor: AppColors.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            SwitchListTile(
              title: Text("Bildirimler", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                // TODO: settingsProvider.toggleNotifications(value);
                print("Bildirimler: $_notificationsEnabled");
              },
              secondary: Icon(Icons.notifications_active_outlined, color: AppColors.secondaryText),
              activeColor: AppColors.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Çıkış Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.8),
                  foregroundColor: AppColors.whiteText,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () {
                  // TODO: Drawer'daki ile aynı logout fonksiyonunu çağır
                  // context.read<AuthProvider>().logout();
                  // Veya AppShell'e bir logout metodu ekleyip onu çağırabilirsiniz.
                  print("Profil sayfasından Çıkış Yap tıklandı");
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Çıkış yapma özelliği Drawer'da mevcut."))
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Icon(Icons.person_outline, size: 50, color: AppColors.primary),
          // TODO: Gerçek profil resmi için backgroundImage: NetworkImage(...) veya AssetImage(...)
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0), // ListTile'lar ile hizalamak için hafif sol padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondaryText, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildProfileOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card( // Daha belirgin olması için Card içine alabiliriz
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondaryText),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.secondaryText) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}