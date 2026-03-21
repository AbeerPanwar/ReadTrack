import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_track/features/title_detail/data/title_detail_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/badge_chip.dart';
import '../../../discover/domain/title_model.dart';
import '../../../library/data/library_repository.dart';
import '../../../library/domain/reading_entry_model.dart';
import '../../domain/review_model.dart';
import '../providers/title_detail_provider.dart';
import '../widgets/add_to_library_sheet.dart';
import '../widgets/review_card.dart';

class TitleDetailScreen extends ConsumerStatefulWidget {
  final TitleModel title;
  const TitleDetailScreen({super.key, required this.title});

  @override
  ConsumerState<TitleDetailScreen> createState() =>
      _TitleDetailScreenState();
}

class _TitleDetailScreenState extends ConsumerState<TitleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _synopsisExpanded = false;
  ReadingEntryModel? _libraryEntry;
  bool _isWritingReview = false;
  final _reviewCtrl = TextEditingController();
  int _reviewRating = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLibraryEntry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLibraryEntry() async {
    final entry = await ref
        .read(libraryRepositoryProvider)
        .getEntry(widget.title.id);
    if (mounted) setState(() => _libraryEntry = entry);
  }

  void _openAddToLibrary() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: AddToLibrarySheet(
          title: widget.title,
          existingEntry: _libraryEntry,
        ),
      ),
    );
    if (result != null) _loadLibraryEntry();
  }

  Future<void> _submitReview() async {
    if (_reviewCtrl.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    final review = ReviewModel(
      id:        '',
      userId:    user.uid,
      username:  user.displayName ?? 'Reader',
      avatarUrl: user.photoURL ?? '',
      rating:    _reviewRating,
      comment:   _reviewCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref
        .read(titleDetailRepositoryProvider)
        .addReview(titleId: widget.title.id, review: review);
    _reviewCtrl.clear();
    setState(() => _isWritingReview = false);
    ref.invalidate(reviewsProvider(widget.title.id));
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewsProvider(widget.title.id));
    final similar = ref.watch(similarTitlesProvider({
      'titleId': widget.title.id,
      'genres':  widget.title.genres,
    }));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred background
                  CachedNetworkImage(
                    imageUrl: widget.title.coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.surface),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                        color: Colors.black.withOpacity(0.5)),
                  ),
                  // Cover + info row
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cover
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: widget.title.coverUrl,
                            width: 110,
                            height: 160,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 110,
                              height: 160,
                              color: AppColors.surface,
                              child: const Icon(Icons.menu_book_rounded,
                                  color: AppColors.textSecondary,
                                  size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BadgeChip(type: widget.title.type),
                              const SizedBox(height: 8),
                              Text(
                                widget.title.title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.title.author,
                                style: GoogleFonts.nunito(
                                    color: Colors.white70,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Row(children: [
                                RatingBarIndicator(
                                  rating: widget.title.averageRating,
                                  itemBuilder: (_, __) => const Icon(
                                      Icons.star,
                                      color: AppColors.accent),
                                  itemCount: 5,
                                  itemSize: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.title.averageRating} (${widget.title.totalRatings})',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white70,
                                      fontSize: 12),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Add to Library Button ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddToLibrary,
                    icon: Icon(_libraryEntry != null
                        ? Icons.edit_rounded
                        : Icons.add_rounded),
                    label: Text(_libraryEntry != null
                        ? 'In Library · ${_libraryEntry!.status.replaceAll('_', ' ')}'
                        : 'Add to Library'),
                  ),
                ),
              ]),
            ),
          ),

          // ── Quick Info Row ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoChip(Icons.format_list_numbered_rounded,
                      '${widget.title.totalChapters} Ch.'),
                  _infoChip(Icons.calendar_today_rounded,
                      '${widget.title.releaseYear}'),
                  _infoChip(
                    widget.title.status == 'ongoing'
                        ? Icons.radio_button_checked
                        : Icons.check_circle_outline,
                    widget.title.status[0].toUpperCase() +
                        widget.title.status.substring(1),
                  ),
                ],
              ),
            ),
          ),

          // ── Genre Tags ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: widget.title.genres
                    .map((g) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(g,
                              style: GoogleFonts.nunito(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ))
                    .toList(),
              ),
            ),
          ),

          // ── Tabs ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Similar'),
                ],
              ),
            ),
          ),

          // ── Tab Content ───────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 500,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Synopsis',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        Text(
                          widget.title.synopsis,
                          maxLines:
                              _synopsisExpanded ? null : 4,
                          overflow: _synopsisExpanded
                              ? null
                              : TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() =>
                              _synopsisExpanded = !_synopsisExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _synopsisExpanded
                                  ? 'Show less'
                                  : 'Read more',
                              style: GoogleFonts.nunito(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reviews tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Write review button
                        OutlinedButton.icon(
                          icon: const Icon(Icons.rate_review_outlined,
                              color: AppColors.accent),
                          label: Text('Write a Review',
                              style: GoogleFonts.nunito(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                          onPressed: () => setState(
                              () => _isWritingReview = !_isWritingReview),
                        ),

                        // Write review form
                        if (_isWritingReview) ...[
                          const SizedBox(height: 16),
                          Row(children: List.generate(5, (i) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _reviewRating = i + 1),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 6),
                                child: Icon(
                                  i < _reviewRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppColors.accent,
                                  size: 28,
                                ),
                              ),
                            );
                          })),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _reviewCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Share your thoughts...',
                              hintStyle: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _submitReview,
                            child: const Text('Submit Review'),
                          ),
                        ],

                        const SizedBox(height: 16),
                        reviews.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.accent)),
                          error: (e, _) => Text('Error: $e',
                              style: const TextStyle(
                                  color: AppColors.error)),
                          data: (list) => list.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text('No reviews yet.\nBe the first!',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                            color:
                                                AppColors.textSecondary)),
                                  ),
                                )
                              : Column(
                                  children: list
                                      .map((r) => ReviewCard(review: r))
                                      .toList(),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Similar tab
                  similar.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent)),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (titles) => GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: titles.length,
                      itemBuilder: (_, i) {
                        final t = titles[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TitleDetailScreen(title: t),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: t.coverUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      Container(
                                    height: 120,
                                    color: AppColors.surface,
                                    child: const Icon(
                                        Icons.menu_book_rounded,
                                        color:
                                            AppColors.textSecondary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(t.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.nunito(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}