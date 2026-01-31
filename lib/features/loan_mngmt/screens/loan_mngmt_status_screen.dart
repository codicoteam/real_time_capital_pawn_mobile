import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class LoanStatusScreen extends StatefulWidget {
  final String loanId;

  const LoanStatusScreen({super.key, required this.loanId});

  @override
  State<LoanStatusScreen> createState() => _LoanStatusScreenState();
}

class _LoanStatusScreenState extends State<LoanStatusScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusHistory = [
    {
      'date': '02 Jan 2024, 10:30 AM',
      'status': 'Application Submitted',
      'description': 'Loan application submitted with collateral',
      'actor': 'Customer',
      'icon': Icons.description_outlined,
      'color': RealTimeColors.success,
    },
    {
      'date': '02 Jan 2024, 2:15 PM',
      'status': 'Application Approved',
      'description': 'Application reviewed and approved by loan officer',
      'actor': 'Loan Officer',
      'icon': Icons.verified_outlined,
      'color': RealTimeColors.success,
    },
    {
      'date': '02 Jan 2024, 3:45 PM',
      'status': 'Loan Disbursed',
      'description': 'K10,000.00 disbursed to customer account',
      'actor': 'System',
      'icon': Icons.attach_money_outlined,
      'color': AppColors.primaryColor,
    },
    {
      'date': '10 Jan 2024, 11:20 AM',
      'status': 'Payment Received',
      'description': 'K2,500.00 payment received via Mobile Money',
      'actor': 'Customer',
      'icon': Icons.payments_outlined,
      'color': RealTimeColors.success,
    },
    {
      'date': '15 Jan 2024, 9:00 AM',
      'status': 'Payment Due',
      'description': 'Next payment of K2,500.00 is due today',
      'actor': 'System',
      'icon': Icons.notifications_outlined,
      'color': RealTimeColors.warning,
    },
  ];

  final List<Map<String, dynamic>> _futureStatuses = [
    {
      'status': 'Loan Renewal',
      'description': 'Option to renew loan after 30 days',
      'date': '01 Feb 2024',
      'icon': Icons.autorenew_outlined,
      'color': AppColors.subtextColor,
    },
    {
      'status': 'Loan Settlement',
      'description': 'Complete loan repayment',
      'date': '15 Feb 2024',
      'icon': Icons.flag_outlined,
      'color': RealTimeColors.success,
    },
    {
      'status': 'Collateral Release',
      'description': 'Collateral returned after full settlement',
      'date': '16 Feb 2024',
      'icon': Icons.inventory_outlined,
      'color': AppColors.primaryColor,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Timeline',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          'Loan ${widget.loanId}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Current Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RealTimeColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: RealTimeColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Active', // From API: current status
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: RealTimeColors.success,
                          ),
                        ),
                        Text(
                          'Loan is active and in good standing',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status History
                    Text(
                      'Status History',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusTimeline(),

                    const SizedBox(height: 24),

                    // Upcoming Statuses
                    Text(
                      'Upcoming Milestones',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._futureStatuses.map((status) {
                      return _buildFutureStatusCard(status);
                    }).toList(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      children: _statusHistory.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isLast = index == _statusHistory.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: status['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status['icon'] as IconData,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 80, color: AppColors.borderColor),
              ],
            ),
            const SizedBox(width: 12),

            // Status card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: status['color'],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Text(
                            status['actor'],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 12,
                          color: AppColors.subtextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status['date'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFutureStatusCard(Map<String, dynamic> status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status['icon'] as IconData,
              color: status['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: status['color'],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Expected',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.subtextColor,
                ),
              ),
              Text(
                status['date'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
