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

  // =====================
  // Image State
  // =====================
  final existingCollateralImageUrls = <String>[].obs;
  final collateralImages = <XFile>[].obs;
  final removedImageUrls = <String>[].obs;
  final isUploadingCollateralImages = false.obs;

  // =====================
  // Reactive selected values
  // =====================
  final selectedLoanCategory = RxnString();
  final selectedLoanCategoryType = RxnString();
  // Loan period drives repayment days and rates on the backend
  final selectedLoanPeriodType = RxString('one_month');
  final isDeclarationChecked = false.obs;

  // UI state
  final isSubmitting = false.obs;
  final isFormValid = false.obs;
  final isLoading = false.obs;

  String? loanApplicationId;
  LoanApplicationModel? originalApplication;

  // =====================
  // Static option lists
  // =====================
  final loanPeriodOptions = [
    {
      'title': '2 Weeks',
      'subtitle': '2% interest • 18% storage',
      'value': 'two_weeks',
      'icon': Icons.calendar_view_week_outlined,
    },
    {
      'title': '1 Month',
      'subtitle': '4% interest • 21% storage',
      'value': 'one_month',
      'icon': Icons.calendar_month_outlined,
    },
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

  // =====================
  // Lifecycle
  // =====================
  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  void _setupListeners() {
    final allControllers = [
      loanAmountController,
      collateralDescController,
      assetValueController,
      vehicleMakeController,
      vehicleModelController,
      vehicleRegController,
      vehicleCcSerialController,
      vehicleEngineController,
      vehicleChassisController,
      vehicleYearController,
      electronicTypeController,
      electronicModelController,
      electronicSerialController,
      jewelTypeController,
      jewelDescController,
      jewelWeightController,
      jewelPurityController,
      jewelEstimatedValueController,
    ];
    for (final ctrl in allControllers) {
      ctrl.addListener(_checkFormValidity);
    }

    ever(selectedLoanCategoryType, (_) {
      _clearCategoryFields();
      _checkFormValidity();
    });
    ever(selectedLoanPeriodType, (_) => _checkFormValidity());
    ever(isDeclarationChecked, (_) => _checkFormValidity());
  }

  // =====================
  // Form validation
  // =====================
  void _checkFormValidity() {
    final loanAmount = double.tryParse(loanAmountController.text);
    final assetValue = double.tryParse(assetValueController.text);

    final baseValid =
        loanAmountController.text.isNotEmpty &&
        loanAmount != null &&
        loanAmount > 0 &&
        assetValueController.text.isNotEmpty &&
        assetValue != null &&
        assetValue > 0 &&
        collateralDescController.text.isNotEmpty &&
        selectedLoanCategory.value != null &&
        isDeclarationChecked.value;

    if (!baseValid) {
      isFormValid.value = false;
      return;
    }

    final categoryType = selectedLoanCategoryType.value;
    if (categoryType == null) {
      isFormValid.value = false;
      return;
    }

    switch (categoryType) {
      case 'motor_vehicle':
        isFormValid.value =
            vehicleMakeController.text.isNotEmpty &&
            vehicleModelController.text.isNotEmpty &&
            vehicleRegController.text.isNotEmpty &&
            vehicleCcSerialController.text.isNotEmpty &&
            vehicleEngineController.text.isNotEmpty &&
            vehicleChassisController.text.isNotEmpty &&
            vehicleYearController.text.isNotEmpty &&
            int.tryParse(vehicleYearController.text) != null;
        break;
      case 'small_loans':
        isFormValid.value =
            electronicTypeController.text.isNotEmpty &&
            electronicModelController.text.isNotEmpty &&
            electronicSerialController.text.isNotEmpty;
        break;
      case 'jewellery':
        isFormValid.value =
            jewelTypeController.text.isNotEmpty &&
            jewelDescController.text.isNotEmpty &&
            jewelWeightController.text.isNotEmpty &&
            double.tryParse(jewelWeightController.text) != null &&
            jewelPurityController.text.isNotEmpty &&
            jewelEstimatedValueController.text.isNotEmpty &&
            double.tryParse(jewelEstimatedValueController.text) != null;
        break;
      default:
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

  // =====================
  // Init with existing model
  // =====================
  void initWithModel(LoanApplicationModel model) {
    isLoading.value = true;
    originalApplication = model;
    loanApplicationId = model.id;

    existingCollateralImageUrls.assignAll(model.collateralImages ?? []);
    collateralImages.clear();
    removedImageUrls.clear();

    loanAmountController.text = model.requestedLoanAmount?.toString() ?? '';
    assetValueController.text = model.declaredAssetValue?.toString() ?? '';
    collateralDescController.text = model.collateralDescription ?? '';
    suretyDescController.text = model.suretyDescription ?? '';

    if (model.loanPeriodType != null) {
      selectedLoanPeriodType.value = model.loanPeriodType!;
    }

    final category = loanCategories.firstWhere(
      (c) => c['type'] == model.collateralCategory,
      orElse: () => loanCategories.first,
    );
    selectedLoanCategory.value = category['title'] as String;
    selectedLoanCategoryType.value = model.collateralCategory;

    if (model.motorVehicleDetails != null) {
      vehicleMakeController.text = model.motorVehicleDetails!.make ?? '';
      vehicleModelController.text = model.motorVehicleDetails!.model ?? '';
      vehicleRegController.text =
          model.motorVehicleDetails!.registrationNo ?? '';
      vehicleCcSerialController.text =
          model.motorVehicleDetails!.ccSerialNo ?? '';
      vehicleEngineController.text = model.motorVehicleDetails!.engineNo ?? '';
      vehicleChassisController.text =
          model.motorVehicleDetails!.chassisNo ?? '';
      vehicleYearController.text =
          model.motorVehicleDetails!.year?.toString() ?? '';
    } else if (model.smallLoanDetails != null) {
      electronicTypeController.text = model.smallLoanDetails!.type ?? '';
      electronicModelController.text = model.smallLoanDetails!.model ?? '';
      electronicSerialController.text = model.smallLoanDetails!.serialNo ?? '';
    } else if (model.jewelleryDetails != null) {
      jewelTypeController.text = model.jewelleryDetails!.type ?? '';
      jewelDescController.text = model.jewelleryDetails!.description ?? '';
      jewelWeightController.text =
          model.jewelleryDetails!.weight?.toString() ?? '';
      jewelPurityController.text = model.jewelleryDetails!.purity ?? '';
      jewelEstimatedValueController.text =
          model.jewelleryDetails!.estimatedValue?.toString() ?? '';
    }

    isDeclarationChecked.value = true;
    isLoading.value = false;
    _checkFormValidity();
  }

  // =====================
  // Image helpers
  // =====================
  int get _totalImageCount =>
      existingCollateralImageUrls.length + collateralImages.length;

  Future<void> pickCollateralImages() async {
    if (isUploadingCollateralImages.value) return;

    final picker = ImagePicker();
    final List<XFile>? picked = await picker.pickMultiImage(
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (picked == null || picked.isEmpty) return;

    final slots = 6 - _totalImageCount;
    if (slots <= 0) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 6 images allowed. Remove an image first.',
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final toAdd = picked.take(slots).toList();
    collateralImages.addAll(toAdd);

    if (toAdd.length < picked.length) {
      Get.snackbar(
        'Limit Applied',
        'Only ${toAdd.length} of ${picked.length} images were added '
            '(6-image maximum).',
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void removeNewCollateralImage(int index) {
    if (index >= 0 && index < collateralImages.length) {
      collateralImages.removeAt(index);
    }
  }

  void removeExistingCollateralImage(int index) {
    if (index >= 0 && index < existingCollateralImageUrls.length) {
      removedImageUrls.add(existingCollateralImageUrls[index]);
      existingCollateralImageUrls.removeAt(index);
    }
  }

  // =====================
  // Upload new images to Supabase
  // =====================
  Future<List<String>> _uploadNewCollateralImages() async {
    if (collateralImages.isEmpty) return [];

    isUploadingCollateralImages.value = true;
    final List<String> uploadedUrls = [];

    try {
      final userId = await CacheUtils.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      const bucket = 'topics';
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < collateralImages.length; i++) {
        final file = collateralImages[i];
        final filePath = '$userId/loan_collateral/${timestamp}_$i';

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
        'Could not upload images: ${e.toString()}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return [];
    } finally {
      isUploadingCollateralImages.value = false;
    }
  }

  // =====================
  // Validation helper for UI
  // =====================
  List<String> getMissingFields() {
    final missing = <String>[];

    if (loanAmountController.text.isEmpty) missing.add('Loan Amount');
    if (selectedLoanCategory.value == null) missing.add('Loan Category');
    if (collateralDescController.text.isEmpty) {
      missing.add('Collateral Description');
    }
    if (assetValueController.text.isEmpty) missing.add('Declared Asset Value');
    if (!isDeclarationChecked.value) missing.add('Declaration Checkbox');

    final loanAmount = double.tryParse(loanAmountController.text);
    final assetValue = double.tryParse(assetValueController.text);
    if (loanAmount == null) missing.add('Valid Loan Amount (number)');
    if (assetValue == null) missing.add('Valid Asset Value (number)');
    if (loanAmount != null && loanAmount <= 0) missing.add('Loan Amount > 0');
    if (assetValue != null && assetValue <= 0) missing.add('Asset Value > 0');

    switch (selectedLoanCategoryType.value) {
      case 'motor_vehicle':
        if (vehicleMakeController.text.isEmpty) missing.add('Vehicle Make');
        if (vehicleModelController.text.isEmpty) missing.add('Vehicle Model');
        if (vehicleRegController.text.isEmpty) {
          missing.add('Registration Number');
        }
        if (vehicleCcSerialController.text.isEmpty) {
          missing.add('CC/Serial Number');
        }
        if (vehicleEngineController.text.isEmpty) missing.add('Engine Number');
        if (vehicleChassisController.text.isEmpty) missing.add('Chassis Number');
        if (vehicleYearController.text.isEmpty) missing.add('Vehicle Year');
        break;
      case 'small_loans':
        if (electronicTypeController.text.isEmpty) {
          missing.add('Electronic Type');
        }
        if (electronicModelController.text.isEmpty) {
          missing.add('Electronic Model');
        }
        if (electronicSerialController.text.isEmpty) {
          missing.add('Serial Number');
        }
        break;
      case 'jewellery':
        if (jewelTypeController.text.isEmpty) missing.add('Jewellery Type');
        if (jewelDescController.text.isEmpty) {
          missing.add('Jewellery Description');
        }
        if (jewelWeightController.text.isEmpty) missing.add('Weight');
        if (jewelPurityController.text.isEmpty) missing.add('Purity');
        if (jewelEstimatedValueController.text.isEmpty) {
          missing.add('Estimated Value');
        }
        break;
    }

    return missing;
  }

  // =====================
  // Submit update
  // =====================
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

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      List<String> newImageUrls = [];
      if (collateralImages.isNotEmpty) {
        newImageUrls = await _uploadNewCollateralImages();
        if (newImageUrls.isEmpty) {
          if (Get.isDialogOpen ?? false) Get.back();
          isSubmitting.value = false;
          return;
        }
      }

      final List<String> finalImageUrls = [
        ...existingCollateralImageUrls,
        ...newImageUrls,
      ];

      final loanAmount = double.parse(loanAmountController.text);
      final assetValue = double.parse(assetValueController.text);

      final Map<String, dynamic> payload = {
        "requested_loan_amount": loanAmount,
        "loan_period_type": selectedLoanPeriodType.value,
        "collateral_category": selectedLoanCategoryType.value,
        "collateral_description": collateralDescController.text,
        "surety_description": suretyDescController.text.isNotEmpty
            ? suretyDescController.text
            : null,
        "declared_asset_value": assetValue,
        "collateral_images": finalImageUrls,
        "declaration_text": _getDeclarationText(),
        "declaration_signed_at": DateTime.now().toIso8601String(),
        "declaration_signature_name":
            originalApplication?.customerUser?.firstName ?? 'Customer',
        "custom_terms_and_conditions": _getCustomTerms(),
      };

      switch (selectedLoanCategoryType.value) {
        case 'motor_vehicle':
          payload["motor_vehicle_details"] = {
            "make": vehicleMakeController.text,
            "model": vehicleModelController.text,
            "registration_no": vehicleRegController.text,
            "cc_serial_no": vehicleCcSerialController.text,
            "engine_no": vehicleEngineController.text,
            "chassis_no": vehicleChassisController.text,
            "year": int.tryParse(vehicleYearController.text),
          };
          break;
        case 'small_loans':
          payload["small_loan_details"] = {
            "type": electronicTypeController.text,
            "model": electronicModelController.text,
            "serial_no": electronicSerialController.text,
          };
          break;
        case 'jewellery':
          payload["jewellery_details"] = {
            "type": jewelTypeController.text,
            "description": jewelDescController.text,
            "weight": double.tryParse(jewelWeightController.text),
            "purity": jewelPurityController.text,
            "estimated_value": double.tryParse(
              jewelEstimatedValueController.text,
            ),
          };
          break;
      }

      final response = await LoanApplicationService.updateLoanApplication(
        loanApplicationId: loanApplicationId!,
        payload: payload,
      );

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
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // =====================
  // Private helpers
  // =====================
  String _getDeclarationText() {
    String item = '';
    switch (selectedLoanCategoryType.value) {
      case 'small_loans':
        item =
            '${electronicTypeController.text} ${electronicModelController.text}';
        break;
      case 'motor_vehicle':
        item = '${vehicleMakeController.text} ${vehicleModelController.text}';
        break;
      case 'jewellery':
        item = jewelTypeController.text;
        break;
    }
    return 'I confirm that the $item offered as collateral is fully owned by '
        'me with no outstanding loans or disputes.';
  }

  String _getCustomTerms() {
    final periodLabel =
        selectedLoanPeriodType.value == 'two_weeks' ? '2 weeks' : '1 month';
    return 'Standard loan terms apply. Late payment penalty of 10% of '
        'outstanding amount. Full repayment due within $periodLabel.';
  }

  // =====================
  // Cleanup
  // =====================
  @override
  void onClose() {
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
