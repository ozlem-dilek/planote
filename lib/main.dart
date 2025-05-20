import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'views/screens/app_shell.dart';
import 'models/category_model.dart';
import 'models/task_model.dart';
import 'services/category_service.dart';
import 'providers/category_provider.dart';
// TODO: TaskService ve TaskProvider da buraya eklenecek

const String categoriesBoxName = 'categoriesBox';
const String tasksBoxName = 'tasksBox';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }

  await Hive.openBox<CategoryModel>(categoriesBoxName);
  await Hive.openBox<TaskModel>(tasksBoxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CategoryService>(
          create: (_) => CategoryService(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(context.read<CategoryService>()),
        ),

        // TODO: TaskService & TaskProvider eklenecek

      ],
      child: MaterialApp(
        title: 'Planote App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}