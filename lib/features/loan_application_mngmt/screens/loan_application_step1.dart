import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_button.dart';

import 'loan_application_step2.dart' show LoanApplicationStep2;

class LoanApplicationStep1 extends StatefulWidget {
  const LoanApplicationStep1({super.key});

  @override
  State<LoanApplicationStep1> createState() => _LoanApplicationStep1State();
}

class _LoanApplicationStep1State extends State<LoanApplicationStep1> {
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

  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedEmploymentType;
  String? _selectedEmploymentDuration;

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
        _workLocationController.text.isNotEmpty;
  }

  @override
  void dispose() {
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
    super.dispose();
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
              'Step 1 of 2',
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
          // Progress Bar
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        bottomLeft: Radius.circular(2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: RealTimeColors.grey300,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
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
                  // Personal Information Card
                  _buildSectionCard(
                        title: 'Personal Information',
                        children: [
                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _nationalIdController,
                            label: 'National ID Number',
                            icon: Icons.credit_card_outlined,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Gender Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                hint: Text(
                                  'Gender',
                                  style: GoogleFonts.poppins(
                                    color: RealTimeColors.grey500,
                                    fontSize: 14,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: RealTimeColors.grey500,
                                ),
                                isExpanded: true,
                                items: _genderOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Custom Date Picker Field
                          _buildDatePickerField(
                            controller: _dateOfBirthController,
                            label: 'Date of Birth',
                            icon: Icons.calendar_today_outlined,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Marital Status Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedMaritalStatus,
                                hint: Text(
                                  'Marital Status',
                                  style: GoogleFonts.poppins(
                                    color: RealTimeColors.grey500,
                                    fontSize: 14,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: RealTimeColors.grey500,
                                ),
                                isExpanded: true,
                                items: _maritalStatusOptions.map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedMaritalStatus = newValue;
                                  });
                                },
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Phone Number Field (using regular TextField)
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Alternative Phone Number Field
                          _buildTextField(
                            controller: _altPhoneController,
                            label: 'Alternative Phone Number (Optional)',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _addressController,
                            label: 'Home Address',
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
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
                        children: [
                          // Employment Type Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedEmploymentType,
                                hint: Text(
                                  'Employment Type',
                                  style: GoogleFonts.poppins(
                                    color: RealTimeColors.grey500,
                                    fontSize: 14,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: RealTimeColors.grey500,
                                ),
                                isExpanded: true,
                                items: _employmentTypeOptions.map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedEmploymentType = newValue;
                                  });
                                },
                              ),
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _jobTitleController,
                            label: 'Job Title',
                            icon: Icons.work_outline,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          // Employment Duration Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedEmploymentDuration,
                                hint: Text(
                                  'Employment Duration',
                                  style: GoogleFonts.poppins(
                                    color: RealTimeColors.grey500,
                                    fontSize: 14,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: RealTimeColors.grey500,
                                ),
                                isExpanded: true,
                                items: _employmentDurationOptions.map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedEmploymentDuration = newValue;
                                  });
                                },
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _workLocationController,
                            label: 'Work Location',
                            icon: Icons.business_outlined,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _employerContactController,
                            label: 'Employer Contact Details (Optional)',
                            icon: Icons.contact_phone_outlined,
                            onChanged: (_) => setState(() {}),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 100), // Space for the button
                ],
              ),
            ),
          ),

          // Fixed Bottom Button Container
          Container(
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
            child: CustomButton(
              btnColor: _isFormComplete
                  ? AppColors.primaryColor
                  : RealTimeColors.grey300,
              width: double.infinity,
              borderRadius: 12,
              onTap: _isFormComplete
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoanApplicationStep2(),
                        ),
                      );
                    }
                  : () {
                      // Show feedback when form is incomplete
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all required fields'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              child: Text(
                'Next',
                style: GoogleFonts.poppins(
                  color: _isFormComplete
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
    );
  }

  Widget _buildSectionCard({
    required String title,
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: Icon(icon, size: 20, color: RealTimeColors.grey500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: RealTimeColors.grey500,
          fontSize: 14,
        ),
      ),
      style: GoogleFonts.poppins(color: AppColors.textColor, fontSize: 14),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    ValueChanged<String>? onChanged,
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
              data: ThemeData(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                  onPrimary: Colors.white,
                  onSurface: AppColors.primaryColor,
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
          if (onChanged != null) onChanged(controller.text);
          setState(() {});
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIcon: Icon(icon, size: 20, color: RealTimeColors.grey500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              color: RealTimeColors.grey500,
              fontSize: 14,
            ),
          ),
          style: GoogleFonts.poppins(color: AppColors.textColor, fontSize: 14),
        ),
      ),
    );
  }
}
