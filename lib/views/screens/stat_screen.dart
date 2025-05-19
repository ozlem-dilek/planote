import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class IstatistiklerEkrani extends StatefulWidget {
  const IstatistiklerEkrani({super.key});

  @override
  State<IstatistiklerEkrani> createState() => _IstatistiklerEkraniState();
}

class _IstatistiklerEkraniState extends State<IstatistiklerEkrani> {
  // TODO: Provider ile istatistik verilerini ve filtre durumlarını yöneteceğiz
  String _selectedDateRange = "Bu Hafta"; // Örnek filtre durumu

  @override
  Widget build(BuildContext context) {
    // Bu ekran AppShell içinde gösteriliyor.
    // AppShell'in Scaffold'una erişmek için GlobalKey veya context üzerinden findAncestorStateOfType kullanılabilir.
    // AppBar'daki leading IconButton için Builder kullanmak en temiz yollardan biridir.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        title: const Text(
          'İstatistikler',
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primaryText),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // AppShell'in Drawer'ını açar
              },
              tooltip: 'Menüyü Aç',
            );
          },
        ),
        actions: [
          // TODO: Tarih aralığı seçimi için bir ikon veya dropdown eklenebilir
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryText),
            onPressed: () {
              print("Filtre tıklandı");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Bakış - $_selectedDateRange',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 20),

            // TODO: Provider'dan gelen verilerle doldurulacak grafikler
            _buildStatCard(
              title: "Tamamlanan Görevler",
              // child: Placeholder(fallbackHeight: 150, color: AppColors.primary.withOpacity(0.2)), // PieChart için
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3))
                ),
                alignment: Alignment.center,
                child: Text("Pasta Grafik (PieChart) Buraya Gelecek", style: TextStyle(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            _buildStatCard(
              title: "Günlük Aktivite",
              // child: Placeholder(fallbackHeight: 200, color: AppColors.accent.withOpacity(0.3)), // BarChart için
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withOpacity(0.4))
                ),
                alignment: Alignment.center,
                child: Text("Çubuk Grafik (BarChart) Buraya Gelecek", style: TextStyle(color: AppColors.accent.withOpacity(0.9))),
              ),
            ),
            const SizedBox(height: 20),
            _buildStatCard(
              title: "Kategori Dağılımı",
              // child: Placeholder(fallbackHeight: 150, color: Colors.orange.withOpacity(0.2)), // Başka bir grafik
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3))
                ),
                alignment: Alignment.center,
                child: Text("Kategori Grafiği Buraya Gelecek", style: TextStyle(color: Colors.orange)),
              ),
            ),
            // TODO: Daha fazla istatistik veya özet bilgi eklenebilir
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required Widget child}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 12.0),
            child, // Grafik buraya gelecek
          ],
        ),
      ),
    );
  }
}