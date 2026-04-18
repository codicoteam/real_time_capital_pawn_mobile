import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart'
    show CacheUtils;
import 'package:real_time_pawn/models/loan_application_model.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/services/loan_application_mngmt_service.dart'
    show LoanApplicationService;

import '../../../config/routers/router.dart';

class UpdateLoanApplicationController extends GetxController {
  // =====================
  // Loan Information Controllers (Editable)
  // =====================
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

  // Collateral Images (can be updated)
  final collateralImages = <XFile>[].obs;
  final existingCollateralImageUrls = <String>[].obs;
  final isUploadingCollateralImages = false.obs;

  // Reactive selected values
  final selectedLoanCategory = RxnString();
  final selectedLoanCategoryType = RxnString(); // for API
  final selectedRepaymentType = RxString('once_off');
  final selectedInstallmentFrequency = RxString('monthly');
  final installmentCount = 1.obs;
  final isDeclarationChecked = false.obs;

  // UI state
  final isSubmitting = false.obs;
  final isFormValid = false.obs;
  final isLoading = false.obs;

  // Original loan application ID
  String? loanApplicationId;
  
  // Original data for comparison
  LoanApplicationModel? originalApplication;

  // Repayment options
  final repaymentTypeOptions = [
    {'title': 'Once Off', 'value': 'once_off', 'icon': Icons.check_circle_outline},
    {'title': 'Installment', 'value': 'installment', 'icon': Icons.calendar_month_outlined},
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
  }

  void _setupListeners() {
    // Listen to loan controllers
    final loanControllers = [
      loanAmountController,
      collateralDescController,
      assetValueController,
    ];
    for (var ctrl in loanControllers) {
      ctrl.addListener(_checkFormValidity);
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
    for (var ctrl in vehicleControllers) {
      ctrl.addListener(_checkFormValidity);
    }

    // Electronics controllers
    final electronicControllers = [
      electronicTypeController,
      electronicModelController,
      electronicSerialController,
    ];
    for (var ctrl in electronicControllers) {
      ctrl.addListener(_checkFormValidity);
    }

    // Jewellery controllers
    final jewelleryControllers = [
      jewelTypeController,
      jewelDescController,
      jewelWeightController,
      jewelPurityController,
      jewelEstimatedValueController,
    ];
    for (var ctrl in jewelleryControllers) {
      ctrl.addListener(_checkFormValidity);
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
      isFormValid.value =
          vehicleMakeController.text.isNotEmpty &&
          vehicleModelController.text.isNotEmpty &&
          vehicleRegController.text.isNotEmpty &&
          vehicleCcSerialController.text.isNotEmpty &&
          vehicleEngineController.text.isNotEmpty &&
          vehicleChassisController.text.isNotEmpty &&
          vehicleYearController.text.isNotEmpty &&
          int.tryParse(vehicleYearController.text) != null;
    } else if (categoryType == 'small_loans') {
      isFormValid.value =
          electronicTypeController.text.isNotEmpty &&
          electronicModelController.text.isNotEmpty &&
          electronicSerialController.text.isNotEmpty;
    } else if (categoryType == 'jewellery') {
      isFormValid.value =
          jewelTypeController.text.isNotEmpty &&
          jewelDescController.text.isNotEmpty &&
          jewelWeightController.text.isNotEmpty &&
          double.tryParse(jewelWeightController.text) != null &&
          jewelPurityController.text.isNotEmpty &&
          jewelEstimatedValueController.text.isNotEmpty &&
          double.tryParse(jewelEstimatedValueController.text) != null;
    } else {
      isFormValid.value = false;
    }
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

  /// Populate all fields from an existing LoanApplicationModel
  void initWithModel(LoanApplicationModel model) {
    isLoading.value = true;
    originalApplication = model;
    loanApplicationId = model.id;

    // Loan details
    loanAmountController.text = model.requestedLoanAmount?.toString() ?? '';
    assetValueController.text = model.declaredAssetValue?.toString() ?? '';
    collateralDescController.text = model.collateralDescription ?? '';
    suretyDescController.text = model.suretyDescription ?? '';

    // Repayment type
    if (model.repaymentType != null) {
      selectedRepaymentType.value = model.repaymentType!;
    }
    
    // Installment details
    if (model.installmentCount != null) {
      installmentCount.value = model.installmentCount!;
    }
    if (model.installmentFrequency != null) {
      selectedInstallmentFrequency.value = model.installmentFrequency!;
    }

    // Find category
    final category = loanCategories.firstWhere(
      (c) => c['type'] == model.collateralCategory,
      orElse: () => loanCategories.first,
    );
    selectedLoanCategory.value = category['title'] as String;
    selectedLoanCategoryType.value = model.collateralCategory;

    // Category-specific details
    if (model.motorVehicleDetails != null) {
      vehicleMakeController.text = model.motorVehicleDetails!.make ?? '';
      vehicleModelController.text = model.motorVehicleDetails!.model ?? '';
      vehicleRegController.text = model.motorVehicleDetails!.registrationNo ?? '';
      vehicleCcSerialController.text = model.motorVehicleDetails!.ccSerialNo ?? '';
      vehicleEngineController.text = model.motorVehicleDetails!.engineNo ?? '';
      vehicleChassisController.text = model.motorVehicleDetails!.chassisNo ?? '';
      vehicleYearController.text = model.motorVehicleDetails!.year?.toString() ?? '';
    } else if (model.smallLoanDetails != null) {
      electronicTypeController.text = model.smallLoanDetails!.type ?? '';
      electronicModelController.text = model.smallLoanDetails!.model ?? '';
      electronicSerialController.text = model.smallLoanDetails!.serialNo ?? '';
    } else if (model.jewelleryDetails != null) {
      jewelTypeController.text = model.jewelleryDetails!.type ?? '';
      jewelDescController.text = model.jewelleryDetails!.description ?? '';
      jewelWeightController.text = model.jewelleryDetails!.weight?.toString() ?? '';
      jewelPurityController.text = model.jewelleryDetails!.purity ?? '';
      jewelEstimatedValueController.text = model.jewelleryDetails!.estimatedValue?.toString() ?? '';
    }

    // Existing collateral images
    if (model.collateralImages != null) {
      existingCollateralImageUrls.assignAll(model.collateralImages!);
    }

    // Declaration checkbox
    isDeclarationChecked.value = true;

    isLoading.value = false;
    _checkFormValidity();
  }

  Future<List<String>> _uploadNewCollateralImages() async {
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

  void removeNewCollateralImage(int index) {
    collateralImages.removeAt(index);
  }

  void removeExistingCollateralImage(int index) {
    existingCollateralImageUrls.removeAt(index);
  }

  /// Validate form and return missing fields list
  List<String> getMissingFields() {
    List<String> missing = [];

    // Base fields
    if (loanAmountController.text.isEmpty) missing.add('Loan Amount');
    if (selectedLoanCategory.value == null) missing.add('Loan Category');
    if (collateralDescController.text.isEmpty) missing.add('Collateral Description');
    if (assetValueController.text.isEmpty) missing.add('Declared Asset Value');
    if (!isDeclarationChecked.value) missing.add('Declaration Checkbox');

    // Validate numeric values
    double? loanAmount = double.tryParse(loanAmountController.text);
    double? assetValue = double.tryParse(assetValueController.text);
    if (loanAmount == null) missing.add('Valid Loan Amount');
    if (assetValue == null) missing.add('Valid Asset Value');
    if (loanAmount != null && loanAmount <= 0) missing.add('Loan Amount > 0');
    if (assetValue != null && assetValue <= 0) missing.add('Asset Value > 0');

    // Repayment validation
    if (selectedRepaymentType.value == 'installment') {
      if (installmentCount.value < 1) missing.add('Installment Count (min 1)');
      if (installmentCount.value > 48) missing.add('Installment Count (max 48)');
    }

    // Category-specific fields
    if (selectedLoanCategoryType.value == 'motor_vehicle') {
      if (vehicleMakeController.text.isEmpty) missing.add('Vehicle Make');
      if (vehicleModelController.text.isEmpty) missing.add('Vehicle Model');
      if (vehicleRegController.text.isEmpty) missing.add('Registration Number');
      if (vehicleCcSerialController.text.isEmpty) missing.add('CC/Serial Number');
      if (vehicleEngineController.text.isEmpty) missing.add('Engine Number');
      if (vehicleChassisController.text.isEmpty) missing.add('Chassis Number');
      if (vehicleYearController.text.isEmpty) missing.add('Vehicle Year');
    } else if (selectedLoanCategoryType.value == 'small_loans') {
      if (electronicTypeController.text.isEmpty) missing.add('Electronic Type');
      if (electronicModelController.text.isEmpty) missing.add('Electronic Model');
      if (electronicSerialController.text.isEmpty) missing.add('Serial Number');
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      if (jewelTypeController.text.isEmpty) missing.add('Jewellery Type');
      if (jewelDescController.text.isEmpty) missing.add('Jewellery Description');
      if (jewelWeightController.text.isEmpty) missing.add('Weight');
      if (jewelPurityController.text.isEmpty) missing.add('Purity');
      if (jewelEstimatedValueController.text.isEmpty) missing.add('Estimated Value');
    }

    return missing;
  }

  /// Submit the updated application
  Future<void> submitUpdate() async {
    final missing = getMissingFields();
    if (missing.isNotEmpty) {
      Get.snackbar(
        'Incomplete Form',
        'Missing: ${missing.join(', ')}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: 4000.ms,
      );
      return;
    }

    if (loanApplicationId == null) {
      Get.snackbar(
        'Error',
        'Loan application ID is missing',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    // Upload new collateral images
    List<String> newImageUrls = await _uploadNewCollateralImages();
    
    // Combine existing and new images
    List<String> allImageUrls = [
      ...existingCollateralImageUrls,
      ...newImageUrls,
    ];

    // Build payload (ONLY loan-specific fields - NO personal/KYC data)
    double loanAmount = double.parse(loanAmountController.text);
    double assetValue = double.parse(assetValueController.text);

    Map<String, dynamic> payload = {
      "requested_loan_amount": loanAmount,
      "collateral_category": selectedLoanCategoryType.value,
      "collateral_description": collateralDescController.text,
      "surety_description": suretyDescController.text.isNotEmpty ? suretyDescController.text : null,
      "declared_asset_value": assetValue,
      "collateral_images": allImageUrls,
      "repayment_type": selectedRepaymentType.value,
      "repayment_days": _calculateRepaymentDays(),
      "declaration_text": _getDeclarationText(),
      "declaration_signed_at": DateTime.now().toIso8601String(),
      "declaration_signature_name": originalApplication?.customerUser?.firstName ?? 'Customer',
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
      
      double estimatedInstallmentAmount = loanAmount / installmentCount.value;
      payload["installment_amount"] = estimatedInstallmentAmount;
    }

    DevLogs.logInfo("Updating loan application $loanApplicationId");
    DevLogs.logInfo("Update payload: $payload");

    // Show loader
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await LoanApplicationService.updateLoanApplication(
        loanApplicationId: loanApplicationId!,
        payload: payload,
      );

      // Close loader
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'Application updated successfully',
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );

        await Future.delayed(const Duration(seconds: 1));
        
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Update Failed',
          response.message ?? 'Failed to update application',
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      DevLogs.logError('Update error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  int _calculateRepaymentDays() {
    if (selectedRepaymentType.value == 'once_off') return 30;

    int daysPerFrequency = 30;
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
      itemDescription = '${electronicTypeController.text} ${electronicModelController.text}';
    } else if (selectedLoanCategoryType.value == 'motor_vehicle') {
      itemDescription = '${vehicleMakeController.text} ${vehicleModelController.text}';
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