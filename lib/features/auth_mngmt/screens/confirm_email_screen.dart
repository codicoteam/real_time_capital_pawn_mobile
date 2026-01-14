import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:real_time_pawn/features/auth_mngmt/helpers/auth_mngmt_helper.dart' show AuthHelper;
import '../../../core/utils/pallete.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Timer for resend functionality (optional)
  int _resendTimer = 30;
  bool _canResend = true;
  
  @override
  void initState() {
    super.initState();
    // Start timer for resend if you want to implement cooldown
    // _startResendTimer();
  }
  
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final success = await AuthHelper.validateAndVerifyEmail(
        email: widget.email,
        otp: _otpController.text,
      );
      
      if (!success && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resendVerification() async {
    setState(() => _isResending = true);
    
    final success = await AuthHelper.validateAndResendVerification(
      email: widget.email,
    );
    
    if (mounted) {
      setState(() => _isResending = false);
      
      // If you want to implement a cooldown timer
      if (success) {
        _startResendTimer();
      }
    }
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 30;
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _resendTimer--);
      }
    }).then((_) {
      if (_resendTimer > 0) {
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.04),

                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Your Email',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),

                      const SizedBox(height: 8),

                      Text(
                        'Enter the 6-digit code sent to your email address',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.subtextColor,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 200.ms)
                          .slideX(begin: -0.3),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Email Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification email sent to:',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.email,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                  SizedBox(height: screenHeight * 0.05),

                  // OTP Input Section
                  Column(
                    children: [
                      // OTP Label
                      Text(
                        'Enter 6-digit OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                      const SizedBox(height: 16),

                      // OTP Input Field
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        backgroundColor: Colors.transparent,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: 60,
                          fieldWidth: 50,
                          activeFillColor: AppColors.surfaceColor,
                          selectedFillColor: AppColors.surfaceColor,
                          inactiveFillColor: AppColors.surfaceColor,
                          activeColor: AppColors.primaryColor,
                          selectedColor: AppColors.primaryColor,
                          inactiveColor: AppColors.borderColor,
                          borderWidth: 2,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        onCompleted: (value) {
                          // Auto-submit when OTP is complete
                          _verifyEmail();
                        },
                        onChanged: (value) {},
                        validator: (value) {
                          if (value == null || value.length != 6) {
                            return 'Please enter a valid 6-digit OTP';
                          }
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                            return 'OTP must contain only numbers';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                      const SizedBox(height: 8),

                      // Validation text
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter the 6-digit code sent to your email',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Verify Email',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),

                  SizedBox(height: screenHeight * 0.03),

                  // Resend Section
                  Column(
                    children: [
                      // Resend Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _canResend && !_isResending ? _resendVerification : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _canResend ? AppColors.primaryColor : AppColors.borderColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      size: 20,
                                      color: _canResend ? AppColors.primaryColor : AppColors.subtextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Resend Verification Code',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _canResend ? AppColors.primaryColor : AppColors.subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                      const SizedBox(height: 12),

                      // Resend timer or instruction
                      if (!_canResend)
                        Text(
                          'Resend available in $_resendTimer seconds',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ).animate().fadeIn(duration: 300.ms)
                      else
                        Text(
                          "Didn't receive the code? Check your spam folder",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Help Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Need Help?',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. Check your spam or junk folder\n'
                          '2. Ensure you entered the correct email\n'
                          '3. Wait a few minutes and try again\n'
                          '4. Contact support if the issue persists',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).slideY(begin: 0.3),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}