import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class LocationService {
  final ApiService _apiService;

  LocationService(this._apiService);

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Get current position
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return null;
      }

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }

  /// Get detailed placemark from coordinates
  Future<Placemark?> getPlacemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks[0];
      }
    } catch (e) {
      debugPrint('Error getting placemark: $e');
    }
    return null;
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Update location on backend
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String locationType = 'gps',
    String privacyLevel = 'approximate',
  }) async {
    try {
      final response = await _apiService.post(
        '/location/update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'city': city,
          'state': state,
          'country': country,
          'postal_code': postalCode,
          'location_type': locationType,
          'privacy_level': privacyLevel,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
    return null;
  }

  /// Get current location and update on backend
  Future<bool> updateCurrentLocation({
    String privacyLevel = 'approximate',
  }) async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return false;

      final placemark = await getPlacemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final result = await updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        city: placemark?.locality,
        state: placemark?.administrativeArea,
        country: placemark?.country,
        postalCode: placemark?.postalCode,
        locationType: 'gps',
        privacyLevel: privacyLevel,
      );

      return result != null;
    } catch (e) {
      debugPrint('Error updating current location: $e');
      return false;
    }
  }

  /// Get current location from backend
  Future<Map<String, dynamic>?> getCurrentLocationFromBackend() async {
    try {
      final response = await _apiService.get('/location/current');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Error getting current location from backend: $e');
    }
    return null;
  }

  /// Get location history from backend
  Future<List<Map<String, dynamic>>> getLocationHistory({
    String? fromDate,
    String? toDate,
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '/location/history',
        queryParameters: {
          if (fromDate != null) 'from_date': fromDate,
          if (toDate != null) 'to_date': toDate,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error getting location history: $e');
    }
    return [];
  }

  /// Get nearby users
  Future<List<Map<String, dynamic>>> getNearbyUsers({
    double? latitude,
    double? longitude,
    int radius = 25,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/location/nearby-users',
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'radius': radius,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']['users']);
      }
    } catch (e) {
      debugPrint('Error getting nearby users: $e');
    }
    return [];
  }

  /// Start location updates in background
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Open app settings for location permission
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Check if background location permission is granted
  Future<bool> hasBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  /// Request background location permission
  Future<bool> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }
}
