import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../shared/enums/booking_status.dart';
import '../../shared/enums/user_role.dart';
import 'auth_provider.dart';

class BookingProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final BookingRepository _bookingRepository;

  List<BookingModel> _activeBookings = [];
  List<BookingModel> _incomingRequests = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _bookingSubscription;
  StreamSubscription? _incomingRequestsSubscription;

  BookingProvider({
    required AuthProvider authProvider,
    BookingRepository? bookingRepository,
  }) : _authProvider = authProvider,
       _bookingRepository = bookingRepository ?? BookingRepository() {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  List<BookingModel> get activeBookings => _activeBookings;
  BookingModel? get currentBooking =>
      _activeBookings.isNotEmpty ? _activeBookings.first : null;

  List<BookingModel> get incomingRequests => _incomingRequests;
  BookingModel? get incomingBooking =>
      _incomingRequests.isNotEmpty ? _incomingRequests.first : null;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _onAuthStateChanged() {
    final user = _authProvider.user;
    if (user != null) {
      _listenToActiveBookings();
    } else {
      _bookingSubscription?.cancel();
      _incomingRequestsSubscription?.cancel();
      _activeBookings = [];
      _incomingRequests = [];
      notifyListeners();
    }
  }

  void _listenToActiveBookings() {
    _bookingSubscription?.cancel();
    _incomingRequestsSubscription?.cancel();

    final user = _authProvider.user;
    final isDriver = _authProvider.activeRole == UserRole.driver;

    if (user == null) return;

    if (isDriver) {
      _bookingSubscription = _bookingRepository
          .watchActiveDriverBookings(user.uid)
          .listen(_onData, onError: _onError);

      _incomingRequestsSubscription = _bookingRepository
          .watchIncomingRequests(user.uid)
          .listen((data) {
            _incomingRequests = data;
            notifyListeners();
          }, onError: _onError);
    } else {
      _bookingSubscription = _bookingRepository
          .watchActiveRiderBookings(user.uid)
          .listen(_onData, onError: _onError);
    }
  }

  void _onData(List<BookingModel> bookings) {
    _activeBookings = bookings;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _onError(Object e) {
    _error = 'Failed to load bookings: $e';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestRide(BookingModel booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookingRepository.createBooking(booking);
      // We don't manually update _activeBookings because the stream handles it.
    } catch (e) {
      _error = 'Failed to request ride: $e';
    } finally {
      // Small delay prevents flickering if stream hasn't caught it yet
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _bookingRepository.updateBookingStatus(bookingId, status);
    } catch (e) {
      _error = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    final uid = _authProvider.user?.uid;
    if (uid == null) return;

    try {
      await _bookingRepository.cancelBooking(bookingId, reason, uid);
    } catch (e) {
      _error = 'Failed to cancel booking: $e';
      notifyListeners();
    }
  }

  Future<void> acceptRide(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookingRepository.acceptBooking(bookingId);
    } catch (e) {
      _error = 'Failed to accept ride: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRide(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookingRepository.rejectBooking(bookingId);
    } catch (e) {
      _error = 'Failed to reject ride: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordCashPayment(String bookingId) async {
    try {
      await _bookingRepository.recordCashPayment(bookingId);
    } catch (e) {
      _error = 'Failed to record payment: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _bookingSubscription?.cancel();
    _incomingRequestsSubscription?.cancel();
    super.dispose();
  }
}
