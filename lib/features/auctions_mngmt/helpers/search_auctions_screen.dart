// search_auctions_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/models/auction_models.dart';

class SearchAuctionsScreen extends StatefulWidget {
  const SearchAuctionsScreen({super.key});

  @override
  State<SearchAuctionsScreen> createState() => _SearchAuctionsScreenState();
}

class _SearchAuctionsScreenState extends State<SearchAuctionsScreen> {
  final AuctionsController _auctionsController = Get.find<AuctionsController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  String _selectedStatus = 'All';
  final List<String> _statusFilters = [
    'All',
    'Live',
    'Upcoming',
    'Past',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length >= 2) {
        _performSearch();
      } else if (_searchController.text.isEmpty) {
        _auctionsController.clearSearchResults();
      }
    });
  }

  Future<void> _performSearch() async {
    if (_searchController.text.length < 2) {
      Get.snackbar(
        'Search Error',
        'Please enter at least 2 characters',
        snackPosition: SnackPosition.TOP,
        backgroundColor: RealTimeColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _auctionsController.searchAuctionsRequest(
      query: _searchController.text,
      status: _selectedStatus != 'All' ? _selectedStatus : null,
    );

    if (!success) {
      Get.snackbar(
        'Search Failed',
        _auctionsController.errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: RealTimeColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Back Button and Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.textColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search Auctions',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
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
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText:
                            'Search by title, description, auction number...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.subtextColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.subtextColor,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _auctionsController.clearSearchResults();
                                },
                                icon: const Icon(Icons.clear),
                                color: AppColors.subtextColor,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: GoogleFonts.poppins(color: AppColors.textColor),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.length >= 2) {
                          _performSearch();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Status Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statusFilters.length,
                      itemBuilder: (context, index) {
                        final status = _statusFilters[index];
                        final isSelected = _selectedStatus == status;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : 'All';
                              });
                              if (_searchController.text.length >= 2) {
                                _performSearch();
                              }
                            },
                            backgroundColor: AppColors.surfaceColor,
                            selectedColor: AppColors.primaryColor.withOpacity(
                              0.1,
                            ),
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
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: Obx(() {
                if (_auctionsController.isLoadingSearch.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_outlined,
                          size: 64,
                          color: RealTimeColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start Searching',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter at least 2 characters to search auctions',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: RealTimeColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_searchController.text.length < 2) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: RealTimeColors.warning,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search Too Short',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter at least 2 characters',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: RealTimeColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final results = _auctionsController.searchResults;

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 64,
                          color: RealTimeColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Results Found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term or adjust filters',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: RealTimeColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final auction = results[index];
                    return _buildSearchResultCard(auction);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Auction auction) {
    return GestureDetector(
      onTap: () {
        AuctionsHelper.navigateToAuctionDetails(
          auctionId: auction.id,
          context: context,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auction Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                          size: 32,
                          color: RealTimeColors.grey400,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Auction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      auction.asset.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
                        fontSize: 12,
                        color: AppColors.subtextColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Status and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AuctionsHelper.getStatusColor(
                              auction.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AuctionsHelper.getStatusText(auction.status),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AuctionsHelper.getStatusColor(
                                auction.status,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '\$${auction.startingBid.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
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
        ),
      ),
    );
  }
}
