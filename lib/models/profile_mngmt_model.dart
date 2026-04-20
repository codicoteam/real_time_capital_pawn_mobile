import 'dart:convert';

class UserProfile {
    final NextOfKin? nextOfKin;
    final String? id;
    final String? email;
    final String? phone;
    final List<String>? roles;
    final String? firstName;
    final String? lastName;
    final String? status;
    final DateTime? dateOfBirth;
    final String? address;
    final String? location;
    final String? gender;
    final String? maritalStatus;
    final String? passportImageUrl;
    final String? proofOfAddressUrl;
    final DateTime? passportExpiryDate;
    final bool? isEmployed;
    final EmploymentDetails? employmentDetails;
    final List<Document>? documents;
    final String? kycVerificationStatus;
    final DateTime? termsAcceptedAt;
    final bool? emailVerified;
    final AddedBy? addedBy;
    final String? fullName;
    final String? emailVerificationOtp;
    final DateTime? emailVerificationExpiresAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;
    final String? nationalIdNumber;
    final String? alternativePhone;
    final String? profilePicUrl;
    final DateTime? drivingLicenseExpiryDate;
    final DateTime? nationalIdExpiryDate;
    final String? nationalIdImageUrl;

    UserProfile({
        this.nextOfKin,
        this.id,
        this.email,
        this.phone,
        this.roles,
        this.firstName,
        this.lastName,
        this.status,
        this.dateOfBirth,
        this.address,
        this.location,
        this.gender,
        this.maritalStatus,
        this.passportImageUrl,
        this.proofOfAddressUrl,
        this.passportExpiryDate,
        this.isEmployed,
        this.employmentDetails,
        this.documents,
        this.kycVerificationStatus,
        this.termsAcceptedAt,
        this.emailVerified,
        this.addedBy,
        this.fullName,
        this.emailVerificationOtp,
        this.emailVerificationExpiresAt,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.nationalIdNumber,
        this.alternativePhone,
        this.profilePicUrl,
        this.drivingLicenseExpiryDate,
        this.nationalIdExpiryDate,
        this.nationalIdImageUrl,
    });

    factory UserProfile.fromJson(String str) => UserProfile.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UserProfile.fromMap(Map<String, dynamic> json) => UserProfile(
        nextOfKin: json["next_of_kin"] == null ? null : NextOfKin.fromMap(json["next_of_kin"]),
        id: json["_id"],
        email: json["email"],
        phone: json["phone"],
        roles: json["roles"] == null ? [] : List<String>.from(json["roles"]!.map((x) => x)),
        firstName: json["first_name"],
        lastName: json["last_name"],
        status: json["status"],
        dateOfBirth: json["date_of_birth"] == null ? null : DateTime.parse(json["date_of_birth"]),
        address: json["address"],
        location: json["location"],
        gender: json["gender"],
        maritalStatus: json["marital_status"],
        passportImageUrl: json["passport_image_url"],
        proofOfAddressUrl: json["proof_of_address_url"],
        passportExpiryDate: json["passport_expiry_date"] == null ? null : DateTime.parse(json["passport_expiry_date"]),
        isEmployed: json["is_employed"],
        employmentDetails: json["employment_details"] == null ? null : EmploymentDetails.fromMap(json["employment_details"]),
        documents: json["documents"] == null ? [] : List<Document>.from(json["documents"]!.map((x) => Document.fromMap(x))),
        kycVerificationStatus: json["kyc_verification_status"],
        termsAcceptedAt: json["terms_accepted_at"] == null ? null : DateTime.parse(json["terms_accepted_at"]),
        emailVerified: json["email_verified"],
        addedBy: json["added_by"] == null ? null : AddedBy.fromMap(json["added_by"]),
        fullName: json["full_name"],
        emailVerificationOtp: json["email_verification_otp"],
        emailVerificationExpiresAt: json["email_verification_expires_at"] == null ? null : DateTime.parse(json["email_verification_expires_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        v: json["__v"],
        nationalIdNumber: json["national_id_number"],
        alternativePhone: json["alternative_phone"],
        profilePicUrl: json["profile_pic_url"],
        drivingLicenseExpiryDate: json["driving_license_expiry_date"] == null ? null : DateTime.parse(json["driving_license_expiry_date"]),
        nationalIdExpiryDate: json["national_id_expiry_date"] == null ? null : DateTime.parse(json["national_id_expiry_date"]),
        nationalIdImageUrl: json["national_id_image_url"],
    );

    Map<String, dynamic> toMap() => {
        "next_of_kin": nextOfKin?.toMap(),
        "_id": id,
        "email": email,
        "phone": phone,
        "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
        "first_name": firstName,
        "last_name": lastName,
        "status": status,
        "date_of_birth": dateOfBirth?.toIso8601String(),
        "address": address,
        "location": location,
        "gender": gender,
        "marital_status": maritalStatus,
        "passport_image_url": passportImageUrl,
        "proof_of_address_url": proofOfAddressUrl,
        "passport_expiry_date": passportExpiryDate?.toIso8601String(),
        "is_employed": isEmployed,
        "employment_details": employmentDetails?.toMap(),
        "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toMap())),
        "kyc_verification_status": kycVerificationStatus,
        "terms_accepted_at": termsAcceptedAt?.toIso8601String(),
        "email_verified": emailVerified,
        "added_by": addedBy?.toMap(),
        "full_name": fullName,
        "email_verification_otp": emailVerificationOtp,
        "email_verification_expires_at": emailVerificationExpiresAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "__v": v,
        "national_id_number": nationalIdNumber,
        "alternative_phone": alternativePhone,
        "profile_pic_url": profilePicUrl,
        "driving_license_expiry_date": drivingLicenseExpiryDate?.toIso8601String(),
        "national_id_expiry_date": nationalIdExpiryDate?.toIso8601String(),
        "national_id_image_url": nationalIdImageUrl,
    };
}

class AddedBy {
    final String? id;
    final String? email;
    final String? firstName;
    final String? lastName;

    AddedBy({
        this.id,
        this.email,
        this.firstName,
        this.lastName,
    });

    factory AddedBy.fromJson(String str) => AddedBy.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AddedBy.fromMap(Map<String, dynamic> json) => AddedBy(
        id: json["_id"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toMap() => {
        "_id": id,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
    };
}

class Document {
    final String? type;
    final String? url;
    final String? fileName;
    final String? mimeType;
    final String? notes;
    final DateTime? uploadedAt;

    Document({
        this.type,
        this.url,
        this.fileName,
        this.mimeType,
        this.notes,
        this.uploadedAt,
    });

    factory Document.fromJson(String str) => Document.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Document.fromMap(Map<String, dynamic> json) => Document(
        type: json["type"],
        url: json["url"],
        fileName: json["file_name"],
        mimeType: json["mime_type"],
        notes: json["notes"],
        uploadedAt: json["uploaded_at"] == null ? null : DateTime.parse(json["uploaded_at"]),
    );

    Map<String, dynamic> toMap() => {
        "type": type,
        "url": url,
        "file_name": fileName,
        "mime_type": mimeType,
        "notes": notes,
        "uploaded_at": uploadedAt?.toIso8601String(),
    };
}

class EmploymentDetails {
    final String? employerName;
    final String? jobTitle;
    final String? duration;
    final String? location;
    final String? contacts;

    EmploymentDetails({
        this.employerName,
        this.jobTitle,
        this.duration,
        this.location,
        this.contacts,
    });

    factory EmploymentDetails.fromJson(String str) => EmploymentDetails.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory EmploymentDetails.fromMap(Map<String, dynamic> json) => EmploymentDetails(
        employerName: json["employer_name"],
        jobTitle: json["job_title"],
        duration: json["duration"],
        location: json["location"],
        contacts: json["contacts"],
    );

    Map<String, dynamic> toMap() => {
        "employer_name": employerName,
        "job_title": jobTitle,
        "duration": duration,
        "location": location,
        "contacts": contacts,
    };
}

class NextOfKin {
    final String? fullName;
    final String? relationship;
    final String? phoneNumber;
    final String? email;
    final String? address;

    NextOfKin({
        this.fullName,
        this.relationship,
        this.phoneNumber,
        this.email,
        this.address,
    });

    factory NextOfKin.fromJson(String str) => NextOfKin.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory NextOfKin.fromMap(Map<String, dynamic> json) => NextOfKin(
        fullName: json["full_name"],
        relationship: json["relationship"],
        phoneNumber: json["phone_number"],
        email: json["email"],
        address: json["address"],
    );

    Map<String, dynamic> toMap() => {
        "full_name": fullName,
        "relationship": relationship,
        "phone_number": phoneNumber,
        "email": email,
        "address": address,
    };
}
