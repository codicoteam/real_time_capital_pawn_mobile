import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/loan_application_model.dart';
import 'package:real_time_pawn/models/attachment_model.dart';

import '../../../config/routers/router.dart' show RoutesHelper;
import '../../../models/attachment_model.dart' show AttachmentModel;
import '../../attached_files_mngmt/controllers/attached_files_mngmt_controller.dart'
    show AttachmentController;
import '../../attached_files_mngmt/helpers/attached_files_mngmt_helper.dart' show AttachmentHelper;
import '../helpers/update_attachments_dialog.dart';


// ---------------------------------------------------------------------
// Main LoanApplicationDetailsScreen
// ---------------------------------------------------------------------
class LoanApplicationDetailsScreen extends StatefulWidget {
  final LoanApplicationModel application;

  const LoanApplicationDetailsScreen({super.key, required this.application});

  @override
  State<LoanApplicationDetailsScreen> createState() =>
      _LoanApplicationDetailsScreenState();
}

class _LoanApplicationDetailsScreenState
    extends State<LoanApplicationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  // Attachment controller
  late final AttachmentController attachmentController;

  // Upload state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadMessage = '';

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showFab) {
        setState(() => _showFab = true);
        _fabController.forward();
      } else if (_scrollController.offset <= 200 && _showFab) {
        setState(() => _showFab = false);
        _fabController.reverse();
      }
    });

    // Initialize attachment controller and fetch data
    attachmentController = Get.put(AttachmentController());
    _fetchAttachments();
  }

  void _fetchAttachments() {
    attachmentController.fetchAttachmentsByUserAndEntity(
      userId: widget.application.customerUser!.id ?? '',
      entityType: 'LoanApplication',
      entityId: widget.application.id ?? '',
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    Get.delete<AttachmentController>(); // Clean up controller
    super.dispose();
  }

  // ------------------ Upload Methods ------------------
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _showAssetDetailsModal(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _showAssetUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildAssetUploadModal();
      },
    );
  }

  void _showAssetDetailsModal(File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return AssetDetailsModal(
          imageFile: imageFile,
          selectedLoanCategory: null, // or pass something if needed
          onAssetSaved: (assetName, serialNumber, conditionNotes) async {
            await _uploadAssetToSupabase(
              imageFile: imageFile,
              assetName: assetName,
              serialNumber: serialNumber,
              conditionNotes: conditionNotes,
            );
          },
        );
      },
    );
  }

  Future<void> _uploadAssetToSupabase({
    required File imageFile,
    required String assetName,
    required String serialNumber,
    required String conditionNotes,
  }) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadMessage = 'Preparing upload...';
    });

    try {
      // Step 1: Upload to Supabase Storage (Public bucket)
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${assetName.replaceAll(' ', '_')}.jpg';
      final filePath = 'attachments/$fileName';

      setState(() {
        _uploadProgress = 0.2;
        _uploadMessage = 'Uploading to storage...';
      });

      DevLogs.logInfo('📤 Uploading to storage: $filePath');

      await _supabase.storage
          .from('topics')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      DevLogs.logInfo('✅ File uploaded to storage');

      setState(() {
        _uploadProgress = 0.5;
        _uploadMessage = 'Getting public URL...';
      });

      final publicUrl = _supabase.storage.from('topics').getPublicUrl(filePath);
      DevLogs.logInfo('🔗 Public URL: $publicUrl');

      setState(() {
        _uploadProgress = 0.7;
        _uploadMessage = 'Registering attachment...';
      });

      // Prepare metadata
      final metaData =
          '{"asset_name":"$assetName","serial_number":"$serialNumber","condition_notes":"$conditionNotes"}';

      DevLogs.logInfo('💾 Registering attachment in database...');

      final attachmentModel = await AttachmentHelper.uploadAttachment(
        entityType: 'LoanApplication',
        entityId: widget.application.id ?? '',
        category: 'asset_photos', // or you can make this dynamic
        filename: fileName,
        mimeType: 'image/jpeg',
        storage: 'url',
        url: publicUrl,
        meta: metaData,
      );

      setState(() {
        _uploadProgress = 0.9;
        _uploadMessage = 'Finalizing...';
      });

      if (attachmentModel != null) {
        // Success: refresh attachments list
        await attachmentController.fetchAttachmentsByUserAndEntity(
          userId: widget.application.customerUser!.id ?? '',
          entityType: 'LoanApplication',
          entityId: widget.application.id ?? '',
        );

        setState(() {
          _uploadProgress = 1.0;
          _uploadMessage = 'Upload complete!';
        });

        DevLogs.logInfo('🎉 Asset uploaded successfully!');

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Attachment uploaded successfully!')),
                ],
              ),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to save attachment to database');
      }
    } on StorageException catch (e) {
      DevLogs.logError('❌ Storage Exception: ${e.toString()}');
      if (mounted) {
        String errorMessage = 'Upload failed: ';
        if (e.statusCode == '403' || e.statusCode == 403) {
          errorMessage +=
              'Access denied. Make sure the storage bucket is public in Supabase Dashboard.';
        } else {
          errorMessage += e.message;
        }
        _showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      DevLogs.logError('❌ General Exception: ${e.toString()}');
      if (mounted) {
        _showErrorSnackbar('Upload failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadMessage = '';
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildAssetUploadModal() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Attachment',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Choose an upload method',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.subtextColor,
            ),
          ),
          const SizedBox(height: 16),

          // Upload Options
          Row(
            children: [
              Expanded(
                child: _buildUploadOption(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can add asset details after selecting an image',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child:
            Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated circular progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: _uploadProgress,
                              strokeWidth: 10,
                              backgroundColor: AppColors.borderColor
                                  .withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                          Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_rounded,
                                  size: 45,
                                  color: AppColors.primaryColor,
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(
                                duration: 2000.ms,
                                color: AppColors.primaryColor.withOpacity(0.5),
                              )
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.15, 1.15),
                                duration: 1000.ms,
                              )
                              .then()
                              .scale(
                                begin: const Offset(1.15, 1.15),
                                end: const Offset(1, 1),
                                duration: 1000.ms,
                              ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Progress percentage
                      Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              letterSpacing: 2,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2000.ms,
                            color: AppColors.primaryColor.withOpacity(0.5),
                          ),
                      const SizedBox(height: 12),

                      // Upload message
                      Text(
                            _uploadMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fadeIn(duration: 1000.ms)
                          .then()
                          .fadeOut(duration: 1000.ms),
                      const SizedBox(height: 20),

                      // Linear progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 10,
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            backgroundColor: AppColors.borderColor.withOpacity(
                              0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Uploading steps indicator
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepIndicator(
                              'Storage',
                              _uploadProgress >= 0.5,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.subtextColor,
                            ),
                            const SizedBox(width: 6),
                            _buildStepIndicator(
                              'Database',
                              _uploadProgress >= 0.9,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.subtextColor,
                            ),
                            const SizedBox(width: 6),
                            _buildStepIndicator('Done', _uploadProgress >= 1.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryColor.withOpacity(0.2)
            : AppColors.borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.primaryColor
              : AppColors.borderColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Icon(Icons.check_circle, size: 12, color: AppColors.primaryColor),
          if (isActive) const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primaryColor : AppColors.subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Image Modal ------------------
  void _showImageModal(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ Helper methods (unchanged) ------------------
  String _formatCurrency(int? amount) {
    if (amount == null) return '\$0.00';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatCollateralCategory(String? category) {
    if (category == null || category.isEmpty) return 'N/A';
    switch (category.toLowerCase()) {
      case 'small_loans':
        return 'Small Loans';
      case 'motor_vehicle':
        return 'Motor Vehicle';
      case 'jewellery':
        return 'Jewellery';
      default:
        return category
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
      case 'under_review':
        return const Color(0xFFF57C00);
      case 'submitted':
      case 'pending':
        return const Color(0xFF1976D2);
      case 'approved':
        return const Color(0xFF388E3C);
      case 'rejected':
      case 'declined':
        return const Color(0xFFD32F2F);
      case 'cancelled':
        return const Color(0xFFC2185B);
      case 'draft':
        return const Color(0xFF616161);
      default:
        return RealTimeColors.grey700;
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
      case 'under_review':
        return const Color(0xFFFFF3E0);
      case 'submitted':
      case 'pending':
        return const Color(0xFFE3F2FD);
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'rejected':
      case 'declined':
        return const Color(0xFFFFEBEE);
      case 'cancelled':
        return const Color(0xFFFCE4EC);
      case 'draft':
        return const Color(0xFFF5F5F5);
      default:
        return RealTimeColors.grey200;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
      case 'under_review':
        return Icons.hourglass_empty_rounded;
      case 'submitted':
      case 'pending':
        return Icons.send_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
      case 'declined':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block_rounded;
      case 'draft':
        return Icons.edit_note_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  bool _isImageUrl(String? url) {
    if (url == null) return false;
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // ------------------ Build methods ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildStatusHeaderCard()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 500.ms),
                    const SizedBox(height: 24),
                    _buildAmountCard()
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 100.ms,
                          duration: 500.ms,
                        ),
                    const SizedBox(height: 24),

                    // Personal Information
                    _buildSection(
                          title: 'Personal Information',
                          icon: Icons.person_outline_rounded,
                          children: [
                            _buildInfoRow(
                              'Full Name',
                              widget.application.fullName ?? 'N/A',
                              Icons.badge_outlined,
                            ),
                            _buildInfoRow(
                              'National ID',
                              widget.application.nationalIdNumber ?? 'N/A',
                              Icons.credit_card_outlined,
                            ),
                            _buildInfoRow(
                              'Gender',
                              widget.application.gender ?? 'N/A',
                              Icons.wc_outlined,
                            ),
                            _buildInfoRow(
                              'Date of Birth',
                              _formatDateShort(widget.application.dateOfBirth),
                              Icons.cake_outlined,
                            ),
                            _buildInfoRow(
                              'Marital Status',
                              widget.application.maritalStatus ?? 'N/A',
                              Icons.favorite_outline_rounded,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 200.ms),
                    const SizedBox(height: 24),

                    // Contact Information
                    _buildSection(
                          title: 'Contact Information',
                          icon: Icons.contact_phone_outlined,
                          children: [
                            _buildInfoRow(
                              'Phone Number',
                              widget.application.contactDetails ?? 'N/A',
                              Icons.phone_outlined,
                            ),
                            _buildInfoRow(
                              'Alternative Number',
                              widget.application.alternativeNumber ?? 'N/A',
                              Icons.phone_android_outlined,
                            ),
                            _buildInfoRow(
                              'Email Address',
                              widget.application.emailAddress ?? 'N/A',
                              Icons.email_outlined,
                            ),
                            _buildInfoRow(
                              'Home Address',
                              widget.application.homeAddress ?? 'N/A',
                              Icons.home_outlined,
                              maxLines: 2,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 300.ms),
                    const SizedBox(height: 24),

                    // Employment Information
                    if (widget.application.employment != null)
                      _buildSection(
                            title: 'Employment Information',
                            icon: Icons.work_outline_rounded,
                            children: [
                              _buildInfoRow(
                                'Employment Type',
                                widget.application.employment?.employmentType ??
                                    'N/A',
                                Icons.business_center_outlined,
                              ),
                              _buildInfoRow(
                                'Job Title',
                                widget.application.employment?.title ?? 'N/A',
                                Icons.assignment_ind_outlined,
                              ),
                              _buildInfoRow(
                                'Duration',
                                widget.application.employment?.duration ??
                                    'N/A',
                                Icons.schedule_outlined,
                              ),
                              _buildInfoRow(
                                'Location',
                                widget.application.employment?.location ??
                                    'N/A',
                                Icons.location_on_outlined,
                              ),
                              _buildInfoRow(
                                'Contacts',
                                widget.application.employment?.contacts ??
                                    'N/A',
                                Icons.contacts_outlined,
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 400.ms),
                    if (widget.application.employment != null)
                      const SizedBox(height: 24),

                    // Loan Details
                    _buildSection(
                          title: 'Loan Details',
                          icon: Icons.account_balance_wallet_outlined,
                          children: [
                            _buildInfoRow(
                              'Application Number',
                              widget.application.applicationNo ?? 'N/A',
                              Icons.confirmation_number_outlined,
                            ),
                            _buildInfoRow(
                              'Requested Amount',
                              _formatCurrency(
                                widget.application.requestedLoanAmount,
                              ),
                              Icons.attach_money_rounded,
                              valueColor: AppColors.primaryColor,
                            ),
                            _buildInfoRow(
                              'Application Date',
                              _formatDateShort(widget.application.createdAt),
                              Icons.calendar_today_outlined,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 500.ms),
                    const SizedBox(height: 24),

                    // Collateral Information
                    _buildSection(
                          title: 'Collateral Information',
                          icon: Icons.security_outlined,
                          children: [
                            _buildInfoRow(
                              'Category',
                              _formatCollateralCategory(
                                widget.application.collateralCategory,
                              ),
                              Icons.category_outlined,
                            ),
                            if (widget.application.collateralDescription !=
                                null)
                              _buildInfoRow(
                                'Description',
                                widget.application.collateralDescription!,
                                Icons.description_outlined,
                                maxLines: 3,
                              ),
                            if (widget.application.declaredAssetValue != null)
                              _buildInfoRow(
                                'Declared Value',
                                _formatCurrency(
                                  widget.application.declaredAssetValue,
                                ),
                                Icons.monetization_on_outlined,
                                valueColor: AppColors.successColor,
                              ),
                            if (widget.application.suretyDescription != null)
                              _buildInfoRow(
                                'Surety',
                                widget.application.suretyDescription!,
                                Icons.person_add_outlined,
                                maxLines: 2,
                              ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 600.ms),
                    const SizedBox(height: 24),

                    // Uploaded Documents Section (Image URLs)
                    _buildUploadedDocumentsSection(),
                    const SizedBox(height: 24),

                    // Attachments Section (from AttachmentController) with Add button
                    _buildAttachmentsSection(),
                    const SizedBox(height: 24),

                    // Declaration
                    if (widget.application.declarationSignatureName != null)
                      _buildSection(
                            title: 'Declaration',
                            icon: Icons.verified_outlined,
                            children: [
                              if (widget.application.declarationText != null)
                                _buildInfoRow(
                                  'Agreement',
                                  widget.application.declarationText!,
                                  Icons.gavel_outlined,
                                  maxLines: 5,
                                ),
                              _buildInfoRow(
                                'Signed By',
                                widget.application.declarationSignatureName!,
                                Icons.draw_outlined,
                              ),
                              if (widget.application.declarationSignedAt !=
                                  null)
                                _buildInfoRow(
                                  'Signed Date',
                                  _formatDate(
                                    widget.application.declarationSignedAt,
                                  ),
                                  Icons.event_available_outlined,
                                ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 700.ms),
                    if (widget.application.declarationSignatureName != null)
                      const SizedBox(height: 24),

                    // Debtor Check
                    if (widget.application.debtorCheck?.checked == true)
                      _buildSection(
                            title: 'Debtor Check',
                            icon: Icons.fact_check_outlined,
                            children: [
                              _buildInfoRow(
                                'Status',
                                widget.application.debtorCheck!.matched == true
                                    ? 'Matched'
                                    : 'Clear',
                                widget.application.debtorCheck!.matched == true
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline_rounded,
                                valueColor:
                                    widget.application.debtorCheck!.matched ==
                                        true
                                    ? AppColors.warningColor
                                    : AppColors.successColor,
                              ),
                              if (widget.application.debtorCheck!.matched ==
                                  true)
                                _buildInfoRow(
                                  'Matched Records',
                                  '${widget.application.debtorCheck!.matchedDebtorRecords?.length ?? 0} record(s)',
                                  Icons.assignment_late_outlined,
                                  valueColor: AppColors.errorColor,
                                ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 800.ms),
                    if (widget.application.debtorCheck?.checked == true)
                      const SizedBox(height: 24),

                    // Internal Notes
                    if (widget.application.internalNotes != null &&
                        widget.application.internalNotes!.isNotEmpty)
                      _buildSection(
                            title: 'Internal Notes',
                            icon: Icons.note_outlined,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: RealTimeColors.grey100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.application.internalNotes!,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textColor,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 1000.ms),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Floating Edit Button
          _buildFloatingEditButton(),

          // Upload overlay
          if (_isUploading) _buildUploadingOverlay(),
        ],
      ),
    );
  }

  // Updated: document tiles are tappable to show image modal
  Widget _buildUploadedDocumentsSection() {
    final hasAny =
        widget.application.nationalIdUrl != null ||
        widget.application.passportUrl != null ||
        widget.application.proofOfResidentUrl != null ||
        widget.application.proofOfEmploymentUrl != null;

    if (!hasAny) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Uploaded Documents',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.application.nationalIdUrl != null)
            _buildDocumentTile(
              'National ID',
              widget.application.nationalIdUrl!,
            ),
          if (widget.application.passportUrl != null)
            _buildDocumentTile('Passport', widget.application.passportUrl!),
          if (widget.application.proofOfResidentUrl != null)
            _buildDocumentTile(
              'Proof of Residence',
              widget.application.proofOfResidentUrl!,
            ),
          if (widget.application.proofOfEmploymentUrl != null)
            _buildDocumentTile(
              'Proof of Employment',
              widget.application.proofOfEmploymentUrl!,
            ),
        ],
      ),
    );
  }

  // Tile for a single document URL – now tappable to show image
  Widget _buildDocumentTile(String title, String url) {
    return GestureDetector(
      onTap: () {
        if (_isImageUrl(url)) {
          _showImageModal(url);
        } else {
          // Optionally handle non-image files (e.g., open URL)
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RealTimeColors.grey400,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          children: [
            if (_isImageUrl(url))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: RealTimeColors.grey300,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url.split('/').last,
                    style: GoogleFonts.poppins(
                      color: AppColors.subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.subtextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Updated: Attachments section with Add button and tappable tiles
  Widget _buildAttachmentsSection() {
    return Obx(() {
      if (attachmentController.isLoading.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      // Even if empty, show a placeholder with add button
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Attachments',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                // Add Attachment Button
                GestureDetector(
                  onTap: _showAssetUploadModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (attachmentController.attachments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No attachments yet. Tap "Add" to upload.',
                    style: GoogleFonts.poppins(
                      color: AppColors.subtextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...attachmentController.attachments.map((attachment) {
                return _buildAttachmentTile(attachment);
              }),
          ],
        ),
      );
    });
  }

  // Tile for a single attachment – now tappable to show image
  Widget _buildAttachmentTile(AttachmentModel attachment) {
    final isImage = _isImageUrl(attachment.url);
    return GestureDetector(
      onTap: () {
        if (isImage && attachment.url != null) {
          _showImageModal(attachment.url!);
        } else {
          // Optionally handle non-image files (e.g., open URL)
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RealTimeColors.grey400,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          children: [
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  attachment.url!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: RealTimeColors.grey300,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.subtextColor,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.filename ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.category ?? 'Uncategorized',
                    style: GoogleFonts.poppins(
                      color: AppColors.subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.subtextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Remaining existing helper widgets (unchanged, except for minor naming)
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3, end: 0),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Application Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ).animate().fadeIn(delay: 200.ms),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(widget.application.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(widget.application.status),
              color: _getStatusColor(widget.application.status),
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Status',
                  style: GoogleFonts.poppins(
                    color: AppColors.subtextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatStatus(widget.application.status),
                  style: GoogleFonts.poppins(
                    color: _getStatusColor(widget.application.status),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().shimmer(
      delay: 800.ms,
      duration: 1500.ms,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Requested Loan Amount',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(widget.application.requestedLoanAmount),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Application #${widget.application.applicationNo ?? 'N/A'}',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().shimmer(
      delay: 1000.ms,
      duration: 1800.ms,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    int maxLines = 1,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RealTimeColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.subtextColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppColors.subtextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: valueColor ?? AppColors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingEditButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: ScaleTransition(
        scale: _fabController,
        child:
            FloatingActionButton.extended(
                  onPressed: () {
                    Get.toNamed(
                      RoutesHelper.updateLoanApplication,
                      arguments: widget.application,
                    );
                  },
                  backgroundColor: AppColors.primaryColor,
                  elevation: 8,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: Text(
                    'Edit Details',
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
      ),
    );
  }
}
