import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/hero_card.dart';
import 'widgets/anniversary_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/recent_activity_timeline.dart';
import 'widgets/featured_memory_card.dart';
import 'widgets/future_letters_summary.dart';
import 'widgets/quote_card.dart';
import 'widgets/weekly_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeroCard(),
                  const SizedBox(height: 24),
                  
                  const AnniversaryCard(),
                  const SizedBox(height: 24),
                  
                  const StatsGrid(),
                  const SizedBox(height: 32),
                  
                  const FutureLettersSummaryWidget(),
                  const SizedBox(height: 32),
                  
                  const FeaturedMemoryCard(),
                  const SizedBox(height: 32),
                  
                  const QuoteCard(),
                  const SizedBox(height: 32),
                  
                  const WeeklySummaryCard(),
                  const SizedBox(height: 32),
                  
                  const RecentActivityTimeline(),
                  const SizedBox(height: 80), // Padding for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
