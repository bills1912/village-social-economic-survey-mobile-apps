// Tambahan ke lib/widgets/chart_widgets.dart – AgeDistributionChart
// (Paste di bagian bawah chart_widgets.dart yang sudah ada)

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AgeDistributionChart extends StatelessWidget {
  final Map<String, int> ageGroups;

  const AgeDistributionChart({super.key, required this.ageGroups});

  @override
  Widget build(BuildContext context) {
    if (ageGroups.isEmpty) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('Belum ada data usia',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    // Ordered buckets
    const order = ['0–4', '5–14', '15–24', '25–39', '40–59', '60+'];
    final ordered = order
        .where((k) => ageGroups.containsKey(k))
        .map((k) => MapEntry(k, ageGroups[k]!))
        .toList();

    if (ordered.isEmpty) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: const Text('Belum ada data usia',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    final maxVal =
        ordered.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final colors = [
      const Color(0xFF42A5F5),
      const Color(0xFF26C6DA),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFEF5350),
      const Color(0xFFAB47BC),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bar chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ordered.asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
                final color = colors[idx % colors.length];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${e.value}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 80 * ratio,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Labels
          Row(
            children: ordered.asMap().entries.map((entry) {
              final idx = entry.key;
              final e = entry.value;
              final color = colors[idx % colors.length];
              return Expanded(
                child: Text(
                  e.key,
                  style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
