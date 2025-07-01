import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'view/screens/app_shell.dart';
import 'view/screens/login_screen.dart';

import 'models/category_model.dart';
import 'models/task_model.dart';
import 'models/user_model.dart';

import 'services/category_service.dart';
import 'providers/category_provider.dart';
import 'services/task_service.dart';
import 'providers/task_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';

const String categoriesBoxName = 'categoriesBox';
const String tasksBoxName = 'tasksBox';
const String usersBoxName = 'usersBox';

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
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  await Hive.openBox<CategoryModel>(categoriesBoxName);
  await Hive.openBox<TaskModel>(tasksBoxName);
  await Hive.openBox<UserModel>(usersBoxName);

  // TODO: Uygulama ilk kez çalışıyorsa veya yeni kullanıcı için varsayılan kategoriler eklenebilir (CategoryService içinde)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        Provider<CategoryService>(
          create: (_) => CategoryService(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(
            context.read<CategoryService>(),
            context.read<AuthProvider>(),
          ),
        ),
        Provider<TaskService>(
          create: (_) => TaskService(),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(
            context.read<TaskService>(),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider<CalendarProvider>(
          create: (context) => CalendarProvider(
            context.read<TaskService>(),
            context.read<CategoryService>(),
            context.read<AuthProvider>(),
            context.read<TaskProvider>(),
          ),
        ),
        ChangeNotifierProvider<StatsProvider>(
          create: (context) => StatsProvider(
            context.read<TaskService>(),
            context.read<CategoryService>(),
            context.read<AuthProvider>(),
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'Planote App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
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
            home: authProvider.isLoggedIn
                ? const AppShell()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}