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
              'Step 1: Complete Application',
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
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth * 0.5,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
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
                  // Auto-fill banner
                  Obx(() {
                    if (controller.userData.value != null &&
                        controller.userData.value!['hasBasicInfo'] == true) {
                      return ProfileAutofillBanner(
                        userData: controller.userData.value!,
                        onEditProfile: () {
                          Get.to(() => const ProfileScreen());
                        },
                      ).animate().fadeIn().slideY(begin: 0.1);
                    }
                    return const SizedBox.shrink();
                  }),

                  // Personal Information Card
                  _buildSectionCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        children: [
                          CustomTextField(
                            controller: controller.fullNameController,
                            labelText: 'Full Name',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.nationalIdController,
                            labelText: 'National ID Number',
                            prefixIcon: const Icon(
                              Icons.credit_card_outlined,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildSelectionRow(
                            label: 'Gender',
                            options: controller.genderOptions,
                            selectedValue: controller.selectedGender,
                            onSelected: (value) =>
                                controller.selectedGender.value = value,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildDatePickerField(
                            controller: controller.dateOfBirthController,
                            label: 'Date of Birth',
                            icon: Icons.calendar_today_outlined,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildSelectionRow(
                            label: 'Marital Status',
                            options: controller.maritalStatusOptions,
                            selectedValue: controller.selectedMaritalStatus,
                            onSelected: (value) =>
                                controller.selectedMaritalStatus.value = value,
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.phoneController,
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.altPhoneController,
                            labelText: 'Alternative Phone (Optional)',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.emailController,
                            labelText: 'Email Address',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.addressController,
                            labelText: 'Home Address',
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                            ),
                            maxLength: 200,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Employment Information Card
                  _buildSectionCard(
                        title: 'Employment Information',
                        icon: Icons.work_outline,
                        children: [
                          _buildSelectionRow(
                            label: 'Employment Type',
                            options: controller.employmentTypeOptions,
                            selectedValue: controller.selectedEmploymentType,
                            onSelected: (value) =>
                                controller.selectedEmploymentType.value = value,
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.jobTitleController,
                            labelText: 'Job Title',
                            prefixIcon: const Icon(
                              Icons.work_outline,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildSelectionRow(
                            label: 'Employment Duration',
                            options: controller.employmentDurationOptions,
                            selectedValue:
                                controller.selectedEmploymentDuration,
                            onSelected: (value) =>
                                controller.selectedEmploymentDuration.value =
                                    value,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.workLocationController,
                            labelText: 'Work Location',
                            prefixIcon: const Icon(
                              Icons.business_outlined,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.employerContactController,
                            labelText: 'Employer Contact (Optional)',
                            prefixIcon: const Icon(
                              Icons.contact_phone_outlined,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Next of Kin Card
                  _buildSectionCard(
                        title: 'Next of Kin (Optional)',
                        icon: Icons.family_restroom,
                        children: [
                          CustomTextField(
                            controller: controller.nextOfKinNameController,
                            labelText: 'Full Name',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller:
                                controller.nextOfKinRelationshipController,
                            labelText: 'Relationship',
                            prefixIcon: const Icon(
                              Icons.people_outline,
                              size: 20,
                            ),
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.nextOfKinPhoneController,
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.nextOfKinEmailController,
                            labelText: 'Email (Optional)',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.nextOfKinAddressController,
                            labelText: 'Address',
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                            ),
                            maxLength: 200,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Loan Details Card
                  _buildSectionCard(
                        title: 'Loan Details',
                        icon: Icons.monetization_on_outlined,
                        children: [
                          CustomTextField(
                            controller: controller.loanAmountController,
                            labelText: 'Loan Amount',
                            prefixIcon: const Icon(
                              Icons.attach_money_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          Text(
                            'Select Loan Category',
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  description: category['description'] as String,
                                  isSelected:
                                      controller.selectedLoanCategory.value ==
                                      category['title'],
                                  onTap: () {
                                    controller.selectedLoanCategory.value =
                                        category['title'] as String?;
                                    controller.selectedLoanCategoryType.value =
                                        category['type'] as String?;
                                  },
                                ),
                              ).animate().fadeIn(delay: (200 + index * 100).ms);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category-specific fields (animated)
                          Obx(() {
                            if (controller.selectedLoanCategoryType.value !=
                                null) {
                              return _buildCategorySpecificFields()
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: 0.1, end: 0);
                            }
                            return const SizedBox.shrink();
                          }),

                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.collateralDescController,
                            labelText: 'Collateral Description',
                            prefixIcon: const Icon(
                              Icons.description_outlined,
                              size: 20,
                            ),
                            maxLength: 300,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.suretyDescController,
                            labelText: 'Surety Description (Optional)',
                            prefixIcon: const Icon(
                              Icons.security_outlined,
                              size: 20,
                            ),
                            maxLength: 200,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.assetValueController,
                            labelText: 'Declared Asset Value',
                            prefixIcon: const Icon(
                              Icons.assessment_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) {},
                          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 600.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Supporting Documents Card
                  _buildSectionCard(
                        title: 'KYC Documents (Optional)',
                        icon: Icons.attach_file_outlined,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Upload clear images of the following documents to speed up processing.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.subtextColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // National ID
                          Obx(
                            () => _buildDocumentUploadRow(
                              label: 'National ID',
                              icon: Icons.credit_card,
                              file: controller.nationalIdFile.value,
                              isUploading:
                                  controller.isUploadingNationalId.value,
                              uploadedUrl: controller.nationalIdUrl.value,
                              onUpload: () => controller.pickAndUploadDocument(
                                'national_id',
                              ),
                              onView: () {
                                if (controller.nationalIdUrl.value != null) {
                                  Get.snackbar(
                                    'Document URL',
                                    controller.nationalIdUrl.value!,
                                    duration: 3.ms,
                                  );
                                }
                              },
                            ),
                          ),

                          // Passport
                          Obx(
                            () => _buildDocumentUploadRow(
                              label: 'Passport',
                              icon: Icons.picture_as_pdf,
                              file: controller.passportFile.value,
                              isUploading: controller.isUploadingPassport.value,
                              uploadedUrl: controller.passportUrl.value,
                              onUpload: () =>
                                  controller.pickAndUploadDocument('passport'),
                              onView: () {
                                if (controller.passportUrl.value != null) {
                                  Get.snackbar(
                                    'Document URL',
                                    controller.passportUrl.value!,
                                    duration: 3000.ms,
                                  );
                                }
                              },
                            ),
                          ),

                          // Proof of Residence
                          Obx(
                            () => _buildDocumentUploadRow(
                              label: 'Proof of Residence',
                              icon: Icons.home,
                              file: controller.proofOfResidentFile.value,
                              isUploading:
                                  controller.isUploadingProofOfResident.value,
                              uploadedUrl: controller.proofOfResidentUrl.value,
                              onUpload: () => controller.pickAndUploadDocument(
                                'proof_of_resident',
                              ),
                              onView: () {
                                if (controller.proofOfResidentUrl.value !=
                                    null) {
                                  Get.snackbar(
                                    'Document URL',
                                    controller.proofOfResidentUrl.value!,
                                    duration: 3000.ms,
                                  );
                                }
                              },
                            ),
                          ),

                          // Proof of Employment
                          Obx(
                            () => _buildDocumentUploadRow(
                              label: 'Proof of Employment',
                              icon: Icons.work,
                              file: controller.proofOfEmploymentFile.value,
                              isUploading:
                                  controller.isUploadingProofOfEmployment.value,
                              uploadedUrl:
                                  controller.proofOfEmploymentUrl.value,
                              onUpload: () => controller.pickAndUploadDocument(
                                'proof_of_employment',
                              ),
                              onView: () {
                                if (controller.proofOfEmploymentUrl.value !=
                                    null) {
                                  Get.snackbar(
                                    'Document URL',
                                    controller.proofOfEmploymentUrl.value!,
                                    duration: 3000.ms,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

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
                                onTap: () =>
                                    controller.isDeclarationChecked.toggle(),
                                child: Obx(
                                  () => AnimatedContainer(
                                    duration: 200.ms,
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.isDeclarationChecked.value
                                          ? AppColors.primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color:
                                            controller
                                                .isDeclarationChecked
                                                .value
                                            ? AppColors.primaryColor
                                            : RealTimeColors.grey400,
                                        width: 2,
                                      ),
                                    ),
                                    child: controller.isDeclarationChecked.value
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
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
                                      'I agree to the terms and conditions and understand that false information may lead to rejection.',
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
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 900.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

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
                btnColor:
                    controller.isFormValid.value &&
                        !controller.isSubmitting.value
                    ? AppColors.primaryColor
                    : RealTimeColors.grey300,
                width: double.infinity,
                borderRadius: 12,
                onTap: () {
                  if (controller.isFormValid.value &&
                      !controller.isSubmitting.value) {
                    controller.submitApplication();
                    
                  } else {
                    // Show validation errors via the validateForm method
                    controller.validateForm(showSnackbar: true);
                  }
                },
                child: controller.isSubmitting.value
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
                        'Continue to Upload Documents',
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
              'Next: Upload collateral photos and documents',
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
              Icon(icon, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
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

  Widget _buildSelectionRow({
    required String label,
    required List<String> options,
    required RxnString? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              return Obx(() {
                final isSelected = selectedValue?.value == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onSelected(option);
                    },
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: AppColors.surfaceColor,
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : AppColors.textColor,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                      ),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(5),
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
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.subtextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                  onPrimary: Colors.white,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          controller.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller,
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildCategorySpecificFields() {
    if (controller.selectedLoanCategoryType.value == 'motor_vehicle') {
      return Column(
        children: [
          const Divider(height: 24),
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
          const Divider(height: 24),
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
          const Divider(height: 24),
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
            labelText: 'Purity (e.g., 18k, 22k)',
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

  Widget _buildDocumentUploadRow({
    required String label,
    required IconData icon,
    required XFile? file,
    required bool isUploading,
    required String? uploadedUrl,
    required VoidCallback onUpload,
    VoidCallback? onView,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (isUploading)
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Uploading...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  )
                else if (uploadedUrl != null)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Uploaded',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.successColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (file != null)
                  Text(
                    'Ready to upload',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.warningColor,
                    ),
                  )
                else
                  Text(
                    'No file selected',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
              ],
            ),
          ),
          if (!isUploading && uploadedUrl == null)
            IconButton(
              onPressed: onUpload,
              icon: const Icon(Icons.cloud_upload_outlined),
              color: AppColors.primaryColor,
              tooltip: 'Upload',
            )
          else if (!isUploading && uploadedUrl != null)
            IconButton(
              onPressed: onView,
              icon: const Icon(Icons.visibility_outlined),
              color: AppColors.primaryColor,
              tooltip: 'View',
            ),
        ],
      ),
    );
  }
}
