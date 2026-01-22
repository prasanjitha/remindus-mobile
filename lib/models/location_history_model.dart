import 'package:cloud_firestore/cloud_firestore.dart';

class LocationHistoryModel {
  final String? locationId;
  final double latitude;
  final double longitude;
  final String familyId;
  final DateTime? recordedAt;

  LocationHistoryModel({
    this.locationId,
    required this.latitude,
    required this.longitude,
    required this.familyId,
    this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'familyId': familyId,
    
      'recordedAt': recordedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory LocationHistoryModel.fromMap(Map<String, dynamic> map) {
    return LocationHistoryModel(
      locationId: map['locationId'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      familyId: map['familyId'] as String? ?? '',
      recordedAt: map['recordedAt'] != null 
          ? (map['recordedAt'] as Timestamp).toDate() 
          : null,
    );
  }
}