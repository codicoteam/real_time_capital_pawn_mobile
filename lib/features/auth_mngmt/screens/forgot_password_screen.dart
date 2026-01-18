import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';

import '../../../config/routers/router.dart';
import '../helpers/auth_mngmt_helper.dart' show AuthHelper;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
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
          onPressed: () {
            Get.offNamed(RoutesHelper.loginScreen);
          },
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
                SizedBox(height: screenHeight * 0.08),

                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),

                    const SizedBox(height: 8),

                    Text(
                          'Enter your email and we\'ll send you a password reset link',
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

                SizedBox(height: screenHeight * 0.06),

                // Reset Password Form Container
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
                          // Email Field
                          CustomTextField(
                                controller: emailController,
                                labelText: 'Email Address',
                                focusedBorderColor: AppColors.primaryColor,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.subtextColor,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 32),

                          // Reset Password Button
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
                                    onTap: () async {
                                      await AuthHelper.validateAndSubmitForgotPassword(
                                        email: emailController.text,
                                      );
                                    },
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
                                                'Send Reset Link',
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
                              .fadeIn(duration: 600.ms, delay: 600.ms)
                              .scale(begin: const Offset(0.95, 0.95)),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 300.ms)
                    .scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 32),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Remember your password? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.subtextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.offNamed(RoutesHelper.loginScreen);
                      },
                      child: Text(
                        'Back to Login',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

                const SizedBox(height: 40),

                // Info Card
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
                            Icons.info_outline,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Check your email',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll send password reset instructions to your email address if an account exists.',
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
}
