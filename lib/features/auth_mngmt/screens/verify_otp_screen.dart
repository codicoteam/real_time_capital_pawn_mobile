import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auth_mngmt/helpers/auth_mngmt_helper.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String? phoneNumber;
  final VoidCallback? onVerificationSuccess;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.phoneNumber,
    this.onVerificationSuccess,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with TickerProviderStateMixin {
  final TextEditingController otpController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  late AnimationController _countdownController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
  }

  void _setupAnimations() {
    _countdownController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startCountdown() {
    _countdownController.forward();
    _updateCountdown();
  }

  void _updateCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  void _shakeOtpField() {
    HapticFeedback.mediumImpact();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    focusNode.dispose();
    _countdownController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 24,
        color: AppColors.textColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primaryColor.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

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
                      'Verify Code',
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
                                text: 'Enter the verification code sent to\n',
                              ),
                              TextSpan(
                                text: widget.phoneNumber ?? widget.email,
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

                SizedBox(height: screenHeight * 0.06),

                // Verification Form Container
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // OTP Input Field
                                Pinput(
                                      controller: otpController,
                                      focusNode: focusNode,
                                      length: 6,
                                      defaultPinTheme: defaultPinTheme,
                                      focusedPinTheme: focusedPinTheme,
                                      submittedPinTheme: submittedPinTheme,
                                      errorPinTheme: errorPinTheme,
                                      pinputAutovalidateMode:
                                          PinputAutovalidateMode.onSubmit,
                                      showCursor: true,
                                      cursor: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 2,
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      hapticFeedbackType:
                                          HapticFeedbackType.lightImpact,
                                      onCompleted: (pin) async {
                                        await AuthHelper.validateAndVerifyOtp(
                                          email: widget.email,
                                          otp: otpController.text,
                                        );
                                      },
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 400.ms)
                                    .scale(begin: const Offset(0.9, 0.9)),

                                const SizedBox(height: 32),

                                // Verify Button
                                Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: otpController.text.length == 6
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
                                          onTap:
                                              otpController.text.length == 6 &&
                                                  !_isLoading
                                              ? () async {
                                                  await AuthHelper.validateAndVerifyOtp(
                                                    email: widget.email,
                                                    otp: otpController.text,
                                                  );
                                                }
                                              : null,
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
                                                      'Verify Code',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms, delay: 600.ms)
                                    .scale(begin: const Offset(0.95, 0.95)),

                                const SizedBox(height: 24),

                                // Resend Code Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Didn't receive code? ",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.subtextColor,
                                      ),
                                    ),
                                    _resendCountdown > 0
                                        ? Text(
                                            'Resend in ${_resendCountdown}s',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: AppColors.subtextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: _isResending
                                                ? null
                                                : _resendCode,
                                            child: Text(
                                              _isResending
                                                  ? 'Sending...'
                                                  : 'Resend Code',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  ],
                                ).animate().fadeIn(
                                  duration: 600.ms,
                                  delay: 800.ms,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 300.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 40),

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
                            'Secure Verification',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This code expires in 10 minutes. Keep this code confidential and don\'t share it with anyone.',
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
                    .fadeIn(duration: 600.ms, delay: 1000.ms)
                    .slideY(begin: 0.3),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });
    await AuthHelper.validateAndVerifyOtp(
      email: widget.email,
      otp: otpController.text,
    );

    setState(() {
      _isResending = false;
    });
  }
}
