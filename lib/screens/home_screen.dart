import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/movie_art.dart';
import '../widgets/movie_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(moviesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(moviesProvider),
        child: movies.when(
          loading: () => const LoadingView(message: 'Loading legal catalog'),
          error: (error, stack) => ErrorStateView(
            message: 'Could not load movies.\n$error',
            onRetry: () => ref.invalidate(moviesProvider),
          ),
          data: (items) => _HomeContent(movies: items),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = movies.where((movie) => movie.isFeatured).isNotEmpty
        ? movies.firstWhere((movie) => movie.isFeatured)
        : movies.first;
    final genres = movies.expand((movie) => movie.genres).toSet().toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _FeaturedHero(movie: featured)),
        SliverToBoxAdapter(
          child: MovieRow(
            title: 'Featured legal streams',
            movies: movies.where((movie) => movie.isFeatured).toList(),
          ),
        ),
        for (final genre in genres)
          SliverToBoxAdapter(
            child: MovieRow(
              title: genre,
              movies: movies
                  .where((movie) => movie.genres.contains(genre))
                  .toList(),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
      ],
    );
  }
}

class _FeaturedHero extends ConsumerWidget {
  const _FeaturedHero({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref
        .watch(watchlistIdsProvider)
        .maybeWhen(data: (items) => items, orElse: () => <String>{});
    final isSaved = ids.contains(movie.id);

    return SizedBox(
      height: 480,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MovieArt(
            url: movie.backdropUrl,
            title: movie.title,
            borderRadius: 0,
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  AppTheme.ink.withValues(alpha: 0.55),
                  AppTheme.ink,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'LUMA',
                        style: TextStyle(
                          color: AppTheme.flame,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.go('/search'),
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.44),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      movie.videoType.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.metaLine,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/watch/${movie.id}'),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        onPressed: () => ref
                            .read(libraryActionsProvider)
                            .toggleWatchlist(movie),
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        tooltip: isSaved
                            ? 'Remove from watchlist'
                            : 'Save title',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
