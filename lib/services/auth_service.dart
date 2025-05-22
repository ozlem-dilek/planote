import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../../main.dart';

class AuthService {
  late Box<UserModel> _usersBox;
  final Uuid _uuid = const Uuid();

  AuthService() {
    _usersBox = Hive.box<UserModel>(usersBoxName);
  }

  String _generateSalt([int length = 32]) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  String _hashPassword(String password, String salt) {
    final saltedPassword = utf8.encode(salt + password);
    final hashedPasswordBytes = sha256.convert(saltedPassword);
    return base64Url.encode(hashedPasswordBytes.bytes);
  }

  bool _isUsernameTaken(String username, {String? excludeUserId}) {
    return _usersBox.values.any((user) =>
    user.username.toLowerCase() == username.toLowerCase() &&
        (excludeUserId == null || user.userId != excludeUserId));
  }

  Future<UserModel?> registerUser({
    required String username,
    required String password,
    String? email,
  }) async {
    if (_isUsernameTaken(username)) {
      throw Exception('Bu kullanıcı adı zaten alınmış.');
    }
    if (password.length < 6) {
      throw Exception('Şifre en az 6 karakter olmalıdır.');
    }

    final salt = _generateSalt();
    final hashedPassword = _hashPassword(password, salt);
    final userId = _uuid.v4();

    final newUser = UserModel(
      userId: userId,
      username: username,
      hashedPassword: hashedPassword,
      salt: salt,
      email: email,
      createdAt: DateTime.now(),
    );

    await _usersBox.put(newUser.userId, newUser);
    return newUser;
  }

  Future<UserModel?> loginUser({
    required String username,
    required String password,
  }) async {
    UserModel? foundUser;
    try {
      foundUser = _usersBox.values.firstWhere(
              (user) => user.username.toLowerCase() == username.toLowerCase()
      );
    } catch (e) {
      foundUser = null;
    }

    if (foundUser == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final hashedPasswordToCheck = _hashPassword(password, foundUser.salt);
    if (hashedPasswordToCheck == foundUser.hashedPassword) {
      return foundUser;
    } else {
      throw Exception('Yanlış şifre.');
    }
  }

  Future<UserModel?> updateUserProfile({
    required String userId,
    String? newUsername,
    String? newEmail,
    String? currentPassword,
    String? newPassword,
    String? newProfileImagePath,
  }) async {
    final userToUpdate = _usersBox.get(userId);
    if (userToUpdate == null) {
      throw Exception("Güncellenecek kullanıcı bulunamadı.");
    }

    bool changed = false;

    if (newUsername != null && newUsername.trim().isNotEmpty && userToUpdate.username != newUsername.trim()) {
      if (_isUsernameTaken(newUsername.trim(), excludeUserId: userId)) {
        throw Exception("Bu kullanıcı adı zaten başkası tarafından kullanılıyor.");
      }
      userToUpdate.username = newUsername.trim();
      changed = true;
    }

    if (newEmail != null && userToUpdate.email != newEmail.trim()) {
      userToUpdate.email = newEmail.trim().isEmpty ? null : newEmail.trim();
      changed = true;
    } else if (newEmail == null && userToUpdate.email != null) {
      if (newEmail.toString().trim().isEmpty) {
        userToUpdate.email = null;
        changed = true;
      }
    }

    if (newProfileImagePath != null && userToUpdate.profileImagePath != newProfileImagePath) {
      userToUpdate.profileImagePath = newProfileImagePath.isEmpty ? null : newProfileImagePath;
      changed = true;
    } else if (newProfileImagePath == null && userToUpdate.profileImagePath != null) {
      userToUpdate.profileImagePath = null; // Fotoğraf kaldırıldıysa
      changed = true;
    }


    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw Exception("Yeni şifre belirlemek için mevcut şifrenizi girmelisiniz.");
      }
      final currentPasswordHash = _hashPassword(currentPassword, userToUpdate.salt);
      if (currentPasswordHash != userToUpdate.hashedPassword) {
        throw Exception("Mevcut şifreniz yanlış.");
      }
      if (newPassword.length < 6) {
        throw Exception('Yeni şifre en az 6 karakter olmalıdır.');
      }
      final newSalt = _generateSalt();
      userToUpdate.salt = newSalt;
      userToUpdate.hashedPassword = _hashPassword(newPassword, newSalt);
      changed = true;
    }

    if (changed) {
      await _usersBox.put(userId, userToUpdate);
    }
    return userToUpdate;
  }
}