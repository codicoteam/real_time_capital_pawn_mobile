import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/screens/asset_upload_section.dart'
    show UploadedAsset, AssetUploadSection;
import 'package:real_time_pawn/widgets/custom_button.dart';
import 'package:real_time_pawn/core/utils/api_response.dart';
import 'package:real_time_pawn/core/utils/logs.dart';
import 'package:real_time_pawn/models/attachment_model.dart';
import 'package:real_time_pawn/features/attached_files_mngmt/services/attached_files_mngmt_service.dart'
    show AttachmentService;

class LoanApplicationUploadScreen extends StatefulWidget {
  final String loanId;
  final String loanCategory;
  final String applicationNo;
  final String userId; // Add user ID for API calls

  const LoanApplicationUploadScreen({
    super.key,
    required this.loanId,
    required this.loanCategory,
    required this.applicationNo,
    required this.userId,
  });

  @override
  State<LoanApplicationUploadScreen> createState() =>
      _LoanApplicationUploadScreenState();
}

class _LoanApplicationUploadScreenState
    extends State<LoanApplicationUploadScreen> {
  final List<UploadedAsset> _uploadedAssets = [];
  bool _canProceed = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchExistingAttachments();
  }

  Future<void> _fetchExistingAttachments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final APIResponse<List<AttachmentModel>> response =
          await AttachmentService.getAttachmentsByUserAndEntity(
            userId: widget.userId,
            entityType: 'LoanApplication',
            entityId: widget.loanId, // ADD THIS
          );

      if (response.success && response.data != null) {
        // Convert AttachmentModel to UploadedAsset
        final List<UploadedAsset> existingAssets = response.data!.map((
          attachment,
        ) {
          return UploadedAsset(
            id: attachment.id,
            category: attachment.category,
            filename: attachment.filename,
            mimeType: attachment.mimeType,
            url: attachment.url,
            meta: attachment.meta,
            createdAt: attachment.createdAt,
          );
        }).toList();

        setState(() {
          _uploadedAssets.clear();
          _uploadedAssets.addAll(existingAssets);
          _canProceed = _uploadedAssets.isNotEmpty;
          _successMessage = response.message ?? 'Loaded existing attachments';
        });

        // Show success message
        _showSuccessSnackbar(_successMessage);
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load attachments';
        });
        _showErrorSnackbar(_errorMessage);
      }
    } catch (e) {
      DevLogs.logError('Error fetching attachments: $e');
      setState(() {
        _errorMessage = 'Error fetching attachments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAttachment(String attachmentId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // You'll need to implement deleteAttachment in AttachmentService
      // For now, we'll just remove from UI
      setState(() {
        _uploadedAssets.removeWhere((asset) => asset.id == attachmentId);
        _canProceed = _uploadedAssets.isNotEmpty;
      });

      _showSuccessSnackbar('Attachment removed successfully');

      // TODO: Call API delete endpoint
      // await AttachmentService.deleteAttachment(attachmentId);
    } catch (e) {
      DevLogs.logError('Error deleting attachment: $e');
      setState(() {
        _errorMessage = 'Error deleting attachment: ${e.toString()}';
      });
      _showErrorSnackbar(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showAttachmentDetails(UploadedAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.attach_file, color: AppColors.primaryColor),
            SizedBox(width: 12),
            Text(
              'Attachment Details',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAttachmentDetailRow('Filename', asset.filename ?? 'N/A'),
              _buildAttachmentDetailRow('Category', asset.category ?? 'N/A'),
              _buildAttachmentDetailRow('Type', asset.mimeType ?? 'N/A'),
              if (asset.createdAt != null)
                _buildAttachmentDetailRow(
                  'Uploaded',
                  '${asset.createdAt!.toLocal()}',
                ),
              if (asset.meta != null && asset.meta!.isNotEmpty)
                _buildAttachmentDetailRow('Metadata', asset.meta!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (asset.id != null)
            CustomButton(
              btnColor: AppColors.errorColor.withOpacity(0.1),
              borderRadius: 12,
              width: 120, // ADD THIS
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteAttachment(asset.id!);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: AppColors.errorColor,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeleteAttachment(String attachmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warningColor),
            SizedBox(width: 12),
            Text(
              'Delete Attachment?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        content: Text(
          'This attachment will be permanently deleted. This action cannot be undone.',
          style: GoogleFonts.poppins(color: AppColors.subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CustomButton(
            btnColor: AppColors.errorColor,
            borderRadius: 12,
            width: 120, // ADD THIS
            onTap: () {
              Navigator.pop(context);
              _deleteAttachment(attachmentId);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textColor,
              fontWeight: FontWeight.w600,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Documents',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Application #${widget.applicationNo}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: RealTimeColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth, // 100% complete
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading && _uploadedAssets.isEmpty
                ? _buildLoadingState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Success Message Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.successColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColors.successColor,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Application Submitted!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.successColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your loan application has been created successfully.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // Instructions Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Next Step: Upload Documents',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Please upload clear photos of your collateral and any supporting documents. This helps us process your application faster.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.subtextColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTip(
                                icon: Icons.camera_alt,
                                text: 'Take clear, well-lit photos',
                              ),
                              const SizedBox(height: 8),
                              _buildTip(
                                icon: Icons.description,
                                text: 'Include all relevant documents',
                              ),
                              const SizedBox(height: 8),
                              _buildTip(
                                icon: Icons.image,
                                text: 'You can upload multiple photos',
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // Asset Upload Section
                        AssetUploadSection(
                          uploadedAssets: _uploadedAssets,
                          selectedLoanCategory: widget.loanCategory,
                          entityType: 'LoanApplication',
                          entityId: widget.loanId,
                          onAssetsUpdated: (List<UploadedAsset> updatedAssets) {
                            setState(() {
                              _uploadedAssets.clear();
                              _uploadedAssets.addAll(updatedAssets);
                              _canProceed = _uploadedAssets.isNotEmpty;
                            });
                          },
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // Attachment List (for existing attachments from API)
                        if (_uploadedAssets.isNotEmpty &&
                            _uploadedAssets.any((a) => a.id != null))
                          _buildExistingAttachmentsList()
                              .animate()
                              .fadeIn(delay: 350.ms)
                              .slideY(begin: 0.1),

                        // Upload Stats Card
                        if (_uploadedAssets.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.cloud_done,
                                      color: AppColors.successColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Upload Summary',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow(
                                  icon: Icons.photo_library,
                                  label: 'Total Files',
                                  value: '${_uploadedAssets.length}',
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  icon: Icons.check_circle,
                                  label: 'Status',
                                  value: _canProceed
                                      ? 'Ready to Submit'
                                      : 'Upload Required',
                                  valueColor: _canProceed
                                      ? AppColors.successColor
                                      : AppColors.warningColor,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  icon: Icons.cloud_upload,
                                  label: 'API Registered',
                                  value:
                                      '${_uploadedAssets.where((a) => a.id != null).length}',
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Complete Application Button
            CustomButton(
              btnColor: _canProceed
                  ? AppColors.primaryColor
                  : RealTimeColors.grey300,
              width: double.infinity,
              borderRadius: 12,
              onTap: _canProceed ? _completeApplication : () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _canProceed ? Colors.white : RealTimeColors.grey600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Complete Application',
                    style: GoogleFonts.poppins(
                      color: _canProceed
                          ? Colors.white
                          : RealTimeColors.grey600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Skip for Now Button
            TextButton(
              onPressed: _skipForNow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.subtextColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Skip for Now (Upload Later)',
                    style: GoogleFonts.poppins(
                      color: AppColors.subtextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _canProceed
                  ? 'Our team will review within 24-48 hours'
                  : 'Upload at least one photo to continue',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _canProceed
                    ? AppColors.subtextColor
                    : AppColors.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
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
          const SizedBox(height: 20),
          Text(
            'Loading attachments...',
            style: GoogleFonts.poppins(
              color: AppColors.subtextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingAttachmentsList() {
    final existingAssets = _uploadedAssets.where((a) => a.id != null).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attachment, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Previously Uploaded Attachments',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...existingAssets.map((asset) {
            return GestureDetector(
              onTap: () => _showAttachmentDetails(asset),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.filename ?? 'Unnamed File',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asset.category ?? 'General',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.subtextColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTip({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.subtextColor,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textColor,
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warningColor),
            const SizedBox(width: 12),
            Text(
              'Exit Upload?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        content: Text(
          'Your application has been saved. You can upload documents later from your applications list.',
          style: GoogleFonts.poppins(color: AppColors.subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CustomButton(
            btnColor: AppColors.primaryColor,
            borderRadius: 12,
            width: double.infinity,
            onTap: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(
              'Exit',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeApplication() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.successColor, size: 32),
            const SizedBox(width: 12),
            Text(
              'Success!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your loan application has been completed successfully with ${_uploadedAssets.length} document(s).',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Number',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.applicationNo,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Our team will review your application and contact you within 24-48 hours.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.subtextColor,
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            btnColor: AppColors.primaryColor,
            borderRadius: 12,
            width: double.infinity,
            onTap: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to main screen
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _skipForNow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryColor),
            const SizedBox(width: 12),
            Text(
              'Skip Upload?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        content: Text(
          'You can upload documents later from your applications list. However, applications with documents are processed faster.',
          style: GoogleFonts.poppins(color: AppColors.subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.subtextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CustomButton(
            btnColor: AppColors.primaryColor,
            borderRadius: 12,
            width: double.infinity, // ADD THIS
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
