import 'package:geolocator/geolocator.dart';

class MapError {
  static String locationServiceDisabled = 'Location services are disabled.';
  static String locationPermissionDenied = 'Location permissions are denied';
  static String locationPermissionPermanentlyDenied =
      'Location permissions are permanently denied, we cannot request permissions.';
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance {
    _instance ??= LocationService();
    return _instance!;
  }

  /// [_locationServiceEnabled] is set to true when the user consent on location service and the app has location service.
  bool _locationServiceEnabled = false;

  /// Use [locationServiceEnabled] to check if the app has location service permission.
  bool get locationServiceEnabled => _locationServiceEnabled;

  /// Checks necessary permission for geolocator.
  /// Throws error if permission is not granted.
  ///
  Future<dynamic> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    /// The location service is available on the phone?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    /// If not, then alert user that location service is turned off.
    if (!serviceEnabled) {
      _locationServiceEnabled = false;
      throw MapError.locationServiceDisabled;
    }

    /// When location service is turned on, request permission.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationServiceEnabled = false;
        throw MapError.locationPermissionDenied;
      }
    }

    ///
    if (permission == LocationPermission.deniedForever) {
      _locationServiceEnabled = false;
      throw MapError.locationPermissionPermanentlyDenied;
    }

    _locationServiceEnabled = true;
    return _locationServiceEnabled;
  }

  /// Return current position.
  ///
  /// When use call this method to get curren position, it will automatically ask permission to users.
  Future<Position> get currentPosition async {
    await checkPermission();
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
