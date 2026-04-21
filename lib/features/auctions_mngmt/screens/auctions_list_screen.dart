import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';

import 'package:real_time_pawn/models/auction_list_model.dart';

import '../../../widgets/cards/auction_list_card.dart';
import '../helpers/filter_auction_helper.dart';

class AuctionsListScreen extends StatefulWidget {
  const AuctionsListScreen({Key? key}) : super(key: key);

  @override
  State<AuctionsListScreen> createState() => _AuctionsListScreenState();
}

class _AuctionsListScreenState extends State<AuctionsListScreen>
    with SingleTickerProviderStateMixin {
  final auctionsController = Get.find<AuctionsController>();

  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _categories = ['All'];
  Map<String, int> _statusCounts = {};
  List<AuctionListModel> _filteredAuctions = [];
  bool _isLoadingMore = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _setupAnimations();
    _loadInitialAuctions();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAuctions() async {
    if (!mounted) return;
    await auctionsController.getAuctionsRequest();
    if (!mounted) return;
    _updateFiltersAndCategories();
  }

  void _updateFiltersAndCategories() {
    if (!mounted) return;
    final allAuctions = auctionsController.auctionsList;
    _categories = AuctionFilters.getAvailableCategories(allAuctions);
    _statusCounts = AuctionFilters.getStatusCounts(allAuctions);
    _applyFilters();
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredAuctions = AuctionFilters.filterAuctions(
        auctions: auctionsController.auctionsList,
        status: _selectedStatus != 'All' ? _selectedStatus : null,
        category: _selectedCategory != 'All' ? _selectedCategory : null,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    });
  }

  void _onSearchChanged() {
    _searchQuery = _searchController.text;
    _applyFilters();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreAuctions();
    }
  }

  Future<void> _loadMoreAuctions() async {
    if (!mounted) return;
    if (_isLoadingMore ||
        auctionsController.currentPage.value >=
            auctionsController.pagination.value.pages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    await auctionsController.loadMoreAuctions();

    if (!mounted) return;
    setState(() {
      _isLoadingMore = false;
      _applyFilters();
    });
  }

  Future<void> _refreshAuctions() async {
    if (!mounted) return;
    await auctionsController.getAuctionsRequest(page: 1);
    if (!mounted) return;
    _updateFiltersAndCategories();
  }

  void _goBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Back Button
                _buildHeader(),

                // Search Bar
                _buildSearchBar(),

                // Status Filter Chips
                _buildStatusFilters(),

                // Category Filter
                _buildCategoryFilter(),

                // Auctions List
                Expanded(
                  child: Obx(() {
                    if (auctionsController.isLoading.value &&
                        auctionsController.auctionsList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_filteredAuctions.isEmpty &&
                        auctionsController.auctionsList.isNotEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshAuctions,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount:
                            _filteredAuctions.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _filteredAuctions.length) {
                            return _buildLoadingMoreIndicator();
                          }
                          final auction = _filteredAuctions[index];
                          return _buildAnimatedCard(index, auction);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(int index, AuctionListModel auction) {
    // Only apply animations if the animation controller is still active
    if (!_animationController.isCompleted && mounted) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index /
                      (_filteredAuctions.length > 0
                          ? _filteredAuctions.length
                          : 1),
                  1.0,
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index /
                    (_filteredAuctions.length > 0
                        ? _filteredAuctions.length
                        : 1),
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: AuctionListCard(
            auction: auction,
            onTap: () {
              AuctionsHelper.navigateToAuctionDetails(
                auctionId: auction.id!,
                context: context,
              );
            },
            onBidNow: () {
              _refreshAuctions();
            },
          ),
        ),
      );
    }

    // Return without animations if controller is completed or widget is not mounted
    return AuctionListCard(
      auction: auction,
      onTap: () {
        AuctionsHelper.navigateToAuctionDetails(
          auctionId: auction.id!,
          context: context,
        );
      },
      onBidNow: () {
        _refreshAuctions();
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button with animation
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _goBack,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Auctions',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          // Filter count badge and history button
          if (_selectedStatus != 'All' || _selectedCategory != 'All')
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_filteredAuctions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              Get.toNamed(RoutesHelper.userBiddingHistoryScreen);
            },
            icon: const Icon(Icons.history_outlined),
            color: AppColors.textColor,
            tooltip: 'Bidding History',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by title or auction number...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.subtextColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.subtextColor),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: GoogleFonts.poppins(color: AppColors.textColor),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Obx(() {
      if (auctionsController.auctionsList.isNotEmpty) {
        _statusCounts = AuctionFilters.getStatusCounts(
          auctionsController.auctionsList,
        );
      }

      return SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          itemCount: _statusCounts.keys.length,
          itemBuilder: (context, index) {
            final status = _statusCounts.keys.elementAt(index);
            final count = _statusCounts[status]!;
            final isSelected = _selectedStatus == status;
            final isDisabled = count == 0 && status != 'All';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('$status ($count)'),
                selected: isSelected,
                onSelected: isDisabled
                    ? null
                    : (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : 'All';
                        });
                        _applyFilters();
                      },
                backgroundColor: AppColors.surfaceColor,
                selectedColor: AppColors.primaryColor.withOpacity(0.1),
                disabledColor: AppColors.surfaceColor.withOpacity(0.5),
                labelStyle: GoogleFonts.poppins(
                  color: isDisabled
                      ? AppColors.subtextColor.withOpacity(0.5)
                      : isSelected
                      ? AppColors.primaryColor
                      : AppColors.subtextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryColor
                        : isDisabled
                        ? AppColors.borderColor.withOpacity(0.3)
                        : AppColors.borderColor,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                _applyFilters();
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
              dropdownColor: AppColors.surfaceColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 64,
            color: RealTimeColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No matching auctions found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search query',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: RealTimeColors.grey500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedStatus = 'All';
                _selectedCategory = 'All';
                _searchController.clear();
                _searchQuery = '';
              });
              _applyFilters();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
