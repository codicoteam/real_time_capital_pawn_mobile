import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/support_mngmt/controllers/support_mngmt_controller.dart';
import 'package:real_time_pawn/features/support_mngmt/helpers/support_mngmt_helper.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final SupportTicketController _controller = Get.put(
    SupportTicketController(),
  );
  final TextEditingController _searchController = TextEditingController();

  String _customerId = '';
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _getCustomerIdAndLoadTickets();
  }

  Future<void> _getCustomerIdAndLoadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get customerId from cache (saved during login)
      _customerId = await CacheUtils.getUserId() ?? '';

      if (_customerId.isEmpty) {
        print('ERROR: No customerId found in cache!');
        // Show error to user
        Get.snackbar(
          'Error',
          'Unable to load tickets. Please login again.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      print('Loading tickets for customerId: $_customerId');

      // Load tickets with the customerId
      await SupportTicketHelper.getCustomerTickets(
        customerId: _customerId,
        showLoader: false,
      );
    } catch (e) {
      print('Error loading tickets: $e');
      Get.snackbar(
        'Error',
        'Failed to load tickets: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Helper functions since model doesn't have display properties
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
          return Icons.money;
        case TicketCategory.payment:
          return Icons.payment;
        case TicketCategory.auction:
          return Icons.gavel;
        case TicketCategory.account:
          return Icons.person;
        case TicketCategory.technical:
          return Icons.settings;
        case TicketCategory.general:
          return Icons.help;
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
          return Colors.orange;
        case TicketStatus.in_progress:
          return Colors.blue;
        case TicketStatus.resolved:
          return Colors.green;
        case TicketStatus.closed:
          return Colors.grey;
      }
    }

    String _getPriorityName(TicketPriority priority) {
      switch (priority) {
        case TicketPriority.low:
          return 'Low';
        case TicketPriority.medium:
          return 'Medium';
        case TicketPriority.high:
          return 'High';
        case TicketPriority.urgent:
          return 'Urgent';
      }
    }

    Color _getPriorityColor(TicketPriority priority) {
      switch (priority) {
        case TicketPriority.low:
          return Colors.green;
        case TicketPriority.medium:
          return Colors.blue;
        case TicketPriority.high:
          return Colors.orange;
        case TicketPriority.urgent:
          return Colors.red;
      }
    }

    // Helper for time ago display
    String _getTimeAgo(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    }

    // Status badge widget
    Widget _getStatusBadge(TicketStatus status) {
      final statusColor = _getStatusColor(status);
      final statusName = _getStatusName(status);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Text(
          statusName,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => SupportTicketHelper.navigateToTicketDetails(ticket.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.ticketNo,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.subject,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _getStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 12),

              // Category and Priority
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(ticket.category),
                    size: 16,
                    color: AppColors.subtextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryName(ticket.category),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(ticket.priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPriorityName(ticket.priority),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _getPriorityColor(ticket.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description preview
              Text(
                ticket.description.length > 100
                    ? '${ticket.description.substring(0, 100)}...'
                    : ticket.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      Text(
                        '${dateFormat.format(ticket.createdAt)} • ${timeFormat.format(ticket.createdAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _getTimeAgo(ticket.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Support Tickets',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You haven\'t created any support tickets yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: SupportTicketHelper.navigateToCreateTicket,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Your First Ticket',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Support Tickets',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (_customerId.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                await SupportTicketHelper.getCustomerTickets(
                  customerId: _customerId,
                  showLoader: false,
                );
                setState(() {
                  _isLoading = false;
                });
              } else {
                // If no customerId, try to get it again
                await _getCustomerIdAndLoadTickets();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: SupportTicketHelper.navigateToCreateTicket,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tickets...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          // Reload tickets without search
                          if (_customerId.isNotEmpty) {
                            _getCustomerIdAndLoadTickets();
                          }
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
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  setState(() {
                    _isSearching = true;
                  });
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      SupportTicketHelper.searchTickets(value).then((_) {
                        setState(() {
                          _isSearching = false;
                        });
                      });
                    }
                  });
                } else if (value.isEmpty && _customerId.isNotEmpty) {
                  // Clear search and reload all tickets
                  _getCustomerIdAndLoadTickets();
                }
              },
            ),
          ),

          // Loading indicator
          if (_isLoading || _isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            // Tickets List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_customerId.isNotEmpty) {
                    await SupportTicketHelper.getCustomerTickets(
                      customerId: _customerId,
                    );
                  }
                },
                child: Obx(() {
                  if (_controller.tickets.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _controller.tickets.length,
                    itemBuilder: (context, index) {
                      return _buildTicketCard(_controller.tickets[index]);
                    },
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
