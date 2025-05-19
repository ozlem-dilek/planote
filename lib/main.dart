import 'package:flutter/material.dart';
import 'package:planote/views/screens/app_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
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