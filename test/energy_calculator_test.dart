import 'package:flutter_test/flutter_test.dart';
import 'package:ecogrid/models/energy_simulation.dart';
import 'package:ecogrid/utils/energy_calculator.dart';

void main() {
  group('EnergyCalculator Tests', () {
    test('Perhitungan nilai default harus tepat sesuai spesifikasi', () {
      const sim = EnergySimulation(
        solarPanelCount: 20,
        solarPanelPowerWp: 450.0,
        effectiveSunHours: 5.0,
        solarPerformanceRatio: 0.80,
        isSolarActive: true,
        windTurbineCount: 3,
        windTurbinePowerKw: 2.0,
        windCapacityFactor: 0.30,
        isWindActive: true,
        householdConsumptionKwhPerDay: 5.0,
      );

      final result = EnergyCalculator.calculate(sim);

      // Verifikasi nilai spesifikasi wajib:
      expect(result.solarPowerKw, closeTo(9.0, 0.001));
      expect(result.solarEnergyKwh, closeTo(36.0, 0.001));
      expect(result.windPowerKw, closeTo(6.0, 0.001));
      expect(result.windEnergyKwh, closeTo(43.2, 0.001));
      expect(result.totalPowerKw, closeTo(15.0, 0.001));
      expect(result.totalEnergyKwh, closeTo(79.2, 0.001));
      expect(result.homesPowered, equals(15));

      // Kontribusi persentase
      expect(result.solarContributionPercent, closeTo(36.0 / 79.2 * 100, 0.01));
      expect(result.windContributionPercent, closeTo(43.2 / 79.2 * 100, 0.01));
    });

    test('Penanganan kondisi nol (zero device & division by zero)', () {
      const simZero = EnergySimulation(
        solarPanelCount: 0,
        windTurbineCount: 0,
      );

      final result = EnergyCalculator.calculate(simZero);

      expect(result.solarPowerKw, equals(0.0));
      expect(result.solarEnergyKwh, equals(0.0));
      expect(result.windPowerKw, equals(0.0));
      expect(result.windEnergyKwh, equals(0.0));
      expect(result.totalPowerKw, equals(0.0));
      expect(result.totalEnergyKwh, equals(0.0));
      expect(result.homesPowered, equals(0));
      expect(result.solarContributionPercent, equals(0.0));
      expect(result.windContributionPercent, equals(0.0));
    });

    test('Penanganan penonaktifan perangkat individual (switch off)', () {
      const simInactive = EnergySimulation(
        solarPanelCount: 20,
        isSolarActive: false,
        windTurbineCount: 3,
        isWindActive: true,
      );

      final result = EnergyCalculator.calculate(simInactive);

      expect(result.solarPowerKw, equals(0.0));
      expect(result.solarEnergyKwh, equals(0.0));
      expect(result.windEnergyKwh, closeTo(43.2, 0.001));
      expect(result.totalEnergyKwh, closeTo(43.2, 0.001));
      expect(result.solarContributionPercent, equals(0.0));
      expect(result.windContributionPercent, closeTo(100.0, 0.001));
    });

    test('Perubahan jumlah perangkat mengubah hasil kalkulasi secara dinamis', () {
      const sim = EnergySimulation(
        solarPanelCount: 40, // 2x lipat
        windTurbineCount: 6, // 2x lipat
      );

      final result = EnergyCalculator.calculate(sim);

      expect(result.solarPowerKw, closeTo(18.0, 0.001));
      expect(result.solarEnergyKwh, closeTo(72.0, 0.001));
      expect(result.windPowerKw, closeTo(12.0, 0.001));
      expect(result.windEnergyKwh, closeTo(86.4, 0.001));
      expect(result.totalEnergyKwh, closeTo(158.4, 0.001));
      expect(result.homesPowered, equals(31)); // floor(158.4 / 5) = 31
    });
  });
}
