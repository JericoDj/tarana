/// Driver availability/presence states
enum DriverStatus {
  offline,
  online,
  pendingRequest,
  arriving,
  onTrip,
  paused;

  String get label {
    switch (this) {
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.online:
        return 'Available';
      case DriverStatus.pendingRequest:
        return 'Request pending';
      case DriverStatus.arriving:
        return 'Arriving';
      case DriverStatus.onTrip:
        return 'On trip';
      case DriverStatus.paused:
        return 'On break';
    }
  }

  bool get isAvailable => this == DriverStatus.online;

  bool get isWorking => [
    DriverStatus.online,
    DriverStatus.pendingRequest,
    DriverStatus.arriving,
    DriverStatus.onTrip,
  ].contains(this);

  static DriverStatus fromString(String value) {
    switch (value) {
      case 'offline':
        return DriverStatus.offline;
      case 'online':
        return DriverStatus.online;
      case 'pending_request':
        return DriverStatus.pendingRequest;
      case 'arriving':
        return DriverStatus.arriving;
      case 'on_trip':
        return DriverStatus.onTrip;
      case 'paused':
        return DriverStatus.paused;
      default:
        return DriverStatus.offline;
    }
  }

  String toFirestore() {
    switch (this) {
      case DriverStatus.pendingRequest:
        return 'pending_request';
      case DriverStatus.onTrip:
        return 'on_trip';
      default:
        return name;
    }
  }
}
