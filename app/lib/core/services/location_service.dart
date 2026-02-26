import 'package:geolocator/geolocator.dart';
import '../../models/course.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Konum izni iste
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Servis açık mı?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Mevcut konumu al
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Ders konumuna yakın mı? (Varsayılan 100 metre)
  Future<bool> isNearCourse(Course course, {int radiusInMeters = 100}) async {
    if (course.latitude == null || course.longitude == null) return false;

    final currentPosition = await getCurrentLocation();
    if (currentPosition == null) return false;

    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      course.latitude!,
      course.longitude!,
    );

    return distance <= radiusInMeters;
  }

  /// Derse yakın mı kontrol et ve mesafe döndür
  Future<double?> getDistanceToCourse(Course course) async {
    if (course.latitude == null || course.longitude == null) return null;

    final currentPosition = await getCurrentLocation();
    if (currentPosition == null) return null;

    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      course.latitude!,
      course.longitude!,
    );
  }
}
