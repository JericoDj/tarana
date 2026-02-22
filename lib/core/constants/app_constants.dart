/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Tarana';
  static const String appVersion = '0.1.0';

  // Timing
  static const Duration driverRequestTimeout = Duration(seconds: 15);
  static const Duration locationUpdateInterval = Duration(seconds: 3);
  static const Duration locationSearchInterval = Duration(seconds: 6);
  static const Duration softDeleteRetention = Duration(days: 30);

  // Limits
  static const int maxStopsPerTrip = 3;
  static const int maxEmergencyContacts = 5;
  static const int maxSavedPlaces = 20;
  static const int maxSavedPassengers = 10;
  static const double driverSearchRadiusKm = 5.0;
  static const double driverSearchExpandKm = 10.0;

  // Firebase Storage paths
  static const String storageProfilePhotos = 'profile_photos';
  static const String storageDriverDocs = 'driver_documents';
  static const String storageVehiclePhotos = 'vehicle_photos';

  // Cloud Functions base URL (to be configured per environment)
  static const String functionsBaseUrl =
      'https://us-central1-YOUR_PROJECT.cloudfunctions.net';

  // Google Maps API
  static const String googleMapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'YOUR_API_KEY',
  );
}
