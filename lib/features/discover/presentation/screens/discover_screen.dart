import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_track/features/title_detail/presentation/screens/title_detail_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/seed_data.dart';
import '../providers/discover_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/horizontal_title_list.dart';
import '../widgets/section_header.dart';
import '../widgets/title_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Seed Firestore on first launch
    SeedData.seedTitles();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filter = ref.watch(discoverFilterProvider);
    final trending = ref.watch(trendingProvider);
    final newReleases = ref.watch(newReleasesProvider);
    final topRated = ref.watch(topRatedProvider);
    final filtered = ref.watch(filteredTitlesProvider);
    final isSearching = searchQuery.isNotEmpty || filter.hasFilters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your next great read',
                      style: GoogleFonts.nunito(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search + Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) =>
                                ref.read(searchQueryProvider.notifier).state =
                                    v,
                            decoration: InputDecoration(
                              hintText: 'Search titles...',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        ref
                                                .read(
                                                  searchQueryProvider.notifier,
                                                )
                                                .state =
                                            '';
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _openFilters,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: filter.hasFilters
                                  ? AppColors.accent
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: filter.hasFilters
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Search / Filter Results ───────────────────
            if (isSearching) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: searchQuery.isNotEmpty
                      ? 'Results for "$searchQuery"'
                      : 'Filtered Results',
                ),
              ),
              SliverToBoxAdapter(
                child: filtered.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  data: (titles) => titles.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  color: AppColors.textSecondary,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No titles found',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.55,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: titles.length,
                            itemBuilder: (_, i) => TitleCard(
                              title: titles[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TitleDetailScreen(title: titles[i]),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],

            // ── Default Sections ─────────────────────────
            if (!isSearching) ...[
              // Trending
              SliverToBoxAdapter(
                child: SectionHeader(title: '🔥 Trending This Week'),
              ),
              SliverToBoxAdapter(
                child: HorizontalTitleList(
                  titlesAsync: trending,
                  onTap: (title) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TitleDetailScreen(title: title),
                    ),
                  ),
                ),
              ),

              // New Releases
              SliverToBoxAdapter(child: SectionHeader(title: '✨ New Releases')),
              SliverToBoxAdapter(
                child: HorizontalTitleList(
                  titlesAsync: newReleases,
                  onTap: (title) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TitleDetailScreen(title: title),
                    ),
                  ),
                ),
              ),

              // Top Rated
              SliverToBoxAdapter(child: SectionHeader(title: '⭐ Top Rated')),
              SliverToBoxAdapter(
                child: topRated.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (titles) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: titles.length,
                      itemBuilder: (_, i) => TitleCard(
                        title: titles[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TitleDetailScreen(title: titles[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }
}
