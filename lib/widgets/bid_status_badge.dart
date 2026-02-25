import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:real_time_pawn/features/bid_mngmnt/helpers/bid_mngmt_helper.dart';

class BidStatusBadge extends StatelessWidget {
  final dynamic bid; // Accepts UserBid or any bid object
  final double fontSize;

  const BidStatusBadge({super.key, required this.bid, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    // Get status text from the bid
    final statusText = BidManagementHelper.getBidStatusText(bid);
    final statusColor = BidManagementHelper.getBidStatusColorFromText(
      statusText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Alternative: Badge with text only
class BidStatusTextBadge extends StatelessWidget {
  final String statusText;
  final double fontSize;

  const BidStatusTextBadge({
    super.key,
    required this.statusText,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = BidManagementHelper.getBidStatusColorFromText(
      statusText,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Dispute status badge
class DisputeStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const DisputeStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = BidManagementHelper.getDisputeStatusColor(status);
    final statusText = BidManagementHelper.getDisputeStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Payment status badge
class PaymentStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = BidManagementHelper.getPaymentStatusColor(status);
    final statusText = BidManagementHelper.getPaymentStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
