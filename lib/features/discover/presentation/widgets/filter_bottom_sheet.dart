import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/discover_repository.dart';
import '../providers/discover_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String? _selectedType;
  String? _selectedStatus;
  double _minRating = 0;
  final List<String> _selectedGenres = [];

  final _types = ['novel', 'manga', 'manhwa', 'webtoon'];
  final _statuses = ['ongoing', 'completed', 'hiatus'];
  final _genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Historical',
    'Isekai',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    final f = ref.read(discoverFilterProvider);
    _selectedType = f.type;
    _selectedStatus = f.status;
    _minRating = f.minRating;
    _selectedGenres.addAll(f.genres);
  }

  void _apply() {
    ref.read(discoverFilterProvider.notifier).state = DiscoverFilter(
      type: _selectedType,
      status: _selectedStatus,
      minRating: _minRating,
      genres: List.from(_selectedGenres),
    );
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _minRating = 0;
      _selectedGenres.clear();
    });
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 16),
    child: Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    'Reset',
                    style: GoogleFonts.nunito(color: AppColors.accent),
                  ),
                ),
              ],
            ),

            // Type
            _label('Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final selected = _selectedType == t;
                return ChoiceChip(
                  label: Text(t.toUpperCase()),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedType = selected ? null : t),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surfaceAlt,
                  labelStyle: GoogleFonts.nunito(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            // Status
            _label('Status'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((s) {
                final selected = _selectedStatus == s;
                return ChoiceChip(
                  label: Text(s[0].toUpperCase() + s.substring(1)),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedStatus = selected ? null : s),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surfaceAlt,
                  labelStyle: GoogleFonts.nunito(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            // Genres
            _label('Genres'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _genres.map((g) {
                final selected = _selectedGenres.contains(g);
                return FilterChip(
                  label: Text(g),
                  selected: selected,
                  onSelected: (_) => setState(
                    () => selected
                        ? _selectedGenres.remove(g)
                        : _selectedGenres.add(g),
                  ),
                  selectedColor: AppColors.accentSoft,
                  backgroundColor: AppColors.surfaceAlt,
                  checkmarkColor: AppColors.accent,
                  labelStyle: GoogleFonts.nunito(
                    color: selected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.accent.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                );
              }).toList(),
            ),

            // Min Rating
            _label('Minimum Rating: ${_minRating.toStringAsFixed(1)}★'),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.surfaceAlt,
              onChanged: (v) => setState(() => _minRating = v),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
