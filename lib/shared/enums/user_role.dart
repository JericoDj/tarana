/// User roles for RBAC
enum UserRole {
  rider,
  driver,
  dispatcher,
  admin,
  superAdmin;

  String get label {
    switch (this) {
      case UserRole.rider:
        return 'Rider';
      case UserRole.driver:
        return 'Driver';
      case UserRole.dispatcher:
        return 'Dispatcher';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'rider':
        return UserRole.rider;
      case 'driver':
        return UserRole.driver;
      case 'dispatcher':
        return UserRole.dispatcher;
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.rider;
    }
  }

  String toFirestore() {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      default:
        return name;
    }
  }
}
