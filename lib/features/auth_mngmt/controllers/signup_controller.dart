import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import '../helpers/register_helper.dart';

class SignupController extends GetxController {
  // ── Step ──────────────────────────────────────────────────────────────────
  final currentStep = 0.obs;
  static const int totalSteps = 5;

  // ── Step 1 — Personal Info ────────────────────────────────────────────────
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final altPhoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  final selectedGender = RxnString();
  final selectedMaritalStatus = RxnString();

  // ── Step 2 — Security ────────────────────────────────────────────────────
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final passwordStrength = 0.obs; // 0-5

  // ── Step 3 — Identity & Address ──────────────────────────────────────────
  final identificationType = 'national_id'.obs;
  final nationalIdCtrl = TextEditingController();
  final passportNumberCtrl = TextEditingController();
  final passportExpiryCtrl = TextEditingController();
  final homeAddressCtrl = TextEditingController();
  final selectedProvince = RxnString();
  final selectedCity = RxnString();

  // ── Step 4 — Next of Kin & Employment ────────────────────────────────────
  final nokNameCtrl = TextEditingController();
  final nokRelationshipCtrl = TextEditingController();
  final selectedNokRelationship = RxnString();
  final nokPhoneCtrl = TextEditingController();
  final nokEmailCtrl = TextEditingController();
  final nokAddressCtrl = TextEditingController();
  final isEmployed = false.obs;
  final employerNameCtrl = TextEditingController();
  final jobTitleCtrl = TextEditingController();
  final employmentDurationCtrl = TextEditingController();
  final employmentLocationCtrl = TextEditingController();
  final employmentContactsCtrl = TextEditingController();

  // ── Step 5 — Documents & Terms ───────────────────────────────────────────
  final nationalIdImageUrl = RxnString();
  final nationalIdBackImageUrl = RxnString();
  final isUploadingNationalIdBack = false.obs;
  final passportImageUrl = RxnString();
  final profilePicUrl = RxnString();
  final proofOfAddressUrl = RxnString();
  final isUploadingNationalId = false.obs;
  final isUploadingPassport = false.obs;
  final isUploadingProfile = false.obs;
  final isUploadingProofOfAddress = false.obs;
  final acceptTerms = false.obs;
  final uploadedDocuments = <Map<String, dynamic>>[].obs;

  // ── Loading ───────────────────────────────────────────────────────────────
  final isLoading = false.obs;

  // ── Internal ──────────────────────────────────────────────────────────────
  final _supabase = Supabase.instance.client;
  SharedPreferences? _prefs;

  // ── Zimbabwe Data ─────────────────────────────────────────────────────────
  static const Map<String, List<String>> zimbabweCities = {
    'Harare': ['Avondale', 'Borrowdale', 'Chitungwiza', 'Epworth', 'Glen View', 'Harare CBD', 'Highfield', 'Kuwadzana', 'Mbare', 'Norton', 'Ruwa', 'Warren Park'],
    'Bulawayo': ['Bulawayo CBD', 'Emakhandeni', 'Luveve', 'Magwegwe', 'Mpopoma', 'Nketa', 'Pumula'],
    'Manicaland': ['Chimanimani', 'Chipinge', 'Mutare', 'Nyanga', 'Rusape'],
    'Mashonaland Central': ['Bindura', 'Centenary', 'Guruve', 'Mount Darwin', 'Mvurwi', 'Shamva'],
    'Mashonaland East': ['Hwedza', 'Marondera', 'Murehwa', 'Murewa', 'Uzumba'],
    'Mashonaland West': ['Chegutu', 'Chinhoyi', 'Kadoma', 'Kariba', 'Karoi'],
    'Masvingo': ['Bikita', 'Chiredzi', 'Gutu', 'Masvingo', 'Triangle', 'Zaka'],
    'Matabeleland North': ['Binga', 'Hwange', 'Lupane', 'Nkayi', 'Tsholotsho', 'Victoria Falls'],
    'Matabeleland South': ['Beitbridge', 'Esigodini', 'Filabusi', 'Gwanda', 'Kezi', 'Plumtree'],
    'Midlands': ['Gokwe', 'Gweru', 'Kwekwe', 'Lalapanzi', 'Mvuma', 'Shurugwi', 'Zvishavane'],
  };

  static const List<String> genderOptions = ['Male', 'Female'];

  static const List<String> maritalStatusOptions = [
    'Single', 'Married', 'Divorced', 'Widowed', 'Separated', 'Prefer not to say',
  ];

  static const List<String> nokRelationshipOptions = [
    'Spouse', 'Parent', 'Child', 'Sibling', 'Relative', 'Guardian', 'Other',
  ];

  // ── Step metadata ─────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> stepMeta = [
    {'title': 'Personal Info', 'desc': 'Tell us about yourself', 'icon': Icons.person_outline},
    {'title': 'Security', 'desc': 'Create a secure password', 'icon': Icons.lock_outline},
    {'title': 'Identity & Address', 'desc': 'Verify your identity', 'icon': Icons.badge_outlined},
    {'title': 'Next of Kin & Work', 'desc': 'Emergency contacts & employment', 'icon': Icons.people_outline},
    {'title': 'Documents & Terms', 'desc': 'Upload required documents', 'icon': Icons.upload_file_outlined},
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    passwordCtrl.addListener(() {
      passwordStrength.value = RegisterHelper.getPasswordStrength(passwordCtrl.text);
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromCache();
    _setupSaveListeners();
  }

  void _loadFromCache() {
    final p = _prefs!;

    firstNameCtrl.text = p.getString('su_firstName') ?? '';
    lastNameCtrl.text = p.getString('su_lastName') ?? '';
    emailCtrl.text = p.getString('su_email') ?? '';
    phoneCtrl.text = p.getString('su_phone') ?? '';
    altPhoneCtrl.text = p.getString('su_altPhone') ?? '';
    dobCtrl.text = p.getString('su_dob') ?? '';

    selectedGender.value = p.getString('su_gender');
    selectedMaritalStatus.value = p.getString('su_maritalStatus');

    identificationType.value = p.getString('su_idType') ?? 'national_id';
    nationalIdCtrl.text = p.getString('su_nationalId') ?? '';
    passportNumberCtrl.text = p.getString('su_passportNumber') ?? '';
    passportExpiryCtrl.text = p.getString('su_passportExpiry') ?? '';
    homeAddressCtrl.text = p.getString('su_homeAddress') ?? '';
    selectedProvince.value = p.getString('su_province');
    selectedCity.value = p.getString('su_city');

    nokNameCtrl.text = p.getString('su_nokName') ?? '';
    nokRelationshipCtrl.text = p.getString('su_nokRelationship') ?? '';
    final cachedRelationship = p.getString('su_nokRelationship');
    selectedNokRelationship.value = (cachedRelationship?.isNotEmpty ?? false) ? cachedRelationship : null;
    nokPhoneCtrl.text = p.getString('su_nokPhone') ?? '';
    nokEmailCtrl.text = p.getString('su_nokEmail') ?? '';
    nokAddressCtrl.text = p.getString('su_nokAddress') ?? '';
    isEmployed.value = p.getBool('su_isEmployed') ?? false;
    employerNameCtrl.text = p.getString('su_employerName') ?? '';
    jobTitleCtrl.text = p.getString('su_jobTitle') ?? '';
    employmentDurationCtrl.text = p.getString('su_employmentDuration') ?? '';
    employmentLocationCtrl.text = p.getString('su_employmentLocation') ?? '';
    employmentContactsCtrl.text = p.getString('su_employmentContacts') ?? '';

    nationalIdImageUrl.value = p.getString('su_nationalIdUrl');
    nationalIdBackImageUrl.value = p.getString('su_nationalIdBackUrl');
    passportImageUrl.value = p.getString('su_passportUrl');
    profilePicUrl.value = p.getString('su_profilePicUrl');
    proofOfAddressUrl.value = p.getString('su_proofOfAddressUrl');
  }

  void _setupSaveListeners() {
    void cache(String key, TextEditingController c) {
      c.addListener(() => _prefs?.setString(key, c.text));
    }
    cache('su_firstName', firstNameCtrl);
    cache('su_lastName', lastNameCtrl);
    cache('su_email', emailCtrl);
    cache('su_phone', phoneCtrl);
    cache('su_altPhone', altPhoneCtrl);
    cache('su_dob', dobCtrl);
    cache('su_nationalId', nationalIdCtrl);
    cache('su_passportNumber', passportNumberCtrl);
    cache('su_passportExpiry', passportExpiryCtrl);
    cache('su_homeAddress', homeAddressCtrl);
    cache('su_nokName', nokNameCtrl);
    cache('su_nokRelationship', nokRelationshipCtrl);
    cache('su_nokPhone', nokPhoneCtrl);
    cache('su_nokEmail', nokEmailCtrl);
    cache('su_nokAddress', nokAddressCtrl);
    cache('su_employerName', employerNameCtrl);
    cache('su_jobTitle', jobTitleCtrl);
    cache('su_employmentDuration', employmentDurationCtrl);
    cache('su_employmentLocation', employmentLocationCtrl);
    cache('su_employmentContacts', employmentContactsCtrl);
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  void setGender(String? v) {
    selectedGender.value = v;
    _prefs?.setString('su_gender', v ?? '');
  }

  void setMaritalStatus(String? v) {
    selectedMaritalStatus.value = v;
    _prefs?.setString('su_maritalStatus', v ?? '');
  }

  void setIdType(String v) {
    identificationType.value = v;
    _prefs?.setString('su_idType', v);
  }

  void setProvince(String? v) {
    selectedProvince.value = v;
    selectedCity.value = null;
    _prefs?.setString('su_province', v ?? '');
    _prefs?.remove('su_city');
  }

  void setCity(String? v) {
    selectedCity.value = v;
    _prefs?.setString('su_city', v ?? '');
  }

  void setIsEmployed(bool v) {
    isEmployed.value = v;
    _prefs?.setBool('su_isEmployed', v);
  }

  void setNokRelationship(String? v) {
    selectedNokRelationship.value = v;
    nokRelationshipCtrl.text = v ?? '';
    _prefs?.setString('su_nokRelationship', v ?? '');
  }

  void toggleAcceptTerms(bool v) {
    acceptTerms.value = v;
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void nextStep(PageController pc) {
    if (!_validateStep(currentStep.value)) return;
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pc.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void prevStep(PageController pc) {
    if (currentStep.value > 0) {
      currentStep.value--;
      pc.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void jumpToStep(int step, PageController pc) {
    if (step < currentStep.value) {
      currentStep.value = step;
      pc.animateToPage(
        step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateStep(int step) {
    switch (step) {
      case 0: return _validateStep1();
      case 1: return _validateStep2();
      case 2: return _validateStep3();
      case 3: return _validateStep4();
      case 4: return _validateStep5();
      default: return true;
    }
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title, msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade700,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
    );
  }

  bool _validateStep1() {
    if (firstNameCtrl.text.trim().length < 2) { _snack('Name', 'First name must be at least 2 characters'); return false; }
    if (lastNameCtrl.text.trim().length < 2) { _snack('Name', 'Last name must be at least 2 characters'); return false; }
    final emailErr = RegisterHelper.getEmailError(emailCtrl.text);
    if (emailErr != null) { _snack('Email', emailErr); return false; }
    if (phoneCtrl.text.isEmpty) { _snack('Phone', 'Phone number is required'); return false; }
    final phoneErr = RegisterHelper.getPhoneError(phoneCtrl.text);
    if (phoneErr != null) { _snack('Phone', phoneErr); return false; }
    if (dobCtrl.text.isEmpty) { _snack('Date of Birth', 'Date of birth is required'); return false; }
    try {
      final dob = DateTime.parse(dobCtrl.text);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      if (age < 18) { _snack('Age', 'You must be at least 18 years old to register'); return false; }
    } catch (_) {
      _snack('Date of Birth', 'Invalid date of birth'); return false;
    }
    if (selectedGender.value == null) { _snack('Gender', 'Please select your gender'); return false; }
    return true;
  }

  bool _validateStep2() {
    final passErr = RegisterHelper.getPasswordError(passwordCtrl.text);
    if (passErr != null) { _snack('Password', passErr); return false; }
    final confirmErr = RegisterHelper.getConfirmPasswordError(passwordCtrl.text, confirmPasswordCtrl.text);
    if (confirmErr != null) { _snack('Confirm Password', confirmErr); return false; }
    return true;
  }

  bool _validateStep3() {
    if (identificationType.value == 'national_id') {
      final idErr = RegisterHelper.getNationalIdError(nationalIdCtrl.text);
      if (idErr != null) { _snack('National ID', idErr); return false; }
    } else {
      if (passportNumberCtrl.text.trim().length < 6) { _snack('Passport', 'Enter a valid passport number'); return false; }
      if (passportExpiryCtrl.text.isEmpty) { _snack('Passport', 'Passport expiry date is required'); return false; }
      try {
        final expiry = DateTime.parse(passportExpiryCtrl.text);
        if (expiry.isBefore(DateTime.now())) { _snack('Passport', 'Passport has expired'); return false; }
      } catch (_) {
        _snack('Passport', 'Invalid expiry date'); return false;
      }
    }
    if (homeAddressCtrl.text.trim().length < 5) { _snack('Address', 'Please enter your home address'); return false; }
    if (selectedProvince.value == null) { _snack('Location', 'Please select your province'); return false; }
    if (selectedCity.value == null) { _snack('Location', 'Please select your city'); return false; }
    return true;
  }

  bool _validateStep4() {
    if (nokNameCtrl.text.trim().length < 2) { _snack('Next of Kin', 'Next of kin full name is required'); return false; }
    if (selectedNokRelationship.value == null) { _snack('Next of Kin', 'Relationship is required'); return false; }
    if (nokAddressCtrl.text.trim().isEmpty) { _snack('Next of Kin', 'Next of kin address is required'); return false; }
    if (isEmployed.value) {
      if (employerNameCtrl.text.trim().isEmpty) { _snack('Employment', 'Employer name is required'); return false; }
      if (jobTitleCtrl.text.trim().isEmpty) { _snack('Employment', 'Job title is required'); return false; }
      if (employmentDurationCtrl.text.trim().isEmpty) { _snack('Employment', 'Employment duration is required'); return false; }
    }
    return true;
  }

  bool _validateStep5() {
    if (profilePicUrl.value == null) { _snack('Documents', 'Please upload your selfie holding your ID'); return false; }
    if (identificationType.value == 'national_id') {
      if (nationalIdImageUrl.value == null) { _snack('Documents', 'Please upload the front of your National ID'); return false; }
      if (nationalIdBackImageUrl.value == null) { _snack('Documents', 'Please upload the back of your National ID'); return false; }
    }
    if (identificationType.value == 'passport' && passportImageUrl.value == null) {
      _snack('Documents', 'Please upload your passport image'); return false;
    }
    if (!acceptTerms.value) { _snack('Terms', 'Please accept the terms and conditions'); return false; }
    return true;
  }

  // ── Date Pickers ──────────────────────────────────────────────────────────

  Future<void> pickDateOfBirth() async {
    final maxDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: maxDate,
      firstDate: DateTime(1920),
      lastDate: maxDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            surface: AppColors.surfaceColor,
            onSurface: AppColors.textColor,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.surfaceColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> pickPassportExpiry() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            surface: AppColors.surfaceColor,
            onSurface: AppColors.textColor,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.surfaceColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      passportExpiryCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // ── Image Picker ──────────────────────────────────────────────────────────

  Future<ImageSource?> _showSourceSheet() async {
    ImageSource? source;
    await showModalBottomSheet(
      context: Get.context!,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
              title: Text('Choose from Gallery', style: TextStyle(color: AppColors.textColor)),
              onTap: () { source = ImageSource.gallery; Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.primaryColor),
              title: Text('Take a Photo', style: TextStyle(color: AppColors.textColor)),
              onTap: () { source = ImageSource.camera; Navigator.pop(ctx); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    return source;
  }

  Future<File?> _pickImage() async {
    final source = await _showSourceSheet();
    if (source == null) return null;
    final xf = await ImagePicker().pickImage(source: source, imageQuality: 80);
    return xf != null ? File(xf.path) : null;
  }

  // ── Supabase Upload ───────────────────────────────────────────────────────

  Future<String?> _uploadToSupabase(File file, String docType) async {
    try {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final ext = file.path.split('.').last;
      final filePath = 'users/$tempId/$docType/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.storage.from('topics').upload(
        filePath, file,
        fileOptions: FileOptions(
          upsert: false,
          contentType: ext == 'pdf' ? 'application/pdf' : 'image/jpeg',
        ),
      );
      return _supabase.storage.from('topics').getPublicUrl(filePath);
    } catch (e) {
      DevLogs.logError('Upload $docType error: $e');
      return null;
    }
  }

  void _uploadSuccess(String message) {
    Get.snackbar(
      'Uploaded', message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade700,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> uploadNationalId() async {
    final file = await _pickImage();
    if (file == null) return;
    isUploadingNationalId.value = true;
    final url = await _uploadToSupabase(file, 'national_id');
    isUploadingNationalId.value = false;
    if (url != null) {
      nationalIdImageUrl.value = url;
      _prefs?.setString('su_nationalIdUrl', url);
      uploadedDocuments.removeWhere((d) => d['type'] == 'national_id' && d['notes'] == 'National ID');
      uploadedDocuments.add({
        'type': 'national_id', 'url': url,
        'file_name': file.path.split('/').last, 'mime_type': 'image/jpeg',
        'notes': 'National ID',
      });
      _uploadSuccess('National ID uploaded');
    }
  }

  Future<void> uploadNationalIdBack() async {
    final file = await _pickImage();
    if (file == null) return;
    isUploadingNationalIdBack.value = true;
    final url = await _uploadToSupabase(file, 'national_id_back');
    isUploadingNationalIdBack.value = false;
    if (url != null) {
      nationalIdBackImageUrl.value = url;
      _prefs?.setString('su_nationalIdBackUrl', url);
      uploadedDocuments.removeWhere((d) => d['notes'] == 'National ID Back');
      uploadedDocuments.add({
        'type': 'national_id', 'url': url,
        'file_name': file.path.split('/').last, 'mime_type': 'image/jpeg',
        'notes': 'National ID Back',
      });
      _uploadSuccess('National ID back uploaded');
    }
  }

  Future<void> uploadPassport() async {
    final file = await _pickImage();
    if (file == null) return;
    isUploadingPassport.value = true;
    final url = await _uploadToSupabase(file, 'passport');
    isUploadingPassport.value = false;
    if (url != null) {
      passportImageUrl.value = url;
      _prefs?.setString('su_passportUrl', url);
      uploadedDocuments.removeWhere((d) => d['type'] == 'passport');
      uploadedDocuments.add({
        'type': 'passport', 'url': url,
        'file_name': file.path.split('/').last, 'mime_type': 'image/jpeg',
        'notes': 'Passport',
      });
      _uploadSuccess('Passport uploaded');
    }
  }

  Future<void> uploadSelfieWithId() async {
    final file = await _pickImage();
    if (file == null) return;
    isUploadingProfile.value = true;
    final url = await _uploadToSupabase(file, 'selfie_with_id');
    isUploadingProfile.value = false;
    if (url != null) {
      profilePicUrl.value = url;
      _prefs?.setString('su_profilePicUrl', url);
      uploadedDocuments.removeWhere((d) => d['notes'] == 'Selfie with ID');
      uploadedDocuments.add({
        'type': 'national_id', 'url': url,
        'file_name': file.path.split('/').last, 'mime_type': 'image/jpeg',
        'notes': 'Selfie with ID',
      });
      _uploadSuccess('Verification photo uploaded');
    }
  }

  Future<void> uploadProofOfAddress() async {
    final file = await _pickImage();
    if (file == null) return;
    isUploadingProofOfAddress.value = true;
    final url = await _uploadToSupabase(file, 'proof_of_address');
    isUploadingProofOfAddress.value = false;
    if (url != null) {
      proofOfAddressUrl.value = url;
      _prefs?.setString('su_proofOfAddressUrl', url);
      uploadedDocuments.removeWhere((d) => d['type'] == 'proof_of_address');
      uploadedDocuments.add({
        'type': 'proof_of_address', 'url': url,
        'file_name': file.path.split('/').last, 'mime_type': 'image/jpeg',
        'notes': 'Proof of address',
      });
      _uploadSuccess('Document uploaded');
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> submitForm() async {
    if (!_validateStep5()) return;
    isLoading.value = true;
    try {
      DateTime? passportExpiry;
      if (passportExpiryCtrl.text.isNotEmpty) {
        passportExpiry = DateTime.tryParse(passportExpiryCtrl.text);
      }

      final fullAddress = '${homeAddressCtrl.text.trim()}, ${selectedCity.value}, ${selectedProvince.value}, Zimbabwe';

      final success = await RegisterHelper.validateRegisterForm(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        confirmPassword: confirmPasswordCtrl.text,
        phone: phoneCtrl.text.trim(),
        alternativePhone: altPhoneCtrl.text.trim().isNotEmpty ? altPhoneCtrl.text.trim() : null,
        identificationType: identificationType.value,
        nationalIdNumber: identificationType.value == 'national_id' ? nationalIdCtrl.text.trim() : null,
        passportNumber: identificationType.value == 'passport' ? passportNumberCtrl.text.trim() : null,
        passportExpiryDate: passportExpiry,
        nationalIdImageUrl: nationalIdImageUrl.value,
        passportImageUrl: passportImageUrl.value,
        profilePicUrl: profilePicUrl.value,
        proofOfAddressUrl: proofOfAddressUrl.value,
        dateOfBirth: dobCtrl.text.trim(),
        address: fullAddress,
        location: selectedCity.value,
        gender: selectedGender.value,
        maritalStatus: selectedMaritalStatus.value,
        isEmployed: isEmployed.value,
        employerName: isEmployed.value && employerNameCtrl.text.trim().isNotEmpty ? employerNameCtrl.text.trim() : null,
        jobTitle: isEmployed.value && jobTitleCtrl.text.trim().isNotEmpty ? jobTitleCtrl.text.trim() : null,
        employmentDuration: isEmployed.value && employmentDurationCtrl.text.trim().isNotEmpty ? employmentDurationCtrl.text.trim() : null,
        employmentLocation: isEmployed.value && employmentLocationCtrl.text.trim().isNotEmpty ? employmentLocationCtrl.text.trim() : null,
        employmentContacts: isEmployed.value && employmentContactsCtrl.text.trim().isNotEmpty ? employmentContactsCtrl.text.trim() : null,
        nextOfKinFullName: nokNameCtrl.text.trim().isNotEmpty ? nokNameCtrl.text.trim() : null,
        nextOfKinRelationship: nokRelationshipCtrl.text.trim().isNotEmpty ? nokRelationshipCtrl.text.trim() : null,
        nextOfKinPhone: nokPhoneCtrl.text.trim().isNotEmpty ? nokPhoneCtrl.text.trim() : null,
        nextOfKinEmail: nokEmailCtrl.text.trim().isNotEmpty ? nokEmailCtrl.text.trim() : null,
        nextOfKinAddress: nokAddressCtrl.text.trim().isNotEmpty ? nokAddressCtrl.text.trim() : null,
        documents: uploadedDocuments.isNotEmpty ? uploadedDocuments.toList() : null,
        acceptTerms: acceptTerms.value,
      );

      if (success) await _clearCache();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearCache() async {
    final keys = (_prefs?.getKeys() ?? {}).where((k) => k.startsWith('su_')).toList();
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    altPhoneCtrl.dispose();
    dobCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    nationalIdCtrl.dispose();
    passportNumberCtrl.dispose();
    passportExpiryCtrl.dispose();
    homeAddressCtrl.dispose();
    nokNameCtrl.dispose();
    nokRelationshipCtrl.dispose();
    nokPhoneCtrl.dispose();
    nokEmailCtrl.dispose();
    nokAddressCtrl.dispose();
    employerNameCtrl.dispose();
    jobTitleCtrl.dispose();
    employmentDurationCtrl.dispose();
    employmentLocationCtrl.dispose();
    employmentContactsCtrl.dispose();
    super.onClose();
  }
}
