import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/bid_placement_dialog.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/user_bid_history_helper.dart';

import 'package:real_time_pawn/models/auction_models.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';

class AuctionsListScreen extends StatefulWidget {
  const AuctionsListScreen({super.key});

  @override
  State<AuctionsListScreen> createState() => _AuctionsListScreenState();
}

class _AuctionsListScreenState extends State<AuctionsListScreen> {
  final auctionsController = Get.put(AuctionsController());
  final List<String> _categories = [
    'All',
    'Electronics',
    'Vehicle',
    'Jewellery',
    'Art',
    'Real Estate',
  ];
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final List<String> _statusFilters = [
    'All',
    'Live',
    'Upcoming',
    'Past',
    'Draft',
  ];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _loadInitialAuctions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAuctions() async {
    await AuctionsHelper.loadAuctions(
      status: _selectedStatus != 'All' ? _selectedStatus : null,
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text.toLowerCase();
    if (newQuery != _searchQuery) {
      _searchQuery = newQuery;
      _refreshAuctions();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreAuctions();
    }
  }

  Future<void> _refreshAuctions() async {
    await AuctionsHelper.loadAuctions(
      status: _selectedStatus != 'All' ? _selectedStatus : null,
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      showLoader: false,
    );
  }

  Future<void> _loadMoreAuctions() async {
    if (_isLoadingMore ||
        auctionsController.currentPage.value >=
            auctionsController.pagination.value.pages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await auctionsController.loadMoreAuctions(
      status: _selectedStatus != 'All' ? _selectedStatus : null,
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _showBidDialog(Auction auction) {
    final currentBidAmount = auction.winningBidAmount ?? auction.startingBid;

    Get.dialog(
      BidPlacementDialog(
        auctionTitle: auction.asset.title,
        currentBid: currentBidAmount,
        reservePrice: auction.reservePrice,
        startingBid: auction.startingBid,
        onPlaceBid: (amount) async {
          // Close dialog
          Get.back();

          // Show loading
          Get.dialog(
            const CustomLoader(message: 'Placing your bid...'),
            barrierDismissible: false,
          );

          // Place the bid
          final success = await auctionsController.placeBidRequest(
            auctionId: auction.id,
            amount: amount,
          );

          // Close loading
          Get.back();

          if (success) {
            // Show success message
            Get.snackbar(
              'Bid Placed!',
              'Your bid of \$${amount.toStringAsFixed(2)} has been placed successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: RealTimeColors.success,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );

            // Refresh auctions
            await _refreshAuctions();
          } else {
            // Show error
            Get.snackbar(
              'Bid Failed',
              auctionsController.errorMessage.value,
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
                  Text(
                    'Auctions',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search auctions...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.subtextColor,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.subtextColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: GoogleFonts.poppins(color: AppColors.textColor),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        AuctionsHelper.navigateToSearchScreen(context);
                      },
                      icon: const Icon(Icons.tune),
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            // Status Filter Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: _statusFilters.length,
                itemBuilder: (context, index) {
                  final status = _statusFilters[index];
                  final isSelected = _selectedStatus == status;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : 'All';
                        });
                        _refreshAuctions();
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

            // Category Filter and Sort Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                              _refreshAuctions();
                            },
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.subtextColor,
                            ),
                            isExpanded: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Auctions List
            Expanded(
              child: Obx(() {
                if (auctionsController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final auctions = auctionsController.auctionsList;

                if (auctions.isEmpty) {
                  return Center(
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
                          'No Auctions Found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: RealTimeColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshAuctions,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: auctions.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= auctions.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }

                      final auction = auctions[index];
                      return _buildAuctionCard(auction);
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

  Widget _buildAuctionCard(Auction auction) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: () {
        AuctionsHelper.navigateToAuctionDetails(
          auctionId: auction.id,
          context: context,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Auction Image
            Container(
              height: 180,
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
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // Auction Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Auction Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          auction.asset.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        auction.auctionNo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Category and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AuctionsHelper.getCategoryDisplayText(
                            auction.asset.category,
                          ).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Text(
                        '\$${auction.startingBid.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Auction Type and Dates
                  Row(
                    children: [
                      Icon(
                        auction.type == AuctionType.in_person
                            ? Icons.location_on_outlined
                            : Icons.computer_outlined,
                        size: 16,
                        color: AppColors.subtextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AuctionsHelper.getAuctionTypeText(auction.type),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.subtextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(auction.startDate)} - ${dateFormat.format(auction.endDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  ),

                  // Live Auction Specific Info
                  if (auction.status == AuctionStatus.live)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RealTimeColors.success.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: RealTimeColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Bid',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                              Text(
                                '\$${(auction.winningBidAmount ?? auction.startingBid).toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: RealTimeColors.success,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Bids',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.subtextColor,
                                ),
                              ),
                              Text(
                                '${auction.bidCount ?? 0} bids',
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

                  // Bid Now Button for Live Auctions
                  if (auction.status == AuctionStatus.live)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: double.infinity,
                      child: GeneralButton(
                        onTap: () {
                          _showBidDialog(auction);
                        },
                        btnColor: AppColors.primaryColor,
                        child: Text(
                          'Bid Now',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
