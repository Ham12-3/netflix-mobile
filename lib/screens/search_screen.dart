import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(moviesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: movies.when(
        loading: () => const LoadingView(message: 'Loading catalog'),
        error: (error, stack) => ErrorStateView(
          message: 'Search is unavailable.\n$error',
          onRetry: () => ref.invalidate(moviesProvider),
        ),
        data: (items) {
          final results = _filter(items);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Title, genre, source',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              if (results.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No matching legal titles yet.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.builder(
                    itemCount: results.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 286,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      return MovieCard(movie: results[index]);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Movie> _filter(List<Movie> movies) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return movies;
    return movies.where((movie) {
      final haystack = [
        movie.title,
        movie.description,
        movie.sourceName,
        ...movie.genres,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }
}
