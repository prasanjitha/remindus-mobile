import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/models/location_history_model.dart';
import 'package:remindus/screens/sos/emwrgency_sos_main_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class MapTrackingScreen extends StatefulWidget {
  final String activeFamilyId;

  const MapTrackingScreen({super.key, required this.activeFamilyId});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  late final MapController _mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LatLng? _currentPosition;
  bool _isMapReady = false;
  bool _isSharing = false;
  StreamSubscription<Position>? _positionStream;
  String _currentAddress = "Fetching location...";
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadInitialLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLocation() async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(widget.activeFamilyId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final lastLocation = data?['lastLocation'];

        if (lastLocation != null &&
            lastLocation['latitude'] != null &&
            lastLocation['longitude'] != null) {
          final lat = lastLocation['latitude'] as double;
          final lng = lastLocation['longitude'] as double;
          if (mounted) {
            setState(() {
              _currentPosition = LatLng(lat, lng);
            });
          }
          _getAddressFromLatLngCoordinates(lat, lng);
          return;
        }
      }
      _checkPermissionsAndGetLocation();
    } catch (e) {
      log("Error loading initial location: $e");
      _checkPermissionsAndGetLocation();
    }
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _getAddressFromLatLng(position);
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        }
      } catch (e) {
        log("Error getting location: $e");
      }
    }
  }

  Future<void> _updateFirebaseLocation(double lat, double lng) async {
    try {
      final batch = _firestore.batch();
      final userDoc = _firestore.collection('users').doc(widget.activeFamilyId);
      final historyDoc = userDoc
          .collection('location-history')
          .doc(widget.activeFamilyId);
      final locationHistory = LocationHistoryModel(
        locationId: widget.activeFamilyId,
        latitude: lat,
        longitude: lng,
        familyId: widget.activeFamilyId,
      );
      batch.set(historyDoc, locationHistory.toMap());
      batch.update(userDoc, {
        'lastLocation': {
          'latitude': lat,
          'longitude': lng,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'isSharingLocation': _isSharing,
      });

      await batch.commit();
      log(
        "Existing History Record Updated for familyId: ${widget.activeFamilyId}",
      );
    } catch (e) {
      log("Error: $e");
    }
  }

  void _toggleLocationSharing() {
    setState(() => _isSharing = !_isSharing);

    if (_isSharing) {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen((Position position) {
            final newLatLng = LatLng(position.latitude, position.longitude);
            _getAddressFromLatLng(position);
            if (mounted) {
              setState(() => _currentPosition = newLatLng);
              if (_isMapReady) {
                _mapController.move(newLatLng, 15.0);
              }
              _updateFirebaseLocation(position.latitude, position.longitude);
            }
          });

      SnackbarHelper.showSuccess(context, "Location Sharing Started");
    } else {
      _positionStream?.cancel();
      _positionStream = null;
      _updateFirebaseLocationStatus(false);
      SnackbarHelper.showError(context, "Location Sharing Stopped");
    }
  }

  Future<void> _updateFirebaseLocationStatus(bool status) async {
    await _firestore.collection('users').doc(widget.activeFamilyId).update({
      'isSharingLocation': status,
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.administrativeArea}, ${place.subAdministrativeArea}, ${place.street}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Location name not found";
      });
    }
  }

  Future<void> _getAddressFromLatLngCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.administrativeArea}, ${place.subAdministrativeArea}, ${place.street}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Location name not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final canEdit = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAdmin : false;
    });

    final isAppOwner = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAppowner : false;
    });

    final isActiveFamilyId = context.select<UserBloc, String>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isActiveFamilyId : '';
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(164.0),
        child: AppBar(
          backgroundColor: appColors.bgColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MainHeaderAppBar(),
                  const SizedBox(height: 20.0),
                  Text(
                    "Location & Check-ins",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textPrimary,
                      fontSize: 28.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Let your family know you're safe",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textSecondary,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      extendBody: true,
      body: isAppOwner
          ? _buildOwnerView(appColors, canEdit, screenWidth, context)
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(isActiveFamilyId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                bool hasLocationData = userData?['lastLocation'] != null;
                log("Has Location Data: $hasLocationData");

                if (!hasLocationData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Your guardian currently not share location details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  );
                }
                return _buildOwnerView(
                  appColors,
                  canEdit,
                  screenWidth,
                  context,
                );
              },
            ),
    );
  }

  Stack _buildOwnerView(
    AppColors appColors,
    bool canEdit,
    double screenWidth,
    BuildContext context,
  ) {
    return Stack(
      children: [
        RepaintBoundary(
          child: _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 15.0,
                    onMapReady: () => _isMapReady = true,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.remindus.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),

        // Floating Map Controls
        Positioned(
          right: 16,
          bottom: 140,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "btn_gps",
                backgroundColor: Colors.white,
                onPressed: () {
                  if (_currentPosition != null) {
                    _mapController.move(_currentPosition!, 15.0);
                  }
                },
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ],
          ),
        ),

        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentAddress,
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Navigation Panel
        if (canEdit)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildShareCard(appColors, screenWidth),
                  LocationBottomCard(
                    width: (screenWidth / 2) - 24,
                    appColors: appColors,
                    imageName: Assets.callRingingIcon,
                    title: "Call Me",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmergencySOSScreen(),
                        ),
                      );
                    },
                  ),
                  LocationBottomCard(
                    width: (screenWidth / 2) - 24,
                    appColors: appColors,
                    imageName: Assets.healthAmbulanceIcon,
                    title: "SOS",
                    isAmbulance: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmergencySOSScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildShareCard(AppColors appColors, double screenWidth) {
    return Container(
      width: (screenWidth / 2) - 24,
      height: 106,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: appColors.primaryLightBlue!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(Assets.mapPinponitIcon, width: 20, height: 20),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Share\nLocation",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch.adaptive(
                  value: _isSharing,
                  activeColor: Colors.green,
                  onChanged: (v) => _toggleLocationSharing(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationBottomCard extends StatelessWidget {
  final String imageName;
  final String title;
  final bool isAmbulance;
  final double width;
  final AppColors appColors;
  final VoidCallback? onTap;

  const LocationBottomCard({
    super.key,
    required this.appColors,
    required this.imageName,
    required this.title,
    required this.width,
    this.isAmbulance = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 106,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isAmbulance
                    ? Colors.red.withOpacity(0.1)
                    : appColors.primaryLightBlue!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                imageName,
                width: 20,
                height: 20,
                color: isAmbulance ? Colors.red : null,
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
