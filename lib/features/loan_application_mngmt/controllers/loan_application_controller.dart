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
import '../screens/Loan application upload screen.dart' show LoanApplicationUploadScreen;

class LoanApplicationControllerTwo extends GetxController {
  // Personal Information Controllers
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

  // Loan Information Controllers
  final loanAmountController = TextEditingController();
  final collateralDescController = TextEditingController();
  final suretyDescController = TextEditingController();
  final assetValueController = TextEditingController();

  // Next of Kin Controllers
  final nextOfKinNameController = TextEditingController();
  final nextOfKinRelationshipController = TextEditingController();
  final nextOfKinPhoneController = TextEditingController();
  final nextOfKinEmailController = TextEditingController();
  final nextOfKinAddressController = TextEditingController();

  // Motor Vehicle Details Controllers
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleRegController = TextEditingController();
  final vehicleCcSerialController = TextEditingController();
  final vehicleEngineController = TextEditingController();
  final vehicleChassisController = TextEditingController();
  final vehicleYearController = TextEditingController();

  // Electronics (Small Loans) Details Controllers
  final electronicTypeController = TextEditingController();
  final electronicModelController = TextEditingController();
  final electronicSerialController = TextEditingController();

  // Jewellery Details Controllers
  final jewelTypeController = TextEditingController();
  final jewelDescController = TextEditingController();
  final jewelWeightController = TextEditingController();
  final jewelPurityController = TextEditingController();
  final jewelEstimatedValueController = TextEditingController();

  // Reactive selected values
  final selectedGender = RxnString();
  final selectedMaritalStatus = RxnString();
  final selectedEmploymentType = RxnString();
  final selectedEmploymentDuration = RxnString();
  final selectedLoanCategory = RxnString();
  final selectedLoanCategoryType = RxnString(); // for API
  final isDeclarationChecked = false.obs;

  // Document files and URLs (reactive)
  final nationalIdFile = Rx<XFile?>(null);
  final nationalIdUrl = RxnString();
  final isUploadingNationalId = false.obs;

  final passportFile = Rx<XFile?>(null);
  final passportUrl = RxnString();
  final isUploadingPassport = false.obs;

  final proofOfResidentFile = Rx<XFile?>(null);
  final proofOfResidentUrl = RxnString();
  final isUploadingProofOfResident = false.obs;

  final proofOfEmploymentFile = Rx<XFile?>(null);
  final proofOfEmploymentUrl = RxnString();
  final isUploadingProofOfEmployment = false.obs;

  // UI state
  final isSubmitting = false.obs;
  final userData = Rx<Map<String, dynamic>?>(null);
  final showAutoFillBanner = false.obs;

  // Form validity (updated via listeners)
  final isFormValid = false.obs;

  // Category options
  final genderOptions = ['Male', 'Female', 'Other'];
  final maritalStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  final employmentTypeOptions = [
    'Full-time',
    'Part-time',
    'Self-employed',
    'Unemployed',
  ];
  final employmentDurationOptions = ['< 1 year', '1-3 years', '3-5 years', '5+ years'];

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
    _autoFillUserData();
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
      // category-specific controllers will be conditionally checked in _checkFormValidity
    ];

    for (var controller in textControllers) {
      controller.addListener(_checkFormValidity);
    }

    // Listen to selected values
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
      isFormValid.value = true; // fallback (should not happen)
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

  Future<void> _autoFillUserData() async {
    final data = await ProfileMngmtHelper.getUserDataForLoanApplication();
    if (data != null) {
      userData.value = data;
      fullNameController.text = data['fullName'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      dateOfBirthController.text = data['dateOfBirth'] ?? '';
      nationalIdController.text = data['nationalIdNumber'] ?? '';
      addressController.text = data['address'] ?? '';
      if (data['location'] != null && data['location']!.isNotEmpty) {
        workLocationController.text = data['location']!;
      }
      showAutoFillBanner.value = true;
      _showAutoFillFeedback(data);
    }
  }

  void _showAutoFillFeedback(Map<String, dynamic> data) {
    final hasBasicInfo = data['hasBasicInfo'] ?? false;
    final missingFields = data['missingFields'] as List<String>? ?? [];
    if (!hasBasicInfo) {
      Get.snackbar(
        'Auto-fill incomplete',
        'Complete your profile to enable auto-fill',
        backgroundColor: AppColors.warningColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: 300.ms,
      );
      return;
    }
    if (hasBasicInfo && missingFields.isNotEmpty) {
      Get.snackbar(
        'Basic info auto-filled',
        'Add ${missingFields.length} more field(s) to complete profile',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: 400.ms,
      );
    }
  }

  Future<String?> _uploadFileToSupabase(XFile file, String documentType) async {
    try {
      final userId = await CacheUtils.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      const bucket = 'loan-documents';
      final filePath =
          '$userId/$documentType/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      await Supabase.instance.client.storage
          .from('topics')
          .upload(filePath, File(file.path));

      final publicUrl =
          Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      DevLogs.logError('Upload failed for $documentType: $e');
      Get.snackbar(
        'Upload failed',
        'Failed to upload $documentType: ${e.toString()}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  Future<void> pickAndUploadDocument(String type) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    switch (type) {
      case 'national_id':
        isUploadingNationalId.value = true;
        nationalIdFile.value = pickedFile;
        break;
      case 'passport':
        isUploadingPassport.value = true;
        passportFile.value = pickedFile;
        break;
      case 'proof_of_resident':
        isUploadingProofOfResident.value = true;
        proofOfResidentFile.value = pickedFile;
        break;
      case 'proof_of_employment':
        isUploadingProofOfEmployment.value = true;
        proofOfEmploymentFile.value = pickedFile;
        break;
    }

    final url = await _uploadFileToSupabase(pickedFile, type);

    switch (type) {
      case 'national_id':
        isUploadingNationalId.value = false;
        if (url != null) nationalIdUrl.value = url;
        break;
      case 'passport':
        isUploadingPassport.value = false;
        if (url != null) passportUrl.value = url;
        break;
      case 'proof_of_resident':
        isUploadingProofOfResident.value = false;
        if (url != null) proofOfResidentUrl.value = url;
        break;
      case 'proof_of_employment':
        isUploadingProofOfEmployment.value = false;
        if (url != null) proofOfEmploymentUrl.value = url;
        break;
    }

    if (url != null) {
      Get.snackbar(
        'Success',
        '$type uploaded successfully',
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: 200.ms,
      );
    }
  }

  /// Validates the entire form and shows a snackbar with missing fields if invalid.
  /// Returns true if valid.
  bool validateForm({bool showSnackbar = true}) {
    List<String> missingFields = [];

    // Base fields
    if (fullNameController.text.isEmpty) missingFields.add('Full Name');
    if (nationalIdController.text.isEmpty) missingFields.add('National ID');
    if (selectedGender.value == null) missingFields.add('Gender');
    if (dateOfBirthController.text.isEmpty) missingFields.add('Date of Birth');
    if (selectedMaritalStatus.value == null) missingFields.add('Marital Status');
    if (phoneController.text.isEmpty) missingFields.add('Phone Number');
    if (emailController.text.isEmpty) missingFields.add('Email');
    if (addressController.text.isEmpty) missingFields.add('Address');
    if (selectedEmploymentType.value == null) missingFields.add('Employment Type');
    if (jobTitleController.text.isEmpty) missingFields.add('Job Title');
    if (selectedEmploymentDuration.value == null) missingFields.add('Employment Duration');
    if (workLocationController.text.isEmpty) missingFields.add('Work Location');
    if (loanAmountController.text.isEmpty) missingFields.add('Loan Amount');
    if (selectedLoanCategory.value == null) missingFields.add('Loan Category');
    if (collateralDescController.text.isEmpty) missingFields.add('Collateral Description');
    if (assetValueController.text.isEmpty) missingFields.add('Declared Asset Value');
    if (!isDeclarationChecked.value) missingFields.add('Declaration Checkbox');

    // Category-specific fields
    if (selectedLoanCategoryType.value == 'motor_vehicle') {
      if (vehicleMakeController.text.isEmpty) missingFields.add('Vehicle Make');
      if (vehicleModelController.text.isEmpty) missingFields.add('Vehicle Model');
      if (vehicleRegController.text.isEmpty) missingFields.add('Registration Number');
      if (vehicleCcSerialController.text.isEmpty) missingFields.add('CC/Serial Number');
      if (vehicleEngineController.text.isEmpty) missingFields.add('Engine Number');
      if (vehicleChassisController.text.isEmpty) missingFields.add('Chassis Number');
      if (vehicleYearController.text.isEmpty) missingFields.add('Vehicle Year');
    } else if (selectedLoanCategoryType.value == 'small_loans') {
      if (electronicTypeController.text.isEmpty) missingFields.add('Electronic Type');
      if (electronicModelController.text.isEmpty) missingFields.add('Electronic Model');
      if (electronicSerialController.text.isEmpty) missingFields.add('Serial Number');
    } else if (selectedLoanCategoryType.value == 'jewellery') {
      if (jewelTypeController.text.isEmpty) missingFields.add('Jewellery Type');
      if (jewelDescController.text.isEmpty) missingFields.add('Jewellery Description');
      if (jewelWeightController.text.isEmpty) missingFields.add('Weight');
      if (jewelPurityController.text.isEmpty) missingFields.add('Purity');
      if (jewelEstimatedValueController.text.isEmpty) missingFields.add('Estimated Value');
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

    // Parse date
    DateTime? parsedDate;
    try {
      final dateParts = dateOfBirthController.text.split('/');
      if (dateParts.length == 3) {
        parsedDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
      }
    } catch (e) {
      // ignore
    }

    // Build payload
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
      "declaration_text":
          "I declare that all information provided is true and accurate.",
      "declaration_signed_at": DateTime.now().toIso8601String(),
      "declaration_signature_name": fullNameController.text,
      "national_id_url": nationalIdUrl.value,
      "passport_url": passportUrl.value,
      "proof_of_resident_url": proofOfResidentUrl.value,
      "proof_of_employment_url": proofOfEmploymentUrl.value,
    };

    // Next of kin
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

    DevLogs.logError("Selected Loan Category Type: ${selectedLoanCategoryType.value}");

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