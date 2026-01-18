import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auth_mngmt/helpers/auth_mngmt_helper.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  final VoidCallback? onPasswordResetSuccess;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
    this.onPasswordResetSuccess,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  final bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _setupListeners() {
    newPasswordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validatePasswordMatch);
  }

  void _validatePassword() {
    final password = newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    setState(() {
      _passwordsMatch =
          newPasswordController.text == confirmPasswordController.text &&
          confirmPasswordController.text.isNotEmpty;
    });
  }

  bool get _isFormValid {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar &&
        _passwordsMatch;
  }

  void _shakeForm() {
    HapticFeedback.mediumImpact();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.06),

                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Password',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),

                    const SizedBox(height: 8),

                    RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.subtextColor,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Create a strong password for\n',
                              ),
                              TextSpan(
                                text: widget.email,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideX(begin: -0.3),
                  ],
                ),

                SizedBox(height: screenHeight * 0.04),

                // Reset Password Form Container
                AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value * 10, 0),
                          child: Container(
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
                                // New Password Field
                                CustomTextField(
                                      controller: newPasswordController,
                                      focusNode: newPasswordFocus,
                                      labelText: 'New Password',
                                      obscureText: _obscureNewPassword,
                                      focusedBorderColor:
                                          AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: AppColors.subtextColor,
                                      ),
                                      suffixIconButton: IconButton(
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppColors.subtextColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                      ),
                                      onSubmitted: (_) {
                                        confirmPasswordFocus.requestFocus();
                                      },
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 400.ms)
                                    .slideY(begin: 0.3),

                                const SizedBox(height: 24),

                                // Confirm Password Field
                                CustomTextField(
                                      controller: confirmPasswordController,
                                      focusNode: confirmPasswordFocus,
                                      labelText: 'Confirm Password',
                                      obscureText: _obscureConfirmPassword,
                                      focusedBorderColor:
                                          _passwordsMatch &&
                                              confirmPasswordController
                                                  .text
                                                  .isNotEmpty
                                          ? Colors.green
                                          : AppColors.primaryColor,
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: AppColors.subtextColor,
                                      ),
                                      suffixIconButton: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (confirmPasswordController
                                              .text
                                              .isNotEmpty)
                                            Icon(
                                              _passwordsMatch
                                                  ? Icons.check_circle
                                                  : Icons.error,
                                              color: _passwordsMatch
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 20,
                                            ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              color: AppColors.subtextColor,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 500.ms)
                                    .slideY(begin: 0.3),

                                const SizedBox(height: 20),

                                // Password Match Indicator
                                if (confirmPasswordController.text.isNotEmpty)
                                  Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _passwordsMatch
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: _passwordsMatch
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.red.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _passwordsMatch
                                                  ? Icons.check_circle
                                                  : Icons.error,
                                              color: _passwordsMatch
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _passwordsMatch
                                                  ? 'Passwords match'
                                                  : 'Passwords don\'t match',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: _passwordsMatch
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(duration: 300.ms)
                                      .scale(begin: const Offset(0.95, 0.95)),

                                const SizedBox(height: 24),

                                // Reset Password Button
                                Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: _isFormValid
                                            ? AppColors.primaryColor
                                            : AppColors.primaryColor
                                                  .withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.borderColor,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            spreadRadius: 0,
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () async {
                                            await AuthHelper.validateAndResetPassword(
                                              email: widget.email,
                                              otp: widget.otp,
                                              newPassword:
                                                  newPasswordController.text,
                                              confirmPassword:
                                                  confirmPasswordController
                                                      .text,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Reset Password',
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
                                    .fadeIn(duration: 600.ms, delay: 700.ms)
                                    .scale(begin: const Offset(0.95, 0.95)),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 300.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 24),

                // Password Requirements
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementItem(
                            'At least 8 characters',
                            _hasMinLength,
                          ),
                          _buildRequirementItem(
                            'One uppercase letter',
                            _hasUppercase,
                          ),
                          _buildRequirementItem(
                            'One lowercase letter',
                            _hasLowercase,
                          ),
                          _buildRequirementItem('One number', _hasNumber),
                          _buildRequirementItem(
                            'One special character',
                            _hasSpecialChar,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3),

                const SizedBox(height: 24),

                // Security Info Card
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.security_outlined,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Keep it secure',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose a strong, unique password that you don\'t use elsewhere. We recommend using a password manager.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.3),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : AppColors.subtextColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isMet ? Colors.green : AppColors.subtextColor,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
