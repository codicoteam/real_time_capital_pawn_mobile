import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/models/auction_models.dart';

class LiveAuctionsScreen extends StatefulWidget {
  const LiveAuctionsScreen({super.key});

  @override
  State<LiveAuctionsScreen> createState() => _LiveAuctionsScreenState();
}

class _LiveAuctionsScreenState extends State<LiveAuctionsScreen> {
  final AuctionsController _auctionsController = Get.find<AuctionsController>();
  final List<String> _categories = [
    'All',
    'Electronics',
    'Vehicle',
    'Jewellery',
  ];
  String _selectedCategory = 'All';
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadLiveAuctions();
  }

  Future<void> _loadLiveAuctions() async {
    await AuctionsHelper.loadLiveAuctions(
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      showLoader: true,
    );
  }

  Future<void> _refreshAuctions() async {
    await AuctionsHelper.loadLiveAuctions(
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      showLoader: false,
    );
  }

  String _formatCountdown(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Ended';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Auctions',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        final liveCount =
                            _auctionsController.liveAuctions.length;
                        return Text(
                          '$liveCount auctions live now',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.subtextColor,
                          ),
                        );
                      }),
                    ],
                  ),
                  // Add a search button here if you want
                  // Add history icon here too
                  IconButton(
                    onPressed: () {
                      Get.toNamed(RoutesHelper.userBiddingHistoryScreen);
                    },
                    icon: const Icon(Icons.history_outlined),
                    color: AppColors.textColor,
                    tooltip: 'View My Bidding History',
                  ),
                ],
              ),
            ),

            // Category Filter
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) async {
                        setState(() {
                          _selectedCategory = selected ? category : 'All';
                        });
                        await _loadLiveAuctions();
                      },
                      backgroundColor: AppColors.surfaceColor,
                      selectedColor: AppColors.primaryColor.withOpacity(0.1),
                      labelStyle: GoogleFonts.poppins(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.subtextColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Live Auctions Grid
            Expanded(
              child: Obx(() {
                if (_auctionsController.isLoadingLive.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final liveAuctions = _auctionsController.liveAuctions;

                if (liveAuctions.isEmpty) {
                  return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshAuctions,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gavel_outlined,
                                size: 64,
                                color: RealTimeColors.grey400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Live Auctions',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check back later for new auctions',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: RealTimeColors.grey500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _refreshAuctions,
                                child: Text(
                                  'Refresh',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refreshAuctions,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: liveAuctions.length,
                    itemBuilder: (context, index) {
                      return _buildLiveAuctionCard(liveAuctions[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAuctionCard(Auction auction) {
    // In _buildLiveAuctionCard method of LiveAuctionsScreen, make the whole card tappable
    // and add bid placement capability:

    return GestureDetector(
      onTap: () {
        // Show bid placement dialog for live auctions
        if (auction.status == AuctionStatus.live) {
          Get.dialog(
            BidPlacementDialog(
              auction: auction,
              currentBidAmount: auction.winningBidAmount ?? auction.startingBid,
              onBidPlaced: (newAmount) {
                // Refresh live auctions
                _refreshAuctions();
              },
            ),
            barrierDismissible: true,
          );
        } else {
          AuctionsHelper.navigateToAuctionDetails(
            auctionId: auction.id,
            context: context,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Auction Image with Live Badge
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: RealTimeColors.grey200,
                  image: auction.asset.attachments.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            auction.asset.attachments.first.url,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: auction.asset.attachments.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: RealTimeColors.grey400,
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: RealTimeColors.success,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Auction Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    auction.asset.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Auction Number
                  Text(
                    auction.auctionNo,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.subtextColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AuctionsHelper.getCategoryDisplayText(
                        auction.asset.category,
                      ).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Current Bid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: AppColors.subtextColor,
                            ),
                          ),
                          Text(
                            '\$${(auction.winningBidAmount ?? auction.startingBid).toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Start',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: AppColors.subtextColor,
                            ),
                          ),
                          Text(
                            '\$${auction.startingBid.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Countdown Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RealTimeColors.warning.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: RealTimeColors.warning.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: RealTimeColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCountdown(auction.endDate),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: RealTimeColors.warning,
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
    );
  }
}
