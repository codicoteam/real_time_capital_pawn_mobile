import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/auctions_mngmt_helper.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/bid_placement_dialog.dart';
import 'package:real_time_pawn/features/auctions_mngmt/helpers/user_bid_history_helper.dart';
import 'package:real_time_pawn/models/auction_models.dart';
import 'package:shimmer/shimmer.dart';

class LiveAuctionsScreen extends StatefulWidget {
  const LiveAuctionsScreen({super.key});

  @override
  State<LiveAuctionsScreen> createState() => _LiveAuctionsScreenState();
}

class _LiveAuctionsScreenState extends State<LiveAuctionsScreen>
    with SingleTickerProviderStateMixin {
  final AuctionsController _auctionsController = Get.find<AuctionsController>();

  final List<String> _categories = ['All', 'Electronics', 'Vehicle', 'Jewellery'];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _loadLiveAuctions();

    // Rebuild every second so countdown timers stay live
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _animController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadLiveAuctions() async {
    _animController.reset();
    await AuctionsHelper.loadLiveAuctions(
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      showLoader: true,
    );
    if (mounted) _animController.forward();
  }

  Future<void> _refreshAuctions() async {
    await AuctionsHelper.loadLiveAuctions(
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      showLoader: false,
    );
    if (mounted) setState(() {});
  }

  List<Auction> get _filteredAuctions {
    final all = _auctionsController.liveAuctions;
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where((a) =>
            a.asset.title.toLowerCase().contains(q) ||
            a.auctionNo.toLowerCase().contains(q))
        .toList();
  }

  String _formatCountdown(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _countdownColor(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return RealTimeColors.error;
    if (diff.inMinutes < 10) return RealTimeColors.error;
    if (diff.inHours < 1) return RealTimeColors.warning;
    return RealTimeColors.success;
  }

  void _showBidDialog(Auction auction) {
    final currentBid = auction.winningBidAmount ?? auction.startingBid;
    Get.dialog(
      BidPlacementDialog(
        auctionTitle: auction.asset.title,
        currentBid: currentBid,
        reservePrice: auction.reservePrice,
        startingBid: auction.startingBid,
        onPlaceBid: (amount) async {
          Get.back();
          Get.dialog(
            const CustomLoader(message: 'Placing your bid...'),
            barrierDismissible: false,
          );
          final success = await _auctionsController.placeBidRequest(
            auctionId: auction.id,
            amount: amount,
          );
          Get.back();
          if (success) {
            Get.snackbar(
              'Bid Placed!',
              'Your bid of \$${amount.toStringAsFixed(2)} was placed successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: RealTimeColors.success,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            await _refreshAuctions();
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Auctions',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Obx(() {
                  final count = _auctionsController.liveAuctions.length;
                  return Text(
                    count == 0 ? 'No auctions live' : '$count live now',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: count > 0 ? RealTimeColors.success : AppColors.subtextColor,
                      fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }),
              ],
            ),
          ),
          // Live indicator dot
          Obx(() {
            if (_auctionsController.liveAuctions.isEmpty) return const SizedBox.shrink();
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 4),
              decoration: const BoxDecoration(
                color: RealTimeColors.success,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scaleXY(end: 1.4, duration: 800.ms, curve: Curves.easeInOut)
                .then()
                .scaleXY(end: 1.0, duration: 800.ms, curve: Curves.easeInOut);
          }),
          IconButton(
            onPressed: () => Get.toNamed(RoutesHelper.userBiddingHistoryScreen),
            icon: const Icon(Icons.history_outlined),
            color: AppColors.textColor,
            tooltip: 'My Bid History',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search auctions...',
            hintStyle: GoogleFonts.poppins(color: AppColors.subtextColor, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.subtextColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.subtextColor),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.poppins(color: AppColors.textColor),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: selected,
              onSelected: (v) async {
                setState(() => _selectedCategory = v ? cat : 'All');
                await _loadLiveAuctions();
              },
              backgroundColor: AppColors.surfaceColor,
              selectedColor: AppColors.primaryColor.withValues(alpha: 0.12),
              labelStyle: GoogleFonts.poppins(
                color: selected ? AppColors.primaryColor : AppColors.subtextColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? AppColors.primaryColor : AppColors.borderColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_auctionsController.isLoadingLive.value) {
        return _buildShimmerList();
      }

      final auctions = _filteredAuctions;

      if (auctions.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshAuctions,
        color: AppColors.primaryColor,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: auctions.length,
              itemBuilder: (_, i) => _buildAuctionCard(auctions[i], i),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAuctionCard(Auction auction, int index) {
    final isLive = auction.status == AuctionStatus.live;
    final currentBid = auction.winningBidAmount ?? auction.startingBid;
    final hasImage = auction.asset.attachments.isNotEmpty;
    final imageUrl = hasImage ? auction.asset.attachments.first.url : null;
    final countdown = _formatCountdown(auction.endDate);
    final countdownColor = _countdownColor(auction.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => AuctionsHelper.navigateToAuctionDetails(
          auctionId: auction.id,
          context: context,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => _shimmerBox(double.infinity, 200),
                            errorWidget: (ctx, url, err) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),

                    // Gradient overlay
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
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // LIVE badge top-left
                    if (isLive)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _liveBadge(),
                      ),

                    // Category badge top-right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AuctionsHelper.getCategoryDisplayText(auction.asset.category)
                              .toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Countdown bottom-left
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            countdown,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bid count bottom-right
                    if (auction.bidCount != null && auction.bidCount! > 0)
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Row(
                          children: [
                            const Icon(Icons.gavel_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${auction.bidCount} bids',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + auction no
                  Text(
                    auction.asset.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    auction.auctionNo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bid info row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Bid',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            Text(
                              '\$${currentBid.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting Bid',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.subtextColor,
                              ),
                            ),
                            Text(
                              '\$${auction.startingBid.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Countdown pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: countdownColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: countdownColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 12, color: countdownColor),
                            const SizedBox(width: 4),
                            Text(
                              countdown,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: countdownColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (isLive) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showBidDialog(auction),
                        icon: const Icon(Icons.gavel_rounded, size: 18),
                        label: Text(
                          'Place Bid Now',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 350.ms)
        .slideY(begin: 0.06, end: 0, delay: (index * 60).ms, duration: 350.ms, curve: Curves.easeOut);
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: RealTimeColors.success,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: RealTimeColors.success.withValues(alpha: 0.4), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(end: 1.5, duration: 600.ms)
              .then()
              .scaleXY(end: 1.0, duration: 600.ms),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surfaceColor,
      child: Center(
        child: Icon(Icons.image_outlined, size: 56, color: RealTimeColors.grey400),
      ),
    );
  }

  Widget _shimmerBox(double w, double h) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(width: w, height: h, color: Colors.white),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 4,
      itemBuilder: (ctx, i) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, color: Colors.white, width: 200),
                    const SizedBox(height: 8),
                    Container(height: 12, color: Colors.white, width: 120),
                    const SizedBox(height: 12),
                    Container(height: 40, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _refreshAuctions,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel_outlined, size: 72, color: RealTimeColors.grey400)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scaleXY(begin: 0.7, end: 1.0, duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty ? 'No results found' : 'No Live Auctions',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Check back later — auctions go live soon',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.subtextColor,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),
                if (_searchQuery.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _searchController.clear(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Search'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _refreshAuctions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
