import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  late String userId;

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String hashedPassword;

  @HiveField(3)
  late String salt;

  @HiveField(4)
  String? email;

  @HiveField(5)
  DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.hashedPassword,
    required this.salt,
    this.email,
    this.createdAt,
  });
}