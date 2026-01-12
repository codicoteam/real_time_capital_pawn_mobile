import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_password_textfield.dart';
import 'package:real_time_pawn/widgets/dialogs/error_dialog.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import '../../terms_and_private_policy_mgmnt/privacy_policy_screen.dart';
import '../../terms_and_private_policy_mgmnt/terms_and_private_screen.dart';
import '../helpers/auth_mngmt_helper.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _acceptTerms = false;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Must be 18+
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textColor,
            ),
            dialogBackgroundColor: AppColors.surfaceColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error
      await Future.delayed(const Duration(milliseconds: 50));
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    if (!_acceptTerms) {
      showErrorDialog('Please accept the terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthHelper.validateRegisterForm(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        nationalIdNumber: nationalIdController.text.trim().isNotEmpty
            ? nationalIdController.text.trim()
            : null,
        dateOfBirth: dateOfBirthController.text.trim().isNotEmpty
            ? dateOfBirthController.text.trim()
            : null,
        address: addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        acceptTerms: _acceptTerms,
      );

      if (success) {
        // Success - navigation will be handled in AuthHelper
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.04),

                // Welcome Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),

                    const SizedBox(height: 8),

                    Text(
                          'Complete your profile to get started',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.subtextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideX(begin: -0.3),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),

                // Personal Information Section
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 12),

                // Register Form Container
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // First Name Field
                          CustomTextField(
                                controller: firstNameController,
                                labelText: 'First Name',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Last Name Field
                          CustomTextField(
                                controller: lastNameController,
                                labelText: 'Last Name',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 500.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Email Field
                          CustomTextField(
                                controller: emailController,
                                labelText: 'Email Address',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                keyboardType: TextInputType.emailAddress,
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 600.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Phone Field
                          CustomTextField(
                                controller: phoneController,
                                labelText: 'Phone Number (Optional)',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                keyboardType: TextInputType.phone,
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 700.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 24),

                          // KYC Information Section
                          Text(
                            'KYC Information (Optional)',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

                          const SizedBox(height: 12),

                          // National ID Field
                          CustomTextField(
                                controller: nationalIdController,
                                labelText: 'National ID',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 900.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Date of Birth Field
                          GestureDetector(
                            onTap: _selectDate,
                            child:
                                AbsorbPointer(
                                      child: CustomTextField(
                                        controller: dateOfBirthController,
                                        labelText: 'Date of Birth',
                                        focusedBorderColor:
                                            AppColors.primaryColor,
                                        prefixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                          color: AppColors.subtextColor,
                                        ),
                                        // suffixIcon: Icon(
                                        //   Icons.calendar_month_outlined,
                                        //   color: AppColors.subtextColor,
                                        // ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 1000.ms)
                                    .slideY(begin: 0.3),
                          ),

                          const SizedBox(height: 16),

                          // Address Field
                          CustomTextField(
                                controller: addressController,
                                labelText: 'Address',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.subtextColor,
                                ),
                                // maxLines: 2,
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1100.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Location Field
                          CustomTextField(
                                controller: locationController,
                                labelText: 'Location/City',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.place_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1200.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 24),

                          // Password Section
                          Text(
                            'Security Information',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 1300.ms),

                          const SizedBox(height: 12),

                          // Password Field
                          CustomPasswordTextfield(
                                controller: passwordController,
                                obscureText: true,
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1400.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          // Confirm Password Field
                          CustomPasswordTextfield(
                                controller: confirmPasswordController,
                                obscureText: true,
                                labelText: 'Confirm Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1500.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 24),

                          // Terms and Conditions Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Wrap(
                                  children: [
                                    Text(
                                      'I agree to the ',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.subtextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => const TermsOfServiceScreen(),
                                        );
                                      },
                                      child: Text(
                                        'Terms of Service',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.subtextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => const PrivacyPolicyScreen(),
                                        );
                                      },
                                      child: Text(
                                        'Privacy Policy',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Register Button
                          Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _isLoading ? null : _submitForm,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'Create Account',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1700.ms)
                              .scale(begin: const Offset(0.95, 0.95)),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 300.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 24),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 1800.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(errorMessage: errorMessage),
    );
  }
}
