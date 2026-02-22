/// Booking lifecycle status
enum BookingStatus {
  pending,
  searching,
  driverAssigned,
  driverArriving,
  arrived,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.searching:
        return 'Searching for driver';
      case BookingStatus.driverAssigned:
        return 'Driver assigned';
      case BookingStatus.driverArriving:
        return 'Driver arriving';
      case BookingStatus.arrived:
        return 'Driver arrived';
      case BookingStatus.inProgress:
        return 'In progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => [
    BookingStatus.searching,
    BookingStatus.driverAssigned,
    BookingStatus.driverArriving,
    BookingStatus.arrived,
    BookingStatus.inProgress,
  ].contains(this);

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return BookingStatus.pending;
      case 'searching':
        return BookingStatus.searching;
      case 'driver_assigned':
        return BookingStatus.driverAssigned;
      case 'driver_arriving':
        return BookingStatus.driverArriving;
      case 'arrived':
        return BookingStatus.arrived;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String toFirestore() {
    switch (this) {
      case BookingStatus.driverAssigned:
        return 'driver_assigned';
      case BookingStatus.driverArriving:
        return 'driver_arriving';
      case BookingStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }
}
