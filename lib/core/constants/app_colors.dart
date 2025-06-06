import 'package:flutter/material.dart';

class AppColors {
  // Ana Renkler
  static const Color primary = Color(0xFF6B8E84); // Yeşilimsi ana renk
  static const Color primaryLight = Color(0xFF97B7AE);
  static const Color primaryDark = Color(0xFF4A635B);
  static const Color accent = Color(0xFFD7E0E9); // Vurgu için açık mavi-gri

  // Metin Renkleri
  static const Color primaryText = Color(0xFF2D3A4A);
  static const Color secondaryText = Color(0xFF78849E);
  static const Color whiteText = Colors.white;
  static const Color blackText = Colors.black87;

  // Arka Plan Renkleri
  static const Color screenBackground = Color(0xFFF0F3F6); // Genel ekran arka planı
  static const Color cardBackground = Color(0xFFFFFFFF); // Kartların arka planı
  static const Color chipBarBackground = Color(0xFFE8F0EF); // Chip bar için

  // Takvim Ekranı Özel Renkleri
  static const Color calendarChipSelectedText = primary;
  static const Color calendarChipUnselectedText = secondaryText;
  static const Color calendarSelectedDayBackground = Color(0x336B8E84); // Primary'nin %20 opaklığı
  static const Color calendarTodayBorder = primaryText;
  static const Color wavyBlueish = Color(0xFFD7E0E9); // Dalgalı kısımdaki açık renk
  static const Color wavyGreenish = Color(0xFFAFC9C3); // Dalgalı kısımdaki koyu renk

  // Özel Alt Navigasyon Çubuğu Renkleri
  static const Color customBottomBarBackground = Color(0xFFADC9C3);
  static const Color customBottomBarIcon = Colors.white;
  static const Color customBottomBarIconDim = Color(0xB3FFFFFF);
  static const Color customBottomBarLabel = Color(0xE6FFFFFF);

  // To-Do List Ekranı Renkleri
  static const Color todoAppBarBackground = Color(0xFFD5E0DC);
  static const Color todoFilterBackground = Color(0xFFE8F0EF);
  static const Color todoFilterSelectedBackground = Colors.white;

  // Not Alma Ekranı Renkleri
  static const Color noteAppBarBackground = Color(0xFFD5E0DC);
  static const Color noteInputBackground = Color(0xFFF0F5F4);
  static const Color notePageCurl = Color(0x20000000);

  // Genel
  static const Color disabled = Colors.grey;
  static const Color error = Colors.redAccent;

  static const Color calendarTitle = Color(0xFF78849E);
  static const Color calendarDayText = Color(0xFFD7E0E9);

  static const Color todoFilterText = Color(0xFF2D3A4A);

  static const List<Color> defaultCategoryColors = [
    Color(0xFFF44336), // Kırmızı
    Color(0xFFE91E63), // Pembe
    Color(0xFF9C27B0), // Mor
    Color(0xFF673AB7), // Koyu Mor
    Color(0xFF3F51B5), // İndigo
    Color(0xFF2196F3), // Mavi
    Color(0xFF03A9F4), // Açık Mavi
    Color(0xFF00BCD4), // Camgöbeği
    Color(0xFF009688), // Deniz Mavisi
    Color(0xFF4CAF50), // Yeşil
    Color(0xFF8BC34A), // Açık Yeşil
    Color(0xFFCDDC39), // Limon Yeşili
    Color(0xFFFFEB3B), // Sarı
    Color(0xFFFFC107), // Kehribar
    Color(0xFFFF9800), // Turuncu
    Color(0xFF49312C), // Kahverengi
    Color(0xFF9E9E9E), // Gri
    Color(0xFF607D8B), // Mavi Gri
  ];
}