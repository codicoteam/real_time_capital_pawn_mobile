import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/widgets/custom_button.dart';

class LoanApplicationStep2 extends StatefulWidget {
  const LoanApplicationStep2({super.key});

  @override
  State<LoanApplicationStep2> createState() => _LoanApplicationStep2State();
}

class _LoanApplicationStep2State extends State<LoanApplicationStep2> {
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _collateralDescController =
      TextEditingController();
  final TextEditingController _suretyDescController = TextEditingController();
  final TextEditingController _assetValueController = TextEditingController();

  String? _selectedCollateralCategory;
  bool _isDeclarationChecked = false;

  final List<String> _collateralOptions = [
    'Small Loans',
    'Electronics',
    'Vehicles',
    'Jewelry',
    'Real Estate',
    'Other',
  ];

  bool get _isFormComplete {
    return _loanAmountController.text.isNotEmpty &&
        _selectedCollateralCategory != null &&
        _collateralDescController.text.isNotEmpty &&
        _assetValueController.text.isNotEmpty &&
        _isDeclarationChecked;
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _collateralDescController.dispose();
    _suretyDescController.dispose();
    _assetValueController.dispose();
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
              'Step 2 of 2',
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
      body: SafeArea(
        child: Column(
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
                        borderRadius: const BorderRadius.all(
                          Radius.circular(2),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Details Card
                    _buildSectionCard(
                          title: 'Loan Details',
                          children: [
                            _buildTextField(
                                  controller: _loanAmountController,
                                  label: 'Requested Loan Amount',
                                  icon: Icons.attach_money_outlined,
                                  keyboardType: TextInputType.number,
                                  prefixText: '\$ ',
                                  onChanged: (_) => setState(() {}),
                                )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideY(begin: 0.1),
                            const SizedBox(height: 16),

                            // Collateral Category Dropdown
                            Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCollateralCategory,
                                      hint: Text(
                                        'Collateral Category',
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
                                      items: _collateralOptions.map((
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
                                          _selectedCollateralCategory =
                                              newValue;
                                        });
                                      },
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.1),
                            const SizedBox(height: 16),

                            _buildTextField(
                                  controller: _collateralDescController,
                                  label: 'Collateral Description',
                                  icon: Icons.description_outlined,
                                  maxLines: 3,
                                  onChanged: (_) => setState(() {}),
                                )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideY(begin: 0.1),
                            const SizedBox(height: 16),

                            _buildTextField(
                                  controller: _suretyDescController,
                                  label: 'Surety Description (Optional)',
                                  icon: Icons.security_outlined,
                                  maxLines: 2,
                                  onChanged: (_) => setState(() {}),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1),
                            const SizedBox(height: 16),

                            _buildTextField(
                                  controller: _assetValueController,
                                  label: 'Declared Asset Value',
                                  icon: Icons.assessment_outlined,
                                  keyboardType: TextInputType.number,
                                  prefixText: '\$ ',
                                  onChanged: (_) => setState(() {}),
                                )
                                .animate()
                                .fadeIn(delay: 500.ms)
                                .slideY(begin: 0.1),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 24),

                    // Declaration Card
                    _buildSectionCard(
                          title: 'Declaration',
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
                                  child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'I declare that the information provided is true and accurate.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'By checking this box, you confirm all details are correct and agree to our terms and conditions.',
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
                        .fadeIn(duration: 500.ms, delay: 300.ms)
                        .scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 100), // Space for buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Action Buttons
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
            Row(
              children: [
                // Back Button
                Expanded(
                  child: CustomButton(
                    btnColor: Colors.transparent,
                    width: double.infinity,
                    borderRadius: 12,
                    boxBorder: Border.all(
                      color: RealTimeColors.grey300,
                      width: 1.5,
                    ),
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Submit Button
                Expanded(
                  child: CustomButton(
                    btnColor: _isFormComplete
                        ? AppColors.primaryColor
                        : RealTimeColors.grey300,
                    width: double.infinity,
                    borderRadius: 12,
                    onTap: _isFormComplete
                        ? () {
                            _submitApplication();
                          }
                        : () {
                            // Show feedback when form is incomplete
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please complete all required fields',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    child: Text(
                      'Submit Application',
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

            const SizedBox(height: 12),

            // Helper Text
            Text(
              'Your application will be reviewed by our loan officers.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  void _submitApplication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Application Submitted',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Your loan application has been submitted successfully. '
          'Our team will review it and contact you within 24-48 hours.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AppColors.primaryColor),
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
    String? prefixText,
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
}
