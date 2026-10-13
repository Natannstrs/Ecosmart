/// Model representasi data konfigurasi dan hasil simulasi EcoGrid
class EnergySimulation {
  // Parameter Panel Surya
  final int solarPanelCount;
  final double solarPanelPowerWp; // Wp per panel
  final double effectiveSunHours; // Jam efektif per hari
  final double solarPerformanceRatio; // Efisiensi PR (misal 0.80)
  final bool isSolarActive;

  // Parameter Turbin Angin
  final int windTurbineCount;
  final double windTurbinePowerKw; // kW per turbin
  final double windCapacityFactor; // Faktor kapasitas (misal 0.30)
  final bool isWindActive;

  // Asumsi Lingkungan & Konsumsi
  final double householdConsumptionKwhPerDay; // kWh per rumah per hari

  const EnergySimulation({
    this.solarPanelCount = 20,
    this.solarPanelPowerWp = 450.0,
    this.effectiveSunHours = 5.0,
    this.solarPerformanceRatio = 0.80,
    this.isSolarActive = true,
    this.windTurbineCount = 3,
    this.windTurbinePowerKw = 2.0,
    this.windCapacityFactor = 0.30,
    this.isWindActive = true,
    this.householdConsumptionKwhPerDay = 5.0,
  });

  EnergySimulation copyWith({
    int? solarPanelCount,
    double? solarPanelPowerWp,
    double? effectiveSunHours,
    double? solarPerformanceRatio,
    bool? isSolarActive,
    int? windTurbineCount,
    double? windTurbinePowerKw,
    double? windCapacityFactor,
    bool? isWindActive,
    double? householdConsumptionKwhPerDay,
  }) {
    return EnergySimulation(
      solarPanelCount: solarPanelCount ?? this.solarPanelCount,
      solarPanelPowerWp: solarPanelPowerWp ?? this.solarPanelPowerWp,
      effectiveSunHours: effectiveSunHours ?? this.effectiveSunHours,
      solarPerformanceRatio:
          solarPerformanceRatio ?? this.solarPerformanceRatio,
      isSolarActive: isSolarActive ?? this.isSolarActive,
      windTurbineCount: windTurbineCount ?? this.windTurbineCount,
      windTurbinePowerKw: windTurbinePowerKw ?? this.windTurbinePowerKw,
      windCapacityFactor: windCapacityFactor ?? this.windCapacityFactor,
      isWindActive: isWindActive ?? this.isWindActive,
      householdConsumptionKwhPerDay:
          householdConsumptionKwhPerDay ?? this.householdConsumptionKwhPerDay,
    );
  }
}
