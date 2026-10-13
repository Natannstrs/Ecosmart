import 'package:flutter/material.dart';
import '../models/energy_simulation.dart';

/// Panel kontrol lengkap untuk mengatur parameter perangkat, cuaca, dan kapasitas
class EnergyControlPanel extends StatelessWidget {
  final EnergySimulation simulation;
  final ValueChanged<EnergySimulation> onSimulationChanged;
  final VoidCallback onResetToDefault;

  const EnergyControlPanel({
    super.key,
    required this.simulation,
    required this.onSimulationChanged,
    required this.onResetToDefault,
  });

  @override
  Widget build(BuildContext context) {
    const solarColor = Color(0xFF00E676);
    const windColor = Color(0xFF00D2FF);

    return Container(
      padding: const EdgeInsets.all(18),
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
          // Header Panel Kontrol + Tombol Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF00E676),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Kontrol Parameter Simulasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onResetToDefault,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5252),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  backgroundColor: const Color(0xFF2B1619),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF5E2328)),
                  ),
                ),
                icon: const Icon(Icons.restart_alt_rounded, size: 16),
                label: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 1. KONTROL PANEL SURYA
          _buildDeviceSectionHeader(
            title: 'Pembangkit Listrik Tenaga Surya (PLTS)',
            icon: Icons.solar_power_rounded,
            color: solarColor,
            isActive: simulation.isSolarActive,
            onToggle: (val) {
              onSimulationChanged(simulation.copyWith(isSolarActive: val));
            },
          ),
          const SizedBox(height: 10),

          // Counter Jumlah Panel Surya
          _buildCounterRow(
            label: 'Jumlah Panel Surya',
            count: simulation.solarPanelCount,
            unit: 'unit',
            color: solarColor,
            min: 0,
            max: 100,
            onChanged: (newCount) {
              onSimulationChanged(simulation.copyWith(solarPanelCount: newCount));
            },
          ),
          const SizedBox(height: 8),

          // Slider Intensitas Matahari (Jam Efektif)
          _buildSliderTile(
            title: 'Jam Matahari Efektif',
            value: simulation.effectiveSunHours,
            displayValue:
                '${simulation.effectiveSunHours.toStringAsFixed(1)} jam/hari',
            min: 1.0,
            max: 10.0,
            divisions: 18,
            color: solarColor,
            onChanged: (val) {
              onSimulationChanged(simulation.copyWith(effectiveSunHours: val));
            },
          ),

          // Slider Kapasitas Panel Wp
          _buildSliderTile(
            title: 'Kapasitas per Panel (Wp)',
            value: simulation.solarPanelPowerWp,
            displayValue: '${simulation.solarPanelPowerWp.toInt()} Wp',
            min: 200.0,
            max: 650.0,
            divisions: 9,
            color: solarColor,
            onChanged: (val) {
              onSimulationChanged(
                  simulation.copyWith(solarPanelPowerWp: val));
            },
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFF1E4835)),
          const SizedBox(height: 12),

          // 2. KONTROL TURBIN ANGIN
          _buildDeviceSectionHeader(
            title: 'Pembangkit Listrik Tenaga Bayu (PLTB)',
            icon: Icons.wind_power_rounded,
            color: windColor,
            isActive: simulation.isWindActive,
            onToggle: (val) {
              onSimulationChanged(simulation.copyWith(isWindActive: val));
            },
          ),
          const SizedBox(height: 10),

          // Counter Jumlah Turbin Angin
          _buildCounterRow(
            label: 'Jumlah Turbin Angin',
            count: simulation.windTurbineCount,
            unit: 'unit',
            color: windColor,
            min: 0,
            max: 20,
            onChanged: (newCount) {
              onSimulationChanged(
                  simulation.copyWith(windTurbineCount: newCount));
            },
          ),
          const SizedBox(height: 8),

          // Slider Faktor Kapasitas Angin
          _buildSliderTile(
            title: 'Faktor Kapasitas Angin (CF)',
            value: simulation.windCapacityFactor,
            displayValue:
                '${(simulation.windCapacityFactor * 100).toStringAsFixed(0)}%',
            min: 0.05,
            max: 0.80,
            divisions: 15,
            color: windColor,
            onChanged: (val) {
              onSimulationChanged(
                  simulation.copyWith(windCapacityFactor: val));
            },
          ),

          // Slider Kapasitas per Turbin kW
          _buildSliderTile(
            title: 'Kapasitas per Turbin (kW)',
            value: simulation.windTurbinePowerKw,
            displayValue:
                '${simulation.windTurbinePowerKw.toStringAsFixed(1)} kW',
            min: 1.0,
            max: 10.0,
            divisions: 18,
            color: windColor,
            onChanged: (val) {
              onSimulationChanged(
                  simulation.copyWith(windTurbinePowerKw: val));
            },
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFF1E4835)),
          const SizedBox(height: 12),

          // 3. PARAMETER KONSUMSI RUMAH TANGGA
          Row(
            children: [
              const Icon(
                Icons.home_work_rounded,
                color: Color(0xFFFFB300),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Asumsi Konsumsi Rumah Tangga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${simulation.householdConsumptionKwhPerDay.toStringAsFixed(1)} kWh/hari',
                style: const TextStyle(
                  color: Color(0xFFFFB300),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFFFB300),
              inactiveTrackColor: const Color(0xFF1A3D2C),
              thumbColor: const Color(0xFFFFB300),
              overlayColor: const Color(0xFFFFB300).withOpacity(0.2),
              trackHeight: 3.5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: simulation.householdConsumptionKwhPerDay,
              min: 2.0,
              max: 15.0,
              divisions: 26,
              onChanged: (val) {
                onSimulationChanged(
                    simulation.copyWith(householdConsumptionKwhPerDay: val));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required bool isActive,
    required ValueChanged<bool> onToggle,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? 'Aktif' : 'Off',
              style: TextStyle(
                color: isActive ? color : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isActive,
                activeColor: color,
                activeTrackColor: color.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: const Color(0xFF193B2B),
                onChanged: onToggle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int count,
    required String unit,
    required Color color,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D241B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B4532)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94B5A3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: count > min ? () => onChanged(count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: color,
                disabledColor: Colors.grey.withOpacity(0.3),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 44),
                alignment: Alignment.center,
                child: Text(
                  '$count $unit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: count < max ? () => onChanged(count + 1) : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: color,
                disabledColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF88AA97),
                fontSize: 11,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: const Color(0xFF183B2B),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
