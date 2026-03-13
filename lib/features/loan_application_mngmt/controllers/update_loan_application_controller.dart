import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/services/loan_application_mngmt_service.dart'
    show LoanApplicationService;

import '../../../config/routers/router.dart';

class UpdateLoanApplicationController extends GetxController {
  // =====================
  // Text Controllers (same as create)
  // =====================
  final fullNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final phoneController = TextEditingController();
  final altPhoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final jobTitleController = TextEditingController();
  final workLocationController = TextEditingController();
  final employerContactController = TextEditingController();

  // Loan Information
  final loanAmountController = TextEditingController();
  final collateralDescController = TextEditingController();
  final suretyDescController = TextEditingController();
  final assetValueController = TextEditingController();

  // Next of Kin
  final nextOfKinNameController = TextEditingController();
  final nextOfKinRelationshipController = TextEditingController();
  final nextOfKinPhoneController = TextEditingController();
  final nextOfKinEmailController = TextEditingController();
  final nextOfKinAddressController = TextEditingController();

  // Motor Vehicle
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleRegController = TextEditingController();
  final vehicleCcSerialController = TextEditingController();
  final vehicleEngineController = TextEditingController();
  final vehicleChassisController = TextEditingController();
  final vehicleYearController = TextEditingController();

  // Electronics (Small Loans)
  final electronicTypeController = TextEditingController();
  final electronicModelController = TextEditingController();
  final electronicSerialController = TextEditingController();

  // Jewellery
  final jewelTypeController = TextEditingController();
  final jewelDescController = TextEditingController();
  final jewelWeightController = TextEditingController();
  final jewelPurityController = TextEditingController();
  final jewelEstimatedValueController = TextEditingController();

  // Reactive selections
  final selectedGender = RxnString();
  final selectedMaritalStatus = RxnString();
  final selectedEmploymentType = RxnString();
  final selectedEmploymentDuration = RxnString();
  final selectedLoanCategory = RxnString(); // display title
  final selectedLoanCategoryType = RxnString(); // API value
  final isDeclarationChecked = false.obs;

  // Document URLs (read‑only – they are not updated via this screen)
  // (We keep them only to display existing ones if needed, but they are not editable)
  final nationalIdUrl = RxnString();
  final passportUrl = RxnString();
  final proofOfResidentUrl = RxnString();
  final proofOfEmploymentUrl = RxnString();

  // UI state
  final isSubmitting = false.obs;
  final isFormValid = false.obs;

  // Original loan application ID (needed for update)
  String? loanApplicationId;

  // Options (same as create)
  final genderOptions = ['Male', 'Female', 'Other'];
  final maritalStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final employmentTypeOptions = [
    'Full-time',
    'Part-time',
    'Self-employed',
    'Unemployed',
  ];
  final employmentDurationOptions = [
    '< 1 year',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  final loanCategories = [
    {
      'title': 'Motor Vehicle',
      'type': 'motor_vehicle',
      'icon': Icons.directions_car,
      'color': RealTimeColors.primaryGreen,
      'description': 'Use your vehicle as collateral',
    },
    {
      'title': 'Electronics',
      'type': 'small_loans',
      'icon': Icons.devices,
      'color': RealTimeColors.primaryGreen,
      'description': 'Phones, laptops, gadgets',
    },
    {
      'title': 'Jewelry',
      'type': 'jewellery',
      'icon': Icons.diamond,
      'color': RealTimeColors.primaryGreen,
      'description': 'Gold, watches, precious items',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to all relevant controllers and Rx variables to update form validity
    final textControllers = [
      fullNameController,
      nationalIdController,
      dateOfBirthController,
      phoneController,
      emailController,
      addressController,
      jobTitleController,
      workLocationController,
      loanAmountController,
      collateralDescController,
      assetValueController,
    ];
    for (var ctrl in textControllers) {
      ctrl.addListener(_checkFormValidity);
    }

    ever(selectedGender, (_) => _checkFormValidity());
    ever(selectedMaritalStatus, (_) => _checkFormValidity());
    ever(selectedEmploymentType, (_) => _checkFormValidity());
    ever(selectedEmploymentDuration, (_) => _checkFormValidity());
    ever(selectedLoanCategoryType, (_) {
      _clearCategoryFields();
      _checkFormValidity();
    });
    ever(isDeclarationChecked, (_) => _checkFormValidity());
  }

  void _checkFormValidity() {
    // Base required fields
    bool baseValid =
        fullNameController.text.isNotEmpty &&
        nationalIdController.text.isNotEmpty &&
        selectedGender.value != null &&
        dateOfBirthController.text.isNotEmpty &&
        selectedMaritalStatus.value != null &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        selectedEmploymentType.value != null &&
        jobTitleController.text.isNotEmpty &&
        selectedEmploymentDuration.value != null &&
        workLocationController.text.isNotEmpty &&
        loanAmountController.text.isNotEmpty &&
        selectedLoanCategory.value != null &&
        collateralDescController.text.isNotEmpty &&
        assetValueController.text.isNotEmpty &&
        isDeclarationChecked.value;

    if (!baseValid) {
      isFormValid.value = false;
      return;
    }

    // Category-specific required fields
    if (selectedLoanCategoryType.value == 'motor_vehicle') {
      isFormValid.value =
          vehicleMakeController.text.isNotEmpty &&
          vehicleModelController.text.isNotEmpty &&
          vehicleRegController.text.isNotEmpty &&
          vehicleCcSerialController.text.isNotEmpty &&
          vehicleEngineController.text.isNotEmpty &&
          vehicleChassisController.text.isNotEmpty &&
          vehicleYearController.text.isNotEmpty;
    } else if (selectedLoanCategoryType.value == 'small_loans') {
      isFormValid.value =
          electronicTypeController.text.isNotEmpty &&
          electronicModelController.text.isNotEmpty &&
          electronicSerialController.text.isNotEmpty;
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      isFormValid.value =
          jewelTypeController.text.isNotEmpty &&
          jewelDescController.text.isNotEmpty &&
          jewelWeightController.text.isNotEmpty &&
          jewelPurityController.text.isNotEmpty &&
          jewelEstimatedValueController.text.isNotEmpty;
    } else {
      isFormValid.value = true; // fallback
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
    loanApplicationId = model.id;

    // Personal
    fullNameController.text = model.fullName ?? '';
    nationalIdController.text = model.nationalIdNumber ?? '';
    selectedGender.value = model.gender;
    if (model.dateOfBirth != null) {
      dateOfBirthController.text =
          "${model.dateOfBirth!.day}/${model.dateOfBirth!.month}/${model.dateOfBirth!.year}";
    }
    selectedMaritalStatus.value = model.maritalStatus;
    phoneController.text = model.contactDetails ?? '';
    altPhoneController.text = model.alternativeNumber ?? '';
    emailController.text = model.emailAddress ?? '';
    addressController.text = model.homeAddress ?? '';

    // Document URLs (read‑only)
    nationalIdUrl.value = model.nationalIdUrl;
    passportUrl.value = model.passportUrl;
    proofOfResidentUrl.value = model.proofOfResidentUrl;
    proofOfEmploymentUrl.value = model.proofOfEmploymentUrl;

    // Next of kin
    if (model.nextOfKin != null) {
      nextOfKinNameController.text = model.nextOfKin!.fullName ?? '';
      nextOfKinRelationshipController.text =
          model.nextOfKin!.relationship ?? '';
      nextOfKinPhoneController.text = model.nextOfKin!.phoneNumber ?? '';
      nextOfKinEmailController.text = model.nextOfKin!.email ?? '';
      nextOfKinAddressController.text = model.nextOfKin!.address ?? '';
    }

    // Employment
    if (model.employment != null) {
      selectedEmploymentType.value = model.employment!.employmentType;
      jobTitleController.text = model.employment!.title ?? '';
      selectedEmploymentDuration.value = model.employment!.duration;
      workLocationController.text = model.employment!.location ?? '';
      employerContactController.text = model.employment!.contacts ?? '';
    }

    // Loan details
    loanAmountController.text = model.requestedLoanAmount?.toString() ?? '';
    // Find category title from type
    final category = loanCategories.firstWhere(
      (c) => c['type'] == model.collateralCategory,
      orElse: () => loanCategories.first,
    );
    selectedLoanCategory.value = category['title'] as String;
    selectedLoanCategoryType.value = model.collateralCategory;
    collateralDescController.text = model.collateralDescription ?? '';
    suretyDescController.text = model.suretyDescription ?? '';
    assetValueController.text = model.declaredAssetValue?.toString() ?? '';

    // Category‑specific details
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

    // Declaration – assume it was already signed, so we pre‑check the box
    isDeclarationChecked.value = true;

    // Re‑validate after loading
    _checkFormValidity();
  }

  /// Validate form and return missing fields list (for UI feedback)
  List<String> getMissingFields() {
    List<String> missing = [];

    if (fullNameController.text.isEmpty) missing.add('Full Name');
    if (nationalIdController.text.isEmpty) missing.add('National ID');
    if (selectedGender.value == null) missing.add('Gender');
    if (dateOfBirthController.text.isEmpty) missing.add('Date of Birth');
    if (selectedMaritalStatus.value == null) missing.add('Marital Status');
    if (phoneController.text.isEmpty) missing.add('Phone Number');
    if (emailController.text.isEmpty) missing.add('Email');
    if (addressController.text.isEmpty) missing.add('Address');
    if (selectedEmploymentType.value == null) missing.add('Employment Type');
    if (jobTitleController.text.isEmpty) missing.add('Job Title');
    if (selectedEmploymentDuration.value == null)
      missing.add('Employment Duration');
    if (workLocationController.text.isEmpty) missing.add('Work Location');
    if (loanAmountController.text.isEmpty) missing.add('Loan Amount');
    if (selectedLoanCategory.value == null) missing.add('Loan Category');
    if (collateralDescController.text.isEmpty)
      missing.add('Collateral Description');
    if (assetValueController.text.isEmpty) missing.add('Declared Asset Value');
    if (!isDeclarationChecked.value) missing.add('Declaration Checkbox');

    // Category‑specific
    if (selectedLoanCategoryType.value == 'motor_vehicle') {
      if (vehicleMakeController.text.isEmpty) missing.add('Vehicle Make');
      if (vehicleModelController.text.isEmpty) missing.add('Vehicle Model');
      if (vehicleRegController.text.isEmpty) missing.add('Registration Number');
      if (vehicleCcSerialController.text.isEmpty)
        missing.add('CC/Serial Number');
      if (vehicleEngineController.text.isEmpty) missing.add('Engine Number');
      if (vehicleChassisController.text.isEmpty) missing.add('Chassis Number');
      if (vehicleYearController.text.isEmpty) missing.add('Vehicle Year');
    } else if (selectedLoanCategoryType.value == 'small_loans') {
      if (electronicTypeController.text.isEmpty) missing.add('Electronic Type');
      if (electronicModelController.text.isEmpty)
        missing.add('Electronic Model');
      if (electronicSerialController.text.isEmpty) missing.add('Serial Number');
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      if (jewelTypeController.text.isEmpty) missing.add('Jewellery Type');
      if (jewelDescController.text.isEmpty)
        missing.add('Jewellery Description');
      if (jewelWeightController.text.isEmpty) missing.add('Weight');
      if (jewelPurityController.text.isEmpty) missing.add('Purity');
      if (jewelEstimatedValueController.text.isEmpty)
        missing.add('Estimated Value');
    }

    return missing;
  }

  /// Submit the updated application
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

    // Parse date of birth
    DateTime? parsedDate;
    try {
      final parts = dateOfBirthController.text.split('/');
      if (parts.length == 3) {
        parsedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}

    // Build payload (same structure as create, but without status/debtor/id)
    Map<String, dynamic> payload = {
      "full_name": fullNameController.text,
      "national_id_number": nationalIdController.text,
      "gender": selectedGender.value,
      "date_of_birth": parsedDate?.toIso8601String(),
      "marital_status": selectedMaritalStatus.value,
      "contact_details": phoneController.text,
      "alternative_number": altPhoneController.text.isNotEmpty
          ? altPhoneController.text
          : null,
      "email_address": emailController.text,
      "home_address": addressController.text,
      "employment": {
        "employment_type": selectedEmploymentType.value,
        "title": jobTitleController.text,
        "duration": selectedEmploymentDuration.value,
        "location": workLocationController.text,
        "contacts": employerContactController.text.isNotEmpty
            ? employerContactController.text
            : null,
      },
      "requested_loan_amount": int.tryParse(loanAmountController.text),
      "collateral_category": selectedLoanCategoryType.value,
      "collateral_description": collateralDescController.text,
      "surety_description": suretyDescController.text.isNotEmpty
          ? suretyDescController.text
          : null,
      "declared_asset_value": int.tryParse(assetValueController.text),

      // Declaration – update signature name and timestamp
      "declaration_text":
          "I declare that all information provided is true and accurate.",
      "declaration_signed_at": DateTime.now().toIso8601String(),
      "declaration_signature_name": fullNameController.text,

      // Document URLs (keep existing ones; they are not editable here)
      "national_id_url": nationalIdUrl.value,
      "passport_url": passportUrl.value,
      "proof_of_resident_url": proofOfResidentUrl.value,
      "proof_of_employment_url": proofOfEmploymentUrl.value,
    };

    // Next of kin (only include if at least one field is filled)
    if (nextOfKinNameController.text.isNotEmpty ||
        nextOfKinRelationshipController.text.isNotEmpty ||
        nextOfKinPhoneController.text.isNotEmpty ||
        nextOfKinEmailController.text.isNotEmpty ||
        nextOfKinAddressController.text.isNotEmpty) {
      payload["next_of_kin"] = {
        "full_name": nextOfKinNameController.text,
        "relationship": nextOfKinRelationshipController.text,
        "phone_number": nextOfKinPhoneController.text,
        "email": nextOfKinEmailController.text.isNotEmpty
            ? nextOfKinEmailController.text
            : null,
        "address": nextOfKinAddressController.text,
      };
    } else {
      payload["next_of_kin"] = null; // explicitly clear if all empty
    }

    // Category details
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
        "estimated_value": int.tryParse(jewelEstimatedValueController.text),
      };
    }

    DevLogs.logInfo("Updating loan application $loanApplicationId");

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
        Get.offAndToNamed(RoutesHelper.main_home_page);
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

  @override
  void onClose() {
    // Dispose all controllers
    fullNameController.dispose();
    nationalIdController.dispose();
    dateOfBirthController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    jobTitleController.dispose();
    workLocationController.dispose();
    employerContactController.dispose();
    loanAmountController.dispose();
    collateralDescController.dispose();
    suretyDescController.dispose();
    assetValueController.dispose();
    nextOfKinNameController.dispose();
    nextOfKinRelationshipController.dispose();
    nextOfKinPhoneController.dispose();
    nextOfKinEmailController.dispose();
    nextOfKinAddressController.dispose();
    vehicleMakeController.dispose();
    vehicleModelController.dispose();
    vehicleRegController.dispose();
    vehicleCcSerialController.dispose();
    vehicleEngineController.dispose();
    vehicleChassisController.dispose();
    vehicleYearController.dispose();
    electronicTypeController.dispose();
    electronicModelController.dispose();
    electronicSerialController.dispose();
    jewelTypeController.dispose();
    jewelDescController.dispose();
    jewelWeightController.dispose();
    jewelPurityController.dispose();
    jewelEstimatedValueController.dispose();
    super.onClose();
  }
}
