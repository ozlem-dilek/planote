import 'package:flutter/material.dart';
import '../constants/app_colors.dart'; //kendim tanımladığım renkler

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary, // Ana renk
      primaryColorLight: AppColors.primaryLight, // Ana renk açık
      primaryColorDark: AppColors.primaryDark, // Ana renk koyu
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: MaterialColor(AppColors.primary.value, const <int, Color>{
          50: AppColors.primaryLight,
          100: AppColors.primaryLight,
          200: AppColors.primaryLight,
          300: AppColors.primary,
          400: AppColors.primary,
          500: AppColors.primary,
          600: AppColors.primaryDark,
          700: AppColors.primaryDark,
          800: AppColors.primaryDark,
          900: AppColors.primaryDark,
        }),
        accentColor: AppColors.accent, // Vurgu için açık renk
        backgroundColor: AppColors.screenBackground, // Genel ekran arka planı
        errorColor: AppColors.error, // Hata rengi
      ).copyWith(secondary: AppColors.accent), // accentColor yerine secondary

      scaffoldBackgroundColor: AppColors.screenBackground,
      fontFamily: 'Poppins', // todo: Bu fontu projeye ekle (assets) ve pubspec.yaml'da tanımla

      appBarTheme: const AppBarTheme(
        elevation: 0, // gölge yok
        backgroundColor: AppColors.screenBackground, // Veya sayfa bazlı AppColors.todoAppBarBackground vb.
        iconTheme: IconThemeData(color: AppColors.primaryText),
        actionsIconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText, fontFamily: 'Poppins'),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryText, fontFamily: 'Poppins'),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryText, fontFamily: 'Poppins'), // Önceki örneklerde kullanıldı
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryText, fontFamily: 'Poppins'),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.primaryText, fontFamily: 'Poppins', height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.secondaryText, fontFamily: 'Poppins', height: 1.4),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.whiteText, fontFamily: 'Poppins'), // Butonlar için
      ),

      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
        size: 24.0,
      ),

      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.whiteText,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.secondaryText, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.secondaryText, fontFamily: 'Poppins'),
        hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontFamily: 'Poppins'),
      ),
      // TODO: Diğer widget temalarını buraya ekle: Chipbar, cardwidget vs.
    );
  }
}