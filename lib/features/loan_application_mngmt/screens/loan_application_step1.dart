import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/screens/asset_upload_section.dart'
    show UploadedAsset, AssetUploadSection;
import 'package:real_time_pawn/widgets/custom_button.dart';
import 'package:real_time_pawn/widgets/text_fields/custom_text_field.dart';
import '../helpers/loan_application_mngmt_helper.dart' show LoanApplicationHelper;
import 'Loan application upload screen.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen>
    with SingleTickerProviderStateMixin {
  // Personal Information
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _workLocationController = TextEditingController();
  final TextEditingController _employerContactController =
      TextEditingController();

  // Loan Information
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _collateralDescController =
      TextEditingController();
  final TextEditingController _suretyDescController = TextEditingController();
  final TextEditingController _assetValueController = TextEditingController();

  // State variables
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEmploymentType;
  String? _selectedEmploymentDuration;
  String? _selectedLoanCategory;
  String? _selectedLoanCategoryType; // Store the type for API
  bool _isDeclarationChecked = false;
  late AnimationController _categoryAnimationController;
  bool _isSubmitting = false;

  // Category options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];
  final List<String> _employmentTypeOptions = [
    'Full-time',
    'Part-time',
    'Self-employed',
    'Unemployed',
  ];
  final List<String> _employmentDurationOptions = [
    '< 1 year',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  // Loan Categories with icons
  final List<Map<String, dynamic>> _loanCategories = [
    {
      'title': 'Motor Vehicle',
      'type': 'motor_vehicle',
      'icon': Icons.directions_car,
      'color': RealTimeColors.primaryGreen,
      'description': 'Use your vehicle as collateral',
    },
    {
      'title': 'Electronics',
      'type': 'small_loans',
      'icon': Icons.devices,
      'color': RealTimeColors.primaryGreen,
      'description': 'Phones, laptops, gadgets',
    },
    {
      'title': 'Jewelry',
      'type': 'jewellery',
      'icon': Icons.diamond,
      'color': RealTimeColors.primaryGreen,
      'description': 'Gold, watches, precious items',
    },
  ];

  @override
  void initState() {
    super.initState();
    _categoryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _categoryAnimationController.dispose();
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _jobTitleController.dispose();
    _workLocationController.dispose();
    _employerContactController.dispose();
    _loanAmountController.dispose();
    _collateralDescController.dispose();
    _suretyDescController.dispose();
    _assetValueController.dispose();
    super.dispose();
  }

  bool get _isFormComplete {
    return _fullNameController.text.isNotEmpty &&
        _nationalIdController.text.isNotEmpty &&
        _selectedGender != null &&
        _dateOfBirthController.text.isNotEmpty &&
        _selectedMaritalStatus != null &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _selectedEmploymentType != null &&
        _jobTitleController.text.isNotEmpty &&
        _selectedEmploymentDuration != null &&
        _workLocationController.text.isNotEmpty &&
        _loanAmountController.text.isNotEmpty &&
        _selectedLoanCategory != null &&
        _collateralDescController.text.isNotEmpty &&
        _assetValueController.text.isNotEmpty &&
        _isDeclarationChecked;
  }

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
                  // Personal Information Card
                  _buildSectionCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        children: [
                          CustomTextField(
                            controller: _fullNameController,
                            labelText: 'Full Name',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                            ),
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _nationalIdController,
                            labelText: 'National ID Number',
                            prefixIcon: const Icon(
                              Icons.credit_card_outlined,
                              size: 20,
                            ),
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Gender Selection
                          _buildSelectionRow(
                            label: 'Gender',
                            options: _genderOptions,
                            selectedValue: _selectedGender,
                            onSelected: (value) =>
                                setState(() => _selectedGender = value),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Date of Birth
                          _buildDatePickerField(
                            controller: _dateOfBirthController,
                            label: 'Date of Birth',
                            icon: Icons.calendar_today_outlined,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Marital Status
                          _buildSelectionRow(
                            label: 'Marital Status',
                            options: _maritalStatusOptions,
                            selectedValue: _selectedMaritalStatus,
                            onSelected: (value) =>
                                setState(() => _selectedMaritalStatus = value),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _phoneController,
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _altPhoneController,
                            labelText: 'Alternative Phone (Optional)',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email Address',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _addressController,
                            labelText: 'Home Address',
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                            ),
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
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
                          // Employment Type
                          _buildSelectionRow(
                            label: 'Employment Type',
                            options: _employmentTypeOptions,
                            selectedValue: _selectedEmploymentType,
                            onSelected: (value) =>
                                setState(() => _selectedEmploymentType = value),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _jobTitleController,
                            labelText: 'Job Title',
                            prefixIcon: const Icon(
                              Icons.work_outline,
                              size: 20,
                            ),
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Employment Duration
                          _buildSelectionRow(
                            label: 'Employment Duration',
                            options: _employmentDurationOptions,
                            selectedValue: _selectedEmploymentDuration,
                            onSelected: (value) => setState(
                              () => _selectedEmploymentDuration = value,
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _workLocationController,
                            labelText: 'Work Location',
                            prefixIcon: const Icon(
                              Icons.business_outlined,
                              size: 20,
                            ),
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _employerContactController,
                            labelText: 'Employer Contact (Optional)',
                            prefixIcon: const Icon(
                              Icons.contact_phone_outlined,
                              size: 20,
                            ),
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Loan Details Card
                  _buildSectionCard(
                        title: 'Loan Details',
                        icon: Icons.monetization_on_outlined,
                        children: [
                          CustomTextField(
                            controller: _loanAmountController,
                            labelText: 'Loan Amount',
                            prefixIcon: const Icon(
                              Icons.attach_money_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Loan Category Grid
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
                            itemCount: _loanCategories.length,
                            itemBuilder: (context, index) {
                              final category = _loanCategories[index];
                              return _buildCategoryCard(
                                title: category['title'],
                                icon: category['icon'],
                                color: category['color'],
                                description: category['description'],
                                isSelected:
                                    _selectedLoanCategory == category['title'],
                                onTap: () => setState(() {
                                  _selectedLoanCategory = category['title'];
                                  _selectedLoanCategoryType = category['type'];
                                }),
                              ).animate().fadeIn(delay: (200 + index * 100).ms);
                            },
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _collateralDescController,
                            labelText: 'Collateral Description',
                            prefixIcon: const Icon(
                              Icons.description_outlined,
                              size: 20,
                            ),
                            maxLength: 300,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _suretyDescController,
                            labelText: 'Surety Description (Optional)',
                            prefixIcon: const Icon(
                              Icons.security_outlined,
                              size: 20,
                            ),
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _assetValueController,
                            labelText: 'Declared Asset Value',
                            prefixIcon: const Icon(
                              Icons.assessment_outlined,
                              size: 20,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
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
                                onTap: () {
                                  setState(() {
                                    _isDeclarationChecked =
                                        !_isDeclarationChecked;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: 200.ms,
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: _isDeclarationChecked
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _isDeclarationChecked
                                          ? AppColors.primaryColor
                                          : RealTimeColors.grey400,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isDeclarationChecked
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
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
            CustomButton(
              btnColor: _isFormComplete && !_isSubmitting
                  ? AppColors.primaryColor
                  : RealTimeColors.grey300,
              width: double.infinity,
              borderRadius: 12,
              onTap: _isFormComplete && !_isSubmitting
                  ? _submitApplication
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Please complete all required fields',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.errorColor,
                        ),
                      );
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Continue to Upload Documents',
                      style: GoogleFonts.poppins(
                        color: _isFormComplete && !_isSubmitting
                            ? Colors.white
                            : RealTimeColors.grey600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
    required String? selectedValue,
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
              final isSelected = selectedValue == option;
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
          context: context,
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
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          controller.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          setState(() {});
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

  void _submitApplication() async {
    if (!_isFormComplete) return;

    setState(() {
      _isSubmitting = true;
    });

    // Parse date
    DateTime? parsedDate;
    try {
      final dateParts = _dateOfBirthController.text.split('/');
      if (dateParts.length == 3) {
        parsedDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
      }
    } catch (e) {
      // Handle date parsing error
    }

    // Prepare payload
    final payload = {
      "full_name": _fullNameController.text,
      "national_id_number": _nationalIdController.text,
      "gender": _selectedGender,
      "date_of_birth": parsedDate?.toIso8601String(),
      "marital_status": _selectedMaritalStatus,
      "contact_details": _phoneController.text,
      "alternative_number": _altPhoneController.text.isNotEmpty
          ? _altPhoneController.text
          : null,
      "email_address": _emailController.text,
      "home_address": _addressController.text,
      "employment": {
        "employment_type": _selectedEmploymentType,
        "title": _jobTitleController.text,
        "duration": _selectedEmploymentDuration,
        "location": _workLocationController.text,
        "contacts": _employerContactController.text.isNotEmpty
            ? _employerContactController.text
            : null,
      },
      "requested_loan_amount": int.tryParse(_loanAmountController.text),
      "collateral_category": _selectedLoanCategoryType, // Use type instead of title
      "collateral_description": _collateralDescController.text,
      "surety_description": _suretyDescController.text.isNotEmpty
          ? _suretyDescController.text
          : null,
      "declared_asset_value": int.tryParse(_assetValueController.text),
      "declaration_text":
          "I declare that all information provided is true and accurate.",
      "declaration_signed_at": DateTime.now().toIso8601String(),
      "declaration_signature_name": _fullNameController.text,
    };
    DevLogs.logError("Selected Loan Category Type: ${_selectedLoanCategoryType}");
    // Call helper and get loan ID
    final result = await LoanApplicationHelper.createLoanApplication(
      payload: payload,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (result.success && result.loanId != null) {
      // Navigate to upload screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoanApplicationUploadScreen(
            loanId: result.loanId!,
            loanCategory: _selectedLoanCategory ?? '',
            applicationNo: result.applicationNo ?? '',
          ),
        ),
      );
    }
  }
}