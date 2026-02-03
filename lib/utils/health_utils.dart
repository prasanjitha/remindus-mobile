import 'package:flutter/material.dart';

enum HealthLevel { normal, elevated, low, high, crisis }

class HealthStatus {
  final String label;
  final Color color;
  final HealthLevel level;

  const HealthStatus({
    required this.label,
    required this.color,
    required this.level,
  });

  static const normal = HealthStatus(
    label: "Healthy",
    color: Color(0xFF4CAF50),
    level: HealthLevel.normal,
  );
  static const elevated = HealthStatus(
    label: "Caution",
    color: Color(0xFFFF9800),
    level: HealthLevel.elevated,
  );
  static const low = HealthStatus(
    label: "Dangerously Low",
    color: Color(0xFF2196F3),
    level: HealthLevel.low,
  );
  static const high = HealthStatus(
    label: "Hypertension",
    color: Color(0xFFF44336),
    level: HealthLevel.high,
  );
  static const highStage2 = HealthStatus(
    label: "Seek Medical Advice",
    color: Color(0xFFD32F2F),
    level: HealthLevel.high,
  );
  static const crisis = HealthStatus(
    label: "Emergency!",
    color: Color(0xFFB71C1C),
    level: HealthLevel.crisis,
  );
  static const unknown = HealthStatus(
    label: "N/A",
    color: Colors.grey,
    level: HealthLevel.normal,
  );
}

class HealthUtils {
  static HealthStatus getHeartRateStatus(dynamic value) {
    if (value == null) return HealthStatus.unknown;
    int? rate;
    if (value is String) {
      rate = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    } else if (value is int) {
      rate = value;
    }

    if (rate == null) return HealthStatus.unknown;

    if (rate > 100) return HealthStatus.high;
    if (rate < 60) return HealthStatus.low;
    return HealthStatus.normal;
  }

  static HealthStatus getBloodPressureStatus(String? bpValue) {
    if (bpValue == null || bpValue.isEmpty || bpValue == "N/A") {
      return HealthStatus.unknown;
    }

    try {
      // Handle values like "120/80 mmHg" or just "120/80" or even "120"
      final String cleanValue = bpValue
          .replaceAll(RegExp(r'[^\d\s/-]'), ' ')
          .trim();

      // Try splitting by common separators
      List<String> parts = [];
      if (cleanValue.contains('/')) {
        parts = cleanValue.split('/');
      } else if (cleanValue.contains('-')) {
        parts = cleanValue.split('-');
      } else {
        // If no common separator, try splitting by space or assume it's a single value
        final List<String> spaceParts = cleanValue.split(RegExp(r'\s+'));
        if (spaceParts.isNotEmpty && spaceParts[0].isNotEmpty) {
          parts = spaceParts;
        } else {
          parts = [cleanValue]; // Treat the whole string as a single value
        }
      }

      if (parts.isEmpty || parts[0].isEmpty) return HealthStatus.unknown;

      final int? systolic = int.tryParse(parts[0].trim());
      final int? diastolic = parts.length > 1
          ? int.tryParse(parts[1].trim())
          : null;

      if (systolic == null) return HealthStatus.unknown;

      // Crisis: S > 180 OR D > 120
      if (systolic > 180 || (diastolic != null && diastolic > 120)) {
        return HealthStatus.crisis;
      }

      // High (Stage 2): S >= 140 OR D >= 90
      if (systolic >= 140 || (diastolic != null && diastolic >= 90)) {
        return HealthStatus.highStage2;
      }

      // High (Stage 1): S 130-139 OR D 80-89
      if ((systolic >= 130 && systolic <= 139) ||
          (diastolic != null && diastolic >= 80 && diastolic <= 89)) {
        return HealthStatus.high;
      }

      // Elevated: S 120-129 AND D < 80
      if (systolic >= 120 &&
          systolic <= 129 &&
          (diastolic == null || diastolic < 80)) {
        return HealthStatus.elevated;
      }

      // Normal: S 90-120 AND D 60-80
      if (systolic >= 90 &&
          systolic <= 120 &&
          (diastolic == null || (diastolic >= 60 && diastolic <= 80))) {
        return HealthStatus.normal;
      }

      // Low: S < 90 OR D < 60
      if (systolic < 90 || (diastolic != null && diastolic < 60)) {
        return HealthStatus.low;
      }

      return HealthStatus.normal;
    } catch (e) {
      return HealthStatus.unknown;
    }
  }
}
