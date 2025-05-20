import 'package:hive/hive.dart';
part 'category_model.g.dart'; // build_runner ile üretilecek.
//modellerin Hive tarafından nasıl saklanıp okunacağını tanımlar.

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int colorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
  });
}