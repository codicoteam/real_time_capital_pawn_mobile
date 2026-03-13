import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/helpers/attached_files_mngmt_helper.dart';
import 'package:real_time_pawn/features/support_mngmt/controllers/support_mngmt_controller.dart';
import 'package:real_time_pawn/features/test/curved_edges.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketDetailScreen extends StatefulWidget {
  final SupportTicket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with TickerProviderStateMixin {
  final SupportTicketController _controller =
      Get.find<SupportTicketController>();
  late SupportTicket _ticket;
  bool _isLoading = false;

  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimationController.forward();
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refreshTicket() async {
    setState(() => _isLoading = true);
    try {
      final success = await _controller.getTicketById(_ticket.id);
      if (success && _controller.selectedTicket.value != null) {
        setState(() {
          _ticket = _controller.selectedTicket.value!;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAttachment() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      // Get user ID
      final userId = await CacheUtils.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      const bucket = 'topics';
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final filePath = 'support_attachments/${_ticket.id}/$fileName';

      String publicUrl;

      // Handle web vs mobile upload differently
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        await Supabase.instance.client.storage
            .from(bucket)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else {
        await Supabase.instance.client.storage
            .from(bucket)
            .upload(filePath, File(pickedFile.path));
      }

      publicUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(filePath);

      DevLogs.logInfo('✅ File uploaded: $publicUrl');

      // Create attachment record
      final metaData = json.encode({
        'uploaded_at': DateTime.now().toIso8601String(),
        'ticket_id': _ticket.id,
        'ticket_number': _ticket.ticketNo,
        'file_name': pickedFile.name,
        'purpose': 'support_attachment',
      });

      final attachmentModel = await AttachmentHelper.uploadAttachment(
        entityType: 'Ticket',
        entityId: _ticket.id,
        category: 'other',
        filename: fileName,
        mimeType: _getMimeType(pickedFile.name),
        storage: 'url',
        url: publicUrl,
        meta: metaData,
      );

      // Add to ticket - BUT DON'T USE THE HELPER'S LOADER
      if (attachmentModel != null && attachmentModel.id != null) {
        // ✅ Call controller directly instead of helper to avoid duplicate loading dialogs
        final success = await _controller.addAttachment(
          ticketId: _ticket.id,
          attachmentId: attachmentModel.id!,
        );

        if (success) {
          await _refreshTicket();
          Get.snackbar(
            'Success',
            'Attachment added successfully',
            backgroundColor: AppColors.successColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: 2000.ms,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to add attachment to ticket',
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to create attachment record',
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      DevLogs.logError('Upload failed: $e');
      Get.snackbar(
        'Error',
        'Failed to upload attachment: ${e.toString()}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      // ✅ This will ALWAYS run
      setState(() => _isLoading = false);
    }
  }

  String _getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  // ---- Helper methods (copied from TicketCard for consistency) ----
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
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final statusColor = _getStatusColor(_ticket.status);
    final priorityColor = _getPriorityColor(_ticket.priority);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Animated Header with curved bottom
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _headerAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -20 * (1 - _headerAnimationController.value),
                      ),
                      child: Opacity(
                        opacity: _headerAnimationController.value,
                        child: ClipPath(
                          clipper: TCustomCurvedEdges(),
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(_ticket.category),
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _ticket.ticketNo,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _ticket.subject,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content Section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Status & Priority Row
                    Row(
                          children: [
                            // Status Card
                            Expanded(
                              child: _buildGlassCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getStatusIcon(_ticket.status),
                                        color: statusColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.subtextColor,
                                            ),
                                          ),
                                          Text(
                                            _getStatusName(_ticket.status),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Priority Card
                            Expanded(
                              child: _buildGlassCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: priorityColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getPriorityName(_ticket.priority)[0],
                                          style: GoogleFonts.poppins(
                                            color: priorityColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Priority',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.subtextColor,
                                            ),
                                          ),
                                          Text(
                                            _getPriorityName(_ticket.priority),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: priorityColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate(controller: _contentAnimationController)
                        .fadeIn()
                        .slideY(
                          begin: 0.2,
                          duration: 400.ms,
                          curve: Curves.easeOutQuad,
                        ),

                    const SizedBox(height: 20),

                    // Details Card
                    _buildSectionCard(
                          title: 'Ticket Details',
                          icon: Icons.info_outline_rounded,
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Category',
                                _getCategoryName(_ticket.category),
                                icon: _getCategoryIcon(_ticket.category),
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildInfoRow(
                                'Customer',
                                _ticket.customerUser.email.isEmpty
                                    ? 'Not available'
                                    : _ticket.customerUser.email,
                                icon: Icons.person_outline_rounded,
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildInfoRow(
                                'Created',
                                dateFormat.format(_ticket.createdAt),
                                icon: Icons.calendar_today_outlined,
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildInfoRow(
                                'Last Updated',
                                '${_getTimeAgo(_ticket.updatedAt)} (${dateFormat.format(_ticket.updatedAt)})',
                                icon: Icons.update_rounded,
                              ),
                            ],
                          ),
                        )
                        .animate(controller: _contentAnimationController)
                        .fadeIn()
                        .slideY(
                          begin: 0.2,
                          delay: 100.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutQuad,
                        ),

                    const SizedBox(height: 20),

                    // Description Card
                    _buildSectionCard(
                          title: 'Description',
                          icon: Icons.description_outlined,
                          child: Text(
                            _ticket.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textColor,
                              height: 1.6,
                            ),
                          ),
                        )
                        .animate(controller: _contentAnimationController)
                        .fadeIn()
                        .slideY(
                          begin: 0.2,
                          delay: 200.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutQuad,
                        ),

                    const SizedBox(height: 20),

                    // Attachments Card
                    _buildSectionCard(
                          title: 'Attachments',
                          icon: Icons.attach_file_rounded,
                          child: _ticket.attachments.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.attachment_outlined,
                                          size: 48,
                                          color: AppColors.subtextColor
                                              .withOpacity(0.4),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No attachments',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppColors.subtextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _ticket.attachments.map((
                                    attachment,
                                  ) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.insert_drive_file_outlined,
                                          size: 20,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      title: Text(
                                        'Attachment',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'ID: ${attachment.substring(0, 8)}...',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.subtextColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        )
                        .animate(controller: _contentAnimationController)
                        .fadeIn()
                        .slideY(
                          begin: 0.2,
                          delay: 300.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutQuad,
                        ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),

          // Custom AppBar with back, attachment, and refresh buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Attachment button
                    if (!_isLoading)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _addAttachment,
                        ),
                      ),

                    const Spacer(),

                    // Refresh button
                    if (!_isLoading)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
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
                          onPressed: _refreshTicket,
                        ),
                      )
                    else
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a consistent card with subtle shadow and border
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.subtextColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.subtextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
