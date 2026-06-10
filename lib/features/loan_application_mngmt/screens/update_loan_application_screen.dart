import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';
import 'package:real_time_pawn/widgets/custom_button.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import '../controllers/update_loan_application_controller.dart';
class UpdateLoanApplicationScreen extends StatelessWidget {
  final LoanApplicationModel application;
  const UpdateLoanApplicationScreen({super.key, required this.application});
  @override
  Widget build(BuildContext context) {
    // Initialize controller and load data
    final controller = Get.put(UpdateLoanApplicationController());
    controller.initWithModel(application);
    // Check if application is editable
    final bool isEditable = _isApplicationEditable(application.status);
    final String? statusMessage = _getStatusMessage(application.status);
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
              isEditable ? 'Edit Loan Application' : 'View Application',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isEditable ? 'Update your loan details' : 'Application details',
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
          // Progress indicator
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: RealTimeColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),

          // Status Banner (if not editable)
          if (!isEditable)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusBannerColor(application.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusBannerIcon(application.status),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusMessage ?? 'This application cannot be edited',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application Info Card (Read-only)
                  _buildInfoCard(
                    application,
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                  const SizedBox(height: 24),

                  // Loan Details Card (Editable)
                  _buildLoanDetailsCard(
                    controller,
                    isEditable,
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const SizedBox(height: 24),

                  // Collateral Details Card (Editable)
                  Obx(() {
                    if (controller.selectedLoanCategoryType.value != null) {
                      return _buildCollateralDetailsCard(
                        controller,
                        isEditable,
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 24),

                  // Repayment Options Card (Editable)
                  _buildRepaymentCard(
                    controller,
                    isEditable,
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                  const SizedBox(height: 24),

                  // Collateral Images Card (Editable)
                  _buildCollateralImagesCard(
                    controller,
                    isEditable,
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                  const SizedBox(height: 24),

                  // Declaration Card (Editable)
                  if (isEditable)
                    _buildDeclarationCard(
                      controller,
                    ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Update Button (only if editable)
      bottomSheet: isEditable
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                      btnColor:
                          controller.isFormValid.value &&
                              !controller.isSubmitting.value &&
                              !controller.isUploadingCollateralImages.value
                          ? AppColors.primaryColor
                          : RealTimeColors.grey300,
                      width: double.infinity,
                      borderRadius: 12,
                      onTap: () {
                        if (controller.isFormValid.value &&
                            !controller.isSubmitting.value &&
                            !controller.isUploadingCollateralImages.value) {
                          controller.submitUpdate();
                        } else if (controller
                            .isUploadingCollateralImages
                            .value) {
                          Get.snackbar(
                            'Please Wait',
                            'Uploading images, please wait...',
                            backgroundColor: AppColors.warningColor,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        } else {
                          final missing = controller.getMissingFields();
                          if (missing.isNotEmpty) {
                            Get.snackbar(
                              'Incomplete Form',
                              'Missing: ${missing.join(', ')}',
                              backgroundColor: AppColors.errorColor,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        }
                      },
                      child:
                          controller.isSubmitting.value ||
                              controller.isUploadingCollateralImages.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Update Application',
                              style: GoogleFonts.poppins(
                                color:
                                    controller.isFormValid.value &&
                                        !controller.isSubmitting.value
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
                    'Only loan-specific fields can be updated',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  bool _isApplicationEditable(String? status) {
    if (status == null) return true;
    final lowerStatus = status.toLowerCase();
    return lowerStatus != 'approved' &&
        lowerStatus != 'rejected' &&
        lowerStatus != 'cancelled';
  }

  String? _getStatusMessage(String? status) {
    if (status == null) return null;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'approved') {
      return 'This application has been approved and cannot be edited.';
    } else if (lowerStatus == 'rejected') {
      return 'This application has been rejected and cannot be edited.';
    } else if (lowerStatus == 'cancelled') {
      return 'This application has been cancelled and cannot be edited.';
    }
    return null;
  }

  Color _getStatusBannerColor(String? status) {
    if (status == null) return AppColors.warningColor;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'approved') return AppColors.successColor;
    if (lowerStatus == 'rejected') return AppColors.errorColor;
    if (lowerStatus == 'cancelled') return AppColors.warningColor;
    return AppColors.warningColor;
  }

  IconData _getStatusBannerIcon(String? status) {
    if (status == null) return Icons.info_outline;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'approved') return Icons.check_circle_outline;
    if (lowerStatus == 'rejected') return Icons.cancel_presentation;
    if (lowerStatus == 'cancelled') return Icons.block_outlined;
    return Icons.info_outline;
  }

  Widget _buildInfoCard(LoanApplicationModel application) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Application Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReadOnlyRow(
            'Application Number',
            application.applicationNo ?? 'N/A',
            Icons.confirmation_number_outlined,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyRow(
            'Status',
            _formatStatus(application.status),
            Icons.flag_outlined,
            statusColor: _getStatusColor(application.status),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyRow(
            'Submitted On',
            _formatDate(application.createdAt),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyRow(
            'Last Updated',
            _formatDate(application.updatedAt),
            Icons.update_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsCard(
    UpdateLoanApplicationController controller,
    bool isEditable,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loan Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: controller.loanAmountController,
            labelText: 'Requested Loan Amount',
            prefixIcon: const Icon(Icons.attach_money_outlined, size: 20),
            keyboardType: TextInputType.number,
            enabled: isEditable,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.assetValueController,
            labelText: 'Declared Asset Value',
            prefixIcon: const Icon(Icons.assessment_outlined, size: 20),
            keyboardType: TextInputType.number,
            enabled: isEditable,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.collateralDescController,
            labelText: 'Collateral Description',
            prefixIcon: const Icon(Icons.description_outlined, size: 20),
            maxLength: 300,
            enabled: isEditable,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.suretyDescController,
            labelText: 'Surety Description (Optional)',
            prefixIcon: const Icon(Icons.security_outlined, size: 20),
            maxLength: 200,
            enabled: isEditable,
          ),
        ],
      ),
    );
  }

  Widget _buildCollateralDetailsCard(
    UpdateLoanApplicationController controller,
    bool isEditable,
  ) {
    final categoryType = controller.selectedLoanCategoryType.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Collateral Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category Selection
          Text(
            'Collateral Category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.loanCategories.length,
            itemBuilder: (context, index) {
              final category = controller.loanCategories[index];
              return Obx(
                () => _buildCategoryCard(
                  title: category['title'] as String,
                  icon: category['icon'] as IconData,
                  color: category['color'] as Color,
                  isSelected:
                      controller.selectedLoanCategory.value ==
                      category['title'],
                  isEnabled: isEditable,
                  onTap: isEditable
                      ? () {
                          controller.selectedLoanCategory.value =
                              category['title'] as String?;
                          controller.selectedLoanCategoryType.value =
                              category['type'] as String?;
                        }
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Category-specific fields
          if (categoryType != null) ...[
            const Divider(height: 24),
            if (categoryType == 'motor_vehicle') ...[
              Text(
                'Motor Vehicle Details',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.vehicleMakeController,
                labelText: 'Make',
                prefixIcon: const Icon(Icons.directions_car, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.vehicleModelController,
                labelText: 'Model',
                prefixIcon: const Icon(Icons.model_training, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.vehicleRegController,
                labelText: 'Registration Number',
                prefixIcon: const Icon(Icons.confirmation_number, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.vehicleCcSerialController,
                labelText: 'CC/Serial Number',
                prefixIcon: const Icon(Icons.numbers, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.vehicleEngineController,
                labelText: 'Engine Number',
                prefixIcon: const Icon(Icons.engineering, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.vehicleChassisController,
                labelText: 'Chassis Number',
                prefixIcon: const Icon(Icons.format_quote, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.vehicleYearController,
                labelText: 'Year',
                prefixIcon: const Icon(Icons.calendar_today, size: 20),
                keyboardType: TextInputType.number,
                enabled: isEditable,
              ),
            ] else if (categoryType == 'small_loans') ...[
              Text(
                'Electronic Gadget Details',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.electronicTypeController,
                labelText: 'Type (e.g., Laptop, Phone)',
                prefixIcon: const Icon(Icons.devices, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.electronicModelController,
                labelText: 'Model',
                prefixIcon: const Icon(Icons.model_training, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.electronicSerialController,
                labelText: 'Serial Number',
                prefixIcon: const Icon(Icons.numbers, size: 20),
                enabled: isEditable,
              ),
            ] else if (categoryType == 'jewellery') ...[
              Text(
                'Jewellery Details',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.jewelTypeController,
                labelText: 'Type (e.g., Ring, Necklace)',
                prefixIcon: const Icon(Icons.diamond, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.jewelDescController,
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description, size: 20),
                maxLength: 200,
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.jewelWeightController,
                labelText: 'Weight (grams)',
                prefixIcon: const Icon(Icons.monitor_weight, size: 20),
                keyboardType: TextInputType.number,
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.jewelPurityController,
                labelText: 'Purity (e.g., 18k, 22k)',
                prefixIcon: const Icon(Icons.percent, size: 20),
                enabled: isEditable,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: controller.jewelEstimatedValueController,
                labelText: 'Estimated Value',
                prefixIcon: const Icon(Icons.attach_money, size: 20),
                keyboardType: TextInputType.number,
                enabled: isEditable,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRepaymentCard(
    UpdateLoanApplicationController controller,
    bool isEditable,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Repayment Plan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Loan Period Selector
          Text(
            'Loan Period',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All loans are once-off repayment. Period drives interest rates.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: controller.loanPeriodOptions.map((option) {
              final isSelected =
                  controller.selectedLoanPeriodType.value == option['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: isEditable
                      ? () => controller.selectedLoanPeriodType.value =
                            option['value'] as String
                      : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
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
                        const SizedBox(height: 6),
                        Text(
                          option['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCollateralImagesCard(
    UpdateLoanApplicationController controller,
    bool isEditable,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Collateral Photos',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              if (isEditable)
                Obx(
                  () => GestureDetector(
                    onTap: controller.isUploadingCollateralImages.value
                        ? null
                        : controller.pickCollateralImages,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (controller.isUploadingCollateralImages.value)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            controller.isUploadingCollateralImages.value
                                ? 'Uploading...'
                                : 'Add Photos',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Existing Images
          Obx(() {
            if (controller.existingCollateralImageUrls.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Photos (${controller.existingCollateralImageUrls.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.existingCollateralImageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  controller.existingCollateralImageUrls[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: RealTimeColors.grey200,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: RealTimeColors.grey200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      ),
                                ),
                                if (isEditable &&
                                    !controller
                                        .isUploadingCollateralImages
                                        .value)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (index <
                                            controller
                                                .existingCollateralImageUrls
                                                .length) {
                                          controller
                                              .removeExistingCollateralImage(
                                                index,
                                              );
                                          Get.snackbar(
                                            'Photo Removed',
                                            'Photo has been removed',
                                            backgroundColor:
                                                AppColors.successColor,
                                            colorText: Colors.white,
                                            duration: 1000.ms,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // New Images
          Obx(() {
            if (controller.collateralImages.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Photos (${controller.collateralImages.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.collateralImages.length,
                      itemBuilder: (context, index) {
                        final image = controller.collateralImages[index];
                        return Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(image.path), fit: BoxFit.cover),
                                if (isEditable &&
                                    !controller
                                        .isUploadingCollateralImages
                                        .value)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (index <
                                            controller
                                                .collateralImages
                                                .length) {
                                          controller.removeNewCollateralImage(
                                            index,
                                          );
                                          Get.snackbar(
                                            'Photo Removed',
                                            'Photo has been removed',
                                            backgroundColor:
                                                AppColors.successColor,
                                            colorText: Colors.white,
                                            duration: 1000.ms,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Empty State
          Obx(() {
            if (controller.existingCollateralImageUrls.isEmpty &&
                controller.collateralImages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 64,
                        color: AppColors.subtextColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isEditable
                            ? 'No photos yet. Tap "Add Photos" to upload.'
                            : 'No photos available',
                        style: GoogleFonts.poppins(
                          color: AppColors.subtextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isEditable &&
                          !controller.isUploadingCollateralImages.value) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: controller.pickCollateralImages,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add Photos',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildDeclarationCard(UpdateLoanApplicationController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Declaration',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RealTimeColors.grey100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.subtextColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor ?? AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isEnabled ? color : AppColors.subtextColor,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isEnabled ? AppColors.textColor : AppColors.subtextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Submitted';
    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Color _getStatusColor(String? status) {
    if (status == null) return AppColors.warningColor;
    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFFF57C00);
      case 'submitted':
        return const Color(0xFF1976D2);
      case 'approved':
        return const Color(0xFF388E3C);
      case 'rejected':
        return const Color(0xFFD32F2F);
      case 'cancelled':
        return const Color(0xFFC2185B);
      default:
        return AppColors.warningColor;
    }
  }
}
