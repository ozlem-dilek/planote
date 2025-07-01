import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
        primaryColor: AppColors.primary,
        primaryColorLight: AppColors.primaryLight,
        primaryColorDark: AppColors.primaryDark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(AppColors.primary.value, const <int, Color>{
            50: AppColors.primaryLight, 100: AppColors.primaryLight,
            200: AppColors.primaryLight, 300: AppColors.primary,
            400: AppColors.primary,     500: AppColors.primary,
            600: AppColors.primaryDark, 700: AppColors.primaryDark,
            800: AppColors.primaryDark, 900: AppColors.primaryDark,
          }),
          accentColor: AppColors.accent,
          backgroundColor: AppColors.screenBackground,
          errorColor: AppColors.error,
          brightness: Brightness.light,
        ).copyWith(secondary: AppColors.accent),

        scaffoldBackgroundColor: AppColors.screenBackground,
        fontFamily: 'Poppins',

        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.screenBackground,
          iconTheme: IconThemeData(color: AppColors.primaryText),
          actionsIconTheme: IconThemeData(color: AppColors.primaryText),
          titleTextStyle: TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        textTheme: const TextTheme( /* ... mevcut light theme textTheme... */ ),
        iconTheme: const IconThemeData(color: AppColors.primaryText, size: 24.0),
        buttonTheme: ButtonThemeData( /* ... */ ),
        elevatedButtonTheme: ElevatedButtonThemeData( /* ... */ ),
        inputDecorationTheme: InputDecorationTheme( /* ... */ ),
        cardTheme: CardTheme(
          elevation: 1.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          color: AppColors.cardBackground,
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
        )
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: MaterialColor(AppColors.primary.value, const <int, Color>{
          50: AppColors.primaryLight, 100: AppColors.primaryLight,
          200: AppColors.primaryLight, 300: AppColors.primary,
          400: AppColors.primary,     500: AppColors.primary,
          600: AppColors.primaryDark, 700: AppColors.primaryDark,
          800: AppColors.primaryDark, 900: AppColors.primaryDark,
        }),
        accentColor: AppColors.accent,
        backgroundColor: const Color(0xFF121212),
        errorColor: Colors.redAccent.shade100,
        brightness: Brightness.dark,
      ).copyWith(secondary: AppColors.accent),

      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      fontFamily: 'Poppins',

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: IconThemeData(color: AppColors.whiteText.withOpacity(0.87)),
        actionsIconTheme: IconThemeData(color: AppColors.whiteText.withOpacity(0.87)),
        titleTextStyle: TextStyle(
          color: AppColors.whiteText.withOpacity(0.87),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: TextTheme( // Koyu tema için metin stilleri
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.whiteText.withOpacity(0.87), fontFamily: 'Poppins'),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.whiteText.withOpacity(0.87), fontFamily: 'Poppins'),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.whiteText.withOpacity(0.87), fontFamily: 'Poppins'),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.whiteText.withOpacity(0.87), fontFamily: 'Poppins'),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.whiteText.withOpacity(0.87), fontFamily: 'Poppins', height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.whiteText.withOpacity(0.60), fontFamily: 'Poppins', height: 1.4),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText, fontFamily: 'Poppins'), // Koyu tema buton metni için
      ),

      iconTheme: IconThemeData(
        color: AppColors.whiteText.withOpacity(0.87),
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
          foregroundColor: AppColors.primaryText,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.whiteText.withOpacity(0.3), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.whiteText.withOpacity(0.5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.whiteText.withOpacity(0.60), fontFamily: 'Poppins'),
        hintStyle: TextStyle(color: AppColors.whiteText.withOpacity(0.40), fontFamily: 'Poppins'),
        prefixIconColor: AppColors.whiteText.withOpacity(0.60),
      ),
      cardTheme: CardTheme(
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: const Color(0xFF2A2A2A),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      ),
      dividerColor: AppColors.whiteText.withOpacity(0.12),
    );
  }
}