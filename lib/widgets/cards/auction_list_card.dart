import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/auctions_mngmt/screens/bid_placement_dialog.dart';
import 'package:real_time_pawn/features/auctions_mngmt/controllers/auctions_mngmt_controller.dart';
import 'package:real_time_pawn/models/auction_list_model.dart';
import 'package:real_time_pawn/widgets/custom_button/general_button.dart';

class AuctionListCard extends StatelessWidget {
  final AuctionListModel auction;
  final VoidCallback onTap;
  final VoidCallback? onBidNow;

  const AuctionListCard({
    Key? key,
    required this.auction,
    required this.onTap,
    this.onBidNow,
  });

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

  String _getAuctionTypeText(String? type) {
    return type?.toLowerCase() == 'live' ? 'Live Auction' : 'Online Auction';
  }

  String _getCategoryDisplayText(String? category) {
    if (category == null) return 'General';
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool get isLive => auction.status?.toLowerCase() == 'live';
  bool get isDraft => auction.status?.toLowerCase() == 'draft';
  bool get isClosed => auction.status?.toLowerCase() == 'closed';

  // FIX: Accept num? and convert safely to double
  String _formatCurrency(num? amount) {
    if (amount == null) return '\$0';
    return '\$${NumberFormat('#,###').format(amount.toDouble())}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('h:mm a').format(date);
  }

  bool _isAuctionEnded(DateTime? endsAt) {
    if (endsAt == null) return false;
    return endsAt.isBefore(DateTime.now());
  }

  Duration _getTimeRemaining(DateTime? endsAt) {
    if (endsAt == null) return Duration.zero;
    return endsAt.difference(DateTime.now());
  }

  String _getTimeRemainingText(DateTime? endsAt) {
    if (endsAt == null) return 'No end date';
    if (_isAuctionEnded(endsAt)) return 'Auction Ended';

    final remaining = _getTimeRemaining(endsAt);
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours.remainder(24)}h remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m remaining';
    } else {
      return 'Ending soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Carousel with fade+slide in
                _buildImageCarousel()
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(begin: -0.05, end: 0, duration: 400.ms),

                // Auction Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Status
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  auction.asset?.title ?? 'Untitled Auction',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Status badge with shimmer for live
                              _buildStatusBadge(),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 350.ms)
                          .slideX(begin: -0.04, end: 0, duration: 350.ms),

                      const SizedBox(height: 8),

                      Text(
                        auction.auctionNo ?? 'No Number',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                      const SizedBox(height: 12),

                      // Category and Price Row
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getCategoryDisplayText(
                                    auction.asset?.category,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Starting Bid',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: AppColors.subtextColor,
                                    ),
                                  ),
                                  // FIX: auction.startingBidAmount is int? — pass directly, _formatCurrency now accepts num?
                                  Text(
                                        _formatCurrency(
                                          auction.startingBidAmount,
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .shimmer(
                                        delay: 800.ms,
                                        duration: 1800.ms,
                                        color: AppColors.primaryColor
                                            .withValues(alpha: 0.3),
                                      ),
                                ],
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 350.ms)
                          .slideY(begin: 0.04, end: 0, duration: 350.ms),

                      const SizedBox(height: 12),

                      // Auction Type
                      Row(
                        children: [
                          Icon(
                            Icons.gavel_outlined,
                            size: 14,
                            color: AppColors.subtextColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getAuctionTypeText(auction.auctionType),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                      const SizedBox(height: 8),

                      // Date Range
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.subtextColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_formatDate(auction.startsAt)} - ${_formatDate(auction.endsAt)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.subtextColor,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 280.ms, duration: 300.ms),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: AppColors.subtextColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Starts: ${_formatTime(auction.startsAt)} | Ends: ${_formatTime(auction.endsAt)}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                      // Live Auction Info Section
                      if (isLive && !_isAuctionEnded(auction.endsAt)) ...[
                        const SizedBox(height: 16),
                        Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    RealTimeColors.success.withValues(alpha: 0.1),
                                    RealTimeColors.success.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: RealTimeColors.success.withValues(alpha: 
                                    0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reserve Price',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: AppColors.subtextColor,
                                            ),
                                          ),
                                          // FIX: auction.reservePrice is int? — pass directly
                                          Text(
                                            _formatCurrency(
                                              auction.reservePrice,
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: RealTimeColors.success
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: RealTimeColors
                                                            .success,
                                                        shape: BoxShape.circle,
                                                      ),
                                                )
                                                .animate(
                                                  onPlay: (c) =>
                                                      c.repeat(reverse: true),
                                                )
                                                .scaleXY(
                                                  begin: 1.0,
                                                  end: 1.4,
                                                  duration: 700.ms,
                                                  curve: Curves.easeInOut,
                                                )
                                                .then()
                                                .fadeOut(duration: 300.ms),
                                            const SizedBox(width: 6),
                                            Text(
                                              _getTimeRemainingText(
                                                auction.endsAt,
                                              ),
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: RealTimeColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: GeneralButton(
                                      onTap: () {
                                        if (onBidNow != null) {
                                          onBidNow!();
                                        } else {
                                          _showBidDialog(context);
                                        }
                                      },
                                      btnColor: AppColors.primaryColor,
                                      child: Text(
                                        'Place Bid Now',
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
                            )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 400.ms)
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            )
                            .then()
                            .shimmer(
                              duration: 2000.ms,
                              delay: 600.ms,
                              color: RealTimeColors.success.withValues(alpha: 0.15),
                            ),
                      ],

                      // Draft Status Info
                      if (isDraft) ...[
                        const SizedBox(height: 12),
                        Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: RealTimeColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: RealTimeColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This auction is in draft mode and not yet open for bidding',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: RealTimeColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 350.ms)
                            .slideX(begin: 0.05, end: 0, duration: 350.ms),
                      ],

                      // Closed / Cancelled Info
                      if (isClosed ||
                          auction.status?.toLowerCase() == 'cancelled') ...[
                        const SizedBox(height: 12),
                        Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: RealTimeColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.block_outlined,
                                    size: 16,
                                    color: RealTimeColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auction.status?.toLowerCase() ==
                                              'cancelled'
                                          ? 'This auction has been cancelled'
                                          : 'This auction has ended',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: RealTimeColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 350.ms)
                            .slideX(begin: 0.05, end: 0, duration: 350.ms),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        // Outer card entrance animation
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor(auction.status);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusText(auction.status),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );

    // Pulsing glow only for live
    if (isLive) {
      return badge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 900.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .shimmer(
            duration: 1500.ms,
            color: RealTimeColors.success.withValues(alpha: 0.4),
          );
    }

    return badge;
  }

  Widget _buildImageCarousel() {
    final List<String> imageUrls = auction.asset?.assetImages ?? [];

    if (imageUrls.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: RealTimeColors.grey200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: RealTimeColors.grey400,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 600.ms)
                  .then()
                  .fadeOut(duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                'No Images Available',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: RealTimeColors.grey500,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 220,
              autoPlay: isLive,
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true,
              enableInfiniteScroll: imageUrls.length > 1,
              viewportFraction: 1.0,
              aspectRatio: 16 / 9,
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
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBidDialog(BuildContext context) {
    final auctionsController = Get.find<AuctionsController>();

    Get.dialog(
      BidPlacementDialog(
        auctionTitle: auction.asset?.title ?? 'Auction',
        currentBid: (auction.startingBidAmount ?? 0).toDouble(),
        // FIX: cast int? to double via .toDouble()
        reservePrice: (auction.reservePrice ?? 0).toDouble(),
        startingBid: (auction.startingBidAmount ?? 0).toDouble(),
        onPlaceBid: (amount) async {
          Get.back();

          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          final success = await auctionsController.placeBidRequest(
            auctionId: auction.id!,
            amount: amount,
          );

          Get.back();

          if (success) {
            Get.snackbar(
              'Bid Placed!',
              'Your bid of ${_formatCurrency(amount)} has been placed successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: RealTimeColors.success,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            if (onBidNow != null) onBidNow!();
          } else {
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
}
