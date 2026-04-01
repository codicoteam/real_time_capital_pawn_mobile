import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';
import 'package:real_time_pawn/features/support_mngmt/controllers/support_mngmt_controller.dart';
import 'package:real_time_pawn/features/support_mngmt/helpers/support_mngmt_helper.dart';
import 'package:real_time_pawn/models/support_ticket_model.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen>
    with TickerProviderStateMixin {
  final SupportTicketController _controller = Get.put(
    SupportTicketController(),
  );
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TicketCategory _selectedCategory = TicketCategory.general;

  int _currentStep = 0;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller.clearMessages();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _animateToStep(int step) {
    _slideController.reset();
    _fadeController.reset();
    setState(() => _currentStep = step);
    _slideController.forward();
    _fadeController.forward();
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      final error = SupportTicketHelper.validateTicketForm(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (error != null) {
        SupportTicketHelper.showError(error);
        return;
      }

      final success = await SupportTicketHelper.createNewTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: TicketPriority.medium,
      );

      if (success) Get.back();
    }
  }

  // ── Category config ──────────────────────────────────────────────
  static const _categories = [
    _CategoryItem(TicketCategory.loan, 'Loan', Icons.account_balance_outlined),
    _CategoryItem(
      TicketCategory.payment,
      'Payment',
      Icons.credit_card_outlined,
    ),
    _CategoryItem(TicketCategory.auction, 'Auction', Icons.gavel_outlined),
    _CategoryItem(TicketCategory.account, 'Account', Icons.person_outline),
    _CategoryItem(
      TicketCategory.technical,
      'Technical',
      Icons.terminal_outlined,
    ),
    _CategoryItem(TicketCategory.general, 'General', Icons.help_outline),
  ];

  // ── Steps ─────────────────────────────────────────────────────────
  static const _stepTitles = ['Category', 'Details'];
  static const _stepSubtitles = ['What\'s this about?', 'Tell us more'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Header — mirrors TicketDetailScreen's gradient header ─────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Ticket',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                Text(
                  _stepSubtitles[_currentStep],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Indicator — white bar matching app card style ────────────
  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: List.generate(_stepTitles.length, (i) {
          final isCompleted = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i < _currentStep) _animateToStep(i);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isActive ? 28 : 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isCompleted || isActive
                                    ? AppColors.primaryColor
                                    : AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isActive || isCompleted
                                      ? AppColors.primaryColor
                                      : AppColors.borderColor,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        '${i + 1}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isActive
                                              ? Colors.white
                                              : AppColors.subtextColor,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _stepTitles[i],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isActive || isCompleted
                                    ? AppColors.textColor
                                    : AppColors.subtextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: isCompleted || isActive
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _stepTitles.length - 1) const SizedBox(width: 8),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step Router ───────────────────────────────────────────────────
  Widget _buildCurrentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: switch (_currentStep) {
        0 => _buildCategoryStep(),
        1 => _buildDetailsStep(),
        _ => const SizedBox.shrink(),
      },
    );
  }

  // ── STEP 1: Category ──────────────────────────────────────────────
  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the area\nthat needs attention.',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat.value;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.12)
                            : AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        cat.icon,
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.subtextColor,
                        size: 18,
                      ),
                    ),
                    Text(
                      cat.label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── STEP 2: Details ───────────────────────────────────────────────
  Widget _buildDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Describe your issue\nin detail.',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Summary pill — showing only category now
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _categories
                      .firstWhere((c) => c.value == _selectedCategory)
                      .icon,
                  color: AppColors.primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _categories
                      .firstWhere((c) => c.value == _selectedCategory)
                      .label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _buildFieldLabel('Subject'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _subjectController,
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 14,
            ),
            decoration: _inputDecoration('Brief description of your issue'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a subject';
              if (v.length < 5) return 'Subject must be at least 5 characters';
              return null;
            },
          ),
          const SizedBox(height: 18),

          _buildFieldLabel('Description'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            style: GoogleFonts.poppins(
              color: AppColors.textColor,
              fontSize: 14,
              height: 1.6,
            ),
            maxLines: 7,
            decoration: _inputDecoration(
              'Describe the issue in full detail.\nInclude dates, amounts, error messages…',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a description';
              if (v.length < 10)
                return 'Description must be at least 10 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Info card — mirrors _buildSectionCard from TicketDetailScreen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.schedule_outlined,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Response within 24–48 hours',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You\'ll receive a ticket ID and our team will follow up via email or phone.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.subtextColor,
                          height: 1.5,
                        ),
                      ),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.subtextColor,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.subtextColor.withOpacity(0.6),
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4757)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4757), width: 1.5),
      ),
      errorStyle: GoogleFonts.poppins(
        color: const Color(0xFFFF4757),
        fontSize: 12,
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final isLastStep = _currentStep == _stepTitles.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            GestureDetector(
              onTap: () => _animateToStep(_currentStep - 1),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: isLastStep
                ? Obx(() => _buildSubmitButton())
                : _buildNextButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () => _animateToStep(_currentStep + 1),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = _controller.isCreatingTicket.value;
    return GestureDetector(
      onTap: isLoading ? null : _submitTicket,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.85),
                  ],
                ),
          color: isLoading ? AppColors.primaryColor.withOpacity(0.4) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Ticket',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Data Classes ──────────────────────────────────────────────────────
class _CategoryItem {
  final TicketCategory value;
  final String label;
  final IconData icon;
  const _CategoryItem(this.value, this.label, this.icon);
}
