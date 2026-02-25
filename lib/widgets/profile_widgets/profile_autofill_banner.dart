// lib/widgets/profile_autofill_banner.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class ProfileAutofillBanner extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditProfile;

  const ProfileAutofillBanner({
    super.key,
    required this.userData,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final hasBasicInfo = userData['hasBasicInfo'] ?? false;
    final hasCompleteProfile = userData['hasCompleteProfile'] ?? false;
    final missingFields = userData['missingFields'] as List<String>? ?? [];
    final filledFields = _getFilledFields(userData);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBannerColor(hasBasicInfo, hasCompleteProfile),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(hasBasicInfo, hasCompleteProfile),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getBannerIcon(hasBasicInfo, hasCompleteProfile),
                color: _getIconColor(hasBasicInfo, hasCompleteProfile),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getBannerTitle(hasBasicInfo, hasCompleteProfile),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getBannerMessage(
              hasBasicInfo,
              hasCompleteProfile,
              filledFields,
              missingFields,
            ),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.subtextColor,
            ),
          ),

          if (missingFields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: missingFields.map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warningColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    field,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (!hasCompleteProfile) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onEditProfile,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Complete Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getFilledFields(Map<String, dynamic> userData) {
    List<String> filled = [];
    if (userData['fullName']?.toString().isNotEmpty == true) filled.add('Name');
    if (userData['email']?.toString().isNotEmpty == true) filled.add('Email');
    if (userData['phone']?.toString().isNotEmpty == true) filled.add('Phone');
    return filled;
  }

  Color _getBannerColor(bool hasBasicInfo, bool hasCompleteProfile) {
    if (hasCompleteProfile) {
      return AppColors.successColor.withOpacity(0.1);
    } else if (hasBasicInfo) {
      return AppColors.primaryColor.withOpacity(0.05);
    } else {
      return AppColors.warningColor.withOpacity(0.1);
    }
  }

  Color _getBorderColor(bool hasBasicInfo, bool hasCompleteProfile) {
    if (hasCompleteProfile) {
      return AppColors.successColor.withOpacity(0.3);
    } else if (hasBasicInfo) {
      return AppColors.primaryColor.withOpacity(0.2);
    } else {
      return AppColors.warningColor.withOpacity(0.3);
    }
  }

  Color _getIconColor(bool hasBasicInfo, bool hasCompleteProfile) {
    if (hasCompleteProfile) {
      return AppColors.successColor;
    } else if (hasBasicInfo) {
      return AppColors.primaryColor;
    } else {
      return AppColors.warningColor;
    }
  }

  IconData _getBannerIcon(bool hasBasicInfo, bool hasCompleteProfile) {
    if (hasCompleteProfile) {
      return Icons.check_circle;
    } else if (hasBasicInfo) {
      return Icons.info_outline;
    } else {
      return Icons.warning_amber;
    }
  }

  String _getBannerTitle(bool hasBasicInfo, bool hasCompleteProfile) {
    if (hasCompleteProfile) {
      return 'Profile data auto-filled';
    } else if (hasBasicInfo) {
      return 'Basic info auto-filled';
    } else {
      return 'Incomplete profile detected';
    }
  }

  String _getBannerMessage(
    bool hasBasicInfo,
    bool hasCompleteProfile,
    List<String> filledFields,
    List<String> missingFields,
  ) {
    if (hasCompleteProfile) {
      return 'Your profile information has been auto-filled. Verify the details.';
    } else if (hasBasicInfo) {
      final filledText = filledFields.join(', ');
      if (missingFields.isNotEmpty) {
        final missingText = missingFields.join(', ');
        return '$filledText auto-filled. Add $missingText to complete profile for faster applications.';
      }
      return '$filledText auto-filled. Complete your profile for faster applications.';
    } else {
      return 'Complete your profile to enable auto-fill for faster applications.';
    }
  }
}
