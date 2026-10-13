import 'package:flutter/material.dart';

enum DeviceType { solar, wind }

/// Model untuk entitas perangkat pada kanvas interaktif EcoGrid
class EnergyDevice {
  final String id;
  final String name;
  final DeviceType type;
  final Offset position; // Koordinat (X, Y) relatif terhadap kanvas
  final bool isSelected;
  final bool isActive;

  const EnergyDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.isSelected = false,
    this.isActive = true,
  });

  EnergyDevice copyWith({
    String? id,
    String? name,
    DeviceType? type,
    Offset? position,
    bool? isSelected,
    bool? isActive,
  }) {
    return EnergyDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      position: position ?? this.position,
      isSelected: isSelected ?? this.isSelected,
      isActive: isActive ?? this.isActive,
    );
  }
}
