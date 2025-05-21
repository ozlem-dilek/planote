import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/stats_provider.dart';
import '../../models/category_model.dart';

class IstatistiklerEkrani extends StatelessWidget {
  const IstatistiklerEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: AppColors.screenBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'İstatistikler',
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primaryText),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Menüyü Aç',
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryText),
            onPressed: () {
              context.read<StatsProvider>().fetchAllStats();
            },
            tooltip: "Yenile",
          ),
        ],
      ),
      body: Builder(
          builder: (context) {
            if (statsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (statsProvider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "İstatistikler yüklenemedi: ${statsProvider.error}",
                    style: const TextStyle(color: AppColors.error, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildStatCard(
                    context: context,
                    title: "Görev Tamamlama Oranı",
                    chartContent: _buildCompletionPieChart(statsProvider),
                    additionalInfo: statsProvider.totalTasks > 0
                        ? Text(
                      "${statsProvider.completedTasks} / ${statsProvider.totalTasks} görev tamamlandı.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                    )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildStatCard(
                    context: context,
                    title: "Kategoriye Göre Görev Dağılımı",
                    chartContent: _buildTasksByCategoryBarChart(statsProvider),
                  ),
                  const SizedBox(height: 20),
                  _buildStatCard(
                    context: context,
                    title: "Haftalık Aktivite (Tamamlanan Görevler)",
                    chartContent: _buildWeeklyActivityChart(statsProvider),
                  ),
                  const SizedBox(height: 20),
                  _buildStatCard(
                    context: context,
                    title: "Aylık Tamamlanan Görev Sayısı",
                    chartContent: _buildMonthlyCompletionLineChart(statsProvider),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildCompletionPieChart(StatsProvider statsProvider) {
    if (statsProvider.completionRateSections.isEmpty || statsProvider.totalTasks == 0) {
      return _buildChartPlaceholder("Tamamlama oranı için yeterli veri yok.");
    }
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: statsProvider.completionRateSections,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // TODO: Dokunma etkileşimleri eklenebilir
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTasksByCategoryBarChart(StatsProvider statsProvider) {
    if (statsProvider.tasksByCategoryGroups.isEmpty) {
      return _buildChartPlaceholder("Kategorilere göre görev dağılımı için veri yok.");
    }
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: statsProvider.tasksByCategoryGroups,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < statsProvider.allCategoriesForChartTitles.length) {
                    final categoryName = statsProvider.allCategoriesForChartTitles[index].name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        categoryName.length > 8 ? '${categoryName.substring(0,6)}...' : categoryName,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _calculateBarChartInterval(statsProvider.tasksByCategoryGroups),
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0 || value == meta.max || value % _calculateBarChartInterval(statsProvider.tasksByCategoryGroups) == 0) {
                    return Text(value.toInt().toString(), style: const TextStyle(color: AppColors.secondaryText, fontSize: 10));
                  }
                  return Container();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateBarChartInterval(statsProvider.tasksByCategoryGroups),
              getDrawingHorizontalLine: (value) {
                return FlLine(color: AppColors.secondaryText.withOpacity(0.1), strokeWidth: 1);
              }
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData group) {
                return Colors.blueGrey.withOpacity(0.8);
              },
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String categoryName;
                if (group.x.toInt() >= 0 && group.x.toInt() < statsProvider.allCategoriesForChartTitles.length) {
                  categoryName = statsProvider.allCategoriesForChartTitles[group.x.toInt()].name;
                } else {
                  categoryName = 'Bilinmeyen';
                }
                return BarTooltipItem(
                  '$categoryName\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rod.toY.toInt()).toString(),
                      style: TextStyle(
                        color: rod.color ?? Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyActivityChart(StatsProvider statsProvider) {
    if (statsProvider.weeklyActivityGroups.isEmpty) {
      return _buildChartPlaceholder("Haftalık aktivite için veri yok.");
    }
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: statsProvider.weeklyActivityGroups,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < statsProvider.last7DaysLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                          statsProvider.last7DaysLabels[index],
                          style: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 10)
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _calculateBarChartInterval(statsProvider.weeklyActivityGroups, minInterval: 1),
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0 || value == meta.max || value % _calculateBarChartInterval(statsProvider.weeklyActivityGroups, minInterval: 1) == 0) {
                    return Text(value.toInt().toString(), style: const TextStyle(color: AppColors.secondaryText, fontSize: 10));
                  }
                  return Container();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateBarChartInterval(statsProvider.weeklyActivityGroups, minInterval: 1),
              getDrawingHorizontalLine: (value) {
                return FlLine(color: AppColors.secondaryText.withOpacity(0.1), strokeWidth: 1);
              }
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String dayName = "";
                if (group.x.toInt() >= 0 && group.x.toInt() < statsProvider.last7DaysLabels.length) {
                  dayName = statsProvider.last7DaysLabels[group.x.toInt()];
                }
                return BarTooltipItem(
                  '$dayName\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rod.toY.toInt()).toString(),
                      style: TextStyle(
                        color: rod.color ?? Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCompletionLineChart(StatsProvider statsProvider) {
    if (statsProvider.monthlyCompletionSpots.isEmpty) {
      return _buildChartPlaceholder("Aylık tamamlama verisi yok.");
    }

    double minY = 0;
    double maxY = statsProvider.maxMonthlyCompletedTasks > 0 ? (statsProvider.maxMonthlyCompletedTasks * 1.2).ceilToDouble() : 5;
    if (maxY == 0 && statsProvider.monthlyCompletionSpots.any((spot) => spot.y > 0)) {
      maxY = statsProvider.monthlyCompletionSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;
      if(maxY < 5) maxY = 5;
      maxY = maxY.ceilToDouble();
    } else if (maxY == 0) {
      maxY = 5;
    }

    double intervalY = (maxY / 5).ceilToDouble();
    if (intervalY == 0) intervalY = 1;


    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 5,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            verticalInterval: 1,
            horizontalInterval: intervalY,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.secondaryText.withOpacity(0.1), strokeWidth: 1);
            },
            getDrawingVerticalLine: (value) {
              return FlLine(color: AppColors.secondaryText.withOpacity(0.1), strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < statsProvider.last6MonthsLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                          statsProvider.last6MonthsLabels[index],
                          style: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 10)
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: intervalY,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value % intervalY == 0) {
                    return Text(value.toInt().toString(), style: const TextStyle(color: AppColors.secondaryText, fontSize: 10));
                  }
                  return Container();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.secondaryText.withOpacity(0.2), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: statsProvider.monthlyCompletionSpots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(radius: 4, color: AppColors.primaryDark, strokeWidth: 1, strokeColor: AppColors.whiteText);
              }),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
              preventCurveOverShooting: true,
              preventCurveOvershootingThreshold: 1.0,
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) => Colors.blueGrey.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final monthIndex = touchedSpot.x.toInt();
                  String monthName = "";
                  if (monthIndex >= 0 && monthIndex < statsProvider.last6MonthsLabels.length) {
                    monthName = statsProvider.last6MonthsLabels[monthIndex];
                  }
                  return LineTooltipItem(
                    '$monthName\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: touchedSpot.y.toInt().toString(),
                        style: TextStyle(
                          color: touchedSpot.bar.gradient?.colors.first ?? touchedSpot.bar.color ?? Colors.blue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const TextSpan(
                        text: ' görev',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _calculateBarChartInterval(List<BarChartGroupData> groups, {double minInterval = 0}) {
    if (groups.isEmpty) return 1;
    double maxVal = 0;
    for (var group in groups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxVal) {
          maxVal = rod.toY;
        }
      }
    }
    if (maxVal == 0) return 1 > minInterval ? 1 : minInterval;
    if (maxVal <= 5) return 1 > minInterval ? 1 : minInterval;
    if (maxVal <= 10) return 2 > minInterval ? 2 : minInterval;
    if (maxVal <= 20) return 5 > minInterval ? 5 : minInterval;
    if (maxVal <= 50) return 10 > minInterval ? 10 : minInterval;
    double calculatedInterval = (maxVal / 5).ceilToDouble();
    return calculatedInterval > minInterval ? calculatedInterval : minInterval;
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
    required Widget chartContent,
    Widget? additionalInfo,
  }) {
    return Card(
      elevation: 1.0,
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
                  fontSize: 18
              ),
            ),
            if (additionalInfo != null) ...[
              const SizedBox(height: 8.0),
              additionalInfo,
            ],
            const SizedBox(height: 16.0),
            chartContent,
          ],
        ),
      ),
    );
  }
}