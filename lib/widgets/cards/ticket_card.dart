import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';

class TicketCard extends StatefulWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  // ---- Helpers ----
  String _getCategoryName(TicketCategory category) {
    switch (category) {
      case TicketCategory.loan:
        return 'Loan';
      case TicketCategory.payment:
        return 'Payment';
      case TicketCategory.auction:
        return 'Auction';
      case TicketCategory.account:
        return 'Account';
      case TicketCategory.technical:
        return 'Technical';
      case TicketCategory.general:
        return 'General';
    }
  }

  IconData _getCategoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.loan:
        return Icons.account_balance_wallet_outlined;
      case TicketCategory.payment:
        return Icons.payment_outlined;
      case TicketCategory.auction:
        return Icons.gavel_rounded;
      case TicketCategory.account:
        return Icons.person_outline_rounded;
      case TicketCategory.technical:
        return Icons.build_circle_outlined;
      case TicketCategory.general:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusName(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.in_progress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFFFF8C00);
      case TicketStatus.in_progress:
        return const Color(0xFF3B82F6);
      case TicketStatus.resolved:
        return const Color(0xFF22C55E);
      case TicketStatus.closed:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.radio_button_unchecked_rounded;
      case TicketStatus.in_progress:
        return Icons.timelapse_rounded;
      case TicketStatus.resolved:
        return Icons.check_circle_outline_rounded;
      case TicketStatus.closed:
        return Icons.cancel_outlined;
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      final y = (diff.inDays / 365).floor();
      return '$y yr${y > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 30) {
      final m = (diff.inDays / 30).floor();
      return '$m mo${m > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.ticket.status);
    final dateStr = DateFormat('MMM dd, yyyy').format(widget.ticket.createdAt);
    final timeAgo = _getTimeAgo(widget.ticket.createdAt);

    return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Left green accent bar
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              statusColor,
                              statusColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Card content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: category icon + subject + status badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category icon bubble
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  _getCategoryIcon(widget.ticket.category),
                                  size: 22,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Subject + category label
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getCategoryName(
                                          widget.ticket.category,
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      widget.ticket.subject,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textColor,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Status badge
                              _StatusBadge(
                                label: _getStatusName(widget.ticket.status),
                                color: statusColor,
                                icon: _getStatusIcon(widget.ticket.status),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Divider
                          Container(
                            height: 1,
                            color: statusColor.withOpacity(0.1),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            widget.ticket.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: AppColors.subtextColor,
                              height: 1.55,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 14),

                          // Footer: date + time ago + arrow
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: AppColors.subtextColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                dateStr,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppColors.subtextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.subtextColor.withOpacity(
                                    0.4,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                timeAgo,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: statusColor,
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
          ),
        )
        .animate()
        .fadeIn(duration: 450.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        )
        .then(delay: 100.ms)
        .shimmer(
          duration: 900.ms,
          color: statusColor.withOpacity(0.06),
        );
  }
}

// ---- Animated Status Badge ----
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 350.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: 200.ms,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }
}
