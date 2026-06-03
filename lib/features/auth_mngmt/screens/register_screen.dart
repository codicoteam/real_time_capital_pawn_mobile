import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_password_textfield.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import '../../terms_and_private_policy_mgmnt/privacy_policy_screen.dart';
import '../../terms_and_private_policy_mgmnt/terms_and_private_screen.dart';
import '../controllers/signup_controller.dart';
import '../helpers/register_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final SignupController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(SignupController());
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    Get.delete<SignupController>();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            _buildNavBar(),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          // Title row
          Obx(() => Row(
            children: [
              if (_c.currentStep.value > 0)
                GestureDetector(
                  onTap: () => _c.prevStep(_pageCtrl),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textColor),
                  ),
                ),
              if (_c.currentStep.value > 0) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SignupController.stepMeta[_c.currentStep.value]['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      SignupController.stepMeta[_c.currentStep.value]['desc'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_c.currentStep.value + 1} / ${SignupController.totalSteps}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )),

          const SizedBox(height: 16),

          // Step indicator
          Obx(() => _StepIndicator(
            currentStep: _c.currentStep.value,
            totalSteps: SignupController.totalSteps,
            onStepTap: (step) => _c.jumpToStep(step, _pageCtrl),
          )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Nav Bar ───────────────────────────────────────────────────────────────

  Widget _buildNavBar() {
    return Obx(() {
      final isLast = _c.currentStep.value == SignupController.totalSteps - 1;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          border: Border(top: BorderSide(color: AppColors.borderColor, width: 0.5)),
        ),
        child: Row(
          children: [
            // Back button
            if (_c.currentStep.value > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _c.prevStep(_pageCtrl),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),

            if (_c.currentStep.value > 0) const SizedBox(width: 12),

            // Next / Submit button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _c.isLoading.value
                    ? null
                    : () {
                        if (isLast) {
                          _c.submitForm();
                        } else {
                          _c.nextStep(_pageCtrl);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _c.isLoading.value
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isLast ? 'Create Account' : 'Continue',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Step 1: Personal Info ─────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _card(
            Column(
              children: [
                _field(_c.firstNameCtrl, 'First Name', Icons.person_outline,
                    validator: (v) => (v?.trim().length ?? 0) < 2 ? 'At least 2 characters' : null),
                _gap(),
                _field(_c.lastNameCtrl, 'Last Name', Icons.person_outline,
                    validator: (v) => (v?.trim().length ?? 0) < 2 ? 'At least 2 characters' : null),
                _gap(),
                _field(_c.emailCtrl, 'Email Address', Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) => RegisterHelper.getEmailError(v ?? '')),
                _gap(),
                _field(_c.phoneCtrl, 'Phone Number *', Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Phone is required';
                      return RegisterHelper.getPhoneError(v);
                    }),
                _gap(),
                _field(_c.altPhoneCtrl, 'Alternative Phone (Optional)', Icons.phone_android_outlined,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) return RegisterHelper.getPhoneError(v);
                      return null;
                    }),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Date of Birth'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _c.pickDateOfBirth,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _c.dobCtrl,
                      labelText: 'Date of Birth (18+ years) *',
                      focusedBorderColor: AppColors.primaryColor,
                      prefixIcon: Icon(Icons.cake_outlined, color: AppColors.subtextColor),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        try {
                          final dob = DateTime.parse(v);
                          final now = DateTime.now();
                          int age = now.year - dob.year;
                          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
                          if (age < 18) return 'Must be 18 or older';
                        } catch (_) { return 'Invalid date'; }
                        return null;
                      },
                      autoValidate: true,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('About You'),
                const SizedBox(height: 12),
                Obx(() => _dropdown<String>(
                  value: _c.selectedGender.value,
                  hint: 'Gender *',
                  icon: Icons.wc_outlined,
                  items: SignupController.genderOptions,
                  onChanged: _c.setGender,
                )),
                _gap(),
                Obx(() => _dropdown<String>(
                  value: _c.selectedMaritalStatus.value,
                  hint: 'Marital Status (Optional)',
                  icon: Icons.favorite_outline,
                  items: SignupController.maritalStatusOptions,
                  onChanged: _c.setMaritalStatus,
                )),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 160.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),
          _signInLink(),
        ],
      ),
    );
  }

  // ── Step 2: Security ──────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Create Password'),
                const SizedBox(height: 4),
                Text(
                  'Use at least 8 characters with uppercase, lowercase, and a number.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                ),
                const SizedBox(height: 16),
                CustomPasswordTextfield(
                  controller: _c.passwordCtrl,
                  obscureText: true,
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.subtextColor),
                  validator: (v) => RegisterHelper.getPasswordError(v ?? ''),
                  autoValidate: true,
                ),
                const SizedBox(height: 12),
                // Password strength bar
                Obx(() => _PasswordStrengthBar(strength: _c.passwordStrength.value)),
                const SizedBox(height: 16),
                CustomPasswordTextfield(
                  controller: _c.confirmPasswordCtrl,
                  obscureText: true,
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.subtextColor),
                  validator: (v) => RegisterHelper.getConfirmPasswordError(
                    _c.passwordCtrl.text, v ?? '',
                  ),
                  autoValidate: true,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Password requirements',
                        style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PasswordRequirement(label: 'At least 8 characters', controller: _c.passwordCtrl, check: (p) => p.length >= 8),
                _PasswordRequirement(label: 'One uppercase letter (A–Z)', controller: _c.passwordCtrl, check: RegisterHelper.hasUppercase),
                _PasswordRequirement(label: 'One lowercase letter (a–z)', controller: _c.passwordCtrl, check: RegisterHelper.hasLowercase),
                _PasswordRequirement(label: 'One number (0–9)', controller: _c.passwordCtrl, check: RegisterHelper.hasNumber),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms).slideY(begin: 0.06),
        ],
      ),
    );
  }

  // ── Step 3: Identity & Address ────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Obx(() => Column(
        children: [
          // ID Type toggle
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Identification Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _idTypeOption('national_id', 'National ID', Icons.badge_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _idTypeOption('passport', 'Passport', Icons.airplane_ticket_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_c.identificationType.value == 'national_id')
                  _field(_c.nationalIdCtrl, 'National ID Number *', Icons.badge_outlined,
                      validator: (v) => RegisterHelper.getNationalIdError(v ?? ''))
                else ...[
                  _field(_c.passportNumberCtrl, 'Passport Number *', Icons.airplane_ticket_outlined,
                      validator: (v) {
                        if (v == null || v.trim().length < 6) return 'Enter a valid passport number';
                        return null;
                      }),
                  _gap(),
                  GestureDetector(
                    onTap: _c.pickPassportExpiry,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        controller: _c.passportExpiryCtrl,
                        labelText: 'Passport Expiry Date *',
                        focusedBorderColor: AppColors.primaryColor,
                        prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.subtextColor),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Expiry date is required';
                          try {
                            if (DateTime.parse(v).isBefore(DateTime.now())) return 'Passport has expired';
                          } catch (_) { return 'Invalid date'; }
                          return null;
                        },
                        autoValidate: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          // Address
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Address in Zimbabwe'),
                const SizedBox(height: 4),
                Text(
                  'Country is fixed to Zimbabwe',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                ),
                const SizedBox(height: 12),
                // Country (fixed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.public_outlined, color: AppColors.subtextColor, size: 20),
                      const SizedBox(width: 12),
                      Text('Country: Zimbabwe', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor)),
                      const Spacer(),
                      Icon(Icons.lock_outline, size: 14, color: AppColors.subtextColor),
                    ],
                  ),
                ),
                _gap(),
                // Province dropdown
                _dropdown<String>(
                  value: _c.selectedProvince.value,
                  hint: 'Province / State *',
                  icon: Icons.map_outlined,
                  items: SignupController.zimbabweCities.keys.toList(),
                  onChanged: _c.setProvince,
                ),
                _gap(),
                // City dropdown
                _dropdown<String>(
                  value: _c.selectedCity.value,
                  hint: 'City *',
                  icon: Icons.location_city_outlined,
                  items: _c.selectedProvince.value != null
                      ? SignupController.zimbabweCities[_c.selectedProvince.value!] ?? []
                      : [],
                  onChanged: _c.setCity,
                  enabled: _c.selectedProvince.value != null,
                ),
                _gap(),
                _field(_c.homeAddressCtrl, 'Home Address (Street / House No.) *', Icons.home_outlined,
                    validator: (v) {
                      if (v == null || v.trim().length < 5) return 'Please enter a valid home address';
                      return null;
                    }),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms).slideY(begin: 0.06),
        ],
      )),
    );
  }

  // ── Step 4: Next of Kin & Employment ─────────────────────────────────────

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Next of Kin *'),
                const SizedBox(height: 4),
                Text(
                  'Required emergency contact information',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                ),
                const SizedBox(height: 14),
                _field(_c.nokNameCtrl, 'Full Name *', Icons.person_outline,
                    validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Name is required' : null),
                _gap(),
                Obx(() => _dropdown<String>(
                  value: _c.selectedNokRelationship.value,
                  hint: 'Relationship *',
                  icon: Icons.family_restroom_outlined,
                  items: SignupController.nokRelationshipOptions,
                  onChanged: _c.setNokRelationship,
                )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 13, color: AppColors.subtextColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Next of kin should share the same surname as you',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextColor),
                      ),
                    ),
                  ],
                ),
                _gap(),
                _field(_c.nokPhoneCtrl, 'Phone Number (Optional)', Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) return RegisterHelper.getPhoneError(v);
                      return null;
                    }),
                _gap(),
                _field(_c.nokEmailCtrl, 'Email (Optional)', Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) return RegisterHelper.getEmailError(v);
                      return null;
                    }),
                _gap(),
                _field(_c.nokAddressCtrl, 'Address *', Icons.location_on_outlined,
                    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Address is required' : null),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          _card(
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Employment', style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor,
                          )),
                          Text(
                            _c.isEmployed.value ? 'Currently employed' : 'Not employed / tap to add',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _c.isEmployed.value,
                      onChanged: _c.setIsEmployed,
                      activeThumbColor: AppColors.primaryColor,
                      activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                if (_c.isEmployed.value) ...[
                  const Divider(height: 24),
                  _field(_c.employerNameCtrl, 'Employer Name *', Icons.business_outlined,
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null),
                  _gap(),
                  _field(_c.jobTitleCtrl, 'Job Title *', Icons.work_outline,
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null),
                  _gap(),
                  _field(_c.employmentDurationCtrl, 'Duration (e.g. 2 years) *', Icons.timelapse_outlined,
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null),
                  _gap(),
                  _field(_c.employmentLocationCtrl, 'Work Location (Optional)', Icons.location_city_outlined),
                  _gap(),
                  _field(_c.employmentContactsCtrl, 'Work Contacts (Optional)', Icons.contact_phone_outlined,
                      keyboard: TextInputType.phone,
                      validator: (v) {
                        if (v != null && v.isNotEmpty) return RegisterHelper.getPhoneError(v);
                        return null;
                      }),
                ],
              ],
            )),
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms).slideY(begin: 0.06),
        ],
      ),
    );
  }

  // ── Step 5: Documents & Terms ─────────────────────────────────────────────

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Obx(() => Column(
        children: [
          // Selfie with ID (required)
          _uploadCard(
            title: 'Selfie Holding Your ID *',
            subtitle: 'Take a clear photo of yourself holding your National ID or Passport next to your face',
            icon: Icons.face_outlined,
            isUploading: _c.isUploadingProfile.value,
            hasFile: _c.profilePicUrl.value != null,
            uploadedLabel: 'Verification photo uploaded',
            onTap: _c.uploadSelfieWithId,
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          // ID document front (required)
          _uploadCard(
            title: _c.identificationType.value == 'national_id'
                ? 'National ID — Front *'
                : 'Passport Image *',
            subtitle: _c.identificationType.value == 'national_id'
                ? 'Upload a clear image of the front of your National ID card'
                : 'Upload a clear image of your passport photo page',
            icon: _c.identificationType.value == 'national_id'
                ? Icons.badge_outlined
                : Icons.airplane_ticket_outlined,
            isUploading: _c.identificationType.value == 'national_id'
                ? _c.isUploadingNationalId.value
                : _c.isUploadingPassport.value,
            hasFile: _c.identificationType.value == 'national_id'
                ? _c.nationalIdImageUrl.value != null
                : _c.passportImageUrl.value != null,
            uploadedLabel: _c.identificationType.value == 'national_id'
                ? 'National ID front uploaded'
                : 'Passport uploaded',
            onTap: _c.identificationType.value == 'national_id'
                ? _c.uploadNationalId
                : _c.uploadPassport,
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms).slideY(begin: 0.06),

          // National ID back (only for national_id)
          if (_c.identificationType.value == 'national_id') ...[
            const SizedBox(height: 12),
            _uploadCard(
              title: 'National ID — Back *',
              subtitle: 'Upload a clear image of the back of your National ID card',
              icon: Icons.flip_outlined,
              isUploading: _c.isUploadingNationalIdBack.value,
              hasFile: _c.nationalIdBackImageUrl.value != null,
              uploadedLabel: 'National ID back uploaded',
              onTap: _c.uploadNationalIdBack,
            ).animate().fadeIn(duration: 500.ms, delay: 120.ms).slideY(begin: 0.06),
          ],

          const SizedBox(height: 12),

          // Proof of address (optional)
          _uploadCard(
            title: 'Proof of Residence (Optional)',
            subtitle: 'Upload a utility bill, bank statement, or official letter as proof of your address',
            icon: Icons.home_outlined,
            isUploading: _c.isUploadingProofOfAddress.value,
            hasFile: _c.proofOfAddressUrl.value != null,
            uploadedLabel: 'Proof of address uploaded',
            onTap: _c.uploadProofOfAddress,
          ).animate().fadeIn(duration: 500.ms, delay: 160.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),

          // Terms
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terms & Conditions', style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor,
                )),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24, height: 24,
                      child: Checkbox(
                        value: _c.acceptTerms.value,
                        onChanged: (v) => _c.toggleAcceptTerms(v ?? false),
                        activeColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Wrap(
                        children: [
                          Text('I agree to the ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor)),
                          GestureDetector(
                            onTap: () => Get.to(() => const TermsOfServiceScreen()),
                            child: Text('Terms of Service',
                                style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
                                )),
                          ),
                          Text(' and ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextColor)),
                          GestureDetector(
                            onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                            child: Text('Privacy Policy',
                                style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.save_outlined, size: 14, color: AppColors.subtextColor),
                    const SizedBox(width: 6),
                    Text(
                      'Your progress is automatically saved',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextColor),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 240.ms).slideY(begin: 0.06),

          const SizedBox(height: 12),
          _signInLink(),
        ],
      )),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _gap([double h = 14]) => SizedBox(height: h);

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor,
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      controller: ctrl,
      labelText: label,
      focusedBorderColor: AppColors.primaryColor,
      prefixIcon: Icon(icon, color: AppColors.subtextColor),
      keyboardType: keyboard,
      validator: validator,
      autoValidate: validator != null,
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: enabled ? AppColors.borderColor : AppColors.borderColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? null : AppColors.backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(hint, style: GoogleFonts.poppins(color: AppColors.subtextColor, fontSize: 14)),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: enabled ? AppColors.subtextColor : AppColors.subtextColor.withOpacity(0.4)),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        items: items.map((item) => DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString(), style: GoogleFonts.poppins(fontSize: 14)),
        )).toList(),
        onChanged: enabled ? onChanged : null,
        dropdownColor: AppColors.surfaceColor,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtextColor),
      ),
    );
  }

  Widget _idTypeOption(String value, String label, IconData icon) {
    return Obx(() {
      final selected = _c.identificationType.value == value;
      return GestureDetector(
        onTap: () => _c.setIdType(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor.withOpacity(0.08) : AppColors.backgroundColor,
            border: Border.all(
              color: selected ? AppColors.primaryColor : AppColors.borderColor,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.primaryColor : AppColors.subtextColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primaryColor : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _uploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploading,
    required bool hasFile,
    required String uploadedLabel,
    required VoidCallback onTap,
  }) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (hasFile ? AppColors.successColor : AppColors.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasFile ? Icons.check_circle_outline_rounded : icon,
                  color: hasFile ? AppColors.successColor : AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textColor,
                    )),
                    if (hasFile)
                      Text(uploadedLabel, style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.successColor,
                      ))
                    else
                      Text(subtitle, style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.subtextColor,
                      ), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isUploading ? null : onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(
                  color: hasFile ? AppColors.successColor : AppColors.primaryColor,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: isUploading
                  ? SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : Icon(
                      hasFile ? Icons.edit_outlined : Icons.cloud_upload_outlined,
                      size: 18,
                      color: hasFile ? AppColors.successColor : AppColors.primaryColor,
                    ),
              label: Text(
                isUploading ? 'Uploading...' : (hasFile ? 'Replace' : 'Upload'),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: hasFile ? AppColors.successColor : AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signInLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextColor)),
          GestureDetector(
            onTap: () => Get.offNamed(RoutesHelper.loginScreen),
            child: Text('Sign In', style: GoogleFonts.poppins(
              fontSize: 14, color: AppColors.primaryColor, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final void Function(int) onStepTap;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          // Connecting line
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: isCompleted ? AppColors.primaryColor : AppColors.borderColor,
            ),
          );
        } else {
          // Step circle
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isActive = stepIndex == currentStep;
          return GestureDetector(
            onTap: () => onStepTap(stepIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 34 : 28,
              height: isActive ? 34 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryColor
                    : isActive
                        ? AppColors.primaryColor
                        : AppColors.backgroundColor,
                border: Border.all(
                  color: (isActive || isCompleted) ? AppColors.primaryColor : AppColors.borderColor,
                  width: isActive ? 2.5 : 1.5,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppColors.subtextColor,
                        ),
                      ),
              ),
            ),
          );
        }
      }),
    );
  }
}

// ── Password Strength Bar ─────────────────────────────────────────────────────

class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0-5

  const _PasswordStrengthBar({required this.strength});

  Color get _color {
    if (strength <= 1) return Colors.red.shade400;
    if (strength == 2) return Colors.orange.shade400;
    if (strength == 3) return Colors.yellow.shade700;
    if (strength == 4) return Colors.lightGreen;
    return Colors.green;
  }

  String get _label {
    if (strength == 0) return '';
    if (strength <= 1) return 'Weak';
    if (strength == 2) return 'Fair';
    if (strength == 3) return 'Good';
    if (strength == 4) return 'Strong';
    return 'Very strong';
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < strength ? _color : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Password Requirement Row ──────────────────────────────────────────────────

class _PasswordRequirement extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool Function(String) check;

  const _PasswordRequirement({
    required this.label,
    required this.controller,
    required this.check,
  });

  @override
  State<_PasswordRequirement> createState() => _PasswordRequirementState();
}

class _PasswordRequirementState extends State<_PasswordRequirement> {
  bool _met = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  void _update() {
    final met = widget.check(widget.controller.text);
    if (met != _met) setState(() => _met = met);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16, height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _met ? Colors.green : Colors.grey.shade200,
            ),
            child: _met
                ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: _met ? Colors.green.shade700 : Colors.grey.shade500,
              fontWeight: _met ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
