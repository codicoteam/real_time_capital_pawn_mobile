import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/config/routers/router.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/core/utils/shared_pref_methods.dart';
import 'package:real_time_pawn/features/profile_mngmt/controllers/profile_mngmt_controller.dart';
import 'package:real_time_pawn/widgets/custom_typography/typography.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomDrawer extends StatelessWidget {
  final ProfileController _profileController = Get.find<ProfileController>();

  CustomDrawer({super.key});

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
          // Drawer Header with profile - Now using Obx for reactive updates
          Obx(() {
            final user = _profileController.userProfile.value;

            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
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
                        // Profile Picture with exact same styling as ProfileScreen
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primaryColor.withOpacity(
                              0.1,
                            ),
                            backgroundImage: user?.profilePicUrl != null
                                ? CachedNetworkImageProvider(
                                    user!.profilePicUrl!,
                                  )
                                : null,
                            child: user?.profilePicUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.primaryColor,
                                  )
                                : null,
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                        const SizedBox(height: 12),

                        // User Name - Same animation and styling as ProfileScreen
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            user?.fullNameDisplay ?? 'Loading...',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ).animate().slideX(begin: -0.1).fadeIn(delay: 100.ms),
                        ),

                        const SizedBox(height: 4),

                        // User Email - Same animation and styling as ProfileScreen
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            user?.email ?? 'Loading...',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ).animate().slideX(begin: -0.1).fadeIn(delay: 200.ms),
                        ),

                        // Show loading indicator if profile is being fetched
                        if (_profileController.isLoading.value && user == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

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
                    onTap: () =>
                        _navigateAndClose(context, RoutesHelper.LoansScreen),
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

                  // Auctions
                  _buildDrawerItem(
                    icon: Icons.gavel,
                    title: 'Auctions',
                    color: RealTimeColors.grey800,
                    onTap: () => _navigateAndClose(
                      context,
                      RoutesHelper.auctionsListScreen,
                    ),
                  ).animate().fadeIn(delay: 460.ms),

                  // Bids
                  _buildDrawerItem(
                    icon: Icons.local_offer_outlined,
                    title: 'Bids',
                    color: RealTimeColors.success,
                    onTap: () =>
                        _navigateAndClose(context, RoutesHelper.myBidsScreen),
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
                    title: 'Loans Applications',
                    color: RealTimeColors.darkGreen,
                    onTap: () {
                      final userId =
                          _profileController.userProfile.value?.id ?? '';
                      _navigateAndClose(
                        context,
                        RoutesHelper.loanApplicationsScreen,
                        arguments: userId,
                      );
                    },
                  ).animate().fadeIn(delay: 520.ms),

                  // Payments
                  _buildDrawerItem(
                    icon: Icons.credit_card,
                    title: 'Loan Payments',
                    color: RealTimeColors.success,
                    onTap: () => _navigateAndClose(
                      context,
                      RoutesHelper.CustomerPaymentsScreen,
                    ),
                  ).animate().fadeIn(delay: 560.ms),

                  // Support
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Support',
                    color: RealTimeColors.warning,
                    onTap: () => _navigateAndClose(
                      context,
                      RoutesHelper.ticketListScreen,
                    ),
                  ).animate().fadeIn(delay: 580.ms),

                  const Divider(height: 32, indent: 20, endIndent: 20),

                  // Extra space at bottom
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

  void _navigateAndClose(
    BuildContext context,
    String route, {
    dynamic arguments,
  }) {
    Get.toNamed(route, arguments: arguments);
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
                final user = _profileController.userProfile.value;
                if (user != null) {
                  await _profileController.requestAccountDeletion(
                    email: user.email,
                  );
                }
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
