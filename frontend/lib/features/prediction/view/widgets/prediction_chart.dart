import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/themes/app_colors.dart';

class PredictionChart extends StatelessWidget {
  final Map<String, double> allConfidences;

  const PredictionChart({super.key, required this.allConfidences});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Sort confidences by value descending
    final sortedEntries = allConfidences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROBABILITY DISTRIBUTION',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.1, // Leave space for labels
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.surfaceDark : Colors.white,
                  tooltipBorder: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  tooltipBorderRadius: BorderRadius.circular(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${sortedEntries[groupIndex].key}\n',
                      theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      children: [
                        TextSpan(
                          text: '${(rod.toY * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= sortedEntries.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          sortedEntries[index].key,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: sortedEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value.value;
                final isTop = index == 0;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      gradient: LinearGradient(
                        colors: isTop
                            ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)]
                            : [AppColors.accent.withValues(alpha: 0.8), AppColors.accent.withValues(alpha: 0.4)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 1.0,
                        color: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
