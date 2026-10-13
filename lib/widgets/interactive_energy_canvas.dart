import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/energy_device.dart';
import '../models/energy_simulation.dart';

/// Kanvas Pembangkit Interaktif dengan Ilustrasi Bukit, Langit, Matahari,
/// serta objek Panel Surya & Turbin Angin yang mendukung Tap, Long Press, dan Drag/Pan Gesture.
class InteractiveEnergyCanvas extends StatefulWidget {
  final EnergySimulation simulation;
  final Offset solarPosition;
  final Offset windPosition;
  final DeviceType selectedDevice;
  final Function(DeviceType type) onDeviceTap;
  final Function(DeviceType type) onDeviceLongPress;
  final Function(DeviceType type, Offset newPosition) onDeviceDrag;

  const InteractiveEnergyCanvas({
    super.key,
    required this.simulation,
    required this.solarPosition,
    required this.windPosition,
    required this.selectedDevice,
    required this.onDeviceTap,
    required this.onDeviceLongPress,
    required this.onDeviceDrag,
  });

  @override
  State<InteractiveEnergyCanvas> createState() =>
      _InteractiveEnergyCanvasState();
}

class _InteractiveEnergyCanvasState extends State<InteractiveEnergyCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _turbineRotationController;

  @override
  void initState() {
    super.initState();
    // Animasi putaran turbin angin
    _turbineRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    if (widget.simulation.isWindActive &&
        widget.simulation.windTurbineCount > 0) {
      _startTurbineAnimation();
    }
  }

  void _startTurbineAnimation() {
    // Kecepatan putaran dipengaruhi faktor kapasitas angin (semakin tinggi, semakin cepat)
    final cf = widget.simulation.windCapacityFactor.clamp(0.05, 1.0);
    final durationMs = (3000 / (cf * 2.5)).clamp(600, 4000).toInt();
    _turbineRotationController.duration = Duration(milliseconds: durationMs);
    if (!_turbineRotationController.isAnimating) {
      _turbineRotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveEnergyCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.simulation.isWindActive &&
        widget.simulation.windTurbineCount > 0) {
      _startTurbineAnimation();
    } else {
      _turbineRotationController.stop();
    }
  }

  @override
  void dispose() {
    _turbineRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1D4533), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            final canvasHeight = constraints.maxHeight;

            // Ukuran bounded objek di kanvas
            const itemWidth = 116.0;
            const itemHeight = 132.0;

            // Clamping posisi agar tetap berada dalam kanvas
            final clampedSolarX = widget.solarPosition.dx.clamp(
              8.0,
              (canvasWidth - itemWidth - 8.0).clamp(8.0, canvasWidth),
            );
            final clampedSolarY = widget.solarPosition.dy.clamp(
              28.0,
              (canvasHeight - itemHeight - 8.0).clamp(28.0, canvasHeight),
            );

            final clampedWindX = widget.windPosition.dx.clamp(
              8.0,
              (canvasWidth - itemWidth - 8.0).clamp(8.0, canvasWidth),
            );
            final clampedWindY = widget.windPosition.dy.clamp(
              28.0,
              (canvasHeight - itemHeight - 8.0).clamp(28.0, canvasHeight),
            );

            final isSolarSelected =
                widget.selectedDevice == DeviceType.solar;
            final isWindSelected =
                widget.selectedDevice == DeviceType.wind;

            return Stack(
              children: [
                // 1. Background Pemandangan Bukit & Langit Alam
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LandscapePainter(
                      isSolarActive: widget.simulation.isSolarActive,
                      isWindActive: widget.simulation.isWindActive,
                      sunIntensity:
                          widget.simulation.effectiveSunHours / 10.0,
                      windIntensity:
                          widget.simulation.windCapacityFactor,
                    ),
                  ),
                ),

                // 2. HUD Info Koordinat & Status di Pojok Atas Kanvas
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF091F16).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF1E4D37),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.selectedDevice == DeviceType.solar
                                  ? Icons.solar_power_rounded
                                  : Icons.wind_power_rounded,
                              size: 14,
                              color: widget.selectedDevice == DeviceType.solar
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFF00D2FF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.selectedDevice == DeviceType.solar
                                  ? 'Surya: (${clampedSolarX.toInt()}, ${clampedSolarY.toInt()})'
                                  : 'Angin: (${clampedWindX.toInt()}, ${clampedWindY.toInt()})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A2218).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF1B4532),
                          ),
                        ),
                        child: const Text(
                          'Drag / Geser untuk Memindahkan',
                          style: TextStyle(
                            color: Color(0xFF90B5A2),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Objek Interaktif: ARRAY PANEL SURYA
                Positioned(
                  left: clampedSolarX,
                  top: clampedSolarY,
                  child: GestureDetector(
                    key: const Key('canvas_solar_device'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onDeviceTap(DeviceType.solar),
                    onLongPress: () =>
                        widget.onDeviceLongPress(DeviceType.solar),
                    onPanStart: (_) {
                      widget.onDeviceDrag(
                          DeviceType.solar, Offset(clampedSolarX, clampedSolarY));
                    },
                    onPanUpdate: (details) {
                      final newPos = Offset(
                        clampedSolarX + details.delta.dx,
                        clampedSolarY + details.delta.dy,
                      );
                      widget.onDeviceDrag(DeviceType.solar, newPos);
                    },
                    child: _buildSolarObject(
                      isSelected: isSolarSelected,
                      isActive: widget.simulation.isSolarActive,
                      count: widget.simulation.solarPanelCount,
                      itemWidth: itemWidth,
                      itemHeight: itemHeight,
                    ),
                  ),
                ),

                // 4. Objek Interaktif: TURBIN ANGIN
                Positioned(
                  left: clampedWindX,
                  top: clampedWindY,
                  child: GestureDetector(
                    key: const Key('canvas_wind_device'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onDeviceTap(DeviceType.wind),
                    onLongPress: () =>
                        widget.onDeviceLongPress(DeviceType.wind),
                    onPanStart: (_) {
                      widget.onDeviceDrag(
                          DeviceType.wind, Offset(clampedWindX, clampedWindY));
                    },
                    onPanUpdate: (details) {
                      final newPos = Offset(
                        clampedWindX + details.delta.dx,
                        clampedWindY + details.delta.dy,
                      );
                      widget.onDeviceDrag(DeviceType.wind, newPos);
                    },
                    child: _buildWindObject(
                      isSelected: isWindSelected,
                      isActive: widget.simulation.isWindActive,
                      count: widget.simulation.windTurbineCount,
                      rotationAnimation: _turbineRotationController,
                      itemWidth: itemWidth,
                      itemHeight: itemHeight,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Tampilan visual untuk Array Panel Surya
  Widget _buildSolarObject({
    required bool isSelected,
    required bool isActive,
    required int count,
    required double itemWidth,
    required double itemHeight,
  }) {
    const accentColor = Color(0xFF00E676); // Neon Green

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: itemWidth,
      height: itemHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accentColor : const Color(0xFF1E4F39),
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                ),
              ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Visual Panel Surya (Grid Modul)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 76,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [const Color(0xFF134E5E), const Color(0xFF71B280)]
                        : [Colors.grey.shade700, Colors.grey.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Colors.cyanAccent : Colors.grey,
                    width: 1.2,
                  ),
                ),
                child: CustomPaint(
                  painter: _SolarGridPainter(isActive: isActive),
                ),
              ),
              if (!isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Label Nama & Unit
          const Text(
            'Panel Surya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count Unit',
            style: TextStyle(
              color: isActive ? accentColor : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AKTIF GESTURE',
                style: TextStyle(
                  color: Color(0xFF091C14),
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  /// Tampilan visual untuk Turbin Angin dengan Animasi Putaran
  Widget _buildWindObject({
    required bool isSelected,
    required bool isActive,
    required int count,
    required Animation<double> rotationAnimation,
    required double itemWidth,
    required double itemHeight,
  }) {
    const accentColor = Color(0xFF00D2FF); // Cyan / Blue

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: itemWidth,
      height: itemHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accentColor : const Color(0xFF1E4F39),
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                ),
              ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Visual Turbin Angin Berputar
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Menara / Tiang
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 4,
                    height: 24,
                    color: Colors.white70,
                  ),
                ),
                // Baling-baling berputar
                Positioned(
                  top: 0,
                  child: AnimatedBuilder(
                    animation: rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: isActive
                            ? rotationAnimation.value * 2 * math.pi
                            : 0.0,
                        child: CustomPaint(
                          size: const Size(38, 38),
                          painter: _WindBladePainter(
                            bladeColor: isActive
                                ? const Color(0xFFE0F7FA)
                                : Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Label Nama & Unit
          const Text(
            'Turbin Angin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count Unit',
            style: TextStyle(
              color: isActive ? accentColor : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AKTIF GESTURE',
                style: TextStyle(
                  color: Color(0xFF091C14),
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar lanskap bukit, langit, dan matahari
class _LandscapePainter extends CustomPainter {
  final bool isSolarActive;
  final bool isWindActive;
  final double sunIntensity;
  final double windIntensity;

  _LandscapePainter({
    required this.isSolarActive,
    required this.isWindActive,
    required this.sunIntensity,
    required this.windIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Langit Gradasi
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF061A12), // Deep emerald night/dusk
          Color(0xFF0C2C1F),
          Color(0xFF144530),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Matahari Bersinar (Clean Glow)
    final sunCenter = Offset(size.width * 0.82, size.height * 0.22);
    final sunRadius = 18.0 + (sunIntensity * 8.0);

    final glowPaint = Paint()
      ..color = isSolarActive
          ? const Color(0xFFFFD54F).withOpacity(0.25 + (sunIntensity * 0.2))
          : Colors.grey.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(sunCenter, sunRadius * 1.8, glowPaint);

    final sunPaint = Paint()
      ..color = isSolarActive ? const Color(0xFFFFEE58) : Colors.grey.shade400;
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 3. Garis Angin Semilir di Langit
    if (isWindActive) {
      final windPaint = Paint()
        ..color = const Color(0xFF80DEEA).withOpacity(0.15 + (windIntensity * 0.2))
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final p1 = Path()
        ..moveTo(size.width * 0.1, size.height * 0.18)
        ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.14,
          size.width * 0.45,
          size.height * 0.20,
        );
      canvas.drawPath(p1, windPaint);

      final p2 = Path()
        ..moveTo(size.width * 0.35, size.height * 0.28)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.24,
          size.width * 0.7,
          size.height * 0.30,
        );
      canvas.drawPath(p2, windPaint);
    }

    // 4. Bukit Belakang (Lighter Dark Green)
    final backHillPaint = Paint()..color = const Color(0xFF0F3625);
    final backHillPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.45,
        size.width * 0.65,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.72,
        size.width,
        size.height * 0.60,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(backHillPath, backHillPaint);

    // 5. Bukit Depan (Deep Forest Green)
    final frontHillPaint = Paint()..color = const Color(0xFF0A261A);
    final frontHillPath = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.68,
        size.width * 0.75,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.88,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontHillPath, frontHillPaint);
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) {
    return oldDelegate.isSolarActive != isSolarActive ||
        oldDelegate.isWindActive != isWindActive ||
        oldDelegate.sunIntensity != sunIntensity ||
        oldDelegate.windIntensity != windIntensity;
  }
}

/// CustomPainter untuk sel solar array grid
class _SolarGridPainter extends CustomPainter {
  final bool isActive;

  _SolarGridPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isActive ? Colors.white.withOpacity(0.4) : Colors.white24
      ..strokeWidth = 1.0;

    // Garis vertikal
    canvas.drawLine(
        Offset(size.width * 0.33, 0), Offset(size.width * 0.33, size.height), linePaint);
    canvas.drawLine(
        Offset(size.width * 0.66, 0), Offset(size.width * 0.66, size.height), linePaint);

    // Garis horizontal
    canvas.drawLine(
        Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), linePaint);
  }

  @override
  bool shouldRepaint(covariant _SolarGridPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

/// CustomPainter untuk 3 bilah baling-baling turbin angin
class _WindBladePainter extends CustomPainter {
  final Color bladeColor;

  _WindBladePainter({required this.bladeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bladeLength = size.width / 2 - 2;

    final bladePaint = Paint()
      ..color = bladeColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(3, -bladeLength * 0.6, 0, -bladeLength)
        ..quadraticBezierTo(-3, -bladeLength * 0.6, 0, 0);
      canvas.drawPath(path, bladePaint);

      canvas.restore();
    }

    // Pusat rotor turbin
    final hubPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 3.5, hubPaint);
  }

  @override
  bool shouldRepaint(covariant _WindBladePainter oldDelegate) {
    return oldDelegate.bladeColor != bladeColor;
  }
}
