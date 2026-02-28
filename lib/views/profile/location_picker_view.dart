import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen map picker. Pass an optional initial [LatLng] via [Get.arguments].
/// Returns the picked [LatLng] via [Get.back(result: latLng)] when confirmed,
/// or null if cancelled.
class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  late LatLng _center;
  final MapController _mapController = MapController();
  bool _locating = false;

  static const LatLng _defaultCenter = LatLng(40.7128, -74.0060); // NYC

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _center = args is LatLng ? args : _defaultCenter;
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied. Enable it in Settings.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      _mapController.move(latLng, 16);
      setState(() => _center = latLng);
    } finally {
      setState(() => _locating = false);
    }
  }

  void _showSnack(String message) {
    Get.snackbar(
      'Location',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back<LatLng?>(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<LatLng>(result: _center),
            child: Text(
              'Confirm',
              style: TextStyle(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() => _center = camera.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.delivery.app',
              ),
            ],
          ),

          // Centered pin (pinhead is at center, tip points to location)
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 52,
                    color: colorScheme.secondary,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Coordinates pill
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.gps_fixed_rounded,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_center.latitude.toStringAsFixed(6)}, '
                        '${_center.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instruction banner
          Positioned(
            top: 12,
            left: 20,
            right: 20,
            child: Material(
              color: colorScheme.inverseSurface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  'Move the map to position the pin on your address',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onInverseSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // My location FAB
          Positioned(
            bottom: 24,
            right: 20,
            child: FloatingActionButton(
              onPressed: _locating ? null : _goToMyLocation,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.secondary,
              elevation: 4,
              child: _locating
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.secondary,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
