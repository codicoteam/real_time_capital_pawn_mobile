import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

import '../../../models/notifications_model.dart';
import '../../../widgets/cards/notification_card.dart';
import '../controllers/notifications_mngmt_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final NotificationController _controller = Get.put(NotificationController());
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerAnimationController.forward();
    _fabAnimationController.forward();

    // Fetch notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchNotifications();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    _refreshAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    _refreshAnimationController.forward().then((_) {
      _refreshAnimationController.reset();
    });
    await _controller.refreshNotifications();
  }

  void _handleNotificationTap(NotificationsModel notification) async {
    // Mark as read if unread
    if (notification.isRead == false) {
      await _controller.markAsRead(notification.id!);
    }

    // Navigate to notification detail (to be implemented)
    Get.toNamed(
      RoutesHelper.notificationDetailsScreen,
      arguments: notification.id,
    );
    // Show a snackbar for now
    Get.snackbar(
      'Notification',
      notification.title ?? 'Notification',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _handleActionTap(NotificationsModel notification) async {
    await _controller.markAsReadAndAct(
      notificationId: notification.id!,
      action: notification.actionText ?? 'view',
    );

    // Handle action based on action_url
    if (notification.actionUrl != null) {
      // Navigate based on action_url
      Get.toNamed(notification.actionUrl!);
    }
  }

  void _handleMarkAllRead() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mark all as read?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will mark all your notifications as read.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Mark All',
              style: GoogleFonts.poppins(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateGroup(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (notificationDate.isAfter(
      today.subtract(const Duration(days: 7)),
    )) {
      return DateFormat('EEEE').format(notificationDate); // Day name
    } else {
      return DateFormat('MMM dd, yyyy').format(notificationDate);
    }
  }

  Map<String, List<NotificationsModel>> _groupNotificationsByDate() {
    final Map<String, List<NotificationsModel>> grouped = {};

    for (var notification in _controller.filteredNotifications) {
      final dateKey = _formatDateGroup(notification.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshNotifications,
          color: AppColors.primaryColor,
          child: Stack(
            children: [
              // Main scrollable content
              CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Space for header
                  const SliverToBoxAdapter(child: SizedBox(height: 180)),

                  // Search & Filters Section
                  SliverToBoxAdapter(
                    child:
                        Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  _buildSearchBar(),
                                  const SizedBox(height: 16),
                                  _buildFilterChips(),
                                  const SizedBox(height: 16),
                                  _buildStatsBar(),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                            ),
                  ),

                  // Notifications List
                  Obx(() {
                    if (_controller.isLoading.value &&
                        _controller.notifications.isEmpty) {
                      return SliverToBoxAdapter(child: _buildLoadingState());
                    }

                    if (_controller.errorMessage.value.isNotEmpty &&
                        _controller.notifications.isEmpty) {
                      return SliverToBoxAdapter(child: _buildErrorState());
                    }

                    if (_controller.filteredNotifications.isEmpty) {
                      return SliverToBoxAdapter(child: _buildEmptyState());
                    }

                    final groupedNotifications = _groupNotificationsByDate();

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final keys = groupedNotifications.keys.toList();
                          final sectionKey = keys[index];
                          final sectionNotifications =
                              groupedNotifications[sectionKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 12,
                                  left: 4,
                                ),
                                child: Text(
                                  sectionKey,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.subtextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Notifications in this section
                              ...sectionNotifications.asMap().entries.map(
                                (entry) => NotificationCard(
                                  notification: entry.value,
                                  index: entry.key,
                                  onTap: () =>
                                      _handleNotificationTap(entry.value),
                                  onMarkRead: () =>
                                      _controller.markAsRead(entry.value.id!),
                                  onActionTap: () =>
                                      _handleActionTap(entry.value),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }, childCount: groupedNotifications.keys.length),
                      ),
                    );
                  }),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Animated Header
              _buildAnimatedHeader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _headerAnimationController,
        builder: (context, child) {
          return ClipPath(
            clipper: _CustomCurvedEdges(),
            child: Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideX(begin: -0.3, end: 0),

                      Row(
                            children: [
                              AnimatedBuilder(
                                animation: _refreshAnimationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _refreshAnimationController.value *
                                        6.28318,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: _refreshNotifications,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.filter_list_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: _showFilterBottomSheet,
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),

                  // Subtitle
                  Obx(
                    () =>
                        Text(
                              'You have ${_controller.unreadCount.value} unread notifications',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 500.ms)
                            .slideY(begin: 0.3, end: 0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _controller.setSearchQuery(value),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search notifications...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.subtextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: AppColors.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: AppColors.subtextColor,
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  _controller.clearSearch();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All',
              isSelected: _controller.selectedFilter.value == 'All',
              onTap: () => _controller.setFilter('All'),
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              label: 'Unread',
              isSelected: _controller.selectedFilter.value == 'Unread',
              onTap: () => _controller.setFilter('Unread'),
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              label: 'Read',
              isSelected: _controller.selectedFilter.value == 'Read',
              onTap: () => _controller.setFilter('Read'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.borderColor,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppColors.textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          duration: 200.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        );
  }

  Widget _buildStatsBar() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_controller.filteredNotifications.length} notifications',
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_controller.unreadCount.value > 0)
              GestureDetector(
                onTap: _handleMarkAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mark all read',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1500.ms),
          const SizedBox(height: 24),
          Text(
                'Loading notifications...',
                style: GoogleFonts.poppins(
                  color: AppColors.subtextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.errorColor,
                ),
              )
              .animate()
              .scale(delay: 100.ms, duration: 400.ms)
              .shake(delay: 500.ms),
          const SizedBox(height: 24),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              _controller.errorMessage.value,
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _controller.refreshNotifications,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasFilter = _controller.selectedFilter.value != 'All';

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasSearch || hasFilter
                      ? Icons.search_off_rounded
                      : Icons.notifications_none_rounded,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
              )
              .animate()
              .scale(delay: 100.ms, duration: 500.ms)
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          Text(
            hasSearch || hasFilter
                ? 'No matching notifications'
                : 'No notifications yet',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          Text(
            hasSearch || hasFilter
                ? 'Try adjusting your search or filters'
                : 'When you receive notifications, they\'ll appear here',
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          if (hasSearch || hasFilter)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: OutlinedButton(
                onPressed: _controller.clearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Clear Filters',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  _buildBottomSheetFilterChip(
                    'All',
                    _controller.selectedFilter.value == 'All',
                    () {
                      _controller.setFilter('All');
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildBottomSheetFilterChip(
                    'Unread',
                    _controller.selectedFilter.value == 'Unread',
                    () {
                      _controller.setFilter('Unread');
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildBottomSheetFilterChip(
                    'Read',
                    _controller.selectedFilter.value == 'Read',
                    () {
                      _controller.setFilter('Read');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _controller.clearFilters();
                  Navigator.pop(context);
                },
                child: Text('Clear All Filters', style: GoogleFonts.poppins()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : AppColors.textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Custom curved edges clipper for header
class _CustomCurvedEdges extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
