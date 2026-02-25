// about_mngmt_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutController extends GetxController {
  static AboutController get to => Get.find();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // About content from the BRD
  final RxString _companyOverview = ''.obs;
  String get companyOverview => _companyOverview.value;

  final RxString _missionStatement = ''.obs;
  String get missionStatement => _missionStatement.value;

  final RxString _visionStatement = ''.obs;
  String get visionStatement => _visionStatement.value;

  final RxList<Map<String, dynamic>> _coreValues = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get coreValues => _coreValues;

  final RxList<Map<String, dynamic>> _keyFeatures =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get keyFeatures => _keyFeatures;

  final RxList<Map<String, String>> _stats = <Map<String, String>>[].obs;
  List<Map<String, String>> get stats => _stats;

  @override
  void onInit() {
    super.onInit();
    loadAboutContent();
  }

  Future<void> loadAboutContent() async {
    _isLoading.value = true;

    // Simulate loading delay (remove when real data source is available)
    await Future.delayed(const Duration(milliseconds: 300));

    // Load content from BRD
    _companyOverview.value =
        "The pawn business has evolved significantly in recent years, transforming from a traditional, often stigmatized industry into a modern financial service that caters to a diverse clientele. Offering loans against assets, pawnshops provide a quick and accessible solution for individuals seeking immediate cash without the lengthy processes typically associated with banks.";

    _missionStatement.value =
        "To provide a vibrant and efficient pawn service tailored to the unique needs of the creative industry, enhancing cash flow while maintaining the integrity of the assets involved.";

    _visionStatement.value =
        "To position ourselves as a legitimate and convenient choice for those needing quick cash, redefining our role in the financial landscape through the effective use of modern systems and technology.";

    _coreValues.value = [
      {
        'title': 'Transparency',
        'description':
            'We maintain high standards of transparency in all our transactions, ensuring customers understand loan terms, interest rates, and asset valuations clearly.',
        'icon': Icons.visibility_outlined,
      },
      {
        'title': 'Integrity',
        'description':
            'We handle all assets with the utmost care and respect, maintaining the integrity of every item entrusted to us.',
        'icon': Icons.verified_outlined,
      },
      {
        'title': 'Innovation',
        'description':
            'We embrace modern technology to streamline operations, enhance customer experiences, and provide innovative financial solutions.',
        'icon': Icons.lightbulb_outline,
      },
      {
        'title': 'Customer Focus',
        'description':
            'We build strong relationships with clients through personalized service and a genuine commitment to meeting their financial needs.',
        'icon': Icons.people_outline,
      },
    ];

    _keyFeatures.value = [
      {
        'title': 'Asset Management',
        'description':
            'Comprehensive tools for submitting, tracking, and managing assets for pawn, with detailed valuation and documentation capabilities.',
        'icon': Icons.inventory_outlined,
      },
      {
        'title': 'Loan Management',
        'description':
            'End-to-end loan processing with automated interest calculations, payment tracking, and flexible repayment options.',
        'icon': Icons.account_balance_wallet_outlined,
      },
      {
        'title': 'Auction Module',
        'description':
            'Real-time bidding platform with registration deposit fees, bid management, and automated notifications.',
        'icon': Icons.gavel_outlined,
      },
      {
        'title': 'Secure Payments',
        'description':
            'Integrated payment processing supporting multiple methods including mobile money, bank transfers, and card payments.',
        'icon': Icons.payment_outlined,
      },
      {
        'title': 'Customer Support',
        'description':
            'Multi-channel support with ticketing system, live chat, and comprehensive knowledge base for customer assistance.',
        'icon': Icons.support_agent_outlined,
      },
      {
        'title': 'Reporting & Analytics',
        'description':
            'Detailed reports on inventory, loan performance, auction revenue, and customer engagement for data-driven decisions.',
        'icon': Icons.analytics_outlined,
      },
    ];

    _stats.value = [
      {'label': 'Active Users', 'value': '500+', 'icon': '👥'},
      {'label': 'Assets Pawned', 'value': '1,200+', 'icon': '📦'},
      {'label': 'Loans Processed', 'value': '₵2.5M+', 'icon': '💰'},
      {'label': 'Auctions Held', 'value': '48+', 'icon': '🔨'},
    ];

    _isLoading.value = false;
  }

  // Helper method to get version info
  String get appVersion => '1.0.0';
}
