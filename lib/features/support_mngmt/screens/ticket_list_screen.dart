import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/support_mngmt/controllers/support_mngmt_controller.dart';
import 'package:real_time_pawn/features/support_mngmt/helpers/support_mngmt_helper.dart';
import 'package:real_time_pawn/features/test/curved_edges.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';

import '../../../config/routers/router.dart';
import '../../../widgets/cards/ticket_card.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen>
    with TickerProviderStateMixin {
  final SupportTicketController _controller = Get.put(
    SupportTicketController(),
  );

  String _customerId = '';
  bool _isLoading = false;

  String _selectedSortBy = 'created_at';
  bool _isAscending = false;
  String? _selectedStatus;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'all', 'label': 'All'},
    {'value': 'open', 'label': 'Open'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'resolved', 'label': 'Resolved'},
    {'value': 'closed', 'label': 'Closed'},
  ];

  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerAnimationController.forward();
    _fabAnimationController.forward();

    _getCustomerIdAndLoadTickets();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _getCustomerIdAndLoadTickets() async {
    setState(() => _isLoading = true);
    try {
      _customerId = await CacheUtils.getUserId() ?? '';
      if (_customerId.isEmpty) {
        Get.snackbar(
          'Error',
          'Unable to load tickets. Please login again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }
      await SupportTicketHelper.getCustomerTickets(
        customerId: _customerId,
        showLoader: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tickets: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshTickets() async {
    await _getCustomerIdAndLoadTickets();
  }

  List<SupportTicket> get _filteredTickets {
    var tickets = _controller.tickets.toList();

    if (_selectedStatus != null && _selectedStatus != 'all') {
      tickets = tickets.where((t) {
        return t.status.toString().split('.').last == _selectedStatus;
      }).toList();
    }

    tickets.sort((a, b) {
      int cmp;
      if (_selectedSortBy == 'created_at') {
        cmp = a.createdAt.compareTo(b.createdAt);
      } else {
        cmp = _priorityValue(a.priority).compareTo(_priorityValue(b.priority));
      }
      return _isAscending ? cmp : -cmp;
    });

    return tickets;
  }

  int _priorityValue(TicketPriority p) {
    switch (p) {
      case TicketPriority.urgent:
        return 4;
      case TicketPriority.high:
        return 3;
      case TicketPriority.medium:
        return 2;
      case TicketPriority.low:
        return 1;
    }
  }

  int get _openTicketsCount =>
      _controller.tickets.where((t) => t.status == TicketStatus.open).length;

  Color _statusAccentColor(String? value) {
    switch (value) {
      case 'open':
        return const Color(0xFFFF8C00);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return const Color(0xFF22C55E);
      case 'closed':
        return const Color(0xFF9CA3AF);
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTickets,
          color: AppColors.primaryColor,
          displacement: 150,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Space for header
                  const SliverToBoxAdapter(child: SizedBox(height: 130)),

                  // Filter card
                  SliverToBoxAdapter(
                    child:
                        Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildControlRow(),
                                  const SizedBox(height: 10),
                                  _buildStatusFilters(),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Divider(
                                      color: Colors.grey.shade100,
                                      thickness: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(
                              begin: 0.12,
                              end: 0,
                              duration: 420.ms,
                              curve: Curves.easeOutCubic,
                            ),
                  ),

                  // Tickets List
                  Obx(() {
                    if (_isLoading && _controller.tickets.isEmpty) {
                      return SliverToBoxAdapter(child: _buildLoadingState());
                    }
                    if (_controller.errorMessage.value.isNotEmpty &&
                        _controller.tickets.isEmpty) {
                      return SliverToBoxAdapter(child: _buildErrorState());
                    }

                    final filtered = _filteredTickets;
                    if (filtered.isEmpty) {
                      return SliverToBoxAdapter(child: _buildEmptyState());
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final ticket = filtered[index];
                          // Staggered entrance: each card delays by 60ms per index
                          return TicketCard(
                                ticket: ticket,
                                // Inside TicketCard's onTap
                                onTap: () {
                                  Get.toNamed(
                                    RoutesHelper.ticketDetailsScreen,
                                    arguments: ticket, 
                                  );
                                },
                              )
                              .animate(delay: (index * 65).ms)
                              .fadeIn(duration: 380.ms, curve: Curves.easeOut)
                              .slideX(
                                begin: 0.1,
                                end: 0,
                                duration: 380.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .scaleXY(
                                begin: 0.96,
                                end: 1,
                                duration: 350.ms,
                                curve: Curves.easeOut,
                              );
                        }, childCount: filtered.length),
                      ),
                    );
                  }),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              _buildAnimatedHeader(),
              _buildFloatingActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Compact Header ----------
  Widget _buildAnimatedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: TCustomCurvedEdges(),
        child: Container(
          height: 158,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        onTap: () => Get.offAllNamed(RoutesHelper.main_home_page),
                      )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 300.ms)
                      .slideX(begin: -0.4, end: 0),

                  Text(
                    'Support Tickets',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

                  _headerIconButton(
                        icon: Icons.refresh_rounded,
                        size: 20,
                        onTap: _refreshTickets,
                      )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 300.ms)
                      .slideX(begin: 0.4, end: 0),
                ],
              ),

              const SizedBox(height: 16),

              Obx(() {
                final total = _controller.tickets.length;
                final filtered = _filteredTickets.length;
                final openCount = _openTicketsCount;
                final inProgressCount = _controller.tickets
                    .where((t) => t.status == TicketStatus.in_progress)
                    .length;

                return Row(
                      children: [
                        _statPill(
                          icon: Icons.confirmation_num_outlined,
                          label: total == filtered
                              ? '$total Tickets'
                              : '$filtered / $total',
                        ),
                        if (openCount > 0) ...[
                          const SizedBox(width: 10),
                          _statPill(
                            icon: Icons.radio_button_checked_rounded,
                            label: '$openCount Open',
                            highlight: true,
                          ),
                        ],
                        if (inProgressCount > 0) ...[
                          const SizedBox(width: 10),
                          _statPill(
                            icon: Icons.timelapse_rounded,
                            label: '$inProgressCount Active',
                            highlight: true,
                          ),
                        ],
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.4, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.2),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _statPill({
    required IconData icon,
    required String label,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: highlight ? 0.5 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Control Row ----------
  Widget _buildControlRow() {
    final sortItems = [
      {
        'label': 'Date',
        'value': 'created_at',
        'icon': Icons.calendar_today_outlined,
      },
      {'label': 'Priority', 'value': 'priority', 'icon': Icons.flag_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Sort',
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),

          // Sort type chips
          ...sortItems.map((item) {
            final isSelected = _selectedSortBy == item['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedSortBy = item['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 13,
                        color: isSelected
                            ? Colors.white
                            : AppColors.subtextColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textColor,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Asc / Desc — icon-only square button with animated rotation
          Tooltip(
            message: _isAscending ? 'Ascending order' : 'Descending order',
            preferBelow: false,
            child: GestureDetector(
              onTap: () => setState(() => _isAscending = !_isAscending),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isAscending
                      ? AppColors.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isAscending
                        ? AppColors.primaryColor.withValues(alpha: 0.4)
                        : Colors.grey.shade200,
                    width: 1.3,
                  ),
                ),
                child: Center(
                  child: AnimatedRotation(
                    turns: _isAscending ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.sort_rounded,
                      size: 20,
                      color: _isAscending
                          ? AppColors.primaryColor
                          : AppColors.subtextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Status Filters ----------
  Widget _buildStatusFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _statusOptions.map((option) {
            final isSelected =
                _selectedStatus == option['value'] ||
                (_selectedStatus == null && option['value'] == 'all');
            final accent = _statusAccentColor(option['value']);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = option['value'] == 'all'
                        ? null
                        : option['value'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? accent.withValues(alpha: 0.45)
                          : Colors.transparent,
                      width: 1.3,
                    ),
                  ),
                  child: Text(
                    option['label']!,
                    style: GoogleFonts.poppins(
                      color: isSelected ? accent : AppColors.subtextColor,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------- State Widgets ----------
  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 1200.ms),
          const SizedBox(height: 18),
          Text(
                'Loading tickets...',
                style: GoogleFonts.poppins(
                  color: AppColors.subtextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 700.ms)
              .then()
              .fadeOut(duration: 700.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.errorColor,
                ),
              )
              .animate()
              .scale(delay: 100.ms, duration: 350.ms)
              .shake(delay: 500.ms),
          const SizedBox(height: 18),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              _controller.errorMessage.value,
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshTickets,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Column(
        children: [
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent_outlined,
                  size: 60,
                  color: AppColors.primaryColor,
                ),
              )
              .animate()
              .scale(delay: 100.ms, duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 20),
          Text(
            _selectedStatus != null ? 'No matching tickets' : 'No tickets yet',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 8),
          Text(
            _selectedStatus != null
                ? 'Try a different status filter'
                : 'Tap the button below to create your first ticket',
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  // ---------- FAB ----------
  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 24,
      right: 20,
      child: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: Curves.easeOutBack.transform(
              _fabAnimationController.value.clamp(0.0, 1.0),
            ),
            child:
                FloatingActionButton.extended(
                      onPressed: SupportTicketHelper.navigateToCreateTicket,
                      backgroundColor: AppColors.primaryColor,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 22),
                      label: Text(
                        'New Ticket',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      delay: 3000.ms,
                      duration: 1200.ms,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
          );
        },
      ),
    );
  }
}
