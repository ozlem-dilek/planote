// lib/models/task_model.dart
import 'package:hive/hive.dart';
part 'task_model.g.dart'; // build_runner ile üretilecek

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? endDateTime;

  @HiveField(4)
  late bool isCompleted;

  @HiveField(5)
  late String categoryId;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  DateTime? startDateTime;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.startDateTime,
    this.endDateTime,
    this.isCompleted = false,
    required this.categoryId,
    this.createdAt,
  });
}