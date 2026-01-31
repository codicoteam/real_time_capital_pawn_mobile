import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/controllers/loan_application_mngmt_controller.dart';
import 'package:real_time_pawn/features/loan_application_mngmt/screens/loan_application_details_screen.dart';
import 'package:real_time_pawn/features/test/curved_edges.dart';
import 'package:real_time_pawn/widgets/cards/loan_application_card.dart';

class LoanApplicationsListScreen extends StatefulWidget {
  final String customerUserId;

  const LoanApplicationsListScreen({
    super.key,
    required this.customerUserId,
  });

  @override
  State<LoanApplicationsListScreen> createState() =>
      _LoanApplicationsListScreenState();
}

class _LoanApplicationsListScreenState
    extends State<LoanApplicationsListScreen> with TickerProviderStateMixin {
  final LoanApplicationController _controller =
      Get.put(LoanApplicationController());
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'created_at';
  String _selectedOrder = 'desc';
  String? _selectedCategory;
  String? _selectedStatus;

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Newest First', 'sortBy': 'created_at', 'order': 'desc'},
    {'label': 'Oldest First', 'sortBy': 'created_at', 'order': 'asc'},
    {
      'label': 'Amount: High to Low',
      'sortBy': 'requested_loan_amount',
      'order': 'desc',
    },
    {
      'label': 'Amount: Low to High',
      'sortBy': 'requested_loan_amount',
      'order': 'asc',
    },
  ];

  final List<Map<String, String>> _categoryOptions = [
    {'value': 'all', 'label': 'All Categories', 'icon': 'all'},
    {'value': 'small_loans', 'label': 'Small Loans', 'icon': 'money'},
    {'value': 'motor_vehicle', 'label': 'Motor Vehicle', 'icon': 'car'},
    {'value': 'jewellery', 'label': 'Jewellery', 'icon': 'diamond'},
  ];

  final List<Map<String, String>> _statusOptions = [
    {'value': 'all', 'label': 'All Status'},
    {'value': 'draft', 'label': 'Draft'},
    {'value': 'submitted', 'label': 'Submitted'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'approved', 'label': 'Approved'},
    {'value': 'rejected', 'label': 'Rejected'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;

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

    _headerAnimationController.forward();
    _fabAnimationController.forward();

    // Fetch loan applications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLoanApplications();
    });

    // Listen to search query changes
    _searchController.addListener(() {
      _controller.updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLoanApplications() async {
    await _controller.fetchLoanApplicationsByCustomer(
      widget.customerUserId,
      sortBy: _selectedFilter,
      sortOrder: _selectedOrder,
    );
  }

  Future<void> _refreshLoanApplications() async {
    await _controller.refreshLoans(widget.customerUserId);
  }

  void _updateSort(String sortBy, String order) {
    setState(() {
      _selectedFilter = sortBy;
      _selectedOrder = order;
    });
    _fetchLoanApplications();
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return '\$0.00';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  double _calculateTotalRequested() {
    final applications = _getFilteredApplications();
    return applications.fold(
      0.0,
      (sum, loan) => sum + (loan.requestedLoanAmount ?? 0),
    );
  }

  List<dynamic> _getFilteredApplications() {
    var applications = _controller.filteredLoanApplications;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'all') {
      applications = applications
          .where(
            (app) =>
                app.collateralCategory?.toLowerCase() ==
                _selectedCategory?.toLowerCase(),
          )
          .toList();
    }

    // Filter by status
    if (_selectedStatus != null && _selectedStatus != 'all') {
      applications = applications
          .where(
            (app) => app.status?.toLowerCase() == _selectedStatus?.toLowerCase(),
          )
          .toList();
    }

    return applications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshLoanApplications,
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
                  const SliverToBoxAdapter(child: SizedBox(height: 240)),

                  // Search & Filters Section
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildSortFilters(),
                          const SizedBox(height: 16),
                          _buildCategoryFilters(),
                          const SizedBox(height: 16),
                          _buildStatusFilters(),
                          const SizedBox(height: 24),
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

                  // Loan Applications List
                  Obx(() {
                    if (_controller.isLoading.value &&
                        _controller.loanApplications.isEmpty) {
                      return SliverToBoxAdapter(child: _buildLoadingState());
                    }

                    if (_controller.errorMessage.value.isNotEmpty &&
                        _controller.loanApplications.isEmpty) {
                      return SliverToBoxAdapter(child: _buildErrorState());
                    }

                    final filteredApplications = _getFilteredApplications();

                    if (filteredApplications.isEmpty) {
                      return SliverToBoxAdapter(child: _buildEmptyState());
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final application = filteredApplications[index];
                            return LoanApplicationCard(
                              application: application,
                              index: index,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoanApplicationDetailsScreen(
                                      application: application,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: filteredApplications.length,
                        ),
                      ),
                    );
                  }),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Animated Header
              _buildAnimatedHeader(),

              // Floating Action Button
              _buildFloatingActionButton(),
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
            clipper: TCustomCurvedEdges(),
            child: Container(
              height: 280,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
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
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _refreshLoanApplications,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    'Loan Applications',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),

                  // Count
                  Obx(
                    () => Text(
                      '${_getFilteredApplications().length} Applications',
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
                  const SizedBox(height: 24),

                  // Total amount
                  Obx(
                    () => Text(
                      _formatCurrency(_calculateTotalRequested().toInt()),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0)
                        .shimmer(
                          delay: 800.ms,
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.3),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Requested Amount',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by name, ID, amount...',
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

  Widget _buildSortFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort By',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _sortOptions.map((option) {
                final isSelected = _selectedFilter == option['sortBy'] &&
                    _selectedOrder == option['order'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildFilterChip(
                    label: option['label']!,
                    isSelected: isSelected,
                    onTap: () => _updateSort(
                      option['sortBy']!,
                      option['order']!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categoryOptions.map((option) {
                final isSelected = _selectedCategory == option['value'] ||
                    (_selectedCategory == null && option['value'] == 'all');
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCategoryChip(
                    label: option['label']!,
                    icon: option['icon']!,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategory = option['value'] == 'all'
                            ? null
                            : option['value'];
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _statusOptions.map((option) {
                final isSelected = _selectedStatus == option['value'] ||
                    (_selectedStatus == null && option['value'] == 'all');
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildFilterChip(
                    label: option['label']!,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedStatus =
                            option['value'] == 'all' ? null : option['value'];
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryColor : AppColors.borderColor,
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

  Widget _buildCategoryChip({
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData iconData;
    switch (icon) {
      case 'money':
        iconData = Icons.attach_money_rounded;
        break;
      case 'car':
        iconData = Icons.directions_car_outlined;
        break;
      case 'diamond':
        iconData = Icons.diamond_outlined;
        break;
      default:
        iconData = Icons.category_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryColor : AppColors.borderColor,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppColors.textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
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
            'Loading applications...',
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
            onPressed: _fetchLoanApplications,
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
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.primaryColor,
            ),
          )
              .animate()
              .scale(delay: 100.ms, duration: 500.ms)
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isNotEmpty ||
                    _selectedCategory != null ||
                    _selectedStatus != null
                ? 'No matching applications'
                : 'No loan applications yet',
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          Text(
            _searchController.text.isNotEmpty ||
                    _selectedCategory != null ||
                    _selectedStatus != null
                ? 'Try adjusting your filters'
                : 'Applications will appear here once created',
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimationController.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to create loan application screen
                // Get.toNamed(RoutesHelper.createLoanApplication);
              },
              backgroundColor: AppColors.primaryColor,
              elevation: 8,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: Text(
                'New Application',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  delay: 2000.ms,
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.3),
                ),
          );
        },
      ),
    );
  }
}