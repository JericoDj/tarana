import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/enums/user_role.dart';

/// User data model for Firestore
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String? photoUrl;
  final List<UserRole> roles;
  final UserRole activeRole;
  final String status; // active, suspended, banned, soft_deleted
  final DateTime? deletedAt;
  final DateTime? purgeScheduledAt;
  final String referralCode;
  final String? referredBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phone,
    this.photoUrl,
    required this.roles,
    required this.activeRole,
    this.status = 'active',
    this.deletedAt,
    this.purgeScheduledAt,
    required this.referralCode,
    this.referredBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the user has the driver role approved
  bool get isDriver => roles.contains(UserRole.driver);

  /// Whether the user is an admin
  bool get isAdmin =>
      roles.contains(UserRole.admin) || roles.contains(UserRole.superAdmin);

  /// Whether the account is active
  bool get isActive => status == 'active';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      roles:
          (data['roles'] as List<dynamic>?)
              ?.map((r) => UserRole.fromString(r as String))
              .toList() ??
          [UserRole.rider],
      activeRole: UserRole.fromString(data['activeRole'] ?? 'rider'),
      status: data['status'] ?? 'active',
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      purgeScheduledAt: (data['purgeScheduledAt'] as Timestamp?)?.toDate(),
      referralCode: data['referralCode'] ?? '',
      referredBy: data['referredBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'photoUrl': photoUrl,
      'roles': roles.map((r) => r.toFirestore()).toList(),
      'activeRole': activeRole.toFirestore(),
      'status': status,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'purgeScheduledAt': purgeScheduledAt != null
          ? Timestamp.fromDate(purgeScheduledAt!)
          : null,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    List<UserRole>? roles,
    UserRole? activeRole,
    String? status,
    DateTime? deletedAt,
    DateTime? purgeScheduledAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      purgeScheduledAt: purgeScheduledAt ?? this.purgeScheduledAt,
      referralCode: referralCode,
      referredBy: referredBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
