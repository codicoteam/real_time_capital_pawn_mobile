import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/widgets/custom_typography/typography.dart';

class CustomDrawer extends StatelessWidget {
  final String? profileImageUrl;
  final String userName;
  final String userEmail;
  final String userId;

  const CustomDrawer({
    super.key,
    this.profileImageUrl,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.2;
    final minHeaderHeight = 200.0;
    final effectiveHeaderHeight = headerHeight.clamp(minHeaderHeight, 250.0);

    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: Column(
        children: [
          // Drawer Header with profile
          GestureDetector(
            onTap: () {
              Get.toNamed(RoutesHelper.profileScreen);
            },
            child: Container(
              height: effectiveHeaderHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Picture with fallback
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: profileImageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildProfileFallback(),
                                ),
                              )
                            : _buildProfileFallback(),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 12),
                      // User Name with overflow protection
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          userName,
                          style: CustomTypography.nunitoTextTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ).animate().slideX(begin: -0.1).fadeIn(delay: 100.ms),
                      ),
                      const SizedBox(height: 4),
                      // User Email with overflow protection
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ).animate().slideX(begin: -0.1).fadeIn(delay: 200.ms),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Drawer Items with flexible space
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // About
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    color: RealTimeColors.primaryGreen,
                    onTap: () => _navigateAndClose(context, '/about'),
                  ).animate().fadeIn(delay: 300.ms),

                  // Loans
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Loans',
                    color: RealTimeColors.primaryGreen,
                    onTap: () => _navigateAndClose(context, '/loans'),
                  ).animate().fadeIn(delay: 400.ms),

                  // Bid Payment
                  _buildDrawerItem(
                    icon: Icons.payment,
                    title: 'Bid Payments',
                    color: RealTimeColors.success,
                    onTap: () => _navigateAndClose(
                      context,
                      RoutesHelper.myBidPaymentsScreen,
                    ),
                  ).animate().fadeIn(delay: 360.ms),

                  // Notifications
                  _buildDrawerItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    color: RealTimeColors.error,
                    onTap: () => _navigateAndClose(context, '/notifications'),
                  ).animate().fadeIn(delay: 420.ms),

                  // Auctions
                  _buildDrawerItem(
                    icon: Icons.gavel,
                    title: 'Auctions',
                    color: RealTimeColors.grey800,
                    onTap: () => Get.toNamed(
                      RoutesHelper.auctionsListScreen,
                    ), // Changed this
                  ).animate().fadeIn(delay: 460.ms),

                  // Bids
                  _buildDrawerItem(
                    icon: Icons.local_offer_outlined,
                    title: 'Bids',
                    color: RealTimeColors.success,
                    onTap: () => _navigateAndClose(context, '/my-bids'),
                  ).animate().fadeIn(delay: 480.ms),

                  // FAQ
                  _buildDrawerItem(
                    icon: Icons.question_answer_outlined,
                    title: 'FAQ',
                    color: RealTimeColors.primaryGreen,
                    onTap: () => _navigateAndClose(context, '/faq'),
                  ).animate().fadeIn(delay: 500.ms),

                  // Loan Application
                  _buildDrawerItem(
                    icon: Icons.article_outlined,
                    title: 'Loans Status',
                    color: RealTimeColors.darkGreen,
                    onTap: () => _navigateAndClose(
                      context,
                      RoutesHelper.loanApplicationsScreen,
                    ),
                  ).animate().fadeIn(delay: 520.ms),

                  // Payments
                  _buildDrawerItem(
                    icon: Icons.credit_card,
                    title: 'Loan Payments',
                    color: RealTimeColors.success,
                    onTap: () => _navigateAndClose(context, '/payments'),
                  ).animate().fadeIn(delay: 560.ms),

                  // Support
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Support',
                    color: RealTimeColors.warning,
                    onTap: () => _navigateAndClose(context, '/support'),
                  ).animate().fadeIn(delay: 580.ms),

                  const Divider(height: 32, indent: 20, endIndent: 20),

                  // Extra space at bottom to prevent button overlap
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ),
          ),

          // Logout Button (fixed at bottom)
          _buildLogoutButton(context).animate().fadeIn(delay: 620.ms),
        ],
      ),
    );
  }

  Widget _buildProfileFallback() {
    return const Icon(Icons.person, color: Colors.white, size: 40);
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: CustomTypography.nunitoTextTheme.bodyMedium?.copyWith(
          color: AppColors.textColor,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, size: 18),
        label: Text(
          'Logout',
          style: CustomTypography.nunitoTextTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _navigateAndClose(BuildContext context, String route) {
    Get.toNamed(route);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.zero,
          shadowColor: Colors.grey.withOpacity(0.2),
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Account Options',
                    style: CustomTypography.nunitoTextTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an option below',
                    style: CustomTypography.nunitoTextTheme.bodyMedium
                        ?.copyWith(color: AppColors.subtextColor),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      onPressed: () async {
                        await CacheUtils.clearCachedToken();
                        Get.offAllNamed(RoutesHelper.loginScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delete Account Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Delete Account'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDeleteAccountConfirmation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.subtextColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'Delete Account',
                style: CustomTypography.nunitoTextTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
                'Are you absolutely sure you want to delete your account?',
                style: CustomTypography.nunitoTextTheme.bodyMedium?.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone. All your data will be permanently removed.',
                style: CustomTypography.nunitoTextTheme.bodySmall?.copyWith(
                  color: AppColors.subtextColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.subtextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.pop(context);
                // await AuthHelper.validateAndDeleteUser(userId: userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
}
