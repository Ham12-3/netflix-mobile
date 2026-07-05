import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/movie_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(moviesProvider);
    final ids = ref.watch(watchlistIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: movies.when(
        loading: () => const LoadingView(message: 'Loading watchlist'),
        error: (error, stack) => ErrorStateView(message: error.toString()),
        data: (items) => ids.when(
          loading: () => const LoadingView(message: 'Syncing saved titles'),
          error: (error, stack) => ErrorStateView(message: error.toString()),
          data: (savedIds) {
            final saved = items
                .where((movie) => savedIds.contains(movie.id))
                .toList();
            if (saved.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Your saved legal streams will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 286,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: saved.length,
              itemBuilder: (context, index) => MovieCard(movie: saved[index]),
            );
          },
        ),
      ),
    );
  }
}
