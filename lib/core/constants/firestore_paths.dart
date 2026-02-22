/// Firestore and RTDB path constants
class FirestorePaths {
  FirestorePaths._();

  // Firestore collections
  static const String users = 'users';
  static const String driverProfiles = 'driver_profiles';
  static const String driverApplications = 'driver_applications';
  static const String bookings = 'bookings';
  static const String promoCodes = 'promo_codes';
  static const String referrals = 'referrals';

  // Firestore subcollections
  static String contacts(String uid) => 'users/$uid/contacts';
  static String savedPlaces(String uid) => 'users/$uid/saved_places';

  // RTDB paths
  static const String rtdbDrivers = 'drivers';
  static String rtdbDriverLocation(String uid) => 'drivers/$uid';
}
