import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_mngmnt/controllers/bid_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_mngmnt/helpers/bid_mngmt_helper.dart';
import 'package:real_time_pawn/models/user_bid_models.dart';

class BidCard extends StatefulWidget {
  final UserBid bid;
  final int index;

  const BidCard({super.key, required this.bid, this.index = 0});

  @override
  State<BidCard> createState() => _BidCardState();
}

class _BidCardState extends State<BidCard> {
  bool _isPressed = false;

  Color _getAuctionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return RealTimeColors.success;
      case 'closed':
        return RealTimeColors.error;
      case 'upcoming':
        return RealTimeColors.warning;
      case 'draft':
        return RealTimeColors.grey500;
      default:
        return RealTimeColors.grey400;
    }
  }

  IconData _getAuctionStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Icons.sensors_rounded;
      case 'closed':
        return Icons.lock_rounded;
      case 'upcoming':
        return Icons.schedule_rounded;
      case 'draft':
        return Icons.edit_note_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BidManagementController>();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final bidStatusText = BidManagementHelper.getBidStatusText(widget.bid);
    final paymentStatus = widget.bid.paymentStatus
        .toString()
        .split('.')
        .last
        .toLowerCase();
    final disputeStatus = widget.bid.dispute.status
        .toString()
        .split('.')
        .last
        .toLowerCase();
    final auctionStatus = widget.bid.auction.status.toLowerCase();

    final hasDispute = controller.hasBidDispute(widget.bid);
    final isPaid = controller.isBidPaid(widget.bid);
    final isWinning = controller.isBidWinning(widget.bid);
    final isWon = controller.isBidWon(widget.bid);
    final isLive = auctionStatus == 'live';

    final staggerDelay = Duration(milliseconds: widget.index * 90);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => Get.toNamed('/bid-details/${widget.bid.id}'),
      child: AnimatedScale(
        scale: _isPressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child:
            Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Top accent line
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withValues(alpha: 0.0),
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header ──────────────────────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primaryColor
                                                  .withValues(alpha: 0.18),
                                              AppColors.primaryColor
                                                  .withValues(alpha: 0.06),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.gavel_rounded,
                                          color: AppColors.primaryColor,
                                          size: 20,
                                        ),
                                      )
                                      .animate(delay: staggerDelay + 100.ms)
                                      .scale(
                                        begin: const Offset(0.5, 0.5),
                                        duration: 500.ms,
                                        curve: Curves.elasticOut,
                                      )
                                      .fadeIn(duration: 250.ms),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child:
                                        Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget
                                                      .bid
                                                      .auction
                                                      .asset
                                                      .title,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textColor,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.numbers_rounded,
                                                      size: 11,
                                                      color: AppColors
                                                          .subtextColor,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      widget
                                                          .bid
                                                          .auction
                                                          .auctionNo,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .subtextColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                            .animate(
                                              delay: staggerDelay + 160.ms,
                                            )
                                            .fadeIn(duration: 300.ms)
                                            .slideX(
                                              begin: -0.05,
                                              duration: 300.ms,
                                              curve: Curves.easeOut,
                                            ),
                                  ),

                                  const SizedBox(width: 10),

                                  BidStatusTextBadge(
                                    statusText: bidStatusText,
                                    animationDelay: staggerDelay + 220.ms,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ── Gradient Divider ─────────────────────────────────
                              Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryColor.withValues(alpha: 
                                            0.0,
                                          ),
                                          AppColors.primaryColor.withValues(alpha: 
                                            0.3,
                                          ),
                                          AppColors.primaryColor.withValues(alpha: 
                                            0.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate(delay: staggerDelay + 260.ms)
                                  .scaleX(
                                    begin: 0,
                                    duration: 500.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .fadeIn(duration: 300.ms),

                              const SizedBox(height: 16),

                              // ── Bid Amount & Date ─────────────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child:
                                        Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'YOUR BID',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.subtextColor,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  BidManagementHelper.formatCurrency(
                                                    widget.bid.amount,
                                                    widget.bid.currency,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.primaryColor,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ],
                                            )
                                            .animate(
                                              delay: staggerDelay + 310.ms,
                                            )
                                            .fadeIn(duration: 400.ms)
                                            .slideY(
                                              begin: 0.2,
                                              duration: 400.ms,
                                              curve: Curves.easeOut,
                                            ),
                                  ),

                                  Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'PLACED AT',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.subtextColor,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month_rounded,
                                                size: 12,
                                                color: AppColors.primaryColor
                                                    .withValues(alpha: 0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                dateFormat.format(
                                                  widget.bid.placedAt,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 12,
                                                color: AppColors.subtextColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                timeFormat.format(
                                                  widget.bid.placedAt,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppColors.subtextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                      .animate(delay: staggerDelay + 360.ms)
                                      .fadeIn(duration: 400.ms)
                                      .slideY(
                                        begin: 0.2,
                                        duration: 400.ms,
                                        curve: Curves.easeOut,
                                      ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ── Status Chips ─────────────────────────────────────
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _StatusChip(
                                    label:
                                        BidManagementHelper.getPaymentStatusText(
                                          paymentStatus,
                                        ),
                                    color:
                                        BidManagementHelper.getPaymentStatusColor(
                                          paymentStatus,
                                        ),
                                    icon: Icons.receipt_long_rounded,
                                    animDelay: staggerDelay + 420.ms,
                                  ),
                                  if (hasDispute)
                                    _StatusChip(
                                      label:
                                          BidManagementHelper.getDisputeStatusText(
                                            disputeStatus,
                                          ),
                                      color:
                                          BidManagementHelper.getDisputeStatusColor(
                                            disputeStatus,
                                          ),
                                      icon: Icons.report_problem_rounded,
                                      animDelay: staggerDelay + 470.ms,
                                    ),
                                  _StatusChip(
                                    label: auctionStatus.toUpperCase(),
                                    color: _getAuctionStatusColor(
                                      auctionStatus,
                                    ),
                                    icon: _getAuctionStatusIcon(auctionStatus),
                                    animDelay: staggerDelay + 520.ms,
                                    isPulsing: isLive,
                                  ),
                                ],
                              ),

                              // ── Pay Now ───────────────────────────────────────────
                              if (auctionStatus == 'closed' &&
                                  isWon &&
                                  !isPaid) ...[
                                const SizedBox(height: 14),
                                _PayNowButton(
                                  onTap: () => Get.toNamed(
                                    '/select-payment-method',
                                    arguments: {
                                      'bidId': widget.bid.id,
                                      'amount': widget.bid.amount,
                                    },
                                  ),
                                  animDelay: staggerDelay + 580.ms,
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
                .fadeIn(
                  duration: 450.ms,
                  delay: staggerDelay,
                  curve: Curves.easeOut,
                )
                .slideY(
                  begin: 0.07,
                  end: 0,
                  duration: 450.ms,
                  delay: staggerDelay,
                  curve: Curves.easeOut,
                ),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final Duration animDelay;
  final bool isPulsing;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.animDelay,
    this.isPulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (isPulsing) ...[
                const SizedBox(width: 5),
                _PulseDot(color: color),
              ],
            ],
          ),
        )
        .animate(delay: animDelay)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.75, 0.75),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}

// ── Live Pulse Dot ────────────────────────────────────────────────────────────

class _PulseDot extends StatelessWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1.4, 1.4),
          duration: 750.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.4, 1.4),
          end: const Offset(0.6, 0.6),
          duration: 750.ms,
          curve: Curves.easeInOut,
        );
  }
}

// ── Pay Now Button ────────────────────────────────────────────────────────────

class _PayNowButton extends StatelessWidget {
  final VoidCallback onTap;
  final Duration animDelay;

  const _PayNowButton({required this.onTap, required this.animDelay});

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.78),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withValues(alpha: 0.15),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pay Now',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: animDelay)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.25, duration: 400.ms, curve: Curves.easeOut)
        .animate(onPlay: (c) => c.repeat(period: 3800.ms))
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.18),
          delay: 1200.ms,
        );
  }
}

// ── Bid Status Badge ──────────────────────────────────────────────────────────

class BidStatusTextBadge extends StatelessWidget {
  final String statusText;
  final double fontSize;
  final Duration animationDelay;

  const BidStatusTextBadge({
    super.key,
    required this.statusText,
    this.fontSize = 11,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = BidManagementHelper.getBidStatusColorFromText(
      statusText,
    );

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor, statusColor.withValues(alpha: 0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.32),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        )
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }
}
