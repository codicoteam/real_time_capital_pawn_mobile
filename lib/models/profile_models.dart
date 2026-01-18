// lib/features/profile_mngmt/models/profile_models.dart

enum DocumentType { national_id, passport, proof_of_address, other }

enum UserRole {
  super_admin_vendor,
  admin_pawn_limited,
  call_centre_support,
  loan_officer_processor,
  loan_officer_approval,
  management,
  customer,
}

enum UserStatus { pending, active, suspended, deleted }

class Document {
  final String id;
  final DocumentType type;
  final String url;
  final String fileName;
  final String mimeType;
  final DateTime uploadedAt;
  final String? notes;

  Document({
    required this.id,
    required this.type,
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.uploadedAt,
    this.notes,
  });

  String get typeString {
    switch (type) {
      case DocumentType.national_id:
        return 'National ID';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.proof_of_address:
        return 'Proof of Address';
      case DocumentType.other:
        return 'Other';
    }
  }
}

class UserProfile {
  String id;
  String email;
  String? phone;
  List<UserRole> roles;

  // Name fields
  String firstName;
  String lastName;
  String? fullName;

  UserStatus status;

  // KYC fields (all optional)
  String? nationalIdNumber;
  DateTime? dateOfBirth;
  String? address;
  String? location;
  DateTime? termsAcceptedAt;

  // Image URLs (optional)
  String? nationalIdImageUrl;
  String? profilePicUrl;

  // Documents
  List<Document> documents;

  // Additional fields
  bool isEmailVerified;
  DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.phone,
    required this.roles,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.status = UserStatus.pending,
    this.nationalIdNumber,
    this.dateOfBirth,
    this.address,
    this.location,
    this.termsAcceptedAt,
    this.nationalIdImageUrl,
    this.profilePicUrl,
    this.documents = const [],
    required this.isEmailVerified,
    required this.createdAt,
  });

  String get fullNameDisplay => '$firstName $lastName';
  String get primaryRole => roles.contains(UserRole.customer)
      ? 'Customer'
      : roles.first.toString().split('.').last.replaceAll('_', ' ');

  bool get hasCompletedBasicKyc =>
      nationalIdNumber != null &&
      nationalIdNumber!.isNotEmpty &&
      dateOfBirth != null;
}
