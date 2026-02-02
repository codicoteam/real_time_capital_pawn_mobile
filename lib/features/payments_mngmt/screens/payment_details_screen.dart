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
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isAmount ? AppColors.textColor : AppColors.textColor,
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
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

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
                          'Payment Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        if (_payment != null)
                          Text(
                            _payment!.reference,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
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

            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: RealTimeColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPaymentDetails,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_payment == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: RealTimeColors.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Payment not found',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount Summary
                      Container(
                        padding: const EdgeInsets.all(16),
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
                                fontSize: 14,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _payment!.formattedAmount,
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            if (_payment!.receiptNo != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
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
                                      size: 16,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Receipt: ${_payment!.receiptNo!}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Quick Action - Check Status for PayNow payments
                      if (_payment!.provider == 'paynow' &&
                          (_payment!.isPending || _payment!.isProcessing))
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: RealTimeColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: RealTimeColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: RealTimeColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This is a PayNow payment. You can check the status manually.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: RealTimeColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _isCheckingStatus
                                    ? null
                                    : _checkPaymentStatus,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: RealTimeColors.warning,
                                  minimumSize: const Size(double.infinity, 44),
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
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.refresh, size: 18),
                                          SizedBox(width: 8),
                                          Text('Check Status Now'),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),

                      if (_payment!.provider == 'paynow' &&
                          (_payment!.isPending || _payment!.isProcessing))
                        const SizedBox(height: 20),

                      // Payment Components Breakdown
                      Text(
                        'Payment Allocation',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.5,
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

                      const SizedBox(height: 20),

                      // Payment Information
                      Container(
                        padding: const EdgeInsets.all(16),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              label: 'Payment Method',
                              value: _payment!.method?.toUpperCase() ?? 'N/A',
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

                      const SizedBox(height: 16),

                      // Transaction Details
                      Container(
                        padding: const EdgeInsets.all(16),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              label: 'Payment ID',
                              value: _payment!.id.substring(0, 12) + '...',
                            ),
                            _buildInfoRow(
                              label: 'Reference',
                              value: _payment!.reference,
                            ),
                            if (_payment!.loan.isNotEmpty)
                              _buildInfoRow(
                                label: 'Loan ID',
                                value: _payment!.loan,
                              ),
                            if (_payment!.loanTerm != null)
                              _buildInfoRow(
                                label: 'Loan Term',
                                value: _payment!.loanTerm!,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notes
                      if (_payment!.notes != null &&
                          _payment!.notes!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _payment!.notes!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Share/Print Receipt Button
                      if (_payment!.isPaid && _payment!.receiptNo != null)
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement receipt sharing/printing
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share_outlined),
                              SizedBox(width: 8),
                              Text('Share Receipt'),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
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
