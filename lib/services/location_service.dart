import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_data.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Stream<Position>? _positionStream;

  /// Check and request location permissions
  Future<bool> checkAndRequestPermissions() async {
    // Check location permission
    PermissionStatus locationStatus = await Permission.location.status;
    
    if (locationStatus.isDenied) {
      locationStatus = await Permission.location.request();
    }

    if (locationStatus.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    return locationStatus.isGranted;
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Start tracking location with continuous updates
  Stream<Position> getLocationStream() {
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
    return _positionStream!;
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Convert Position to LocationData
  LocationData positionToLocationData(Position position, String userId) {
    return LocationData(
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );
  }

  /// Get address from coordinates using geocoding
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Convert Position to LocationData with address
  Future<LocationData> positionToLocationDataWithAddress(Position position, String userId) async {
    String? address = await getAddressFromCoordinates(position.latitude, position.longitude);
    return LocationData(
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      address: address,
    );
  }
}