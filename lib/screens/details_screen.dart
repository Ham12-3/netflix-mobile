import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/movie_art.dart';

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = ref.watch(movieByIdProvider(movieId));
    final watchlist = ref
        .watch(watchlistIdsProvider)
        .maybeWhen(data: (ids) => ids, orElse: () => <String>{});

    return Scaffold(
      body: movie.when(
        loading: () => const LoadingView(message: 'Loading title'),
        error: (error, stack) => ErrorStateView(message: error.toString()),
        data: (item) {
          if (item == null) {
            return const ErrorStateView(message: 'Movie not found.');
          }
          final isSaved = watchlist.contains(item.id);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      MovieArt(
                        url: item.backdropUrl,
                        title: item.title,
                        borderRadius: 0,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.ink.withValues(alpha: 0.92),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.list(
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.metaLine,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push('/watch/${item.id}'),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Play'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: () => ref
                              .read(libraryActionsProvider)
                              .toggleWatchlist(item),
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          tooltip: isSaved
                              ? 'Remove from watchlist'
                              : 'Add to watchlist',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(item.description),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final genre in item.genres)
                          Chip(
                            label: Text(genre),
                            backgroundColor: AppTheme.panelSoft,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Source',
                      body: item.sourceName,
                    ),
                    _InfoTile(
                      icon: Icons.policy_outlined,
                      title: 'License note',
                      body: item.licenseNote,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.mint),
      title: Text(title),
      subtitle: Text(body),
    );
  }
}
