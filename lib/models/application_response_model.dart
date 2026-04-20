import 'dart:convert';

class LoanApplicationResponseModel {
  final String loanId;
  final String loanCategory;
  final String applicationNo;
  final String userId;

  LoanApplicationResponseModel({
    required this.loanId,
    required this.loanCategory,
    required this.applicationNo,
    required this.userId,
  });

  factory LoanApplicationResponseModel.fromJson(String str) =>
      LoanApplicationResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoanApplicationResponseModel.fromMap(Map<String, dynamic> json) =>
      LoanApplicationResponseModel(
        loanId: json["_id"] ?? "",
        loanCategory: json["collateral_category"] ?? "",
        applicationNo: json["application_no"] ?? "",
        userId: json["customer_user"]?["_id"] ?? json["created_by"] ?? "",
      );

  Map<String, dynamic> toMap() => {
    "loanId": loanId,
    "loanCategory": loanCategory,
    "applicationNo": applicationNo,
    "userId": userId,
  };
}
