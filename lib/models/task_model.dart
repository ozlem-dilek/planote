import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late DateTime dueDate;

  @HiveField(4)
  late bool isCompleted;

  @HiveField(5)
  late String categoryId;

  @HiveField(6)
  DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.categoryId,
    this.createdAt,
  });
}