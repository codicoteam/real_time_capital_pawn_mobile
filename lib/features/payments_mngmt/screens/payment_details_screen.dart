import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/payments_mngmt/controllers/payments_mngmt_controller.dart';
import 'package:real_time_pawn/models/payment_mngmt_model.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final PaymentController _controller = Get.find<PaymentController>();
  PaymentModel? _payment;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadPaymentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final payment = await _controller.getPaymentDetails(widget.paymentId);

      if (payment != null) {
        setState(() {
          _payment = payment;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load payment details';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading payment details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPaymentStatus() async {
    if (_payment == null) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final statusResult = await _controller.checkPaymentStatus(
        widget.paymentId,
      );

      if (statusResult != null) {
        // Update payment with new data
        await _loadPaymentDetails();
        Get.snackbar(
          'Status Updated',
          'Payment status has been updated',
          backgroundColor: RealTimeColors.success.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check payment status',
        backgroundColor: RealTimeColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  String _formatDateFull(DateTime date) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'successful':
        return RealTimeColors.success;
      case 'pending':
      case 'processing':
        return RealTimeColors.warning;
      case 'failed':
      case 'cancelled':
      case 'declined':
        return RealTimeColors.error;
      default:
        return AppColors.subtextColor;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isAmount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.subtextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isAmount ? AppColors.textColor : AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header - FIXED
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
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
                    iconSize: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        if (_payment != null)
                          Text(
                            _payment!.reference.length > 20 && isSmallScreen
                                ? '${_payment!.reference.substring(0, 20)}...'
                                : _payment!.reference,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_payment != null)
                    _buildStatusChip(_payment!.paymentStatus),
                ],
              ),
            ),

            // Main Content - SCROLLABLE
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: isSmallScreen ? 48 : 64,
                              color: RealTimeColors.error,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 16),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 16,
                              ),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: AppColors.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 16),
                            SizedBox(
                              width: isSmallScreen ? 120 : 150,
                              child: ElevatedButton(
                                onPressed: _loadPaymentDetails,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 10 : 12,
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _payment == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: isSmallScreen ? 48 : 64,
                            color: RealTimeColors.grey400,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 16,
                            ),
                            child: Text(
                              'Payment not found',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 16 : 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.subtextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Amount Summary - RESPONSIVE
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Amount',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: AppColors.subtextColor,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 4 : 8),
                                Text(
                                  _payment!.formattedAmount,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 24 : 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                if (_payment!.receiptNo != null) ...[
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 8 : 12,
                                      vertical: isSmallScreen ? 4 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.receipt_outlined,
                                          size: isSmallScreen ? 14 : 16,
                                          color: AppColors.primaryColor,
                                        ),
                                        SizedBox(width: isSmallScreen ? 4 : 6),
                                        Flexible(
                                          child: Text(
                                            _payment!.receiptNo!.length > 15 &&
                                                    isSmallScreen
                                                ? 'Receipt: ${_payment!.receiptNo!.substring(0, 15)}...'
                                                : 'Receipt: ${_payment!.receiptNo!}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmallScreen ? 10 : 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // Quick Action - Check Status for PayNow payments
                          if (_payment!.provider == 'paynow' &&
                              (_payment!.isPending || _payment!.isProcessing))
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: RealTimeColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: RealTimeColors.warning.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: RealTimeColors.warning,
                                        size: isSmallScreen ? 16 : 20,
                                      ),
                                      SizedBox(width: isSmallScreen ? 4 : 8),
                                      Expanded(
                                        child: Text(
                                          'This is a PayNow payment. You can check the status manually.',
                                          style: GoogleFonts.poppins(
                                            fontSize: isSmallScreen ? 11 : 12,
                                            color: RealTimeColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isCheckingStatus
                                          ? null
                                          : _checkPaymentStatus,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: RealTimeColors.warning,
                                        minimumSize: Size(
                                          double.infinity,
                                          isSmallScreen ? 40 : 44,
                                        ),
                                      ),
                                      child: _isCheckingStatus
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.refresh,
                                                  size: isSmallScreen ? 16 : 18,
                                                ),
                                                SizedBox(
                                                  width: isSmallScreen ? 4 : 8,
                                                ),
                                                Text(
                                                  'Check Status Now',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: isSmallScreen
                                                        ? 12
                                                        : 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_payment!.provider == 'paynow' &&
                              (_payment!.isPending || _payment!.isProcessing))
                            SizedBox(height: isSmallScreen ? 12 : 20),

                          // Payment Components Breakdown - RESPONSIVE
                          Text(
                            'Payment Allocation',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isSmallScreen ? 2 : 2,
                                  crossAxisSpacing: isSmallScreen ? 8 : 12,
                                  mainAxisSpacing: isSmallScreen ? 8 : 12,
                                  childAspectRatio: isSmallScreen
                                      ? 1.3
                                      : (isLargeScreen ? 1.8 : 1.5),
                                ),
                            children: [
                              _buildComponentCard(
                                label: 'Principal',
                                amount: _payment!.principalComponent,
                                color: AppColors.primaryColor,
                              ),
                              _buildComponentCard(
                                label: 'Interest',
                                amount: _payment!.interestComponent,
                                color: RealTimeColors.warning,
                              ),
                              _buildComponentCard(
                                label: 'Storage',
                                amount: _payment!.storageComponent,
                                color: AppColors.primaryColor.withOpacity(0.7),
                              ),
                              _buildComponentCard(
                                label: 'Penalty',
                                amount: _payment!.penaltyComponent,
                                color: RealTimeColors.error,
                              ),
                            ],
                          ),

                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // Payment Information
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Information',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 16),
                                _buildInfoRow(
                                  label: 'Payment Method',
                                  value:
                                      _payment!.method?.toUpperCase() ?? 'N/A',
                                ),
                                if (_payment!.provider != null)
                                  _buildInfoRow(
                                    label: 'Provider',
                                    value: _payment!.provider!.toUpperCase(),
                                  ),
                                _buildInfoRow(
                                  label: 'Currency',
                                  value: _payment!.currency,
                                ),
                                _buildInfoRow(
                                  label: 'Created Date',
                                  value: _formatDateFull(_payment!.createdAt),
                                ),
                                if (_payment!.paymentDate != null)
                                  _buildInfoRow(
                                    label: 'Payment Date',
                                    value: _payment!.paymentDate!,
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 8 : 16),

                          // Transaction Details
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Details',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 16),
                                _buildInfoRow(
                                  label: 'Payment ID',
                                  value: _payment!.id.length > 12
                                      ? '${_payment!.id.substring(0, 12)}...'
                                      : _payment!.id,
                                ),
                                _buildInfoRow(
                                  label: 'Reference',
                                  value: _payment!.reference.length > 15
                                      ? '${_payment!.reference.substring(0, 15)}...'
                                      : _payment!.reference,
                                ),
                                if (_payment!.loan.isNotEmpty)
                                  _buildInfoRow(
                                    label: 'Loan ID',
                                    value: _payment!.loan.length > 12
                                        ? '${_payment!.loan.substring(0, 12)}...'
                                        : _payment!.loan,
                                  ),
                                if (_payment!.loanTerm != null)
                                  _buildInfoRow(
                                    label: 'Loan Term',
                                    value: _payment!.loanTerm!,
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 8 : 16),

                          // Notes
                          if (_payment!.notes != null &&
                              _payment!.notes!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notes',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  Text(
                                    _payment!.notes!,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: AppColors.subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Share/Print Receipt Button
                          if (_payment!.isPaid && _payment!.receiptNo != null)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.snackbar(
                                    'Receipt',
                                    'Receipt sharing feature coming soon!',
                                    backgroundColor: AppColors.primaryColor,
                                    colorText: Colors.white,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 12 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.share_outlined,
                                      size: isSmallScreen ? 18 : 24,
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 8),
                                    Text(
                                      'Share Receipt',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          SizedBox(height: isSmallScreen ? 16 : 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
