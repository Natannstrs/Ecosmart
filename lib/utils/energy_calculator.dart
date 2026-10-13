import '../models/energy_simulation.dart';

/// Kelas hasil kalkulasi energi EcoGrid
class EnergyCalculationResult {
  final double solarPowerKw; // Daya nominal surya (kW)
  final double solarEnergyKwh; // Energi harian surya (kWh/hari)
  final double windPowerKw; // Daya nominal angin (kW)
  final double windEnergyKwh; // Energi harian angin (kWh/hari)
  final double totalPowerKw; // Total daya nominal (kW)
  final double totalEnergyKwh; // Total energi harian (kWh/hari)
  final int homesPowered; // Estimasi rumah yang disuplai
  final double solarContributionPercent; // % kontribusi surya
  final double windContributionPercent; // % kontribusi angin
  final double co2AvoidedKg; // Estimasi reduksi CO2 (kg/hari) untuk SDG 13

  const EnergyCalculationResult({
    required this.solarPowerKw,
    required this.solarEnergyKwh,
    required this.windPowerKw,
    required this.windEnergyKwh,
    required this.totalPowerKw,
    required this.totalEnergyKwh,
    required this.homesPowered,
    required this.solarContributionPercent,
    required this.windContributionPercent,
    required this.co2AvoidedKg,
  });
}

/// Utility murni untuk perhitungan matematis energi EcoGrid
class EnergyCalculator {
  /// Faktor emisi grid standar (kg CO2 per kWh) untuk menghitung kontribusi SDG 13
  static const double co2EmissionFactorPerKwh = 0.785;

  /// Menghitung seluruh metrik energi berdasarkan parameter simulasi
  static EnergyCalculationResult calculate(EnergySimulation sim) {
    // 1. Perhitungan Surya
    final double solarPowerKw;
    final double solarEnergyKwh;

    if (sim.isSolarActive && sim.solarPanelCount > 0) {
      solarPowerKw = (sim.solarPanelCount * sim.solarPanelPowerWp) / 1000.0;
      solarEnergyKwh = (sim.solarPanelCount *
              sim.solarPanelPowerWp *
              sim.effectiveSunHours *
              sim.solarPerformanceRatio) /
          1000.0;
    } else {
      solarPowerKw = 0.0;
      solarEnergyKwh = 0.0;
    }

    // 2. Perhitungan Angin
    final double windPowerKw;
    final double windEnergyKwh;

    if (sim.isWindActive && sim.windTurbineCount > 0) {
      windPowerKw = sim.windTurbineCount * sim.windTurbinePowerKw;
      windEnergyKwh = sim.windTurbineCount *
          sim.windTurbinePowerKw *
          sim.windCapacityFactor *
          24.0;
    } else {
      windPowerKw = 0.0;
      windEnergyKwh = 0.0;
    }

    // 3. Total Daya dan Energi
    final double totalPowerKw = solarPowerKw + windPowerKw;
    final double totalEnergyKwh = solarEnergyKwh + windEnergyKwh;

    // 4. Rumah yang Disuplai (menggunakan floor)
    final int homesPowered;
    if (sim.householdConsumptionKwhPerDay > 0 && totalEnergyKwh > 0) {
      homesPowered = (totalEnergyKwh / sim.householdConsumptionKwhPerDay).floor();
    } else {
      homesPowered = 0;
    }

    // 5. Persentase Kontribusi (penanganan pembagian dengan nol)
    final double solarContributionPercent;
    final double windContributionPercent;

    if (totalEnergyKwh > 0) {
      solarContributionPercent = (solarEnergyKwh / totalEnergyKwh) * 100.0;
      windContributionPercent = (windEnergyKwh / totalEnergyKwh) * 100.0;
    } else {
      solarContributionPercent = 0.0;
      windContributionPercent = 0.0;
    }

    // 6. Reduksi Emisi CO2
    final double co2AvoidedKg = totalEnergyKwh * co2EmissionFactorPerKwh;

    return EnergyCalculationResult(
      solarPowerKw: solarPowerKw,
      solarEnergyKwh: solarEnergyKwh,
      windPowerKw: windPowerKw,
      windEnergyKwh: windEnergyKwh,
      totalPowerKw: totalPowerKw,
      totalEnergyKwh: totalEnergyKwh,
      homesPowered: homesPowered,
      solarContributionPercent: solarContributionPercent,
      windContributionPercent: windContributionPercent,
      co2AvoidedKg: co2AvoidedKg,
    );
  }
}
