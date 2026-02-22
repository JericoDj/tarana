import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsSource {
  final FirebaseFunctions _functions;

  CloudFunctionsSource({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  /// Generic callable — invoke any Cloud Function by name
  Future<HttpsCallableResult> call(String functionName, [dynamic data]) async {
    try {
      final callable = _functions.httpsCallable(functionName);
      return await callable.call(data);
    } catch (e) {
      throw Exception('Cloud Function "$functionName" failed: $e');
    }
  }

  Future<String> createBooking({
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    required String paymentMethod,
  }) async {
    try {
      final callable = _functions.httpsCallable('createBooking');
      final response = await callable.call({
        'pickup': pickup,
        'dropoff': dropoff,
        'paymentMethod': paymentMethod,
      });
      return response.data['bookingId'] as String;
    } catch (e) {
      throw Exception('Cloud Functions createBooking failed: $e');
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    try {
      final callable = _functions.httpsCallable('acceptBooking');
      await callable.call({'bookingId': bookingId});
    } catch (e) {
      throw Exception('Cloud Functions acceptBooking failed: $e');
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      final callable = _functions.httpsCallable('rejectBooking');
      await callable.call({'bookingId': bookingId});
    } catch (e) {
      throw Exception('Cloud Functions rejectBooking failed: $e');
    }
  }
}
