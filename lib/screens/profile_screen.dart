import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.flame,
                  child: Text(
                    (user?.label.isNotEmpty ?? false)
                        ? user!.label.characters.first.toUpperCase()
                        : 'L',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.label ?? 'Viewer',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(
              AppConfig.hasSupabaseConfig ? 'Supabase connected' : 'Demo mode',
            ),
            subtitle: Text(
              AppConfig.hasSupabaseConfig
                  ? 'Auth, movies, watchlist, and history use Supabase.'
                  : 'Set SUPABASE_URL and SUPABASE_ANON_KEY to use your backend.',
            ),
          ),
          history.when(
            loading: () => const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading history'),
            ),
            error: (error, stack) => ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(error.toString()),
            ),
            data: (items) => ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Watch history'),
              subtitle: Text('${items.length} title(s) with saved progress'),
            ),
          ),
          const Divider(height: 32),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
