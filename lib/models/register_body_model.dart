import 'dart:convert';

class RegisterBodyModel {
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final List<String>? roles;
  final DateTime? dateOfBirth;
  final String? address;
  final String? location;
  final String? gender;
  final String? maritalStatus;
  final String? alternativePhone;
  final String? nationalIdNumber;
  final String? nationalIdImageUrl;
  final String? passportImageUrl;
  final String? proofOfAddressUrl;
  final String? profilePicUrl;
  final DateTime? passportExpiryDate;
  final DateTime? drivingLicenseExpiryDate;
  final DateTime? nationalIdExpiryDate;
  final EmploymentDetails? employmentDetails;
  final NextOfKin? nextOfKin;
  final bool? isEmployed;
  final DateTime? termsAcceptedAt;
  final List<Document>? documents;

  RegisterBodyModel({
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.phone,
    this.roles,
    this.dateOfBirth,
    this.address,
    this.location,
    this.gender,
    this.maritalStatus,
    this.alternativePhone,
    this.nationalIdNumber,
    this.nationalIdImageUrl,
    this.passportImageUrl,
    this.proofOfAddressUrl,
    this.profilePicUrl,
    this.passportExpiryDate,
    this.drivingLicenseExpiryDate,
    this.nationalIdExpiryDate,
    this.employmentDetails,
    this.nextOfKin,
    this.isEmployed,
    this.termsAcceptedAt,
    this.documents,
  });

  factory RegisterBodyModel.fromJson(String str) =>
      RegisterBodyModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RegisterBodyModel.fromMap(Map<String, dynamic> json) =>
      RegisterBodyModel(
        email: json["email"],
        password: json["password"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
        roles: json["roles"] == null
            ? []
            : List<String>.from(json["roles"]!.map((x) => x)),
        dateOfBirth: json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
        address: json["address"],
        location: json["location"],
        gender: json["gender"],
        maritalStatus: json["marital_status"],
        alternativePhone: json["alternative_phone"],
        nationalIdNumber: json["national_id_number"],
        nationalIdImageUrl: json["national_id_image_url"],
        passportImageUrl: json["passport_image_url"],
        proofOfAddressUrl: json["proof_of_address_url"],
        profilePicUrl: json["profile_pic_url"],
        passportExpiryDate: json["passport_expiry_date"] == null
            ? null
            : DateTime.parse(json["passport_expiry_date"]),
        drivingLicenseExpiryDate: json["driving_license_expiry_date"] == null
            ? null
            : DateTime.parse(json["driving_license_expiry_date"]),
        nationalIdExpiryDate: json["national_id_expiry_date"] == null
            ? null
            : DateTime.parse(json["national_id_expiry_date"]),
        employmentDetails: json["employment_details"] == null
            ? null
            : EmploymentDetails.fromMap(json["employment_details"]),
        nextOfKin: json["next_of_kin"] == null
            ? null
            : NextOfKin.fromMap(json["next_of_kin"]),
        isEmployed: json["is_employed"],
        termsAcceptedAt: json["terms_accepted_at"] == null
            ? null
            : DateTime.parse(json["terms_accepted_at"]),
        documents: json["documents"] == null
            ? []
            : List<Document>.from(
                json["documents"]!.map((x) => Document.fromMap(x)),
              ),
      );

  Map<String, dynamic> toMap() => {
    "email": email,
    "password": password,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    if (dateOfBirth != null)
      "date_of_birth":
          "${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}",
    "address": address,
    "location": location,
    "gender": gender,
    "marital_status": maritalStatus,
    "alternative_phone": alternativePhone,
    "national_id_number": nationalIdNumber,
    "national_id_image_url": nationalIdImageUrl,
    "passport_image_url": passportImageUrl,
    "proof_of_address_url": proofOfAddressUrl,
    "profile_pic_url": profilePicUrl,
    if (passportExpiryDate != null)
      "passport_expiry_date":
          "${passportExpiryDate!.year.toString().padLeft(4, '0')}-${passportExpiryDate!.month.toString().padLeft(2, '0')}-${passportExpiryDate!.day.toString().padLeft(2, '0')}",
    if (drivingLicenseExpiryDate != null)
      "driving_license_expiry_date":
          "${drivingLicenseExpiryDate!.year.toString().padLeft(4, '0')}-${drivingLicenseExpiryDate!.month.toString().padLeft(2, '0')}-${drivingLicenseExpiryDate!.day.toString().padLeft(2, '0')}",
    if (nationalIdExpiryDate != null)
      "national_id_expiry_date":
          "${nationalIdExpiryDate!.year.toString().padLeft(4, '0')}-${nationalIdExpiryDate!.month.toString().padLeft(2, '0')}-${nationalIdExpiryDate!.day.toString().padLeft(2, '0')}",
    "employment_details": employmentDetails?.toMap(),
    "next_of_kin": nextOfKin?.toMap(),
    "is_employed": isEmployed,
    "terms_accepted_at": termsAcceptedAt?.toIso8601String(),
    "documents": documents == null
        ? []
        : List<dynamic>.from(documents!.map((x) => x.toMap())),
  };
}

class Document {
  final String? type;
  final String? url;
  final String? fileName;
  final String? mimeType;
  final String? notes;

  Document({this.type, this.url, this.fileName, this.mimeType, this.notes});

  factory Document.fromJson(String str) => Document.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Document.fromMap(Map<String, dynamic> json) => Document(
    type: json["type"],
    url: json["url"],
    fileName: json["file_name"],
    mimeType: json["mime_type"],
    notes: json["notes"],
  );

  Map<String, dynamic> toMap() => {
    "type": type,
    "url": url,
    "file_name": fileName,
    "mime_type": mimeType,
    "notes": notes,
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

  factory EmploymentDetails.fromJson(String str) =>
      EmploymentDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EmploymentDetails.fromMap(Map<String, dynamic> json) =>
      EmploymentDetails(
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
