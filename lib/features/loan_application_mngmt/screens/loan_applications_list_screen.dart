import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/screens/loan_application_details_screen.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';

class LoanApplicationsListScreen extends StatefulWidget {
  const LoanApplicationsListScreen({super.key});

  @override
  State<LoanApplicationsListScreen> createState() =>
      _LoanApplicationsListScreenState();
}

class _LoanApplicationsListScreenState
    extends State<LoanApplicationsListScreen> {
  // Mock data
  final List<LoanApplication> _loanApplications = [
    LoanApplication(
      id: 'LA001',
      applicantName: 'Ipanoshi Chirume',
      status: 'Processing',
      amount: 1500.00,
      collateralCategory: 'Small Loan',
      applicationDate: 'Jan 17, 2026',
    ),
    LoanApplication(
      id: 'LA002',
      applicantName: 'John Mwansa',
      status: 'Submitted',
      amount: 5000.00,
      collateralCategory: 'Vehicle Loan',
      applicationDate: 'Jan 15, 2026',
    ),
    LoanApplication(
      id: 'LA003',
      applicantName: 'Sarah Banda',
      status: 'Approved',
      amount: 10000.00,
      collateralCategory: 'Property Loan',
      applicationDate: 'Jan 10, 2026',
    ),
    LoanApplication(
      id: 'LA004',
      applicantName: 'Peter Phiri',
      status: 'Processing',
      amount: 2500.00,
      collateralCategory: 'Jewelry Loan',
      applicationDate: 'Jan 8, 2026',
    ),
    LoanApplication(
      id: 'LA005',
      applicantName: 'Mary Tembo',
      status: 'Submitted',
      amount: 7500.00,
      collateralCategory: 'Electronics Loan',
      applicationDate: 'Jan 5, 2026',
    ),
    // Add more for scrolling
    LoanApplication(
      id: 'LA006',
      applicantName: 'James Ngoma',
      status: 'Approved',
      amount: 3000.00,
      collateralCategory: 'Small Loan',
      applicationDate: 'Jan 3, 2026',
    ),
    LoanApplication(
      id: 'LA007',
      applicantName: 'Anna Bwalya',
      status: 'Processing',
      amount: 6000.00,
      collateralCategory: 'Jewelry Loan',
      applicationDate: 'Jan 1, 2026',
    ),
    LoanApplication(
      id: 'LA008',
      applicantName: 'David Lungu',
      status: 'Submitted',
      amount: 8500.00,
      collateralCategory: 'Vehicle Loan',
      applicationDate: 'Dec 28, 2025',
    ),
  ];

  String _selectedFilter = 'Newest';
  final List<String> _filterOptions = [
    'Newest',
    'Oldest',
    'Amount: High to Low',
    'Amount: Low to High',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header with Gradient
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppBar content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hi, Ipanoshi Chirume',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '\$18,750.00',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Requested Loans',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Search & Filters Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.subtextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search applications...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppColors.subtextColor,
                                  fontSize: 14,
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    Row(
                      children: [
                        // Newest Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor,
                                fontSize: 14,
                              ),
                              items: _filterOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFilter = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Filter Icon Button
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color: AppColors.textColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Another Filter Icon Button
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: AppColors.textColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Loan Applications List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ..._loanApplications
                        .map((application) => _buildLoanCard(application))
                        .toList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Pagination
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.textColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Page 1 of 5',
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(Icons.home_outlined, 'Home', false),
                    _buildBottomNavItem(
                      Icons.request_quote_outlined,
                      'Loans',
                      true,
                    ),
                    // FAB-style center button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                    _buildBottomNavItem(
                      Icons.history_outlined,
                      'History',
                      false,
                    ),
                    _buildBottomNavItem(Icons.person_outline, 'Profile', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanCard(LoanApplication application) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoanApplicationDetailsScreen(application: application),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Loan ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  application.id,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildStatusChip(application.status),
              ],
            ),
            const SizedBox(height: 16),

            // Applicant Name
            Text(
              application.applicantName,
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Collateral Type and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  application.collateralCategory,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  application.applicationDate,
                  style: GoogleFonts.poppins(
                    color: AppColors.subtextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount
            Text(
              '\$${application.amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Processing':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        break;
      case 'Submitted':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case 'Approved':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF388E3C);
        break;
      default:
        backgroundColor = RealTimeColors.grey200;
        textColor = RealTimeColors.grey700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.primaryColor : AppColors.subtextColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isActive ? AppColors.primaryColor : AppColors.subtextColor,
          ),
        ),
      ],
    );
  }
}
