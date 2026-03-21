import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/discover_repository.dart';
import '../../domain/title_model.dart';

// Filter state
final discoverFilterProvider = StateProvider<DiscoverFilter>(
  (ref) => const DiscoverFilter(),
);

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Data providers
final trendingProvider = FutureProvider<List<TitleModel>>((ref) {
  return ref.watch(discoverRepositoryProvider).getTrending();
});

final newReleasesProvider = FutureProvider<List<TitleModel>>((ref) {
  return ref.watch(discoverRepositoryProvider).getNewReleases();
});

final topRatedProvider = FutureProvider<List<TitleModel>>((ref) {
  return ref.watch(discoverRepositoryProvider).getTopRated();
});

final filteredTitlesProvider = FutureProvider<List<TitleModel>>((ref) {
  final filter = ref.watch(discoverFilterProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isNotEmpty) {
    return ref.watch(discoverRepositoryProvider).search(query);
  }
  if (filter.hasFilters) {
    return ref.watch(discoverRepositoryProvider).getFiltered(filter);
  }
  return Future.value([]);
});
