import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/profile_mngmt/screens/profile_mngmt_screen.dart';
import 'package:real_time_pawn/widgets/custom_button.dart';
import 'package:real_time_pawn/widgets/profile_widgets/profile_autofill_banner.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import '../controllers/loan_application_controller.dart';

class LoanApplicationScreen extends GetView<LoanApplicationControllerTwo> {
  const LoanApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply for a Loan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Tell us about your collateral',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: RealTimeColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.33,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Info Card
                  Obx(() {
                    if (controller.userData.value != null) {
                      return _buildProfileInfoCard(controller.userData.value!)
                          .animate()
                          .fadeIn()
                          .slideY(begin: 0.1);
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 16),

                  // Loan Amount Card
                  _buildSectionCard(
                    title: 'Loan Amount',
                    icon: Icons.monetization_on_outlined,
                    children: [
                      CustomTextField(
                        controller: controller.loanAmountController,
                        labelText: 'Requested Loan Amount',
                        prefixIcon: const Icon(Icons.attach_money_outlined, size: 20),
                        keyboardType: TextInputType.number,
                        onChanged: (_) {},
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: 8),
                      Text(
                        'Minimum loan amount: \$50.00',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Collateral Category Card
                  _buildSectionCard(
                    title: 'Select Collateral Type',
                    icon: Icons.category_outlined,
                    children: [
                      Text(
                        'Choose the type of asset you\'re using as collateral',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: controller.loanCategories.length,
                        itemBuilder: (context, index) {
                          final category = controller.loanCategories[index];
                          return Obx(
                            () => _buildCategoryCard(
                              title: category['title'] as String,
                              icon: category['icon'] as IconData,
                              color: category['color'] as Color,
                              isSelected: controller.selectedLoanCategory.value == category['title'],
                              onTap: () {
                                controller.selectedLoanCategory.value = category['title'] as String?;
                                controller.selectedLoanCategoryType.value = category['type'] as String?;
                              },
                            ),
                          ).animate().fadeIn(delay: (200 + index * 100).ms);
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Category-specific Details Card
                  Obx(() {
                    if (controller.selectedLoanCategoryType.value != null) {
                      return _buildSectionCard(
                        title: 'Item Details',
                        icon: Icons.info_outline,
                        children: [_buildCategorySpecificFields()],
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 24),

                  // Collateral Description Card
                  _buildSectionCard(
                    title: 'Collateral Information',
                    icon: Icons.description_outlined,
                    children: [
                      CustomTextField(
                        controller: controller.collateralDescController,
                        labelText: 'Collateral Description',
                        prefixIcon: const Icon(Icons.description_outlined, size: 20),
                        maxLength: 300,
                        onChanged: (_) {},
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.assetValueController,
                        labelText: 'Declared Asset Value',
                        prefixIcon: const Icon(Icons.assessment_outlined, size: 20),
                        keyboardType: TextInputType.number,
                        onChanged: (_) {},
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.suretyDescController,
                        labelText: 'Surety Description (Optional)',
                        prefixIcon: const Icon(Icons.security_outlined, size: 20),
                        maxLength: 200,
                        onChanged: (_) {},
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Collateral Images Card
                  _buildSectionCard(
                    title: 'Collateral Photos',
                    icon: Icons.photo_camera_outlined,
                    children: [
                      Text(
                        'Upload clear photos of your collateral (max 6 images)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => _buildImageUploadGrid()),
                      const SizedBox(height: 8),
                      if (controller.collateralImages.isEmpty)
                        Center(
                          child: TextButton.icon(
                            onPressed: controller.pickCollateralImages,
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: Text(
                              'Add Photos',
                              style: GoogleFonts.poppins(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Repayment Options Card
                  _buildSectionCard(
                    title: 'Repayment Options',
                    icon: Icons.payment_outlined,
                    children: [
                      Text(
                        'Choose how you want to repay your loan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => _buildRepaymentTypeSelector()),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (controller.selectedRepaymentType.value == 'installment') {
                          return _buildInstallmentOptions().animate().fadeIn().slideY(begin: 0.1);
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Declaration Card
                  _buildSectionCard(
                    title: 'Declaration',
                    icon: Icons.verified_outlined,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => controller.isDeclarationChecked.toggle(),
                            child: Obx(
                              () => AnimatedContainer(
                                duration: 200.ms,
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  color: controller.isDeclarationChecked.value
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: controller.isDeclarationChecked.value
                                        ? AppColors.primaryColor
                                        : RealTimeColors.grey400,
                                    width: 2,
                                  ),
                                ),
                                child: controller.isDeclarationChecked.value
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'I declare that all information provided is true and accurate.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textColor,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'I confirm that the collateral is fully owned by me with no outstanding loans or disputes.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.subtextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Submit Button
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => CustomButton(
                btnColor: controller.isFormValid.value && !controller.isSubmitting.value
                    ? AppColors.primaryColor
                    : RealTimeColors.grey300,
                width: double.infinity,
                borderRadius: 12,
                onTap: () {
                  if (controller.isFormValid.value && !controller.isSubmitting.value) {
                    controller.submitApplication();
                  } else {
                    controller.validateForm(showSnackbar: true);
                  }
                },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Application',
                        style: GoogleFonts.poppins(
                          color: controller.isFormValid.value && !controller.isSubmitting.value
                              ? Colors.white
                              : RealTimeColors.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your application will be reviewed by our team',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor.withOpacity(0.1), AppColors.primaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Applying as: ${userData['fullName'] ?? 'Customer'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${userData['email'] ?? ''} | ${userData['phone'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.to(() => const ProfileScreen()),
            child: Text(
              'View Profile',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificFields() {
    if (controller.selectedLoanCategoryType.value == 'motor_vehicle') {
      return Column(
        children: [
          CustomTextField(
            controller: controller.vehicleMakeController,
            labelText: 'Make',
            prefixIcon: const Icon(Icons.directions_car, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleModelController,
            labelText: 'Model',
            prefixIcon: const Icon(Icons.model_training, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleRegController,
            labelText: 'Registration Number',
            prefixIcon: const Icon(Icons.confirmation_number, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleCcSerialController,
            labelText: 'CC/Serial Number',
            prefixIcon: const Icon(Icons.numbers, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleEngineController,
            labelText: 'Engine Number',
            prefixIcon: const Icon(Icons.engineering, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleChassisController,
            labelText: 'Chassis Number',
            prefixIcon: const Icon(Icons.format_quote, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleYearController,
            labelText: 'Year',
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            keyboardType: TextInputType.number,
            onChanged: (_) {},
          ),
        ],
      );
    } else if (controller.selectedLoanCategoryType.value == 'small_loans') {
      return Column(
        children: [
          CustomTextField(
            controller: controller.electronicTypeController,
            labelText: 'Device Type',
            prefixIcon: const Icon(Icons.devices, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.electronicModelController,
            labelText: 'Model',
            prefixIcon: const Icon(Icons.model_training, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.electronicSerialController,
            labelText: 'Serial Number',
            prefixIcon: const Icon(Icons.numbers, size: 20),
            onChanged: (_) {},
          ),
        ],
      );
    } else if (controller.selectedLoanCategoryType.value == 'jewellery') {
      return Column(
        children: [
          CustomTextField(
            controller: controller.jewelTypeController,
            labelText: 'Jewelry Type',
            prefixIcon: const Icon(Icons.diamond, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelDescController,
            labelText: 'Description',
            prefixIcon: const Icon(Icons.description, size: 20),
            maxLength: 200,
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelWeightController,
            labelText: 'Weight (grams)',
            prefixIcon: const Icon(Icons.monitor_weight, size: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelPurityController,
            labelText: 'Purity',
            prefixIcon: const Icon(Icons.percent, size: 20),
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelEstimatedValueController,
            labelText: 'Estimated Value',
            prefixIcon: const Icon(Icons.attach_money, size: 20),
            keyboardType: TextInputType.number,
            onChanged: (_) {},
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageUploadGrid() {
    if (controller.collateralImages.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor, ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.subtextColor),
              const SizedBox(height: 8),
              Text(
                'Tap "Add Photos" to upload images',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextColor),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: controller.collateralImages.length,
      itemBuilder: (context, index) {
        final image = controller.collateralImages[index];
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => controller.removeCollateralImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRepaymentTypeSelector() {
    return Row(
      children: controller.repaymentTypeOptions.map((option) {
        final isSelected = controller.selectedRepaymentType.value == option['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.selectedRepaymentType.value = option['value'] as String,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    option['icon'] as IconData,
                    color: isSelected ? Colors.white : AppColors.textColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstallmentOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Installments',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (controller.installmentCount.value > 1) {
                              controller.installmentCount.value--;
                            }
                          },
                          icon: const Icon(Icons.remove, size: 20),
                        ),
                        Expanded(
                          child: Obx(
                            () => Text(
                              '${controller.installmentCount.value}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (controller.installmentCount.value < 48) {
                              controller.installmentCount.value++;
                            }
                          },
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Frequency',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.selectedInstallmentFrequency.value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: controller.installmentFrequencyOptions.map((option) {
                        return DropdownMenuItem(
                          value: option['value'] as String,
                          child: Text(
                            option['title'] as String,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedInstallmentFrequency.value = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => Text(
                    'You will make ${controller.installmentCount.value} ${controller.selectedInstallmentFrequency.value} payments',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}