import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:planote/views/screens/app_shell.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null); // Türkçe tarih formatları için
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