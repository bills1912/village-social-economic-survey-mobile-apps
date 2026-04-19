// lib/widgets/chart_widgets.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

// Simple Pie Chart for gender distribution
class GenderPieChart extends StatelessWidget {
  final int lakiLaki;
  final int perempuan;

  const GenderPieChart({
    super.key,
    required this.lakiLaki,
    required this.perempuan,
  });

  @override
  Widget build(BuildContext context) {
    final total = lakiLaki + perempuan;
    if (total == 0) return _emptyState();

    final lakiPct = lakiLaki / total;
    final perPct = perempuan / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _PieChartPainter(
                values: [lakiPct, perPct],
                colors: [AppTheme.primaryBlue, Colors.pink],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$total',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Total',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendItem(
                  color: AppTheme.primaryBlue,
                  label: 'Laki-laki',
                  value: lakiLaki,
                  pct: lakiPct,
                ),
                const SizedBox(height: 12),
                _legendItem(
                  color: Colors.pink,
                  label: 'Perempuan',
                  value: perempuan,
                  pct: perPct,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required int value,
    required double pct,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const Spacer(),
            Text('${(pct * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$value orang',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _emptyState() => Container(
    height: 120,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text('Belum ada data',
        style: TextStyle(color: Colors.grey[400])),
  );
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bar chart for officer progress
class OfficerProgressChart extends StatelessWidget {
  final Map<String, int> perPetugas;

  const OfficerProgressChart({super.key, required this.perPetugas});

  @override
  Widget build(BuildContext context) {
    if (perPetugas.isEmpty) return _emptyState();

    final sorted = perPetugas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: sorted.take(8).map((entry) {
          final ratio = maxVal > 0 ? entry.value / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(entry.key,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textPrimary),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '${entry.value} KK',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.grey[100],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState() => Container(
    height: 80,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text('Belum ada data petugas',
        style: TextStyle(color: Colors.grey[400])),
  );
}

// Education bar chart
class EducationBarChart extends StatelessWidget {
  final Map<String, int> perPendidikan;

  const EducationBarChart({super.key, required this.perPendidikan});

  @override
  Widget build(BuildContext context) {
    if (perPendidikan.isEmpty) return const SizedBox.shrink();

    final sorted = perPendidikan.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value.toDouble();

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.accentGreen,
      AppTheme.accentOrange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final idx = entry.key;
          final e = entry.value;
          final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
          final color = colors[idx % colors.length];

          // Shorten label
          String label = e.key;
          if (label.length > 22) label = '${label.substring(0, 20)}...';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 10,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${e.value}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
