class LocationData {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? address;
  final bool isEmergency;

  LocationData({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.address,
    this.isEmergency = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'address': address,
      'isEmergency': isEmergency,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      userId: json['userId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      address: json['address'] as String?,
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}