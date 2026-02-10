// lib/features/profile_mngmt/models/profile_mngmt_models.dart
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

  // Convert to API payload
  Map<String, dynamic> toApiPayload() {
    String typeString;
    switch (type) {
      case DocumentType.national_id:
        typeString = 'national_id';
        break;
      case DocumentType.passport:
        typeString = 'passport';
        break;
      case DocumentType.proof_of_address:
        typeString = 'proof_of_address';
        break;
      default:
        typeString = 'other';
    }

    return {
      'type': typeString,
      'url': url,
      'file_name': fileName,
      'mime_type': mimeType,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class UserProfile {
  String id;
  String email;
  String? phone;
  List<UserRole> roles;

  // ✅ ONLY FIELDS FROM YOUR BACKEND RESPONSE:
  String firstName;
  String lastName;
  String? fullName;
  UserStatus status;
  DateTime? termsAcceptedAt;

  // ✅ FROM BACKEND: Documents array
  List<Document> documents;

  // ✅ FROM BACKEND: Email verification status
  bool isEmailVerified;

  // ✅ FROM BACKEND: Timestamps
  DateTime createdAt;
  DateTime updatedAt;

  // ❌ REMOVED (NOT IN BACKEND):
  // String? nationalIdNumber;
  // DateTime? dateOfBirth;
  // String? address;
  // String? location;
  // String? nationalIdImageUrl;

  // ✅ Optional for UI only (not from backend)
  String? profilePicUrl;

  UserProfile({
    required this.id,
    required this.email,
    this.phone,
    required this.roles,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.status = UserStatus.pending,
    this.termsAcceptedAt,
    this.profilePicUrl,
    this.documents = const [],
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullNameDisplay => '$firstName $lastName';

  String get primaryRole => roles.contains(UserRole.customer)
      ? 'Customer'
      : roles.first.toString().split('.').last.replaceAll('_', ' ');

  // ✅ UPDATED: KYC completion based on ACTUAL backend fields
  bool get hasCompletedBasicKyc {
    // Check if user has uploaded any documents
    if (documents.isEmpty) return false;

    // Check if email is verified (from backend)
    if (!isEmailVerified) return false;

    // Check if phone is provided
    if (phone == null || phone!.isEmpty) return false;

    return true;
  }

  // ✅ UPDATED: Convert to API update payload (only fields that exist)
  Map<String, dynamic> toUpdatePayload() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      // ❌ NO date_of_birth, address, or location - they don't exist in backend
    };
  }

  // ✅ UPDATED copyWith METHOD (only backend fields)
  UserProfile copyWith({
    String? id,
    String? email,
    String? phone,
    List<UserRole>? roles,
    String? firstName,
    String? lastName,
    String? fullName,
    UserStatus? status,
    DateTime? termsAcceptedAt,
    String? profilePicUrl,
    List<Document>? documents,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      status: status ?? this.status,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      documents: documents ?? this.documents,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
