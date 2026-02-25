import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/profile_mngmt_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onTap; // Add this line

  const ProfileHeader({
    super.key,
    required this.user,
    this.onTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Make CircleAvatar clickable
            GestureDetector(
              onTap: onTap, // Triggers when avatar is tapped
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: user.profilePicUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: user.profilePicUrl!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primaryColor,
                          ),
                  ),
                  // Add edit icon overlay
                  if (onTap != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullNameDisplay,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.primaryRole,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.subtextColor,
              ),
            ),
            if (user.isEmailVerified) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 14, color: AppColors.successColor),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Email',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DocumentItem extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap; // ✅ Keep onTap for opening documents

  const DocumentItem({
    super.key,
    required this.document,
    this.onTap, // ✅ Remove onDelete parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            // Default behavior: Show document details
            _showDocumentPreview(context);
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          children: [
            // Document Icon
            _buildDocumentIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.typeString,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    document.fileName,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.subtextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (document.notes != null && document.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        document.notes!,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.subtextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 12,
                        color: AppColors.subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(document.uploadedAt),
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: AppColors.subtextColor,
                        ),
                      ),
                      const Spacer(),
                      // Show file type label
                      if (document.mimeType.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getFileTypeLabel(document.mimeType),
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ DELETE BUTTON COMPLETELY REMOVED
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon() {
    // Different icons based on file type
    IconData icon;
    Color iconColor;

    if (document.mimeType.startsWith('image/')) {
      icon = Icons.image_outlined;
      iconColor = Colors.green;
    } else if (document.mimeType == 'application/pdf') {
      icon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.red;
    } else if (document.mimeType.contains('document') ||
        document.mimeType.contains('word')) {
      icon = Icons.description_outlined;
      iconColor = Colors.blue;
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = AppColors.primaryColor;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 24, color: iconColor),
    );
  }

  String _getFileTypeLabel(String mimeType) {
    if (mimeType.startsWith('image/')) return 'Image';
    if (mimeType == 'application/pdf') return 'PDF';
    if (mimeType.contains('document') || mimeType.contains('word'))
      return 'Doc';
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel'))
      return 'Excel';
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint'))
      return 'PPT';
    return 'File';
  }

  void _showDocumentPreview(BuildContext context) {
    // Show a bottom sheet with document options
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.remove_red_eye,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'Preview Document',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _openDocument(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.download_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'Download',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadDocument(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'Share',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _shareDocument(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: AppColors.errorColor),
              title: Text(
                'Cancel',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorColor,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.surfaceColor,
    );
  }

  void _openDocument(BuildContext context) async {
    // Check if URL is valid
    if (document.url.isEmpty || document.url == 'string') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(document.url);

      // For images, open in PhotoView
      if (document.mimeType.startsWith('image/')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(document.fileName)),
              body: Center(
                child: CachedNetworkImage(
                  imageUrl: document.url,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(color: AppColors.primaryColor),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline, color: Colors.red),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      } else {
        // For other files, try to open in browser
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open this file type'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadDocument(BuildContext context) {
    // Implement download logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Download functionality coming soon'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _shareDocument(BuildContext context) {
    // Implement share logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
