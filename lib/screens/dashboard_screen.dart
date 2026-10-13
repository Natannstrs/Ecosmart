import 'package:flutter/material.dart';
import '../models/energy_device.dart';
import '../models/energy_simulation.dart';
import '../utils/energy_calculator.dart';
import '../widgets/device_detail_sheet.dart';
import '../widgets/energy_contribution_chart.dart';
import '../widgets/energy_control_panel.dart';
import '../widgets/energy_stat_card.dart';
import '../widgets/interactive_energy_canvas.dart';

/// Layar Utama Dashboard EcoGrid Energy Simulator
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // Model state simulasi
  EnergySimulation _simulation = const EnergySimulation();

  // State gesture & interaksi kanvas
  DeviceType _selectedDevice = DeviceType.solar;
  Offset _solarPosition = const Offset(24, 85);
  Offset _windPosition = const Offset(190, 75);

  // Indikator status gesture terakhir untuk pembuktian interaktivitas
  String _lastGestureType = 'TAP';
  String _lastGestureTarget = 'Panel Surya';
  String _lastGestureDetail = 'Posisi: (24, 85) - Terpilih';
  Color _lastGestureColor = const Color(0xFF00E676);

  // Controller animasi pulsing indikator LIVE SIMULATION
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Helper untuk reset nilai ke default
  void _resetToDefault() {
    setState(() {
      _simulation = const EnergySimulation();
      _solarPosition = const Offset(24, 85);
      _windPosition = const Offset(190, 75);
      _lastGestureType = 'RESET';
      _lastGestureTarget = 'Semua Parameter';
      _lastGestureDetail = 'Parameter dikembalikan ke nilai default';
      _lastGestureColor = const Color(0xFFFF5252);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF163C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00E676)),
        ),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF00E676)),
            SizedBox(width: 10),
            Text(
              'Parameter simulasi berhasil di-reset ke nilai default!',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Handler 1: TAP GESTURE
  void _handleDeviceTap(DeviceType type) {
    setState(() {
      _selectedDevice = type;
      _lastGestureType = 'TAP GESTURE';
      _lastGestureTarget =
          type == DeviceType.solar ? 'Panel Surya' : 'Turbin Angin';
      final pos = type == DeviceType.solar ? _solarPosition : _windPosition;
      _lastGestureDetail =
          'Perangkat dipilih • Koordinat: (${pos.dx.toInt()}, ${pos.dy.toInt()})';
      _lastGestureColor = type == DeviceType.solar
          ? const Color(0xFF00E676)
          : const Color(0xFF00D2FF);
    });
  }

  // Handler 2: LONG PRESS GESTURE
  void _handleDeviceLongPress(DeviceType type) {
    final targetName =
        type == DeviceType.solar ? 'Panel Surya' : 'Turbin Angin';

    setState(() {
      _selectedDevice = type;
      _lastGestureType = 'LONG PRESS GESTURE';
      _lastGestureTarget = targetName;
      _lastGestureDetail = 'Membuka Modal Detail & Kontrol Status';
      _lastGestureColor = const Color(0xFFFFD54F);
    });

    DeviceDetailSheet.show(
      context: context,
      deviceType: type,
      simulation: _simulation,
      onToggleActive: (val) {
        setState(() {
          if (type == DeviceType.solar) {
            _simulation = _simulation.copyWith(isSolarActive: val);
          } else {
            _simulation = _simulation.copyWith(isWindActive: val);
          }
        });
        Navigator.of(context).pop();
      },
      onCountChanged: (newCount) {
        setState(() {
          if (type == DeviceType.solar) {
            _simulation = _simulation.copyWith(solarPanelCount: newCount);
          } else {
            _simulation = _simulation.copyWith(windTurbineCount: newCount);
          }
        });
      },
    );
  }

  // Handler 3: PAN / DRAG GESTURE
  void _handleDeviceDrag(DeviceType type, Offset newPosition) {
    setState(() {
      _selectedDevice = type;
      if (type == DeviceType.solar) {
        _solarPosition = newPosition;
      } else {
        _windPosition = newPosition;
      }
      _lastGestureType = 'DRAG/PAN GESTURE';
      _lastGestureTarget =
          type == DeviceType.solar ? 'Panel Surya' : 'Turbin Angin';
      _lastGestureDetail =
          'Posisi baru: (${newPosition.dx.toInt()}, ${newPosition.dy.toInt()})';
      _lastGestureColor = const Color(0xFFE040FB);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = EnergyCalculator.calculate(_simulation);
    final activeDevicesCount = (_simulation.isSolarActive ? _simulation.solarPanelCount : 0) +
        (_simulation.isWindActive ? _simulation.windTurbineCount : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1913),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C241B),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00E676).withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Color(0xFF00E676),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoGrid Simulator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'NIM: 202431091 (Ganjil) • SDG 7 & 13',
                  style: TextStyle(
                    color: Color(0xFF8BAE9B),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Indikator LIVE SIMULATION
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF133626),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E523A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00E676),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE SIMULATION',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BANNER FEEDBACK GESTURE TERAKHIR
              _buildGestureFeedbackBanner(),

              const SizedBox(height: 14),

              // 2. KANVAS PEMBANGKIT INTERAKTIF (Stack + LayoutBuilder + Gestures)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kanvas Pembangkit Interaktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Objek Terpilih: ${_selectedDevice == DeviceType.solar ? "Panel Surya" : "Turbin Angin"}',
                    style: TextStyle(
                      color: _selectedDevice == DeviceType.solar
                          ? const Color(0xFF00E676)
                          : const Color(0xFF00D2FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              InteractiveEnergyCanvas(
                simulation: _simulation,
                solarPosition: _solarPosition,
                windPosition: _windPosition,
                selectedDevice: _selectedDevice,
                onDeviceTap: _handleDeviceTap,
                onDeviceLongPress: _handleDeviceLongPress,
                onDeviceDrag: _handleDeviceDrag,
              ),

              const SizedBox(height: 18),

              // 3. STATISTIK UTAMA
              const Text(
                'Ringkasan Produksi Daya & Energi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Grid Kartu Statistik
              Row(
                children: [
                  Expanded(
                    child: EnergyStatCard(
                      title: 'Total Daya Nominal',
                      value: result.totalPowerKw,
                      unit: 'kW',
                      icon: Icons.flash_on_rounded,
                      accentColor: const Color(0xFF00E676),
                      subtitle: 'Kapasitas terpasang',
                      isSelected: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: EnergyStatCard(
                      title: 'Total Energi Harian',
                      value: result.totalEnergyKwh,
                      unit: 'kWh/hari',
                      icon: Icons.battery_charging_full_rounded,
                      accentColor: const Color(0xFF00D2FF),
                      subtitle: 'Produksi per hari',
                      isSelected: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: EnergyStatCard(
                      title: 'Rumah Disuplai',
                      value: result.homesPowered.toDouble(),
                      unit: 'Rumah',
                      icon: Icons.holiday_village_rounded,
                      accentColor: const Color(0xFFFFB300),
                      subtitle:
                          'Asumsi ${_simulation.householdConsumptionKwhPerDay.toStringAsFixed(0)} kWh/hari',
                      decimalPlaces: 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: EnergyStatCard(
                      title: 'Reduksi Emisi CO₂',
                      value: result.co2AvoidedKg,
                      unit: 'kg/hari',
                      icon: Icons.eco_rounded,
                      accentColor: const Color(0xFF69F0AE),
                      subtitle: 'Dampak Bersih SDG 13',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Breakdown Detail Surya vs Angin
              Row(
                children: [
                  Expanded(
                    child: EnergyStatCard(
                      title: 'Energi Surya',
                      value: result.solarEnergyKwh,
                      unit: 'kWh/hari',
                      icon: Icons.wb_sunny_rounded,
                      accentColor: const Color(0xFF00E676),
                      subtitle: 'Daya: ${result.solarPowerKw.toStringAsFixed(1)} kW',
                      isSelected: _selectedDevice == DeviceType.solar,
                      onTap: () => _handleDeviceTap(DeviceType.solar),
                      onLongPress: () =>
                          _handleDeviceLongPress(DeviceType.solar),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: EnergyStatCard(
                      title: 'Energi Angin',
                      value: result.windEnergyKwh,
                      unit: 'kWh/hari',
                      icon: Icons.air_rounded,
                      accentColor: const Color(0xFF00D2FF),
                      subtitle: 'Daya: ${result.windPowerKw.toStringAsFixed(1)} kW',
                      isSelected: _selectedDevice == DeviceType.wind,
                      onTap: () => _handleDeviceTap(DeviceType.wind),
                      onLongPress: () =>
                          _handleDeviceLongPress(DeviceType.wind),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. DIAGRAM KONTRIBUSI SUMBER ENERGI
              EnergyContributionChart(
                solarKwh: result.solarEnergyKwh,
                windKwh: result.windEnergyKwh,
                totalKwh: result.totalEnergyKwh,
                solarPercent: result.solarContributionPercent,
                windPercent: result.windContributionPercent,
                onSolarTap: () => _handleDeviceTap(DeviceType.solar),
                onWindTap: () => _handleDeviceTap(DeviceType.wind),
              ),

              const SizedBox(height: 16),

              // 5. STATUS PERANGKAT & LINGKUNGAN RINGKAS
              _buildEnvironmentStatusCard(activeDevicesCount),

              const SizedBox(height: 16),

              // 6. PANEL KONTROL SIMULASI
              EnergyControlPanel(
                simulation: _simulation,
                onSimulationChanged: (newSim) {
                  setState(() {
                    _simulation = newSim;
                  });
                },
                onResetToDefault: _resetToDefault,
              ),

              const SizedBox(height: 16),

              // 7. CATATAN EDUKASI & KELAYAKAN SDG 7 & SDG 13
              _buildEducationalFooter(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner penunjuk gesture yang aktif
  Widget _buildGestureFeedbackBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2B1F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lastGestureColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: _lastGestureColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _lastGestureColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app_rounded,
              color: _lastGestureColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _lastGestureType,
                      style: TextStyle(
                        color: _lastGestureColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $_lastGestureTarget',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _lastGestureDetail,
                  style: const TextStyle(
                    color: Color(0xFF90B5A2),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu status parameter lingkungan dan perangkat aktif
  Widget _buildEnvironmentStatusCard(int activeDevicesCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F291E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E4D37)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStatus(
            icon: Icons.devices_rounded,
            label: 'Perangkat Aktif',
            value: '$activeDevicesCount Unit',
            color: const Color(0xFF00E676),
          ),
          Container(width: 1, height: 32, color: const Color(0xFF1F4836)),
          _buildMiniStatus(
            icon: Icons.wb_sunny_rounded,
            label: 'Matahari',
            value: '${_simulation.effectiveSunHours.toStringAsFixed(1)} Jam',
            color: const Color(0xFFFFD54F),
          ),
          Container(width: 1, height: 32, color: const Color(0xFF1F4836)),
          _buildMiniStatus(
            icon: Icons.air_rounded,
            label: 'Kapasitas Angin',
            value: '${(_simulation.windCapacityFactor * 100).toInt()}%',
            color: const Color(0xFF00D2FF),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatus({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8BAE9B),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Banner informasi edukatif SDG 7 & SDG 13
  Widget _buildEducationalFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2118),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF19412F)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFF00E676), size: 18),
              SizedBox(width: 8),
              Text(
                'Catatan Simulasi Edukatif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Data ini merupakan simulasi matematis edukatif untuk memahami dinamika pembangkit listrik energi terbarukan.\n'
            '• Produksi riil di lapangan dipengaruhi oleh kondisi cuaca lokal, efisiensi inverter, sudut kemiringan (tilt angle), dan rugi-rugi jaringan.\n'
            '• Aplikasi ini mendukung target SDG 7 (Akses Energi Bersih & Terjangkau) dan SDG 13 (Tindakan Terhadap Perubahan Iklim).',
            style: TextStyle(
              color: Color(0xFF86A896),
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
