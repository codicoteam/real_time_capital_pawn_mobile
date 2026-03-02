import 'dart:convert';

class UserModel {
  final String? fullName;
  final String? userId;
  final String? email;
  final List<String>? roles;
  final int? iat;
  final int? exp;

  UserModel({
    this.fullName,
    this.userId,
    this.email,
    this.roles,
    this.iat,
    this.exp,
  });

  factory UserModel.fromJson(String str) => UserModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    fullName: json["full_name"],
    userId: json["userId"],
    email: json["email"],
    roles: json["roles"] == null
        ? []
        : List<String>.from(json["roles"]!.map((x) => x)),
    iat: json["iat"],
    exp: json["exp"],
  );

  Map<String, dynamic> toMap() => {
    "full_name": fullName,
    "userId": userId,
    "email": email,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "iat": iat,
    "exp": exp,
  };
}
