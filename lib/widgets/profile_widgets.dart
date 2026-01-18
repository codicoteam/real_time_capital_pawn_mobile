import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import '../models/profile_models.dart';

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
  final VoidCallback onDelete;

  const DocumentItem({
    super.key,
    required this.document,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 24,
              color: AppColors.primaryColor,
            ),
          ),
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
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.errorColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
