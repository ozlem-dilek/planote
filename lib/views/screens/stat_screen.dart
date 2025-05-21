import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class IstatistiklerEkrani extends StatefulWidget {
  const IstatistiklerEkrani({super.key});

  @override
  State<IstatistiklerEkrani> createState() => _IstatistiklerEkraniState();
}

class _IstatistiklerEkraniState extends State<IstatistiklerEkrani> {
  String _selectedDateRangeFilter = "Bu Ay";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.screenBackground,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 4,
            right: 16,
            bottom: 10,
          ),
          child: Row(
            children: [
              Builder(
                builder: (BuildContext buttonContext) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primaryText, size: 28),
                    onPressed: () {
                      Scaffold.of(buttonContext).openDrawer();
                    },
                    tooltip: 'Menüyü Aç',
                  );
                },
              ),
              const Text(
                'İstatistikler',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryText),
                onPressed: () {
                  print("İstatistik Filtre tıklandı");
                  // TODO: Filtreleme seçeneklerini göster
                },
                tooltip: "Filtrele",
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatCard(
                  context: context,
                  title: "Görev Tamamlama Oranı",
                  chartPlaceholder: _buildChartPlaceholder("Pasta Grafik (Tamamlama Oranı)"),
                  // TODO: statsProvider.completionRateData ile PieChart eklenecek
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context: context,
                  title: "Kategoriye Göre Görev Dağılımı",
                  chartPlaceholder: _buildChartPlaceholder("Çubuk/Pasta Grafik (Kategoriler)"),
                  // TODO: statsProvider.tasksByCategoryData ile BarChart/PieChart eklenecek
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context: context,
                  title: "Haftalık Aktivite",
                  chartPlaceholder: _buildChartPlaceholder("Çubuk Grafik (Haftalık Aktivite)"),
                  // TODO: statsProvider.weeklyActivityData ile BarChart eklenecek
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context: context,
                  title: "Aylık Tamamlanan Görev Sayısı",
                  chartPlaceholder: _buildChartPlaceholder("Çizgi Grafik (Aylık Trend)"),
                  // TODO: statsProvider.monthlyCompletionData ile LineChart eklenecek
                ),
                // TODO: Daha fazla istatistik kartı eklenebilir
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder(String text) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 16),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required Widget chartPlaceholder,
    Widget? additionalInfo,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (additionalInfo != null) ...[
              const SizedBox(height: 8.0),
              additionalInfo,
            ],
            const SizedBox(height: 16.0),
            chartPlaceholder,
          ],
        ),
      ),
    );
  }
}