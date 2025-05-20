import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:planote/views/screens/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/category_model.dart';
import 'models/task_model.dart';

const String categoriesBoxName = 'categoriesBox';
const String tasksBoxName = 'tasksBox';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null); // Türkçe tarih formatları için

  // hive initialization
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }

  await Hive.openBox<CategoryModel>(categoriesBoxName);
  await Hive.openBox<TaskModel>(tasksBoxName);

  // TODO: Hive kutuları burada veya servislerde açılabilri.



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: MultiProvider ile Provider'ları burada sarmala
    //     // TODO: go_router kullanacaksan routerConfig burada tanımlanacak


    // Şimdilik Provider olmadan:
    return MaterialApp(
      title: 'Planote App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}