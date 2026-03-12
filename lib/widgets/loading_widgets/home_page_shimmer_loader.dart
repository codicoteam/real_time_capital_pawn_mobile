import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_time_pawn/core/utils/pallete.dart';

class HomePageShimmerLoader extends StatelessWidget {
  const HomePageShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: const Icon(Icons.menu_rounded, color: Colors.white),
        title: Text(
          'Real Time Capital',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: const [
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          period: const Duration(milliseconds: 1500),
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              // Welcome Section Shimmer
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 24, color: Colors.white),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 14, height: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content Shimmer
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Carousel Shimmer
                    _buildCarouselShimmer(),

                    const SizedBox(height: 15),

                    // Stats Cards Shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCardShimmer()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCardShimmer()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Live Auctions Header Shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 20,
                            color: Colors.white,
                          ),
                          Container(width: 60, height: 16, color: Colors.white),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Horizontal Auction Cards Shimmer
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 3,
                        itemBuilder: (context, index) => Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 13,
                                    color: Colors.white,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 60,
                                height: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 80,
                                height: 18,
                                color: Colors.white,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Container(
                                    width: 11,
                                    height: 11,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Container(
                                    width: 80,
                                    height: 9,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Latest Bid Activity Header Shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Latest Bid Card Shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Latest Loans Header Shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            height: 20,
                            color: Colors.white,
                          ),
                          Container(width: 60, height: 16, color: Colors.white),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Loan Cards Shimmer (3 items)
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: _buildLoanCardShimmer(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Recent Applications Header Shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150,
                            height: 20,
                            color: Colors.white,
                          ),
                          Container(width: 60, height: 16, color: Colors.white),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Application Cards Shimmer (2 items)
                    ...List.generate(
                      2,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: _buildApplicationCardShimmer(),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselShimmer() {
    return Column(
      children: [
        Container(
          height: 183,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 30, height: 30, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 22, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 42),
                  child: Container(height: 14, width: 200, color: Colors.white),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              width: index == 0 ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Container(width: 60, height: 24, color: Colors.white),
          const SizedBox(height: 4),
          Container(width: 80, height: 12, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildLoanCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 100, height: 16, color: Colors.white),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 50, height: 12, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 20, color: Colors.white),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 50, height: 12, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 20, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 100, height: 12, color: Colors.white),
                  Container(width: 30, height: 12, color: Colors.white),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 14, height: 14, color: Colors.white),
              const SizedBox(width: 6),
              Container(width: 100, height: 12, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 14, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 12, color: Colors.white),
                    const SizedBox(height: 2),
                    Container(width: 100, height: 11, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Container(width: 80, height: 11, color: Colors.white),
                ],
              ),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
