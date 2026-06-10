// lib/features/profile_mngmt/screens/edit_profile_screen.dart
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImageProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/profile_mngmt/helpers/profile_mngmt_helper.dart';
import 'package:real_time_pawn/features/test/curved_edges_widget.dart';
import 'package:real_time_pawn/models/profile_mngmt_model.dart';
import 'package:real_time_pawn/models/register_body_model.dart' as register_model;

import '../controllers/profile_mngmt_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  // Controllers for edit form
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController dateOfBirthCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController alternativePhoneCtrl;
  late TextEditingController nationalIdNumberCtrl;

  // Employment controllers
  late TextEditingController employerNameCtrl;
  late TextEditingController jobTitleCtrl;
  late TextEditingController employmentDurationCtrl;
  late TextEditingController employmentLocationCtrl;
  late TextEditingController employmentContactsCtrl;

  // Next of Kin controllers
  late TextEditingController nextOfKinNameCtrl;
  late TextEditingController nextOfKinRelationshipCtrl;
  late TextEditingController nextOfKinPhoneCtrl;
  late TextEditingController nextOfKinEmailCtrl;
  late TextEditingController nextOfKinAddressCtrl;

  // Dropdown values
  String? _selectedGender;
  String? _selectedMaritalStatus;
  bool _isEmployed = false;
  bool _showEmploymentFields = false;
  bool _showNextOfKinFields = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _updateControllersFromUser(widget.userProfile);
  }

  void _initializeControllers() {
    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    dateOfBirthCtrl = TextEditingController();
    addressCtrl = TextEditingController();
    locationCtrl = TextEditingController();
    alternativePhoneCtrl = TextEditingController();
    nationalIdNumberCtrl = TextEditingController();

    employerNameCtrl = TextEditingController();
    jobTitleCtrl = TextEditingController();
    employmentDurationCtrl = TextEditingController();
    employmentLocationCtrl = TextEditingController();
    employmentContactsCtrl = TextEditingController();

    nextOfKinNameCtrl = TextEditingController();
    nextOfKinRelationshipCtrl = TextEditingController();
    nextOfKinPhoneCtrl = TextEditingController();
    nextOfKinEmailCtrl = TextEditingController();
    nextOfKinAddressCtrl = TextEditingController();
  }

  void _updateControllersFromUser(UserProfile user) {
    firstNameCtrl.text = user.firstName ?? '';
    lastNameCtrl.text = user.lastName ?? '';
    phoneCtrl.text = user.phone ?? '';
    dateOfBirthCtrl.text = user.dateOfBirth != null
        ? DateFormat('yyyy-MM-dd').format(user.dateOfBirth!)
        : '';
    addressCtrl.text = user.address ?? '';
    locationCtrl.text = user.location ?? '';
    _selectedGender = user.gender;
    _selectedMaritalStatus = user.maritalStatus;
    alternativePhoneCtrl.text = user.alternativePhone ?? '';
    nationalIdNumberCtrl.text = user.nationalIdNumber ?? '';

    _isEmployed = user.isEmployed ?? false;
    _showEmploymentFields = _isEmployed;

    if (user.employmentDetails != null) {
      employerNameCtrl.text = user.employmentDetails!.employerName ?? '';
      jobTitleCtrl.text = user.employmentDetails!.jobTitle ?? '';
      employmentDurationCtrl.text = user.employmentDetails!.duration ?? '';
      employmentLocationCtrl.text = user.employmentDetails!.location ?? '';
      employmentContactsCtrl.text = user.employmentDetails!.contacts ?? '';
    }

    _showNextOfKinFields = user.nextOfKin != null;
    if (user.nextOfKin != null) {
      nextOfKinNameCtrl.text = user.nextOfKin!.fullName ?? '';
      nextOfKinRelationshipCtrl.text = user.nextOfKin!.relationship ?? '';
      nextOfKinPhoneCtrl.text = user.nextOfKin!.phoneNumber ?? '';
      nextOfKinEmailCtrl.text = user.nextOfKin!.email ?? '';
      nextOfKinAddressCtrl.text = user.nextOfKin!.address ?? '';
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> saveProfile() async {
    if (firstNameCtrl.text.trim().isEmpty) {
      ProfileMngmtHelper.showError('First name is required');
      return;
    }

    if (lastNameCtrl.text.trim().isEmpty) {
      ProfileMngmtHelper.showError('Last name is required');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Build EmploymentDetails if employed
      EmploymentDetails? employmentDetails;
      if (_isEmployed && _showEmploymentFields) {
        employmentDetails = EmploymentDetails(
          employerName: employerNameCtrl.text.trim().isNotEmpty
              ? employerNameCtrl.text.trim()
              : null,
          jobTitle: jobTitleCtrl.text.trim().isNotEmpty
              ? jobTitleCtrl.text.trim()
              : null,
          duration: employmentDurationCtrl.text.trim().isNotEmpty
              ? employmentDurationCtrl.text.trim()
              : null,
          location: employmentLocationCtrl.text.trim().isNotEmpty
              ? employmentLocationCtrl.text.trim()
              : null,
          contacts: employmentContactsCtrl.text.trim().isNotEmpty
              ? employmentContactsCtrl.text.trim()
              : null,
        );
      }

      // Build NextOfKin if enabled
      NextOfKin? nextOfKin;
      if (_showNextOfKinFields) {
        nextOfKin = NextOfKin(
          fullName: nextOfKinNameCtrl.text.trim().isNotEmpty
              ? nextOfKinNameCtrl.text.trim()
              : null,
          relationship: nextOfKinRelationshipCtrl.text.trim().isNotEmpty
              ? nextOfKinRelationshipCtrl.text.trim()
              : null,
          phoneNumber: nextOfKinPhoneCtrl.text.trim().isNotEmpty
              ? nextOfKinPhoneCtrl.text.trim()
              : null,
          email: nextOfKinEmailCtrl.text.trim().isNotEmpty
              ? nextOfKinEmailCtrl.text.trim()
              : null,
          address: nextOfKinAddressCtrl.text.trim().isNotEmpty
              ? nextOfKinAddressCtrl.text.trim()
              : null,
        );
      }

      // Parse date of birth
      DateTime? dateOfBirth;
      if (dateOfBirthCtrl.text.trim().isNotEmpty) {
        dateOfBirth = DateTime.tryParse(dateOfBirthCtrl.text.trim());
      }

      // Create RegisterBodyModel
      final registerBody = register_model.RegisterBodyModel(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
        dateOfBirth: dateOfBirth,
        address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
        location: locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : null,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        alternativePhone: alternativePhoneCtrl.text.trim().isNotEmpty
            ? alternativePhoneCtrl.text.trim()
            : null,
        nationalIdNumber: nationalIdNumberCtrl.text.trim().isNotEmpty
            ? nationalIdNumberCtrl.text.trim()
            : null,
        isEmployed: _isEmployed,
        employmentDetails: employmentDetails != null
            ? register_model.EmploymentDetails(
                employerName: employmentDetails.employerName,
                jobTitle: employmentDetails.jobTitle,
                duration: employmentDetails.duration,
                location: employmentDetails.location,
                contacts: employmentDetails.contacts,
              )
            : null,
        nextOfKin: nextOfKin != null
            ? register_model.NextOfKin(
                fullName: nextOfKin.fullName,
                relationship: nextOfKin.relationship,
                phoneNumber: nextOfKin.phoneNumber,
                email: nextOfKin.email,
                address: nextOfKin.address,
              )
            : null,
      );

      final success = await ProfileMngmtHelper.updateProfileWithModel(
        profileData: registerBody,
      );

      if (success) {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().fetchUserProfile();
        }
        Get.back();
        ProfileMngmtHelper.showSuccess('Profile updated successfully');
      }
    } catch (e) {
      ProfileMngmtHelper.showError('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    dateOfBirthCtrl.dispose();
    addressCtrl.dispose();
    locationCtrl.dispose();
    alternativePhoneCtrl.dispose();
    nationalIdNumberCtrl.dispose();
    employerNameCtrl.dispose();
    jobTitleCtrl.dispose();
    employmentDurationCtrl.dispose();
    employmentLocationCtrl.dispose();
    employmentContactsCtrl.dispose();
    nextOfKinNameCtrl.dispose();
    nextOfKinRelationshipCtrl.dispose();
    nextOfKinPhoneCtrl.dispose();
    nextOfKinEmailCtrl.dispose();
    nextOfKinAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                TCurvedEdgeWidget(
                  child: Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2F855A), Color(0xFF38A169)],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                                onPressed: () => Get.back(),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Edit Profile',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(width: 40, height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: widget.userProfile.profilePicUrl != null
                              ? CachedNetworkImageProvider(widget.userProfile.profilePicUrl!)
                              : null,
                          child: widget.userProfile.profilePicUrl == null
                              ? Icon(Icons.person, size: 40, color: AppColors.primaryColor)
                              : null,
                        ),
                      ).animate().fadeIn(duration: 400.ms).scale(delay: 200.ms, duration: 400.ms, begin: const Offset(0.8, 0.8)),

                      const SizedBox(height: 8),

                      Text(
                        widget.userProfile.email ?? '',
                        style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildEditForm().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First Name *', style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      TextField(
                        controller: firstNameCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Name *', style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      TextField(
                        controller: lastNameCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => _selectDate(dateOfBirthCtrl),
              child: AbsorbPointer(
                child: TextField(
                  controller: dateOfBirthCtrl,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: addressCtrl,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: locationCtrl,
              decoration: InputDecoration(
                labelText: 'Location/City',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text('Select Gender', style: GoogleFonts.nunito()),
                decoration: const InputDecoration(border: InputBorder.none),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: _selectedMaritalStatus,
                hint: Text('Marital Status', style: GoogleFonts.nunito()),
                decoration: const InputDecoration(border: InputBorder.none),
                items: _maritalStatusOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) => setState(() => _selectedMaritalStatus = value),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: alternativePhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Alternative Phone (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nationalIdNumberCtrl,
              decoration: InputDecoration(
                labelText: 'National ID Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isEmployed,
                        onChanged: (value) {
                          setState(() {
                            _isEmployed = value ?? false;
                            _showEmploymentFields = _isEmployed;
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      Text('I am currently employed', style: GoogleFonts.nunito()),
                    ],
                  ),
                  if (_showEmploymentFields) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: employerNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Employer Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: jobTitleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Job Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: employmentDurationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Duration (e.g., 2 years)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: employmentLocationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Work Location',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: employmentContactsCtrl,
                      decoration: InputDecoration(
                        labelText: 'Work Contacts',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _showNextOfKinFields,
                        onChanged: (value) {
                          setState(() => _showNextOfKinFields = value ?? false);
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      Text('Add Next of Kin (Optional)', style: GoogleFonts.nunito()),
                    ],
                  ),
                  if (_showNextOfKinFields) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: nextOfKinNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nextOfKinRelationshipCtrl,
                      decoration: InputDecoration(
                        labelText: 'Relationship',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nextOfKinPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nextOfKinEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nextOfKinAddressCtrl,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text('Cancel', style: GoogleFonts.nunito()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Save Changes', style: GoogleFonts.nunito(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}