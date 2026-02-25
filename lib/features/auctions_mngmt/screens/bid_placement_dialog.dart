import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/auction_models.dart';

class BidPlacementDialog extends StatefulWidget {
  final Auction? auction; // Make auction optional
  final String? auctionTitle; // Alternative to auction
  final double currentBid;
  final double? reservePrice;
  final double startingBid;
  final Function(double) onPlaceBid;

  // Constructor that works with both patterns
  const BidPlacementDialog({
    super.key,
    this.auction,
    this.auctionTitle,
    required this.currentBid,
    this.reservePrice,
    required this.startingBid,
    required this.onPlaceBid,
  }) : assert(
         auction != null || auctionTitle != null,
         'Either auction or auctionTitle must be provided',
       );

  @override
  State<BidPlacementDialog> createState() => _BidPlacementDialogState();
}

class _BidPlacementDialogState extends State<BidPlacementDialog> {
  final TextEditingController _amountController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set initial bid amount (10% higher than current)
    final suggestedBid = (widget.currentBid * 1.1).ceilToDouble();
    _amountController.text = suggestedBid.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _placeBid() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() => _errorMessage = 'Please enter a bid amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      setState(() => _errorMessage = 'Please enter a valid number');
      return;
    }

    if (amount <= widget.currentBid) {
      setState(() => _errorMessage = 'Bid must be higher than current bid');
      return;
    }

    // ADD THIS CHECK:
    final now = DateTime.now().toUtc();
    if (widget.auction?.startDate != null &&
        widget.auction!.startDate.isAfter(now)) {
      setState(() => _errorMessage = 'Auction has not started yet');
      return;
    }

    setState(() => _isSubmitting = true);
    widget.onPlaceBid(amount);
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.auction?.asset.title ?? widget.auctionTitle ?? 'Auction';

    return AlertDialog(
      title: Column(
        children: [
          Icon(Icons.gavel_rounded, color: AppColors.primaryColor, size: 40),
          const SizedBox(height: 8),
          Text(
            'Place a Bid',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              'Current bid: \$${widget.currentBid.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            if (widget.reservePrice != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reserve price: \$${widget.reservePrice!.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, color: RealTimeColors.warning),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Your bid amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _errorMessage,
              ),
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _placeBid,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Place Bid', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
