import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // --- Global University Location ---

  static const String _prefLatKey = 'university_lat';
  static const String _prefLngKey = 'university_lng';
  static const String _prefRadiusKey = 'university_radius';

  /// Üniversite konumunu kaydet
  Future<void> saveUniversityLocation(double lat, double lng, {double radius = 500.0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefLatKey, lat);
    await prefs.setDouble(_prefLngKey, lng);
    await prefs.setDouble(_prefRadiusKey, radius);
  }

  /// Kayıtlı üniversite konumunu getir
  /// [lat, lng, radius] döner. Konum yoksa null döner.
  Future<List<double>?> getUniversityLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_prefLatKey);
    final lng = prefs.getDouble(_prefLngKey);
    final radius = prefs.getDouble(_prefRadiusKey) ?? 500.0;

    if (lat == null || lng == null) return null;
    return [lat, lng, radius];
  }

  /// Sil
  Future<void> clearUniversityLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLatKey);
    await prefs.remove(_prefLngKey);
    await prefs.remove(_prefRadiusKey);
  }

  /// Üniversitede mi? kontrol et
  Future<bool> isAtUniversity() async {
    final uniLoc = await getUniversityLocation();
    if (uniLoc == null) return false;

    final currentPosition = await getCurrentLocation();
    if (currentPosition == null) return false;

    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      uniLoc[0],
      uniLoc[1],
    );

    return distance <= uniLoc[2]; // yarıçaptan küçük eşitese üniversitededir.
  }
}
