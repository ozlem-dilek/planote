import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'views/screens/app_shell.dart';

import 'models/category_model.dart';
import 'models/task_model.dart';

import 'services/category_service.dart';
import 'providers/category_provider.dart';
import 'services/task_service.dart';
import 'providers/task_provider.dart';
import 'providers/calendar_provider.dart';


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
        Provider<TaskService>(
          create: (_) => TaskService(),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(context.read<TaskService>()),
        ),
        ChangeNotifierProvider<CalendarProvider>(
          create: (context) => CalendarProvider(
            context.read<TaskService>(),
            context.read<CategoryService>(),
            context.read<TaskProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Planote App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', ''),
        ],
        locale: const Locale('tr', 'TR'),
        home: const AppShell(),
      ),
    );
  }
}