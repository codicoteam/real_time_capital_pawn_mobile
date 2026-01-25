import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/models/auction_models.dart';

class AuctionDetailsScreen extends StatefulWidget {
  final String auctionId;

  const AuctionDetailsScreen({super.key, required this.auctionId});

  @override
  State<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends State<AuctionDetailsScreen> {
  final AuctionsController _auctionsController = Get.find<AuctionsController>();
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadAuctionDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAuctionDetails() async {
    await AuctionsHelper.loadAuctionDetails(auctionId: widget.auctionId);
  }

  String _formatTimeLeft(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Auction Ended';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_auctionsController.isLoadingDetails.value) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final auction = _auctionsController.selectedAuction.value;
      if (auction == null) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textColor),
              onPressed: () => Get.back(),
            ),
          ),
          body: Center(
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
                  'Auction Not Found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The auction you\'re looking for doesn\'t exist or has been removed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.subtextColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      }

      final dateFormat = DateFormat('MMM dd, yyyy');
      final timeFormat = DateFormat('h:mm a');

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Auction Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // Share functionality
                      },
                      icon: const Icon(Icons.share_outlined),
                      color: AppColors.textColor,
                    ),
                    IconButton(
                      onPressed: () {
                        // Bookmark functionality
                      },
                      icon: const Icon(Icons.bookmark_border_outlined),
                      color: AppColors.textColor,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Carousel
                      SizedBox(
                        height: 280,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: auction.asset.attachments.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final attachment =
                                    auction.asset.attachments[index];
                                return Container(
                                  decoration: attachment.url.isNotEmpty
                                      ? BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(attachment.url),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : BoxDecoration(
                                          color: RealTimeColors.grey200,
                                        ),
                                  child: attachment.url.isEmpty
                                      ? Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 64,
                                            color: RealTimeColors.grey400,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),

                            // Status Badge
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AuctionsHelper.getStatusColor(
                                    auction.status,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  AuctionsHelper.getStatusText(auction.status),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            // Image Indicators
                            if (auction.asset.attachments.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    auction.asset.attachments.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Auction Summary Section
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Auction Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        auction.asset.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        auction.auctionNo,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    AuctionsHelper.getAuctionTypeText(
                                      auction.type,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Live Auction Timer (if live)
                            if (auction.status == AuctionStatus.live)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: RealTimeColors.success.withOpacity(
                                    0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: RealTimeColors.success.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Time Left',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTimeLeft(auction.endDate),
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: RealTimeColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Current Bid',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${(auction.winningBidAmount ?? auction.startingBid).toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Auction Details Grid
                            Column(
                              children: [
                                // First Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDetailItem(
                                        icon: Icons.gavel_outlined,
                                        label: 'Starting Bid',
                                        value:
                                            '\$${auction.startingBid.toStringAsFixed(0)}',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDetailItem(
                                        icon: Icons.flag_outlined,
                                        label: 'Reserve Price',
                                        value: auction.reservePrice != null
                                            ? '\$${auction.reservePrice!.toStringAsFixed(0)}'
                                            : 'Not set',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Second Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDetailItem(
                                        icon:
                                            Icons.format_list_numbered_outlined,
                                        label: 'Bids',
                                        value: '${auction.bidCount ?? 0} bids',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 16,
                                                  color: AppColors.subtextColor,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Ends',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.subtextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dateFormat.format(
                                                    auction.endDate,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  timeFormat.format(
                                                    auction.endDate,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Asset Details Section
                            Text(
                              'Asset Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Asset Details List
                            Column(
                              children: [
                                _buildAssetDetailItem(
                                  label: 'Category',
                                  value: AuctionsHelper.getCategoryDisplayText(
                                    auction.asset.category,
                                  ),
                                ),
                                const Divider(height: 24),
                                _buildAssetDetailItem(
                                  label: 'Condition',
                                  value: auction.asset.condition,
                                ),
                                const Divider(height: 24),
                                _buildAssetDetailItem(
                                  label: 'Evaluated Value',
                                  value:
                                      '\$${auction.asset.evaluatedValue.toStringAsFixed(0)}',
                                ),
                                const Divider(height: 24),
                                _buildAssetDetailItem(
                                  label: 'Storage Location',
                                  value: auction.asset.storageLocation,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Description
                            Text(
                              auction.asset.description,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.subtextColor,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Recent Bids Section (for live auctions)
                            if (auction.status == AuctionStatus.live)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Activity',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Bids',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.subtextColor,
                                              ),
                                            ),
                                            Text(
                                              '${auction.bidCount ?? 0}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Highest Bid',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: AppColors.subtextColor,
                                              ),
                                            ),
                                            Text(
                                              '\$${(auction.winningBidAmount ?? auction.startingBid).toStringAsFixed(0)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            // Winning Bid (for closed auctions)
                            if (auction.status == AuctionStatus.closed &&
                                auction.winningBidAmount != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: RealTimeColors.error.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: RealTimeColors.error.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Winning Bid',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                        Text(
                                          '\$${auction.winningBidAmount!.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: RealTimeColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RealTimeColors.error,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'SOLD',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Action Bar
              if (auction.status == AuctionStatus.live)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    border: Border(
                      top: BorderSide(color: AppColors.borderColor),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Place Bid action - Will be implemented separately
                        Get.snackbar(
                          'Coming Soon',
                          'Bid placement feature will be available soon',
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
                        elevation: 2,
                      ),
                      child: Text(
                        'Place Bid',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 16, color: AppColors.subtextColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetDetailItem({required String label, required String value}) {
    return Row(
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
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
