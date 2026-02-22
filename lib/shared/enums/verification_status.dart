/// Driver verification status
enum VerificationStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  static VerificationStatus fromString(String value) {
    switch (value) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }
}
