import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/grade.dart';

class GradeChart extends StatelessWidget {
  final List<Grade> grades;

  const GradeChart({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data nilai.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<BarChartGroupData> barGroups = [];
    final colorPalette = <Color>[
      Colors.blue.shade400,
      Colors.indigo.shade500,
      Colors.purple.shade500,
      Colors.pink.shade400,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.amber.shade400,
      Colors.green.shade400,
    ];

    for (var i = 0; i < grades.length; i++) {
      final raw = grades[i].finalScore;
      final double safe =
          (raw.isFinite ? raw : 0.0).clamp(0.0, 100.0).toDouble();
      final color = colorPalette[i % colorPalette.length];

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: safe,
              color: color,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200, // tinggi chart
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadowColor: Colors.blueAccent.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Grafik Nilai Mata Pelajaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.cyan[100] : Colors.indigo[800],
                  ),
                ),
              ),
              Expanded(
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey.withOpacity(0.25),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 20,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= grades.length) {
                              return const SizedBox.shrink();
                            }
                            final label = grades[index].subject;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                label.length > 5
                                    ? '${label.substring(0, 5)}…'
                                    : label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex < 0 || groupIndex >= grades.length) {
                            return null;
                          }
                          final g = grades[groupIndex];
                          return BarTooltipItem(
                            '${g.subject}\nNilai: ${rod.toY.toStringAsFixed(1)}',
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
