import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/controllers/bid_payment_mngmt_controller.dart';
import 'package:real_time_pawn/features/bid_payment_mngmt/helpers/bid_payment_mngmt_helper.dart';
import 'package:real_time_pawn/models/bid_payment_model.dart';

class MyBidPaymentsScreen extends StatefulWidget {
  const MyBidPaymentsScreen({super.key});

  @override
  State<MyBidPaymentsScreen> createState() => _MyBidPaymentsScreenState();
}

class _MyBidPaymentsScreenState extends State<MyBidPaymentsScreen> {
  final BidPaymentController _controller = Get.put(BidPaymentController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // List of status filters - moved to class level
  final List<String> statusFilters = [
    'All',
    'Successful',
    'Pending',
    'Failed',
    'Refunded',
  ];

  // Track active status filter
  String? _activeStatusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialPayments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    // Cancel search timer
    if (_searchDebounceTimer != null) {
      _searchDebounceTimer!.cancel();
    }
    super.dispose();
  }

  void _loadInitialPayments() async {
    await BidPaymentHelper.loadPayerPayments(showLoader: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePayments();
    }
  }

  Future<void> _loadMorePayments() async {
    if (_controller.isLoadingMore.value || !_controller.hasMorePayments.value) {
      return;
    }

    _controller.isLoadingMore.value = true;

    await _controller.loadMorePayments();

    _controller.isLoadingMore.value = false;
  }

  Timer? _searchDebounceTimer;

  void _handleSearch(String query) {
    // Cancel previous timer
    if (_searchDebounceTimer != null) {
      _searchDebounceTimer!.cancel();
    }

    // Set a new timer
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _clearSearch();
      } else if (query.length >= 2) {
        // Check if there are any payments first
        if (_controller.bidPayments.isEmpty) {
          BidPaymentHelper.showError(
            'No payments to search. You have no payments yet.',
          );
          return;
        }

        // Use client-side search
        final results = _searchPaymentsLocallyImpl(query);
        if (results.isNotEmpty) {
          _controller.bidPayments.value = results;
          BidPaymentHelper.showSuccess('Found ${results.length} payments');
        } else {
          BidPaymentHelper.showError('No payments found matching "$query"');
        }
      } else {
        // 1 character - show message
        BidPaymentHelper.showError('Search requires at least 2 characters');
      }
    });
  }

  // CLIENT-SIDE SEARCH METHOD
  void _searchPaymentsLocally(String query) {
    final results = _searchPaymentsLocallyImpl(query);
    if (results.isNotEmpty) {
      _controller.bidPayments.value = results;
      BidPaymentHelper.showSuccess('Found ${results.length} payments');
    } else {
      BidPaymentHelper.showError('No payments found matching "$query"');
      _refreshPayments(); // Reset to show all
    }
  }

  // IMPLEMENTATION: Client-side search
  List<BidPayment> _searchPaymentsLocallyImpl(String query) {
    if (query.isEmpty || query.length < 2) return _controller.bidPayments;

    final searchLower = query.toLowerCase();

    return _controller.bidPayments.where((payment) {
      return payment.auction.asset.title.toLowerCase().contains(searchLower) ||
          payment.auction.auctionNo.toLowerCase().contains(searchLower) ||
          payment.method.toLowerCase().contains(searchLower) ||
          payment.provider.toLowerCase().contains(searchLower) ||
          payment.statusText.toLowerCase().contains(searchLower) ||
          (payment.receiptNo?.toLowerCase().contains(searchLower) ?? false) ||
          (payment.payerPhone?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  // CLIENT-SIDE STATUS FILTERING METHOD
  List<BidPayment> _filterPaymentsByStatus(String statusText) {
    if (statusText == 'All') return _controller.bidPayments;

    PaymentStatus status;
    switch (statusText.toLowerCase()) {
      case 'successful':
        status = PaymentStatus.success;
        break;
      case 'pending':
        status = PaymentStatus.pending;
        break;
      case 'failed':
        status = PaymentStatus.failed;
        break;
      case 'refunded':
        status = PaymentStatus.refunded;
        break;
      default:
        return _controller.bidPayments;
    }

    return _controller.bidPayments
        .where((payment) => payment.status == status)
        .toList();
  }

  void _clearSearch() {
    // Clear search and refresh original list
    setState(() {
      _activeStatusFilter = null;
    });
    _controller.clearSearch();
    _refreshPayments();
  }

  Future<void> _refreshPayments() async {
    await BidPaymentHelper.loadPayerPayments(showLoader: false);
    setState(() {
      _activeStatusFilter = null;
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 64,
            color: RealTimeColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payments Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  'You haven\'t made any bid payments yet.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: RealTimeColors.grey500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payments will appear here after you:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: RealTimeColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 12,
                      color: RealTimeColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Win an auction',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: RealTimeColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 12,
                      color: RealTimeColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Make a payment for your won bid',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: RealTimeColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Go to auctions instead of bids
              Get.offAllNamed('/auctions');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Browse Auctions',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Get.toNamed('/my-bids');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: BorderSide(color: AppColors.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View My Bids',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final stats = _controller.getPaymentStatistics();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Paid',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BidPaymentHelper.formatCurrency(
                      _controller.totalPaidAmount,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
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
                    'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BidPaymentHelper.formatCurrency(
                      _controller.pendingPaymentAmount,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: RealTimeColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats grid
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatItem(
                value: stats['total']?.toString() ?? '0',
                label: 'Total',
                color: AppColors.primaryColor,
              ),
              _buildStatItem(
                value: stats['successful']?.toString() ?? '0',
                label: 'Paid',
                color: RealTimeColors.success,
              ),
              _buildStatItem(
                value: stats['pending']?.toString() ?? '0',
                label: 'Pending',
                color: RealTimeColors.warning,
              ),
              _buildStatItem(
                value: stats['failed']?.toString() ?? '0',
                label: 'Failed',
                color: RealTimeColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.subtextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(BidPayment payment) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.toNamed('/payment-details/${payment.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auction header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.auction.asset.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.auction.auctionNo,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Payment status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BidPaymentHelper.getPaymentStatusColor(
                        payment.statusText.toLowerCase(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      payment.statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Payment amount and method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        BidPaymentHelper.formatCurrency(payment.amount),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Method',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        BidPaymentHelper.getPaymentMethodDisplayName(
                          payment.method,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      if (payment.provider.isNotEmpty)
                        Text(
                          payment.provider,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Payment info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paid',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(payment.paidAt ?? payment.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        timeFormat.format(payment.paidAt ?? payment.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                    ],
                  ),
                  if (payment.receiptNo != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Receipt',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.receiptNo!,
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

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.toNamed('/payment-details/${payment.id}');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Bid Payments',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _refreshPayments,
                    icon: const Icon(Icons.refresh_outlined),
                    color: AppColors.textColor,
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search payments...',
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _clearSearch();
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _handleSearch,
              ),
            ),

            // Status filter chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: statusFilters.length,
                itemBuilder: (context, index) {
                  final status = statusFilters[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: _activeStatusFilter == status,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _activeStatusFilter = status;
                          } else {
                            _activeStatusFilter = null;
                          }
                        });

                        if (selected) {
                          if (status == 'All') {
                            _refreshPayments();
                          } else {
                            // Check if there are any payments first
                            if (_controller.bidPayments.isEmpty) {
                              BidPaymentHelper.showError(
                                'No payments to filter. You have no payments yet.',
                              );
                              setState(() {
                                _activeStatusFilter = null;
                              });
                              return;
                            }

                            // Use client-side filtering
                            final filtered = _filterPaymentsByStatus(status);
                            if (filtered.isNotEmpty) {
                              _controller.bidPayments.value = filtered;
                              BidPaymentHelper.showSuccess(
                                'Found ${filtered.length} ${status.toLowerCase()} payments',
                              );
                            } else {
                              BidPaymentHelper.showError(
                                'No ${status.toLowerCase()} payments found',
                              );
                              // Don't clear the filter - keep it selected but show empty state
                            }
                          }
                        } else {
                          // Deselected - show all
                          _refreshPayments();
                        }
                      },
                      backgroundColor: AppColors.surfaceColor,
                      selectedColor: AppColors.primaryColor.withOpacity(0.1),
                      labelStyle: GoogleFonts.poppins(
                        color: _activeStatusFilter == status
                            ? AppColors.primaryColor
                            : AppColors.subtextColor,
                        fontWeight: _activeStatusFilter == status
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _activeStatusFilter == status
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Summary card - NEEDS Obx to watch bidPayments
            Obx(() {
              if (_controller.bidPayments.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildSummaryCard();
            }),

            // Payments list - NEEDS Obx
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.bidPayments.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refreshPayments,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        _controller.bidPayments.length +
                        (_controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _controller.bidPayments.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }

                      return _buildPaymentCard(_controller.bidPayments[index]);
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
}
