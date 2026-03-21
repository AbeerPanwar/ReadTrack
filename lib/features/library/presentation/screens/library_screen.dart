import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/library_provider.dart';
import '../widgets/library_entry_card.dart';
import '../widgets/stats_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  static const _tabs = [
    {'label': 'Reading', 'status': 'reading'},
    {'label': 'Completed', 'status': 'completed'},
    {'label': 'On Hold', 'status': 'on_hold'},
    {'label': 'Dropped', 'status': 'dropped'},
    {'label': 'Plan to Read', 'status': 'plan_to_read'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(libraryStatsProvider);

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'My Library',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Stats card
              stats.when(
                loading: () => const SizedBox(height: 8),
                error: (_, __) => const SizedBox(height: 8),
                data: (s) => StatsCard(stats: s),
              ),

              // Tab bar
              TabBar(
                isScrollable: true,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  children: _tabs.map((t) {
                    return _LibraryTabView(status: t['status']!);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryTabView extends ConsumerWidget {
  final String status;
  const _LibraryTabView({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(libraryByStatusProvider(status));

    return entries.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      data: (list) => list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 56,
                    color: AppColors.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nothing here yet',
                    style: GoogleFonts.nunito(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add titles from the Discover screen',
                    style: GoogleFonts.nunito(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: list.length,
              itemBuilder: (_, i) => LibraryEntryCard(entry: list[i]),
            ),
    );
  }
}
