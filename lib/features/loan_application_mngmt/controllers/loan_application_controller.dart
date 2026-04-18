import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/profile_mngmt/helpers/profile_mngmt_helper.dart';
import 'package:real_time_pawn/widgets/loading_widgets/circular_loader.dart';
import '../../../core/utils/shared_pref_methods.dart' show CacheUtils;
import '../helpers/loan_application_mngmt_helper.dart'
    show LoanApplicationHelper;
import '../screens/Loan application upload screen.dart'
    show LoanApplicationUploadScreen;

class LoanApplicationControllerTwo extends GetxController {
  // Loan Information Controllers
  final loanAmountController = TextEditingController();
  final collateralDescController = TextEditingController();
  final suretyDescController = TextEditingController();
  final assetValueController = TextEditingController();

  // Electronics (Small Loans) Details Controllers
  final electronicTypeController = TextEditingController();
  final electronicModelController = TextEditingController();
  final electronicSerialController = TextEditingController();

  // Motor Vehicle Details Controllers
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleRegController = TextEditingController();
  final vehicleCcSerialController = TextEditingController();
  final vehicleEngineController = TextEditingController();
  final vehicleChassisController = TextEditingController();
  final vehicleYearController = TextEditingController();

  // Jewellery Details Controllers
  final jewelTypeController = TextEditingController();
  final jewelDescController = TextEditingController();
  final jewelWeightController = TextEditingController();
  final jewelPurityController = TextEditingController();
  final jewelEstimatedValueController = TextEditingController();

  // Collateral Images (multiple)
  final collateralImages = <XFile>[].obs;
  final collateralImageUrls = <String>[].obs;
  final isUploadingCollateralImages = false.obs;

  // Reactive selected values
  final selectedLoanCategory = RxnString();
  final selectedLoanCategoryType = RxnString(); // for API
  final selectedRepaymentType = RxString(
    'once_off',
  ); // 'once_off' or 'installment'
  final selectedInstallmentFrequency = RxString(
    'monthly',
  ); // weekly, biweekly, monthly, quarterly
  final installmentCount = 1.obs;
  final isDeclarationChecked = false.obs;

  // UI state
  final isSubmitting = false.obs;
  final userData = Rx<Map<String, dynamic>?>(null);
  final showProfileInfo = false.obs;

  // Form validity (updated via listeners)
  final isFormValid = false.obs;

  // Repayment options
  final repaymentTypeOptions = [
    {
      'title': 'Once Off',
      'value': 'once_off',
      'icon': Icons.check_circle_outline,
    },
    {
      'title': 'Installment',
      'value': 'installment',
      'icon': Icons.calendar_month_outlined,
    },
  ];

  final installmentFrequencyOptions = [
    {'title': 'Weekly', 'value': 'weekly'},
    {'title': 'Bi-Weekly', 'value': 'biweekly'},
    {'title': 'Monthly', 'value': 'monthly'},
    {'title': 'Quarterly', 'value': 'quarterly'},
  ];

  final loanCategories = [
    {
      'title': 'Electronics',
      'type': 'small_loans',
      'icon': Icons.devices,
      'color': RealTimeColors.primaryGreen,
    },
    {
      'title': 'Motor Vehicle',
      'type': 'motor_vehicle',
      'icon': Icons.directions_car,
      'color': RealTimeColors.primaryGreen,
    },
    {
      'title': 'Jewelry',
      'type': 'jewellery',
      'icon': Icons.diamond,
      'color': RealTimeColors.primaryGreen,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    _loadUserProfileInfo();
  }

  void _setupListeners() {
    // Base controllers
    final baseControllers = [
      loanAmountController,
      collateralDescController,
      assetValueController,
    ];

    for (var controller in baseControllers) {
      controller.addListener(_checkFormValidity);
    }

    // Motor Vehicle controllers
    final vehicleControllers = [
      vehicleMakeController,
      vehicleModelController,
      vehicleRegController,
      vehicleCcSerialController,
      vehicleEngineController,
      vehicleChassisController,
      vehicleYearController,
    ];

    for (var controller in vehicleControllers) {
      controller.addListener(_checkFormValidity);
    }

    // Electronics controllers
    final electronicControllers = [
      electronicTypeController,
      electronicModelController,
      electronicSerialController,
    ];

    for (var controller in electronicControllers) {
      controller.addListener(_checkFormValidity);
    }

    // Jewellery controllers
    final jewelleryControllers = [
      jewelTypeController,
      jewelDescController,
      jewelWeightController,
      jewelPurityController,
      jewelEstimatedValueController,
    ];

    for (var controller in jewelleryControllers) {
      controller.addListener(_checkFormValidity);
    }

    // Listen to selected values
    ever(selectedLoanCategoryType, (_) {
      _clearCategoryFields();
      _checkFormValidity();
    });
    ever(selectedRepaymentType, (_) => _checkFormValidity());
    ever(selectedInstallmentFrequency, (_) => _checkFormValidity());
    ever(installmentCount, (_) => _checkFormValidity());
    ever(isDeclarationChecked, (_) => _checkFormValidity());
    ever(collateralImages, (_) => _checkFormValidity());
  }

  void _checkFormValidity() {
    // Base required fields
    bool baseValid =
        loanAmountController.text.isNotEmpty &&
        double.tryParse(loanAmountController.text) != null &&
        selectedLoanCategory.value != null &&
        collateralDescController.text.isNotEmpty &&
        assetValueController.text.isNotEmpty &&
        double.tryParse(assetValueController.text) != null &&
        isDeclarationChecked.value;

    if (!baseValid) {
      isFormValid.value = false;
      return;
    }

    // Validate loan amount is positive
    double loanAmount = double.tryParse(loanAmountController.text) ?? 0;
    double assetValue = double.tryParse(assetValueController.text) ?? 0;
    if (loanAmount <= 0 || assetValue <= 0) {
      isFormValid.value = false;
      return;
    }

    // Repayment type specific validation
    if (selectedRepaymentType.value == 'installment') {
      if (installmentCount.value < 1 || installmentCount.value > 48) {
        isFormValid.value = false;
        return;
      }
    }

    // Category-specific required fields
    final categoryType = selectedLoanCategoryType.value;
    
    if (categoryType == null) {
      isFormValid.value = false;
      return;
    }

    if (categoryType == 'motor_vehicle') {
      final isValid = 
          vehicleMakeController.text.isNotEmpty &&
          vehicleModelController.text.isNotEmpty &&
          vehicleRegController.text.isNotEmpty &&
          vehicleCcSerialController.text.isNotEmpty &&
          vehicleEngineController.text.isNotEmpty &&
          vehicleChassisController.text.isNotEmpty &&
          vehicleYearController.text.isNotEmpty &&
          int.tryParse(vehicleYearController.text) != null;
      
      isFormValid.value = isValid;
    } else if (categoryType == 'small_loans') {
      final isValid =
          electronicTypeController.text.isNotEmpty &&
          electronicModelController.text.isNotEmpty &&
          electronicSerialController.text.isNotEmpty;
      
      isFormValid.value = isValid;
    } else if (categoryType == 'jewellery') {
      final isValid = 
          jewelTypeController.text.isNotEmpty &&
          jewelDescController.text.isNotEmpty &&
          jewelWeightController.text.isNotEmpty &&
          double.tryParse(jewelWeightController.text) != null &&
          jewelPurityController.text.isNotEmpty &&
          jewelEstimatedValueController.text.isNotEmpty &&
          double.tryParse(jewelEstimatedValueController.text) != null;
      
      isFormValid.value = isValid;
    } else {
      isFormValid.value = false;
    }
    
    // Debug logging to help troubleshoot
    DevLogs.logInfo('Form validity check - Category: $categoryType, IsValid: ${isFormValid.value}');
  }

  void _clearCategoryFields() {
    vehicleMakeController.clear();
    vehicleModelController.clear();
    vehicleRegController.clear();
    vehicleCcSerialController.clear();
    vehicleEngineController.clear();
    vehicleChassisController.clear();
    vehicleYearController.clear();

    electronicTypeController.clear();
    electronicModelController.clear();
    electronicSerialController.clear();

    jewelTypeController.clear();
    jewelDescController.clear();
    jewelWeightController.clear();
    jewelPurityController.clear();
    jewelEstimatedValueController.clear();
  }

  Future<void> _loadUserProfileInfo() async {
    final data = await ProfileMngmtHelper.getUserDataForLoanApplication();
    if (data != null) {
      userData.value = data;
      showProfileInfo.value = true;
    }
  }

  Future<List<String>> _uploadCollateralImages() async {
    if (collateralImages.isEmpty) return [];

    isUploadingCollateralImages.value = true;
    List<String> uploadedUrls = [];

    try {
      final userId = await CacheUtils.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      const bucket = 'topics';

      for (int i = 0; i < collateralImages.length; i++) {
        final file = collateralImages[i];
        final filePath =
            '$userId/loan_collateral/${DateTime.now().millisecondsSinceEpoch}_${i}_${file.name}';

        await Supabase.instance.client.storage
            .from(bucket)
            .upload(filePath, File(file.path));

        final publicUrl = Supabase.instance.client.storage
            .from(bucket)
            .getPublicUrl(filePath);

        uploadedUrls.add(publicUrl);
      }

      collateralImageUrls.assignAll(uploadedUrls);
      return uploadedUrls;
    } catch (e) {
      DevLogs.logError('Failed to upload collateral images: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload collateral images: ${e.toString()}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return [];
    } finally {
      isUploadingCollateralImages.value = false;
    }
  }

  Future<void> pickCollateralImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage(
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      if (collateralImages.length + pickedFiles.length > 6) {
        Get.snackbar(
          'Limit Reached',
          'Maximum 6 images allowed',
          backgroundColor: AppColors.warningColor,
          colorText: Colors.white,
        );
        return;
      }
      collateralImages.addAll(pickedFiles);
    }
  }

  void removeCollateralImage(int index) {
    collateralImages.removeAt(index);
  }

  /// Validates the entire form and shows a snackbar with missing fields if invalid.
  bool validateForm({bool showSnackbar = true}) {
    List<String> missingFields = [];

    // Base fields
    if (loanAmountController.text.isEmpty) missingFields.add('Loan Amount');
    if (selectedLoanCategory.value == null) missingFields.add('Loan Category');
    if (collateralDescController.text.isEmpty)
      missingFields.add('Collateral Description');
    if (assetValueController.text.isEmpty)
      missingFields.add('Declared Asset Value');
    if (!isDeclarationChecked.value) missingFields.add('Declaration Checkbox');

    // Validate numeric values
    double? loanAmount = double.tryParse(loanAmountController.text);
    double? assetValue = double.tryParse(assetValueController.text);
    if (loanAmount == null) missingFields.add('Valid Loan Amount');
    if (assetValue == null) missingFields.add('Valid Asset Value');
    if (loanAmount != null && loanAmount <= 0)
      missingFields.add('Loan Amount > 0');
    if (assetValue != null && assetValue <= 0)
      missingFields.add('Asset Value > 0');

    // Repayment validation
    if (selectedRepaymentType.value == 'installment') {
      if (installmentCount.value < 1)
        missingFields.add('Installment Count (min 1)');
      if (installmentCount.value > 48)
        missingFields.add('Installment Count (max 48)');
    }

    // Category-specific fields
    if (selectedLoanCategoryType.value == 'motor_vehicle') {
      if (vehicleMakeController.text.isEmpty) missingFields.add('Vehicle Make');
      if (vehicleModelController.text.isEmpty)
        missingFields.add('Vehicle Model');
      if (vehicleRegController.text.isEmpty)
        missingFields.add('Registration Number');
      if (vehicleCcSerialController.text.isEmpty)
        missingFields.add('CC/Serial Number');
      if (vehicleEngineController.text.isEmpty)
        missingFields.add('Engine Number');
      if (vehicleChassisController.text.isEmpty)
        missingFields.add('Chassis Number');
      if (vehicleYearController.text.isEmpty) missingFields.add('Vehicle Year');
      if (int.tryParse(vehicleYearController.text) == null)
        missingFields.add('Valid Vehicle Year');
    } else if (selectedLoanCategoryType.value == 'small_loans') {
      if (electronicTypeController.text.isEmpty)
        missingFields.add('Electronic Type');
      if (electronicModelController.text.isEmpty)
        missingFields.add('Electronic Model');
      if (electronicSerialController.text.isEmpty)
        missingFields.add('Serial Number');
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      if (jewelTypeController.text.isEmpty) missingFields.add('Jewellery Type');
      if (jewelDescController.text.isEmpty)
        missingFields.add('Jewellery Description');
      if (jewelWeightController.text.isEmpty) missingFields.add('Weight');
      if (double.tryParse(jewelWeightController.text) == null)
        missingFields.add('Valid Weight Number');
      if (jewelPurityController.text.isEmpty) missingFields.add('Purity');
      if (jewelEstimatedValueController.text.isEmpty)
        missingFields.add('Estimated Value');
      if (double.tryParse(jewelEstimatedValueController.text) == null)
        missingFields.add('Valid Estimated Value');
    }

    if (missingFields.isNotEmpty) {
      if (showSnackbar) {
        String message = 'Missing: ${missingFields.join(', ')}';
        Get.snackbar(
          'Incomplete Form',
          message,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: 4000.ms,
        );
      }
      return false;
    }
    return true;
  }

  Future<void> submitApplication() async {
    if (!validateForm()) return;

    isSubmitting.value = true;

    // Upload collateral images first
    List<String> imageUrls = await _uploadCollateralImages();

    // Build payload according to the new schema
    double loanAmount = double.parse(loanAmountController.text);
    double assetValue = double.parse(assetValueController.text);

    Map<String, dynamic> payload = {
      "requested_loan_amount": loanAmount,
      "collateral_category": selectedLoanCategoryType.value,
      "collateral_description": collateralDescController.text,
      "surety_description": suretyDescController.text.isNotEmpty
          ? suretyDescController.text
          : null,
      "declared_asset_value": assetValue,
      "collateral_images": imageUrls,
      "repayment_type": selectedRepaymentType.value,
      "repayment_days": _calculateRepaymentDays(),
      "declaration_text": _getDeclarationText(),
      "declaration_signed_at": DateTime.now().toIso8601String(),
      "declaration_signature_name": userData.value?['fullName'] ?? 'Customer',
      "custom_terms_and_conditions": _getCustomTerms(),
    };

    // Add category-specific details
    if (selectedLoanCategoryType.value == 'motor_vehicle') {
      payload["motor_vehicle_details"] = {
        "make": vehicleMakeController.text,
        "model": vehicleModelController.text,
        "registration_no": vehicleRegController.text,
        "cc_serial_no": vehicleCcSerialController.text,
        "engine_no": vehicleEngineController.text,
        "chassis_no": vehicleChassisController.text,
        "year": int.tryParse(vehicleYearController.text),
      };
    } else if (selectedLoanCategoryType.value == 'small_loans') {
      payload["small_loan_details"] = {
        "type": electronicTypeController.text,
        "model": electronicModelController.text,
        "serial_no": electronicSerialController.text,
      };
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      payload["jewellery_details"] = {
        "type": jewelTypeController.text,
        "description": jewelDescController.text,
        "weight": double.tryParse(jewelWeightController.text),
        "purity": jewelPurityController.text,
        "estimated_value": double.tryParse(jewelEstimatedValueController.text),
      };
    }

    // Add installment-specific fields if applicable
    if (selectedRepaymentType.value == 'installment') {
      payload["installment_count"] = installmentCount.value;
      payload["installment_frequency"] = selectedInstallmentFrequency.value;

      // Calculate approximate installment amount (simplified - actual calculation may vary)
      double estimatedInstallmentAmount = loanAmount / installmentCount.value;
      payload["installment_amount"] = estimatedInstallmentAmount;
    }

    DevLogs.logInfo("Submitting loan application payload: $payload");

    // Show loader
    Get.dialog(
      const CustomLoader(message: 'Submitting application...'),
      barrierDismissible: false,
    );

    final result = await LoanApplicationHelper.createLoanApplication(
      payload: payload,
    );

    // Close loader
    if (Get.isDialogOpen ?? false) Get.back();

    isSubmitting.value = false;

    if (result.success && result.loanId != null) {
      final currentUserId = await CacheUtils.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        Get.snackbar(
          'Error',
          'User ID not found. Please login again.',
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      Get.to(
        () => LoanApplicationUploadScreen(
          loanId: result.loanId!,
          loanCategory: selectedLoanCategory.value ?? '',
          applicationNo: result.applicationNo ?? '',
          userId: currentUserId,
        ),
      );
    } else {
      Get.snackbar(
        'Submission Failed',
        result.message ?? 'Failed to create application',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  int _calculateRepaymentDays() {
    // Default to 30 days for once-off
    if (selectedRepaymentType.value == 'once_off') return 30;

    // For installment, calculate based on frequency and count
    int daysPerFrequency = 30; // default monthly
    switch (selectedInstallmentFrequency.value) {
      case 'weekly':
        daysPerFrequency = 7;
        break;
      case 'biweekly':
        daysPerFrequency = 14;
        break;
      case 'monthly':
        daysPerFrequency = 30;
        break;
      case 'quarterly':
        daysPerFrequency = 90;
        break;
    }
    return installmentCount.value * daysPerFrequency;
  }

  String _getDeclarationText() {
    String itemDescription = '';
    if (selectedLoanCategoryType.value == 'small_loans') {
      itemDescription =
          '${electronicTypeController.text} ${electronicModelController.text}';
    } else if (selectedLoanCategoryType.value == 'motor_vehicle') {
      itemDescription =
          '${vehicleMakeController.text} ${vehicleModelController.text}';
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      itemDescription = jewelTypeController.text;
    }

    return 'I confirm that the $itemDescription offered as collateral is fully owned by me with no outstanding loans or disputes.';
  }

  String _getCustomTerms() {
    if (selectedRepaymentType.value == 'once_off') {
      return 'Standard loan terms apply. Late payment penalty of 10% of outstanding amount. Full repayment due within ${_calculateRepaymentDays()} days.';
    } else {
      return 'Standard loan terms apply. Late payment penalty of 10% of outstanding amount. ${installmentCount.value} installments on a ${selectedInstallmentFrequency.value} basis.';
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    loanAmountController.dispose();
    collateralDescController.dispose();
    suretyDescController.dispose();
    assetValueController.dispose();
    electronicTypeController.dispose();
    electronicModelController.dispose();
    electronicSerialController.dispose();
    vehicleMakeController.dispose();
    vehicleModelController.dispose();
    vehicleRegController.dispose();
    vehicleCcSerialController.dispose();
    vehicleEngineController.dispose();
    vehicleChassisController.dispose();
    vehicleYearController.dispose();
    jewelTypeController.dispose();
    jewelDescController.dispose();
    jewelWeightController.dispose();
    jewelPurityController.dispose();
    jewelEstimatedValueController.dispose();
    super.onClose();
  }
}