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
  DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.phone,
    required this.roles,
    required this.firstName,
    required this.lastName,
    this.fullName,
    this.status = UserStatus.pending,
    this.nationalIdNumber, // nullable
    this.dateOfBirth, // nullable
    this.address, // nullable
    this.location, // nullable
    this.termsAcceptedAt,
    this.nationalIdImageUrl, // nullable
    this.profilePicUrl, // nullable
    this.documents = const [],
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullNameDisplay => '$firstName $lastName';
  String get primaryRole => roles.contains(UserRole.customer)
      ? 'Customer'
      : roles.first.toString().split('.').last.replaceAll('_', ' ');

  bool get hasCompletedBasicKyc =>
      nationalIdNumber != null &&
      nationalIdNumber!.isNotEmpty &&
      dateOfBirth != null;

  // Convert to API update payload
  Map<String, dynamic> toUpdatePayload() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (profilePicUrl != null && profilePicUrl!.isNotEmpty)
        'profile_pic_url': profilePicUrl,
    };
  }

  // Format date for display
  String? get formattedDateOfBirth {
    if (dateOfBirth == null) return null;
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}-'
        '${dateOfBirth!.month.toString().padLeft(2, '0')}-'
        '${dateOfBirth!.year}';
  }

  // Format date for API (YYYY-MM-DD)
  String? get apiDateOfBirth {
    if (dateOfBirth == null) return null;
    return '${dateOfBirth!.year}-'
        '${dateOfBirth!.month.toString().padLeft(2, '0')}-'
        '${dateOfBirth!.day.toString().padLeft(2, '0')}';
  }

  // ✅ ADD THIS copyWith METHOD
  UserProfile copyWith({
    String? id,
    String? email,
    String? phone,
    List<UserRole>? roles,
    String? firstName,
    String? lastName,
    String? fullName,
    UserStatus? status,
    String? nationalIdNumber,
    DateTime? dateOfBirth,
    String? address,
    String? location,
    DateTime? termsAcceptedAt,
    String? nationalIdImageUrl,
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
      nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      location: location ?? this.location,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      nationalIdImageUrl: nationalIdImageUrl ?? this.nationalIdImageUrl,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      documents: documents ?? this.documents,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
