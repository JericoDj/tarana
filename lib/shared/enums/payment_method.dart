/// Payment methods — cash only for now, extensible for digital later
enum PaymentMethod {
  cash;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'cash':
        return PaymentMethod.cash;
      default:
        return PaymentMethod.cash;
    }
  }
}
