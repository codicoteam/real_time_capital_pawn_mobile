// models/loan_application.dart
class LoanApplication {
  final String id;
  final String applicantName;
  final String status;
  final double amount;
  final String collateralCategory;
  final String applicationDate;

  LoanApplication({
    required this.id,
    required this.applicantName,
    required this.status,
    required this.amount,
    required this.collateralCategory,
    required this.applicationDate,
  });
}
