import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:real_time_pawn/config/api_config/api_keys.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/utils/logs.dart';
import '../../../core/utils/shared_pref_methods.dart';
import '../../../models/application_response_model.dart';
import '../../../models/loan_application_model.dart';

class LoanApplicationService {
  /// 🔹 Create loan application
static Future<APIResponse<LoanApplicationResponseModel>> createLoanApplication({
  required Map<String, dynamic> payload,
}) async {
  final token = await CacheUtils.checkToken();
  final String url = '${ApiKeys.baseUrl}/loan-applications';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    DevLogs.logInfo('Create loan application response: ${response.body}');
    debugPrint('Create loan application response: ${response.body}', wrapWidth: 1024);
    final decoded = json.decode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final application = LoanApplicationResponseModel.fromMap(decoded['data']);
      return APIResponse<LoanApplicationResponseModel>(
        success: true,
        data: application,
        message: decoded['message'] ?? 'Loan application created successfully',
      );
    } else {
      return APIResponse<LoanApplicationResponseModel>(
        success: false,
        message: decoded['message'] ?? 'Failed to create loan application. HTTP ${response.statusCode}',
      );
    }
  } catch (e) {
    DevLogs.logError('Create loan application error: $e');
    return APIResponse<LoanApplicationResponseModel>(
      success: false,
      message: 'Error creating loan application: $e',
    );
  }
}
  /// 🔹 Get loan applications by customer user
  static Future<APIResponse<List<LoanApplicationModel>>>
  getLoanApplicationsByCustomer({
    required String customerUserId,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final token = await CacheUtils.checkToken();

    final String url =
        '${ApiKeys.baseUrl}/loan-applications'
        '?sortBy=$sortBy'
        '&sortOrder=$sortOrder'
        '&customer_user=$customerUserId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      DevLogs.logInfo('Get loan applications response: ${response.body}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        final List applicationsJson = decoded['data']?['applications'] ?? [];

        final applications = applicationsJson
            .map((e) => LoanApplicationModel.fromMap(e as Map<String, dynamic>))
            .toList();
        return APIResponse<List<LoanApplicationModel>>(
          success: true,
          data: applications,
          message:
              decoded['message'] ?? 'Loan applications retrieved successfully',
        );
      } else {
        return APIResponse<List<LoanApplicationModel>>(
          success: false,
          message:
              decoded['message'] ??
              'Failed to fetch loan applications. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Get loan applications error: $e');
      return APIResponse<List<LoanApplicationModel>>(
        success: false,
        message: 'Error fetching loan applications: $e',
      );
    }
  }

  /// 🔹 Update loan application
  static Future<APIResponse<String>> updateLoanApplication({
    required String loanApplicationId,
    required Map<String, dynamic> payload,
  }) async {
    final token = await CacheUtils.checkToken();

    final String url =
        '${ApiKeys.baseUrl}/loan-applications/$loanApplicationId';
    try {
      DevLogs.logInfo(
        'Updating loan application with payload as json: ${jsonEncode(payload)}',
      );
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      DevLogs.logInfo('Update loan application response: ${response.body}');
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return APIResponse<String>(
          success: true,
          data: "Sucess",
          message:
              decoded['message'] ?? 'Loan application updated successfully',
        );
      } else {
        return APIResponse<String>(
          success: false,
          message:
              decoded['message'] ??
              'Failed to update loan application. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      DevLogs.logError('Update loan application error: $e');
      return APIResponse<String>(
        success: false,
        message: 'Error updating loan application: $e',
      );
    }
  }
}
