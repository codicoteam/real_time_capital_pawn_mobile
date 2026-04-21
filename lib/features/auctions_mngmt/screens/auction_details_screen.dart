import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/auction_bids_screen.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/bid_placement_dialog.dart';
import 'package:real_time_pawn/models/auction_detail_response.dart';

import '../../../widgets/custom_button/general_button.dart';

class AuctionDetailsScreen extends StatefulWidget {
  final String auctionId;

  const AuctionDetailsScreen({super.key, required this.auctionId});

  @override
  State<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends State<AuctionDetailsScreen> {
  final AuctionsController _auctionsController = Get.find<AuctionsController>();
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _loadAuctionDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAuctionDetails() async {
    await _auctionsController.getAuctionDetailsRequest(
      auctionId: widget.auctionId,
    );
  }

  String _formatTimeLeft(DateTime? endDate) {
    if (endDate == null) return 'No end date';

    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Auction Ended';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'Ending soon';
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
        return 'LIVE';
      case 'draft':
        return 'DRAFT';
      case 'closed':
        return 'CLOSED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status?.toUpperCase() ?? 'UNKNOWN';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
        return RealTimeColors.success;
      case 'draft':
        return RealTimeColors.warning;
      case 'closed':
        return RealTimeColors.warning;
      case 'cancelled':
        return RealTimeColors.error;
      default:
        return RealTimeColors.grey500;
    }
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return r'$0';
    final formatter = NumberFormat('#,###');
    return '\$${formatter.format(amount)}';
  }

  bool get isLive =>
      _auctionsController.selectedAuction.value?.status?.toLowerCase() ==
      'live';
  bool get isClosed =>
      _auctionsController.selectedAuction.value?.status?.toLowerCase() ==
      'closed';
  bool get isDraft =>
      _auctionsController.selectedAuction.value?.status?.toLowerCase() ==
      'draft';

  void _showBidDialog(Auction auction, CurrentBid? currentBid) {
    final currentBidAmount =
        currentBid?.amount?.toDouble() ??
        auction.startingBidAmount?.toDouble() ??
        0;

    Get.dialog(
      BidPlacementDialog(
        auctionTitle: auction.asset?.title ?? 'Auction',
        currentBid: currentBidAmount,
        reservePrice: (auction.reservePrice ?? 0)
            .toDouble(), // Convert int to double
        startingBid: (auction.startingBidAmount ?? 0)
            .toDouble(), // Convert int to double
        onPlaceBid: (amount) async {
          Get.back();

          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          final success = await _auctionsController.placeBidRequest(
            auctionId: auction.id!,
            amount: amount.toDouble(),
          );

          Get.back();

          if (success) {
            Get.snackbar(
              'Bid Placed!',
              'Your bid of ${_formatCurrency(amount.toInt())} has been placed successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: RealTimeColors.success,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            await _loadAuctionDetails();
          } else {
            Get.snackbar(
              'Bid Failed',
              _auctionsController.errorMessage.value,
              snackPosition: SnackPosition.TOP,
              backgroundColor: RealTimeColors.error,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        },
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_auctionsController.isLoadingDetails.value) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading auction details...',
                  style: GoogleFonts.poppins(color: AppColors.subtextColor),
                ),
              ],
            ),
          ),
        );
      }

      final auction = _auctionsController.selectedAuction.value;
      final currentBid = _auctionsController.currentBid.value;

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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
      final assetImages = auction.asset?.assetImages ?? [];

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Carousel
                      _buildImageCarousel(assetImages),

                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Auction Header
                            _buildAuctionHeader(auction),

                            const SizedBox(height: 20),

                            // Live Auction Timer and Current Bid
                            if (isLive)
                              _buildLiveAuctionSection(auction, currentBid),

                            if (isLive) const SizedBox(height: 20),

                            // Bid Statistics
                            _buildBidStatistics(auction, currentBid),

                            const SizedBox(height: 24),

                            // Auction Details Grid
                            _buildAuctionDetailsGrid(
                              auction,
                              dateFormat,
                              timeFormat,
                            ),

                            const SizedBox(height: 24),

                            // Asset Details Section
                            _buildAssetDetailsSection(auction),

                            const SizedBox(height: 16),

                            // Description
                            if (auction.asset?.description != null &&
                                auction.asset!.description!.isNotEmpty)
                              _buildDescription(auction.asset!.description!),

                            const SizedBox(height: 80), // Space for bottom bar
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Action Bar
              if (!isDraft) _buildBottomActionBar(auction, currentBid),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.textColor,
            iconSize: 20,
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
              Get.to(
                () => AuctionBidsScreen(
                  auctionId: widget.auctionId,
                  auctionTitle:
                      _auctionsController.selectedAuction.value?.asset?.title ??
                      'Auction',
                ),
              );
            },
            icon: const Icon(Icons.list_alt_outlined),
            color: AppColors.textColor,
            tooltip: 'View All Bids',
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: RealTimeColors.grey200,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 64,
                color: RealTimeColors.grey400,
              ),
              const SizedBox(height: 8),
              Text(
                'No Images Available',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: RealTimeColors.grey500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 320,
            autoPlay: isLive,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            enableInfiniteScroll: imageUrls.length > 1,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: RealTimeColors.grey200,
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
              ),
            ),
          ),
        ),

        // Status Badge
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(
                _auctionsController.selectedAuction.value?.status,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _getStatusText(_auctionsController.selectedAuction.value?.status),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Image Indicators
        if (imageUrls.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImageIndex == index
                        ? AppColors.primaryColor
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAuctionHeader(Auction auction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                auction.asset?.title ?? 'Untitled',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                auction.auctionType?.toUpperCase() ?? 'ONLINE',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.tag_outlined, size: 14, color: AppColors.subtextColor),
            const SizedBox(width: 4),
            Text(
              auction.auctionNo ?? 'No Number',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveAuctionSection(Auction auction, CurrentBid? currentBid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RealTimeColors.success.withOpacity(0.15),
            RealTimeColors.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RealTimeColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Remaining',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 20,
                      color: RealTimeColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeLeft(auction.endsAt),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: RealTimeColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                  _formatCurrency(
                    currentBid?.amount ?? auction.startingBidAmount,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                if (currentBid?.bidderUser != null)
                  Text(
                    'by ${currentBid!.bidderUser!.email?.split('@').first ?? 'Bidder'}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.subtextColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidStatistics(Auction auction, CurrentBid? currentBid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.gavel_outlined,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Starting Bid',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(auction.startingBidAmount),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderColor),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reserve Price',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(auction.reservePrice),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.borderColor),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Bids',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentBid != null ? 1 : 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionDetailsGrid(
    Auction auction,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auction Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'Start Date',
              value: auction.startsAt != null
                  ? '${dateFormat.format(auction.startsAt!)}\n${timeFormat.format(auction.startsAt!)}'
                  : 'Not set',
            ),
            _buildInfoCard(
              icon: Icons.event_busy_outlined,
              label: 'End Date',
              value: auction.endsAt != null
                  ? '${dateFormat.format(auction.endsAt!)}\n${timeFormat.format(auction.endsAt!)}'
                  : 'Not set',
            ),
            _buildInfoCard(
              icon: Icons.person_outline,
              label: 'Created By',
              value: auction.createdBy?.email?.split('@').first ?? 'Admin',
            ),
            _buildInfoCard(
              icon: Icons.access_time_outlined,
              label: 'Created At',
              value: auction.createdAt != null
                  ? dateFormat.format(auction.createdAt!)
                  : 'Unknown',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetDetailsSection(Auction auction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Information',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              _buildAssetDetailRow(
                label: 'Asset Number',
                value: auction.asset?.assetNo ?? 'N/A',
              ),
              const Divider(height: 24),
              _buildAssetDetailRow(
                label: 'Category',
                value: _formatCategory(auction.asset?.category),
              ),
              const Divider(height: 24),
              _buildAssetDetailRow(
                label: 'Condition',
                value: _formatCondition(auction.asset?.condition),
              ),
              const Divider(height: 24),
              _buildAssetDetailRow(
                label: 'Evaluated Value',
                value: _formatCurrency(auction.asset?.evaluatedValue),
              ),
              const Divider(height: 24),
              _buildAssetDetailRow(
                label: 'Storage Location',
                value: _formatStorageLocation(auction.asset?.storageLocation),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetDetailRow({required String label, required String value}) {
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
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(Auction auction, CurrentBid? currentBid) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: isLive
          ? SizedBox(
              width: double.infinity,
              child: GeneralButton(
                onTap: () => _showBidDialog(auction, currentBid),
                btnColor: AppColors.primaryColor,
                child: Text(
                  'Place Bid - ${_formatCurrency(currentBid?.amount ?? auction.startingBidAmount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : isClosed
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RealTimeColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: RealTimeColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This auction has ended. No more bids can be placed.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: RealTimeColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  String _formatCategory(String? category) {
    if (category == null) return 'General';
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatCondition(String? condition) {
    if (condition == null) return 'Not specified';
    return condition[0].toUpperCase() + condition.substring(1);
  }

  String _formatStorageLocation(String? location) {
    if (location == null) return 'Not specified';
    return location
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
