import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  File? _selectedImageFile;
  String? _currentProfileImagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUser.username);
    _emailController = TextEditingController(text: widget.currentUser.email ?? "");
    _currentProfileImagePath = widget.currentUser.profileImagePath;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isDenied || status.isRestricted) {
      status = await permission.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İzin kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.')),
        );
        await openAppSettings();
      }
      return false;
    }
    return status.isGranted;
  }

  Future<void> _pickImage(ImageSource source) async {
    bool permissionGranted = false;
    if (source == ImageSource.camera) {
      permissionGranted = await _requestPermission(Permission.camera);
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permissionGranted = await _requestPermission(Permission.photos);
        } else {
          permissionGranted = await _requestPermission(Permission.storage);
        }
      } else {
        permissionGranted = await _requestPermission(Permission.photos);
      }
    }

    if (!permissionGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(source == ImageSource.camera ? 'Kamera izni gerekli.' : 'Galeriye erişim izni gerekli.')),
        );
      }
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 800);
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _currentProfileImagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilemedi: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bottomSheetTheme.modalBackgroundColor ?? theme.cardColor,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: theme.iconTheme.color),
                  title: Text('Galeriden Seç', style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  }),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: theme.iconTheme.color),
                title: Text('Kamera ile Çek', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImageFile != null || (_currentProfileImagePath != null && _currentProfileImagePath!.isNotEmpty))
                ListTile(
                  leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  title: Text('Fotoğrafı Kaldır', style: TextStyle(color: theme.colorScheme.error)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedImageFile = null;
                      _currentProfileImagePath = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? finalProfileImagePath = _currentProfileImagePath;

      if (_selectedImageFile != null) {
        try {
          final Directory appDir = await getApplicationDocumentsDirectory();
          final String fileName = p.basename(_selectedImageFile!.path);
          final String profilePicturesPath = p.join(appDir.path, 'profile_pictures');

          final profilePicDir = Directory(profilePicturesPath);
          if (!await profilePicDir.exists()) {
            await profilePicDir.create(recursive: true);
          }

          final String savedImagePath = p.join(profilePicturesPath, fileName);
          await _selectedImageFile!.copy(savedImagePath);
          finalProfileImagePath = savedImagePath;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profil fotoğrafı kaydedilirken hata: $e')),
            );
          }
          setState(() { _isLoading = false; });
          return;
        }
      } else if (_currentProfileImagePath == null && widget.currentUser.profileImagePath != null) {
        finalProfileImagePath = null;
        // TODO: Cihazdan eski dosyayı silme mantığı
      }

      String? currentPassword = _currentPasswordController.text.isNotEmpty ? _currentPasswordController.text : null;
      String? newPassword = _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null;

      bool success = await authProvider.updateUserProfile(
        newUsername: _usernameController.text.trim(),
        newEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newProfileImagePath: finalProfileImagePath,
      );

      if (!mounted) return;
      setState(() { _isLoading = false; });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Profil güncellenirken bir hata oluştu.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget profileImageWidget;
    if (_selectedImageFile != null) {
      profileImageWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
    } else if (_currentProfileImagePath != null && _currentProfileImagePath!.isNotEmpty) {
      final file = File(_currentProfileImagePath!);
      if (file.existsSync()) {
        profileImageWidget = Image.file(file, fit: BoxFit.cover);
      } else {
        profileImageWidget = Icon(Icons.person_rounded, size: 60, color: theme.colorScheme.primary.withOpacity(0.7));
      }
    } else {
      profileImageWidget = Icon(Icons.person_rounded, size: 60, color: theme.colorScheme.primary.withOpacity(0.7));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profili Düzenle', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        iconTheme: theme.appBarTheme.iconTheme,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(icon: const Icon(Icons.check_rounded), tooltip: 'Değişiklikleri Kaydet', onPressed: _saveProfileChanges),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: ClipOval(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: profileImageWidget,
                      ),
                    ),
                  ),
                  Material(
                    color: theme.colorScheme.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showImageSourceActionSheet(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt_outlined, color: AppColors.whiteText, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: _usernameController,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı', prefixIcon: Icon(Icons.person_outline_rounded, color: theme.inputDecorationTheme.prefixIconColor)),
              validator: (value) { if (value == null || value.trim().isEmpty) { return 'Lütfen kullanıcı adınızı girin.'; } if (value.trim().length < 3) { return 'Kullanıcı adı en az 3 karakter olmalıdır.'; } return null; },
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'E-posta (Opsiyonel)', prefixIcon: Icon(Icons.email_outlined, color: theme.inputDecorationTheme.prefixIconColor)),
              validator: (value) { if (value != null && value.trim().isNotEmpty && !value.contains('@')) { return 'Lütfen geçerli bir e-posta adresi girin.'; } return null; },
            ),
            const SizedBox(height: 24.0),
            Text("Şifre Değiştir (İsteğe Bağlı)", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary)),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: !_isCurrentPasswordVisible,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'Mevcut Şifre', prefixIcon: Icon(Icons.lock_open_rounded, color: theme.inputDecorationTheme.prefixIconColor), suffixIcon: IconButton(icon: Icon(_isCurrentPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: theme.iconTheme.color), onPressed: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible))),
              validator: (value) { if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) { return 'Yeni şifre için mevcut şifre gerekli.'; } return null; },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'Yeni Şifre', prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.inputDecorationTheme.prefixIconColor), suffixIcon: IconButton(icon: Icon(_isNewPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: theme.iconTheme.color), onPressed: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible))),
              validator: (value) { if (value != null && value.isNotEmpty && value.length < 6) { return 'Yeni şifre en az 6 karakter olmalıdır.'; } if (value != null && value.isNotEmpty && _currentPasswordController.text.isEmpty) { return 'Lütfen önce mevcut şifrenizi girin.'; } return null; },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _confirmNewPasswordController,
              obscureText: !_isConfirmNewPasswordVisible,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(labelText: 'Yeni Şifre Tekrar', prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.inputDecorationTheme.prefixIconColor), suffixIcon: IconButton(icon: Icon(_isConfirmNewPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: theme.iconTheme.color), onPressed: () => setState(() => _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible))),
              validator: (value) { if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) { return 'Lütfen yeni şifrenizi tekrar girin.'; } if (value != _newPasswordController.text) { return 'Yeni şifreler eşleşmiyor.'; } return null; },
            ),
            const SizedBox(height: 30.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Değişiklikleri Kaydet'),
              onPressed: _isLoading ? null : _saveProfileChanges,
              style: theme.elevatedButtonTheme.style,
            ),
          ],
        ),
      ),
    );
  }
}