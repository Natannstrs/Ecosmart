import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Diagram kontribusi sumber energi (Surya vs Angin) dengan CustomPainter & animasi
class EnergyContributionChart extends StatelessWidget {
  final double solarKwh;
  final double windKwh;
  final double totalKwh;
  final double solarPercent;
  final double windPercent;
  final VoidCallback? onSolarTap;
  final VoidCallback? onWindTap;

  const EnergyContributionChart({
    super.key,
    required this.solarKwh,
    required this.windKwh,
    required this.totalKwh,
    required this.solarPercent,
    required this.windPercent,
    this.onSolarTap,
    this.onWindTap,
  });

  @override
  Widget build(BuildContext context) {
    const solarColor = Color(0xFF00E676); // Neon Green
    const windColor = Color(0xFF00D2FF); // Cyan / Electric Blue

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10281F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F4A38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    color: Color(0xFF00E676),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Kontribusi Sumber Energi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF163C2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalKwh.toStringAsFixed(1)} kWh/hari',
                  style: const TextStyle(
                    color: Color(0xFF8CE3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // Donut Ring Visualizer
              SizedBox(
                width: 110,
                height: 110,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: solarPercent),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, animSolar, child) {
                    return CustomPaint(
                      painter: _DonutChartPainter(
                        solarRatio: totalKwh > 0 ? animSolar / 100.0 : 0.0,
                        solarColor: solarColor,
                        windColor: windColor,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                color: Color(0xFF8BA799),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              totalKwh.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'kWh',
                              style: TextStyle(
                                color: Color(0xFF8BA799),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Legend and Detailed Bars
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Solar row
                    InkWell(
                      onTap: onSolarTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.wb_sunny_rounded,
                                      color: solarColor,
                                      size: 15,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Energi Surya',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${solarPercent.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: solarColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${solarKwh.toStringAsFixed(1)} kWh/hari',
                              style: const TextStyle(
                                color: Color(0xFF8BA799),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFF1E4233), height: 12),
                    // Wind row
                    InkWell(
                      onTap: onWindTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.air_rounded,
                                      color: windColor,
                                      size: 15,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Energi Angin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${windPercent.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: windColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${windKwh.toStringAsFixed(1)} kWh/hari',
                              style: const TextStyle(
                                color: Color(0xFF8BA799),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (solarPercent * 10).round().clamp(0, 1000),
                    child: Container(color: solarColor),
                  ),
                  Expanded(
                    flex: (windPercent * 10).round().clamp(0, 1000),
                    child: Container(color: windColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double solarRatio;
  final Color solarColor;
  final Color windColor;

  _DonutChartPainter({
    required this.solarRatio,
    required this.solarColor,
    required this.windColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF163C2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (solarRatio <= 0.001 && (1 - solarRatio) <= 0.001) {
      return;
    }

    final solarSweep = 2 * math.pi * solarRatio;
    final windSweep = 2 * math.pi * (1.0 - solarRatio);

    final solarPaint = Paint()
      ..color = solarColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final windPaint = Paint()
      ..color = windColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Gambar segmen surya (mulai dari -pi/2 atau jam 12)
    if (solarRatio > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        solarSweep - 0.08,
        false,
        solarPaint,
      );
    }

    // Gambar segmen angin
    if ((1.0 - solarRatio) > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + solarSweep,
        windSweep - 0.08,
        false,
        windPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.solarRatio != solarRatio ||
        oldDelegate.solarColor != solarColor ||
        oldDelegate.windColor != windColor;
  }
}
