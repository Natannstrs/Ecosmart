import 'package:flutter/material.dart';
import '../models/energy_device.dart';
import '../models/energy_simulation.dart';
import '../utils/energy_calculator.dart';

/// Modal Bottom Sheet untuk Long Press Gesture
class DeviceDetailSheet extends StatelessWidget {
  final DeviceType deviceType;
  final EnergySimulation simulation;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<int>? onCountChanged;

  const DeviceDetailSheet({
    super.key,
    required this.deviceType,
    required this.simulation,
    required this.onToggleActive,
    this.onCountChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required DeviceType deviceType,
    required EnergySimulation simulation,
    required ValueChanged<bool> onToggleActive,
    ValueChanged<int>? onCountChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DeviceDetailSheet(
        deviceType: deviceType,
        simulation: simulation,
        onToggleActive: onToggleActive,
        onCountChanged: onCountChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSolar = deviceType == DeviceType.solar;
    final primaryColor =
        isSolar ? const Color(0xFF00E676) : const Color(0xFF00D2FF);

    final title =
        isSolar ? 'Array Panel Surya (Solar Photovoltaic)' : 'Turbin Angin (Wind Turbine)';
    final icon = isSolar ? Icons.solar_power_rounded : Icons.wind_power_rounded;
    final isActive = isSolar ? simulation.isSolarActive : simulation.isWindActive;
    final count = isSolar ? simulation.solarPanelCount : simulation.windTurbineCount;
    final unitCap = isSolar
        ? '${simulation.solarPanelPowerWp.toInt()} Wp / panel'
        : '${simulation.windTurbinePowerKw.toStringAsFixed(1)} kW / turbin';

    final result = EnergyCalculator.calculate(simulation);
    final totalPower = isSolar ? result.solarPowerKw : result.windPowerKw;
    final totalEnergy = isSolar ? result.solarEnergyKwh : result.windEnergyKwh;
    final contribution =
        isSolar ? result.solarContributionPercent : result.windContributionPercent;

    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0D241B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF1F4A38), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF275440),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header with device icon & status switch
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryColor.withOpacity(0.4)),
                ),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive ? 'Status: AKTIF' : 'Status: NONAKTIF',
                      style: TextStyle(
                        color: isActive ? primaryColor : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch Toggle
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: isActive,
                  activeColor: primaryColor,
                  activeTrackColor: primaryColor.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: const Color(0xFF1A382B),
                  onChanged: (val) {
                    onToggleActive(val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFF1A3D2D)),
          const SizedBox(height: 12),

          // Detail Grid Data
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  label: 'Jumlah Unit',
                  value: '$count Unit',
                  icon: Icons.numbers_rounded,
                  accentColor: primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetailTile(
                  label: 'Kapasitas per Unit',
                  value: unitCap,
                  icon: Icons.speed_rounded,
                  accentColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  label: 'Total Daya Nominal',
                  value: '${totalPower.toStringAsFixed(2)} kW',
                  icon: Icons.bolt_rounded,
                  accentColor: primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetailTile(
                  label: 'Estimasi Energi Harian',
                  value: '${totalEnergy.toStringAsFixed(2)} kWh',
                  icon: Icons.electric_meter_rounded,
                  accentColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDetailTile(
            label: 'Pangsa Kontribusi Grid',
            value: '${contribution.toStringAsFixed(1)}% dari total produksi',
            icon: Icons.pie_chart_rounded,
            accentColor: primaryColor,
          ),

          const SizedBox(height: 18),

          // Quick Count Controller (if callback provided)
          if (onCountChanged != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF132F23),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E4835)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Atur Jumlah Unit:',
                    style: TextStyle(
                      color: Color(0xFF9EBAAA),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: count > 0
                            ? () => onCountChanged!(count - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: primaryColor,
                        disabledColor: Colors.grey.withOpacity(0.3),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onCountChanged!(count + 1),
                        icon: const Icon(Icons.add_circle_outline),
                        color: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF275A44)),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text(
                'Tutup Detail',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF122C21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1D4533)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor.withOpacity(0.8), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF86A594),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
}
