import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';

class LoanApplicationDetailsScreen extends StatelessWidget {
  final LoanApplication application;

  const LoanApplicationDetailsScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Application Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Application Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Loan ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Text(
                      application.id,
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: application.status == 'Processing'
                          ? const Color(0xFFFFF3E0)
                          : application.status == 'Submitted'
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      application.status,
                      style: GoogleFonts.poppins(
                        color: application.status == 'Processing'
                            ? const Color(0xFFF57C00)
                            : application.status == 'Submitted'
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF388E3C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Applicant Information Card
            _buildSectionCard(
              title: 'Applicant Information',
              children: [
                _buildInfoRow(
                  label: 'Full Name',
                  value: application.applicantName,
                ),
                _buildInfoRow(label: 'National ID', value: '63-2123456C01'),
                _buildInfoRow(
                  label: 'Email',
                  value: 'ipanoshichirume@email.com',
                ),
                _buildInfoRow(label: 'Phone Number', value: '+260 97 123 4567'),
              ],
            ),

            const SizedBox(height: 24),

            // Loan Information Card
            _buildSectionCard(
              title: 'Loan Information',
              children: [
                _buildInfoRow(
                  label: 'Requested Loan Amount',
                  value: '\$${application.amount.toStringAsFixed(2)}',
                  valueStyle: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildInfoRow(
                  label: 'Application Date',
                  value: application.applicationDate,
                ),
                _buildInfoRow(label: 'Loan Term', value: '12 months'),
                _buildInfoRow(label: 'Interest Rate', value: '15% per annum'),
              ],
            ),

            const SizedBox(height: 24),

            // Collateral Information Card
            _buildSectionCard(
              title: 'Collateral Information',
              children: [
                _buildInfoRow(
                  label: 'Category',
                  value: application.collateralCategory,
                ),
                _buildInfoRow(
                  label: 'Description',
                  value:
                      'Gold necklace with diamond pendant, approximately 18K gold weight.',
                  maxLines: 2,
                ),
                _buildInfoRow(
                  label: 'Estimated Value',
                  value: '\$${(application.amount * 1.5).toStringAsFixed(2)}',
                ),
                _buildInfoRow(
                  label: 'Storage Location',
                  value: 'Main Vault - Room A12',
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
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

  Widget _buildInfoRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                valueStyle ??
                GoogleFonts.poppins(
                  color: AppColors.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
