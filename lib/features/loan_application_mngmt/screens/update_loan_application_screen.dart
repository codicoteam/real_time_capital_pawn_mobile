import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
              'Edit Loan Application',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Update your information',
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
          // Progress indicator (optional, we can reuse or remove)
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
                      width: constraints.maxWidth * 1.0, // full width for edit
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
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.nationalIdController,
                            labelText: 'National ID Number',
                            prefixIcon: const Icon(
                              Icons.credit_card_outlined,
                              size: 20,
                            ),
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
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: controller.employerContactController,
                            labelText: 'Employer Contact (Optional)',
                            prefixIcon: const Icon(
                              Icons.contact_phone_outlined,
                              size: 20,
                            ),
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
                                  description:
                                      category['description'] as String,
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

                          // Category-specific fields
                          Obx(() {
                            if (controller.selectedLoanCategoryType.value !=
                                null) {
                              return _buildCategorySpecificFields(controller)
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
                          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 600.ms)
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

      // Update Button
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
                    controller.submitUpdate();
                  } else {
                    // Show validation errors via missing fields
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
          ],
        ),
      ),
    );
  }

  // Reusable UI components (same as in LoanApplicationScreen)

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

  Widget _buildCategorySpecificFields(
    UpdateLoanApplicationController controller,
  ) {
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
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleModelController,
            labelText: 'Model',
            prefixIcon: const Icon(Icons.model_training, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleRegController,
            labelText: 'Registration Number',
            prefixIcon: const Icon(Icons.confirmation_number, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleCcSerialController,
            labelText: 'CC/Serial Number',
            prefixIcon: const Icon(Icons.numbers, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleEngineController,
            labelText: 'Engine Number',
            prefixIcon: const Icon(Icons.engineering, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleChassisController,
            labelText: 'Chassis Number',
            prefixIcon: const Icon(Icons.format_quote, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.vehicleYearController,
            labelText: 'Year',
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            keyboardType: TextInputType.number,
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
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.electronicModelController,
            labelText: 'Model',
            prefixIcon: const Icon(Icons.model_training, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.electronicSerialController,
            labelText: 'Serial Number',
            prefixIcon: const Icon(Icons.numbers, size: 20),
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
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelDescController,
            labelText: 'Description',
            prefixIcon: const Icon(Icons.description, size: 20),
            maxLength: 200,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelWeightController,
            labelText: 'Weight (grams)',
            prefixIcon: const Icon(Icons.monitor_weight, size: 20),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelPurityController,
            labelText: 'Purity (e.g., 18k, 22k)',
            prefixIcon: const Icon(Icons.percent, size: 20),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.jewelEstimatedValueController,
            labelText: 'Estimated Value',
            prefixIcon: const Icon(Icons.attach_money, size: 20),
            keyboardType: TextInputType.number,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
