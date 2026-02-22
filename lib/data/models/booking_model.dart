import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/enums/booking_status.dart';
import '../../shared/enums/payment_method.dart';

class BookingLocation {
  final double lat;
  final double lng;
  final String address;
  final String? placeId;

  BookingLocation({
    required this.lat,
    required this.lng,
    required this.address,
    this.placeId,
  });

  factory BookingLocation.fromMap(Map<String, dynamic> map) {
    return BookingLocation(
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      placeId: map['placeId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      if (placeId != null) 'placeId': placeId,
    };
  }
}

class BookingFare {
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeMultiplier;
  final double discount;
  final double total;
  final String currency;

  BookingFare({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.surgeMultiplier,
    required this.discount,
    required this.total,
    required this.currency,
  });

  factory BookingFare.fromMap(Map<String, dynamic> map) {
    return BookingFare(
      baseFare: (map['baseFare'] as num?)?.toDouble() ?? 0.0,
      distanceFare: (map['distanceFare'] as num?)?.toDouble() ?? 0.0,
      timeFare: (map['timeFare'] as num?)?.toDouble() ?? 0.0,
      surgeMultiplier: (map['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'PHP',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'timeFare': timeFare,
      'surgeMultiplier': surgeMultiplier,
      'discount': discount,
      'total': total,
      'currency': currency,
    };
  }
}

class BookingModel {
  final String id;
  final String riderId;
  final String? driverId;
  final BookingStatus status;
  final BookingLocation pickup;
  final BookingLocation dropoff;
  final List<BookingLocation> stops;
  final bool isScheduled;
  final DateTime? scheduledAt;
  final BookingFare fare;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final String? promoCode;
  final double distanceKm;
  final double durationMinutes;
  final String routePolyline;
  final int? riderRating;
  final int? driverRating;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.status,
    required this.pickup,
    required this.dropoff,
    this.stops = const [],
    this.isScheduled = false,
    this.scheduledAt,
    required this.fare,
    required this.paymentMethod,
    required this.paymentStatus,
    this.promoCode,
    required this.distanceKm,
    required this.durationMinutes,
    required this.routePolyline,
    this.riderRating,
    this.driverRating,
    this.cancelledBy,
    this.cancellationReason,
    required this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return BookingModel(
      id: doc.id,
      riderId: data['riderId'] as String? ?? '',
      driverId: data['driverId'] as String?,
      status: BookingStatus.fromString(data['status'] as String? ?? 'pending'),
      pickup: BookingLocation.fromMap(
        data['pickup'] as Map<String, dynamic>? ?? {},
      ),
      dropoff: BookingLocation.fromMap(
        data['dropoff'] as Map<String, dynamic>? ?? {},
      ),
      stops:
          (data['stops'] as List<dynamic>?)
              ?.map((e) => BookingLocation.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isScheduled: data['isScheduled'] as bool? ?? false,
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      fare: BookingFare.fromMap(data['fare'] as Map<String, dynamic>? ?? {}),
      paymentMethod: PaymentMethod.fromString(
        data['paymentMethod'] as String? ?? 'cash',
      ),
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      promoCode: data['promoCode'] as String?,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (data['durationMinutes'] as num?)?.toDouble() ?? 0.0,
      routePolyline: data['routePolyline'] as String? ?? '',
      riderRating: data['riderRating'] as int?,
      driverRating: data['driverRating'] as int?,
      cancelledBy: data['cancelledBy'] as String?,
      cancellationReason: data['cancellationReason'] as String?,
      requestedAt:
          (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      arrivedAt: (data['arrivedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'riderId': riderId,
      if (driverId != null) 'driverId': driverId,
      'status': status.toFirestore(),
      'pickup': pickup.toMap(),
      'dropoff': dropoff.toMap(),
      'stops': stops.map((s) => s.toMap()).toList(),
      'isScheduled': isScheduled,
      if (scheduledAt != null) 'scheduledAt': Timestamp.fromDate(scheduledAt!),
      'fare': fare.toMap(),
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus,
      if (promoCode != null) 'promoCode': promoCode,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'routePolyline': routePolyline,
      if (riderRating != null) 'riderRating': riderRating,
      if (driverRating != null) 'driverRating': driverRating,
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'requestedAt': Timestamp.fromDate(requestedAt),
      if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),
      if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt!),
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (cancelledAt != null) 'cancelledAt': Timestamp.fromDate(cancelledAt!),
    };
  }
}
